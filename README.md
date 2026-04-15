# Omnichannel-analysis-and-segmentation
Analyzing online and offline sales data with SQL to identify high-value customers and improve omnichannel business strategy.

📌 Project Overview
This project focuses on analyzing sales data for a retail company that operates both an online store and a physical branch network. The goal is to provide actionable insights into customer behavior and sales performance across different channels.

🎯 Business Goals
As a Data Analyst, I addressed the following key business questions:

1.Customer Value: Identify top-spending customers.
2.Product Performance: Determine popular products sold across both online and offline channels.
3.Channel Comparison: Analyze differences in Average Order Value (AOV) between channels.
4.Seasonality: Identify purchase distribution and trends by month.

🛠 Skills & Tools Demonstrated
1.Advanced SQL (DQL): Writing complex queries to extract business insights.
2.Data Transformation: Converting data types and formatting dates for monthly analysis.
3.Aggregations & Grouping: Calculating totals, averages, and counts using GROUP BY and HAVING.
4.Table Joins: Merging data from multiple sources to enable omnichannel analysis.
5.Handling Missing Data: Processing null values for accurate reporting.

📈 Impact for the Business
The results of this analysis prepare the company for:

1.Strategic Planning: Optimizing inventory based on channel-specific demand.
2.Customer Segmentation: Personalizing marketing offers for the most active buyers.
3.Omnichannel Optimization: Understanding how digital and physical sales complement each other.

---

## 🔍 Detailed Analysis & Results
<details>
  <summary><b>Task 1. Analysis of search results</b></summary>

**SQL Query:**
```sql
with total_orders as(
select user_id,
       o.order_id,
       p.product_id,
       p.product_price,
       oi.quantity,
       p.product_price*oi.quantity as Total_sum
from order_items_sql_project oi
join orders_sql_project o 
    on oi.order_id=o.order_id 
join products_sql_project p 
    on oi.product_id=p.product_id
),
paid_orders as (
select *
from total_orders t 
join payments_sql_project pay
on t.order_id=pay.order_id 
where pay.payment_status = 'Оплачено'
)
select user_id, sum (total_sum) as total_spend
from paid_orders 
group by user_id
order by total_spend Desc;
```

![Result for Task 1](screenshots/Задание%201.png)
</details>

<details>
  <summary><b>Task 2. Combining data from different channels (purchase id, order date, order id)</b></summary>

**SQL Query:**
```sql
select user_id,
       order_date,
       order_id
from orders_sql_project
union all 
select user_id , order_date, store_order_id 
from store_orders;
```

![Result for Task 2](screenshots/Задание%202.png)
</details>

<details>
  <summary><b>Task 3. Search for products that were purchased both online and offline</b></summary>

**SQL Query:**
```sql
select product_id
from order_items_sql_project
intersect 
select product_id
from store_order_items
order by product_id;
```

![Result for Task 3](screenshots/Задание%203.png)
</details>

<details>
  <summary><b>Task 4. Number of active buyers who bought both online and offline, >2 units of leather goods</b></summary>

**SQL Query:**
```sql
with online as (
select o.order_id,
       o.user_id,
       oi.quantity
from orders_sql_project o 
join order_items_sql_project oi
  on o.order_id=oi.order_id
where oi.quantity in (2, 3)),
offline as (
select s.store_order_id,
       s.user_id,
       so.quantity
from store_orders s
join store_order_items so
  on s.store_order_id=so.store_order_id
  where so.quantity in (2, 3))
select * 
from online
union all
select *
from offline
order by user_id;
```

![Result for Task 4](screenshots/Задание%204.png)
</details>

<details>
  <summary><b>Task 5. Calculating the average check online</b></summary>

**SQL Query:**
```sql
SELECT AVG(order_sum) AS avg_online_check
FROM (
    SELECT o.order_id,
           SUM(oi.quantity * p.product_price) AS order_sum
    FROM orders_sql_project o
    JOIN order_items_sql_project oi ON o.order_id = oi.order_id
    JOIN products_sql_project p ON oi.product_id=p.product_id 
    join payments_sql_project pay on o.order_id=pay.order_id
    WHERE pay.payment_status  = 'Оплачено'
    GROUP BY o.order_id
) t;
```

![Result for Task 5](screenshots/Задание%205.png)
</details>

<details>
  <summary><b>Task 6. Shopping statistics by channel</b></summary>

**SQL Query:**
```sql
with all_orders as (
select o.order_id,
       oi.quantity,
       'online' AS channel
from orders_sql_project o
join order_items_sql_project oi on o.order_id=oi.order_id 
union all
select s.store_order_id, so.quantity, 'offline' AS channel
from store_orders s
join store_order_items so on s.store_order_id=so.store_order_id
)
select 
    channel, 
    sum (quantity) as total_quantity,
    count(distinct order_id) as total_orders
from all_orders 
group by channel 
order by channel;
```

![Result for Task 6](screenshots/Задание%206.png)
</details>

<details>
  <summary><b>Task 7. Determining the most popular products</b></summary>

**SQL Query:**
```sql
with all_orders as (
select o.order_id,
       o.user_id,
       oi.product_id,
       oi.quantity
from orders_sql_project o
join order_items_sql_project oi on o.order_id=oi.order_id 
where o.user_id is not null
union all
select s.store_order_id, s.user_id, so.product_id, so.quantity
from store_orders s 
join store_order_items so on s.store_order_id=so.store_order_id 
where s.user_id is not null
)
select 
count (distinct user_id) as users_count, product_id 
from all_orders 
group by product_id 
order by users_count  desc
limit 3;
```

![Result for Task 7](screenshots/Задание%207.png)
</details>

<details>
  <summary><b>Task 8. Comparison of average checks</b></summary>

**SQL Query:**
```sql
select 
channel,
AVG(total_cash) as avg_check
from 
   (select 
       'online' as channel,	
       oi.order_id,
       SUM(oi.quantity * p.product_price) as total_cash
    from order_items_sql_project oi
    join products_sql_project p on oi.product_id=p.product_id 
    group by oi.order_id

    union all

    select 
       'offline' as channel,	
       s.store_order_id,
       SUM(s.quantity * p.product_price) as total_cash
    from store_order_items s
    join products_sql_project p on s.product_id =p.product_id 
    group by s.store_order_id)
    as t
    group by channel 
    order by avg_check;
```

![Result for Task 8](screenshots/Задание%208.png)
</details>

<details>
  <summary><b>Task 9.Search for customers who have at least once purchased an online product that is more expensive than the average price of products purchased offline</b></summary>

**SQL Query:**
```sql
 with avg_price_offline as (select
 AVG(p.product_price) as avg_price
from store_order_items s
join products_sql_project p on s.product_id =p.product_id)                                       
 select distinct o.user_id 
 from orders_sql_project o 
 join order_items_sql_project oi on o.order_id=oi.order_id 
 join products_sql_project p on oi.product_id=p.product_id 
 where o.user_id is not null 
 and p.product_price > (select avg_price from avg_price_offline)
 order by o.user_id
```

![Result for Task 9](screenshots/Задание%209.png)
</details>

<details>
  <summary><b>Task 10.Analysis of large amounts of orders by month</b></summary>

**SQL Query:**
```sql
with all_orders as(
select 
s.user_id, 
s.order_date,
sum (soi.quantity * pr.product_price) as total
from store_orders s 
join store_payments spay on s.store_order_id=spay.store_order_id
join store_order_items soi on s.store_order_id=soi.store_order_id 
join products_sql_project pr on soi.product_id=pr.product_id 
where spay.payment_status = 'Оплачено' 
group by s.user_id, s.order_date
union all
select 
o.user_id,
o.order_date,
sum (oi.quantity * pr.product_price) as total
from orders_sql_project o
join payments_sql_project pay on o.order_id =pay.order_id 
join order_items_sql_project oi on o.order_id =oi.order_id 
join products_sql_project pr on oi.product_id=pr.product_id 
where pay.payment_status  = 'Оплачено'
group by o.user_id, o.order_date),
average as (
select avg(total) as avg_order 
from all_orders)

select count (distinct user_id) as count_user, EXTRACT(MONTH FROM order_date) AS month
from all_orders
where total > (select avg_order from average) and user_id is not null
group by month
order by month
```

![Result for Task 10](screenshots/Задание%210.png)
</details>