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
