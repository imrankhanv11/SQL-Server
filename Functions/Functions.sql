CREATE DATABASE Functions;

USE Functions;

CREATE TABLE Departments (
    DepartmentID INT PRIMARY KEY IDENTITY(1,1),
    DepartmentName NVARCHAR(100)
);

CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    BirthDate DATE,
    HireDate DATE,
    Salary DECIMAL(10, 2),
    DepartmentID INT FOREIGN KEY REFERENCES Departments(DepartmentID)
);

CREATE TABLE Projects (
    ProjectID INT PRIMARY KEY IDENTITY(1,1),
    ProjectName NVARCHAR(100),
    StartDate DATE,
    EndDate DATE,
    DepartmentID INT FOREIGN KEY REFERENCES Departments(DepartmentID)
);

INSERT INTO Departments (DepartmentName) VALUES
('Sales'),
('Marketing'),
('IT'),
('HR');

INSERT INTO Employees (FirstName, LastName, BirthDate, HireDate, Salary, DepartmentID) VALUES
('John', 'Doe', '1985-04-23', '2010-06-15', 60000, 1),
('Jane', 'Smith', '1990-11-30', '2012-09-01', 75000, 3),
('Michael', 'Johnson', '1982-01-12', '2008-03-20', 80000, 3),
('Emily', 'Davis', '1995-07-19', '2018-11-12', 55000, 2),
('William', 'Brown', '1978-05-05', '2005-04-01', 90000, 1),
('Linda', 'Wilson', '1988-12-25', '2013-08-19', 62000, 4);

INSERT INTO Projects (ProjectName, StartDate, EndDate, DepartmentID) VALUES
('Project Alpha', '2023-01-01', '2023-06-30', 1),
('Project Beta', '2023-03-15', '2023-09-15', 3),
('Project Gamma', '2023-05-01', '2023-12-31', 2),
('Project Delta', '2023-02-20', '2023-08-20', 4);

SELECT * FROM Departments;

SELECT * FROM Employees;

SELECT * FROM Projects;

----------------------------------------------------------------------------------------------------------------

--Retrieve employees’ full names in uppercase.
CREATE FUNCTION fullname(@firstName VARCHAR(20), @lastName VARCHAR(20))
RETURNS VARCHAR(50)
AS
BEGIN 
	RETURN @firstName+' '+@lastName;
end;

-------calling functions
SELECT dbo.fullname(FirstName, LastName) AS FullNameUpper
FROM Employees;


--Calculate the current age of each employee.
CREATE FUNCTION agecalculate(@DOB DATE)
RETURNS INT
AS
BEGIN
    RETURN FLOOR(DATEDIFF(day, @DOB, GETDATE()) / 365.25);
END;

--calling function
SELECT dbo.fullname(FirstName, LastName) AS FullName, dbo.agecalculate(BirthDate) AS AGE
FROM Employees;

----------------------------------------------------------------------------------------------------------------
-- Get all employees who work in a specific department by passing the department ID.
CREATE FUNCTION dbo.GetEmployeesByDepartment (@DeptID INT)
RETURNS TABLE
AS
RETURN
(
    SELECT EmployeeID, FirstName, LastName, Salary, HireDate
    FROM Employees
    WHERE DepartmentID = @DeptID
);

--calling functions
SELECT * FROM dbo.GetEmployeesByDepartment(3);

-- Retrieve all projects that start and end within a given date range.
CREATE FUNCTION dbo.projectsInDateRange (@StartDate DATE, @EndDate DATE)
RETURNS @Projects TABLE
(
    ProjectID INT,
    ProjectName NVARCHAR(100),
    StartDate DATE,
    EndDate DATE,
    DepartmentID INT
)
AS
BEGIN
    INSERT INTO @Projects
    SELECT ProjectID, ProjectName, StartDate, EndDate, DepartmentID
    FROM Projects
    WHERE StartDate >= @StartDate AND EndDate <= @EndDate;

    RETURN;
END;

--calling functions
SELECT * FROM dbo.projectsInDateRange('2023-01-01', '2023-06-30');


--List all employees with a salary greater than a specified amount.
CREATE FUNCTION dbo.highSalaryEmployees (@MinSalary DECIMAL(10,2))
RETURNS TABLE
AS
RETURN
(
    SELECT EmployeeID, FirstName, LastName, Salary, DepartmentID
    FROM Employees
    WHERE Salary > @MinSalary
);

--calling functions
SELECT * FROM dbo.highSalaryEmployees(70000);

--Get the number of employees and average salary for each department.
CREATE FUNCTION dbo.GetDepartmentStats()
RETURNS @DeptStats TABLE
(
    DepartmentID INT,
    DepartmentName NVARCHAR(100),
    EmployeeCount INT,
    AverageSalary DECIMAL(10,2)
)
AS
BEGIN
    INSERT INTO @DeptStats
    SELECT 
        d.DepartmentID,
        d.DepartmentName,
        COUNT(e.EmployeeID),
        AVG(e.Salary)
    FROM Departments d
    LEFT JOIN Employees e ON d.DepartmentID = e.DepartmentID
    GROUP BY d.DepartmentID, d.DepartmentName;

    RETURN;
END;

--calling functions
SELECT * FROM dbo.GetDepartmentStats();




