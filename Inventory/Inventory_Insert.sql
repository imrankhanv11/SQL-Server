
-- ROLE AND PERMISSIONS
INSERT INTO Roles (role_name) VALUES 
('Admin'), ('Staff');

INSERT INTO Permissions (permission_name) VALUES 
('Add Product'), ('Edit Product'), ('Delete Product'), ('View Reports');

INSERT INTO RolePermissions (role_id, permission_id) VALUES 
(1, 1), (1, 2), (1, 3), (1, 4),
(2, 1), (2, 4);

-- USERS
INSERT INTO Users (username, password_hash, full_name, contact_info, role_id) VALUES 
('admin1', 'pass123', 'Admin One', 'admin1@example.com', 1),
('staff1', 'pass123', 'Staff One', 'staff1@example.com', 2),
('staff2', 'pass123', 'Staff Two', 'staff2@example.com', 2),
('staff3', 'pass123', 'Staff Three', 'staff3@example.com', 2),
('staff4', 'pass123', 'Staff Four', 'staff4@example.com', 2),
('staff5', 'pass123', 'Staff Five', 'staff5@example.com', 2);

-- CATEGORIES
INSERT INTO Categories (category_name) VALUES 
('Electronics'), ('Groceries'), ('Books'), ('Clothing'), ('Home Decor'), ('Fitness');

-- PRODUCTS
INSERT INTO Products (name, category_id, price) VALUES 
('Smartphone', 1, 20000),
('LED TV', 1, 35000),
('Rice Bag', 2, 1000),
('Notebook', 3, 100),
('T-Shirt', 4, 400),
('Yoga Mat', 6, 1200);

-- WAREHOUSES
INSERT INTO Warehouses (name, location) VALUES 
('Warehouse A', 'Chennai'),
('Warehouse B', 'Coimbatore'),
('Warehouse C', 'Madurai'),
('Warehouse D', 'Trichy'),
('Warehouse E', 'Salem'),
('Warehouse F', 'Tirunelveli');

-- PRODUCT-WAREHOUSE STOCK
INSERT INTO ProductWarehouseStock (product_id, warehouse_id, quantity_in_stock) VALUES 
(1, 1, 50),
(2, 2, 30),
(3, 3, 200),
(4, 4, 150),
(5, 5, 100),
(6, 6, 80);

-- SUPPLIERS
INSERT INTO Suppliers (name, contact_info) VALUES 
('ABC Supplies', 'abc@supplies.com'),
('Global Trade', 'global@trade.com'),
('Value Mart', 'valuemart@supply.com'),
('TechnoSource', 'tech@source.com'),
('Agro India', 'agro@india.com'),
('QuickServe Ltd.', 'quick@serve.com');

-- PURCHASES
INSERT INTO Purchases (product_id, supplier_id, quantity, purchase_date, total_cost, user_id) VALUES 
(1, 1, 10, GETDATE(), 200000, 1),
(2, 2, 5, GETDATE(), 175000, 1),
(3, 3, 50, GETDATE(), 50000, 2),
(4, 4, 100, GETDATE(), 10000, 3),
(5, 5, 60, GETDATE(), 24000, 4),
(6, 6, 20, GETDATE(), 24000, 5);

-- SUPPLIER PAYMENTS
INSERT INTO SupplierPayments (purchase_id, amount_paid, payment_date, payment_method, status) VALUES 
(1, 200000, GETDATE(), 'Bank Transfer', 'Paid'),
(2, 175000, GETDATE(), 'Cheque', 'Paid'),
(3, 50000, GETDATE(), 'Cash', 'Paid'),
(4, 10000, GETDATE(), 'Card', 'Paid'),
(5, 24000, GETDATE(), 'UPI', 'Paid'),
(6, 24000, GETDATE(), 'Bank Transfer', 'Paid');

-- INVENTORY LOG
INSERT INTO Inventory_Log (product_id, action, quantity, action_date, reference_id, user_id, warehouse_id) VALUES 
(1, 'ADD', 10, GETDATE(), 1, 1, 1),
(2, 'ADD', 5, GETDATE(), 2, 1, 2),
(3, 'ADD', 50, GETDATE(), 3, 2, 3),
(4, 'ADD', 100, GETDATE(), 4, 3, 4),
(5, 'ADD', 60, GETDATE(), 5, 4, 5),
(6, 'ADD', 20, GETDATE(), 6, 5, 6);

-- CUSTOMERS
INSERT INTO Customers (name, contact_info) VALUES 
('Imran Khan', 'imran@example.com'),
('Sita Devi', 'sita@example.com'),
('Ravi Kumar', 'ravi@example.com'),
('Asha Mehta', 'asha@example.com'),
('Faizal Rahman', 'faizal@example.com'),
('Geeta Arora', 'geeta@example.com');

-- SALES
INSERT INTO Sales (customer_id, sale_date, total_price, user_id) VALUES 
(1, GETDATE(), 20000, 1),
(2, GETDATE(), 35000, 2),
(3, GETDATE(), 1000, 3),
(4, GETDATE(), 500, 4),
(5, GETDATE(), 1200, 5),
(6, GETDATE(), 400, 6);

-- SALES DETAILS
INSERT INTO SalesDetails (sale_id, product_id, quantity, price) VALUES 
(1, 1, 1, 20000),
(2, 2, 1, 35000),
(3, 3, 1, 1000),
(4, 4, 5, 100),
(5, 6, 1, 1200),
(6, 5, 1, 400);

-- PRODUCT REVIEWS
INSERT INTO ProductReviews (customer_id, product_id, rating, comments, review_date) VALUES 
(1, 1, 5, 'Great smartphone!', GETDATE()),
(2, 2, 4, 'TV is decent quality.', GETDATE()),
(3, 3, 3, 'Average rice.', GETDATE()),
(4, 4, 4, 'Notebooks are fine.', GETDATE()),
(5, 6, 5, 'Loved the yoga mat!', GETDATE()),
(6, 5, 4, 'Good fabric.', GETDATE());
