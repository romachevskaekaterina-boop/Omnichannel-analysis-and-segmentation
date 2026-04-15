--Завдання 1. Аналіз витрат користувачів--
--Виведи для кожного з унікальних користувачів загальну суму витрат на онлайн покупки--
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


--Завдання 2. Об'єднання даних з різних каналів(id покупця, дата замовлення, id замовлення)--

select user_id,
       order_date,
       order_id
from orders_sql_project
union all 
select user_id , order_date, store_order_id 
from store_orders;


--Завдання 3. Пошук товарів в обох каналах--
--Вибери id тільки тих товарів, які купували як онлайн, так і офлайн--
select product_id
from order_items_sql_project
intersect 
select product_id
from store_order_items
order by product_id;

--Завдання 4. Визначення активних покупців--
--Вибери id тільки тих покупців, які купували як онлайн, так і офлайн, >2 одиниць кожного товару--
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

--Завдання 5. Розрахунок середнього чека онлайн--

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


--Завдання 6. Статистика покупок по каналах--

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

--Завдання 7. Визначення найпопулярніших товарів--

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
limit 3


--Завдання 8. Порівняння середніх чеків--

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


--Завдання 9. Пошук клієнтів з дорогими онлайн-покупками--
--Знайди клієнтів, які хоч раз купили онлайн товар дорожчий за середню ціну товарів, придбаних офлайн--
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


--Завдання 10. Аналіз великих сум замовлень по місяцях--
--Вибери замовлення, що перевищують середній чек, порахований серед усіх видів покупок та всіх покупців. Скільки покупців з відомим ідентифікатором (не порожній) зробили такі замовлення в кожен місяць року--
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