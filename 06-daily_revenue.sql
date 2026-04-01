-- Purpose: Identify daily revenue and orders
select
o.order_date,
count(distinct o.order_id)as
orders_per_day,
sum(oi.total_amount) as
revenue_per_day
from orders o
join order_items oi
on o.order_id = oi.order_id
group by o.order_date
order by o.order_date
;