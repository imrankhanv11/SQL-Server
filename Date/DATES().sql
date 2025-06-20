CREATE DATABASE DatePractice;

-- Create Orders table
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    OrderDate DATE
);

-- Insert initial and additional sample data into Orders
INSERT INTO Orders (OrderID, OrderDate) VALUES
(1, '2025-06-01'),
(2, '2025-06-15'),
(3, '2025-06-30'),
(4, '2025-07-01'),
(5, '2025-05-25'),
(6, '2025-06-10'),
(7, '2025-06-20'),
(8, '2025-07-02'),
(9, '2025-07-15'),
(10, '2025-05-31');

-- Create Events table
CREATE TABLE Events (
    EventID INT PRIMARY KEY,
    EventName VARCHAR(50),
    EventDate DATE
);

-- Insert initial and additional sample data into Events
INSERT INTO Events (EventID, EventName, EventDate) VALUES
(1, 'Conference', '2025-06-05'),
(2, 'Workshop', '2025-06-30'),
(3, 'Meetup', '2025-07-04'),
(4, 'Seminar', '2025-05-29'),
(5, 'Hackathon', '2025-06-12'),
(6, 'Webinar', '2025-06-25'),
(7, 'Team Building', '2025-07-10'),
(8, 'Product Launch', '2025-05-30'),
(9, 'Networking Event', '2025-06-18');

SELECT *
FROM Orders
WHERE MONTH(OrderDate)= 6 and YEAR(OrderDate)= 2025;

SELECT *
FROM Orders
WHERE OrderDate >= '2025-06-01' AND OrderDate < '2025-07-01'

--Find all events happening after June 15, 2025.
SELECT *
FROM Events
WHERE EventDate >= '2025-06-15';


--Get the count of orders placed before July 2025.
SELECT COUNT(*)
FROM Orders
WHERE OrderDate < '2025-07-01';


--List all events and orders happening on the same day.
SELECT *
FROM Orders
JOIN Events ON Events.EventDate = Orders.OrderDate;


--Find the earliest event date and the latest order date.
SELECT 
    (SELECT MIN(EventDate) FROM Events) AS EarliestEventDate,
    (SELECT MAX(OrderDate) FROM Orders) AS LatestOrderDate;

-- Retrieve all orders placed on weekends (Saturday or Sunday)
SELECT * 
FROM Orders
WHERE DATENAME(WEEKDAY, OrderDate) IN ('Saturday', 'Sunday');

-- List events that occurred in May 2025
SELECT * 
FROM Events
WHERE EventDate >= '2025-05-01' AND EventDate < '2025-06-01';

-- Calculate the number of days between each order and the nearest upcoming event
SELECT o.OrderID, o.OrderDate, MIN(DATEDIFF(DAY, o.OrderDate, e.EventDate)) AS DaysToNextEvent
FROM Orders o
JOIN Events e ON e.EventDate >= o.OrderDate
GROUP BY o.OrderID, o.OrderDate;

-- Get all orders that happened in the same month and year as the 'Conference' event
SELECT * 
FROM Orders
WHERE YEAR(OrderDate) = (SELECT YEAR(EventDate) FROM Events WHERE EventName = 'Conference')
  AND MONTH(OrderDate) = (SELECT MONTH(EventDate) FROM Events WHERE EventName = 'Conference');

-- Find events that happened within 7 days before or after an order
SELECT DISTINCT e.EventID, e.EventName, e.EventDate
FROM Events e
JOIN Orders o ON e.EventDate BETWEEN DATEADD(DAY, -7, o.OrderDate) AND DATEADD(DAY, 7, o.OrderDate);

-- Retrieve all orders placed in June 2025
SELECT * 
FROM Orders
WHERE MONTH(OrderDate) = 6 AND YEAR(OrderDate) = 2025;

-- 1. Which day of the week had the highest number of orders?
SELECT TOP 1 DATENAME(WEEKDAY, OrderDate) AS Weekday, COUNT(*) AS OrderCount
FROM Orders
GROUP BY DATENAME(WEEKDAY, OrderDate)
ORDER BY OrderCount DESC;

-- 2. What is the average number of days between an order and the next upcoming event?
SELECT AVG(DaysToNextEvent) AS AvgDaysToNextEvent
FROM (
    SELECT o.OrderID, o.OrderDate, MIN(DATEDIFF(DAY, o.OrderDate, e.EventDate)) AS DaysToNextEvent
    FROM Orders o
    JOIN Events e ON e.EventDate >= o.OrderDate
    GROUP BY o.OrderID, o.OrderDate
) AS DiffTable;

-- 3. List orders for which there is no event on the same date
SELECT o.*
FROM Orders o
LEFT JOIN Events e ON o.OrderDate = e.EventDate
WHERE e.EventID IS NULL;

-- 4. Find the total number of events per month
SELECT YEAR(EventDate) AS EventYear, MONTH(EventDate) AS EventMonth, COUNT(*) AS EventCount
FROM Events
GROUP BY YEAR(EventDate), MONTH(EventDate)
ORDER BY EventYear, EventMonth;

-- 5. Show all orders that occurred within 3 days of an event (before or after)
SELECT DISTINCT o.*
FROM Orders o
JOIN Events e ON DATEDIFF(DAY, o.OrderDate, e.EventDate) <= 3;

-- 6. Identify months that had both events and orders
SELECT DISTINCT YEAR(o.OrderDate) AS Year, MONTH(o.OrderDate) AS Month
FROM Orders o
JOIN Events e 
    ON YEAR(o.OrderDate) = YEAR(e.EventDate) 
    AND MONTH(o.OrderDate) = MONTH(e.EventDate)
ORDER BY Year, Month;

---------------------------------------------------------------------------------------------------------------------
------------------------------------ADVANCE DATES CONCEPTS WITH WINDOW FUNCTION -------------------------------------
---------------------------------------------------------------------------------------------------------------------

--Calculate number of sales per product per month for the current year
SELECT 
	productid, dateformat(saledate, 'yyyymm') as months, count(*)
FROM SALE
WHERE YEAR(SALEDATE) =  YEAR(GETDATE())
GROUP BY PRODUCTID, MONTHS

--Find the total sales for each product for each year.
SELECT 
    PRODUCTID, 
    PRODUCTNAME, 
    YEAR(SALEDATE) AS SALE_YEAR, 
    COUNT(*) AS TOTALSALE
FROM 
    SALES
GROUP BY 
    PRODUCTID, 
    PRODUCTNAME, 
    YEAR(SALEDATE);

--Get the number of sales transactions made each day for the last 15 days.
SELECT 
    CAST(SALESDATE AS DATE) AS SALEDATE, 
    COUNT(*) AS SALESCOUNT
FROM 
    SALES
WHERE 
    SALESDATE >= DATEADD(DAY, -15, CAST(GETDATE() AS DATE))
GROUP BY 
    CAST(SALESDATE AS DATE)
ORDER BY 
    SALEDATE;

--List all products that had their first sale in the current year.
SELECT PRODUCTID, MIN(SALEDATE) AS FIRSTSALE
FROM SALES
WHERE YEAR(SALEDATE) = YEAR(GETDATE())
GROUP BY PROUDUCTID;

--Find the average sales amount per product for each month of the current year.
SELECT PROUDUCTID, MONTH(SALEDATE) AS MONTHVALUE, AVG(SALEAMOUNT)
FROM SALES
WHERE YEAR(SALEDATE) = YEAR(GETDATE())
GROUP BY PROUDUCTID, MONTH(SALEDATE)

--Show the date with the highest total sales overall.
WITH CTE AS (
	SELECT CAST(SALEDATE AS DATE), DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS RNK
	FROM SALES
	GROUP BY CAST(SALEDATE AS DATE)
)
SELECT SALEDATE
FROM CTE
WHERE RNK = 1;

SELECT TOP 1 CAST(SALEDATE AS DATE) AS DATEDWITHHIGH, COUNT(*) AS VALUESS
FROM SALES
GROUP BY CAST(SALEDATE AS DATE)
ORDER BY VALUESS DESC;

--Find the day of the week with the most sales on average (e.g., Monday, Tuesday, etc.).
SELECT TOP 1 DATENAME(WEEKDAY, SALEDATE) AS WEEKDAYNAME, AVG(SALEAMOUNT) AS HIGHT
FROM SALES
GROUP BY DATENAME(WEEKDAY, SALEDATE) 
ORDER BY HIGHT DESC;

--List all products that had a gap of more than 10 days between two consecutive sales.
WITH CTE AS (
    SELECT 
        PRODUCTID, 
        SALEDATE,
        LAG(SALEDATE) OVER (PARTITION BY PRODUCTID ORDER BY SALEDATE) AS PREV_SALEDATE
    FROM SALES
)
SELECT DISTINCT PRODUCTID
FROM CTE
WHERE PREV_SALEDATE IS NOT NULL 
  AND DATEDIFF(DAY, PREV_SALEDATE, SALEDATE) > 10;

--Calculate month-over-month sales growth per product.
WITH MonthlySales AS (
    SELECT 
        PRODUCTID,
        FORMAT(SALEDATE, 'yyyyMM') AS YEARMONTH,
        SUM(SALEAMOUNT) AS TOTAL_SALE
    FROM SALES
    GROUP BY PRODUCTID, FORMAT(SALEDATE, 'yyyyMM')
)
SELECT 
    PRODUCTID,
    YEARMONTH,
    TOTAL_SALE,
    TOTAL_SALE - LAG(TOTAL_SALE) OVER (PARTITION BY PRODUCTID ORDER BY YEARMONTH) AS MoM_GROWTH
FROM MonthlySales;

--Get the total sales for each quarter of the last 2 years.
SELECT 
    YEAR(SALEDATE) AS SALE_YEAR,
    DATEPART(QUARTER, SALEDATE) AS SALE_QUARTER,
    SUM(SALEAMOUNT) AS TOTAL_SALES
FROM SALES
WHERE SALEDATE >= DATEADD(YEAR, -2, CAST(GETDATE() AS DATE))
GROUP BY 
    YEAR(SALEDATE), 
    DATEPART(QUARTER, SALEDATE)
ORDER BY 
    SALE_YEAR, 
    SALE_QUARTER;

--with chatgpt
--for half year
SELECT 
    YEAR(SALEDATE) AS SALE_YEAR,
    CASE 
        WHEN MONTH(SALEDATE) BETWEEN 1 AND 6 THEN 'H1'
        WHEN MONTH(SALEDATE) BETWEEN 7 AND 12 THEN 'H2'
    END AS HALF_YEAR,
    SUM(SALEAMOUNT) AS TOTAL_SALES
FROM SALES
GROUP BY 
    YEAR(SALEDATE),
    CASE 
        WHEN MONTH(SALEDATE) BETWEEN 1 AND 6 THEN 'H1'
        WHEN MONTH(SALEDATE) BETWEEN 7 AND 12 THEN 'H2'
    END
ORDER BY 
    SALE_YEAR,
    HALF_YEAR;


--Find products with no sales in the current month.
SELECT PRODUCTNAME
FROM PRODUCT
WHERE PRODUCTID NOT IN (
    SELECT PRODUCTID
    FROM SALES
    WHERE 
        MONTH(SALEDATE) = MONTH(GETDATE()) AND 
        YEAR(SALEDATE) = YEAR(GETDATE())
);

--Show the count of distinct sale dates per product.
SELECT PRODUCTID, COUNT(DISTINCT CAST(SALEDATE AS DATE)) AS TOTALSALEDATE
FROM SALES
GROUP BY PROUDUCTID

--List the most recent sale amount per product along with the number of days since that sale.
SELECT 
    PRODUCTID, 
    MAX(CAST(SALEDATE AS DATE)) AS RECENT_SALE_DATE,
    DATEDIFF(DAY, MAX(CAST(SALEDATE AS DATE)), CAST(GETDATE() AS DATE)) AS DAYS_SINCE_LAST_SALE
FROM SALES
GROUP BY PRODUCTID;

--Find the number of sales made in each week of the current year.
SELECT 
    DATEPART(ISO_WEEK, SALEDATE) AS WEEKNUMBER,
    COUNT(*) AS SALECOUNT
FROM SALES
WHERE YEAR(SALEDATE) = YEAR(GETDATE())
GROUP BY DATEPART(ISO_WEEK, SALEDATE)
ORDER BY WEEKNUMBER;

--List all products that had sales every day for a given month (e.g., May 2025).
WITH CTE AS (
    SELECT 
        PRODUCTNAME,
        SALEDATE
    FROM SALES
    WHERE 
        YEAR(SALEDATE) = YEAR(@DATE) AND 
        MONTH(SALEDATE) = MONTH(@DATE)
    GROUP BY PRODUCTNAME, SALEDATE
)

SELECT PRODUCTNAME
FROM CTE
GROUP BY PRODUCTNAME
HAVING COUNT(DISTINCT SALEDATE) = DAY(EOMONTH(@DATE));