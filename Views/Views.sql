--use database
USE Practice;

--CREATING  SIMPLE VIEW ( single table without aggregate functions and join )
CREATE VIEW simpleview AS
SELECT *
FROM Sales;

--USE VIEW
SELECT *
FROM simpleview;

SELECT COUNT(PaymentMethod)
FROM simpleview
GROUP BY PaymentMethod;

INSERT INTO simpleview (CustomerName)
VALUES ('HAPPY');

UPDATE simpleview
SET Product='Laptop'
WHERE SaleID=17;

--CREATE COMPLEX VIEW ( table compain joins or aggregate functions )
CREATE VIEW complexview AS
SELECT E.Name, D.DepartmentID, D.DepartmentName, E.Salary
FROM Employee E 
JOIN Department D ON D.DepartmentID = E.Department;

SELECT *
FROM complexview;


