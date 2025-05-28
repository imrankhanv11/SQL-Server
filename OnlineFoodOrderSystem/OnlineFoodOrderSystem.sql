-- 1. MenuType
CREATE TABLE MenuType (
    MenuTypeID INT PRIMARY KEY,
    Type VARCHAR(50) NOT NULL
);

-- 2. Restaurant
CREATE TABLE Restaurant (
    RestaurantID INT PRIMARY KEY,
    RestaurantName VARCHAR(100) NOT NULL,
    Phone VARCHAR(15),
    Address TEXT
);

-- 3. Menu
CREATE TABLE Menu (
    MenuID INT PRIMARY KEY,
    RestaurantID INT,
    MenuName VARCHAR(100),
    MenuTypeID INT,
    CONSTRAINT FK_Menu_Restaurant_RestaurantID FOREIGN KEY (RestaurantID) REFERENCES Restaurant(RestaurantID),
    CONSTRAINT FK_Menu_MenuType_MenuTypeID FOREIGN KEY (MenuTypeID) REFERENCES MenuType(MenuTypeID)
);

-- 4. MenuItem
CREATE TABLE MenuItem (
    MenuItemID INT PRIMARY KEY,
    MenuID INT,
    ItemName VARCHAR(100),
    Price DECIMAL(10,2),
    CONSTRAINT FK_MenuItem_Menu_MenuID FOREIGN KEY (MenuID) REFERENCES Menu(MenuID)
);

-- 5. Customer
CREATE TABLE Customer (
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(100) NOT NULL,
    Phone VARCHAR(15),
    Address TEXT
);

-- 6. [Order]
CREATE TABLE [Order] (
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    RestaurantID INT,
    OrderDate DATETIME DEFAULT GETDATE(),
    Status VARCHAR(20) DEFAULT 'Pending',
    CONSTRAINT FK_Order_Customer_CustomerID FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
    CONSTRAINT FK_Order_Restaurant_RestaurantID FOREIGN KEY (RestaurantID) REFERENCES Restaurant(RestaurantID)
);

-- 7. OrderItem
CREATE TABLE OrderItem (
    OrderID INT,
    MenuItemID INT,
    Quantity INT DEFAULT 1,
    Price DECIMAL(10,2) NOT NULL,
    CONSTRAINT PK_OrderItem PRIMARY KEY (OrderID, MenuItemID),
    CONSTRAINT FK_OrderItem_Order_OrderID FOREIGN KEY (OrderID) REFERENCES [Order](OrderID),
    CONSTRAINT FK_OrderItem_MenuItem_MenuItemID FOREIGN KEY (MenuItemID) REFERENCES MenuItem(MenuItemID)
);

-- 8. Delivery_Person
CREATE TABLE Delivery_Person (
    DPersonID INT PRIMARY KEY,
    Name VARCHAR(100),
    Phone VARCHAR(15)
);

-- 9. Delivery
CREATE TABLE Delivery (
    DeliveryID INT PRIMARY KEY,
    OrderID INT,
    Address TEXT,
    Status VARCHAR(50) DEFAULT 'Out for Delivery',
    DeliveryPersonID INT,
    DeliveryTime DATETIME,
    CONSTRAINT FK_Delivery_Order_OrderID FOREIGN KEY (OrderID) REFERENCES [Order](OrderID),
    CONSTRAINT FK_Delivery_DeliveryPerson_DeliveryPersonID FOREIGN KEY (DeliveryPersonID) REFERENCES Delivery_Person(DPersonID)
);

-- 10. Payment
CREATE TABLE Payment (
    PaymentID INT PRIMARY KEY,
    OrderID INT,
    Status VARCHAR(50) DEFAULT 'Unpaid',
    PaymentDate DATETIME DEFAULT GETDATE(),
    PaymentMethod VARCHAR(50),
    CONSTRAINT FK_Payment_Order_OrderID FOREIGN KEY (OrderID) REFERENCES [Order](OrderID)
);
