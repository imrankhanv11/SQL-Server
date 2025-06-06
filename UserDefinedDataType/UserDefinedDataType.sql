--Create Scalar UDT
CREATE TYPE PhoneNumber FROM VARCHAR(15) NOT NULL;

--Use UDT in a Table
CREATE TABLE Contacts (
    ContactID INT PRIMARY KEY,
    FullName VARCHAR(100),
    Mobile PhoneNumber -- using scalar UDT
);

--Insert Data Using UDT
INSERT INTO Contacts VALUES (1, 'Alice', '1234567890');

--Declare and Use a Variable of UDT Type
DECLARE @MyPhone PhoneNumber;
SET @MyPhone = '9876543210';
PRINT 'My Phone: ' + @MyPhone;

--Use UDT in a Stored Procedure
CREATE PROCEDURE AddContact
    @FullName VARCHAR(100),
    @Mobile PhoneNumber
AS
BEGIN
    INSERT INTO Contacts (FullName, Mobile) VALUES (@FullName, @Mobile);
END;

-- Call the procedure
EXEC AddContact 'Bob', '7778889999';

--Use UDT in a Scalar Function
CREATE FUNCTION FormatPhone (@Mobile PhoneNumber)
RETURNS VARCHAR(20)
AS
BEGIN
    RETURN '+91-' + @Mobile;
END;

-- Use the function
SELECT FullName, dbo.FormatPhone(Mobile) AS FormattedMobile FROM Contacts;

--unsupported features ( this will fails )
--can't create constraints inside UDT:
-- CREATE TYPE EmailType FROM VARCHAR(50) CHECK (EmailType LIKE '%@%');Not allowed

--can't ALTER a UDT
-- ALTER TYPE PhoneNumber FROM VARCHAR(20); --Not allowed

--Drop UDT (only after removing all dependencies)
--Clean up (drop procedure, function, table first)
DROP PROCEDURE AddContact;
DROP FUNCTION FormatPhone;
DROP TABLE Contacts;
DROP TYPE PhoneNumber;

--------------------------------------------------------------------------------------------------
--Create Scalar UDT (used inside the table type)
CREATE TYPE PhoneNumber FROM VARCHAR(15) NOT NULL;

--Create User-Defined Table Type (UDTT)
CREATE TYPE EmployeeTableType AS TABLE (
    EmpID INT PRIMARY KEY,
    Name VARCHAR(100),
    Mobile PhoneNumber -- using scalar UDT here
);

--Create target table
CREATE TABLE Employees (
    EmpID INT PRIMARY KEY,
    Name VARCHAR(100),
    Mobile PhoneNumber
);

--Create a stored procedure that accepts the UDTT
CREATE PROCEDURE InsertEmployees
    @EmpData EmployeeTableType READONLY
AS
BEGIN
    INSERT INTO Employees (EmpID, Name, Mobile)
    SELECT EmpID, Name, Mobile FROM @EmpData;
END;

--Declare a variable of the table type and insert sample data
DECLARE @EmpList EmployeeTableType;

INSERT INTO @EmpList VALUES 
(1, 'Alice', '1234567890'),
(2, 'Bob', '9876543210');

--Execute the procedure using the table-type variable
EXEC InsertEmployees @EmpList;

--Query the Employees table to see inserted data
SELECT * FROM Employees;

--Unsupported operations (fail)
--cannot ALTER the table type directly
-- ALTER TYPE EmployeeTableType ADD Department VARCHAR(50); --Not allowed

--cannot define default values in UDTT
-- CREATE TYPE MyTableType AS TABLE (ID INT DEFAULT 1); --Not allowed

--Table-type parameters must be READONLY
-- CREATE PROCEDURE InvalidProc (@Data EmployeeTableType) AS BEGIN END;

--Drop all created objects in correct order
DROP PROCEDURE InsertEmployees;
DROP TABLE Employees;
DROP TYPE EmployeeTableType;
DROP TYPE PhoneNumber;
