create database tiny_shop_sale;
use tiny_shop_sale;

CREATE TABLE customers (
    customer_id integer PRIMARY KEY,
    first_name varchar(100),
    last_name varchar(100),
    email varchar(100)
);

CREATE TABLE products (
    product_id integer PRIMARY KEY,
    product_name varchar(100),
    price decimal
);

CREATE TABLE orders (
    order_id integer PRIMARY KEY,
    customer_id integer,
    order_date date
);

CREATE TABLE order_items (
    order_id integer,
    product_id integer,
    quantity integer
);

INSERT INTO customers (customer_id, first_name, last_name, email) VALUES
(1, 'John', 'Doe', 'johndoe@email.com'),
(2, 'Jane', 'Smith', 'janesmith@email.com'),
(3, 'Bob', 'Johnson', 'bobjohnson@email.com'),
(4, 'Alice', 'Brown', 'alicebrown@email.com'),
(5, 'Charlie', 'Davis', 'charliedavis@email.com'),
(6, 'Eva', 'Fisher', 'evafisher@email.com'),
(7, 'George', 'Harris', 'georgeharris@email.com'),
(8, 'Ivy', 'Jones', 'ivyjones@email.com'),
(9, 'Kevin', 'Miller', 'kevinmiller@email.com'),
(10, 'Lily', 'Nelson', 'lilynelson@email.com'),
(11, 'Oliver', 'Patterson', 'oliverpatterson@email.com'),
(12, 'Quinn', 'Roberts', 'quinnroberts@email.com'),
(13, 'Sophia', 'Thomas', 'sophiathomas@email.com');

INSERT INTO products (product_id, product_name, price) VALUES
(1, 'Product A', 10.00),
(2, 'Product B', 15.00),
(3, 'Product C', 20.00),
(4, 'Product D', 25.00),
(5, 'Product E', 30.00),
(6, 'Product F', 35.00),
(7, 'Product G', 40.00),
(8, 'Product H', 45.00),
(9, 'Product I', 50.00),
(10, 'Product J', 55.00),
(11, 'Product K', 60.00),
(12, 'Product L', 65.00),
(13, 'Product M', 70.00);

INSERT INTO orders (order_id, customer_id, order_date) VALUES
(1, 1, '2023-05-01'),
(2, 2, '2023-05-02'),
(3, 3, '2023-05-03'),
(4, 1, '2023-05-04'),
(5, 2, '2023-05-05'),
(6, 3, '2023-05-06'),
(7, 4, '2023-05-07'),
(8, 5, '2023-05-08'),
(9, 6, '2023-05-09'),
(10, 7, '2023-05-10'),
(11, 8, '2023-05-11'),
(12, 9, '2023-05-12'),
(13, 10, '2023-05-13'),
(14, 11, '2023-05-14'),
(15, 12, '2023-05-15'),
(16, 13, '2023-05-16');

INSERT INTO order_items (order_id, product_id, quantity) VALUES
(1, 1, 2),
(1, 2, 1),
(2, 2, 1),
(2, 3, 3),
(3, 1, 1),
(3, 3, 2),
(4, 2, 4),
(4, 3, 1),
(5, 1, 1),
(5, 3, 2),
(6, 2, 3),
(6, 1, 1),
(7, 4, 1),
(7, 5, 2),
(8, 6, 3),
(8, 7, 1),
(9, 8, 2),
(9, 9, 1),
(10, 10, 3),
(10, 11, 2),
(11, 12, 1),
(11, 13, 3),
(12, 4, 2),
(12, 5, 1),
(13, 6, 3),
(13, 7, 2),
(14, 8, 1),
(14, 9, 2),
(15, 10, 3),
(15, 11, 1),
(16, 12, 2),
(16, 13, 3);

SELECT * FROM customers;
SELECT * FROM products;
SELECT * FROM orders;
SELECT * FROM order_items;

-- 1) Which product has the highest price? Only return a single row.

SELECT product_name, price FROM products
ORDER BY price DESC
LIMIT 1;

-- 2) Which customer has made the most orders?

SELECT c.customer_id, CONCAT(first_name, ' ', last_name) AS full_name,
COUNT(o.order_id) AS no_of_orders
FROM customers c JOIN orders o ON c.customer_id = o.customer_id
GROUP BY 1 , 2
ORDER BY 3 DESC
LIMIT 1;

-- 3) What’s the total revenue per product?

SELECT p.product_id, p.product_name, SUM(p.price * oi.quantity) AS total_revenue
FROM products p JOIN order_items oi 
ON p.product_id = oi.product_id
GROUP BY p.product_id , p.product_name
ORDER BY p.product_id;

-- 4) Find the day with the highest revenue.

SELECT o.order_date, SUM(p.price * oi.quantity) AS total_revenue
FROM products p  JOIN order_items oi 
ON p.product_id = oi.product_id
JOIN orders o 
ON oi.order_id = o.order_id
GROUP BY o.order_date
ORDER BY total_revenue DESC
LIMIT 1;

-- 5) Find the first order (by date) for each customer.

WITH first_order_cte AS
(SELECT c.customer_id, CONCAT(first_name,' ', last_name) AS full_name, o.order_date,
DENSE_RANK() OVER(PARTITION BY c.customer_id ORDER BY o.order_date) AS rnk
FROM customers c JOIN orders o 
ON c.customer_id = o.customer_id
)
SELECT customer_id, full_name, order_date AS first_order_date
FROM first_order_cte
WHERE rnk = 1;

-- 6) Find the top 3 customers who have ordered the most distinct products
SELECT c.customer_id, c.first_name, c.last_name, COUNT(DISTINCT oi.product_id) AS unique_products
FROM customers c JOIN orders o 
ON c.customer_id = o.customer_id
JOIN order_items oi 
ON o.order_id = oi.order_id
GROUP BY c.customer_id , c.first_name , c.last_name
ORDER BY unique_products DESC
LIMIT 3;

-- 7) Which product has been bought the least in terms of quantity?

SELECT p.product_id, p.product_name, COUNT(oi.quantity) AS least_bought
FROM order_items oi JOIN products p 
ON oi.product_id = p.product_id
GROUP BY p.product_id , p.product_name
ORDER BY least_bought
LIMIT 1;

-- 8) What is the median order total?
with median_cte as (
select p.product_id, p.product_name, SUM(p.price * oi.quantity) as total
from products p join order_items oi 
on p.product_id = oi.product_id
group by p.product_id, p.product_name);

-- 9) For each order, determine if it was ‘Expensive’ (total over 300), ‘Affordable’ (total over 100), or ‘Cheap’.

WITH order_cte AS (
SELECT oi.order_id, SUM(p.price * oi.quantity) AS total
FROM products p 
JOIN order_items oi 
ON p.product_id = oi.product_id
GROUP BY oi.order_id
ORDER BY total) 
SELECT order_id, 
CASE WHEN total > 300 THEN 'Expensive'
     WHEN total BETWEEN 100 AND 300 THEN 'Affordable'
     ELSE 'Cheap'
     END AS order_type
From order_cte;
-- 10) Find customers who have ordered the product with the highest price.

WITH high_price_cte AS
                     (select c.customer_id, CONCAT(c.first_name,' ',c.last_name) as cust_name, 
                     p.product_name, p.price
					 FROM customers c JOIN orders o 
					 ON c.customer_id = o.customer_id 
					 JOIN order_items oi
					 ON o.order_id = oi.order_id 
					 JOIN products p
					 ON oi.product_id = p.product_id
					 GROUP BY c.customer_id,cust_name,p.product_name,p.price
					 ORDER BY p.price)
SELECT c.customer_id, cust_name FROM high_price_cte
WHERE price = (SELECT MAX(price) AS highest_price FROM high_price_cte);
