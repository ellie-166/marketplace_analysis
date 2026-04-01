-- What % of revenue from the top 10% customer
with ranked_customers as (
select
customer_id,
total_spend_lifetime,
ntile(10) over (order by total_spend_lifetime desc) as spend_group
from customer_analytics
),
top_customers as (
select sum(total_spend_lifetime) as top_revenue
from ranked_customers
where spend_group = 1 
),
total_revenue as (
select sum(total_spend_lifetime) as total_revenue
from customer_analytics
)
select 
(top_revenue/ total_revenue) * 100 as revenue_percentage
from top_customers, total_revenue;
