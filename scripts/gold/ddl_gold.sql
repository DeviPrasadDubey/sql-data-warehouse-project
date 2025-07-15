/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer 
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/

-- ========================================================
-- Creating Dimension: 'gold.dim_customers'
-- ========================================================

IF OBJECT_ID('gold.dim_customers','V') IS NOT NULL
DROP VIEW gold.dim_customers;

GO

CREATE VIEW gold.dim_customers AS
select
	ROW_NUMBER() OVER(ORDER BY cst_id) AS customer_key,
	ci.cst_id AS customer_id,
	ci.cst_key AS customer_number,
	ci.cst_firstname AS first_name,
	ci.cst_lastname AS last_name,
	la.cntry AS country,
	ci.cst_marital_status AS marital_status,
	CASE 
		WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr -- CRM is the Master for gender Info
		ELSE COALESCE(ca.gen,'n/a')
	END AS gender,
	ca.bdate AS birthdate,
	ci.cst_create_date AS create_date
from silver.crm_cust_info as ci
left join silver.erp_cust_az12 as ca
on	ci.cst_key = ca.cid
left join silver.erp_loc_a101 as la
on  ci.cst_key = la.cid

-- ========================================================
-- Creating Dimension: 'gold.dim_products'
-- ========================================================

IF OBJECT_ID('gold.dim_products','V') IS NOT NULL
DROP VIEW gold.dim_products;

GO

CREATE VIEW gold.dim_products AS
select 
	ROW_NUMBER() OVER(ORDER BY pn.prd_start_dt, pn.prd_key) as product_key,
	pn.prd_id AS product_id,
	pn.prd_key AS product_number,
	pn.prd_nm AS prdouct_name,
	pn.cat_id AS category_id,
	pc.cat AS category,
	pc.subcat AS subcategory,
	pc.maintenance,
	pn.prd_cost AS cost,
	pn.prd_line AS product_line,
	pn.prd_start_dt AS start_date
from silver.crm_prd_info pn
left join silver.erp_px_cat_g1v2 pc
on pn.cat_id = pc.id
where prd_end_dt IS NULL; -- Filter out all historical data.

GO


-- ========================================================
-- Creating Fact: 'gold.fact_sales'
-- ========================================================
IF OBJECT_ID('gold.fact_sales','V') IS NOT NULL
DROP VIEW gold.fact_sales;

GO

CREATE VIEW gold.fact_sales AS
select 
	sd.sls_ord_num AS order_number,
    pr.product_key,
    cu.customer_key,
    sd.sls_order_dt AS order_date,
    sd.sls_ship_dt AS shipping_date,
    sd.sls_due_dt AS due_date,
    sd.sls_sales AS sales_amount,
    sd.sls_quantity AS quantity,
    sd.sls_price AS price
from silver.crm_sales_details sd
LEFT JOIN  gold.dim_products pr
on sd.sls_prd_key = pr.product_number
left join gold.dim_customers cu
on sd.sls_cust_id = cu.customer_id;

GO
