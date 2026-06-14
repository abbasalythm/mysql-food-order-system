DROP DATABASE IF EXISTS food_order_system;
CREATE DATABASE food_order_system;
USE food_order_system;

--  Customer Table
CREATE TABLE Customer (
    Cust_Id      INT           NOT NULL AUTO_INCREMENT,
    Cust_Name    VARCHAR(100)  NOT NULL,
    Cust_Contact VARCHAR(15)   NOT NULL,
    Cust_Mail    VARCHAR(100)  NOT NULL UNIQUE,
    PRIMARY KEY (Cust_Id)
);

--  Restaurant Table
CREATE TABLE Restaurant (
    Rest_Id      INT           NOT NULL AUTO_INCREMENT,
    Rest_Name    VARCHAR(100)  NOT NULL,
    Rest_Contact VARCHAR(15)   NOT NULL,
    Rest_Address TEXT          NOT NULL,
    PRIMARY KEY (Rest_Id)
);

--  Delivery Person Table
CREATE TABLE Delivery_Person (
    DP_Id      INT           NOT NULL AUTO_INCREMENT,
    DP_Name    VARCHAR(100)  NOT NULL,
    DP_Contact VARCHAR(15)   NOT NULL,
    DP_Mail    VARCHAR(100)  NOT NULL UNIQUE,
    Rest_Id    INT           NOT NULL,
    PRIMARY KEY (DP_Id),
    FOREIGN KEY (Rest_Id) REFERENCES Restaurant(Rest_Id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

--  Orders Table
CREATE TABLE Orders (
    Order_Id     INT          NOT NULL AUTO_INCREMENT,
    Order_Date   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Order_Status ENUM('Placed','Preparing','Ready','Delivered') NOT NULL DEFAULT 'Placed',
    Cust_Id      INT          NOT NULL,
    DP_Id        INT,
    PRIMARY KEY (Order_Id),
    FOREIGN KEY (Cust_Id) REFERENCES Customer(Cust_Id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (DP_Id) REFERENCES Delivery_Person(DP_Id)
        ON DELETE SET NULL ON UPDATE CASCADE
);

--  Order_Item Table
CREATE TABLE Order_Item (
    Item_Id    INT             NOT NULL AUTO_INCREMENT,
    Item_Name  VARCHAR(100)    NOT NULL,
    Item_Price DECIMAL(8,2)    NOT NULL,
    Quantity   INT             NOT NULL DEFAULT 1,
    Order_Id   INT             NOT NULL,
    PRIMARY KEY (Item_Id),
    FOREIGN KEY (Order_Id) REFERENCES Orders(Order_Id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

--  Payment Table
-- Amount_Returned is automatically calculated
CREATE TABLE Payment (
    Pay_Id           INT             NOT NULL AUTO_INCREMENT,
    Total_Amount     DECIMAL(10,2)   NOT NULL,
    Amount_Paid      DECIMAL(10,2)   NOT NULL,
    Amount_Returned  DECIMAL(10,2)   GENERATED ALWAYS AS (Amount_Paid - Total_Amount) STORED,
    Pay_Status       ENUM('Pending','Completed') NOT NULL DEFAULT 'Pending',
    Order_Id         INT             NOT NULL UNIQUE,
    PRIMARY KEY (Pay_Id),
    FOREIGN KEY (Order_Id) REFERENCES Orders(Order_Id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

--  Insert Customers
INSERT INTO Customer (Cust_Name, Cust_Contact, Cust_Mail) VALUES
('Abbas Ali',       '03001234567', 'abbas.ali@gmail.com'),
('Muhammad Bilal',  '03119876543', 'bilal.m@gmail.com'),
('Sara Khan',       '03451122334', 'sara.khan@yahoo.com');

--  Insert Restaurants
INSERT INTO Restaurant (Rest_Name, Rest_Contact, Rest_Address) VALUES
('Savour Foods',   '0519876543', 'F-6 Markaz, Islamabad'),
('Nando\'s',       '0512345678', 'Centaurus Mall, Islamabad');

--  Insert Delivery Persons
INSERT INTO Delivery_Person (DP_Name, DP_Contact, DP_Mail, Rest_Id) VALUES
('Usman Raza',   '03331234567', 'usman.raza@mail.com',  1),
('Ali Hassan',   '03219988776', 'ali.hassan@mail.com',  1),
('Zain Ahmed',   '03461234567', 'zain.ahmed@mail.com',  2);

--  Insert Orders
INSERT INTO Orders (Order_Date, Order_Status, Cust_Id, DP_Id) VALUES
('2025-11-01 12:30:00', 'Delivered',  1, 1),
('2025-11-02 14:00:00', 'Preparing',  2, 2),
('2025-11-03 09:15:00', 'Placed',     3, NULL);

--  Insert Order Items
INSERT INTO Order_Item (Item_Name, Item_Price, Quantity, Order_Id) VALUES
('Chicken Karahi',  550.00, 1, 1),
('Naan',             30.00, 4, 1),
('Peri Peri Burger', 750.00, 2, 2),
('Fries',            250.00, 1, 2),
('Biryani',          400.00, 1, 3);

--  Insert Payments
INSERT INTO Payment (Total_Amount, Amount_Paid, Pay_Status, Order_Id) VALUES
(670.00,  700.00,  'Completed', 1),
(1750.00, 2000.00, 'Completed', 2),
(400.00,  400.00,  'Pending',   3);
--  View all customers
SELECT * FROM Customer;

-- 4.2 View all restaurants
SELECT * FROM Restaurant;

-- 4.3 View all delivery persons with their restaurant name
SELECT
    dp.DP_Id,
    dp.DP_Name,
    dp.DP_Contact,
    dp.DP_Mail,
    r.Rest_Name
FROM Delivery_Person dp
JOIN Restaurant r ON dp.Rest_Id = r.Rest_Id;

-- 4.4 View all orders with customer name and order status
SELECT
    o.Order_Id,
    c.Cust_Name,
    o.Order_Date,
    o.Order_Status
FROM Orders o
JOIN Customer c ON o.Cust_Id = c.Cust_Id;

-- 4.5 View all order items with their order id
SELECT
    oi.Item_Id,
    o.Order_Id,
    oi.Item_Name,
    oi.Item_Price,
    oi.Quantity,
    (oi.Item_Price * oi.Quantity) AS Subtotal
FROM Order_Item oi
JOIN Orders o ON oi.Order_Id = o.Order_Id;

-- 4.6 View payment details per order
SELECT
    p.Pay_Id,
    o.Order_Id,
    c.Cust_Name,
    p.Total_Amount,
    p.Amount_Paid,
    p.Amount_Returned,
    p.Pay_Status
FROM Payment p
JOIN Orders o ON p.Order_Id = o.Order_Id
JOIN Customer c ON o.Cust_Id = c.Cust_Id;

-- 4.7 Total revenue from completed payments
SELECT SUM(Total_Amount) AS Total_Revenue
FROM Payment
WHERE Pay_Status = 'Completed';

-- 4.8 Count total orders placed by each customer
SELECT
    c.Cust_Name,
    COUNT(o.Order_Id) AS Total_Orders
FROM Customer c
LEFT JOIN Orders o ON c.Cust_Id = o.Cust_Id
GROUP BY c.Cust_Id, c.Cust_Name;

-- 4.9 Find all delivered orders
SELECT
    o.Order_Id,
    c.Cust_Name,
    o.Order_Date,
    dp.DP_Name AS Delivered_By
FROM Orders o
JOIN Customer c         ON o.Cust_Id = c.Cust_Id
JOIN Delivery_Person dp ON o.DP_Id   = dp.DP_Id
WHERE o.Order_Status = 'Delivered';

-- 4.10 Full order summary (multi-table JOIN)
SELECT
    o.Order_Id,
    c.Cust_Name,
    c.Cust_Contact,
    o.Order_Date,
    o.Order_Status,
    oi.Item_Name,
    oi.Item_Price,
    oi.Quantity,
    (oi.Item_Price * oi.Quantity) AS Item_Total,
    p.Total_Amount,
    p.Pay_Status,
    dp.DP_Name AS Delivery_Person
FROM Orders o
JOIN Customer        c  ON o.Cust_Id  = c.Cust_Id
JOIN Order_Item      oi ON oi.Order_Id = o.Order_Id
JOIN Payment         p  ON p.Order_Id  = o.Order_Id
LEFT JOIN Delivery_Person dp ON o.DP_Id = dp.DP_Id
ORDER BY o.Order_Id, oi.Item_Id;

-- 4.11 Orders still pending delivery
SELECT
    o.Order_Id,
    c.Cust_Name,
    o.Order_Status
FROM Orders o
JOIN Customer c ON o.Cust_Id = c.Cust_Id
WHERE o.Order_Status IN ('Placed', 'Preparing', 'Ready');

-- 4.12 Most expensive item ordered
SELECT Item_Name, Item_Price
FROM Order_Item
ORDER BY Item_Price DESC
LIMIT 1;
