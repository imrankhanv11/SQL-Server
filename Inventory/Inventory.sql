CREATE DATABASE INVENTORY

CREATE TABLE Categories (
    category_id INT PRIMARY KEY IDENTITY,
    category_name VARCHAR(100) NOT NULL
);

CREATE TABLE Suppliers (
    supplier_id INT PRIMARY KEY IDENTITY,
    name VARCHAR(100) NOT NULL,
    contact_info VARCHAR(255)
);

CREATE TABLE Products (
    product_id INT PRIMARY KEY IDENTITY,
    name VARCHAR(100) NOT NULL,
    category_id INT,
    price DECIMAL(10,2),
    quantity_in_stock INT DEFAULT 0,
    FOREIGN KEY (category_id) REFERENCES Categories(category_id)
);

CREATE TABLE Purchases (
    purchase_id INT PRIMARY KEY IDENTITY,
    product_id INT,
    supplier_id INT,
    quantity INT,
    purchase_date DATE,
    total_cost DECIMAL(10,2),
    FOREIGN KEY (product_id) REFERENCES Products(product_id),
    FOREIGN KEY (supplier_id) REFERENCES Suppliers(supplier_id)
);


CREATE TABLE Inventory_Log (
    log_id INT PRIMARY KEY IDENTITY,
    product_id INT,
    action VARCHAR(10), -- 'IN' or 'OUT'
    quantity INT,
    action_date DATE,
    reference_id INT, -- Can refer to sale or purchase ID
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);


CREATE TABLE Customers (
    customer_id INT PRIMARY KEY IDENTITY,
    name VARCHAR(100),
    contact_info VARCHAR(100)
);
ALTER TABLE Sales
ADD customer_id INT;

ALTER TABLE Sales
ADD CONSTRAINT FK_Sales_Customers
FOREIGN KEY (customer_id) REFERENCES Customers(customer_id);

CREATE TABLE Sales (
    sale_id INT PRIMARY KEY IDENTITY,
    customer_id INT,
    sale_date DATE,
    total_price DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);
CREATE TABLE SalesDetails (
    sale_detail_id INT PRIMARY KEY IDENTITY,
    sale_id INT,
    product_id INT,
    quantity INT,
    price DECIMAL(10,2),
    FOREIGN KEY (sale_id) REFERENCES Sales(sale_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

CREATE TABLE Users (
    user_id INT PRIMARY KEY IDENTITY,
    username VARCHAR(50),
    password_hash VARCHAR(255),
    role VARCHAR(20), -- 'admin', 'staff', etc.
    full_name VARCHAR(100),
    contact_info VARCHAR(100)
);

ALTER TABLE Sales
ADD user_id INT;
ALTER TABLE Sales
ADD CONSTRAINT FK_Sales_Users FOREIGN KEY (user_id) REFERENCES Users(user_id);

ALTER TABLE Purchases
ADD user_id INT;
ALTER TABLE Purchases
ADD CONSTRAINT FK_Purchases_Users FOREIGN KEY (user_id) REFERENCES Users(user_id);

ALTER TABLE Inventory_Log
ADD user_id INT;
ALTER TABLE Inventory_Log
ADD CONSTRAINT FK_InventoryLog_Users FOREIGN KEY (user_id) REFERENCES Users(user_id);


SELECT * FROM fn_dblog(NULL, NULL);

--Create the Warehouses table
CREATE TABLE Warehouses (
    warehouse_id INT PRIMARY KEY IDENTITY(1,1),
    name VARCHAR(100) NOT NULL,
    location TEXT
);

-- 2. Create the ProductWarehouseStock table to manage stock per warehouse
CREATE TABLE ProductWarehouseStock (
    pws_id INT PRIMARY KEY IDENTITY(1,1),
    product_id INT NOT NULL,
    warehouse_id INT NOT NULL,
    quantity_in_stock INT NOT NULL CHECK (quantity_in_stock >= 0),

    CONSTRAINT FK_PWS_Product FOREIGN KEY (product_id) REFERENCES Products(product_id),
    CONSTRAINT FK_PWS_Warehouse FOREIGN KEY (warehouse_id) REFERENCES Warehouses(warehouse_id)
);

--Update Inventory_Log to track warehouse location of each inventory change
ALTER TABLE Inventory_Log
ADD warehouse_id INT;

ALTER TABLE Inventory_Log
ADD CONSTRAINT FK_InventoryLog_Warehouse
FOREIGN KEY (warehouse_id) REFERENCES Warehouses(warehouse_id);

CREATE TABLE SupplierPayments (
    payment_id INT PRIMARY KEY IDENTITY(1,1),
    purchase_id INT FOREIGN KEY REFERENCES Purchases(purchase_id),
    amount_paid DECIMAL(10,2),
    payment_date DATE,
    payment_method VARCHAR(50),
    status VARCHAR(50) -- e.g., Paid, Partially Paid, Unpaid
);

CREATE TABLE ProductReviews (
    review_id INT PRIMARY KEY IDENTITY(1,1),
    customer_id INT FOREIGN KEY REFERENCES Customers(customer_id),
    product_id INT FOREIGN KEY REFERENCES Products(product_id),
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comments TEXT,
    review_date DATE
);


CREATE TABLE Roles (
    role_id INT PRIMARY KEY IDENTITY(1,1),
    role_name VARCHAR(50)
);

CREATE TABLE Permissions (
    permission_id INT PRIMARY KEY IDENTITY(1,1),
    permission_name VARCHAR(100)
);

CREATE TABLE RolePermissions (
    role_id INT FOREIGN KEY REFERENCES Roles(role_id),
    permission_id INT FOREIGN KEY REFERENCES Permissions(permission_id)
);

ALTER TABLE Users ADD role_id INT FOREIGN KEY REFERENCES Roles(role_id);

ALTER TABLE ProductReviews
ADD CONSTRAINT UQ_Review UNIQUE (product_id, customer_id);

ALTER TABLE Users DROP COLUMN role;
