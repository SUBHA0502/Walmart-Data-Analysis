select * from walmart
select count(*) from walmart;
select distinct payment_method from walmart

select payment_method, count(*)
from walmart
Group By payment_method

select 
count(distinct branch) 
from walmart

select category, count(*)
from walmart
Group By category 
order by count(*) desc

select category, sum(total_amount)
from walmart
Group By category 
order by sum(total_amount) desc


select max(quantity),
min(quantity), 
avg(quantity) 
from walmart;

--BUSINESS PROBLEMS:
--Question 1: What are the different payment methods, and how many transactions and items were sold with each method?
select payment_method, sum(quantity) as "total_items" , count(*) as "total_transactions"
from walmart
group by payment_method
order by "total_transactions" desc;

--Question 2: Which category received the highest average rating in each branch?
select * 
from 
(
select branch, category, avg(rating) as "average_rating",
rank() over(partition by branch order by avg(rating) desc)
from walmart
group by branch, category
)
where rank = 1;

--Question 3: What is the busiest day of the week for each branch based on transaction volume?
 
select * from --using subquery
(
select branch, count(*) as no_of_transactions, 
to_char(to_date(date,'DD/mm/YY'), 'Day') as day_name, --Converting/ Extracting Day name from the date column
rank() over(partition by branch order by count(*) desc) as "rank"
from walmart
group by branch, day_name )
where rank = 1


--Question 4: How many items were sold through each payment method?
select payment_method, sum(quantity) as no_of_items_sold
from walmart
group by payment_method

--Question 5: What are the average, minimum, and maximum ratings for each category in each city?
select city, category, 
avg(rating), max(rating), 
min(rating)
from walmart
group by city, category
order by city

--Question 6: What is the total profit for each category, ranked from highest to lowest?
select * from walmart
select category, 
sum(profit_margin) as total_profit_margin
from walmart
group by category
order by total_profit_margin desc;

--Question 7: What is the most frequently used payment method in each branch?
select * from (
select branch, payment_method, count(*),
rank() over(partition by branch order by count(*)) as "rank"
from walmart
group by branch, payment_method)
where rank = 1


--Question 8: How many transactions occur in each shift (Morning, Afternoon, Evening) across branches?
select  branch,
   case 
        when extract (hour from(time::time)) < 12 then 'Morning'
        when extract (hour from(time::time)) between 12 and 17 then 'Afternoon'
        else 'Evening'
   end day_time,
   count(*) as no_of_transaction
from walmart
group by branch, day_time
order by branch, no_of_transaction desc


--Question 9: Which branches experienced the largest decrease in revenue compared to the previous year?
select *, 
Extract(year from to_date(date, 'dd/mm/yy')) as 
extracted_year
from walmart

--2022 sales
with revenue_2022 as
(
select branch, sum(total_amount) as revenue
from walmart
where Extract(year from to_date(date, 'dd/mm/yy')) = 2022
group by branch
),
revenue_2023 as
(
select branch, sum(total_amount) as revenue
from walmart
where Extract(year from to_date(date, 'dd/mm/yy')) = 2023
group by branch
)
select lr.branch as branch, 
lr.revenue as last_year_rev, 
cr.revenue as current_year_rev,
round(
	(lr.revenue- cr.revenue)::numeric/ 
	lr.revenue::numeric *100, 4) as rev_decr_ratio
from revenue_2022 as lr
join revenue_2023 as cr
on lr.branch= cr.branch
where lr.revenue > cr.revenue
order by rev_decr_ratio desc
limit 5














