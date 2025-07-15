# Data Catalog – Gold Layer

This document contains the **data catalog** for the Gold Layer of our data warehouse. The Gold Layer is the final stage of the ETL pipeline and contains clean, structured data that's ready for analysis and reporting. It mainly includes **dimension tables** (for descriptive information) and **fact tables** (for transactional or numeric data).

The **Gold Layer** represents the finalized business-ready data model. It is designed to support advanced reporting, dashboards, and analytics. This layer includes **dimension tables** that add context, and **fact tables** that store measurable business data.
---

### 1. **gold.dim_customers**

**Purpose:**  
This table stores detailed customer information, including basic details and demographic info. It helps in understanding the customer base better for business analysis.

| Column Name     | Data Type     | Description                                                                 |
|------------------|---------------|-----------------------------------------------------------------------------|
| customer_key     | INT           | A unique surrogate key for each customer row.                               |
| customer_id      | INT           | Original ID given to each customer by the system.                           |
| customer_number  | NVARCHAR(50)  | A code used to track or reference customers.                                |
| first_name       | NVARCHAR(50)  | Customer’s first name.                                                      |
| last_name        | NVARCHAR(50)  | Customer’s last name.                                                       |
| country          | NVARCHAR(50)  | Country where the customer lives (e.g., India, Australia).                  |
| marital_status   | NVARCHAR(50)  | Marital status like Single, Married, etc.                                   |
| gender           | NVARCHAR(50)  | Gender of the customer (Male, Female, or Not Available).                    |
| birthdate        | DATE          | Customer's date of birth (format: YYYY-MM-DD).                              |
| create_date      | DATE          | Date when this record was added to the system.                              |

---

### 2. **gold.dim_products**

**Purpose:**  
This dimension table contains full product details like name, category, price, and whether it needs maintenance. It helps in analyzing product-wise performance and categorization.

| Column Name         | Data Type     | Description                                                                 |
|----------------------|---------------|-----------------------------------------------------------------------------|
| product_key          | INT           | Surrogate key for uniquely identifying each product.                        |
| product_id           | INT           | System-assigned product ID.                                                 |
| product_number       | NVARCHAR(50)  | Product code used in inventory or catalog.                                  |
| product_name         | NVARCHAR(50)  | Full name or description of the product.                                    |
| category_id          | NVARCHAR(50)  | ID for the main product category.                                           |
| category             | NVARCHAR(50)  | Broad classification of product (e.g., Bikes, Accessories).                |
| subcategory          | NVARCHAR(50)  | More specific classification (e.g., Helmets, Tires).                        |
| maintenance_required | NVARCHAR(50)  | Shows if product needs maintenance (Yes/No).                                |
| cost                 | INT           | Base cost of the product in currency (no decimals).                         |
| product_line         | NVARCHAR(50)  | Series or line of the product (e.g., Road, Mountain).                       |
| start_date           | DATE          | Date when the product became available.                                     |

---

### 3. **gold.fact_sales**

**Purpose:**  
This fact table stores each sales transaction. It connects to both customers and products and is used for sales reporting and revenue analysis.


| Column Name   | Data Type     | Description                                                                 |
|----------------|---------------|-----------------------------------------------------------------------------|
| order_number   | NVARCHAR(50)  | Unique ID for each sales order (e.g., SO1001).                              |
| product_key    | INT           | Foreign key linking to `dim_products`.                                      |
| customer_key   | INT           | Foreign key linking to `dim_customers`.                                     |
| order_date     | DATE          | The date when the order was placed.                                         |
| shipping_date  | DATE          | The date when the product was shipped.                                      |
| due_date       | DATE          | The expected payment due date.                                              |
| sales_amount   | INT           | Total value of the sale (in full currency amount).                          |
| quantity       | INT           | Number of units sold.                                                       |
| price          | INT           | Price per unit at time of sale.                                             |

