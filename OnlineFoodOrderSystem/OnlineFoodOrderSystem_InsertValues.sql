-- Insert into MenuType
INSERT INTO MenuType (MenuTypeID, Type) VALUES
(1, 'Breakfast'),
(2, 'Lunch'),
(3, 'Dinner'),
(4, 'Drinks');

-- Insert into Restaurant
INSERT INTO Restaurant (RestaurantID, RestaurantName, Phone, Address) VALUES
(1, 'Urban Bites', '1234567890', '123 Main St'),
(2, 'The Green Spoon', '9876543210', '45 Garden Ave'),
(3, 'Tandoori Nights', '1122334455', '88 Spice Lane');

-- Insert into Menu
INSERT INTO Menu (MenuID, RestaurantID, MenuName, MenuTypeID) VALUES
(1, 1, 'Morning Delights', 1),
(2, 1, 'Lunch Combo', 2),
(3, 2, 'Healthy Lunch', 2),
(4, 3, 'Dinner Specials', 3),
(5, 3, 'Spicy Drinks', 4);

-- Insert into MenuItem
INSERT INTO MenuItem (MenuItemID, MenuID, ItemName, Price) VALUES
(1, 1, 'Pancakes', 5.99),
(2, 1, 'Omelette', 4.49),
(3, 2, 'Burger & Fries', 8.99),
(4, 3, 'Quinoa Salad', 7.50),
(5, 4, 'Chicken Tikka Masala', 12.00),
(6, 5, 'Masala Chai', 2.50);

-- Insert into Customer
INSERT INTO Customer (CustomerID, CustomerName, Phone, Address) VALUES
(1, 'Alice Johnson', '3216549870', '12 Apple St'),
(2, 'Bob Smith', '6543217890', '34 Cherry Blvd'),
(3, 'Carla Gomez', '7890123456', '56 Lemon Rd');

-- Insert into Order
INSERT INTO "Order" (OrderID, CustomerID, RestaurantID, OrderDate, Status) VALUES
(1, 1, 1, '2024-06-01 08:00:00', 'Completed'),
(2, 2, 3, '2024-06-01 19:30:00', 'Completed'),
(3, 3, 2, '2024-06-02 12:15:00', 'Pending');

-- Insert into OrderItem
INSERT INTO OrderItem (OrderID, MenuItemID, Quantity, Price) VALUES
(1, 1, 2, 12),
(1, 2, 1, 4),
(2, 5, 1, 12),
(2, 6, 2, 5),
(3, 4, 1, 8);

-- Insert into Delivery_Person
INSERT INTO Delivery_Person (DPersonID, Name, Phone) VALUES
(1, 'David Rider', '4441237890'),
(2, 'Esha Patel', '5552348901'),
(3, 'Farhan Ali', '6663459012');

-- Insert into Delivery
INSERT INTO Delivery (DeliveryID, OrderID, Address, Status, DeliveryPersonID, DeliveryTime) VALUES
(1, 1, '12 Apple St', 'Delivered', 1, '2024-06-01 08:30:00'),
(2, 2, '34 Cherry Blvd', 'Delivered', 2, '2024-06-01 20:00:00'),
(3, 3, '56 Lemon Rd', 'Out for Delivery', 3, NULL);

-- Insert into Payment
INSERT INTO Payment (PaymentID, OrderID, Status, PaymentDate, PaymentMethod) VALUES
(1, 1, 'Paid', '2024-06-01 08:10:00', 'Credit Card'),
(2, 2, 'Paid', '2024-06-01 19:45:00', 'Cash'),
(3, 3, 'Unpaid', NULL, NULL);

------------------------------------------------------------------------------------------

-- 1. MenuType
SELECT * FROM MenuType;

-- 2. Restaurant
SELECT * FROM Restaurant;

-- 3. Menu
SELECT * FROM Menu;

-- 4. MenuItem
SELECT * FROM MenuItem;

-- 5. Customer
SELECT * FROM Customer;

-- 6. [Order]
SELECT * FROM [Order];

-- 7. OrderItem
SELECT * FROM OrderItem;

-- 8. Delivery_Person
SELECT * FROM Delivery_Person;

-- 9. Delivery
SELECT * FROM Delivery;

-- 10. Payment
SELECT * FROM Payment;