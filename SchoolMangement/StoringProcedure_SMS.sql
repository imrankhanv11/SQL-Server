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
CREATE PROCEDURE add_teacherWITHsubject
    @teacherName VARCHAR(30),
    @departmentID INT,
    @subjectID INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM Department WHERE DepartmentID = @departmentID)
        BEGIN
            RAISERROR('DepartmentID does not exist', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM Subject WHERE SubjectID = @subjectID)
        BEGIN
            RAISERROR('SubjectID does not exist', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        INSERT INTO Teacher (Name, DepartmentID)
        VALUES (@teacherName, @departmentID);

        DECLARE @newTeacherID INT = SCOPE_IDENTITY();

        INSERT INTO TeacherSubject (TeacherID, SubjectID)
        VALUES (@newTeacherID, @subjectID);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;

---------
EXEC add_teacherWITHsubject 123,2,3;

SELECT * FROM Subject;
SELECT * FROM Department;
SELECT * FROM Teacher;

-----------------------------------------------

CREATE PROCEDURE add_CourseEnrollment
	@studentID INT,
	@courseID INT,
	@enrollmentDate DATE
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRANSACTION
			
			IF NOT EXISTS ( SELECT 1 FROM Student WHERE StudentId = @studentID )
			BEGIN
				RAISERROR ('StudentId not found', 16, 1);
				ROLLBACK TRANSACTION
				RETURN
			END

			IF NOT EXISTS ( SELECT 1 FROM Course WHERE CourseID = @courseID )
			BEGIN 
				RAISERROR('CourseID not found', 16,1);
				ROLLBACK TRANSACTION
				RETURN
			END

			INSERT INTO CourseEnrollment ( StudentID, CourseID, EnrollmentDate )
			VALUES ( @studentID, @courseID, @enrollmentDate)

		COMMIT TRANSACTION

	END TRY

	BEGIN CATCH
		ROLLBACK TRANSACTION;
        THROW;
	END CATCH

END

---------------------------------

--14.	Write a stored procedure GetStudentFeeSummary that takes a StudentID and returns the total fee, total paid, and outstanding amount.
CREATE PROCEDURE getstudentfeesummary( @studentid int )
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION 
			
			IF NOT EXISTS ( SELECT 1 FROM Student WHERE StudentID = @studentid )
			BEGIN
				RAISERROR('STUDENT DETAILS NOT FOUND', 16,1);
				ROLLBACK TRANSACTION
				RETURN
			END

			SELECT S.StudentName, fs.TotalFeeAmount, fs.TotalPaidAmount, fs.OutstandingAmount
			FROM Student S
			JOIN StudentFeeSummary FS ON FS.StudentID = S.StudentID
			WHERE S.StudentID = @studentid

		COMMIT TRANSACTION
	END TRY

	BEGIN CATCH
		
			ROLLBACK TRANSACTION;
		THROW
	END CATCH
END

EXEC getstudentfeesummary 1;

--15.	Write a stored procedure AddPayment that inserts a payment record for a student and updates the LastUpdated column in StudentFeeSummary.
ALTER PROCEDURE AddPayment 
    @StudentID INT,
    @AmountPaid DECIMAL(10, 2),
	@PaymentMode VARCHAR(10)
AS
BEGIN
	
	SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM Student WHERE StudentID = @StudentID)
        BEGIN
            RAISERROR('STUDENT DETAILS NOT FOUND', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        INSERT INTO StudentFeePayment (
            StudentID, PaymentDate, AmountPaid, PaymentMethod, Remarks
        )
        VALUES (
            @StudentID, GETDATE(), @AmountPaid, @PaymentMode, 'Payment added'
        );

        UPDATE StudentFeeSummary
        SET 
            TotalPaidAmount = TotalPaidAmount + @AmountPaid,
            LastUpdated = GETDATE()
        WHERE StudentID = @StudentID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrMsg NVARCHAR(4000), @ErrSeverity INT, @ErrState INT;
        SELECT 
            @ErrMsg = ERROR_MESSAGE(),
            @ErrSeverity = ERROR_SEVERITY(),
            @ErrState = ERROR_STATE();
        RAISERROR(@ErrMsg, @ErrSeverity, @ErrState);
    END CATCH
END;
GO

EXEC AddPayment 66,5000,'Cash';

---
---Stored procedure-----

--36. Create a stored procedure sp_GetStudentDetails that takes a StudentID and returns personal info, course name, contact info, and fee summary.
CREATE PROCEDURE sp_GetStudentDetails 
    @studentID INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION

        -- Check if student exists
        IF NOT EXISTS (SELECT 1 FROM Student WHERE StudentID = @studentID)
        BEGIN
            RAISERROR('STUDENT ID NOT FOUND', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Select student details
        SELECT 
            S.StudentID,
            S.StudentName,
            S.DOB,
            C.CourseName,
            CT.Phone,
            CT.Email,
            F.TotalFeeAmount,
            F.TotalPaidAmount,
            (F.TotalFeeAmount - F.TotalPaidAmount) AS OutstandingAmount
        FROM 
            Student S
            LEFT JOIN CourseEnrollment E ON S.StudentID = E.StudentID
            LEFT JOIN Course C ON E.CourseID = C.CourseID
            LEFT JOIN StudentContact CT ON S.StudentID = CT.StudentID
            LEFT JOIN StudentFeeSummary F ON S.StudentID = F.StudentID
        WHERE 
            S.StudentID = @studentID;

        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrMsg NVARCHAR(4000), @ErrSeverity INT;
        SELECT 
            @ErrMsg = ERROR_MESSAGE(),
            @ErrSeverity = ERROR_SEVERITY();

        RAISERROR(@ErrMsg, @ErrSeverity, 1);
    END CATCH
END;

--37. Create a stored procedure sp_AddStudentPayment that:
--•	Inserts a payment
--•	Updates the StudentFeeSummary table accordingly
CREATE PROCEDURE sp_AddStudentPayment
	@studentid INT,
	@paymentdate DATE,
	@amountpaid INT,
	@paymentmethod VARCHAR(10),
	@remark VARCHAR(30)
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION

		IF NOT EXISTS ( SELECT 1 FROM Student WHERE StudentID = @studentid )
		BEGIN
			RAISERROR('STUDENT ID NOT FOUND',16,1);
			ROLLBACK TRANSACTION
			RETURN
		END

		INSERT INTO StudentFeePayment (StudentID, PaymentDate, AmountPaid, PaymentMethod, Remarks )
		VALUES 
		(@studentid, @paymentdate, @amountpaid, @paymentmethod, @remark);
		
		UPDATE StudentFeeSummary
		SET TotalPaidAmount = TotalPaidAmount + @amountpaid,
			LastUpdated = @paymentdate
		WHERE StudentID = @studentid;

		COMMIT TRANSACTION
	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION
		END

		DECLARE @ERR_MESSAGE VARCHAR(50), @ERR_NUMBER INT

		SELECT @ERR_MESSAGE = ERROR_MESSAGE(), @ERR_NUMBER = ERROR_NUMBER()

		RAISERROR(@ERR_MESSAGE, @ERR_NUMBER,1)
	END CATCH

END

--38. Write a stored procedure to get all students who haven't paid any amount yet.
CREATE PROCEDURE sp_notpaidstudent
AS
BEGIN
	BEGIN TRY
		
		SELECT s.StudentName
		FROM Student s 
		LEFT JOIN StudentFeePayment SFP ON SFP.StudentID = S.StudentID
		WHERE PaymentID IS NULL

	END TRY

	BEGIN CATCH
		DECLARE @ERR_MESSAGE VARCHAR(50), @ERR_NUMBER INT

		SELECT @ERR_MESSAGE = ERROR_MESSAGE(), @ERR_NUMBER = ERROR_NUMBER()

		RAISERROR(@ERR_MESSAGE, @ERR_NUMBER,1)
	END CATCH
END

--39. Create a procedure that returns all subjects in a course (by CourseID) along with whether they are mandatory.
CREATE PROCEDURE sp_coursesubject
	@courseid int
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
			
			IF NOT EXISTS ( SELECT 1 FROM Course WHERE CourseID = @courseid )
			BEGIN
				RAISERROR('COURSE ID IS NOT FOUND', 16,1 );
				ROLLBACK TRANSACTION
				RETURN
			END

			SELECT C.CourseName, S.Name, SC.IsMandatory
			FROM Course C
			LEFT JOIN SubjectCourse SC ON SC.CourseID = C.CourseID
			LEFT JOIN Subject S ON S.SubjectID = SC.SubjectID

		COMMIT TRANSACTION
	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION
		END

		DECLARE @ER_MESG VARCHAR(30), @ER_NUMBER INT

		SELECT @ER_MESG = ERROR_MESSAGE(), @ER_NUMBER = ERROR_NUMBER()

		RAISERROR(@ER_MESG, @ER_NUMBER, 1)
	END CATCH
END

--40. Create a stored procedure to assign a teacher to a subject (inserts a record into TeacherSubject).
CREATE PROCEDURE sp_addsubtoteacher
	@teacherID int,
	@subjectID int
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
			
			IF NOT EXISTS ( SELECT 1 FROM Teacher WHERE TeacherID = @teacherID )
			BEGIN
				RAISERROR('TEACHER ID NOT FOUND', 16, 1)
				ROLLBACK TRANSACTION
				RETURN
			END

			IF NOT EXISTS ( SELECT 1 FROM Subject WHERE SubjectID = @subjectID )
			BEGIN
				RAISERROR('SUBJECT ID NOT FOUND', 16,1);
				ROLLBACK TRANSACTION
				RETURN
			END
			
			INSERT INTO TeacherSubject ( TeacherID, SubjectID )
			VALUES
			( @teacherID, @subjectID )
		COMMIT TRANSACTION
	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION
		END

		
		DECLARE @ER_MESG VARCHAR(30), @ER_NUMBER INT

		SELECT @ER_MESG = ERROR_MESSAGE(), @ER_NUMBER = ERROR_NUMBER()

		RAISERROR(@ER_MESG, @ER_NUMBER, 1)

	END CATCH
END