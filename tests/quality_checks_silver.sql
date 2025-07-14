/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script performs various quality checks for data consistency, accuracy, 
    and standardization across the 'silver' layer. It includes checks for:
    - Null or duplicate primary keys.
    - Unwanted spaces in string fields.
    - Data standardization and consistency.
    - Invalid date ranges and orders.
    - Data consistency between related fields.

Usage Notes:
    - Run these checks after data loading Silver Layer.
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/

-- ======================================================================================================================================
--  CHECKING QUALITY AND CONSISTENCY OF 'silver.crm_cust_info'
-- ======================================================================================================================================

-- Check for NULLS or Duplicates in Primary Key
-- Expectation: No Result

SELECT 
    cst_id, 
    COUNT(*) 
FROM silver.crm_cust_info
GROUP BY cst_id 
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Checking for Unwanted Spaces.
-- Expectation: No Result

SELECT
    cst_key
FROM silver.crm_cust_info
WHERE cst_key != TRIM(cst_key);

SELECT 
    cst_firstname 
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);

SELECT 
    cst_lastname
FROM silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);

SELECT 
    cst_gndr
FROM silver.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr);

SELECT 
    cst_marital_status 
FROM silver.crm_cust_info
WHERE cst_marital_status != TRIM(cst_marital_status);

-- Data Standardization & Consistency
SELECT DISTINCT 
    cst_marital_status 
FROM silver.crm_cust_info;

SELECT DISTINCT 
    cst_gndr
FROM silver.crm_cust_info;

-- Final Look of the Table
SELECT * 
FROM silver.crm_cust_info;

-- ======================================================================================================================================
--  CHECKING QUALITY AND CONSISTENCY OF 'silver.crm_prd_info'
-- ======================================================================================================================================

-- Check for NULLS or Duplicates in Primary Key
-- Expectation: No Result
SELECT 
    prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- Checking for NULLS or Negative Numbers.
-- Expectation: No Result

SELECT
    prd_cost 
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- Data Standardization & Consistency
SELECT * 
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;

--  Check for Invalid Date Orders
SELECT * 
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;

-- Final Look of the Table
SELECT * 
FROM silver.crm_prd_info;

-- ======================================================================================================================================
--  CHECKING QUALITY AND CONSISTENCY OF 'silver.crm_sales_details'
-- ======================================================================================================================================

-- Check For Invalid Date Orders
SELECT *
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR 
      sls_order_dt > sls_due_dt;

-- Check Data Consistency: Between Sales, Quantity, and Price
-- >> Sales == Quantity * Price
-- >> Values must not be NULL, Zero, or Negative
SELECT DISTINCT
    sls_sales,
    sls_quantity,
    sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
      OR sls_sales <= 0 
      OR sls_quantity <= 0 
      OR sls_price <= 0
      OR sls_sales IS NULL 
      OR sls_quantity IS NULL 
      OR sls_price IS NULL
ORDER BY sls_sales, sls_quantity, sls_price;

-- Final Look of the Table
SELECT * 
FROM silver.crm_sales_details;

-- ======================================================================================================================================
--  CHECKING QUALITY AND CONSISTENCY OF 'silver.erp_cust_az12'
-- ======================================================================================================================================

-- Identify Out-of_Range Dates
-- Dates more than current Date.
SELECT DISTINCT 
    bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE();

-- Data Standardization & Consistency
SELECT DISTINCT 
    gen 
FROM silver.erp_cust_az12;

-- Final Look of the Table
SELECT * 
FROM silver.erp_cust_az12;

-- ======================================================================================================================================
--  CHECKING QUALITY AND CONSISTENCY OF 'silver.erp_px_cat_g1v2'
-- ======================================================================================================================================
-- Data Standardization & Consistency
SELECT DISTINCT 
    cntry 
FROM silver.erp_loc_a101
ORDER BY cntry;

-- Final Look of the table
SELECT * 
FROM silver.erp_loc_a101;

-- ======================================================================================================================================
--  CHECKING QUALITY AND CONSISTENCY OF 'silver.erp_px_cat_g1v2'
-- ======================================================================================================================================
-- THE DATA OF THE ERP_PRODUCT_CATEGORY TABLE IN BRONZE LAYER IS ALMOST CORRECT & CONSISTENT SO, NO CHANGES WERE REQUIRED
-- THE DATA OF BRONZE LAYER IS DIRECTLY INSERTED BECAUES NO CHANGE REQUIRED
SELECT * 
FROM silver.erp_px_cat_g1v2;
