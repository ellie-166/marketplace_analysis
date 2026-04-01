-- highest orders based on cities/Average order by cities
select
ci.city_name,
sum(ca.total_spend_lifetime) / sum(ca.total_orders_lifetime) as avg_order_value
from customer_analytics_v2 ca
join customers c
on ca.customer_id = c.customer_id
join cities ci
on c.city_id = ci.city_id
group by ci.city_name
order by avg_order_value desc;
