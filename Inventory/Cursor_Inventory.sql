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