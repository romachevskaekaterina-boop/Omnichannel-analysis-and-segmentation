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

### Task 1: Identify top-spending customers
**Business Question:** Which customers have contributed the most to the total revenue?

**SQL Query:**
```sql
WITH total_orders AS (
    SELECT user_id, o.order_id, p.product_price * oi.quantity AS Total_sum
    FROM order_items_sql_project oi
    JOIN orders_sql_project o ON oi.order_id = o.order_id
    JOIN products_sql_project p ON oi.product_id = p.product_id
),
paid_orders AS (
    SELECT *
    FROM total_orders t
    JOIN payments_sql_project pay ON t.order_id = pay.order_id
    WHERE pay.payment_status = 'Оплачено'
)
SELECT user_id, SUM(total_sum) AS total_spend
FROM paid_orders
GROUP BY user_id
ORDER BY total_spend DESC
LIMIT 10;
```

![Result for Task 1](screenshots/Задание%201.png)