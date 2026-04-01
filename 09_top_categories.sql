-- top 10 performing categories by revenue
select
c.category_name,
sum(oi.quantity) as total_quantity_sold,
sum(oi.total_amount) as total_revenue
from order_items oi
join products p
on oi.product_id = p.product_id
join categories c
on p.category_id = c.category_id
group by c.category_name
order by total_revenue desc
;