select review_rating from customer;

ALTER TABLE customer
ALTER COLUMN customer_id TYPE INTEGER USING customer_id::INTEGER,
ALTER COLUMN age TYPE INTEGER USING age::INTEGER,
ALTER COLUMN purchase_amount TYPE INTEGER USING purchase_amount::INTEGER,
ALTER COLUMN review_rating TYPE FLOAT USING review_rating::FLOAT,
ALTER COLUMN previous_purchases TYPE INTEGER USING previous_purchases::INTEGER,
ALTER COLUMN purchases_frequency_days TYPE INTEGER USING purchases_frequency_days::INTEGER;


-- Q1. What is the total revenue genrated by male vs female customer ?

select gender, sum(purchase_amount) as revenue
from customer
group by gender;

--Q2. Which customer used a discount but still  spent more  then the average purchase amount?

select customer_id , purchase_amount 
from customer 
where discount_applied ='Yes' and purchase_amount >= (select Avg (purchase_amount) from customer);

select review_rating from customer;

--Q3. Which are the top 5 Product with the highest avarage review rating?

select item_purchased as "Product" , round (avg(review_rating::numeric),2 )as "Average product Rating" 
from customer 
group by item_purchased
order by avg (review_rating) desc
limit 5 ;

--Q4. Comapre the Average purchase Amount between Standard and Express Shipping?

select shipping_type,
round(avg (purchase_amount),2)
from customer 
where shipping_type in ('Standard','Express')
group by shipping_type;

--Q5. Do subscribe customers spend more? compare average spend and total revenue bwtween suscribers and non- suscribers?

select subscription_status ,
count (customer_id) as total_customer,
round (avg(purchase_amount),2) as avg_spend,
round (sum(purchase_amount),2) as total_revenue
from customer
group by subscription_status
order by total_revenue, avg_spend desc;

--Q6. Which 5 product have the highest percentage of purchase with discounts applied?
select item_purchased, 
round(100*sum(case when discount_applied ='Yes' Then 1 else 0 end)/count(*),2) as discount_rate
from customer
group by item_purchased
order by discount_rate descof 
limit 5;

--Q7. Segment customer into new, 
--Returning and  Loyal based  on their Total number  of perivious purchase , 
--and show the count of each segment 

with customer_type as (
select customer_id ,previous_purchases,
case
   when previous_purchases = 1 then 'New'
   when previous_purchases between 2 and 10 then 'Returning'
   else 'Loyal'
   end  as customer_segment
from customer 
)
select customer_segment, count(*) as "Number of customer"
from customer_type 
group by customer_segment 

--Q8. What are the top 3 most purchased product within each category?

with item_count as (
select category ,
item_purchased , 
count (customer_id ) as total_orders,
row_number () over (partition by category order by 	count (customer_id )desc ) as item_rank 
from customer 
group by category,item_purchased 
)
select item_rank, category, item_purchased, total_orders
from item_count
where item_rank <3;

--Q9 Are customers who are repeat buyrs (more than 5 pervious purchase) also likely the subscribe?

select subscription_status,
count (customer_id) as repeat_buyres
from customer
where previous_purchases > 5
group by subscription_status 

--Q10 What is the revenue contribution of each age group?
select age_group, 
sum(purchase_amount) as total_revenue
from customer
group by age_group
order by total_revenue desc;




 WITH review_rating AS (
    SELECT AVG(review_rating) AS avg_val
    FROM customer
    WHERE review_rating = review_rating      -- removes NaN (because NaN != NaN in SQL)
)
SELECT 
    CASE 
        WHEN review_rating <> review_rating THEN (SELECT avg_val FROM review_rating)
        ELSE review_rating
    END AS Rating_Clean
FROM customer;
