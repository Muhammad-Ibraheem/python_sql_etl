-- find top 10 highest revenue generating products
select product_id, sum(sale_price) as sales
from orders
group by product_id
order by sales desc
limit 10;

WITH RankedSales AS (
    SELECT region, product_id, SUM(sale_price) AS total_sales,
           ROW_NUMBER() OVER (PARTITION BY region ORDER BY SUM(sale_price) DESC) AS `rank`
    FROM orders
    GROUP BY region, product_id
)
SELECT region, product_id, total_sales
FROM RankedSales
WHERE `rank` <= 5
ORDER BY region, total_sales DESC;

-- find month over month growth comparison for 2022 and 2023 sales eg. jan 2022 vs jan 2023

with cte as ( select year(order_date) as order_year, month(order_date) as order_month, sum(sale_price) as sales
from orders
group by year(order_date), month(order_date))
select order_month,
sum(case when order_year=2022 then sales else 0 end) as sales_2022,
sum(case when order_year=2023 then sales else 0 end) as sales_2023
from cte
group by order_month
order by order_month;


-- for each category which month had highest sales

with cte as (select category, DATE_FORMAT(order_date, '%Y%m') as order_year_month, sum(sale_price) as sales
from orders
group by category, DATE_FORMAT(order_date, '%Y%m'))
select * from (
select *, row_number() over(partition by category order by sales desc) as `rank`
from cte) a 
where `rank` = 1;


-- which sub category had highest gwoth by profit in 2023 compare to 2022.

with cte as (
select sub_category, year(order_date) as order_year, sum(sale_price) as sales
from orders
group by sub_category, year(order_date)
)
, cte2 as (select sub_category,
sum(case when order_year=2022 then sales else 0 end) as sales_2022,
sum(case when order_year=2023 then sales else 0 end) as sales_2023
from cte
group by sub_category
)
select *,
(sales_2023 - sales_2022) * 100/sales_2022 as growth
from cte2
order by growth desc
limit 1;