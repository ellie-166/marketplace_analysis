-- Welcome to Marketplace analysis
-- This is a mini project that shows the revenue trend, growth and general data-insights of an online market store.
-- I created the schema and named it marketplace.
-- here's an easy to read and well documented bunch of codes from creating tables, to loading data, cleaning and writing queries.
-- let's begin!

-- creating tables

create table marketplace.categories (category_id int primary key, category_name varchar(100) unique not null);
create table marketplace.brands (brand_id int primary key, brand_name varchar(100) unique not null);
create table marketplace.platforms (platform_id int primary key, platform_name varchar(100) unique not null);
create table marketplace.cities (city_id int primary key, city_name varchar(100) unique not null);

create table marketplace.products (product_id int primary key,
 product_name varchar(255) not null, 
 category_id int,
 brand_id int, 
 price decimal(10,2),
 foreign key (brand_id) references marketplace.categories(category_id),
 foreign key (brand_id) references marketplace.brands(brand_id)
 );

create table marketplace.order_items
( 
order_items_id int primary key,
order_id int,
product_id int,
quantity int,
price decimal (10,2),
foreign key (order_id) references marketplace.orders(order_id),
foreign key (product_id) references marketplace.products(product_id)
 );
 
 create table marketplace.reviews
( 
review_id int primary key,
product_id int,
rating decimal (2, 1),
review_num int,
foreign key (product_id) references marketplace.products(product_id)
 );
 
 -- checking to confirm if my tables exist
 select *
 from categories;
 
 -- creating a staging table to load my csv datafile
 create table if not exists
 marketplace_staging (
 orderid varchar(50),
 product varchar(255),
 category varchar(255),
 brand varchar(255),
 platform varchar(100),
 city varchar(100),
 price varchar(50),
 quantity varchar(50),
 total_amount varchar(50),
 rating varchar(50),
 review varchar(50),
 order_date varchar(50)
 );
 
 -- load csv into staging table
 load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/ecommerce_10000.csv'
 into table marketplace_staging
 fields terminated by ','
 enclosed by '"'
 lines terminated by '\r\n'
 ignore 1 rows
 
 
 -- working on load infile error
 show variables like 'local_infile';
 set global local_infile = 1;
 show variables like 'secure_file_priv';

-- validating my staged data
select *
from marketplace_staging limit 10;
select count(*) from marketplace_staging;

-- cleaning staged data

-- checking for invalid numbers
select *
from marketplace_staging
where price not regexp '^[0-9]+(\\.[0-9]+)?$'
or quantity not regexp '^[0-9]+$'
or total_amount not regexp '^[0-9]+(\\.[0-9]+)?$'
;
-- checking for invalid dates
select *
from marketplace_staging
where str_to_date(order_date, '%m/%d/%y') is null
;
-- checking for empty or missing orderIDs
select * 
from marketplace_staging 
where orderid is null or orderid = ''
;


 -- loading data from staged table(marketplace_staging) to relational table
 
 -- categories
insert into categories (category_name)
 select distinct s.category
 from marketplace_staging s
where s.category is not null
and s.category <> ''
and not exists(
select 1
from categories c
where c.category_name = s.category
);

-- resolving auto-increment error and foreign key restrains errors
describe categories;

alter table categories
modify category_id int not null 
auto_increment;
 
 drop table marketplace.categories;
 create table marketplace.categories (category_id int auto_increment primary key, category_name varchar(100) unique not null);
 
 show create  table products;
  set foreign_key_checks = 0;
  
  -- dropping table to fix auto-increment error
  drop table if exists
  brands,
  categories,
  cities, 
  order_items,
  orders,
  platforms,
  products,
  reviews
  ;
  
  -- recreating table to correct autoincrement error
create table marketplace.categories (category_id int auto_increment primary key, category_name varchar(100) unique not null);
create table marketplace.brands (brand_id int auto_increment primary key, brand_name varchar(100) unique not null);
create table marketplace.platforms (platform_id int auto_increment primary key, platform_name varchar(100) unique not null);
create table marketplace.cities (city_id int auto_increment primary key, city_name varchar(100) unique not null);

create table marketplace.products (product_id int auto_increment primary key,
 product_name varchar(255) not null, 
 category_id int not null,
 brand_id int not null, 
 unique (product_name, category_id, brand_id),
 foreign key (category_id) references marketplace.categories(category_id),
 foreign key (brand_id) references marketplace.brands(brand_id)
 );
 
 create table marketplace.orders (
 order_id int primary key,
 platform_id int not null, 
 city_id int not null,
 order_date date not null, 
 
 foreign key (platform_id) references marketplace.platforms(platform_id),
 foreign key (city_id) references marketplace.cities(city_id)
 );

create table marketplace.order_items
( 
order_item_id int auto_increment primary key,
order_id int not null,
product_id int not null,
price decimal(10,2) not null,
quantity int not null,
total_amount decimal (10,2) not null,
foreign key (order_id) references marketplace.orders(order_id),
foreign key (product_id) references marketplace.products(product_id)
 );
 
 create table marketplace.reviews
( 
review_id int auto_increment primary key,
order_id int not null,
rating decimal (2, 1),
review int,
foreign key (order_id) references marketplace.orders(order_id)
 );
  
  set foreign_key_checks = 1;
 
  -- reloading data from staged table(marketplace_staging) to relational table
 
 -- categories
insert into categories (category_name)
 select distinct s.category
 from marketplace_staging s
where s.category is not null
and s.category <> ''
and not exists(
select 1
from categories c
where c.category_name = s.category
);

-- checking to see loaded data
select category_id, category_name
from categories 
;

-- brands
insert into brands(brand_name)
 select distinct s.brand
 from marketplace_staging s
where s.brand is not null
and s.brand <> ''
and not exists(
select 1
from brands b
where b.brand_name = s.brand
);

-- checking to see loaded data
select brand_id, brand_name
from brands 
;
 
-- platforms
insert into platforms(platform_name)
 select distinct s.platform
 from marketplace_staging s
where s.platform is not null
and s.platform <> ''
and not exists(
select 1
from platforms p
where p.platform_name = s.platform
);

-- checking to see loaded data
select platform_id, platform_name
from platforms 
;
  
 -- cities
insert into cities(city_name)
 select distinct s.city
 from marketplace_staging s
where s.city is not null
and s.city <> ''
and not exists(
select 1
from cities cs
where cs.city_name = s.city
);

-- checking to see loaded data
select city_id, city_name
from cities 
;
  
-- products
insert into products(product_name, category_id, brand_id)
 select distinct 
 s.product, 
 c.category_id,
 b.brand_id
 from marketplace_staging s
 join categories c on c.category_name = s.category
 join brands b on b.brand_name = s.brand
where s.product is not null
and s.product <> ''
and s.category is not null
and s.category <> ''
and s.brand is not null
and s.brand <> ''
and not exists(
select 1
from products p
where p.product_name = s.product
and p.category_id = c.category_id
and p.brand_id = b.brand_id
);

-- checking to see loaded data
select *
from products 
;

-- orders
insert into orders(
order_id, 
platform_id, 
city_id, 
order_date)
 select distinct 
 cast(substring(s.orderid, 4) as unsigned) as order_id,
 pl.platform_id,
 cs.city_id,
 str_to_date(s.order_date, '%m/%d/%Y') as order_date
 from marketplace_staging s
 join platforms pl on pl.platform_name = s.platform
 join  cities cs on cs.city_name = s.city
 where s.orderid regexp '^ORD[0-9]+$' 
 and str_to_date(s.order_date, '%m/%d/%Y') is not null
and not exists(
select 1
from orders o
where o.order_id = cast(substring(s.orderid, 4) as unsigned)
);

select s.orderid,
substring(s.orderid, 4) as extracted,
cast(substring(s.orderid, 4) as unsigned) as orderid
from marketplace_staging s
limit 10
;

-- checking to see loaded data
select *
from orders
limit 10
;

-- order_items
insert into order_items(
order_id,
product_id,
price,
quantity,
total_amount)
select 
cast(substring(s.orderid, 4) as unsigned) as order_id,
p.product_id,
s.price,
s.quantity,
s.total_amount
from marketplace_staging s
join products p
on p.product_name = s.product
where s.orderid regexp '^ORD[0-9]+$'
and s.price is not null
and s.quantity is not null
and s.total_amount is not null
;

-- reviews
insert into reviews(order_id,
rating,
review)
select
cast(substring(s.orderid, 4)as unsigned) as order_id,
cast(s.rating as decimal(2,1)) as rating,
cast(s.review as unsigned) as review
from marketplace_staging s
join orders o
on o.order_id = cast(substring(s.orderid, 4) as unsigned)
where rating is not null
and review is not null
;
