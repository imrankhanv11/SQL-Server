--Joins & Query Logic (1–5)
--1. Write a query to display: CustomerName, RestaurantName, FoodName, Quantity, SubPrice for all orders.
SELECT C.CustomerName, R.RestaurantName, F.FoodName, OI.Quantity, OI.SubPrice
FROM Customers C 
JOIN Orders O ON O.CustomerID = C.CustomerID
JOIN OrderItems OI ON OI.OrderID=O.OrderID
JOIN MenuItems MI ON MI.MenuItemID = OI.MenuItemID
JOIN Restaurants R ON R.RestaurantID = MI.RestaurantID
JOIN Foods F ON F.FoodID = MI.FoodID

--2. Display names of customers who have ordered "Paneer Butter Masala".
SELECT C.CustomerName
FROM Customers C 
JOIN Orders O ON O.CustomerID = C.CustomerID
JOIN OrderItems OI ON OI.OrderID=O.OrderID
JOIN MenuItems MI ON MI.MenuItemID = OI.MenuItemID
JOIN Foods F ON F.FoodID = MI.FoodID 
WHERE F.FoodName = 'PANEER BUTTER MASALA';

--Show delivery agents who handled more than 3 deliveries.
SELECT DA.DeliveryAgentName
FROM Delivery D
JOIN DeliveryAgent DA ON DA.DeliveryAgentID = D.DeliveryAgentID
GROUP BY DA.DeliveryAgentID, DA.DeliveryAgentName
HAVING COUNT(*) > 3;

--List orders where the total amount is greater than ₹500.
SELECT OrderID
FROM Orders 
WHERE TotalAmount > 500;

--5. Display orders placed from more than one restaurant.
SELECT O.OrderID
FROM Orders O
JOIN OrderItems OI ON O.OrderID = OI.OrderID
JOIN MenuItems MI ON MI.MenuItemID = OI.MenuItemID
GROUP BY O.OrderID
HAVING COUNT(DISTINCT MI.RestaurantID) > 1;

--Aggregation & Grouping (6–8)
--Show total number of items ordered per customer.
SELECT C.CustomerName, COUNT(*) AS TOTALITEMS
FROM Customers C
JOIN Orders O ON O.CustomerID = C.CustomerID
JOIN OrderItems OI ON OI.OrderID = O.OrderID
GROUP BY C.CustomerID,C.CustomerName;

--Show total revenue generated per restaurant.
SELECT R.RestaurantName, SUM(OI.SubPrice) AS REVENUE
FROM Restaurants R
LEFT JOIN MenuItems MI ON MI.RestaurantID = R.RestaurantID
JOIN OrderItems OI ON OI.MenuItemID = MI.MenuItemID
JOIN Orders O ON O.OrderID=OI.OrderID
GROUP BY R.RestaurantID, R.RestaurantName

--Show average delivery time per delivery agent.
SELECT DA.DeliveryAgentName, AVG(D.DeliveryTime) AS AvgDeliveryTime
FROM DeliveryAgent DA
JOIN Delivery D ON D.DeliveryAgentID = DA.DeliveryAgentID
GROUP BY DA.DeliveryAgentID, DA.DeliveryAgentName;

--Subqueries & Filtering (9–11)
--Find customers who have never placed an order.
SELECT C.CustomerName
FROM Customers C
WHERE C.CustomerID NOT IN ( SELECT CustomerID FROM Orders)

SELECT C.CUSTOMERNAME
FROM Customers C
LEFT JOIN Orders O ON O.CustomerID = C.CustomerID
WHERE O.OrderID IS NULL;

SELECT C.CustomerName
FROM Customers C
WHERE NOT EXISTS (
    SELECT 1 
    FROM Orders O 
    WHERE O.CustomerID = C.CustomerID
);

--Display the most ordered food item by quantity.
SELECT TOP 1 F.FoodName, SUM(OI.Quantity) AS TotalQuantity
FROM Foods F
JOIN MenuItems MI ON MI.FoodID = F.FoodID
JOIN OrderItems OI ON OI.MenuItemID = MI.MenuItemID
GROUP BY F.FoodID, F.FoodName
ORDER BY SUM(OI.Quantity) DESC;
-----
WITH FoodOrderTotals AS (
    SELECT F.FoodName, SUM(OI.Quantity) AS TotalQuantity,
           DENSE_RANK() OVER (ORDER BY SUM(OI.Quantity) DESC) AS Rnk
    FROM Foods F
    JOIN MenuItems MI ON MI.FoodID = F.FoodID
    JOIN OrderItems OI ON OI.MenuItemID = MI.MenuItemID
    GROUP BY F.FoodID, F.FoodName
)
SELECT FoodName, TotalQuantity
FROM FoodOrderTotals
WHERE Rnk = 1;

--List customers who made the highest total payment.
SELECT C.CustomerName
FROM Customers  C
WHERE CustomerID = ( SELECT C2.CustomerID FROM Orders C2 WHERE C2.TotalAmount = ( SELECT MAX(C3.TOTALAMOUNT) FROM Orders C3 ))
GO 

WITH RANKVALUE AS (
	SELECT C.CustomerName,
	DENSE_RANK() OVER( ORDER BY O.TOTALAMOUNT DESC) AS VALUESS
	FROM Customers C 
	JOIN Orders O ON O.CustomerID = C.CustomerID
)
SELECT R.CustomerName
FROM RANKVALUE R
WHERE VALUESS = 1;

--Views, Functions, Procedures (12–15)
--Create a view vw_OrderSummary to show: OrderID, CustomerName, TotalAmount, OrderDate, PaymentStatus
CREATE VIEW vw_ordersummary
AS
SELECT O.OrderID, C.CustomerName, O.TotalAmount, O.OrderedDate, PS.Status
FROM Customers C
JOIN Orders O ON O.CustomerID = C.CustomerID
JOIN Payment P ON P.OrderID = O.OrderID
JOIN PaymentStatus PS ON PS.PaymentStatusID = P.PaymentStatusID;

--Write a scalar function that takes @RestaurantID and returns total orders placed for that restaurant.
CREATE or alter FUNCTION fn_totalorderofREST (@restaurantID INT)
RETURNS INT
AS
BEGIN
    DECLARE @TOTAL INT;

    SELECT @TOTAL = COUNT(*)
    FROM Restaurants R
    JOIN MenuItems MI ON MI.RestaurantID = R.RestaurantID
    JOIN OrderItems OI ON OI.MenuItemID = MI.MenuItemID
    WHERE R.RestaurantID = @restaurantID;

    RETURN @TOTAL;
END;

--Create a stored procedure sp_AssignDeliveryAgent that takes @OrderItemsID, @AgentID and inserts a new delivery.
CREATE PROCEDURE sp_AssignDeliveryAgent
    @OrderItemsID INT,
    @AgentID INT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Delivery (OrderItemsID, DeliveryAgentID, DeliveryTime)
    VALUES (@OrderItemsID, @AgentID, GETDATE());

    PRINT 'Delivery assigned successfully.';
END;

--Triggers & Constraints (16–17)
--Write a trigger to prevent placing an order if TotalAmount is less than ₹100.
CREATE TRIGGER trg_preventorderlessthen100 
ON Orders
INSTEAD OF INSERT
AS
BEGIN
	IF EXISTS ( SELECT 1 FROM inserted WHERE TotalAmount < 100 )
	BEGIN
		RAISERROR('CANNOT INSERT THE ORDER',16,1);
		RETURN
	END

	INSERT INTO Orders ( CustomerID, OrderedDate, TotalAmount )
	SELECT CustomerID, OrderedDate, TotalAmount
	FROM inserted
END

------------------------------------------------------------------------------------------------------------------------------------
--Level 1: Easy
--List the names of customers who have placed at least one order.
SELECT C.CustomerName
FROM Customers C
WHERE C.CustomerID IN ( SELECT CustomerID FROM Orders )

SELECT C.CUSTOMERNAME
FROM Customers C
LEFT JOIN Orders O ON O.CustomerID = C.CustomerID
WHERE O.OrderID IS NOT NULL;

SELECT C.CustomerName
FROM Customers C
WHERE EXISTS (
    SELECT 1
    FROM Orders O
    WHERE O.CustomerID = C.CustomerID
);

--Find the names of foods that belong to the ‘Dessert’ food type.
SELECT F.FoodName
FROM FoodType FT 
JOIN Foods F ON F.FoodTypeID = FT.FoodTypeID
WHERE FT.FoodTypeName='Dessert';

SELECT F.FOODNAME
FROM Foods F
WHERE F.FoodTypeID IN ( SELECT FoodTypeID FROM FoodType WHERE FoodTypeName ='DESSERT');

SELECT F.FOODNAME
FROM FOODS F
WHERE EXISTS ( SELECT 1 FROM FoodType WHERE F.FoodTypeID = FoodTypeID AND FoodTypeName = 'DESSERT');

--Display orders where the total amount is greater than the average order amount.
SELECT O.ORDERID
FROM Orders O
WHERE O.TotalAmount > ( SELECT AVG(TOTALAMOUNT) FROM Orders )

--Find the names of restaurants that offer at least one menu item.
SELECT DISTINCT R.RestaurantName
FROM Restaurants R
JOIN MenuItems MI ON MI.RestaurantID = R.RestaurantID

SELECT R.RESTAURANTNAME
FROM Restaurants R
WHERE R.RestaurantID IN ( SELECT RestaurantID FROM MenuItems)

SELECT R.RESTAURANTNAME
FROM Restaurants R
WHERE EXISTS ( SELECT 1 FROM MenuItems WHERE RestaurantID = R.RestaurantID)
--Level 2: Medium
--Show the customers who have never made a payment.
SELECT C.CustomerName
FROM Customers C
LEFT JOIN Orders O ON O.CustomerID = C.CustomerID
LEFT JOIN Payment P ON P.OrderID = O.OrderID
WHERE P.PaymentID IS NULL;

SELECT C.CustomerName
FROM Customers C
WHERE NOT EXISTS (
    SELECT 1
    FROM Orders O
    JOIN Payment P ON P.OrderID = O.OrderID
    WHERE O.CustomerID = C.CustomerID
);

--List the orders that have been delivered by the delivery agent who handled the most deliveries.
-- First, find the ID of the top delivery agent
SELECT OI.OrderID, DA.DeliveryAgentName
FROM OrderItems OI
JOIN Delivery D ON D.OrderItemsID = OI.OrderItemsID
JOIN DeliveryAgent DA ON DA.DeliveryAgentID = D.DeliveryAgentID
WHERE DA.DeliveryAgentID = (
    SELECT TOP 1 D.DeliveryAgentID
    FROM Delivery D
    GROUP BY D.DeliveryAgentID
    ORDER BY COUNT(*) DESC
);---------------------------


--Find all customers who have placed orders from more than one restaurant.
SELECT C.CustomerName
FROM Customers C
JOIN Orders O ON O.CustomerID = C.CustomerID
JOIN OrderItems OI ON OI.OrderID = O.OrderID
JOIN MenuItems MI ON MI.MenuItemID = OI.MenuItemID
GROUP BY C.CustomerID, C.CustomerName
HAVING COUNT(DISTINCT MI.RestaurantID) > 1;

SELECT C.CustomerName
FROM Customers C
WHERE (
    SELECT COUNT(DISTINCT MI.RestaurantID)
    FROM Orders O
    JOIN OrderItems OI ON O.OrderID = OI.OrderID
    JOIN MenuItems MI ON MI.MenuItemID = OI.MenuItemID
    WHERE O.CustomerID = C.CustomerID
) > 1;

--Display the food item(s) with the highest price in each restaurant.
SELECT R.RestaurantName, F.FoodName, MI.Price
FROM MenuItems MI
JOIN Restaurants R ON MI.RestaurantID = R.RestaurantID
JOIN Foods F ON MI.FoodID = F.FoodID
WHERE MI.Price = (
    SELECT MAX(MI2.Price)
    FROM MenuItems MI2
    WHERE MI2.RestaurantID = MI.RestaurantID
);

WITH RankedMenu AS (
    SELECT 
        R.RestaurantName,
        F.FoodName,
        MI.Price,
        RANK() OVER (PARTITION BY MI.RestaurantID ORDER BY MI.Price DESC) AS price_rank
    FROM MenuItems MI
    JOIN Restaurants R ON MI.RestaurantID = R.RestaurantID
    JOIN Foods F ON MI.FoodID = F.FoodID
)
SELECT RestaurantName, FoodName, Price
FROM RankedMenu
WHERE price_rank = 1;