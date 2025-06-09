-- JOIN Questions

--1. List all products with their category names.
SELECT P.name, C.category_name
FROM Products P 
LEFT JOIN Categories C ON C.category_id = P.category_id;

--2. Show all sales along with the customer name and the user who made the sale.
SELECT s.sale_id, c.name, u.username
FROM Sales s 
LEFT JOIN Customers C ON C.customer_id = S.customer_id
LEFT JOIN Users U ON U.user_id = S.user_id;

--3. List all product reviews with customer name and product name.
SELECT C.name, p.name, pr.rating, pr.comments
FROM ProductReviews pr 
LEFT JOIN Products P ON P.product_id = pr.product_id
JOIN Customers C ON C.customer_id = PR.CUSTOMER_ID;

--4. Display all purchases along with supplier name and product name.
SELECT P.PURCHASE_ID, S.NAME AS SUPPLIER_NAME , PR.NAME AS PRODUCT_NAME
FROM Purchases P
LEFT JOIN Suppliers S ON S.supplier_id = P.supplier_id 
JOIN Products PR ON PR.product_id = P.product_id;

--5. Show warehouse stock details with product and warehouse names.
SELECT P.name, W.name, PWS.quantity_in_stock
FROM Products P 
LEFT JOIN ProductWarehouseStock PWS ON PWS.product_id = p.product_id
JOIN Warehouses W ON W.warehouse_id = PWS.warehouse_id;

--6. Get all inventory log entries with the product name, warehouse name, and user who performed the action.
SELECT p.name, w.name, i.action, u.username
FROM Inventory_Log i
LEFT JOIN Products P ON P.product_id = I.product_id 
LEFT JOIN Warehouses w on w.warehouse_id = i.warehouse_id 
LEFT JOIN Users U ON I.user_id = U.user_id;

--7. List users along with their roles.
SELECT U.username, r.role_name
FROM Users U
LEFT JOIN ROLES R ON R.ROLE_ID = U.ROLE_ID;

--8. Show permissions assigned to each user via roles.
SELECT U.username, r.role_name, p.permission_name
FROM Users U 
LEFT JOIN Roles r ON U.role_id = r.role_id
LEFT JOIN RolePermissions RP ON RP.role_id = r.role_id
LEFT JOIN Permissions p on p.permission_id = rp.permission_id;

---JOIN with GROUP BY Questions

--9. Find the total sales quantity for each product.
SELECT p.name, SUM(sd.quantity) AS TOTAL_SALE_QUANTITY
FROM Products P 
LEFT JOIN SalesDetails SD ON SD.product_id = P.product_id
GROUP BY P.product_id, P.name;

--10. Get the total purchase quantity and total cost per supplier.
SELECT s.name, SUM(P.QUANTITY), SUM(P.total_cost)
FROM Purchases P 
LEFT JOIN Suppliers S ON S.supplier_id = P.supplier_id
GROUP BY S.supplier_id, S.name;

--11. List the number of reviews given by each customer.
SELECT C.name, COUNT(*) AS COUNTOFCUSTOMERREVIEW
FROM PRODUCTREVIEWS p
LEFT JOIN Customers c on c.customer_id = p.customer_id
GROUP BY c.customer_id, c.name;

--12. Show total inventory movement (sum of quantity) for each warehouse.
SELECT w.name, SUM(pws.quantity_in_stock) AS STOCK
FROM Warehouses w
LEFT JOIN ProductWarehouseStock pws on pws.warehouse_id = w.warehouse_id
GROUP BY w.warehouse_id, w.name;

--13. Display the number of users assigned to each role.
SELECT R.role_name, COUNT(*) AS NUMBER
FROM ROLES R 
LEFT JOIN Users  u ON U.role_id = R.ROLE_ID
GROUP BY R.ROLE_ID, R.ROLE_NAME;

--14. Count how many products belong to each category.
SELECT c.category_name, COUNT(*) AS COUNTVALUE
FROM Categories C 
LEFT JOIN Products P ON P.category_id = C.category_id
GROUP BY C.category_id, C.category_name;

-----JOIN with GROUP BY and HAVING Question

--15. List products with total sales quantity greater than 3.
SELECT P.name, SUM(SD.quantity) AS  TOTAL
FROM Products p
LEFT JOIN SalesDetails sd on sd.product_id = p.product_id
GROUP BY p.product_id, p.name
HAVING SUM(SD.quantity) > 3;

--16. Find suppliers with total purchase cost more than 10,000.
SELECT S.name, SUM(p.total_cost) as total
FROM Suppliers S 
LEFT JOIN Purchases P ON P.supplier_id = S.supplier_id
GROUP BY S.supplier_id, S.name
HAVING SUM(P.TOTAL_COST) > 10000;

--17. Show categories with more than 5 products.
SELECT c.category_name, SUM(p.product_id) as total
FROM Categories C
LEFT JOIN Products P ON C.category_id = P.category_id
GROUP BY C.category_id, C.category_name
HAVING SUM(P.product_id) >5;

--18. List users who have performed more than 2 inventory actions.
SELECT U.username
FROM Users U
LEFT JOIN Inventory_Log I ON I.user_id = U.user_id
GROUP BY U.user_id, U.username
HAVING COUNT(*) > 2;

--19. Display customers who have given more than 2 product reviews.
SELECT C.name 
FROM Customers C
JOIN ProductReviews PR ON PR.customer_id = C.customer_id
GROUP BY C.customer_id, C.name
HAVING COUNT(*) > 2;

--20. Get roles assigned to more than 1 user.
SELECT r.role_name
FROM Roles r 
JOIN Users U ON U.role_id = R.role_id
GROUP BY R.ROLE_ID, R.ROLE_NAME
HAVING COUNT(*) > 1;


-----Advanced SQL Join-Based Questions

--Find the latest purchase date for each supplier and the total amount paid (from SupplierPayments).
SELECT 
    s.name AS supplier_name,
    MAX(p.purchase_date) AS latest_purchase_date,
    SUM(sp.amount_paid) AS total_amount_paid
FROM Suppliers s
JOIN Purchases p ON p.supplier_id = s.supplier_id
JOIN SupplierPayments sp ON sp.purchase_id = p.purchase_id
GROUP BY s.supplier_id, s.name;

--Display the top 3 products with the highest total sales quantity.
SELECT TOP 3 P.name, SUM(sd.quantity) as total
FROM Products P
JOIN SalesDetails SD ON SD.product_id = P.product_id
GROUP BY P.product_id, P.name
ORDER BY total DESC;

WITH  RANKVALUE AS (
	SELECT *,
	DENSE_RANK() OVER ( ORDER BY name DESC) AS RANKING
	FROM Products
) 

SELECT *
FROM RANKVALUE
WHERE RANKING <=3;

--List all users who have not performed any purchases or inventory actions.
SELECT U.username 
FROM Users U
LEFT JOIN Purchases p ON P.user_id = U.user_id
LEFT JOIN Inventory_Log I ON I.user_id = u.user_id
WHERE I.log_id IS NULL OR P.purchase_id IS NULL;

--Find all customers who bought products that they also reviewed.
SELECT DISTINCT C.name
FROM Customers C
JOIN Sales S ON S.customer_id = C.customer_id
JOIN SalesDetails SD ON SD.sale_id = S.sale_id
JOIN ProductReviews PR ON PR.customer_id = C.customer_id AND PR.product_id = SD.product_id;

--Show the product-wise average rating and list only those with an average rating above 4.
SELECT P.name, AVG(pr.rating) as avgrating
FROM Products P
LEFT JOIN ProductReviews PR ON PR.product_id = P.product_id
GROUP BY p.product_id, p.name
HAVING AVG(PR.RATING) > 4;

--For each warehouse, list the product with the highest quantity in stock.
SELECT 
    w.name AS warehouse_name,
    p.name AS product_name,
    pws.quantity_in_stock
FROM ProductWarehouseStock pws
JOIN Warehouses w ON pws.warehouse_id = w.warehouse_id
JOIN Products p ON p.product_id = pws.product_id
WHERE pws.quantity_in_stock = (
    SELECT MAX(pws2.quantity_in_stock)
    FROM ProductWarehouseStock pws2
    WHERE pws2.warehouse_id = pws.warehouse_id
);


WITH RankedStocks AS (
    SELECT 
        w.name AS warehouse_name,
        p.name AS product_name,
        pws.quantity_in_stock,
        ROW_NUMBER() OVER (PARTITION BY w.warehouse_id ORDER BY pws.quantity_in_stock DESC) AS rn
    FROM Warehouses w
    JOIN ProductWarehouseStock pws ON pws.warehouse_id = w.warehouse_id
    JOIN Products p ON p.product_id = pws.product_id
)
SELECT warehouse_name, product_name, quantity_in_stock
FROM RankedStocks
WHERE rn = 1;

--Display monthly total sales amount and number of transactions (use GROUP BY with DATEPART).
SELECT 
    DATEPART(YEAR, s.sale_date) AS sale_year,
    DATEPART(MONTH, s.sale_date) AS sale_month,
    SUM(sd.quantity * sd.price) AS total_sales_amount,
    COUNT(DISTINCT s.sale_id) AS number_of_transactions
FROM Sales s
JOIN SalesDetails sd ON s.sale_id = sd.sale_id
GROUP BY DATEPART(YEAR, s.sale_date), DATEPART(MONTH, s.sale_date)
ORDER BY sale_year, sale_month;

--Find products with stock in more than 1 warehouse
SELECT p.name AS product_name, pws.product_id, COUNT(DISTINCT pws.warehouse_id) AS warehouse_count
FROM ProductWarehouseStock pws
JOIN Products p ON p.product_id = pws.product_id
GROUP BY pws.product_id, p.name
HAVING COUNT(DISTINCT pws.warehouse_id) > 1;
