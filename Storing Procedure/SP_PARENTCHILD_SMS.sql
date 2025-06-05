--SP FOR STUDENT AND STUDENTCONTACT
--CHILD ( INSERT STUDENT )
CREATE PROCEDURE sp_InsertStudent
    @StudentName NVARCHAR(100),
    @DOB DATE,
    @Gender CHAR(1),
    @NewStudentID INT OUTPUT
AS
BEGIN
    BEGIN TRY
        IF @StudentName IS NULL OR LTRIM(RTRIM(@StudentName)) = ''
        BEGIN
            RAISERROR('Student name is required.', 16, 1);
            RETURN;
        END
        IF @Gender NOT IN ('Male', 'Female')
        BEGIN
            RAISERROR('Gender must be Male or Female.', 16, 1);
            RETURN;
        END

        INSERT INTO Student (StudentName, DOB, Gender)
        VALUES (@StudentName, @DOB, @Gender);

        SET @NewStudentID = SCOPE_IDENTITY();
    END TRY
    BEGIN CATCH
        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrMsg, 16, 1);
    END CATCH
END

--CHILD ( INSERT STUDENT CONTACT )
CREATE PROCEDURE sp_InsertStudentContact
    @StudentID INT,
    @Phone NVARCHAR(15),
    @Email NVARCHAR(100),
    @Address NVARCHAR(255),
    @GuardianName NVARCHAR(100),
    @GuardianPhone NVARCHAR(15)
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Student WHERE StudentID = @StudentID)
        BEGIN
            RAISERROR('Student ID does not exist.', 16, 1);
            RETURN;
        END
        IF @Phone IS NULL OR LEN(@Phone) < 10
        BEGIN
            RAISERROR('Phone number is invalid.', 16, 1);
            RETURN;
        END

        INSERT INTO StudentContact (StudentID, Phone, Email, Address, GuardianName, GuardianPhone)
        VALUES (@StudentID, @Phone, @Email, @Address, @GuardianName, @GuardianPhone);
    END TRY
    BEGIN CATCH
        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrMsg, 16, 1);
    END CATCH
END


--PARENT
CREATE PROCEDURE sp_InsertFullStudent
    @StudentName NVARCHAR(100),
    @DOB DATE,
    @Gender CHAR(1),
    @Phone NVARCHAR(15),
    @Email NVARCHAR(100),
    @Address NVARCHAR(255),
    @GuardianName NVARCHAR(100),
    @GuardianPhone NVARCHAR(15)
AS
BEGIN
    DECLARE @NewStudentID INT;

    BEGIN TRY
        BEGIN TRANSACTION;

        EXEC sp_InsertStudent
            @StudentName = @StudentName,
            @DOB = @DOB,
            @Gender = @Gender,
            @NewStudentID = @NewStudentID OUTPUT;

        EXEC sp_InsertStudentContact
            @StudentID = @NewStudentID,
            @Phone = @Phone,
            @Email = @Email,
            @Address = @Address,
            @GuardianName = @GuardianName,
            @GuardianPhone = @GuardianPhone;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrMsg, 16, 1);
    END CATCH
END

-----------------------------------------------------------------------------------------------------------

--SP FOR TEACHER AND TEACHER CONTACT
--CHILD ( INSERT TEACHER )
CREATE PROCEDURE sp_InsertTeacher
    @Name NVARCHAR(100),
    @DepartmentID INT,
    @NewTeacherID INT OUTPUT
AS
BEGIN
    BEGIN TRY
        IF @Name IS NULL OR LTRIM(RTRIM(@Name)) = ''
        BEGIN
            RAISERROR('Teacher name is required.', 16, 1);
            RETURN;
        END
        IF NOT EXISTS (SELECT 1 FROM Department WHERE DepartmentID = @DepartmentID)
        BEGIN
            RAISERROR('Invalid Department ID.', 16, 1);
            RETURN;
        END

        INSERT INTO Teacher (Name, DepartmentID)
        VALUES (@Name, @DepartmentID);

        SET @NewTeacherID = SCOPE_IDENTITY();
    END TRY
    BEGIN CATCH
        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrMsg, 16, 1);
    END CATCH
END

--CHILD ( INSERT TEACHER CONTACT )
CREATE PROCEDURE sp_InsertTeacherContact
    @TeacherID INT,
    @Phone NVARCHAR(15),
    @Email NVARCHAR(100),
    @Address NVARCHAR(255),
    @EmergencyContact NVARCHAR(15)
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Teacher WHERE TeacherID = @TeacherID)
        BEGIN
            RAISERROR('Teacher ID does not exist.', 16, 1);
            RETURN;
        END
        IF @Phone IS NULL OR LEN(@Phone) < 10
        BEGIN
            RAISERROR('Invalid phone number.', 16, 1);
            RETURN;
        END

        INSERT INTO TeacherContact (TeacherID, Phone, Email, Address, EmergencyContact)
        VALUES (@TeacherID, @Phone, @Email, @Address, @EmergencyContact);
    END TRY
    BEGIN CATCH
        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrMsg, 16, 1);
    END CATCH
END

--PARENT ( BOTH TEACHER AND TEACHER CONTACT )
CREATE PROCEDURE sp_InsertFullTeacher
    @Name NVARCHAR(100),
    @DepartmentID INT,
    @Phone NVARCHAR(15),
    @Email NVARCHAR(100),
    @Address NVARCHAR(255),
    @EmergencyContact NVARCHAR(15)
AS
BEGIN
    DECLARE @NewTeacherID INT;

    BEGIN TRY
        BEGIN TRANSACTION;

        EXEC sp_InsertTeacher
            @Name = @Name,
            @DepartmentID = @DepartmentID,
            @NewTeacherID = @NewTeacherID OUTPUT;

        EXEC sp_InsertTeacherContact
            @TeacherID = @NewTeacherID,
            @Phone = @Phone,
            @Email = @Email,
            @Address = @Address,
            @EmergencyContact = @EmergencyContact;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrMsg, 16, 1);
    END CATCH
END

----------------------------------------------------------------------------------------------------------------------

