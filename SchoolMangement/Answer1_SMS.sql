--1.	List all students along with their gender and date of birth.
SELECT StudentName, Gender
FROM Student;

--2.	Find the names of all courses along with their course codes.
SELECT CourseName, CourseCode
FROM Course;

--3.	Retrieve all teachers along with their department names.
SELECT t.Name, d.DepartmentName
FROM Teacher t 
JOIN Department d on d.DepartmentID=t.DepartmentId;

--4.	Get the total fee amount and outstanding amount for each student.
SELECT S.StudentName, F.TotalFeeAmount, F.OutstandingAmount
FROM Student S
JOIN StudentFeeSummary F ON F.StudentID=S.StudentID;

--5.	List all students enrolled in a specific course by course code.
SELECT s.StudentName, c.CourseName, c.CourseCode
FROM Student s 
JOIN CourseEnrollment CE ON CE.StudentID = S.StudentID
JOIN Course C ON C.CourseID= CE.CourseID;

--6.	Find all subjects taught by a particular teacher.
SELECT s.Name,T.Name
FROM Teacher T 
JOIN TeacherSubject TS ON TS.TeacherID = T.TeacherID
JOIN Subject S ON S.SubjectID=TS.SubjectID;

--7.	Show all mandatory subjects in each course.
SELECT C.Coursename, s.Name
FROM Course C 
JOIN SubjectCourse SC ON SC.CourseID = C.CourseID
JOIN Subject S ON S.SubjectID = SC.SubjectID
WHERE IsMandatory = 1;

--8.	Get the total amount paid by each student so far from the StudentFeePayment table.
SELECT s.StudentID, s.StudentName, SUM(F.AmountPaid) AS TOTALPAIDAMOUNT
FROM Student S 
JOIN StudentFeePayment F ON F.StudentID=S.StudentID
GROUP BY S.StudentID,S.StudentName;

--9.	List all students along with their contact details (phone, email, guardian name).
SELECT S.StudentName, d.Phone, d.email, d.GuardianName
FROM Student S
JOIN StudentContact D ON D.StudentID=S.StudentID;

---FUNCTIONS
--10.	Write a query to calculate the average payment amount made by students.
CREATE FUNCTION avg_payment_student()
RETURNS Table 
AS
RETURN(
	SELECT s.StudentName, s.StudentID, AVG(f.AmountPaid) AS AVGPaid
	FROM Student s
	JOIN StudentFeePayment F ON F.StudentID= S.StudentID
	GROUP BY s.StudentID,s.StudentName
)

SELECT * FROM avg_payment_student();

------
CREATE FUNCTION avg_payment_studentINPERSON(@studentid INT )
RETURNS Table 
AS
RETURN(
	SELECT s.StudentName, s.StudentID, AVG(f.AmountPaid) AS AVGPaid
	FROM Student s
	JOIN StudentFeePayment F ON F.StudentID= S.StudentID
	WHERE s.StudentID = @studentid
	GROUP BY s.StudentID,s.StudentName
)

SELECT * FROM avg_payment_studentINPERSON(2);

--11.	Find students who have not paid their fees fully (OutstandingAmount > 0).
CREATE FUNCTION fees_balance()
RETURNS Table
AS
RETURN(
	SELECT s.StudentName
	FROM Student S
	JOIN StudentFeeSummary SFS ON SFS.StudentID=S.StudentID
	WHERE SFS.OutstandingAmount > 0
)

SELECT * FROM fees_balance();

--12.	Write a query to show the number of students enrolled in each course.
CREATE FUNCTION enrolled_course_students()
RETURNS Table
AS
RETURN(
	SELECT C.CourseName, COUNT(CE.StudentID) AS Totalcount
	FROM Course C 
	JOIN CourseEnrollment CE ON CE.CourseID = C.CourseID
	GROUP BY C.CourseID, C.CourseName
)

SELECT * FROM enrolled_course_students()

--13.	Display the list of courses along with the number of mandatory and optional subjects in each.
CREATE FUNCTION course_subject_counts()
RETURNS TABLE
AS
RETURN (
    SELECT 
        C.CourseName,
        SUM(CASE WHEN S.IsMandatory = 1 THEN 1 ELSE 0 END) AS MandatorySubjects,
        SUM(CASE WHEN S.IsMandatory = 0 THEN 1 ELSE 0 END) AS OptionalSubjects
    FROM Course C
    JOIN SubjectCourse S ON S.CourseID = C.CourseID
    GROUP BY C.CourseName
);

SELECT * FROM course_subject_counts()

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

--18.	Create a scalar function that returns the age of a student given their StudentID (based on DOB).
CREATE FUNCTION get_Age(@DOB DATE)
RETURNS INT
AS
BEGIN
    DECLARE @AGE INT;
    
    SET @AGE = DATEDIFF(YEAR, @DOB, GETDATE()) - 
        CASE 
            WHEN (MONTH(@DOB) > MONTH(GETDATE()) OR
                  (MONTH(@DOB) = MONTH(GETDATE()) AND
				  DAY(@DOB) > DAY(GETDATE())))
            THEN 1 
            ELSE 0 
        END;

    RETURN @AGE;
END;

--19.	Create a function that returns the total number of courses a student is enrolled in.
CREATE OR ALTER FUNCTION enrolled_details( @studentid int)
RETURNS TABLE
AS
RETURN(
	SELECT S.StudentName, COUNT(C.CourseID) AS TOTALENROLMENT
	FROM Student s
	JOIN CourseEnrollment C ON C.StudentID = S.StudentID
	WHERE S.StudentID = @studentid
	GROUP BY C.StudentID, S.StudentName
)

SELECT * FROM enrolled_details(4);

-----------------------
--20. List student names, their enrolled courses, and course codes.
SELECT s.StudentName, c.CourseName, c.CourseCode
FROM Student s 
JOIN CourseEnrollment ce on ce.StudentID = s.StudentID
JOIN Course C ON C.CourseID=CE.CourseID;

--21. Show all students along with their contact information and enrolled course names.
SELECT S.StudentName, sc.Phone, sc.Email, c.CourseName
FROM Student S 
JOIN StudentContact SC ON SC.StudentID = S.StudentID
JOIN CourseEnrollment CE ON CE.StudentID = S.StudentID
JOIN Course C ON C.CourseID = CE.CourseID;

--22. Retrieve teacher names along with the subject names they teach and the department they belong to.
SELECT T.Name, D.DepartmentName, S.Name
FROM Teacher T
JOIN Department D ON D.DepartmentID = T.DepartmentId
JOIN TeacherSubject TS ON TS.TeacherID = T.TeacherID
JOIN Subject S ON S.SubjectID = TS.SubjectID;

--23. List all subjects along with the course(s) they are part of and whether they are mandatory.
SELECT S.Name, C.CourseName
FROM Subject S
JOIN SubjectCourse SC ON SC.SubjectID = S.SubjectID
JOIN Course C ON C.CourseID = SC.CourseID
WHERE SC.IsMandatory=1;

--24. Find all students along with the total amount paid and outstanding fee (using StudentFeeSummary and StudentFeePayment).
SELECT StudentID, TotalFeeAmount, OutstandingAmount
FROM StudentFeeSummary;

--25. List the student name, course name, and the department head of the department the course's teacher belongs to.
SELECT S.StudentName, C.CourseName, SUB.Name, T.Name, D.DepartmentHead
FROM Student S
JOIN CourseEnrollment CE ON CE.StudentID = S.StudentID
JOIN Course C ON C.CourseID = CE.CourseID
JOIN SubjectCourse SC ON SC.CourseID = C.CourseID
JOIN Subject SUB ON SUB.SubjectID = SC.SubjectID
JOIN TeacherSubject TS ON TS.SubjectID = SUB.SubjectID
JOIN Teacher T ON T.TeacherID = TS.TeacherID
JOIN Department D ON D.DepartmentID = T.DepartmentId;

--------------------------------
--26. Find the number of students enrolled in each course and show only those courses with more than 1 students.
SELECT C.CourseName, COUNT(*) AS ENROLLEDCOUNT
FROM Course C 
JOIN CourseEnrollment CE ON CE.CourseID = C.CourseID
GROUP BY C.CourseID,C.CourseName
HAVING COUNT(*) > 1;

--27. Find the total fee paid by students, grouped by course.
SELECT C.CourseName, SUM(FS.TotalPaidAmount) AS totalamount
FROM Student S
JOIN StudentFeeSummary FS ON FS.StudentID = S.StudentID
JOIN CourseEnrollment CE ON CE.StudentID =S.StudentID
JOIN Course C ON C.CourseID = CE.CourseID
GROUP BY C.CourseID, C.CourseName;

--28. List departments having more than one teacher assigned.
SELECT D.DepartmentName, count(*)
FROM Department D
JOIN Teacher T  ON T.DepartmentId = D.DepartmentID
GROUP BY D.DepartmentID, D.DepartmentName
HAVING COUNT(*) > 1;

--29. Show payment methods used and the total amount paid by each method, but only include methods where total payment exceeds 5000.
SELECT SFP.PaymentMethod, SUM(SFP.AmountPaid) AS PAIDAMOUNT
FROM StudentFeePayment SFP
GROUP BY SFP.PaymentMethod
HAVING SUM(SFP.AmountPaid) > 5000;

--30. Get the average fee paid by students, grouped by gender, and only include genders where average is above 3000.
SELECT s.Gender, AVG(FS.AmountPaid) AS AVGAMOUNT
FROM Student S
JOIN StudentFeePayment FS ON FS.StudentID = S.StudentID
GROUP BY S.Gender
HAVING AVG(FS.AmountPaid) > 3000;

--------------------------------------------
--FUNCTIONS
--31. Create a scalar function fn_GetStudentAge that returns the age of a student given their StudentID.
CREATE FUNCTION fn_GetStudentAge(@StudentID INT)
RETURNS INT
AS
BEGIN
    DECLARE @AGE INT;
    DECLARE @DOB DATE;

    SELECT @DOB = DOB
    FROM Student
    WHERE StudentID = @StudentID;

    SELECT @AGE = dbo.get_age(@DOB);

    RETURN @AGE;
END;

--32. Write a function fn_TotalPaidByStudent that takes a StudentID and returns the total amount paid.
CREATE FUNCTION fn_TotalPaidByStudent(@studentID INT)
RETURNS INT
AS
BEGIN
	DECLARE @TOTALAMOUNT INT;

	SELECT @TOTALAMOUNT = TotalPaidAmount
	FROM StudentFeeSummary
	WHERE StudentID = @studentID

	RETURN @TOTALAMOUNT;
END


SELECT dbo.fn_TotalPaidByStudent(4) AS TotalPaid;

--33. Create a function fn_EnrolledCourseCount to return the number of courses a student is enrolled.
CREATE FUNCTION fn_EnrolledCourseCount(@studentId INT)
RETURNS INT
AS
BEGIN
    DECLARE @COUNT INT;

    SELECT @COUNT = COUNT(*)
    FROM CourseEnrollment
    WHERE StudentID = @studentId;

    RETURN @COUNT;
END;

SELECT dbo.fn_EnrolledCourseCount(2) AS COUNTVALUE;

--34. Write a table-valued function that returns all subjects taught by a specific teacher.
CREATE FUNCTION fn_teacher_teachingSUB ( @teacherID INT )
RETURNS Table
AS
RETURN(
	SELECT T.Name, S.Name as subjectname
	FROM Teacher T 
	JOIN TeacherSubject TS ON TS.TeacherID = T.TeacherID
	JOIN Subject S ON S.SubjectID = TS.SubjectID
	WHERE T.TeacherID = @teacherID
)

SELECT * FROM fn_teacher_teachingSUB(1);

--35. Create a function to return the outstanding amount for a student based on real-time payment data (not the computed column).
CREATE FUNCTION check_outstandingamount(
    @StudentID INT,
    @Amount INT
)
RETURNS INT
AS
BEGIN
    DECLARE @OUT INT;

    SELECT @OUT = OutstandingAmount
    FROM StudentFeeSummary
    WHERE StudentID = @StudentID;

    SET @OUT = @OUT - @Amount;

    RETURN @OUT;
END;

-------------------------------
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

---------------
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

