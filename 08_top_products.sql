
-- product performance

select
p.product_name,
sum(oi.quantity) as total_quantity_sold,
sum(oi.total_amount) as total_revenue
from order_items oi
join products p
on oi.product_id = p.product_id
group by p.product_name
order by total_revenue desc
;

-- top 10 performing products by revenue
select
p.product_name,
sum(oi.quantity) as total_quantity_sold,
sum(oi.total_amount) as total_revenue
from order_items oi
join products p
on oi.product_id = p.product_id
group by p.product_name
order by total_revenue desc
limit 10
;
