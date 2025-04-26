CREATE SCHEMA pizza_runner;

USE pizza_runner;

DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  runner_id INTEGER,
  registration_date DATE
);

INSERT INTO runners
  (runner_id, registration_date)
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');

DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  order_id INTEGER,
  customer_id INTEGER,
  pizza_id INTEGER,
  exclusions VARCHAR(4),
  extras VARCHAR(4),
  order_time TIMESTAMP
);

INSERT INTO customer_orders
  (order_id, customer_id, pizza_id, exclusions, extras, order_time)
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');

DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  order_id INTEGER,
  runner_id INTEGER,
  pickup_time VARCHAR(19),
  distance VARCHAR(7),
  duration VARCHAR(10),
  cancellation VARCHAR(23)
);

INSERT INTO runner_orders
  (order_id, runner_id, pickup_time, distance, duration, cancellation)
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');

DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  pizza_id INTEGER,
  pizza_name TEXT
);

INSERT INTO pizza_names
  (pizza_id, pizza_name)
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');

DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  pizza_id INTEGER,
  topping_id INTEGER
);

-- Normalized insert
INSERT INTO pizza_recipes (pizza_id, topping_id) VALUES
(1, 1), (1, 2), (1, 3), (1, 4), (1, 5), (1, 6), (1, 8), (1, 10),
(2, 4), (2, 6), (2, 7), (2, 9), (2, 11), (2, 12);

DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  topping_id INTEGER,
  topping_name TEXT
);

INSERT INTO pizza_toppings
  (topping_id, topping_name)
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');
  
  CREATE TABLE cust_orders
  SELECT
	order_id,
	customer_id, 
	pizza_id, 
	CASE
		WHEN exclusions = '' THEN NULL
		WHEN exclusions = 'null' THEN NULL
	ELSE exclusions
	END AS exclusions_cleaned,
	CASE
		WHEN extras = '' THEN NULL
		WHEN extras = 'NaN' THEN NULL
        WHEN extras = 'null' THEN NULL
	ELSE extras
	END AS extras_cleaned,
	order_time
  FROM customer_orders;
  
CREATE TABLE runner_orders_pre
SELECT
	order_id,
	runner_id,
	CASE
		WHEN pickup_time = 'null' THEN null
		ELSE pickup_time
	END AS pick_up_time,
	CASE
		WHEN distance = 'null' THEN null
		ELSE regexp_replace(distance, '[a-z]+', '')
	END AS distance_km,
	CASE
		WHEN duration = 'null' THEN null
		ELSE regexp_replace(duration, '[a-z]+', '')
		END AS duration_mins,
	CASE
		WHEN cancellation = '' THEN null
		WHEN cancellation = 'null' THEN null
		ELSE cancellation
		END AS cancellation               
FROM runner_orders;

CREATE TABLE runner_orders_post
	SELECT
		order_id,
		runner_id,
		pick_up_time,
		CAST(distance_km AS DECIMAL(3,1)) AS distance_km, 
		CAST(duration_mins AS SIGNED INT) AS duration_mins,
		cancellation
    FROM runner_orders_pre;
    
-- How many pizzas were ordered?
select count(*) pizzas_ordered from cust_orders;

-- How many unique customer orders were made?
select count(distinct order_id, customer_id) unique_orders from cust_orders;

-- How many successful orders were delivered by each runner?
select runner_id, count(*) successful_orders 
from runner_orders_post 
where cancellation is null 
group by runner_id;

-- How many of each type of pizza was delivered?
select pizza_id, count(*) delivered from cust_orders c
join runner_orders_post r on c.order_id = r.order_id
where cancellation is null
group by pizza_id