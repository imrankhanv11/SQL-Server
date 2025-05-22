--Create new database for joins
CREATE DATABASE JOINS;
---------------------------------------------------------------------------------------
--using the database
USE JOINS;
---------------------------------------------------------------------------------------

-- Create Department table first
CREATE TABLE Department (
    DepartmentID INT PRIMARY KEY IDENTITY(1,1),
    DepartmentName NVARCHAR(100) NOT NULL
);

--insert values for department table
INSERT INTO Department (DepartmentName) VALUES ('Human Resources');
INSERT INTO Department (DepartmentName) VALUES ('Information Technology');
INSERT INTO Department (DepartmentName) VALUES ('Finance');
---------------------------------------------------------------------------------------

-- Create Employee table second, which references Department
CREATE TABLE tbl_Employee (
    EmployeeID INT PRIMARY KEY,
    EmployeeName VARCHAR(30) NOT NULL,
    DepartmentID INT NOT NULL,
    FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID)
);

--insert values for employee table
-- Assume DepartmentIDs: 1 = HR, 2 = IT, 3 = Finance
INSERT INTO tbl_Employee (EmployeeID, EmployeeName, DepartmentID) VALUES (1,'Arun Kumar', 1);
INSERT INTO tbl_Employee (EmployeeID, EmployeeName, DepartmentID) VALUES (2,'Priya', 2);
INSERT INTO tbl_Employee (EmployeeID, EmployeeName, DepartmentID) VALUES (3,'Ravi', 2);
INSERT INTO tbl_Employee (EmployeeID, EmployeeName, DepartmentID) VALUES (4,'Ram', 3);
INSERT INTO tbl_Employee (EmployeeID, EmployeeName, DepartmentID) VALUES (5,'Kumaran', 1);
INSERT INTO tbl_Employee (EmployeeID, EmployeeName, DepartmentID) VALUES (6,'Gokul', 1);
---------------------------------------------------------------------------------------

-- Create EmployeePersonalDetails table last, which references Employee
CREATE TABLE EmployeePersonalDetails (
    DetailID INT PRIMARY KEY IDENTITY(1,1),
    EmployeeID INT NOT NULL,
    DateOfBirth DATE,
    Address NVARCHAR(255),
    PhoneNumber NVARCHAR(15),
    FOREIGN KEY (EmployeeID) REFERENCES tbl_Employee(EmployeeID)
);

--insert values for employee personal details
INSERT INTO EmployeePersonalDetails (EmployeeID, DateOfBirth, Address, PhoneNumber)
VALUES (1, '1990-05-12', '23 MG Road, Chennai', '9876543210'),
(2, '1992-08-25', '14 Bannerghatta Road, Bangalore', '9123456789'),
(3, '1988-11-10', '7 Cyber City, Hyderabad', '9001122334'),
(4, '1995-03-18', '89 Jubilee Hills, Hyderabad', '9988776655'),
(5, '1985-07-29', '45 Park Street, Kolkata', '9665544332');

INSERT INTO EmployeePersonalDetails (EmployeeID, DateOfBirth, Address)
VALUES (6, '1985-07-26', '45 nEW Park Street, Kolkata');
---------------------------------------------------------------------------------------

--Inner join
SELECT E.EmployeeName, D.DepartmentName
FROM tbl_Employee E
INNER JOIN Department D ON E.DepartmentID=D.DepartmentID;
---------------------------------------------------------------------------------------

--Left Join
SELECT E.EmployeeName, EP.DateOfBirth, EP.PhoneNumber
FROM tbl_Employee E
LEFT JOIN EmployeePersonalDetails EP ON EP.EmployeeID = E.EmployeeID;
---------------------------------------------------------------------------------------

--right join
SELECT E.EmployeeName, EP.DateOfBirth, EP.PhoneNumber
FROM EmployeePersonalDetails EP
RIGHT JOIN tbl_Employee E ON EP.EmployeeID = E.EmployeeID;
---------------------------------------------------------------------------------------

-- Full Outer Join
SELECT E.EmployeeName, EP.DateOfBirth, EP.PhoneNumber
FROM tbl_Employee E
FULL OUTER JOIN EmployeePersonalDetails EP ON EP.EmployeeID = E.EmployeeID;
---------------------------------------------------------------------------------------

-- Cross Join
SELECT E.EmployeeName, D.DepartmentName
FROM tbl_Employee E
CROSS JOIN Department D;
---------------------------------------------------------------------------------------

-- Inner Join across all three tables
SELECT 
    E.EmployeeID,
    E.EmployeeName,
    D.DepartmentName,
    EP.DateOfBirth,
    EP.Address,
    EP.PhoneNumber
FROM tbl_Employee E
INNER JOIN Department D ON E.DepartmentID = D.DepartmentID
INNER JOIN EmployeePersonalDetails EP ON E.EmployeeID = EP.EmployeeID;
---------------------------------------------------------------------------------------



