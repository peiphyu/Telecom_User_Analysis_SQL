# Create unique customer list from customer table. 
DROP table if EXISTS tbl_customer_list;
create table tbl_customer_list as
select DISTINCT customer_id, city, signup_date from tbl_customer

# Total Customer List
select count (customer_id) total_customer 
from tbl_customer_list 
-- Total 12,000 customers in system.

# Calculate total data usage for each customer
drop table if exists tbl_data_usage_customer;
CREATE table tbl_data_usage_customer AS
select Customer.customer_id,
sum(data_used_mb) total_data_usage_mb
from tbl_customer_list as Customer
join tbl_data as Data on Customer.customer_id=Data.customer_id
group by Customer.customer_id

--select * from tbl_data_usage_customer
--select sum (total_data_usage_mb) total_data_usage_mb from tbl_data_usage_customer;

# Create table for customer data usage MB to GB.
drop table if exists tbl_customer_data_usage_slab_wise;
create table tbl_customer_data_usage_slab_wise as 
select customer_id,
CASE
    WHEN total_data_usage_mb BETWEEN 1000 AND 1999 THEN '1-2 GB'
    WHEN total_data_usage_mb BETWEEN 2000 AND 2999 THEN '2-3 GB'
    WHEN total_data_usage_mb BETWEEN 3000 AND 3999 THEN '3-4 GB'
    WHEN total_data_usage_mb BETWEEN 4000 AND 4999 THEN '4-5 GB'
    WHEN total_data_usage_mb BETWEEN 5000 AND 5999 THEN '5-6 GB'
    WHEN total_data_usage_mb BETWEEN 6000 AND 6999 THEN '6-7 GB'
    WHEN total_data_usage_mb BETWEEN 7000 AND 7999 THEN '7-8 GB'
    WHEN total_data_usage_mb BETWEEN 8000 AND 8999 THEN '8-9 GB'
    ELSE '9-10 GB'
END AS data_slab
FROM tbl_data_usage_customer

--select * from tbl_customer_data_usage_slab_wise;
--select data_slab, count (customer_id) uu from tbl_customer_data_usage_slab_wise group by data_slab order by uu DESC

# Create data user segmentations
drop table if exists tbl_data_user_segment;
create table tbl_data_user_segment AS
select customer_id,
case 
when data_slab>='1-2 GB' AND  data_slab<='2-3 GB' then 'Low'
when data_slab>='3-4 GB'  AND  data_slab<='4-5 GB' then 'Medium'
when data_slab>='5-6 GB'  AND  data_slab<='7-8 GB' then 'High'
when data_slab>='8-9 GB' then 'Very High' END as data_user_segment
from tbl_customer_data_usage_slab_wise

--select * from tbl_data_user_segment
--select count (*) cnt from tbl_data_user_segment group by data_user_segment-- 9740

# Calculate call usage for each customer
drop table if exists tbl_call_usage_customer;
CREATE table tbl_call_usage_customer AS
select Customer.customer_id,
sum(duration_minutes) total_call_minutes
from tbl_customer_list as Customer
join tbl_call as Call ON Customer.customer_id=Call.customer_id
group by Customer.customer_id

--select * from tbl_call_usage_customer
--select count (*) cnt from tbl_call_usage_customer group by call_type
# Create call user segmentations
drop table if exists tbl_customer_call_segment;
create table tbl_customer_call_segment as
SELECT
customer_id,
CASE
    WHEN total_call_minutes = 0 THEN 'No Calls'
    WHEN total_call_minutes <= 100 THEN 'Very Low'
    WHEN total_call_minutes <= 300 THEN 'Low'
    WHEN total_call_minutes <= 600 THEN 'Medium'
    WHEN total_call_minutes <= 1000 THEN 'High'
    ELSE 'Very High'
END AS call_usage_slab
FROM tbl_call_usage_customer;

--select call_usage_slab, count (*) cnt from tbl_customer_call_segment group by call_usage_slab

# Create customer table along with their data and call usage
drop table if exists tbl_active_customer;
CREATE TABLE tbl_active_customer AS
SELECT 
    Cus.customer_id,
    Cus.city,
    CASE 
        WHEN COALESCE(D.total_data_usage_mb,0) > 0 
          OR COALESCE(C.total_call_minutes,0) > 0
        THEN 'Active'
        ELSE 'Inactive'
    END AS Active_Flag
FROM tbl_customer_list Cus
LEFT JOIN tbl_data_usage_customer D 
       ON Cus.customer_id = D.customer_id
LEFT JOIN tbl_call_usage_customer C 
       ON Cus.customer_id = C.customer_id;

--select active_flag, Count (*) cnt from tbl_active_customer group by active_flag
# How many active customer who has data and call usage?
select count (customer_id) active_uu from tbl_active_customer 
where active_flag='Active'
-- Total 11,557 active customer. (96% Active)

# Top cities by Active customers
drop table if exists tbl_top_cities_by_active_customer;
create table tbl_top_cities_by_active_customer as
select city, count (customer_id) active_uu
from tbl_active_customer 
where active_flag='Active' 
group by city 
order by active_uu desc

select * from tbl_top_cities_by_active_customer
-- Mawlamyine has the highest number of active customers (2,036), followed by Bago with 2,006 customers.

# Create customer table along with their subscription plan
drop table if exists tbl_customer_subscription;
create table tbl_customer_subscription as 
select Cus.customer_id,
Cus.Active_Flag,
S.plan_id,
S.plan_name
from tbl_active_customer as Cus 
join (
  select Sub.customer_id, Sub.plan_id,
  Pln.plan_name
  from tbl_subscriptions as Sub 
  join tbl_plans as Pln On Sub.plan_id=Pln.plan_id) as S on Cus.customer_id=S.customer_id
Where Active_Flag='Active'

--select * from tbl_customer_subscription

# Analysis for User Types
drop table if exists tbl_user_analysis;
create table tbl_user_analysis as 
select Cus.customer_id,
case when Data_Seg.data_user_segment is NULL then 'No Usage' else Data_Seg.data_user_segment end as data_segment,
case when Call_Seg.call_usage_slab is NULL then 'No Calls' else Call_Seg.call_usage_slab end as call_segment
from tbl_customer_list as Cus 
Left JOIN tbl_data_user_segment as Data_Seg ON Cus.customer_id=Data_Seg.customer_id
left join tbl_customer_call_segment as Call_Seg ON Cus.customer_id=Call_Seg.customer_id

--select * from tbl_user_analysis;
--select count (*) cnt from tbl_user_analysis

--select data_segment, call_segment, count (customer_id) uu from tbl_user_analysis group by data_segment, call_segment

-- Final Result
SELECT 
CASE
    WHEN data_segment IN ('High','Very High') 
         AND call_segment IN ('No Calls','Very Low','Low')
         THEN 'Data Users'
         
    WHEN data_segment IN ('Low','No Usage') 
         AND call_segment IN ('Medium','High')
         THEN 'Voice Users'
         
    WHEN data_segment IN ('High','Very High') 
         AND call_segment IN ('Medium','High')
         THEN 'Heavy Users'
         
    ELSE 'Balanced Users'
END AS user_type,
Count(customer_id) customers
FROM tbl_user_analysis
GROUP BY user_type
ORDER BY customers DESC;

Balanced Users - 7,125
Data Users 	- 4,873
Heavy Users - 2
