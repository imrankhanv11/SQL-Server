--Create Database 
CREATE DATABASE WindowFunctions;

--USE Database
USE WindowFunctions;

CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,
    EmployeeName VARCHAR(50),
    Department VARCHAR(50)
);

INSERT INTO Employees VALUES
(1, 'Alice', 'Sales'),
(2, 'Bob', 'Marketing'),
(3, 'Charlie', 'Sales'),
(4, 'Diana', 'HR');


CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    EmployeeID INT,
    OrderDate DATE,
    OrderAmount DECIMAL(10,2),
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);

INSERT INTO Orders VALUES
(101, 1, '2024-01-10', 500.00),
(102, 2, '2024-01-12', 300.00),
(103, 1, '2024-01-15', 700.00),
(104, 3, '2024-01-20', 200.00),
(105, 2, '2024-01-25', 900.00),
(106, 4, '2024-01-30', 100.00);

INSERT INTO Orders VALUES
(107, 1, '2024-02-01', 500.00),
(108, 2, '2024-02-03', 300.00),
(109, 3, '2024-02-05', 200.00),
(110, 4, '2024-02-07', 100.00),
(111, 1, '2024-02-10', 700.00),
(112, 2, '2024-02-15', 900.00),
(113, 3, '2024-02-20', 200.00),
(114, 4, '2024-02-22', 100.00),
(115, 1, '2024-02-25', 500.00);


CREATE TABLE Bonuses (
    BonusID INT PRIMARY KEY,
    EmployeeID INT,
    BonusAmount DECIMAL(10,2),
    BonusDate DATE,
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);

INSERT INTO Bonuses VALUES
(201, 1, 50.00, '2024-01-31'),
(202, 2, 75.00, '2024-01-31'),
(203, 3, 40.00, '2024-01-31'),
(204, 4, 25.00, '2024-01-31');

INSERT INTO Bonuses VALUES
(205, 1, 50.00, '2024-02-01'),
(206, 2, 75.00, '2024-02-03'),
(207, 3, 40.00, '2024-02-05'),
(208, 4, 25.00, '2024-02-07'),
(209, 1, 50.00, '2024-02-10'),
(210, 2, 75.00, '2024-02-12'),
(211, 3, 40.00, '2024-02-15'),
(212, 4, 25.00, '2024-02-17'),
(213, 1, 50.00, '2024-02-20'),
(214, 2, 75.00, '2024-02-22'),
(215, 3, 40.00, '2024-02-25');


----------------------------------------------------
SELECT *
FROM Employees E 
LEFT JOIN Orders O ON O.EmployeeID = E.EmployeeID
LEFT JOIN Bonuses B ON B.EmployeeID = E.EmployeeID;
----------------------------------------------------
--Row_number
SELECT *, ROW_NUMBER() OVER ( PARTITION BY Department ORDER BY OrderAmount ) AS ROWNUMBER
FROM Employees e
LEFT JOIN Orders o ON o.EmployeeID = e.EmployeeID;

--Rank number
SELECT *, RANK() OVER ( PARTITION BY Department ORDER BY OrderAmount ) AS ROWNUMBER
FROM Employees e
LEFT JOIN Orders o ON o.EmployeeID = e.EmployeeID;

--Dense rank
SELECT *, DENSE_RANK() OVER ( PARTITION BY Department ORDER BY OrderAmount DESC ) AS ROWNUMBER
FROM Employees e
LEFT JOIN Orders o ON o.EmployeeID = e.EmployeeID;

--NTILE
SELECT *, NTILE(2) OVER ( PARTITION BY Department ORDER BY OrderAmount ) AS ROWNUMBER
FROM Employees e
LEFT JOIN Orders o ON o.EmployeeID = e.EmployeeID;

---------------------------------------------------------

-- 1. Rank employees by total order amount across all orders
SELECT 
    EmployeeID,
    SUM(OrderAmount) AS TotalOrder,
    RANK() OVER (ORDER BY SUM(OrderAmount) DESC) AS OrderRank
FROM Orders
GROUP BY EmployeeID;


-- 2. Rank orders within each employee by order amount (descending)
SELECT *,
    RANK() OVER (PARTITION BY EmployeeID ORDER BY OrderAmount DESC) AS RankPerEmployee
FROM Orders;


-- 3. Find total order amount per employee with window SUM
SELECT 
    OrderID,
    EmployeeID,
    OrderAmount,
    SUM(OrderAmount) OVER (PARTITION BY EmployeeID order by EmployeeID) AS TotalPerEmployee
FROM Orders;


-- 4. Find running total of orders for each employee (by date)
SELECT 
    EmployeeID,
    OrderDate,
    OrderAmount,
    SUM(OrderAmount) OVER (PARTITION BY EmployeeID ORDER BY OrderDate) AS RunningTotal
FROM Orders;


-- 5. Get previous order amount for each employee using LAG
SELECT 
    EmployeeID,
    OrderID,
    OrderAmount,
    LAG(OrderAmount) OVER (PARTITION BY EmployeeID ORDER BY OrderDate) AS PrevOrder
FROM Orders;


-- 6. Get next bonus amount for each employee using LEAD
SELECT 
    EmployeeID,
    BonusAmount,
    BonusDate,
    LEAD(BonusAmount) OVER (PARTITION BY EmployeeID ORDER BY BonusDate) AS NextBonus
FROM Bonuses;


-- 7. Assign row numbers to orders for each employee
SELECT 
    EmployeeID,
    OrderID,
    ROW_NUMBER() OVER (PARTITION BY EmployeeID ORDER BY OrderDate) AS RowNum
FROM Orders;


-- 8. Divide orders into 4 buckets (quartiles) based on amount
SELECT 
    OrderID,
    OrderAmount,
    NTILE(4) OVER (ORDER BY OrderAmount) AS AmountQuartile
FROM Orders;


-- 9. Get highest bonus per employee using MAX() OVER
SELECT 
    EmployeeID,
    BonusAmount,
    MAX(BonusAmount) OVER (PARTITION BY EmployeeID) AS MaxBonusPerEmp
FROM Bonuses;

-- 11. Average order amount per employee
SELECT 
    EmployeeID,
    OrderAmount,
    AVG(OrderAmount) OVER (PARTITION BY EmployeeID) AS AvgOrder
FROM Orders;


-- 12. Find employees with the second highest bonus using DENSE_RANK
WITH RankedBonuses AS (
    SELECT *, DENSE_RANK() OVER (ORDER BY BonusAmount DESC) AS BonusRank
    FROM Bonuses
)
SELECT * 
FROM RankedBonuses
WHERE BonusRank = 2;


-- 13. Calculate difference between current and previous bonus for each employee
SELECT 
    EmployeeID,
    BonusDate,
    BonusAmount,
    BonusAmount - LAG(BonusAmount) OVER (PARTITION BY EmployeeID ORDER BY BonusDate) AS BonusDiff
FROM Bonuses;


-- 14. Show total company-wide bonus per row
SELECT 
    EmployeeID,
    BonusAmount,
    SUM(BonusAmount) OVER () AS TotalCompanyBonus
FROM Bonuses;


-- 15. Rank employees by average order amount
SELECT 
    EmployeeID,
    AVG(OrderAmount) AS AvgOrderAmount,
    RANK() OVER (ORDER BY AVG(OrderAmount) DESC) AS AvgOrderRank
FROM Orders
GROUP BY EmployeeID;
