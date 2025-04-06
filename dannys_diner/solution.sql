-- Create the database and switch to it
CREATE DATABASE dannys_diner;
USE dannys_diner;

-- Create the sales table
CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INT
);

-- Insert data into the sales table
INSERT INTO sales (customer_id, order_date, product_id) VALUES
  ('A', '2021-01-01', 1),
  ('A', '2021-01-01', 2),
  ('A', '2021-01-07', 2),
  ('A', '2021-01-10', 3),
  ('A', '2021-01-11', 3),
  ('A', '2021-01-11', 3),
  ('B', '2021-01-01', 2),
  ('B', '2021-01-02', 2),
  ('B', '2021-01-04', 1),
  ('B', '2021-01-11', 1),
  ('B', '2021-01-16', 3),
  ('B', '2021-02-01', 3),
  ('C', '2021-01-01', 3),
  ('C', '2021-01-01', 3),
  ('C', '2021-01-07', 3);

-- Create the menu table
CREATE TABLE menu (
  product_id INT,
  product_name VARCHAR(10),
  price INT
);

-- Insert data into the menu table
INSERT INTO menu (product_id, product_name, price) VALUES
  (1, 'sushi', 10),
  (2, 'curry', 15),
  (3, 'ramen', 12);

-- Create the members table
CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

-- Insert data into the members table
INSERT INTO members (customer_id, join_date) VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');

-- What is the total amount each customer spent at the restaurant?
SELECT s.customer_id, SUM(m.price) total_amount 
FROM sales s JOIN menu m ON s.product_id = m.product_id 
GROUP BY s.customer_id;

-- How many days has each customer visited the restaurant?
SELECT customer_id, COUNT(DISTINCT(order_date)) visit_count FROM sales 
GROUP BY customer_id;

-- What was the first item from the menu purchased by each customer?


-- What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT m.product_name, ms.purchase_count times_purchased FROM 
menu m JOIN (SELECT product_id, COUNT(product_id) purchase_count FROM sales GROUP BY product_id ORDER BY purchase_count DESC LIMIT 1) ms 
ON m.product_id = ms.product_id