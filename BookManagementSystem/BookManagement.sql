--Creting database
CREATE DATABASE BOOKMANAGEMENT;

--Use database
USE BOOKMANAGEMENT;

-------Section A---------------
--1. Create the following tables with appropriate data types and constraints 
--Creating Authors table
CREATE TABLE tbl_Author(
	AuthorID Int PRIMARY KEY,
	Name VARCHAR(20) NOT NULL,
	Country VARCHAR(20) NOT NULL
);

--Creating Book table
CREATE TABLE tbl_Book (
    BookID INT PRIMARY KEY,
    Title VARCHAR(20) NOT NULL,
    Genere VARCHAR(20) NOT NULL,
    Price DECIMAL(6,2) NOT NULL,
    AuthorID INT,
    FOREIGN KEY (AuthorID) REFERENCES tbl_Author(AuthorID)
);

--Creating Customer table
CREATE TABLE tbl_Customer(
	CustomerID INT PRIMARY KEY,
	FullName VARCHAR(30) NOT NULL,
	Email VARCHAR(20) NOT NULL
);

--Alter table for email data value change
ALTER TABLE tbl_Customer
ALTER COLUMN Email VARCHAR(30);

--Creating Sales table
CREATE TABLE tbl_Sales(
	SalesID INT PRIMARY KEY,
	BookID INT,
	CustomerID INT,
	SaleDate DATE,
	Quantity INT,
	FOREIGN KEY (BookID) REFERENCES tbl_Book(BookID),
	FOREIGN KEY (CustomerID) REFERENCES tbl_Customer(CustomerID)
);

--2. Modify the Books table to add a new column named PublishedYear.
--add new coloum in book table
ALTER TABLE tbl_Book
ADD PublishedYear CHAR(4) NOT NULL;


--3. Remove the PublishedYear column from the Books table.
--removeing publiedYear in book table
ALTER TABLE tbl_Book
DROP COLUMN PublishedYear;

--4. Drop the Customers table permanently.
--DROP the customer table
DROP TABLE tbl_Customer;

--5. Insert sample data (at least 3 records) into all remaining tables using proper SQL statements.
--insert values to author
INSERT INTO tbl_Author 
VALUES 
(1, 'Imran', 'India'),
(2, 'Ram', 'India'),
(3, 'Adil', 'Canada'),
(4, 'Gokul','USA');

INSERT INTO tbl_Author
VALUES
(5, 'Karthik', 'China'),
(6, 'Gokul B','Sri Lanka');

--insert values to book
INSERT INTO tbl_Book
VALUES
(1,'Java','Programming',40.80,2),
(2,'Oops','Programming',45.00,3),
(3,'Happy','Fiction',38.00,1),
(4,'Cricket for One','Fiction',100.00,1);

INSERT INTO tbl_Book
VALUES
(5, 'For test','Exam',20,4);

--insert values to customer
INSERT INTO tbl_Customer (CustomerID, FullName, Email)
VALUES
(1, 'Alice Johnson', 'alice.johnson@email.com'),
(2, 'Bob Smith', 'bob.smith@email.com'),
(3, 'Charlie Brown', 'charlie.brown@email.com'),
(4, 'Diana Green', 'diana.green@email.com');

--INSERT values in sales
INSERT INTO tbl_Sales (SalesID, BookID, CustomerID, SaleDate, Quantity)
VALUES
(1, 1, 2, '2024-05-01', 2),
(2, 2, 1, '2024-05-03', 1),
(3, 3, 3, '2024-05-05', 4),
(4, 1, 4, '2024-05-07', 1),
(5, 4, 2, '2024-05-10', 3);

INSERT INTO tbl_Sales 
VALUES
(6, 5, 2, '2024-05-10', 3);



--update book name
UPDATE tbl_Book
SET Title = 'Python'
WHERE BookID = 2;

UPDATE tbl_Book
SET Price = Price * 1.10
WHERE Title = 'Python';
----------------------------------------------------------------------
-------------Section B---------------------

--7. Retrieve the list of all books with their title, genre, and price.
SELECT Title, Genere, Price
FROM tbl_Book;

SELECT B.Title, A.Name AS AuthorName, B.Genere, B.Price
FROM tbl_Book B
JOIN tbl_Author A ON A.AuthorID = B.AuthorID;
-------------

--8. Display the names of authors who have written more than one book.
SELECT A.Name AS AuthorName
From tbl_Author A 
JOIN tbl_Book B ON A.AuthorID = B.AuthorID
GROUP BY B.AuthorID, A.Name
HAVING COUNT(B.AuthorID) > 1;

SELECT Name
FROM tbl_Author
WHERE AuthorID IN (
	SELECT AuthorID
	FROM tbl_Book
	GROUP BY AuthorID
	HAVING COUNT(AuthorID) > 1
);
------------------

--9. Show the total quantity sold for each book, ordered by highest quantity sold.
SELECT B.Title, SUM(S.Quantity)
FROM tbl_Book B
JOIN tbl_Sales S ON B.BookID=S.BookID
GROUP BY B.Title;

---------------------

--10. Fetch the details of books that have not been sold yet.
SELECT B.Title 
FROM tbl_Book B
LEFT JOIN tbl_Sales S ON B.BookID=S.BookID
where S.Quantity IS NULL;

SELECT Title
FROM tbl_Book
WHERE BookID NOT IN (
	SELECT BookID
	FROM tbl_Sales
);
--------------------

--11. Display the full name and email of customers who purchased books written by authors from 'USA'.
SELECT FullName, Email
FROM tbl_Customer
WHERE CustomerID IN (
	SELECT S.CustomerID
	FROM tbl_Sales S
	JOIN tbl_Book B ON B.BookID = S.BookID
	JOIN tbl_Author A ON B.AuthorID = A.AuthorID
	WHERE A.Country='USA'
);

SELECT DISTINCT C.FullName, C.Email
FROM tbl_Customer C
JOIN tbl_Sales S ON C.CustomerID = S.CustomerID
JOIN tbl_Book B ON S.BookID = B.BookID
JOIN tbl_Author A ON B.AuthorID = A.AuthorID
WHERE A.Country = 'USA';

-------------------------

--12. List the total sales amount (Price × Quantity) for each book, but only show books with total sales exceeding $100.
SELECT B.Title, SUM(B.Price * S.Quantity) AS TotalAmount
FROM tbl_Book B
LEFT JOIN tbl_Sales S ON B.BookID=S.BookID
GROUP BY B.Title
HAVING SUM(B.Price * S.Quantity) > 100;
--------------------------------------------------------------------------
-----------Section C---------------

--13. Find the average price of books for each genre.
SELECT Genere, AVG(Price) AS Price
FROM tbl_Book
GROUP BY Genere;
------------------------------------

--14. Show the genre-wise total number of books sold, but only for genres that have sold more than 3 books
SELECT B.Genere, SUM(S.Quantity)
FROM tbl_Book B
INNER JOIN tbl_Sales S ON B.BookID=S.BookID
GROUP BY B.Genere
HAVING SUM(S.Quantity) > 3;
--------------------------------------

--15. List all authors along with the number of books they have written. Include authors who haven’t written any books.
SELECT A.Name, COUNT(B.AuthorID) AS TotalBooks
FROM tbl_Author A
LEFT JOIN tbl_Book B ON A.AuthorID=B.AuthorID
GROUP BY A.Name;
-----------------------------------------

--16. Get the highest selling book's title and the total quantity sold.
SELECT TOP 1 B.Title, SUM(S.Quantity) As Total
FROM tbl_Book B
JOIN tbl_Sales S ON B.BookID=S.BookID
GROUP BY B.Title
ORDER BY Total DESC;
------------------------------------------
--17. Write a query to display the top 2 customers who have spent the most on books (Price × Quantity).
SELECT FullName
FROM tbl_Customer
WHERE CustomerID IN (
    SELECT TOP 2 S.CustomerID
    FROM tbl_Sales S
    JOIN tbl_Book B ON B.BookID = S.BookID
    GROUP BY S.CustomerID
    ORDER BY SUM(B.Price * S.Quantity) DESC
);

SELECT TOP 2 C.FullName, SUM(B.Price * S.Quantity) AS TotalSpent
FROM tbl_Customer C
JOIN tbl_Sales S ON C.CustomerID = S.CustomerID
JOIN tbl_Book B ON B.BookID = S.BookID
GROUP BY C.FullName
ORDER BY TotalSpent DESC;
------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------------
--to check the clusters in database--------
SELECT
    OBJECT_NAME(i.object_id) AS TableName,
    i.name AS IndexName,
    i.type_desc,
    s.user_seeks, s.user_scans, s.user_lookups, s.user_updates
FROM sys.indexes i
JOIN sys.dm_db_index_usage_stats s
    ON i.object_id = s.object_id AND i.index_id = s.index_id
WHERE OBJECTPROPERTY(i.object_id, 'IsUserTable') = 1
ORDER BY s.user_seeks DESC;
--------------------------------------------------------------------------------------------------------------------------------------