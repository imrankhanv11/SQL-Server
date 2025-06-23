-- Create a table with a JSON column
CREATE TABLE Products (
    Id INT PRIMARY KEY,
    ProductDetails NVARCHAR(MAX) 
);

-- Insert JSON documents
INSERT INTO Products (Id, ProductDetails)
VALUES 
(1, N'{ "name": "Laptop", "price": 1200, "specs": { "cpu": "i7", "ram": "16GB" } }'),
(2, N'{ "name": "Phone", "price": 699, "features": ["5G", "OLED", "128GB"] }');

-- Query specific JSON fields
SELECT 
    JSON_VALUE(ProductDetails, '$.name') AS ProductName,
    JSON_VALUE(ProductDetails, '$.price') AS Price,
    JSON_VALUE(ProductDetails, '$.specs.cpu') AS CPU,
    JSON_VALUE(ProductDetails, '$.specs.ram') AS RAM,
	JSON_VALUE(ProductDetails, '$.features[0]') AS Features
FROM Products;

SELECT 
    Id,
    JSON_QUERY(ProductDetails, '$.specs') AS FullSpecs
FROM Products
WHERE JSON_VALUE(ProductDetails, '$.name') = 'Laptop';