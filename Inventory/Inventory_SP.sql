--FOR SUPPLIER PAYMENT
CREATE PROCEDURE PaymentForPurchase
	@purchaseID INT,
	@amountPaid INT,
	@paymentDate DATE,
	@paymentMethod VARCHAR(30),
	@status VARCHAR(40)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		IF NOT EXISTS ( SELECT 1 FROM Purchases WHERE purchase_id = @purchaseID )
	BEGIN 
		RAISERROR('PURCHASE ID IS NOT FOUND',16,1);
		RETURN;
	END

	IF @amountPaid <= 0
	BEGIN
		RAISERROR('AMOUNT CANNOT BE ZERO OR NEGATIVE',16,1);
		RETURN;
	END

	INSERT INTO SupplierPayments(purchase_id, amount_paid, payment_date, payment_method, status)
	VALUES(@purchaseID, @amountPaid, @paymentDate, @paymentMethod, @status)
	END TRY
	BEGIN CATCH
		DECLARE @ErrMsg NVARCHAR(4000), @ErrSeverity INT, @ErrState INT;
        SELECT 
            @ErrMsg = ERROR_MESSAGE(),
            @ErrSeverity = ERROR_SEVERITY(),
            @ErrState = ERROR_STATE();
        RAISERROR(@ErrMsg, @ErrSeverity, @ErrState);
	END CATCH
END

--FUCNTIN FOR CALCULATE THE TOTALCOST
CREATE FUNCTION dbo.fn_CalculateTotalCost
(
    @productID INT,
    @quantity INT
)
RETURNS DECIMAL(18, 2)
AS
BEGIN
    DECLARE @totalCost DECIMAL(18, 2);

    SELECT @totalCost = price * @quantity
    FROM Products
    WHERE product_id = @productID;

    RETURN ISNULL(@totalCost, 0);
END

--FOR PURCHASES
CREATE OR ALTER PROCEDURE purchasesproducts 
	@productID INT,
	@supplierID INT,
	@quantity INT,
	@purchaseDate DATE,
	@user_id INT,
	@amountPaid INT,
	@paymentDate DATE,
	@paymentMethod VARCHAR(30),
	@satus VARCHAR(40),
	@warehouseid INT
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @ID INT;
	DECLARE @totalCost DECIMAL(16,2);
	BEGIN TRY
		IF NOT EXISTS ( SELECT 1 FROM Products WHERE product_id = @productID )
		BEGIN
			RAISERROR('PRODUCT ID NOT FOUND', 16, 1);
			RETURN;
		END

		IF NOT EXISTS ( SELECT 1 FROM Suppliers WHERE supplier_id = @supplierID )
		BEGIN
			RAISERROR('SUPPLIERS ID NOT FOUND', 16, 1);
			RETURN
		END

		IF @quantity <= 0 
		BEGIN
			RAISERROR('PRODUCT QUANTITY CANNOT BE ZERO', 16,1);
			RETURN;
		END

		BEGIN TRANSACTION

			SET @totalCost = dbo.fn_CalculateTotalCost(@productID, @quantity);


			INSERT INTO Purchases ( product_id, supplier_id, quantity, purchase_date, total_cost, user_id)
			VALUES ( @productID, @supplierID, @quantity, @purchaseDate, @totalCost, @user_id)

			SET @ID = SCOPE_IDENTITY();

			IF @amountPaid > 0
			BEGIN
				EXEC PaymentForPurchase 
				@ID, @amountPaid, @paymentDate, @paymentMethod, @satus;
			END

			IF NOT EXISTS ( SELECT 1 FROM Warehouses WHERE warehouse_id = @warehouseid )
			BEGIN
				RAISERROR ('WAREHOUSE WAS NOT FOUND',16, 1);
				ROLLBACK TRANSACTION;
				RETURN
			END
			
			IF NOT EXISTS ( SELECT 1 FROM ProductWarehouseStock WHERE product_id = @productID AND warehouse_id = @warehouseid )
			BEGIN
				INSERT INTO ProductWarehouseStock ( product_id, warehouse_id, quantity_in_stock )
				VALUES ( @productID, @warehouseid, @quantity )
			END
			ELSE
			BEGIN
				UPDATE ProductWarehouseStock
				SET quantity_in_stock = quantity_in_stock + @quantity
				WHERE product_id = @productID AND warehouse_id = @warehouseId;
			END

			INSERT INTO Inventory_Log ( product_id, action, quantity, action_date, user_id, warehouse_id )
			VALUES ( @productID, 'PURCHASE', @quantity, @purchaseDate, @user_id, @warehouseid)


		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION
		END
		DECLARE @ErrMsg NVARCHAR(4000), @ErrSeverity INT, @ErrState INT;
        SELECT 
            @ErrMsg = ERROR_MESSAGE(),
            @ErrSeverity = ERROR_SEVERITY(),
            @ErrState = ERROR_STATE();
        RAISERROR(@ErrMsg, @ErrSeverity, @ErrState);

	END CATCH
END
--------------------------------------------------------------------------------------------------------------------------
--CREATE TYPE
CREATE TYPE SALESTABLE AS TABLE
(
	ProudctID INT,
	QUANTITY INT,
	PRICE DECIMAL(16,5)
);
GO
CREATE OR ALTER PROCEDURE SaleProducts
	@customerId INT,
	@saleDate DATE,
	@userId INT,
	@warehouseId INT,
	@salesdetails SALESTABLE READONLY
AS	
BEGIN
	SET NOCOUNT ON;

	DECLARE @saleId INT;
	DECLARE @totalprice DECIMAL(16,5);

	BEGIN TRY
		IF NOT EXISTS ( SELECT 1 FROM Customers WHERE customer_id = @customerId )
		BEGIN 
			RAISERROR('CUSTOMER ID NOT FOUND',16,1);
			RETURN
		END

		SELECT @totalprice = SUM(QUANTITY * PRICE) FROM @salesdetails;

		BEGIN TRANSACTION;

		INSERT INTO Sales (customer_id, sale_date, total_price, user_id)
		VALUES (@customerId, @saleDate, @totalprice, @userId);

		SET @saleId = SCOPE_IDENTITY();

		INSERT INTO SalesDetails (sale_id, product_id, quantity, price)
		SELECT @saleId, ProudctID, QUANTITY, QUANTITY*PRICE AS PRICE FROM @salesdetails;

		DECLARE @product_id INT, @qty INT, @price DECIMAL(16,5);

		DECLARE product_cursor CURSOR FOR
			SELECT ProudctID, QUANTITY, PRICE FROM @salesdetails;

		OPEN product_cursor;
		FETCH NEXT FROM product_cursor INTO @product_id, @qty, @price;

		WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE ProductWarehouseStock
			SET quantity_in_stock = quantity_in_stock - @qty
			WHERE product_id = @product_id AND warehouse_id = @warehouseId;

			INSERT INTO Inventory_Log (product_id, action, quantity, action_date, reference_id, user_id, warehouse_id)
			VALUES (@product_id, 'SALE', @qty, @saleDate, @saleId, @userId, @warehouseId);

			FETCH NEXT FROM product_cursor INTO @product_id, @qty, @price;
		END

		CLOSE product_cursor;
		DEALLOCATE product_cursor;

		COMMIT TRANSACTION;

		PRINT 'Sale completed. Sale ID: ' + CAST(@saleId AS VARCHAR);

	END TRY

	BEGIN CATCH
		ROLLBACK TRANSACTION;
		PRINT 'Error: ' + ERROR_MESSAGE();
	END CATCH
END;
GO

------------
DECLARE @sales SALESTABLE;

INSERT INTO @sales (ProudctID, QUANTITY, PRICE)
VALUES 
    (1, 2, 150.00), 
    (2, 1, 200.00);  

EXEC SaleProducts 
    @customerId    = 2,
    @saleDate      = '2025-06-11',
    @userId        = 1,
    @warehouseId   = 1,
    @salesdetails  = @sales;

-------------------------------------------------------------------------------------------
--ANOTHER WAY
-- Step 1: Declare raw input (without price)
DECLARE @tempInput TABLE (
    ProductID INT,
    Quantity INT
);

INSERT INTO @tempInput (ProductID, Quantity)
VALUES 
    (1, 2),
    (2, 1);

-- Step 2: Declare the actual @sales table variable
DECLARE @sales SALESTABLE;

-- Step 3: Insert into @sales with prices from Products table
INSERT INTO @sales (ProudctID, QUANTITY, PRICE)
SELECT 
    ti.ProductID,
    ti.Quantity,
    p.price
FROM @tempInput ti
JOIN Products p ON p.product_id = ti.ProductID;

-- Step 4: Call the procedure
EXEC SaleProducts 
    @customerId    = 2,
    @saleDate      = '2025-06-11',
    @userId        = 1,
    @warehouseId   = 1,
    @salesdetails  = @sales;
-----------------------------------------------------------------------------------------------

SELECT * FROM Sales;
SELECT * FROM SalesDetails;

CREATE PROCEDURE CustomerReview
	@customerID INT,
	@productID INT,
	@rating INT,
	@comments VARCHAR(500),
	@reviewDate DATE = NULL
AS
BEGIN
	
	SET NOCOUNT ON;

	BEGIN TRY
		IF NOT EXISTS ( SELECT 1 FROM Customers WHERE customer_id = @customerID )
		BEGIN
			RAISERROR('CUSTOMER ID NOT FOUND', 16, 1);
			RETURN;
		END

		IF NOT EXISTS ( SELECT 1 FROM Products WHERE product_id = @productID )
		BEGIN
			RAISERROR('PRODUCT ID NOT FOUND', 16 ,1);
			RETURN
		END

		IF @rating > 5 OR @rating < 0 
		BEGIN 
			RAISERROR('RATING SHOULD BE IN 0 TO 5', 16, 1);
			RETURN
		END

		INSERT INTO ProductReviews ( customer_id, product_id, rating, comments, review_date)
		VALUES ( @customerID, @productID, @rating, @comments, @reviewDate)

	END TRY

	BEGIN CATCH
		DECLARE @ERR_MESSAGE VARCHAR(200), @ERR_NUMBER INT;
		
		SELECT @ERR_MESSAGE = ERROR_MESSAGE(), @ERR_NUMBER = ERROR_NUMBER();

		RAISERROR(@ERR_MESSAGE, @ERR_NUMBER, 16, 1);
	END CATCH
END