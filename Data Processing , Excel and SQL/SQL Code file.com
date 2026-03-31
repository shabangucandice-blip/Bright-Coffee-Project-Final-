
------------------------------------------------------------------
---I want to explore the table.
------------------------------------------------------------------
select * from `workspace`.`default`.`brightcoffeesales2` limit 100;

------------------------------------------------------------------
-- I want to check date range from the table 
------------------------------------------------------------------
select Min(transaction_date) AS min_date from `workspace`.`default`.`brightcoffeesales2`;



select Max(transaction_date) As latest_date from `workspace`.`default`.`brightcoffeesales2`;


------------------------------------------------------------------
-- I want to check the number of store locations Brightcoffee has
------------------------------------------------------------------
select distinct store_location From `workspace`.`default`.`brightcoffeesales2`;



-------------------------------------------------------------------------------------
-- I want to see the unique values for product category, product type,product detail. 
-------------------------------------------------------------------------------------
select distinct product_category, product_type, product_detail from `workspace`.`default`.`brightcoffeesales2`;



-----------------------------------------------------------------
--I want to count the number of rows, sales,products and stores.
-----------------------------------------------------------------
select count(*) As number_of_rows,
       count(Distinct transaction_id) As number_of_sales,
       count(Distinct product_id) As number_of_products,
       count(Distinct store_id) As number_of_stores
from `workspace`.`default`.`brightcoffeesales2`;



-------------------------------------------------------------------------
--I want to retrieve transaction details including revenue per transaction
--------------------------------------------------------------------------
select 
       transaction_date,
       dayname(transaction_date) as day_name,
       monthname(transaction_date) as month_name,
  date_format(transaction_time, 'HH:mm:ss') As purchase_time,

     
--Creating time buckets 
     
  CASE
    when date_format(transaction_time, 'HH:mm:ss') between '00:00:00' and '11:59:59' then '01.Morning'
    when date_format(transaction_time, 'HH:mm:ss') between '12:00:00' and '16:59:59' then '02.Afternoon'
    when date_format(transaction_time, 'HH:mm:ss') >='17:00:00' then '03.Evening'
  end as time_buckets, 
 ------------------------------------------------------------
  --Count of ID looking for the no of sales, products        
  -----------------------------------------------------------
  
  count(distinct transaction_id) as number_of_sales,
  count(distinct store_id) as number_of_stores,
  count(distinct product_id) as number_of_products,
 
  --Revenue 
  Sum(transaction_qty* unit_price) AS revenue_per_day,

 -----------------------------------------------------------
  --Categorical columns
 -----------------------------------------------------------
  product_category,
  store_location,
  product_detail
from `workspace`.`default`.`brightcoffeesales2`
group By

       transaction_date,
       day_name, 
       store_location,
     product_category,
     product_detail,
     month_name,
     purchase_time;
