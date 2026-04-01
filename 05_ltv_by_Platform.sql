-- platforms with highest ltv(first 6 months)

with first_order as (
select
customer_id,
min(order_date) as first_order_date
from orders
group by customer_id
),
six_month_orders as (
select
o.customer_id,
o.platform_id,
oi.total_amount
from orders o
join order_items oi
on o.order_id = oi.order_id
join first_order f
on o.customer_id = f.customer_id
where o.order_date <= date_add(f.first_order_date, interval 6 month) 
),
customer_ltv as (
select
customer_id,
platform_id,
sum(total_amount) as ltv_6m
from six_month_orders
group by customer_id, platform_id
)
select 
p.platform_name,
avg(cl.ltv_6m) as avg_ltv_6m
from customer_ltv cl
join platforms p
on cl.platform_id = p.platform_id
group by p.platform_name
order by avg_ltv_6m desc;