--Zero divition Error
CREATE PROCEDURE sp_zerodevition
	@number_1 INT,
	@number_2 INT
AS
BEGIN
	DECLARE @RESULT INT;
	SET @RESULT = 0;
	SET @RESULT = @number_1 / @number_2;
	PRINT 'THE RESULT IS : ' + CAST(@RESULT AS VARCHAR(10));
END

EXEC sp_zerodevition 10,0;

--Msg 8134, Level 16, State 1, Procedure sp_zerodevition, Line 8 [Batch Start Line 12]
--Divide by zero error encountered.
--THE RESULT IS : 0

------------------------------------------------------------------------------------------------
--Syntax

BEGIN TRY
    --content
END TRY

BEGIN CATCH
    -- ERROR_NUMBER(), ERROR_MESSAGE(), ERROR_SEVERITY(), ERROR_STATE(), ERROR_LINE(), ERROR_PROCEDURE()
END CATCH

------------------------------------------------------------------------------------------------
--Handling Error
CREATE PROCEDURE HandleDivideByZeroError
AS
BEGIN
    BEGIN TRY
        DECLARE @result INT
        SET @result = 1 / 0
    END TRY
    BEGIN CATCH
        SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_MESSAGE() AS ErrorMessage,
            ERROR_LINE() AS ErrorLine,
            ERROR_SEVERITY() AS ErrorSeverity,
            ERROR_STATE() AS ErrorState,
            ERROR_PROCEDURE() AS ErrorProcedure
    END CATCH
END

EXEC HandleDivideByZeroError

--ErrorNumber - 8134
--ErrorMessage - Divide by zero error encountered
--ErrorLine - 6
--ErrorSeverity - 16
--ErrorState - 1
--ErrorProcedure - HandleDivideByZeroError

------------------------------------------------------------------------------------------------
CREATE PROCEDURE sp_DivideWithErrorCheck
    @num1 INT,
    @num2 INT
AS
BEGIN
    DECLARE @result INT;

    SET @result = @num1 / @num2;

    IF @@ERROR <> 0
    BEGIN
        PRINT 'An error occurred';
        RETURN;
    END

    PRINT 'Result is: ' + CAST(@result AS VARCHAR);
END

-- No error
EXEC sp_DivideWithErrorCheck @num1 = 10, @num2 = 2;

--Result is: 5


-- Causes divide by zero
EXEC sp_DivideWithErrorCheck @num1 = 10, @num2 = 0;

--Msg 8134, Level 16, State 1, Procedure sp_DivideWithErrorCheck, Line 8 [Batch Start Line 83]
--Divide by zero error encountered.
--An error occurred

------------------------------------------------------------------------------------------------
--Raiserror
CREATE OR ALTER  PROCEDURE RaiseErrorInTryBlock
AS
BEGIN
    DECLARE @SomeCondition INT = 1;

    BEGIN TRY
        IF @SomeCondition = 1
        BEGIN
            RAISERROR('This is RAISERROR', 16, 1);
        END
		PRINT 'CHECK';
    END TRY
    BEGIN CATCH
        PRINT 'Caught an error: ' + ERROR_MESSAGE();
    END CATCH
END


EXEC RaiseErrorInTryBlock;

--Caught an error: This is RAISERROR

------------------------------------------------------------------------------------------------
--Throw
CREATE PROCEDURE ThrowErrorOnly
AS
BEGIN
    BEGIN TRY
        DECLARE @x INT = 1, @y INT = 0, @z INT;
        SET @z = @x / @y;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END

EXEC ThrowErrorOnly;

--Msg 8134, Level 16, State 1, Procedure ThrowErrorOnly, Line 6 [Batch Start Line 94]
--Divide by zero error encountered.

------------------------------------------------------------------------------------------------

--Throw with custom message
CREATE PROCEDURE ThrowErrorOnlyWithMessage
AS
BEGIN
    DECLARE @SomeCondition INT = 1;

    BEGIN TRY
        IF @SomeCondition = 1
        BEGIN
            THROW 50001, 'Custom error triggered because condition is true.', 1;
        END
    END TRY
    BEGIN CATCH
        PRINT 'Caught error: ' + ERROR_MESSAGE();
    END CATCH
END

EXEC ThrowErrorOnlyWithMessage;

--Caught error: Custom error triggered because condition is true.

------------------------------------------------------------------------------------------------
--XACT_STATE()
BEGIN TRY
    BEGIN TRANSACTION;
    DECLARE @a INT = 1, @b INT = 0, @c INT;
    SET @c = @a / @b;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() = -1
    BEGIN
        PRINT 'Transaction is uncommittable. Rolling back...';
        ROLLBACK TRANSACTION;
    END
    ELSE IF XACT_STATE() = 1
    BEGIN
        PRINT 'Transaction is still valid. Rolling back anyway...';
        ROLLBACK TRANSACTION;
    END

    PRINT 'Error: ' + ERROR_MESSAGE();
END CATCH
------------------------------------------------------------------------------------------------
--Create a stored procedure sp_AddStudentPayment that:
--	Inserts a payment
--	Updates the StudentFeeSummary table accord
CREATE PROCEDURE sp_AddStudentPayment
    @studentid INT,
    @paymentdate DATE,
    @amountpaid INT,
    @paymentmethod VARCHAR(10),
    @remark VARCHAR(30)
AS
BEGIN
    BEGIN TRY
        
        IF NOT EXISTS (SELECT 1 FROM Student WHERE StudentID = @studentid)
        BEGIN
            RAISERROR('STUDENT ID NOT FOUND', 16, 1);
            RETURN;
        END

		BEGIN TRANSACTION;

        INSERT INTO StudentFeePayment (StudentID, PaymentDate, AmountPaid, PaymentMethod, Remarks)
        VALUES (@studentid, @paymentdate, @amountpaid, @paymentmethod, @remark);

        UPDATE StudentFeeSummary
        SET TotalPaidAmount = TotalPaidAmount + @amountpaid,
            LastUpdated = @paymentdate
        WHERE StudentID = @studentid;

        IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR('StudentFeeSummary record not found for the student.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		DECLARE @ERR_MESSAGE NVARCHAR(4000), @ERR_NUMBER INT, @FullMessage NVARCHAR(4000);

		SELECT 
			@ERR_MESSAGE = ERROR_MESSAGE(),
			@ERR_NUMBER = ERROR_NUMBER();

		SET @FullMessage = 'Error Number: ' + CAST(@ERR_NUMBER AS NVARCHAR(10)) + '; Message: ' + @ERR_MESSAGE;

		RAISERROR(@FullMessage, 16, 1);
	END CATCH
END

------------------------------------------------------------------------------------------------

--FOR SUPPLIER PAYMENT -- WITH RISERROR
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


--FOR SUPPLIER PAYMENT -- WITH THROW
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
		IF NOT EXISTS (SELECT 1 FROM Purchases WHERE purchase_id = @purchaseID)
		BEGIN 
			THROW 50001, 'PURCHASE ID IS NOT FOUND', 1;
		END

		IF @amountPaid <= 0
		BEGIN
			THROW 50002, 'AMOUNT CANNOT BE ZERO OR NEGATIVE', 1;
		END

		INSERT INTO SupplierPayments(purchase_id, amount_paid, payment_date, payment_method, status)
		VALUES (@purchaseID, @amountPaid, @paymentDate, @paymentMethod, @status)
	END TRY
	BEGIN CATCH
		THROW;
	END CATCH
END
