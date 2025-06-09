-- Use your database
USE Practice;
GO

-- 1. CREATE A SIMPLE VIEW (Single table, no join or aggregate)
CREATE VIEW simpleview AS
SELECT *
FROM Sales;
GO

-- 2. USE THE SIMPLE VIEW (Read)
SELECT * FROM simpleview;
GO

-- 3. SELECT with FILTER and ORDER
SELECT * FROM simpleview WHERE TotalPrice > 1000;
SELECT * FROM simpleview ORDER BY SaleDate DESC;
GO

-- 4. SELECT with JOIN using the view
SELECT v.CustomerID, u.Username
FROM simpleview v
JOIN Users u ON v.UserID = u.UserID;
GO

-- 5. SELECT with GROUP BY (outside view)
SELECT PaymentMethod, COUNT(*) AS Count
FROM simpleview
GROUP BY PaymentMethod;
GO

-- 8. CREATE COMPLEX VIEW (JOIN between tables)
CREATE VIEW complexview AS
SELECT E.Name, D.DepartmentID, D.DepartmentName, E.Salary
FROM Employee E
JOIN Department D ON D.DepartmentID = E.Department;
GO

-- 9. SELECT FROM COMPLEX VIEW
SELECT * FROM complexview;
GO

-- 10. TRYING TO INSERT INTO COMPLEX VIEW  Not allowed)
-- INSERT INTO complexview (Name, DepartmentID, Salary) VALUES ('New Emp', 2, 50000); --  Will fail
-- GO

-- 11. CREATE VIEW WITH AGGREGATE
CREATE VIEW total_sales_by_customer AS
SELECT CustomerID, SUM(TotalPrice) AS TotalSales
FROM Sales
GROUP BY CustomerID;
GO

-- 12. SELECT FROM AGGREGATE VIEW
SELECT * FROM total_sales_by_customer;
GO

-- 13. CREATE VIEW WITH EXPRESSION
CREATE VIEW sales_with_gst AS
SELECT SaleID, CustomerID, TotalPrice, TotalPrice * 0.18 AS GST
FROM Sales;
GO

-- 14. SELECT FROM EXPRESSION VIEW
SELECT * FROM sales_with_gst;
GO

-- 15. INVALID: CREATE VIEW WITH ORDER BY ( Not allowed unless using TOP or OFFSET-FETCH)
-- CREATE VIEW ordered_sales AS
-- SELECT * FROM Sales ORDER BY SaleDate DESC; --  Invalid in view
-- GO
