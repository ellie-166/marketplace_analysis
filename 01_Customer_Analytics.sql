-- Customer_Analytics
-- creating a customer table for customer analytics

create table customers (
customer_id int primary key auto_increment,
first_name varchar(50),
last_name varchar(50),
email varchar(100) unique,
signup_date date,
city_id int,
constraint fk_customer_city
foreign key (city_id)
references cities(city_id) 
);

-- generate realistic synthetic customers. 
insert into customers (first_name, last_name, email, signup_date, city_id)
with recursive seq as (
select 1 as n
union all
select n + 1
 from seq 
 where n < 1000
)
select
concat('User', n),
'Portfolio',
concat('user', n, '@example.com'),
date_sub(curdate(), interval floor(Rand()*365) day),
floor(1 + Rand()*5)
from seq
;


alter table orders
add column customer_id int;

alter table orders
add constraint fk_customer
foreign key(customer_id)
references customers(customer_id);

-- creating a customer_analytics view

create view customer_analytics as
select
o.customer_id,
count(Distinct o.order_id) as total_orders_lifetime,
sum(oi.quantity * oi.price ) as total_spend_lifetime,
min(o.order_date) as first_order_date,
max(o.order_date) as last_order_date,
datediff (curdate(), max(o.order_date)) as recency_days,
CASE
        WHEN DATEDIFF(CURDATE(), MAX(o.order_date)) <= 30 THEN 'Active'
        WHEN DATEDIFF(CURDATE(), MAX(o.order_date)) > 30
             AND COUNT(DISTINCT o.order_id) >= 3 THEN 'At Risk'
        ELSE 'Low Engagement'
    END AS churn_risk
    from orders o
join order_items oi
on o.order_id = oi.order_id
where o.customer_id is not null
group by o.customer_id
;

-- checking to confirm if my customer_analytics view exists

select * from customer_analytics;