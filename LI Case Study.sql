CREATE DATABASE LI_DAY2;
USE LI_DAY2;
# Part 1 – Sales and Delivery:
SELECT * FROM ORDERS_DIMEN;
SELECT * FROM CUST_DIMEN;
SELECT * FROM MARKET_FACT;
SELECT * FROM PROD_DIMEN;
SELECT * FROM SHIPPING_DIMEN;
# Question 1: Find the top 3 customers who have the maximum number of orders
SELECT CUSTOMER_NAME,SUM(ORDER_QUANTITY) FROM CUST_DIMEN CD
JOIN MARKET_FACT MF ON CD.CUST_ID=MF.CUST_ID
GROUP BY CUSTOMER_NAME
ORDER BY SUM(ORDER_QUANTITY) DESC LIMIT 3;
# Question 2: Create a new column DaysTakenForDelivery that contains the date difference between Order_Date and Ship_Date.
CREATE TABLE ORDERS_SHIPPING;
(SELECT SHIP_DATE,ORDER_DATE,DATEDIFF(STR_TO_DATE(SHIP_DATE,'%d-%m-%Y'),STR_TO_DATE(ORDER_DATE,'%d-%m-%Y')) DIFF FROM SHIPPING_DIMEN SD
JOIN ORDERS_DIMEN OD ON SD.ORDER_ID=OD.ORDER_ID);
/*create table DaysTakenForDelivery;
(select ship_date,order_date,datediff(str_to_date(ship_date,'%d-%m-%Y'),
str_to_date(order_date,'%d-%m-%Y')) diff 
from orders_dimen o join
shipping_dimen s on o.order_id=s.order_id);*/
# Question 3: Find the customer whose order took the maximum time to get delivered.
select * from (select datediff(str_to_date(Ship_Date,'%d-%m-%Y'),str_to_date(Order_Date,'%d-%m-%Y')) DateDiff,Order_Date,
Ship_Date
 from market_fact mf 
inner join orders_dimen od on od.ord_id=mf.ord_id 
inner join shipping_dimen sd on sd.ship_id=mf.ship_id)t order by DateDiff desc limit 1;
# Question 4: Retrieve total sales made by each product from the data (use Windows function)
explain select distinct prod_id,sum(sales) over(partition by prod_id) TOTAL from market_fact ;
# Question 5: Retrieve the total profit made from each product from the data (use Windows function)

# Question 6: Count the total number of unique customers in January and how many of them came back any of the month over the entire year in 2011
/*select count(distinct m.cust_id) from orders_dimen o,market_fact m where m.Ord_id = o.Ord_id  and
month(STR_TO_DATE(o.Order_Date, "%d-%m-%Y")) in (2,3,4,5,6,7,8,9,10,11,12) and year(STR_TO_DATE(o.Order_Date, "%d-%m-%Y")) = 2011
and m.cust_id in
(select distinct m.cust_id from market_fact m join 
orders_dimen o on m.Ord_id = o.Ord_id 
where month(STR_TO_DATE(o.Order_Date, "%d-%m-%Y")) = 1 and year(STR_TO_DATE(o.Order_Date, "%d-%m-%Y")) = 2011);*/
create view temp_details as (
select  distinct c.cust_id as customer_id ,customer_name,order_date, month(str_to_date(order_date,'%d-%m-%Y')) as month_ordered,
year(str_to_date(order_date,'%d-%m-%Y')) as year_ordered from orders_dimen o join
shipping_dimen s on o.order_id=s.order_id
join market_fact f on f.ord_id=o.ord_id
join cust_dimen c on c.cust_id=f.cust_id);

select * from temp_details;
    

SELECT distinct year_ordered, month_ordered, 
count(customer_id) OVER (PARTITION BY month_ordered order by month_ordered) AS Total_Unique_Customers
FROM temp_details
WHERE year_ordered=2011 AND customer_id 
IN (SELECT DISTINCT customer_id
	FROM temp_details
	WHERE month_ordered=1
	AND year_ordered=2011);  
  
# Part 2 – Restaurant:
SELECT * FROM USERPROFILE;
SELECT * FROM CHEFMOZACCEPTS;
SELECT * FROM CHEFMOZCUISINE;
SELECT * FROM CHEFMOZHOURS4;
SELECT * FROM CHEFMOZPARKING;
SELECT * FROM GEOPLACES2;
SELECT * FROM RATING_FINAL;
SELECT * FROM USERCUISINE;
SELECT * FROM USERPAYMENT;
# Question 1: - We need to find out the total visits to all restaurants under all alcohol categories available.
SELECT COUNT(DISTINCT PLACEID) TOTAL_VISITS FROM GEOPLACES2 WHERE ALCOHOL<>'No_Alcohol_Served' AND ALCOHOL<>'NULL';
# Question 2: -Let's find out the average rating according to alcohol and price so that we can understand the rating in respective price categories as well.
SELECT ALCOHOL,AVG(RATING) AVG_RATING,PRICE FROM RATING_FINAL R
JOIN GEOPLACES2 G ON R.PLACEID=G.PLACEID
WHERE ALCOHOL<>'No_Alcohol_Served'
GROUP BY ALCOHOL,PRICE;
# Question 3:  Let’s write a query to quantify that what are the parking availability as well in different alcohol categories along with the total number of restaurants.
SELECT COUNT(NAME) NO_OF_RESTAURENTS,COUNT(PARKING_LOT) NO_OF_PARKING_LOT,ALCOHOL FROM CHEFMOZPARKING CP
JOIN GEOPLACES2 G
ON CP.PLACEID=G.PLACEID 
GROUP BY ALCOHOL;
# Question 4: -Also take out the percentage of different cuisines in each alcohol type.
SELECT COUNT(NAME) NO_OF_RESTAURENTS,COUNT(PARKING_LOT) NO_OF_PARKING_LOT,ALCOHOL,RCUISINE FROM CHEFMOZPARKING CP
JOIN GEOPLACES2 G
ON CP.PLACEID=G.PLACEID 
JOIN CHEFMOZCUISINE CMC ON CMC.PLACEID=G.PLACEID
GROUP BY ALCOHOL,RCUISINE;
# Question 5: - let’s take out the average rating of each state.
# Question 6: -' Tamaulipas' Is the lowest average rated state. Quantify the reason why it is the lowest rated by providing the summary based on State, alcohol, and Cuisine.
# Question 7:  - Find the average weight, food rating, and service rating of the customers who have visited KFC and tried Mexican or Italian types of cuisine, 
# and also their budget level is low.
# We encourage you to give it a try by not using joins.
