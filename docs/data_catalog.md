Data Catalog: Gold Layer
The Gold Layer serves as the definitive business-level data representation, meticulously structured to empower sophisticated analytical and reporting use cases. This layer comprises both dimension tables, providing contextual attributes, and fact tables, capturing key business metrics.

1. gold.dim_customers
Purpose: This dimension table meticulously curates comprehensive customer details, significantly enriched with vital demographic and geographic data to provide a holistic view of your customer base.

Column Name

Data Type

Description

customer_key

INT

A surrogate key acting as the unique identifier for each customer record within this dimension table.

customer_id

INT

The distinct numerical identifier assigned to every customer for internal tracking.

customer_number

NVARCHAR(50)

An alphanumeric code for customer tracking and cross-referencing purposes.

first_name

NVARCHAR(50)

The customer's given name, precisely as recorded in the system.

last_name

NVARCHAR(50)

The customer's surname or family name.

country

NVARCHAR(50)

The customer's country of residence (e.g., 'Australia').

marital_status

NVARCHAR(50)

The current marital status of the customer (e.g., 'Married', 'Single').

gender

NVARCHAR(50)

The specified gender of the customer (e.g., 'Male', 'Female', 'n/a').

birthdate

DATE

The customer's date of birth, formatted as YYYY-MM-DD (e.g., 1971-10-06).

create_date

DATE

The timestamp when this customer record was initially generated within the system.

2. gold.dim_products
Purpose: This dimension table furnishes exhaustive information regarding products and their intrinsic attributes, enabling granular analysis of your product portfolio.

Column Name

Data Type

Description

product_key

INT

A surrogate key serving as the unique identifier for each product entry in this dimension table.

product_id

INT

A unique numerical identifier assigned to the product for seamless internal tracking and referencing.

product_number

NVARCHAR(50)

A structured alphanumeric code representing the product, often instrumental for categorization or inventory management.

product_name

NVARCHAR(50)

The comprehensive descriptive name of the product, encompassing crucial details like type, color, and size.

category_id

NVARCHAR(50)

A unique identifier for the product's overarching category, facilitating its high-level classification.

category

NVARCHAR(50)

The broader classification of the product (e.g., Bikes, Components) designed to logically group related items.

subcategory

NVARCHAR(50)

A more refined classification of the product within its designated category, often indicating product type.

maintenance_required

NVARCHAR(50)

An indicator specifying whether the product necessitates ongoing maintenance (e.g., 'Yes', 'No').

cost

INT

The fundamental cost or base price of the product, denominated in whole monetary units.

product_line

NVARCHAR(50)

The specific product line or series to which the product inherently belongs (e.g., Road, Mountain).

start_date

DATE

The precise date when the product became commercially available for sale or general use.

3. gold.fact_sales
Purpose: This fact table meticulously captures and stores critical transactional sales data, serving as the cornerstone for in-depth analytical investigations and performance insights.

Column Name

Data Type

Description

order_number

NVARCHAR(50)

A unique alphanumeric identifier for each distinct sales order (e.g., 'SO54496').

product_key

INT

A surrogate key that establishes the crucial link between the sales order and the gold.dim_products dimension table.

customer_key

INT

A surrogate key that links the sales order to the gold.dim_customers dimension table.

order_date

DATE

The date on which the sales order was formally placed.

shipping_date

DATE

The date when the ordered goods were dispatched to the customer.

due_date

DATE

The specified date by which payment for the order was expected.

sales_amount

INT

The total monetary value of the sale for a particular line item, expressed in whole currency units (e.g., 25).

quantity

INT

The numerical count of product units ordered for the specific line item (e.g., 1).

price

INT

The unit price of the product for the line item, also represented in whole currency units (e.g., 25).
