CREATE DATABASE ecsales;
USE ecsales;
CREATE TABLE products (
    product_id INT IDENTITY(1,1) PRIMARY KEY,
    product_name VARCHAR(200),
    category_id INT,
    cost_price DECIMAL(10,2),
    list_price DECIMAL(10,2),

    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);
CREATE TABLE orders (
    order_id INT IDENTITY(1,1) PRIMARY KEY,
    customer_id INT,
    order_date DATE DEFAULT GETDATE(),
    status VARCHAR(20),

    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
CREATE TABLE order_items (
    order_item_id INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10,2),

    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
CREATE TABLE payments (
    payment_id INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT,
    paid_amount DECIMAL(10,2),
    paid_at DATETIME DEFAULT GETDATE(),
    method VARCHAR(50),

    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);
INSERT INTO categories (category_name)
VALUES ('Apparel'), ('Electronics'), ('Home');
INSERT INTO products (product_name, category_id, cost_price, list_price)
VALUES 
('T-Shirt', 1, 5.00, 12.99),
('Earbuds', 2, 20.00, 49.99),
('Coffee Mug', 3, 2.50, 9.99);
INSERT INTO customers (email, first_name, last_name, country)
VALUES 
('riya@gmail.com','Riya','Sharma','India'),
('arjun@gmail.com','Arjun','Patel','India');
INSERT INTO orders (customer_id, status)
VALUES 
(1,'PAID'),
(2,'PAID');
INSERT INTO order_items (order_id, product_id, quantity, unit_price)
VALUES 
(1,1,2,12.99),
(1,3,1,9.99),
(2,2,1,49.99);
INSERT INTO payments (order_id, paid_amount, method)
VALUES 
(1,35.97,'CARD'),
(2,49.99,'UPI');
SELECT SUM(quantity * unit_price) AS total_revenue
FROM order_items;
SELECT COUNT(*) AS total_orders
FROM orders;
SELECT 
SUM(quantity * unit_price) / COUNT(DISTINCT order_id) AS AOV
FROM order_items;
SELECT p.product_name,
SUM(oi.quantity) AS total_units,
SUM(oi.quantity * oi.unit_price) AS revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_name
ORDER BY revenue DESC;
SELECT c.first_name,
SUM(oi.quantity * oi.unit_price) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.first_name;
SELECT o.order_date,
SUM(oi.quantity * oi.unit_price) AS daily_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_date;
CREATE TABLE channels (
    channel_id INT IDENTITY(1,1) PRIMARY KEY,
    channel_name VARCHAR(100) UNIQUE NOT NULL
);
CREATE TABLE channel_spend (
    spend_id INT IDENTITY(1,1) PRIMARY KEY,
    spend_date DATE,
    channel_id INT,
    spend DECIMAL(10,2),

    FOREIGN KEY (channel_id) REFERENCES channels(channel_id)
);
INSERT INTO channels (channel_name)
VALUES ('Google Ads'), ('Meta Ads'), ('Email');
INSERT INTO channel_spend (spend_date, channel_id, spend)
VALUES 
('2025-08-01',1,120),
('2025-08-01',2,80),
('2025-08-01',3,10);
SELECT c.channel_name,
SUM(oi.quantity * oi.unit_price) AS revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN channels c ON o.customer_id IS NOT NULL
GROUP BY c.channel_name;
SELECT 
c.channel_name,
SUM(oi.quantity * oi.unit_price) AS revenue,
SUM(cs.spend) AS ad_spend,
SUM(oi.quantity * oi.unit_price) / SUM(cs.spend) AS roas
FROM channel_spend cs
JOIN channels c ON cs.channel_id = c.channel_id
JOIN orders o ON 1=1
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.channel_name;
SELECT TOP 5
p.product_name,
SUM(oi.quantity * oi.unit_price) AS revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_name
ORDER BY revenue DESC;
SELECT c.customer_id,
c.first_name,
SUM(oi.quantity * oi.unit_price) AS lifetime_value
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.first_name;
CREATE VIEW v_sales AS
SELECT 
o.order_id,
o.order_date,
c.first_name,
p.product_name,
oi.quantity,
oi.unit_price,
(oi.quantity * oi.unit_price) AS revenue
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id;
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_items_order ON order_items(order_id);
CREATE INDEX idx_items_product ON order_items(product_id);
SELECT 
customer_id,
MIN(order_date) AS first_purchase,
COUNT(order_id) AS total_orders
FROM orders
GROUP BY customer_id;
