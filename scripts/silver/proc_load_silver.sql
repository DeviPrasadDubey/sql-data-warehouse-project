/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
	Actions Performed:
		- Truncates Silver tables.
		- Inserts transformed and cleansed data from Bronze into Silver tables.
		
Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC Silver.load_silver; -- ( or you can run the last line of this code only to 
                                  exec the same thing is written there)
===============================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver  AS
BEGIN
	DECLARE @start_time	DATETIME, @end_time DATETIME,@batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY
		SET @batch_start_time = getdate();
		PRINT '==================================================='
		PRINT '>> Inserting data of customer into silver layer'
		PRINT '==================================================='

		PRINT '---------------------------------------------------'
		PRINT '>> Inserting data into CRM Tables'
		PRINT '---------------------------------------------------'
		-- ======================================================================================================================================
		--  TRUNCATING & INSERTING DATA INTO CRM CUSTOMER INformation TABLE
		-- ======================================================================================================================================
		SET @start_time = getdate();

		PRINT '>> Truncating Table: silver.crm_cust_info';
		TRUNCATE TABLE silver.crm_cust_info;
		PRINT'>> InsertinData Into : silver.crm_cust_info';
		INSERT INTO silver.crm_cust_info(
		cst_id,
		cst_key,
		cst_firstname,
		cst_lastname,
		cst_marital_status,
		cst_gndr,
		cst_create_date
		)
		select 
			cst_id,
			cst_key,
			TRIM(cst_firstname) as cst_firstname,		-- Removing Unwanted Spaces from firstname (for data consistency
			TRIM(cst_lastname) as cst_lastname,			-- Removing Unwanted Spaces from lastname
			case 
				when UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
				when UPPER(TRIM(cst_marital_status)) = 'M' Then 'Married'
				 Else 'n/a'
			End cst_marital_status,		-- Normalize marital status values to redable format (for meaningful values & handling missing or null values & user-friendly descriptions)
			case 
				when UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
				when UPPER(TRIM(cst_gndr)) = 'M' Then 'Male'
				 Else 'n/a'
			End cst_gndr,		-- Normalize gender values to redable format (for meaningful values and user-friendly descriptions)
			cst_create_date
		from(
			select 
				*,
				ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY  cst_create_date DESC) as flag_last
			from bronze.crm_cust_info
			where cst_id is not null
		)t where flag_last=1;  -- Select the most recent record per customer (Removing duplicates)

		SET @end_time= GETDATE();
		PRINT '>> Load  Duration: '+ CAST(DATEDIFF(SECOND,@start_time, @end_time) as nvarchar)+ ' seconds';
		PRINT '>> -----------------'
		-- ======================================================================================================================================
		-- TRUNCATING & INSERTING DATA INTO CRM  PRODUCT INFORMATION TABLE
		-- ======================================================================================================================================
		SET @start_time = getdate();

		PRINT '>> Truncating Table: silver.crm_prd_info';
		TRUNCATE TABLE silver.crm_prd_info;
		PRINT'>> InsertinData Into : silver.crm_prd_info';
		INSERT INTO silver.crm_prd_info(
			prd_id,
			cat_id,
			prd_key,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt
		)
			select 
				prd_id,
				REPLACE(SUBSTRING(prd_key,1,5),'-','_') as cat_id,		-- Extracted Category ID
				SUBSTRING(prd_key,7,LEN(prd_key)) as prd_key,			-- Extracted Product Key
				prd_nm,
				ISNULL(prd_cost,0) as prd_cost,
				CASE 
					When UPPER(TRIM(prd_line))= 'M' THEN 'Mountain'
					When UPPER(TRIM(prd_line))= 'R' THEN 'Road'
					When UPPER(TRIM(prd_line))= 'S' THEN 'Other Sales'
					When UPPER(TRIM(prd_line))= 'T' THEN 'Touring'
					else 'n/a'
				END as prd_line,		-- Mapping product line codes to descriptive values
				CAST(prd_start_dt as DATE) as prd_start_dt,
				CAST(
					LEAD(prd_start_dt) over(partition by prd_key Order by prd_start_dt)-1
					AS DATE
				)AS prd_end_dt -- Calculating end Date as one day before the next start date
		from bronze.crm_prd_info;

		SET @end_time= GETDATE();
		PRINT '>> Load  Duration: '+ CAST(DATEDIFF(SECOND,@start_time, @end_time) as nvarchar)+ ' seconds';
		PRINT '>> -----------------'

		-- ======================================================================================================================================
		-- TRUNCATING & INSERTING DATA INTO CRM SALES DETAILS TABLE
		-- ======================================================================================================================================
		SET @start_time = getdate();

		PRINT '>> Truncating Table: silver.crm_sales_details';
		TRUNCATE TABLE silver.crm_sales_details;
		PRINT'>> InsertinData Into : silver.crm_sales_details';
		INSERT INTO silver.crm_sales_details(
				sls_ord_num,
				sls_prd_key,
				sls_cust_id,
				sls_order_dt,
				sls_ship_dt,
				sls_due_dt,
				sls_sales,
				sls_quantity,
				sls_price
		)

		select 
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			CASE 
				WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
				ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
			END AS sls_order_dt,
			CASE 
				WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
				ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
			END AS sls_ship_dt,
			CASE 
				WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
				ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
			END AS sls_due_dt,
			case 
				when sls_sales is null or sls_sales <= 0 or sls_sales != sls_quantity * ABS(sls_price)
					then sls_quantity * ABS(sls_price)
				else sls_sales
			END AS sls_sales,
			sls_quantity,
			case 
				when sls_price is null or sls_price <= 0
					then sls_sales/NULLIF(sls_quantity,0)
				else sls_price
			END AS sls_price
		from bronze.crm_sales_details;

		SET @end_time= GETDATE();
		PRINT '>> Load  Duration: '+ CAST(DATEDIFF(SECOND,@start_time, @end_time) as nvarchar)+ ' seconds';
		PRINT '>> -----------------'


		
		PRINT '-----------------------------------------------';
		PRINT 'Loading ERP Tables';
		PRINT '-----------------------------------------------';


		-- ======================================================================================================================================
		-- TRUNCATING & INSERTING DATA INTO ERP CUSTOMER DETAILS TABLE
		-- ======================================================================================================================================
		SET @start_time = getdate();

		PRINT '>> Truncating Table: silver.erp_cust_az12';
		TRUNCATE TABLE silver.erp_cust_az12;
		PRINT'>> InsertinData Into : silver.erp_cust_az12';
		insert Into silver.erp_cust_az12
		(
			cid,
			bdate,
			gen
		)
		select 
		CASE
			WHEN cid LIKE  'NAS%' THEN SUBSTRING (cid,4,LEN(CID))  -- Remove 'NAS' prefix if present.
			ELSE cid
		END as cid,
		CASE
			WHEN bdate> GETDATE() THEN NULL
			ELSE bdate
		end as bdate,		-- Set future birth date to NULL
		CASE 
			WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
			when UPPER(TRIM(gen)) IN ('M','MALE') THEN 'Male'
			ELSE 'n/a'
		END AS gen -- Normalize gender value and handle unknown cases
		FROM bronze.erp_cust_az12;

		SET @end_time= GETDATE();
		PRINT '>> Load  Duration: '+ CAST(DATEDIFF(SECOND,@start_time, @end_time) as nvarchar)+ ' seconds';
		PRINT '>> -----------------'

		-- ======================================================================================================================================
		-- TRUNCATING & INSERTING DATA INTO ERP LOCATION (COUNTRY) TABLE
		-- ======================================================================================================================================
		SET @start_time = getdate();

		PRINT '>> Truncating Table: silver.erp_loc_a101';
		TRUNCATE TABLE silver.erp_loc_a101;
		PRINT'>> InsertinData Into : silver.erp_loc_a101';
		INSERT INTO silver.erp_loc_a101
		(cid,
		cntry)
		select replace(cid,'-','') AS CID,
			case
				 when TRIM(cntry) = '' or cntry is NULL then 'n/a'
				 when TRIM(cntry) = 'DE' THEN 'Germany'
				 When TRIM(cntry) in ('US','USA') then 'United States'
			else trim(cntry)
		END AS cntry
		from bronze.erp_loc_a101;

		SET @end_time= GETDATE();
		PRINT '>> Load  Duration: '+ CAST(DATEDIFF(SECOND,@start_time, @end_time) as nvarchar)+ ' seconds';
		PRINT '>> -----------------'

		-- ======================================================================================================================================
		-- TRUNCATING & INSERTING DATA INTO ERP PRODUCT CATERGORY TABLE
		-- ======================================================================================================================================
		SET @start_time = getdate();

		PRINT '>> Truncating Table: silver.erp_px_cat_g1v2';
		TRUNCATE TABLE silver.erp_px_cat_g1v2;
		PRINT'>> InsertinData Into : silver.erp_px_cat_g1v2';
		INSERT INTO silver.erp_px_cat_g1v2
		(	id,
			cat,
			subcat,
			maintenance
		)
		select 
		id,
		cat,
		subcat,
		maintenance
		from bronze.erp_px_cat_g1v2;

		SET @end_time= GETDATE();
		PRINT'===================================='
		PRINT'Inserting Data into Silver Layer is Completed';
		PRINT'  - Total Load Duration: ' + CAST(Datediff(SECOND, @batch_start_time, @batch_end_time) as Nvarchar) + ' seconds';
		PRINT'===================================='
	END TRY 
	BEGIN CATCH
		PRINT '==================================='
		PRINT'ERROR OCCURED DURING LOADING or INSERTING DATA INTO SilVER LAYER'
		PRINT'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '==================================='
	END CATCH

END



exec silver.load_silver;
