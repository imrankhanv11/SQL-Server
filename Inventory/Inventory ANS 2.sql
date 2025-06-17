--SELECT + CASE + Expressions
--1.	Show all products along with a status column: 'Expensive' if price > 1000, 'Moderate' if between 500–1000, and 'Cheap' otherwise.
SELECT 
    name,
    price,
    CASE 
        WHEN price > 1000 THEN 'Expensive'
        WHEN price BETWEEN 500 AND 1000 THEN 'Moderate'
        ELSE 'Cheap'
    END AS PriceStatus
FROM Products;

--Aggregate Functions + Filtering
--2.	Find the top 2 suppliers (by total purchases) in each year.
WITH SupplierTotals AS (
    SELECT 
        S.supplier_id,
        S.name AS SupplierName,
        YEAR(P.purchase_date) AS PurchaseYear,
        SUM(P.total_cost) AS TotalPurchase,
        ROW_NUMBER() OVER (
            PARTITION BY YEAR(P.purchase_date) 
            ORDER BY SUM(P.total_cost) DESC
        ) AS rn
    FROM 
        Suppliers S
    JOIN 
        Purchases P ON S.supplier_id = P.supplier_id
    GROUP BY 
        S.supplier_id, S.name, YEAR(P.purchase_date)
)
SELECT 
    SupplierName, PurchaseYear, TotalPurchase
FROM 
    SupplierTotals
WHERE 
    rn <= 2
ORDER BY 
    PurchaseYear, TotalPurchase DESC;


--3.	For each customer, show their total spending and the number of different products purchased.
SELECT C.NAME, SUM(S.TOTAL_PRICE) AS SPENDING, COUNT(DISTINCT SD.product_id) AS PRODUCTCOUNT
FROM Customers C
LEFT JOIN Sales S ON S.customer_id = C.customer_id
JOIN SalesDetails SD ON SD.sale_id = S.sale_id
GROUP BY C.customer_id, C.name

--GROUP BY + HAVING (Advanced)
--4.	List users who handled more than 3 inventory actions in a single day.
SELECT U.FULL_NAME
FROM Users U 
LEFT JOIN Inventory_Log IL ON IL.user_id = U.user_id
GROUP BY U.user_id, U.full_name, IL.action_date
HAVING COUNT(*) > 3;

--5.	Show product categories where the average rating across all their products is below 3.5.
SELECT C.category_name
FROM Categories C
LEFT JOIN Products P ON P.category_id = C.category_id
LEFT JOIN ProductReviews PR ON PR.product_id = P.product_id
GROUP BY C.category_name
HAVING AVG(PR.rating) < 3.5;

--🔹 4. JOINs (Complex)
--6.	List all products and the total quantity sold, including products that have never been sold.
SELECT P.NAME, SUM(SD.QUANTITY) AS SOLD
FROM Products P
LEFT JOIN SalesDetails SD ON SD.product_id = P.product_id
GROUP BY P.product_id, P.name;

--7.	Get a list of suppliers who never supplied products that were sold.
SELECT DISTINCT S.name AS SupplierName
FROM Suppliers S
JOIN Purchases P ON S.supplier_id = P.supplier_id
LEFT JOIN SalesDetails SD ON SD.product_id = P.product_id
WHERE SD.product_id IS NULL;

--Subqueries 
--8.	Find the name of the product with the second highest average rating.
WITH AvgRatings AS (
    SELECT 
        P.product_id,
        P.name AS ProductName,
        AVG(PR.rating) AS AvgRating
    FROM Products P
    JOIN ProductReviews PR ON PR.product_id = P.product_id
    GROUP BY P.product_id, P.name
),
RankedRatings AS (
    SELECT *,
        DENSE_RANK() OVER (ORDER BY AvgRating DESC) AS rating_rank
    FROM AvgRatings
)
SELECT ProductName, AvgRating
FROM RankedRatings
WHERE rating_rank = 2;

--9.	List products that were never purchased and never reviewed.
SELECT P.NAME
FROM Products P 
LEFT JOIN Purchases PS ON PS.product_id = P.product_id
LEFT JOIN ProductReviews PR ON PR.product_id = P.product_id
WHERE PR.review_id IS NULL AND PS.purchase_id IS NULL;

SELECT P.NAME
FROM Products P
WHERE P.product_id NOT IN ( SELECT P.product_id FROM ProductReviews PR JOIN Purchases PS ON PS.product_id = PR.product_id )

--10.	Find warehouses that store every product from category X (relational division).
SELECT W.warehouse_id
FROM Warehouses W
WHERE NOT EXISTS (
    SELECT 1
    FROM Products P
    WHERE P.category_id = 3
    AND NOT EXISTS (
        SELECT 1
        FROM ProductWarehouseStock PWS
        WHERE PWS.product_id = P.product_id
        AND PWS.warehouse_id = W.warehouse_id
    )
);--------------------------------------------------------------------

--Views
--11.	Create a view that returns, for each product total sold, and remaining quantity.
CREATE VIEW vw_prouductstockdetails
AS
SELECT P.NAME, SUM(SD.QUANTITY) AS SOLD, SUM(PWS.QUANTITY_IN_STOCK) AS REMAINING_QUANTITY
FROM Products P
LEFT JOIN SalesDetails SD ON SD.product_id = P.product_id
LEFT JOIN ProductWarehouseStock PWS ON PWS.product_id = P.product_id
GROUP BY P.product_id,P.name;

--12.	Create a view to show monthly purchase totals per supplier, including months with no purchases.
CREATE OR ALTER VIEW vw_purchasedetails_month
AS
SELECT 
    S.name AS SupplierName,
    YEAR(PS.purchase_date) AS PurchaseYear,
    MONTH(PS.purchase_date) AS PurchaseMonth,
    SUM(PS.total_cost) AS TotalCost
FROM 
    Suppliers S
LEFT JOIN 
    Purchases PS ON PS.supplier_id = S.supplier_id
GROUP BY 
    S.name, YEAR(PS.purchase_date), MONTH(PS.purchase_date);

--🔹 7. Stored Procedures
--13.	Create a procedure to get all sales by customer ID and optional date range.
CREATE PROCEDURE sp_costomerpuchase
	@customerId INT
AS
BEGIN
	BEGIN TRY
		IF NOT EXISTS ( SELECT 1 FROM Customers WHERE customer_id = @customerId )
		BEGIN
			RAISERROR('CUSTOMER NOT FOUND',16,1);
			RETURN
		END
		SELECT C.NAME, S.sale_id, P.NAME
		FROM Customers C
		LEFT JOIN Sales S ON S.customer_id = C.customer_id
		LEFT JOIN SalesDetails SD ON SD.sale_id = S.sale_id
		LEFT JOIN Products P ON P.product_id = SD.product_id
		WHERE C.customer_id = @customerId
	END TRY

	BEGIN CATCH
		DECLARE @msg NVARCHAR(400), @line INT;
        SELECT 
            @msg = ERROR_MESSAGE(),
            @line = ERROR_LINE();

        RAISERROR('Error: %s at line %d', 16, 1, @msg, @line);	
	END CATCH
END

--14.	Create a procedure to insert a review only if no previous review exists for that product and customer.
CREATE PROCEDURE sp_productreview
	@customerID INT,
	@prouductID INT,
	@rating INT,
	@commands VARCHAR(200),
	@reviewDate DATE
AS
BEGIN
	BEGIN TRY
		IF NOT EXISTS ( SELECT 1 FROM ProductReviews WHERE customer_id = @customerID AND product_id =@prouductID )
		BEGIN
			RAISERROR('ALREADY REVIEWD THE PRODUCT',16,1);
			RETURN;
		END

		INSERT INTO ProductReviews ( customer_id, product_id, rating, comments, review_date )
		VALUES ( @customerID, @prouductID, @rating, @commands, @reviewDate)
	END TRY

	BEGIN CATCH
		DECLARE @MESSAGE VARCHAR(200), @LINE INT

		SELECT @MESSAGE = ERROR_MESSAGE(), @LINE = ERROR_LINE()

		RAISERROR(@MESSAGE,16,1);
	END CATCH
END

--Functions (Scalar & Table-Valued)
--15.	Write a scalar function that returns 'High', 'Medium', or 'Low' based on stock quantity.
CREATE FUNCTION dbo.stockquantityvalue ( @quanity INT)
RETURNS VARCHAR(10)
AS
BEGIN
	DECLARE @VALUE varchar(10)
	IF @quanity > 10 
		SET @VALUE = 'High'
	ELSE IF @quanity BETWEEN 3 AND 4 
		SET @VALUE = 'Medium'
	ELSE 
		SET @VALUE ='Low'	

	RETURN @VALUE;
END

--16.	Create a table-valued function that returns all sales of a given product with customer names.
CREATE FUNCTION fn_prouductsalewithcustomer ( @productId INT )
RETURNS TABLE
AS
RETURN
	SELECT P.name AS PRODUCTNAME, C.name AS CUSTOMERNAME, S.sale_id, SD.quantity, S.sale_date
	FROM Products P 
	JOIN SalesDetails SD ON SD.product_id = P.product_id
	JOIN Sales S ON S.sale_id = SD.sale_id
	JOIN Customers C ON C.customer_id = S.customer_id
	WHERE P.product_id =@productId

SELECT * FROM dbo.fn_prouductsalewithcustomer(1);

--Triggers
--17.	Write a trigger that prevents inserting a purchase if the supplier contact info is null.
CREATE OR ALTER TRIGGER trg_preventPurchaseIfNoContact
ON Purchases
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM inserted i
        JOIN Suppliers S ON i.supplier_id = S.supplier_id
        WHERE S.contact_info IS NULL
    )
    BEGIN
        RAISERROR('Purchase prevented: Supplier contact info is missing.', 16, 1);
        RETURN;
    END
    INSERT INTO Purchases (purchase_id, product_id, supplier_id, quantity, purchase_date, total_cost, user_id)
    SELECT 
        i.purchase_id, i.product_id, i.supplier_id, i.quantity, 
        i.purchase_date, i.total_cost, i.user_id
    FROM inserted i;
END;

--Indexes + Performance
--19.	Create a covering index on SalesDetails(product_id, sale_id, price) to improve reporting queries.
CREATE NONCLUSTERED INDEX ix_salesdetails 
ON Salesdetails(product_id, sale_id, price);

--20.	Create a filtered index on Inventory_Log(action) where action = 'SALE'.
CREATE INDEX ix_INLog_sale
ON Inventory_Log(action)
WHERE ACTION = 'SALE';