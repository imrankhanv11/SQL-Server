--Using Database(Practice)
USE Practice;

--1. Create Table
CREATE TABLE Employee(
	EmployeeID INT CONSTRAINT PK_Employee PRIMARY KEY,
	Name VARCHAR(30) NOT NULL,
	Department VARCHAR(20) DEFAULT 'Trainee',
	Salary INT
);

--------------------------------------

--2. Drop Table
DROP TABLE Employee;     

--------------------------------------

--3. Alter Table (add new Coloum)
ALTER TABLE Employee
ADD age INT;

--Alter Table (drop Coloum)
ALTER TABLE Employee
DROP COLUMN Department;

--Alter Table (Change Datatype or Size)
ALTER TABLE Employee
ALTER COLUMN Name VARCHAR(25);

--Alter Table (add Constraint)
ALTER TABLE Employee
ADD CONSTRAINT CK_Salary CHECK (Salary > 0);

--Alter Table (drop Constraint)
ALTER TABLE Employee
DROP CONSTRAINT CK_Salary;

--------------------------------------

--4. Truncate Table
TRUNCATE TABLE Employee;

--------------------------------------

--5. Reaname Coloum
EXEC sp_rename 'Employee.age', 'Age', 'COLUMN';
