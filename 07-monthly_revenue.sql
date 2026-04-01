-- using common table expression to derive monthly revenue and percent change for each month
WITH monthly_revenue as (
select 
date_format(o.order_date, '%Y-%m') as month,
sum(oi.total_amount) as revenue

from orders o
join order_items oi
on o.order_id = oi.order_id
group by date_format(o.order_date, '%Y-%m')
)
select
month,
revenue,
lag(revenue) over (order by month) -- previous revenue
as previous_month_revenue,
round(
(revenue - lag(revenue) over (order by month)) / lag (revenue) over (order by month)* 100,
2 ) as percentage_change

from monthly_revenue
order by month
;