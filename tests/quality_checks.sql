/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script performs quality checks to validate the integrity, consistency, 
    and accuracy of the Gold Layer. These checks ensure:
    - Uniqueness of surrogate keys in dimension tables.
    - Referential integrity between fact and dimension tables.
    - Validation of relationships in the data model for analytical purposes.

Usage Notes:
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/


-- ========================================================
-- Checking 'gold.dim_customers'
-- ========================================================

-- Check for Uniqueness of Customer Key in gold.dim_customers
-- Expectation: No Results
Select 
	customer_key,
	count(*) As duplicate_count
from gold.dim_customers
group by customer_key
having count(*) >1;

-- CHECKING STANDARDIZATION & CONSISTENCY.
select distinct
	gender 
from gold.dim_customers;


-- Final look of view
select * from gold.dim_customers


-- ========================================================
-- Checking 'gold.dim_products'
-- ========================================================

-- Check for Uniqueness of Customer Key in gold.dim_customers
-- Expectation: No Results
Select 
	product_key,
	count(*) As duplicate_count
from gold.dim_products
group by product_key
having count(*) >1;

-- Final look of view
select * from gold.dim_products

-- ========================================================
-- Checking 'gold.fact_sales'
-- ========================================================


-- Checking the data model connectivity between fact and dimensions

select * 
from gold.fact_sales f
left join gold.dim_products p
on f.product_key = p.product_key
left join gold.dim_customers c
on f.customer_key = c.customer_key
where c.customer_key IS NULL or p.product_key is null;

-- Final look of view
select * from gold.fact_sales
