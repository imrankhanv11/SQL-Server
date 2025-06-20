--Write a query that returns the 7-day rolling average of sales for each product from a table Sales(ProductID, SaleDate, SalesAmount).
-- Step 1: Create the SALES table
CREATE TABLE SALES (
    ProductID INT,
    ProductName VARCHAR(100),
    SaleDate DATE,
    SaleAmount DECIMAL(10, 2)
);

INSERT INTO SALES (ProductID, ProductName, SaleDate, SaleAmount)
VALUES
-- Product A
(1, 'Product A', '2025-06-01', 100.00),
(1, 'Product A', '2025-06-02', 110.00),
(1, 'Product A', '2025-06-03', 120.00),
(1, 'Product A', '2025-06-04', 90.00),
(1, 'Product A', '2025-06-05', 95.00),
(1, 'Product A', '2025-06-06', 105.00),
(1, 'Product A', '2025-06-07', 115.00),
(1, 'Product A', '2025-06-08', 130.00),
(1, 'Product A', '2025-06-09', 125.00),
(1, 'Product A', '2025-06-10', 140.00),

-- Product B
(2, 'Product B', '2025-06-01', 200.00),
(2, 'Product B', '2025-06-03', 220.00),
(2, 'Product B', '2025-06-05', 210.00),
(2, 'Product B', '2025-06-07', 190.00),
(2, 'Product B', '2025-06-10', 230.00);

WITH CTE AS (
    SELECT 
        ProductID,
        ProductName, 
        SaleDate, 
        SUM(SaleAmount) AS AVGVALUE
    FROM SALES
    GROUP BY ProductID, ProductName, SaleDate
)
SELECT 
    ProductID, 
    ProductName,
    SaleDate, 
    AVGVALUE AS SalesAmount,
    AVG(AVGVALUE) OVER (
        PARTITION BY ProductID 
        ORDER BY SaleDate 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS Rolling7DayAvg
FROM CTE
ORDER BY ProductID, SaleDate;

-------------------------------------------------------------------------------------
SELECT 
    PRODUCTID, 
    PRODUCTNAME, 
    SALEDATE, 
    AVGVALUE AS SALEAMOUNT,
    AVG(AVGVALUE) OVER (
        PARTITION BY PRODUCTID 
        ORDER BY SALEDATE 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS VALUE
FROM (
    SELECT 
        PRODUCTID,
        PRODUCTNAME, 
        SALEDATE, 
        SUM(SALEAMOUNT) AS AVGVALUE
    FROM SALES
    GROUP BY PRODUCTID, PRODUCTNAME, SALEDATE
) AS SubSales 
ORDER BY PRODUCTID, SALEDATE;

-------------------------------------------------------------------------------------
WITH DailySales AS (
    SELECT 
        ProductID, 
        SaleDate, 
        SUM(SaleAmount) AS TotalSales
    FROM Sales
    GROUP BY ProductID, SaleDate
)
SELECT 
    s1.ProductID, 
    s1.SaleDate, 
    s1.TotalSales,
    (
        SELECT AVG(s2.TotalSales)
        FROM DailySales s2
        WHERE s2.ProductID = s1.ProductID
          AND s2.SaleDate BETWEEN DATEADD(DAY, -6, s1.SaleDate) AND s1.SaleDate
    ) AS Rolling7DayAvg
FROM DailySales s1
ORDER BY s1.ProductID, s1.SaleDate;
-------------------------------------------------------------------------------------
WITH DailySales AS (
    SELECT 
        ProductID, 
        SaleDate, 
        SUM(SalesAmount) AS TotalSales
    FROM Sales
    GROUP BY ProductID, SaleDate
)
SELECT 
    s1.ProductID, 
    s1.SaleDate, 
    s1.TotalSales,
    (
        SELECT SUM(s2.TotalSales) / 7
        FROM DailySales s2
        WHERE s2.ProductID = s1.ProductID
          AND s2.SaleDate BETWEEN DATEADD(DAY, -6, s1.SaleDate) AND s1.SaleDate
    ) AS Rolling7DayAvg
FROM DailySales s1
ORDER BY s1.ProductID, s1.SaleDate;
-------------------------------------------------------------------------------------
--Write a query that returns each product’s daily sales and the difference compared to the previous day using LAG().
SELECT 
	ProductID,
	SaleDate,
	SaleAmount,
	SaleAmount - lag(SaleAmount,1,0) over(partition by productId order by saledate) as saleprve
from sales;

--Write a query that returns each product’s first and last sale date using FIRST_VALUE() and LAST_VALUE().
SELECT 
	ProductID,
	SaleDate,
	SaleAmount,
	FIRST_VALUE(SaleAmount) over ( partition by productid order by saleDate ) as firstvalue,
	LAST_VALUE(SALEAMOUNT) over ( partition by productid order by saledate rows between unbounded preceding and unbounded following ) as last
from sales;

--For each product, calculate the average of the last 3 sales (including current row) ordered by SaleDate.
SELECT 
	ProductID,
	SaleAmount,
	saleDate,
	AVG(SaleAmount) OVER ( PARTITION BY ProductID order by saleDate rows between 2 preceding and current row) as vlaue
from sales;

--For each product, show the cumulative sum of sales over time.
SELECT
	productid,
	saleamount,
	saledate,
	SUM(SALEAMOUNT) over ( PARTITION BY PRODUCTID ORDER BY SALEDATE ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW ) AS CUMULATIVE
FROM SALES;

--For each product, show the cumulative sum of sales 7 days rolling
WITH CTE2 AS (
	SELECT 
		PRODUCTID, 
		PRODUCTNAME, 
		SALEDATE, 
		SUM(SALEAMOUNT) AS SALEVALUE
	FROM SALES
	GROUP BY PRODUCTID, PRODUCTNAME, SALEDATE
)
SELECT 
	PRODUCTID, 
	PRODUCTNAME, 
	SALEDATE, 
	SUM(SALEVALUE) OVER (
		PARTITION BY PRODUCTID 
		ORDER BY SALEDATE 
		ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
	) AS cumulative
FROM CTE2
ORDER BY PRODUCTID, SALEDATE;

--For each product, calculate the running average of sales up to each day.
WITH CTE3 AS (
    SELECT 
        ProductID, 
        ProductName, 
        SaleDate,
        SUM(SalesAmount) AS Amount
    FROM Sales
    GROUP BY ProductID, ProductName, SaleDate
)
SELECT 
    B.ProductID, 
    B.ProductName, 
    B.SaleDate,
    (
        SELECT AVG(A.Amount)
        FROM CTE3 A
        WHERE A.ProductID = B.ProductID
          AND A.SaleDate <= B.SaleDate
    ) AS RunningAvg
FROM CTE3 B
ORDER BY B.ProductID, B.SaleDate;

---
WITH CTE3 AS (
    SELECT 
        ProductID, 
        ProductName, 
        SaleDate,
        SUM(SalesAmount) AS Amount
    FROM Sales
    GROUP BY ProductID, ProductName, SaleDate
)
SELECT
    ProductID,
    ProductName,
    SaleDate,
    AVG(Amount) OVER (
        PARTITION BY ProductID 
        ORDER BY SaleDate 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS AvgValue
FROM CTE3;

-- In a sale table based on product max quanity sell and min quanity sell at time
SELECT 
	PRODUCTID, PROUDUCTNAME, 
	MAX(QUANITY) OVER ( PARTITION BY PRODUCTID ORDER BY PRODUCTID) AS MAXQUANITY,
	MIN(QUANITY) OVER ( PARTITION BY PRODUCTID ORDER BY PRODUCTID) AS MINQUANITY
FROM ORDERDETIALS

-- Average of last 3 sales per product excluding current row
SELECT
	PRODUCTID, PRODUCTNAME, SALEDATE, SALEAMOUNT,
	AVG(SALEAMOUNT) OVER ( PARTITION BY PROUDUCTID ORDER BY SALEDATE ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING) AS AVGAMOUNT
FROM SALES

--Cumulative monthly sales by product
WITH CTEMONTH AS (
    SELECT 
        PRODUCTID, 
        PRODUCTNAME, 
        FORMAT(SALEDATE, 'yyyyMM') AS MONTHLYSALE,
        SUM(SALEAMOUNT) AS TOTAL
    FROM SALES
    GROUP BY PRODUCTID, PRODUCTNAME, FORMAT(SALEDATE, 'yyyyMM')
)
SELECT
    PRODUCTID, 
    PRODUCTNAME, 
    MONTHLYSALE,
    SUM(TOTAL) OVER (
        PARTITION BY PRODUCTID 
        ORDER BY MONTHLYSALE 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS TOTALCUMULATIVE
FROM CTEMONTH
ORDER BY PRODUCTID, MONTHLYSALE;
---
WITH CTEMONTH AS (
    SELECT 
        PRODUCTID, 
        PRODUCTNAME, 
        FORMAT(SALEDATE, 'yyyyMM') AS MONTHLYSALE,
        SUM(SALEAMOUNT) AS TOTAL
    FROM SALES
    GROUP BY PRODUCTID, PRODUCTNAME, FORMAT(SALEDATE, 'yyyyMM')
)
SELECT 
    c1.PRODUCTID, 
    c1.PRODUCTNAME, 
    c1.MONTHLYSALE,
    (
        SELECT SUM(c2.TOTAL)
        FROM CTEMONTH c2
        WHERE c2.PRODUCTID = c1.PRODUCTID
          AND c2.MONTHLYSALE <= c1.MONTHLYSALE
    ) AS TOTALCUMULATIVE
FROM CTEMONTH c1
ORDER BY c1.PRODUCTID, c1.MONTHLYSALE;

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

--Calculate a 7-day moving average for total company sales (not per product).
WITH CTE AS (
	SELECT COMPANYNAME, SALEDATE, SUM(SALEAMOUNT) AS TOTALAMOUNT
	FROM SALES
	GROUP BY COMPANYNAME
)
SELECT COMPANYNAME, SALEDATE, TOTALAMOUNT,  ( SELECT AVG(TOTALAMOUNT) FROM CTE 1 WHERE 1.COMPANYNAME = 2.COMPANYNAME AND SALEDATE BETWEEN DATADD(DAY, -6, SALEDATE) AND SALEDATE ) AS AVGSALE7DAY
FROM CTE 2
--
WITH CTE AS (
	SELECT 
		COMPANYNAME, 
		SALEDATE, 
		SUM(SALEAMOUNT) AS TOTALAMOUNT
	FROM SALES
	GROUP BY COMPANYNAME, SALEDATE
)
SELECT 
	COMPANYNAME, SALEDATE, TOTALAMOUNT,
	AVG(TOTALAMOUNT) OVER (
		PARTITION BY COMPANYNAME 
		ORDER BY SALEDATE 
		ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
	) AS Rolling7DayAvg
FROM CTE
ORDER BY COMPANYNAME, SALEDATE;

--Identify the longest streak of consecutive days with sales for each product.
WITH DistinctSales AS (
    SELECT DISTINCT ProductName, SaleDate
    FROM SALES
),
NumberedSales AS (
    SELECT 
        ProductName,
        SaleDate,
        ROW_NUMBER() OVER (PARTITION BY ProductName ORDER BY SaleDate) AS RowNum
    FROM DistinctSales
),
StreakGroups AS (
    SELECT 
        ProductName,
        SaleDate,
        DATEADD(DAY, -RowNum, SaleDate) AS StreakGroup
    FROM NumberedSales
),
StreakCounts AS (
    SELECT 
        ProductName,
        StreakGroup,
        COUNT(*) AS StreakLength,
        MIN(SaleDate) AS StartDate,
        MAX(SaleDate) AS EndDate
    FROM StreakGroups
    GROUP BY ProductName, StreakGroup
),
MaxStreak AS (
    SELECT 
        ProductName,
        MAX(StreakLength) AS MaxStreakLength
    FROM StreakCounts
    GROUP BY ProductName
)
SELECT 
    s.ProductName,
    s.StreakLength,
    s.StartDate,
    s.EndDate
FROM StreakCounts s
JOIN MaxStreak m
  ON s.ProductName = m.ProductName AND s.StreakLength = m.MaxStreakLength
ORDER BY s.ProductName;
