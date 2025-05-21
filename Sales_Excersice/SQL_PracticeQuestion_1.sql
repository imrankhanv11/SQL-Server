--Use Database
USE Practice;

-----------------------------
--1. DDL-Create a Sales Table
-----------------------------
CREATE TABLE Sales(
	SaleID INT IDENTITY(1,1) PRIMARY KEY,
	SaleDate Date,
	CustomerName VARCHAR(30),
	Product VARCHAR(30),
	Quantity Int,
	PricePerUnit Decimal(8,2),
	PaymentMethod	VARCHAR(10) CHECK (PaymentMethod = 'Cash' or PaymentMethod = 'Card' or PaymentMethod = 'Online')
);
------------------------------------------------------------

------------------------------
--2. DML – INSERT (Insert Data)
------------------------------
INSERT INTO Sales (SaleDate, CustomerName, Product, Quantity, PricePerUnit, PaymentMethod)
VALUES
('2025-05-01', 'Alice', 'Headphones', 2, 150.00, 'Card'),
('2025-05-02', 'Bob', 'Smartphone', 1, 700.00, 'Online'),
('2025-05-03', 'Charlie', 'Charger', 3, 25.00, 'Cash'),
('2025-05-03', 'Alice', 'Laptop',	1, 1200.00, 'Card');
------------------------------------------------------------

-------------------------------
--3. DML – UPDATE (Update Data)
-------------------------------

--a) Update the payment method to 'Online' for all sales made by 'Alice'.
UPDATE Sales
SET PaymentMethod = CASE
	WHEN CustomerName = 'Alice' THEN 'Online'
	ELSE PaymentMethod
END;

--b) Update the price per unit of 'Charger' to 30.00.
UPDATE Sales
SET PricePerUnit = 30.00
WHERE Product = 'Charger';
------------------------------------------------------------

-------------------------------
--4. DML – DELETE (Delete Data)
-------------------------------

--a) Delete all sales records where the quantity is less than 2.
DELETE 
FROM Sales
WHERE Quantity < 2;

--b) Delete the record of any sale made by 'Bob'.
DELETE
FROM Sales
WHERE CustomerName = 'Bob';
------------------------------------------------------------

------------------------------
--5. DQL (Data Query Language)
------------------------------

--a) List all sales made using the 'Card' payment method.
SELECT *
FROM Sales
WHERE PaymentMethod = 'Card';

--b) Calculate the total revenue generated (Quantity × PricePerUnit).
SELECT SUM(Quantity * PricePerUnit) AS TotalRevenue
From Sales;

--c) Display the total quantity of each product sold.
SELECT Product, SUM(Quantity) AS TotalQuantitySold
FROM  Sales
GROUP BY Product;

--d) Show all sales where the quantity sold is more than 1.
SELECT *
FROM Sales
WHERE Quantity > 1;

--e) Find the customer who spent the most in a single transaction.
SELECT TOP 1 SaleID, CustomerName, (Quantity * PricePerUnit) AS AmountSpent
FROM Sales
ORDER BY AmountSpent DESC;

