use sakila;

-- Lab | SQL Rolling calculations

-- 1. Get number of monthly active customers.
-- step 1: first i'll create a view with all the data i'm going to need:
create or replace view user_activity as
select customer_id, convert(rental_date, date) as Activity_date,
date_format(convert(rental_date,date), '%m') as Activity_Month,
date_format(convert(rental_date,date), '%Y') as Activity_year
from rental;

select * from sakila.user_activity;

create or replace view user_activity as
select customer_id, convert(rental_date, date) as Activity_date,
monthname(rental_date) as Activity_Month,
year(rental_date) as Activity_year
from rental;

-- step 2: getting the total number of active user per month and year
create or replace view sakila.monthly_active_users as
select Activity_year, Activity_Month, count(customer_id) as Active_users
from sakila.user_activity
group by Activity_year, Activity_Month
order by Activity_year asc, Activity_Month asc;

select * from monthly_active_users;

-- 2. Active users in the previous month
select 
   Activity_year, 
   Activity_month,
   Active_users, 
   lag(Active_users) over (order by Activity_year, Activity_Month) as Last_month -- lag(Active_users, 2) -- partition by Activity_year
from monthly_active_users;

-- 3. Percentage change in the number of active customers.
with cte_view as 
(
	select 
	Activity_year, 
	Activity_month,
	Active_users, 
	lag(Active_users) over (order by Activity_year, Activity_Month) as Last_month
	from monthly_active_users
)
select 
   Activity_year, 
   Activity_month, 
   Active_users, 
   Last_month, 
   (Active_users - Last_month) as Difference,
   round(((Active_users - Last_month)/Active_users*100), 2) as Percentage_Change
from cte_view;


-- 4. Retained customers every month
SELECT a.activity_month, b.activity_month, COUNT(distinct a.customer_id)
FROM sakila.user_activity a
JOIN sakila.user_activity b on b.customer_id = a.customer_id
WHERE a.Activity_month = 'June'
	and b.Activity_month = 'July';
    
SELECT COUNT(distinct customer_id), Activity_month
FROM sakila.user_activity
WHERE Activity_month='June'
AND customer_id in (SELECT customer_id
FROM sakila.user_activity
WHERE Activity_month='May');

SELECT COUNT(distinct customer_id), Activity_month
FROM sakila.user_activity
WHERE Activity_month='July'
AND customer_id in (SELECT customer_id
FROM sakila.user_activity
WHERE Activity_month='June');

SELECT COUNT(distinct customer_id), Activity_month
FROM sakila.user_activity
WHERE customer_id in (SELECT customer_id
FROM sakila.user_activity)
GROUP BY Activity_month;