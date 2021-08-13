
SELECT * FROM  pizza_runner.runners;
SELECT * FROM pizza_runner.customer_orders ;
SELECT * FROM pizza_runner.runner_orders;
SELECT * FROM  pizza_runner.pizza_names;
SELECT * FROM pizza_runner.pizza_recipes;
SELECT * FROM pizza_runner.pizza_toppings;

-------------------A. Pizza Metrics---------------------------------
--1.How many pizzas were ordered----
SELECT COUNT(order_id) as Total from  pizza_runner.customer_orders ;

--2.How many unique customer orders were made------
 SELECT COUNT(order_id)AS UNIQUECUSTOMER,customer_id as Total from  pizza_runner.customer_orders 
group by customer_id having COUNT(customer_id)>=1 ;

--3.How many successful orders were delivered by each runner----
SELECT
	runners.runner_id,
    runners.registration_date,
	COUNT(DISTINCT runner_orders.order_id) AS orders
FROM pizza_runner.runners
INNER JOIN pizza_runner.runner_orders
	ON runners.runner_id = runner_orders.runner_id
WHERE runner_orders.duration IS NOT NULL AND runner_orders.cancellation IS NOT NULL
GROUP BY
	runners.runner_id,
    runners.registration_date;
 --4.How many of each type of pizza was delivered---
SELECT COUNT(pizza_names.PIZZA_ID) as Types, CAST(pizza_names.PIZZA_NAME AS nvarchar(100)) as PIZZA_NAME 
FROM
pizza_runner.pizza_names
INNER JOIN pizza_runner.customer_orders
ON pizza_names.PIZZA_ID=customer_orders.PIZZA_ID
GROUP BY CAST(pizza_names.PIZZA_NAME AS nvarchar(100))

--5.How many Vegetarian and Meatlovers were ordered by each customer---------
SELECT COUNT(pizza_names.PIZZA_ID) as Types, CAST(pizza_names.PIZZA_NAME AS nvarchar(100)) as PIZZA_NAME,customer_id 
FROM
pizza_runner.pizza_names
INNER JOIN pizza_runner.customer_orders
ON pizza_names.PIZZA_ID=customer_orders.PIZZA_ID
GROUP BY CAST(pizza_names.PIZZA_NAME AS nvarchar(100)),customer_id 

--6.What was the maximum number of pizzas delivered in a single order------------
select top 1*  from 
(
SELECT COUNT(order_id)AS maxorder,customer_id ,order_time from  pizza_runner.customer_orders 
group by customer_id,order_time having COUNT(customer_id)>=1 
)a order by maxorder desc;

--7.For each customer, how many delivered pizzas had at least 1 change and how many had no changes----


----8.How many pizzas were delivered that had both exclusions and extras---
SELECT COUNT(order_id) as totalpizzas 
FROM pizza_runner.customer_orders where exclusions !='null' and isnull(exclusions,'')<>''
and extras!='null' and isnull(extras, '')<>'';

--9.What was the total volume of pizzas ordered for each hour of the day--------------
select count(HOURLY) as totalpizza,HOURLY
from
(
SELECT Row_number()over(partition by order_time order by order_id) as rn, order_time ,order_id,customer_id
,DATEPART(HOUR, order_time) as HOURLY
FROM     pizza_runner.customer_orders
)a group by HOURLY

---10.What was the volume of orders for each day of the week-------

SELECT COUNT(CAST(order_time AS DATE)) as volume,CAST(order_time AS DATE) as dated
FROM   pizza_runner.customer_orders GROUP BY CAST(order_time AS DATE);

---------------B. Runner and Customer Experience------------------------------------

----1.How many runners signed up for each 1 week period (i.e. week starts 2021-01-01)------

SELECT count(DATEPART(week,registration_date)) as signedup_member,DATEPART(week,registration_date) week_days
 FROM  pizza_runner.runners
group by DATEPART(week,registration_date);

---2.What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order--

SELECT AVG(DATEPART(mi,R.pickup_time)-DATEPART(mi,ORDER_TIME)) time_in_min,R1.runner_id 
 FROM pizza_runner.customer_orders C
INNER JOIN  pizza_runner.runner_orders R ON C.order_id=R.order_id AND R.pickup_time != 'NULL'
INNER JOIN pizza_runner.runners R1 ON R1.runner_id=R.runner_id
GROUP BY R1.runner_id

---3.Is there any relationship between the number of pizzas and how long the order takes to prepare-----
-- This not specified in the this relationship model to order takes time based on the no of pizza.

--4.What was the average distance travelled for each customer------
SELECT AVG(CAST(TIME_AS  AS DECIMAL(9,2))) AS DISTANCE ,CUSTOMER_ID
  FROM
  (
 SELECT (REPLACE(DISTANCE, 'KM','')) AS TIME_AS,C.customer_id 
 FROM pizza_runner.runner_orders R INNER JOIN pizza_runner.customer_orders C
 ON C.order_id=R.order_id WHERE R.distance!='NULL'
 ) D 
 WHERE ISNULL(TIME_AS,'')<>''
 GROUP BY customer_id

 --5.-What was the difference between the longest and shortest delivery times for all orders----

SELECT (MAX(CAST(REPLACE(REPLACE(REPLACE(duration,'minutes',''),'MINS',''),'MINUTE','') AS INT)) -
 MIN(CAST(REPLACE(REPLACE(REPLACE(duration,'minutes',''),'MINS',''),'MINUTE','') AS INT))) AS DIFFERENCE
FROM pizza_runner.runner_orders WHERE duration != 'NULL';

--6.What was the average speed for each runner for each delivery and do you notice any trend for these values--

SELECT AVG(CAST((REPLACE(DISTANCE, 'KM','')) AS DECIMAL(9,2))
/CAST(REPLACE(REPLACE(REPLACE(duration,'minutes',''),'MINS',''),'MINUTE','') AS INT)) AS SPEED,C.runner_id,C.order_id
FROM pizza_runner.runner_orders C INNER JOIN pizza_runner.runners R ON C.runner_id=R.runner_id
WHERE distance!='NULL' AND ISNULL((REPLACE(DISTANCE, 'KM','')),'')<>''
AND duration != 'NULL' AND ISNULL(REPLACE(REPLACE(REPLACE(duration,'minutes',''),'MINS',''),'MINUTE',''),'')<>'' 
GROUP BY C.runner_id,C.order_id
;

----------------------------------------------------------------------------------------------------------------

