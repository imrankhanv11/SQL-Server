CREATE TRIGGER trg_UpdateStudentFeeSummary
ON StudentFeePayment
AFTER INSERT
AS
BEGIN
    UPDATE sfs
    SET 
        sfs.TotalPaidAmount = sfs.TotalPaidAmount + i.AmountPaid,
        sfs.OutstandingAmount = sfs.TotalFeeAmount - (sfs.TotalPaidAmount + i.AmountPaid)
    FROM StudentFeeSummary sfs
    INNER JOIN INSERTED i ON sfs.StudentID = i.StudentID;
END;
GO---------------------not run because the outstandingamount column is computed

---------------------------------------
CREATE TRIGGER trg_UpdateStudentFeeSummary2
ON StudentFeePayment
AFTER INSERT
AS
BEGIN
    -- Update only the TotalPaidAmount; OutstandingAmount is computed
    UPDATE sfs
    SET 
        sfs.TotalPaidAmount = sfs.TotalPaidAmount + i.AmountPaid
    FROM StudentFeeSummary sfs
    INNER JOIN INSERTED i ON sfs.StudentID = i.StudentID;
END;
GO
------------------------------------------
-----
SELECT *
FROM StudentFeeSummary;
-----
INSERT INTO StudentFeePayment
VALUES (4,'2025-06-02',5000,'Cash','test');
---------------------------------------------


--16.	Create a trigger that updates the LastUpdated column in StudentFeeSummary every time a payment is made (insert on StudentFeePayment).
CREATE TRIGGER trg_dateupdate
ON StudentFeePayment
AFTER INSERT
AS
BEGIN
    UPDATE SFS
    SET LastUpdated = GETDATE()
    FROM StudentFeeSummary SFS
    JOIN inserted i ON i.StudentID = SFS.StudentID;
END;

--17.	Create a trigger that prevents deletion of a department if there are teachers assigned to it.
CREATE TRIGGER tgr_preventteacher
ON Department
INSTEAD OF DELETE
AS
BEGIN

    IF EXISTS (
        SELECT 1
        FROM deleted d
        WHERE EXISTS (
            SELECT 1
            FROM Teacher t
            WHERE t.DepartmentID = d.DepartmentID
        )
    )
    BEGIN
        RAISERROR ('Cannot delete department: teachers are assigned to this department.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    DELETE d
    FROM Department d
    INNER JOIN deleted del ON d.DepartmentID = del.DepartmentID;
END

--
--TRIGGERS--
--41. Create a trigger trg_UpdateFeeSummary that updates TotalPaidAmount and LastUpdated in StudentFeeSummary when a new record is inserted in StudentFeePayment.
CREATE TRIGGER trg_UPDATEFEESUMMARY
ON StudentFeePayment
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE s --- remember this i can't use full name just the s ( AS )
    SET 
        TotalPaidAmount = s.TotalPaidAmount + i.AmountPaid,
        LastUpdated = GETDATE()
    FROM StudentFeeSummary s
    INNER JOIN inserted i ON s.StudentID = i.StudentID;
END

--42. Write a trigger that prevents deleting a student if there are fee payments associated.
CREATE TRIGGER trg_preventdeleteonstudent
ON Student
INSTEAD OF DELETE
AS
BEGIN
	BEGIN TRY

	BEGIN TRANSACTION

	IF EXISTS (
    SELECT 1
    FROM StudentFeePayment p
    INNER JOIN deleted d ON p.StudentID = d.StudentID
	)
	BEGIN
		RAISERROR('CANNOT DELETE THE STUDENT DETAILS BECAUSE OF STUDENT PAID SOME FEES', 16, 1);
		ROLLBACK TRANSACTION
		RETURN
	END

	DELETE
	FROM Student
	WHERE StudentID IN ( SELECT StudentID FROM deleted )


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

--43. Create a trigger that logs whenever a student contact info is updated (store logs in a new table StudentContactLog).
CREATE TRIGGER contactlog
ON StudentContact
AFTER UPDATE
AS
BEGIN
    INSERT INTO StudentContactLog (StudentID, OldPhone, NewPhone, OldEmail, NewEmail, OldAddress, NewAddress)
    SELECT
        d.StudentID,
        d.Phone AS OldPhone,
        i.Phone AS NewPhone,
        d.Email AS OldEmail,
        i.Email AS NewEmail,
        d.Address AS OldAddress,
        i.Address AS NewAddress
    FROM
        deleted d
        INNER JOIN inserted i ON d.StudentID = i.StudentID
    WHERE
        ISNULL(d.Phone, '') <> ISNULL(i.Phone, '') OR
        ISNULL(d.Email, '') <> ISNULL(i.Email, '') OR
        ISNULL(d.Address, '') <> ISNULL(i.Address, '');
END


--44. Write a trigger that prevents inserting a subject into SubjectCourse if it already exists for that course.
CREATE TRIGGER preventsubONcourse
ON SubjectCourse
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN SubjectCourse sc
            ON i.SubjectID = sc.SubjectID
            AND i.CourseID = sc.CourseID
    )
    BEGIN
        RAISERROR('This subject already exists for the course.', 16, 1);
        RETURN;
    END

    -- If no duplicates, perform the actual insert
    INSERT INTO SubjectCourse (SubjectID, CourseID)
    SELECT SubjectID, CourseID
    FROM inserted;
END;
