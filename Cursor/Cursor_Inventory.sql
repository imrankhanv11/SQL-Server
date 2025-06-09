CREATE PROCEDURE sp_AddSaleWithDetails
    @customer_id INT,
    @sale_date DATETIME,
    @total_price DECIMAL(10,2),
    @user_id INT,
    @Details TVP_SaleDetails READONLY
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

		--insert sales
        INSERT INTO Sales (customer_id, sale_date, total_price, user_id)
        VALUES (@customer_id, @sale_date, @total_price, @user_id);

        DECLARE @sale_id INT = SCOPE_IDENTITY();

        DECLARE @product_id INT, @quantity INT, @price DECIMAL(10,2), @warehouse_id INT;

        DECLARE sale_cursor CURSOR FOR
        SELECT product_id, quantity, price, warehouse_id FROM @Details;

        OPEN sale_cursor;
        FETCH NEXT FROM sale_cursor INTO @product_id, @quantity, @price, @warehouse_id;

        WHILE @@FETCH_STATUS = 0
        BEGIN
			
			--insert selaesdetails
            INSERT INTO SalesDetails (sale_id, product_id, quantity, price)
            VALUES (@sale_id, @product_id, @quantity, @price);

			--update stock in warehouse
            UPDATE ProductWarehouseStock
            SET quantity_in_stock = quantity_in_stock - @quantity
            WHERE product_id = @product_id AND warehouse_id = @warehouse_id;

			--insert log
            INSERT INTO Inventory_Log (product_id, action, quantity, action_date, reference_id, user_id, warehouse_id)
            VALUES (@product_id, 'SALE', @quantity, GETDATE(), @sale_id, @user_id, @warehouse_id);

            FETCH NEXT FROM sale_cursor INTO @product_id, @quantity, @price, @warehouse_id;
        END

        CLOSE sale_cursor;

        DEALLOCATE sale_cursor;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END


----------------------------------------------------
CREATE TYPE TVP_SaleDetails AS TABLE (
    product_id INT,
    quantity INT,
    price DECIMAL(10,2),
    warehouse_id INT
);
-----------------------------------------------------
DECLARE @saleItems TVP_SaleDetails;

INSERT INTO @saleItems (product_id, quantity, price, warehouse_id)
VALUES (1, 2, 20000, 1), (3, 1, 1000, 3);

EXEC sp_AddSaleWithDetails
    @customer_id = 1,
    @sale_date = GETDATE(),
    @total_price = 41000,
    @user_id = 2,
    @Details = @saleItems;     
	
--------------------------------------
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

