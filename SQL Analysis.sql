select * from customer limit 20;

-------------------------------------------------Data Analysis using SQL---------------------------------------------------------

--REVENUE SPLIT BY GENDER
select gender , SUM(purchase_amount) as revenue
from customer
group by gender;

--CUSTOMERS WHICH USED DISCOUNT BUT STILL SPENT MORE THAN THE AVG PURCHASE AMOUNT
select customer_id , purchase_amount
from customer 
where discount_applied = 'Yes'
and purchase_amount > (select avg(purchase_amount) from customer);

--TOP 5 PRODUCTS BASED ON THEIR AVERAGE RATING
select item_purchased, ROUND(avg(review_rating), 2) as rating
from customer
group by item_purchased
order by rating desc
limit 5;

--AVERAGE PURCHASE AMOUNTS BETWEEN STANDARD AND EXPRESS SHIPPING
select shipping_type, round(avg(purchase_amount),2) as average_purchase
from customer
where shipping_type in ('Express','Standard')
group by shipping_type;

--COMPARE AVG SPEND AND TOTAL REVENUE BETWEEN SUBSCRIBERS AND NON-SUBSCRIBERS
select CASE WHEN subscription_status = 'Yes' THEN 'Subscriber' ELSE 'Non-Subscriber' END as "Subscription Status", 
		count(customer_id) as "Total Customer",
		sum(purchase_amount) as "Total Revenue", round(avg(purchase_amount),2) as "Average Spent"
from customer
group by subscription_status
order by "Total Revenue", "Average Spent" desc;

--PRODUCTS WITH HIGHEST NUMBER OF PURCHASES WITH DISCOUNT APPLIED 
select item_purchased as "Item", 
	   round(100 * sum(case when discount_applied = 'Yes' then 1 else 0 end)/count(*) ,2) as "Discount Rate"
from customer
group by item_purchased
order by "Discount Rate" desc
limit 5;

--SEGMENT CUSTOMERS INTO NEW, RETURNING, LOYAL BASED ON THEIR PREV. PURCHASES 
with customer_type as (
select customer_id, previous_purchases,
		CASE
			WHEN previous_purchases = 1 THEN 'New'
			WHEN previous_purchases > 1 and previous_purchases < 10 THEN 'Returning'
			ELSE 'Loyal'
		END as customer_segment
from customer
)
select customer_segment, count(*) 
from customer_type
group by customer_segment;

--TOP 3 MOST PURCHASED PRODUCTS WITHIN EACH CATEGORY
WITH category_products as (
SELECT 
    item_purchased, 
    category,
    COUNT(*) AS item_sold, 
    ROW_NUMBER() OVER (PARTITION BY category ORDER BY COUNT(*) DESC) AS sales_rank
FROM customer
GROUP BY item_purchased, category
)
SELECT * FROM category_products WHERE sales_rank < 4;

--ARE CUSTOMER WHO REPEAT BUYERS (~MORE THAN 5 PREV PURCHASES) ALSO SUBSCRIBE ?
select subscription_status, 
	   count(customer_id) as repeat_buyers
from customer
where previous_purchases > 5
group by subscription_status;

--REVENUE BY AGE GROUP
select age_group, sum(purchase_amount) as revenue
from customer
group by age_group
order by revenue desc;
	   
