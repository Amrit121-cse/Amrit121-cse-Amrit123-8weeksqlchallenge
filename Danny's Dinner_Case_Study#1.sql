------------------------------Case Study #1-Danny's Dinner--------------------------------------------
SELECT * FROM dannys_diner.sales;
SELECT * FROM dannys_diner.MENU;
SELECT * FROM dannys_diner.MEMBERS;

---1 What is the total amount each customer spent at the restaurant-----

With cte as
(
SELECT SUM(PRICE)AS TOTAL_AMOUNT,CUSTOMER_ID 
FROM dannys_diner.MENU M INNER JOIN dannys_diner.SALES S 
ON S.PRODUCT_ID=M.PRODUCT_ID
GROUP BY CUSTOMER_ID
) select * from cte;

----2 How many days has each customer visited the restaurant-----

SELECT COUNT(RN) AS VISITED,CUSTOMER_ID FROM
(
SELECT CUSTOMER_ID,ORDER_DATE,DENSE_RANK() OVER(PARTITION BY CUSTOMER_ID ORDER BY CUSTOMER_ID) AS RN
FROM dannys_diner.sales 
) A GROUP BY CUSTOMER_ID

----- 3 What was the first item from the menu purchased by each customer-----

With cte as
(
SELECT CUSTOMER_ID,PRODUCT_NAME
FROM
(
SELECT CUSTOMER_ID,PRODUCT_NAME,ORDER_DATE
,ROW_NUMBER() OVER(PARTITION BY PRODUCT_NAME  ORDER BY CUSTOMER_ID DESC) AS RN1
FROM
(
SELECT  CUSTOMER_ID,PRODUCT_NAME,DENSE_RANK() OVER( ORDER BY ORDER_DATE) AS RN,ORDER_DATE
 FROM dannys_diner.MENU M INNER JOIN dannys_diner.SALES S 
ON S.PRODUCT_ID=M.PRODUCT_ID
) A WHERE RN=1
) A WHERE RN1=1 
)select * from cte ORDER BY CUSTOMER_ID;

----4 What is the most purchased item on the menu and how many times was it purchased by all customers---

With cte as
(
SELECT TOP 1 COUNT(PRODUCT_NAME) AS MOST_PURCHED,PRODUCT_NAME
 FROM dannys_diner.MENU M INNER JOIN dannys_diner.SALES S 
ON S.PRODUCT_ID=M.PRODUCT_ID
GROUP BY PRODUCT_NAME
ORDER BY MOST_PURCHED DESC
) select * from cte

---5.Which item was the most popular for each customer-----

SELECT CUSTOMER_ID,MOST_POPULAR,PRODUCT_NAME
FROM
(
SELECT CUSTOMER_ID,MOST_POPULAR,PRODUCT_NAME, 
DENSE_RANK() OVER( PARTITION BY CUSTOMER_ID ORDER BY MOST_POPULAR DESC) AS RN
 FROM 
 (
SELECT CUSTOMER_ID,COUNT(S.PRODUCT_ID) AS MOST_POPULAR,PRODUCT_NAME, 
DENSE_RANK() OVER( PARTITION BY PRODUCT_NAME ORDER BY CUSTOMER_ID) AS RN 
FROM dannys_diner.MENU M INNER JOIN dannys_diner.SALES S 
ON S.PRODUCT_ID=M.PRODUCT_ID
GROUP BY PRODUCT_NAME,CUSTOMER_ID
) A  
) A WHERE RN=1
ORDER BY CUSTOMER_ID, MOST_POPULAR DESC

------6.Which item was purchased first by the customer after they became a member------------
with cte
as
(
SELECT min(ORDER_DATE) as orderdate,CUSTOMER_ID
FROM
(
SELECT COUNT(PRODUCT_NAME) as a,PRODUCT_NAME,ORDER_DATE,s.CUSTOMER_ID
FROM dannys_diner.MENU M INNER JOIN dannys_diner.SALES S 
ON S.PRODUCT_ID=M.PRODUCT_ID
INNER JOIN dannys_diner.MEMBERS M1 ON M1.CUSTOMER_ID=S.CUSTOMER_ID
WHERE ORDER_DATE>=JOIN_DATE
GROUP BY PRODUCT_NAME,ORDER_DATE,s.CUSTOMER_ID
)a group by CUSTOMER_ID
)select c.customer_id,m1.product_name from cte c INNER JOIN dannys_diner.MEMBERS m
on m.customer_id=c.customer_id 
INNER JOIN dannys_diner.sales s on s.order_date=c.orderdate AND c.customer_id=s.customer_id
INNER JOIN dannys_diner.MENU m1 on m1.product_id=s.product_id


------7.Which item was purchased just before the customer became a member--------

SELECT CUSTOMER_ID,PRODUCT_NAME
FROM
(
SELECT COUNT(PRODUCT_NAME) AS C,s.CUSTOMER_ID,PRODUCT_NAME
FROM dannys_diner.MENU M INNER JOIN dannys_diner.SALES S 
ON S.PRODUCT_ID=M.PRODUCT_ID
INNER JOIN dannys_diner.MEMBERS M1 ON M1.CUSTOMER_ID=S.CUSTOMER_ID
WHERE ORDER_DATE<=JOIN_DATE
GROUP BY s.CUSTOMER_ID,PRODUCT_NAME
) A ORDER BY CUSTOMER_ID

----8.What is the total items and amount spent for each member before they became a member------

SELECT s.CUSTOMER_ID,COUNT(PRODUCT_NAME) as Total_item,SUM(price) as Total_amount
FROM dannys_diner.MENU M INNER JOIN dannys_diner.SALES S 
ON S.PRODUCT_ID=M.PRODUCT_ID
INNER JOIN dannys_diner.MEMBERS M1 ON M1.CUSTOMER_ID=S.CUSTOMER_ID
WHERE ORDER_DATE<=JOIN_DATE
GROUP BY s.CUSTOMER_ID
----9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier 
--- how many points would each customer have---

SELECT SUM( CASE WHEN S.PRODUCT_ID=1 THEN PRICE*20
             ELSE PRICE*10 END) AS TOTAL,M.product_name
			 FROM dannys_diner.sales S
			 INNER JOIN dannys_diner.menu M ON 
			 M.product_id=S.product_id
			 GROUP BY M.product_name

----10.In the first week after a customer joins the program (including their join date) 
---they earn 2x points on all items, not just sushi 
---- how many points do customer A and B have at the end of January

SELECT SUM(A) AS TOTAL,CUSTOMER_ID
FROM
(
SELECT SUM(PRICE*20) AS A, 
PRODUCT_NAME,ORDER_DATE,s.CUSTOMER_ID 
FROM dannys_diner.MENU M INNER JOIN dannys_diner.SALES S 
ON S.PRODUCT_ID=M.PRODUCT_ID
INNER JOIN dannys_diner.MEMBERS M1 ON M1.CUSTOMER_ID=S.CUSTOMER_ID
WHERE ORDER_DATE>=JOIN_DATE
AND ORDER_DATE<='2021-1-31'
GROUP BY PRODUCT_NAME,ORDER_DATE,s.CUSTOMER_ID
) P GROUP BY CUSTOMER_ID

----------------Bonous Question--------------------------

SELECT CUSTOMER_ID,ORDER_DATE,PRODUCT_NAME,PRICE,MEMBER, 
CASE WHEN MEMBER='N' THEN NULL ELSE ROW_NUMBER() 
OVER(PARTITION BY CUSTOMER_ID,MEMBER ORDER BY PRODUCT_NAME) END AS RANK
FROM
(
SELECT  S.CUSTOMER_ID,ORDER_DATE,PRODUCT_NAME,PRICE,CASE WHEN ORDER_DATE>=JOIN_DATE THEN 'Y' ELSE 'N' END AS MEMBER
FROM dannys_diner.MENU M INNER JOIN dannys_diner.SALES S 
ON S.PRODUCT_ID=M.PRODUCT_ID
LEFT JOIN dannys_diner.MEMBERS M1 ON M1.CUSTOMER_ID=S.CUSTOMER_ID
) A















			





