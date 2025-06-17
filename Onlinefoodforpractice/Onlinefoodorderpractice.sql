create database OnlineFoodOrder;
use OnlineFoodOrder;
 
-- 1. Addresses
CREATE TABLE Addresses (
  AddressID INT PRIMARY KEY,
  AddressType VARCHAR(50),
  StreetName VARCHAR(100),
  CityName VARCHAR(50),
  State VARCHAR(50),
  PinCode INT
);
 
INSERT INTO Addresses VALUES
(1, 'Home', 'MG Road', 'Bangalore', 'Karnataka', 560001),
(2, 'Office', 'Anna Salai', 'Chennai', 'Tamil Nadu', 600002),
(3, 'Home', 'Park Street', 'Kolkata', 'West Bengal', 700016);
 
 
-- 2. Customers
CREATE TABLE Customers (
  CustomerID INT PRIMARY KEY,
  CustomerName VARCHAR(100),
  CustomerEmail VARCHAR(100),
  CustomerPhone VARCHAR(15),
  AddressID INT FOREIGN KEY REFERENCES Addresses(AddressID)
);
 
INSERT INTO Customers VALUES
(101, 'Neha Sharma', 'neha@gmail.com', '9999999999', 1),
(102, 'Rahul Verma', 'rahul@gmail.com', '8888888888', 2),
(103, 'Divya Patel', 'divya@gmail.com', '7777777777', 3);
 
 
-- 3. Restaurants
CREATE TABLE Restaurants (
  RestaurantID INT PRIMARY KEY,
  RestaurantName VARCHAR(100),
  AddressID INT,
  Phone VARCHAR(15)
);
 
INSERT INTO Restaurants VALUES
(201, 'Tandoori Nights', 1, '0801234567'),
(202, 'Pizza Palace', 2, '0449876543'),
(203, 'South Spice', 3, '0334567890');
 
 
-- 4. Foods and FoodTypes
CREATE TABLE FoodType (
  FoodTypeID INT PRIMARY KEY,
  FoodTypeName VARCHAR(50)
);
 
CREATE TABLE Foods (
  FoodID INT PRIMARY KEY,
  FoodName VARCHAR(100),
  FoodTypeID INT FOREIGN KEY REFERENCES FoodType(FoodTypeID)
);
 
INSERT INTO FoodType VALUES
(1, 'Main Course'),
(2, 'Beverage'),
(3, 'Dessert');
 
INSERT INTO Foods VALUES
(301, 'Paneer Butter Masala', 1),
(302, 'Coke', 2),
(303, 'Gulab Jamun', 3),
(304, 'Veg Biryani', 1);
 
 
-- 5. MenuItems
CREATE TABLE MenuItems (
  MenuItemID INT PRIMARY KEY,
  FoodID INT,
  RestaurantID INT,
  Price DECIMAL(10,2),
  Description VARCHAR(255),
  FOREIGN KEY (FoodID) REFERENCES Foods(FoodID),
  FOREIGN KEY (RestaurantID) REFERENCES Restaurants(RestaurantID)
);
 
INSERT INTO MenuItems VALUES
(401, 301, 201, 180.00, 'Spicy North Indian dish'),
(402, 302, 201, 40.00, 'Chilled soft drink'),
(403, 303, 202, 70.00, 'Sweet dessert item'),
(404, 304, 203, 160.00, 'Aromatic biryani served with raita');
 
 
-- 6. Orders
CREATE TABLE Orders (
  OrderID INT PRIMARY KEY,
  CustomerID INT,
  OrderedDate DATE,
  TotalAmount DECIMAL(10,2),
  FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);
 
INSERT INTO Orders VALUES
(501, 101, '2025-06-15', 460.00),
(502, 102, '2025-06-16', 230.00);
 
 
-- 7. OrderItems
CREATE TABLE OrderItems (
  OrderItemsID INT PRIMARY KEY,
  OrderID INT,
  MenuItemID INT,
  Quantity INT,
  SubPrice DECIMAL(10,2),
  FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
  FOREIGN KEY (MenuItemID) REFERENCES MenuItems(MenuItemID)
);
 
INSERT INTO OrderItems VALUES
(601, 501, 401, 2, 360.00),
(602, 501, 402, 1, 40.00),
(603, 501, 403, 1, 70.00),
(604, 502, 404, 1, 160.00),
(605, 502, 402, 1, 40.00),
(606, 502, 403, 1, 30.00);
 
 
-- 8. PaymentType and PaymentStatus
CREATE TABLE PaymentType (
  PaymentTypeID INT PRIMARY KEY,
  PaymentName VARCHAR(50)
);
 
CREATE TABLE PaymentStatus (
  PaymentStatusID INT PRIMARY KEY,
  Status VARCHAR(50)
);
 
INSERT INTO PaymentType VALUES
(1, 'UPI'), (2, 'Card'), (3, 'Cash');
 
INSERT INTO PaymentStatus VALUES
(1, 'Success'), (2, 'Pending'), (3, 'Failed');
 
 
-- 9. Payment
CREATE TABLE Payment (
  PaymentID INT PRIMARY KEY,
  OrderID INT,
  PaymentTypeID INT,
  PaymentDate DATE,
  PaymentStatusID INT,
  FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
  FOREIGN KEY (PaymentTypeID) REFERENCES PaymentType(PaymentTypeID),
  FOREIGN KEY (PaymentStatusID) REFERENCES PaymentStatus(PaymentStatusID)
);
 
INSERT INTO Payment VALUES
(701, 501, 1, '2025-06-15', 1),
(702, 502, 2, '2025-06-16', 2);
 
-- 10. DeliveryAgent
CREATE TABLE DeliveryAgent (
  DeliveryAgentID INT PRIMARY KEY,
  DeliveryAgentName VARCHAR(100),
  AgentEmail VARCHAR(100),
  DeliveryAgentPhone VARCHAR(15),
  BikeNumber VARCHAR(20)
);
 
INSERT INTO DeliveryAgent VALUES
(801, 'Ravi Kumar', 'ravi@delivery.com', '9876543210', 'TN09AB1234'),
(802, 'Anita Das', 'anita@delivery.com', '8765432109', 'KA01XY9999');
 
 
-- 11. DeliveryStatus
CREATE TABLE DeliveryStatus (
  DeliveryStatusID INT PRIMARY KEY,
  Status VARCHAR(50)
);
 
INSERT INTO DeliveryStatus VALUES
(1, 'Pending'), (2, 'Dispatched'), (3, 'Delivered');
 
 
-- 12. Delivery
CREATE TABLE Delivery (
  DeliveryID INT PRIMARY KEY,
  DeliveryAgentID INT,
  OrderItemsID INT,
  DeliveryStatusID INT,
  DeliveryDate DATE,
  DeliveryTime TIME,
  FOREIGN KEY (DeliveryAgentID) REFERENCES DeliveryAgent(DeliveryAgentID),
  FOREIGN KEY (OrderItemsID) REFERENCES OrderItems(OrderItemsID),
  FOREIGN KEY (DeliveryStatusID) REFERENCES DeliveryStatus(DeliveryStatusID)
);
 
INSERT INTO Delivery VALUES
(901, 801, 601, 2, '2025-06-15', '19:00:00'),
(902, 801, 602, 3, '2025-06-15', '19:30:00'),
(903, 802, 603, 2, '2025-06-15', '19:45:00');