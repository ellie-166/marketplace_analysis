-- churn_risk analysis
select
churn_risk,
count(*) as number_of_customers
from customer_analytics
group by churn_risk;


-- value segmentation based on spend bands using case
with customer_spend as (
select
o.customer_id,
sum(oi.total_amount) as total_spend
from orders o 
join order_items oi
on o.order_id = oi.order_id
group by o.customer_id
)
select
customer_id,
total_spend,
case
 when total_spend >= 500000 then 'high value'
 when total_spend >= 100000 then 'medium value'
 else 'low value'
end as value_segment
from customer_spend;

-- create a reusable view/table
create view customer_analytics_v2 as
select *,
case 
  when total_spend_lifetime >= 500000 then 'high value'
  when total_spend_lifetime >= 100000 then 'medium value'
 else 'low value'
end as value_segment,
case
when recency_days <= 15 then 'Active'
when recency_days <= 30 then 'warm'
else 'Cold'
end as activity_status
from customer_analytics;
 
select * from 
customer_analytics_v2;
  
-- Answering key stakeholders questions

-- checking for high_value_churn_risk customers
select 
count(*) as high_value_churn_risk_customers
from customer_analytics_v2
where churn_risk = "At Risk"
and value_segment = 'high value'; 

-- from the distribution we have 19 high value customers at risk of churn.
 