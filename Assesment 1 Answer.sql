--SECTION A
--Q1. Design a relational database schema for hospital Mangement

--Patients Table
CREATE TABLE Patients (
	PatientID INT PRIMARY KEY IDENTITY(1,1),
	PatientsName VARCHAR(30) NOT NULL,
	ContactNo VARCHAR(20) NOT NULL,
	DOB DATE
)

--Depatement Table
CREATE TABLE Department (
	DepartmentID INT PRIMARY KEY IDENTITY (1,1),
	DeptName VARCHAR(20) NOT NULL
)

--Doctor Table
CREATE TABLE Doctor (
	DoctorID INT PRIMARY KEY IDENTITY(1,1),
	DoctorName VARCHAR(30) NOT NULL,
	ContactNo VARCHAR(20) NOT NULL,
	DOB DATE,
	DepartmentID INT,
	CONSTRAINT FK_Doctor_Depatment FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID)
)

--Appointments Table
CREATE TABLE Appointments (
	AppointmentID INT PRIMARY KEY IDENTITY(1,1),
	DoctorID INT,
	PatientID INT,
	Date DATE,
	CONSTRAINT FK_Appointments_Doctor  FOREIGN KEY (DoctorID)  REFERENCES Doctor(DoctorID),
	CONSTRAINT FK_Appointments_Patient FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
	CONSTRAINT Unique_Did_Pid_Date UNIQUE (DoctorID, PatientID, Date)
)

--DoctorFees Table
CREATE TABLE DoctorFees (
    FeeID INT PRIMARY KEY IDENTITY(1,1),
    DoctorID INT NOT NULL,
    ConsultationFee DECIMAL(10,2) NOT NULL,
    EffectiveFrom DATE NOT NULL,
    CONSTRAINT FK_DoctorFees_Doctor FOREIGN KEY (DoctorID) REFERENCES Doctor(DoctorID)
)

--Prescriptions Table
CREATE TABLE Prescriptions (
    PrescriptionID INT PRIMARY KEY IDENTITY(1,1),
    DoctorID INT NOT NULL,
    PatientID INT NOT NULL,
    AppointmentID INT NOT NULL,
    PrescribedDate DATE NOT NULL,
    Dosage VARCHAR(50),
	CONSTRAINT FK_Prescriptions_Appointment FOREIGN KEY (AppointmentID)  REFERENCES Appointments(AppointmentID)
)

--Index
CREATE NONCLUSTERED INDEX IX_name_depatmentID
ON Doctor(DoctorName)
INCLUDE (DepartmentID);

--Q2. Normalization
--Prouduct Table
CREATE TABLE Products (
	ProuductID INT PRIMARY KEY IDENTITY(1,1),
	ProuductName VARCHAR(30) NOT NULL,
	Price INT NOT NULL
)

--Customer Table
CREATE TABLE Customer (
	CustomerID INT PRIMARY KEY IDENTITY(1,1),
	CustomerName VARCHAR(30) NOT NULL,
	ContactNo VARCHAR(20) NOT NULL,
	AddressID INT,
	CONSTRAINT FK_Customer_Address FOREIGN KEY (AddressID)  REFERENCES Address(AddressID)
)

--Address Table
CREATE TABLE Address (
	AddressID INT PRIMARY KEY IDENTITY(1,1),
	City VARCHAR(20),
	PinCode VARCHAR(10),
	CONSTRAINT Unique_city_pincode UNIQUE (City,PinCode)
)

--Order Table
CREATE TABLE Orders(
	OrderID INT PRIMARY KEY IDENTITY(1,1),
	CustomerID INT,
	OrderDate DATE,
	TotalAmount INT,
	CONSTRAINT FK_Orders_Customer FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
)

--OrderDetails Table
CREATE TABLE OrderDetails (
	OrderDetailsID INT PRIMARY KEY IDENTITY(1,1),
	OrderID INT,
	ProductID INT,
	Quantity INT NOT NULL CHECK (Quantity <> 0),
	CONSTRAINT FK_OrderDetials_Order FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
	CONSTRAINT FK_OrderDetials_Prouduct FOREIGN KEY (ProductID) REFERENCES Products(ProuductID)
)
GO
-----------------------------------------------------------------------------------------------------------------

--SECTION B
--Q3. Write a query to find customers who have placed at least one order in each of the past 6 months.
CREATE TABLE OrdersQ3 (
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    OrderDate DATE
);

INSERT INTO OrdersQ3 (OrderID, CustomerID, OrderDate) VALUES
(1, 101, '2025-01-15'),
(2, 101, '2025-02-10'),
(3, 101, '2025-03-05'),
(4, 101, '2025-04-20'),
(5, 101, '2025-05-25'),
(6, 101, '2025-06-02');


WITH CTE AS (
    SELECT CustomerID, FORMAT(OrderDate, 'yyyyMM') AS OrderMonth
    FROM OrdersQ3
    WHERE OrderDate >= DATEADD(MONTH, -6, CAST(GETDATE() AS DATE))
)
SELECT CustomerID
FROM CTE
GROUP BY CustomerID
HAVING COUNT(DISTINCT OrderMonth) = 6;

--Q4. USING a recursive CTE, write a query to retrieve all employees who report directly or indirectly to a specific manger.
CREATE TABLE Employee (
    EmployeeID INT PRIMARY KEY,
    Name VARCHAR(100),
    ManagerID INT,
    FOREIGN KEY (ManagerID) REFERENCES Employee(EmployeeID)
);

INSERT INTO Employee (EmployeeID, Name, ManagerID) VALUES
(1, 'IMRAN', NULL),
(2, 'RAM', 1),
(3, 'ADIL', 1),
(4, 'GOKUL', 2),
(5, 'SARAVANAN', 2);

SELECT E2.Name AS Employee, E1.Name AS Manager
FROM Employee E1
INNER JOIN Employee E2 ON E1.EmployeeID = E2.ManagerID;

--Q5. Write a query to return the second highest salary from the employees table.
CREATE TABLE EmployeeQ5 (
    EmployeeID INT PRIMARY KEY,
    Name VARCHAR(100),
    Salary INT
);

INSERT INTO EmployeeQ5 (EmployeeID, Name, Salary) VALUES
(1, 'A', 70000),
(2, 'B', 85000),
(3, 'C', 120000),
(4, 'D', 90000),
(5, 'E', 120000);

SELECT MAX(Salary) AS SecondHighestSalary
FROM EmployeeQ5
WHERE Salary < (SELECT MAX(Salary) FROM EmployeeQ5);
GO;

WITH SalaryRank AS (
    SELECT Salary, DENSE_RANK() OVER (ORDER BY Salary DESC) AS rnk
    FROM EmployeeQ5
)
SELECT Salary
FROM SalaryRank
WHERE rnk = 2;
GO;
--Q6. Write a query that returns the 7 day rolling average of sales for each product.
CREATE TABLE Sales6 (
    SaleID INT PRIMARY KEY,
    ProductID INT,
    SaleDate DATE,
    SalesAmount DECIMAL(10, 2)
);

INSERT INTO Sales6 (SaleID, ProductID, SaleDate, SalesAmount) VALUES
(1, 101, '2025-06-01', 100.00),
(2, 101, '2025-06-02', 150.00),
(3, 101, '2025-06-03', 130.00),
(4, 101, '2025-06-04', 120.00),
(5, 101, '2025-06-05', 170.00),
(6, 101, '2025-06-06', 160.00),
(7, 101, '2025-06-07', 180.00);

SELECT 
    ProductID,
    SaleDate,
    AVG(SalesAmount) OVER (
        PARTITION BY ProductID
        ORDER BY SaleDate
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS Roll7day
FROM Sales6
ORDER BY ProductID, SaleDate;
-----------------------------------------------------------------------------------------------------------------------------
--SECTION C;
--Q7. Write a stored procedure
CREATE TABLE Products7 (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    Price DECIMAL(10, 2)
);

CREATE TABLE OrderDetails7 (
    OrderDetailID INT PRIMARY KEY,
    OrderID INT,
    ProductID INT,
    Quantity INT
);

CREATE TABLE AuditLog7 (
    AuditLogID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT,
    TotalCost DECIMAL(10, 2),
    LogDate DATETIME
);

INSERT INTO Products7 (ProductID, ProductName, Price) VALUES
(1, 'PEN', 10.00),
(2, 'PENCIL', 15.50),
(3, 'ERASER', 7.25);

INSERT INTO OrderDetails7 (OrderDetailID, OrderID, ProductID, Quantity) VALUES
(1, 1001, 1, 3),   
(2, 1001, 2, 2),  
(3, 1002, 3, 5);   
GO;

CREATE PROCEDURE CalculateOrderTotal
    @OrderID INT,
    @TotalCost INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT @TotalCost = SUM(od.Quantity * p.Price)
    FROM OrderDetails7 od
    INNER JOIN Products7 p ON od.ProductID = p.ProductID
    WHERE od.OrderID = @OrderID;

    INSERT INTO AuditLog7 (OrderID, TotalCost, LogDate)
    VALUES (@OrderID, @TotalCost, GETDATE());

END
GO

DECLARE @Total DECIMAL(10, 2);
EXEC CalculateOrderTotal @OrderID = 1001, @TotalCost = @Total OUTPUT;
SELECT @Total AS OrderTotal;
GO;

--Q8. Write a table-valued function that returns customers who have not placed any orders in the last N months, where N is a paramerter.
CREATE TABLE Customers8 (
    CustomerID INT PRIMARY KEY,
    Name NVARCHAR(100)
);

CREATE TABLE Orders8 (
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    OrderDate DATE,
    FOREIGN KEY (CustomerID) REFERENCES Customers8(CustomerID)
);

INSERT INTO Customers8 (CustomerID, Name) VALUES 
(1, 'A'),
(2, 'B'),
(3, 'C'),
(4, 'D');

INSERT INTO Orders8 (OrderID, CustomerID, OrderDate) VALUES
(101, 1, DATEADD(MONTH, -2, GETDATE())),  
(102, 2, DATEADD(MONTH, -10, GETDATE())), 
(103, 3, DATEADD(MONTH, -1, GETDATE())); 
GO;

CREATE FUNCTION dbo.GetInactiveCustomers (@Months INT)
RETURNS TABLE
AS
RETURN
(
    SELECT c.CustomerID, c.Name
    FROM Customers8 c
    LEFT JOIN Orders8 o ON c.CustomerID = o.CustomerID
    AND 
	o.OrderDate >= DATEADD(MONTH, -@Months, GETDATE())
    WHERE o.OrderID IS NULL
);
Go;

SELECT * FROM dbo.GetInactiveCustomers(6);

--Q9. Create a View that shows each customer's most recent order, along with the order amount. include only those custmers who have placed more than 5 orders.
CREATE TABLE Orders9 (
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    OrderDate DATE,
    OrderAmount DECIMAL(10, 2)
);

INSERT INTO Orders9 (OrderID, CustomerID, OrderDate, OrderAmount) VALUES
(1, 101, '2025-01-15', 100.00),
(2, 101, '2025-02-10', 150.00),
(3, 101, '2025-03-05', 200.00),
(4, 101, '2025-04-20', 250.00),
(5, 101, '2025-05-25', 300.00);

INSERT INTO Orders9 (OrderID, CustomerID, OrderDate, OrderAmount) VALUES
(6, 102, '2025-06-10', 400.00),
(7, 103, '2025-01-01', 90.00),
(8, 103, '2025-02-15', 110.00);


INSERT INTO Orders9 (OrderID, CustomerID, OrderDate, OrderAmount) VALUES
(16, 101, '2025-06-02', 350.00),
(17, 102, '2025-01-17', 120.00),
(18, 102, '2025-02-22', 180.00),
(19, 102, '2025-03-15', 220.00),
(10, 102, '2025-04-10', 280.00),
(11, 102, '2025-05-05', 330.00);
GO;

CREATE or alter  VIEW CustomerRecentOrders AS
SELECT o.CustomerID, o.OrderID, o.OrderDate, o.OrderAmount
FROM Orders9 o
WHERE o.OrderDate = (
    SELECT MAX(OrderDate)
    FROM Orders9 o2
    WHERE o2.CustomerID = o.CustomerID
)
AND o.CustomerID IN (
    SELECT CustomerID
    FROM Orders9
    GROUP BY CustomerID
    HAVING COUNT(*) > 5
);
GO;

SELECT * FROM CustomerRecentOrders
GO;

--Q10. Creae a determininstic scalar functions that returns the square of a number and can be used in an indexed view.
CREATE FUNCTION dbo.SquareNumber(@num INT)
RETURNS INT
WITH SCHEMABINDING
AS
BEGIN
    RETURN @num * @num;
END;
GO

SELECT dbo.SquareNumber(3)
------------------------------------------------------------------------------------------------------------------------------------------------
--SECTION D
--Q11. Write a trigger that prevents a prouduct's price from being reduced by more than 20% of its prvious value during an update.
CREATE TABLE Products11 (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    Price DECIMAL(10, 2),
    CategoryID INT
);

INSERT INTO Products11 (ProductID, ProductName, Price, CategoryID)
VALUES 
(1, 'Product A', 100.00, 1),
(2, 'Product B', 200.00, 2),
(3, 'Product C', 150.00, 3);
GO;

CREATE TRIGGER trg_PreventLargePriceDrop
ON Products11
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN deleted d ON i.ProductID = d.ProductID
        WHERE i.Price < d.Price * 0.8
    )
    BEGIN
        RAISERROR('Update blocked', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    UPDATE p
    SET 
        p.ProductName = i.ProductName,
        p.Price = i.Price,
        p.CategoryID = i.CategoryID
    FROM Products11 p
    JOIN inserted i ON p.ProductID = i.ProductID;
END;
GO

UPDATE Products11
SET Price = 70.00
WHERE ProductID = 1;


--Q12. Write a trigger captures any row deleted form teh employee table and insert it tino and employeearchive table, along with the current timestamp.
CREATE TABLE EmployeeArchive (
    EmployeeID INT,
    Name VARCHAR(100),
    Department VARCHAR(100),
    DeletedAt DATETIME
);

CREATE TABLE Employee12 (
    EmployeeID INT PRIMARY KEY,
    Name VARCHAR(100),
    Department VARCHAR(100)
);

INSERT INTO Employee12 (EmployeeID, Name, Department) VALUES
(1, 'A', 'HR'),
(2, 'B', 'Finance'),
(3, 'C', 'IT'),
(4, 'D', 'Marketing'),
(5, 'E', 'Sales');
GO;


CREATE TRIGGER trg_ArchiveDeletedEmployees
ON Employee12
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO EmployeeArchive (EmployeeID, Name, Department, DeletedAt )
    SELECT 
        EmployeeID,
        Name,
        Department,
        GETDATE() AS DeletedAt
    FROM deleted;
END;
GO

DELETE 
FROM Employee12
WHERE EmployeeID = 5;

SELECT * FROM EmployeeArchive;

--Q13. Define a user-defined data type for intenational phone numbers.
CREATE TYPE InternationalPhoneNumber FROM VARCHAR(20) NOT NULL;

CREATE TABLE Customer13 (
	CustomerId INT PRIMARY KEY,
	Name VARCHAR(30),
	Phone InternationalPhoneNumber
)

--Q14. Write a T-SQL block TRY-CATCH.
CREATE TABLE ErrorLog (
	ErrorNumber INT,
	ErrorMessage VARCHAR(100)
)

CREATE TABLE Employee14 (
	ID INT,
	NAME VARCHAR(30)
)

BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO Employee14 (ID, Name)
    VALUES ('HAAPY', 'value2');

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    DECLARE @ErrNum INT = ERROR_NUMBER();
    DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
    INSERT INTO ErrorLog (ErrorNumber, ErrorMessage)
    VALUES (@ErrNum, @ErrMsg);
END CATCH;

SELECT * FROM ErrorLog;
---------------------------------------------------------------------------------------------------------------------------
--SECTION E:
--Q15. Design a Training Mangement System that manages:
--1. Design
CREATE TABLE Trainer (
    TrainerID INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) UNIQUE NOT NULL,
    Phone NVARCHAR(20)
);

CREATE TABLE Trainee (
    TraineeID INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) UNIQUE NOT NULL,
    Phone NVARCHAR(20),
    DateOfBirth DATE,
    RegistrationDate DATE DEFAULT GETDATE()
);

CREATE TABLE Session (
    SessionID INT PRIMARY KEY IDENTITY(1,1),
    Title NVARCHAR(100) NOT NULL,
    Description NVARCHAR(500),
    TrainerID INT NOT NULL,
    StartDateTime DATETIME NOT NULL,
    EndDateTime DATETIME NOT NULL,
    Location NVARCHAR(100),
    CONSTRAINT FK_Session_Trainer FOREIGN KEY (TrainerID) REFERENCES Trainer(TrainerID)
);

CREATE TABLE Attendance (
    AttendanceID INT PRIMARY KEY IDENTITY(1,1),
    SessionID INT NOT NULL,
    TraineeID INT NOT NULL,
    AttendanceStatus NVARCHAR(20) NOT NULL CHECK (AttendanceStatus IN ('Present', 'Absent')),
    AttendanceDateTime DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Attendance_Session FOREIGN KEY (SessionID) REFERENCES Session(SessionID),
    CONSTRAINT FK_Attendance_Trainee FOREIGN KEY (TraineeID) REFERENCES Trainee(TraineeID),
    CONSTRAINT UQ_Attendance_Session_Trainee UNIQUE (SessionID, TraineeID)
);

CREATE TABLE Feedback (
    FeedbackID INT PRIMARY KEY IDENTITY(1,1),
    SessionID INT NOT NULL,
    TraineeID INT NOT NULL,
    Rating INT CHECK (Rating BETWEEN 1 AND 5),
    Comments NVARCHAR(1000),
    FeedbackDate DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Feedback_Session FOREIGN KEY (SessionID) REFERENCES Session(SessionID),
    CONSTRAINT FK_Feedback_Trainee FOREIGN KEY (TraineeID) REFERENCES Trainee(TraineeID)
);

CREATE TABLE AttendanceWarning (
    WarningID INT PRIMARY KEY IDENTITY(1,1),
    TraineeID INT NOT NULL,
    WarningDate DATETIME DEFAULT GETDATE(),
    WarningMessage NVARCHAR(500),
    CONSTRAINT FK_Warning_Trainee FOREIGN KEY (TraineeID) REFERENCES Trainee(TraineeID)
);
Go;

-- Insert data into Trainer
INSERT INTO Trainer (FirstName, LastName, Email, Phone) VALUES
('A', 'D', 'AMD@example.com', '15245125'),
('M', 'L', 'DFDF@example.com', '42516584'),
('E', 'Z', 'DFDFD@example.com', '45468454');

-- Insert data into Trainee
INSERT INTO Trainee (FirstName, LastName, Email, Phone, DateOfBirth) VALUES
('RAJA', 'RAM', 'RAJA@example.com', '5484654654', '1990-05-15'),
('SaraN', 'KUMAR', 'sara@example.com', '57545545', '1992-08-22'),
('DHANUSH', 'RAJA', 'DR@example.com', '67545455', '1988-11-30');

-- Insert data into Session
INSERT INTO Session (Title, Description, TrainerID, StartDateTime, EndDateTime, Location) VALUES
('SQL Basics', 'Introduction to SQL queries and databases', 1, '2025-07-01 09:00', '2025-07-01 12:00', 'Room 101'),
('Advanced Python', 'Deep dive into Python programming', 2, '2025-07-02 13:00', '2025-07-02 17:00', 'Room 102'),
('Data Analysis', 'Techniques for data analysis and visualization', 3, '2025-07-03 10:00', '2025-07-03 14:00', 'Room 103');

-- Insert data into Attendance
INSERT INTO Attendance (SessionID, TraineeID, AttendanceStatus) VALUES
(1, 1, 'Present'),
(1, 2, 'Absent'),
(2, 2, 'Present'),
(2, 3, 'Present'),
(3, 1, 'Absent'),
(3, 3, 'Present');

-- Insert data into Feedback
INSERT INTO Feedback (SessionID, TraineeID, Rating, Comments) VALUES
(1, 1, 5, 'Great session, very informative!'),
(2, 2, 4, 'Good content but a bit fast-paced.'),
(3, 3, 5, 'Excellent instructor and materials.');
GO

--2. Stored procedure
CREATE PROCEDURE sp_AddAttendance
    @SessionID INT,
    @TraineeID INT,
    @AttendanceStatus NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1 FROM Attendance
        WHERE SessionID = @SessionID AND TraineeID = @TraineeID
    )
    BEGIN
        RAISERROR('Attendance record for this trainee and session already exists.', 16, 1);
        RETURN;
    END

    INSERT INTO Attendance (SessionID, TraineeID, AttendanceStatus)
    VALUES (@SessionID, @TraineeID, @AttendanceStatus);
END
GO

--3. View to show each Trainee's attedndance rate
CREATE OR ALTER  VIEW vw_TraineeAttendanceRate AS
WITH AttendanceStats AS (
    SELECT 
        t.TraineeID,
        t.FirstName,
        t.LastName,
        COUNT(a.AttendanceID) AS TotalSessions,
        SUM(CASE WHEN a.AttendanceStatus = 'Present' THEN 1 ELSE 0 END) AS PresentSessions
    FROM Trainee t
    LEFT JOIN Attendance a ON t.TraineeID = a.TraineeID
    GROUP BY t.TraineeID, t.FirstName, t.LastName
)
SELECT 
    TraineeID,
    FirstName,
    LastName,
    ISNULL(100 * PresentSessions / NULLIF(TotalSessions, 0), 0) AS AttendanceRatePercentage
FROM AttendanceStats;
GO;

SELECT * FROM vw_TraineeAttendanceRate;
GO;
--4. Create trigger that inserts a warning into a warning table if a trinee's attedance drops below 70%.
CREATE TRIGGER trg_Warning
ON Attendance
AFTER INSERT
AS
BEGIN
	INSERT INTO AttendanceWarning (TraineeID, WarningDate, WarningMessage)
	SELECT DISTINCT I.TraineeID, GETDATE(), 'Below 70%'
	FROM inserted I
	WHERE dbo.fn_AttendanceCheck(I.TraineeID) < 70 --If the call call properly then all right
END
GO;

CREATE FUNCTION dbo.fn_AttendanceCheck ( @traineeId INT )
RETURNS DECIMAL(12,6) 
AS
BEGIN
	DECLARE @PERCENTAGE DECIMAL(12,6);

	SELECT 
		@PERCENTAGE = ISNULL(100.0 * SUM(CASE WHEN AttendanceStatus = 'Present' THEN 1 ELSE 0 END) / 
			NULLIF(COUNT(*), 0), 0)
	FROM Attendance
	WHERE TraineeID = @traineeId;

	RETURN @PERCENTAGE
END;
GO;