-- ===========================================
-- SHEIN E-Commerce Database
-- ===========================================

CREATE DATABASE SHEIN_DB;
GO
USE SHEIN_DB;
GO

-- ========== TABLES ==========
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY IDENTITY,
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    Email NVARCHAR(100) UNIQUE,
    Phone NVARCHAR(20),
    Country NVARCHAR(50)
);

CREATE TABLE Categories (
    CategoryID INT PRIMARY KEY IDENTITY,
    CategoryName NVARCHAR(100),
    Description NVARCHAR(255)
);

CREATE TABLE Products (
    ProductID INT PRIMARY KEY IDENTITY,
    ProductName NVARCHAR(100),
    Price DECIMAL(10,2),
    Stock INT,
    CategoryID INT FOREIGN KEY REFERENCES Categories(CategoryID)
);

CREATE TABLE Orders (
    OrderID INT PRIMARY KEY IDENTITY,
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID),
    OrderDate DATE,
    TotalAmount DECIMAL(10,2)
);

CREATE TABLE OrderDetails (
    OrderDetailID INT PRIMARY KEY IDENTITY,
    OrderID INT FOREIGN KEY REFERENCES Orders(OrderID),
    ProductID INT FOREIGN KEY REFERENCES Products(ProductID),
    Quantity INT,
    Subtotal AS (Quantity * (SELECT Price FROM Products WHERE Products.ProductID = OrderDetails.ProductID))
);

CREATE TABLE Payments (
    PaymentID INT PRIMARY KEY IDENTITY,
    OrderID INT FOREIGN KEY REFERENCES Orders(OrderID),
    PaymentDate DATE,
    Amount DECIMAL(10,2),
    Method NVARCHAR(30)
);

-- ========== SAMPLE DATA ==========
INSERT INTO Categories VALUES ('Women', 'Women’s clothing'), ('Men', 'Men’s clothing'), ('Accessories', 'Bags, jewelry, etc.');
INSERT INTO Customers VALUES ('Maria', 'Ivanova', 'maria@example.com', '+359888123456', 'Bulgaria');
INSERT INTO Products VALUES ('Dress', 45.99, 100, 1), ('T-Shirt', 25.50, 150, 2), ('Necklace', 15.99, 200, 3);
INSERT INTO Orders VALUES (1, GETDATE(), 71.49);
INSERT INTO OrderDetails VALUES (1, 1, 1, 1), (1, 3, 1, 1);
INSERT INTO Payments VALUES (1, 1, GETDATE(), 71.49, 'Credit Card');

-- ========== STORED PROCEDURE ==========
GO
CREATE PROCEDURE GetCustomerOrders
    @CustomerID INT
AS
BEGIN
    SELECT o.OrderID, o.OrderDate, o.TotalAmount
    FROM Orders o
    WHERE o.CustomerID = @CustomerID;
END;
GO

-- ========== FUNCTION ==========
CREATE FUNCTION GetStockValue()
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @value DECIMAL(10,2);
    SELECT @value = SUM(Price * Stock) FROM Products;
    RETURN @value;
END;
GO

-- ========== TRIGGER ==========
CREATE TRIGGER trg_UpdateStock
ON OrderDetails
AFTER INSERT
AS
BEGIN
    UPDATE Products
    SET Stock = Stock - i.Quantity
    FROM Products p
    INNER JOIN inserted i ON p.ProductID = i.ProductID;
END;
GO
