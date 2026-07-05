CREATE TABLE calendar (
    date DATE PRIMARY KEY
);

drop table if exists customers;
CREATE TABLE customers (
    customer_key INT PRIMARY KEY,
    prefix VARCHAR(10),
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    birth_date DATE,
    marital_status CHAR(1),
    gender CHAR(3),
    email_address VARCHAR(100),
    annual_income VARCHAR(30),
    total_children INT,
    education_level VARCHAR(50),
    occupation VARCHAR(50),
    home_owner CHAR(1)
);

CREATE TABLE product_categories (
    product_category_key INT PRIMARY KEY,
    category_name VARCHAR(50)
);

CREATE TABLE product_subcategories (
    product_subcategory_key INT PRIMARY KEY,
    subcategory_name VARCHAR(100),
    product_category_key INT
);

CREATE TABLE products (
    product_key INT PRIMARY KEY,
    product_subcategory_key INT,
    product_sku VARCHAR(50),
    product_name VARCHAR(150),
    model_name VARCHAR(100),
    product_description TEXT,
    product_color VARCHAR(30),
    product_size VARCHAR(20),
    product_style VARCHAR(30),
    product_cost NUMERIC(10,4),
    product_price NUMERIC(10,4)
);

CREATE TABLE territories (
    sales_territory_key INT PRIMARY KEY,
    region VARCHAR(50),
    country VARCHAR(50),
    continent VARCHAR(50)
);

CREATE TABLE sales_2015 (
    order_date DATE,
    stock_date DATE,
    order_number VARCHAR(20),
    product_key INT,
    customer_key INT,
    territory_key INT,
    order_line_item INT,
    order_quantity INT
);

CREATE TABLE sales_2016 (
    order_date DATE,
    stock_date DATE,
    order_number VARCHAR(20),
    product_key INT,
    customer_key INT,
    territory_key INT,
    order_line_item INT,
    order_quantity INT
);

CREATE TABLE sales_2017 (
    order_date DATE,
    stock_date DATE,
    order_number VARCHAR(20),
    product_key INT,
    customer_key INT,
    territory_key INT,
    order_line_item INT,
    order_quantity INT
);

CREATE TABLE returns (
    return_date DATE,
    territory_key INT,
    product_key INT,
    return_quantity INT
);

ALTER TABLE product_subcategories
ADD CONSTRAINT fk_category
FOREIGN KEY (product_category_key)
REFERENCES product_categories(product_category_key);

ALTER TABLE products
ADD CONSTRAINT fk_subcategory
FOREIGN KEY (product_subcategory_key)
REFERENCES product_subcategories(product_subcategory_key);

ALTER TABLE sales_2015
ADD CONSTRAINT fk_sales2015_product
FOREIGN KEY (product_key)
REFERENCES products(product_key);

ALTER TABLE sales_2015
ADD CONSTRAINT fk_sales2015_customer
FOREIGN KEY (customer_key)
REFERENCES customers(customer_key);

ALTER TABLE sales_2015
ADD CONSTRAINT fk_sales2015_territory
FOREIGN KEY (territory_key)
REFERENCES territories(sales_territory_key);

ALTER TABLE sales_2016
ADD CONSTRAINT fk_sales2016_product
FOREIGN KEY (product_key)
REFERENCES products(product_key);

ALTER TABLE sales_2016
ADD CONSTRAINT fk_sales2016_customer
FOREIGN KEY (customer_key)
REFERENCES customers(customer_key);

ALTER TABLE sales_2016
ADD CONSTRAINT fk_sales2016_territory
FOREIGN KEY (territory_key)
REFERENCES territories(sales_territory_key);

ALTER TABLE sales_2017
ADD CONSTRAINT fk_sales2017_product
FOREIGN KEY (product_key)
REFERENCES products(product_key);

ALTER TABLE sales_2017
ADD CONSTRAINT fk_sales2017_customer
FOREIGN KEY (customer_key)
REFERENCES customers(customer_key);

ALTER TABLE sales_2017
ADD CONSTRAINT fk_sales2017_territory
FOREIGN KEY (territory_key)
REFERENCES territories(sales_territory_key);

ALTER TABLE returns
ADD CONSTRAINT fk_returns_product
FOREIGN KEY (product_key)
REFERENCES products(product_key);

ALTER TABLE returns
ADD CONSTRAINT fk_returns_territory
FOREIGN KEY (territory_key)
REFERENCES territories(sales_territory_key);


SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;

CREATE TABLE sales AS
SELECT * FROM sales_2015
UNION ALL

SELECT * FROM sales_2016
UNION ALL

SELECT * FROM sales_2017;

select round(sum(s.order_quantity*p.product_price),2) as Total_Revenue
from sales s 
join products p
on s.product_key=p.p

SELECT COUNT(DISTINCT Order_Number) AS Total_Orders
FROM sales;

SELECT COUNT(DISTINCT Customer_Key) AS Total_Customers
FROM sales;

SELECT SUM(Order_Quantity) AS Total_Products_Sold
FROM sales;

SELECT
    ROUND(
        SUM(s.Order_Quantity * p.Product_Price) /
        COUNT(DISTINCT s.Order_Number),2
    ) AS Average_Order_Value
FROM sales s
JOIN products p
ON s.Product_Key = p.Product_Key;

SELECT
    EXTRACT(YEAR FROM Order_Date) AS Year,
    ROUND(SUM(s.Order_Quantity * p.Product_Price),2) AS Revenue
FROM sales s
JOIN products p
ON s.Product_Key = p.Product_Key
GROUP BY Year
ORDER BY Year;

SELECT
    TO_CHAR(Order_Date,'Month') AS Month,
    ROUND(SUM(s.Order_Quantity * p.Product_Price),2) AS Revenue
FROM sales s
JOIN products p
ON s.Product_Key=p.Product_Key
GROUP BY Month
ORDER BY MIN(Order_Date);

SELECT
    p.Product_Name,
    ROUND(SUM(s.Order_Quantity * p.Product_Price),2) AS Revenue
FROM sales s
JOIN products p
ON s.Product_Key=p.Product_Key
GROUP BY p.Product_Name
ORDER BY Revenue DESC
LIMIT 10;

SELECT
    p.Product_Name,
    ROUND(SUM(s.Order_Quantity * p.Product_Price),2) AS Revenue
FROM sales s
JOIN products p
ON s.Product_Key=p.Product_Key
GROUP BY p.Product_Name
ORDER BY Revenue
LIMIT 10;

SELECT
    pc.Category_Name,
    ROUND(SUM(s.Order_Quantity * p.Product_Price),2) AS Revenue
FROM sales s
JOIN products p
ON s.Product_Key=p.Product_Key
JOIN product_subcategories ps
ON p.Product_Subcategory_Key=ps.Product_Subcategory_Key
JOIN product_categories pc
ON ps.Product_Category_Key=pc.Product_Category_Key
GROUP BY pc.Category_Name
ORDER BY Revenue DESC;

SELECT
    ps.Subcategory_Name,
    ROUND(SUM(s.Order_Quantity * p.Product_Price),2) AS Revenue
FROM sales s
JOIN products p
ON s.Product_Key=p.Product_Key
JOIN product_subcategories ps
ON p.Product_Subcategory_Key=ps.Product_Subcategory_Key
GROUP BY ps.Subcategory_Name
ORDER BY Revenue DESC;

SELECT
    t.Region,
    ROUND(SUM(s.Order_Quantity * p.Product_Price),2) AS Revenue
FROM sales s
JOIN products p
ON s.Product_Key=p.Product_Key
JOIN territories t
ON s.Territory_Key=t.Sales_Territory_Key
GROUP BY t.Region
ORDER BY Revenue DESC;

--Top 10 products by quantity sold
SELECT
    p.Product_Name,
    SUM(s.Order_Quantity) AS Units_Sold
FROM sales s
JOIN products p
ON s.Product_Key = p.Product_Key
GROUP BY p.Product_Name
ORDER BY Units_Sold DESC
LIMIT 10;

--Products with highest return
SELECT
    p.Product_Name,
    SUM(r.Return_Quantity) AS Returned_Units
FROM returns r
JOIN products p
ON r.Product_Key = p.Product_Key
GROUP BY p.Product_Name
ORDER BY Returned_Units DESC
LIMIT 10;

--Return rate by product
SELECT
    p.Product_Name,
    SUM(COALESCE(r.Return_Quantity,0)) AS Returns,
    SUM(s.Order_Quantity) AS Sold,
    ROUND(
        SUM(COALESCE(r.Return_Quantity,0))*100.0/
        SUM(s.Order_Quantity),2
    ) AS Return_Rate
FROM sales s
JOIN products p
ON s.Product_Key=p.Product_Key
LEFT JOIN returns r
ON s.Product_Key=r.Product_Key
GROUP BY p.Product_Name
ORDER BY Return_Rate DESC;

--Most Expensive Products
SELECT
    Product_Name,
    Product_Price
FROM products
ORDER BY Product_Price DESC
LIMIT 10;

--Highest profit margin products
SELECT
    Product_Name,
    Product_Price,
    Product_Cost,
    ROUND(
        Product_Price-Product_Cost,
        2
    ) AS Profit
FROM products
ORDER BY Profit DESC
LIMIT 10;

--Top Customers by revenue
SELECT
    c.Customer_Key,
    c.First_Name,
    c.Last_Name,
    ROUND(
        SUM(s.Order_Quantity*p.Product_Price),2
    ) AS Revenue
FROM sales s
JOIN customers c
ON s.Customer_Key=c.Customer_Key
JOIN products p
ON s.Product_Key=p.Product_Key
GROUP BY
c.Customer_Key,
c.First_Name,
c.Last_Name
ORDER BY Revenue DESC
LIMIT 10;

--Gender wise Revenue
SELECT
    c.Gender,
    ROUND(
        SUM(s.Order_Quantity*p.Product_Price),2
    ) AS Revenue
FROM sales s
JOIN customers c
ON s.Customer_Key=c.Customer_Key
JOIN products p
ON s.Product_Key=p.Product_Key
GROUP BY
c.Gender;

--Occupation wise revenue
SELECT
    c.Occupation,
    ROUND(
        SUM(s.Order_Quantity*p.Product_Price),2
    ) AS Revenue
FROM sales s
JOIN customers c
ON s.Customer_Key=c.Customer_Key
JOIN products p
ON s.Product_Key=p.Product_Key
GROUP BY
c.Occupation
ORDER BY Revenue DESC;

--Revenue by country
SELECT
    t.Country,
    ROUND(SUM(s.Order_Quantity * p.Product_Price),2) AS Revenue
FROM sales s
JOIN products p
ON s.Product_Key = p.Product_Key
JOIN territories t
ON s.Territory_Key = t.Sales_Territory_Key
GROUP BY t.Country
ORDER BY Revenue DESC;

--Revenue by continent
SELECT
    t.Continent,
    ROUND(SUM(s.Order_Quantity * p.Product_Price),2) AS Revenue
FROM sales s
JOIN products p
ON s.Product_Key = p.Product_Key
JOIN territories t
ON s.Territory_Key = t.Sales_Territory_Key
GROUP BY t.Continent
ORDER BY Revenue DESC;

--Orders by region
SELECT
    t.Region,
    COUNT(DISTINCT s.Order_Number) AS Orders
FROM sales s
JOIN territories t
ON s.Territory_Key = t.Sales_Territory_Key
GROUP BY t.Region
ORDER BY Orders DESC;

--Avg revenue per order by region
SELECT
    t.Region,
    ROUND(
        SUM(s.Order_Quantity * p.Product_Price) /
        COUNT(DISTINCT s.Order_Number),2
    ) AS Avg_Order_Value
FROM sales s
JOIN products p
ON s.Product_Key = p.Product_Key
JOIN territories t
ON s.Territory_Key = t.Sales_Territory_Key
GROUP BY t.Region
ORDER BY Avg_Order_Value DESC;

--Monthly revenue trend
SELECT
    DATE_TRUNC('month', s.Order_Date) AS Month,
    ROUND(SUM(s.Order_Quantity * p.Product_Price),2) AS Revenue
FROM sales s
JOIN products p
ON s.Product_Key = p.Product_Key
GROUP BY Month
ORDER BY Month;

--Quarterly revenue
SELECT
    EXTRACT(YEAR FROM s.Order_Date) AS Year,
    EXTRACT(QUARTER FROM s.Order_Date) AS Quarter,
    ROUND(SUM(s.Order_Quantity * p.Product_Price),2) AS Revenue
FROM sales s
JOIN products p
ON s.Product_Key = p.Product_Key
GROUP BY Year, Quarter
ORDER BY Year, Quarter;

--Revenue by day of week
SELECT
    TO_CHAR(s.Order_Date,'Day') AS Day_Name,
    ROUND(SUM(s.Order_Quantity * p.Product_Price),2) AS Revenue
FROM sales s
JOIN products p
ON s.Product_Key = p.Product_Key
GROUP BY Day_Name
ORDER BY Revenue DESC;

--Best sales month
SELECT
    TO_CHAR(s.Order_Date,'Month') AS Month,
    ROUND(SUM(s.Order_Quantity * p.Product_Price),2) AS Revenue
FROM sales s
JOIN products p
ON s.Product_Key = p.Product_Key
GROUP BY Month
ORDER BY Revenue DESC;

--overall return rate
SELECT
ROUND(
SUM(r.Return_Quantity)*100.0/
SUM(s.Order_Quantity),2
) AS Return_Rate
FROM sales s
JOIN returns r
ON s.Product_Key = r.Product_Key;

--return by category
SELECT
pc.Category_Name,
SUM(r.Return_Quantity) AS Returns
FROM returns r
JOIN products p
ON r.Product_Key = p.Product_Key
JOIN product_subcategories ps
ON p.Product_Subcategory_Key = ps.Product_Subcategory_Key
JOIN product_categories pc
ON ps.Product_Category_Key = pc.Product_Category_Key
GROUP BY pc.Category_Name
ORDER BY Returns DESC;

--Return by territory
SELECT
t.Region,
SUM(r.Return_Quantity) AS Returns
FROM returns r
JOIN territories t
ON r.Territory_Key = t.Sales_Territory_Key
GROUP BY t.Region
ORDER BY Returns DESC;

