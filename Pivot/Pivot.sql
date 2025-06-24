-- Create the SalesData table
CREATE TABLE SalesData (
    SalesPerson NVARCHAR(50),
    Product NVARCHAR(50),
    Quantity INT
);
GO

--Insert more sample data into SalesData
INSERT INTO SalesData (SalesPerson, Product, Quantity) VALUES
('Alice', 'Apples', 10),
('Alice', 'Oranges', 5),
('Alice', 'Bananas', 7),
('Bob', 'Apples', 7),
('Bob', 'Oranges', 8),
('Bob', 'Bananas', 2),
('Charlie', 'Apples', 12),
('Charlie', 'Oranges', 3),
('Charlie', 'Bananas', 5),
('David', 'Apples', 6),
('David', 'Oranges', 9),
('David', 'Bananas', 4),
('Eve', 'Apples', 11),
('Eve', 'Oranges', 7),
('Eve', 'Bananas', 1);
GO

INSERT INTO SalesData ( SalesPerson, Product, Quantity)
VALUES 
('Fraclin','Apples', 30),
('Fraclin','Oranges', 29),
('Fraclin','Oranges', 10),
('Fraclin','Bananas', 25),
('Fraclin','Apples', 24);
Go;


--Perform a PIVOT operation: show quantities by salesperson and product
SELECT SalesPerson, [Apples], [Oranges], [Bananas]
FROM
(
    SELECT SalesPerson, Product, Quantity
    FROM SalesData
) src
PIVOT
(
    SUM(Quantity)
    FOR Product IN ([Apples], [Oranges], [Bananas])
) AS pvt;
GO

SELECT SalesPerson,
       SUM(CASE WHEN Product = 'Apples' THEN Quantity ELSE 0 END) AS Apples,
       SUM(CASE WHEN Product = 'Oranges' THEN Quantity ELSE 0 END) AS Oranges,
       SUM(CASE WHEN Product = 'Bananas' THEN Quantity ELSE 0 END) AS Bananas
INTO SalesSummary
FROM SalesData
GROUP BY SalesPerson;

SELECT SalesPerson, Product, Quantity
FROM SalesSummary
UNPIVOT
(
    Quantity FOR Product IN (Apples, Oranges, Bananas)
) AS UnpivotedData
WHERE Quantity > 0
ORDER BY SalesPerson, Product;
GO

--Perform an UNPIVOT operation to revert back to row format
WITH PivotedSales AS
(
    SELECT SalesPerson, [Apples], [Oranges], [Bananas]
    FROM
    (
        SELECT SalesPerson, Product, Quantity
        FROM SalesData
    ) src
    PIVOT
    (
        SUM(Quantity)
        FOR Product IN ([Apples], [Oranges], [Bananas])
    ) AS pvt
)
SELECT SalesPerson, Product, Quantity
FROM PivotedSales
UNPIVOT
(
    Quantity FOR Product IN ([Apples], [Oranges], [Bananas])
) AS unpvt
WHERE Quantity IS NOT NULL
ORDER BY SalesPerson, Product;
GO


