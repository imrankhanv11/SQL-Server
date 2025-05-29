--storing procedure for insert new depatment
CREATE PROCEDURE insert_depatment(
		@DepartmentName VARCHAR(20),
		@Result VARCHAR(40) OUTPUT
		)
AS
BEGIN
	INSERT INTO Department 
	VALUES (@DepartmentName)

	SELECT @Result ='Completed'
END;
GO
-----------------------------------------------------------------------------------------
--procedure for new student add
CREATE PROCEDURE addNewStudent
    @name VARCHAR(20),
    @dob DATE,
    @gender VARCHAR(8),
    @newStudentID INT OUTPUT
AS
BEGIN
    INSERT INTO Student (StudentName, DOB, Gender)
    VALUES (@name, @dob, @gender);

    SET @newStudentID = SCOPE_IDENTITY();-- taking the id 
END;
GO
------------------------------------------------------------------------------------------
--STROING PROCEDRUE FOR studentcontact
CREATE PROCEDURE insert_studentcontact
(
    @id INT,
    @phone VARCHAR(20),
    @email VARCHAR(30),
    @address VARCHAR(50),
    @gname VARCHAR(20),
    @gphone VARCHAR(20)
)
AS
BEGIN
    -- Insert data into STUDENTCONTACT table
    INSERT INTO StudentContact (StudentID, Phone, Email, Address, GuardianName, GuardianPhone)
    VALUES (@id, @phone, @email, @address, @gname, @gphone);
END;
GO
----------------------------------------------------
--storing procedure for insertstudentfeesummary
CREATE PROCEDURE upsertStudentFeeSummary
    @StudentID INT,
    @TotalFeeAmount DECIMAL(10,2),
    @TotalPaidAmount DECIMAL(10,2) = 0
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM StudentFeeSummary WHERE StudentID = @StudentID)
    BEGIN
        -- Update existing record
        UPDATE StudentFeeSummary
        SET TotalFeeAmount = @TotalFeeAmount,
            TotalPaidAmount = @TotalPaidAmount,
            LastUpdated = GETDATE()
        WHERE StudentID = @StudentID;
    END
    ELSE
    BEGIN
        -- Insert new record
        INSERT INTO StudentFeeSummary (StudentID, TotalFeeAmount, TotalPaidAmount, LastUpdated)
        VALUES (@StudentID, @TotalFeeAmount, @TotalPaidAmount, GETDATE());
    END
END;
GO
---------------------------------
--storing procedure for insert fees payment
CREATE PROCEDURE addStudentFeePayment
    @StudentID INT,
    @PaymentDate DATE,
    @AmountPaid DECIMAL(10,2),
    @PaymentMethod NVARCHAR(50),
    @Remarks NVARCHAR(255) = NULL
AS
BEGIN
    INSERT INTO StudentFeePayment (StudentID, PaymentDate, AmountPaid, PaymentMethod, Remarks)
    VALUES (@StudentID, @PaymentDate, @AmountPaid, @PaymentMethod, @Remarks);

    UPDATE StudentFeeSummary
    SET TotalPaidAmount = TotalPaidAmount + @AmountPaid,
        LastUpdated = GETDATE()
    WHERE StudentID = @StudentID;

END;
GO


---------------------------------------------------------------------------------------------------
-------calling fuctions
DECLARE @NEWSTUDENT INT
EXEC addNewStudent 'Akash','2004-07-09','Male', @NEWSTUDENT OUTPUT;
PRINT @NEWSTUDENT


EXEC insert_studentcontact
    @id = @NEWSTUDENT,
    @phone = '998786767',
    @email = 'student10001@example.com',
    @address = '456 sorathur Street',
    @gname = 'nope',
    @gphone = '54651545';

EXEC upsertStudentFeeSummary 
    @StudentID = @NEWSTUDENT,
    @TotalFeeAmount = 111110.00,
    @TotalPaidAmount = 10000.00;

EXEC addStudentFeePayment
    @StudentID = @NEWSTUDENT,
    @PaymentDate = '2025-05-29',
    @AmountPaid = 1000.00,
    @PaymentMethod = 'Cash',
    @Remarks = 'Payment for May';
GO
----------------------------------------------------------------------------------------------------------------
