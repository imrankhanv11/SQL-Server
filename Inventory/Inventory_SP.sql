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

			INSERT INTO ProductWarehouseStock ( product_id, warehouse_id, quantity_in_stock )
			VALUES ( @productID, @warehouseid, @quantity )

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