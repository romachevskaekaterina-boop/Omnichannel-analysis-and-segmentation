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