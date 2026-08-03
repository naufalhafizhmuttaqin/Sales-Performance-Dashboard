/* Sales Performance Analytics SQL */
DROP DATABASE IF EXISTS sales_performance;
CREATE DATABASE sales_performance;
USE sales_performance;

CREATE TABLE superstore(
row_id INT,order_id VARCHAR(30),order_date DATE,ship_date DATE,ship_mode VARCHAR(50),
customer_id VARCHAR(30),customer_name VARCHAR(100),segment VARCHAR(50),
country VARCHAR(100),city VARCHAR(100),state VARCHAR(100),postal_code INT,region VARCHAR(50),
product_id VARCHAR(50),category VARCHAR(50),sub_category VARCHAR(50),product_name TEXT,
sales DECIMAL(12,2),quantity INT,discount DECIMAL(5,2),profit DECIMAL(12,2),
order_year INT,order_quarter INT,order_month INT,order_month_name VARCHAR(20),
order_weekday VARCHAR(20),shipping_days INT,profit_margin DECIMAL(8,2),
sales_per_unit DECIMAL(12,2),profit_per_unit DECIMAL(12,2));

-- Import superstore_clean.csv before executing the queries below.

-- KPI
SELECT ROUND(SUM(sales),2) total_sales FROM superstore;
SELECT ROUND(SUM(profit),2) total_profit FROM superstore;
SELECT COUNT(DISTINCT order_id) total_orders FROM superstore;
SELECT COUNT(DISTINCT customer_id) total_customers FROM superstore;
SELECT ROUND(SUM(profit)/SUM(sales)*100,2) profit_margin FROM superstore;

-- Category Analysis
SELECT category,ROUND(SUM(sales),2) total_sales,ROUND(SUM(profit),2) total_profit
FROM superstore GROUP BY category ORDER BY total_sales DESC;

SELECT sub_category,ROUND(SUM(sales),2) total_sales,ROUND(SUM(profit),2) total_profit
FROM superstore GROUP BY sub_category ORDER BY total_sales DESC;

-- Region
SELECT region,ROUND(SUM(sales),2) total_sales,ROUND(SUM(profit),2) total_profit
FROM superstore GROUP BY region ORDER BY total_sales DESC;

SELECT state,ROUND(SUM(sales),2) total_sales,ROUND(SUM(profit),2) total_profit
FROM superstore GROUP BY state ORDER BY total_sales DESC;

-- Segment
SELECT segment,ROUND(SUM(sales),2) total_sales,ROUND(SUM(profit),2) total_profit
FROM superstore GROUP BY segment ORDER BY total_sales DESC;

-- Customer
SELECT customer_name,COUNT(DISTINCT order_id) total_orders,
ROUND(SUM(sales),2) lifetime_sales,
ROUND(SUM(profit),2) lifetime_profit
FROM superstore
GROUP BY customer_name
ORDER BY lifetime_sales DESC
LIMIT 10;

-- Product
SELECT product_name,ROUND(SUM(sales),2) total_sales
FROM superstore
GROUP BY product_name
ORDER BY total_sales DESC
LIMIT 10;

SELECT product_name,ROUND(SUM(profit),2) total_profit
FROM superstore
GROUP BY product_name
ORDER BY total_profit
LIMIT 10;

-- Monthly Trend
SELECT order_year,order_month,
ROUND(SUM(sales),2) total_sales,
ROUND(SUM(profit),2) total_profit
FROM superstore
GROUP BY order_year,order_month
ORDER BY order_year,order_month;

-- Discount
SELECT discount,
ROUND(AVG(sales),2) avg_sales,
ROUND(AVG(profit),2) avg_profit
FROM superstore
GROUP BY discount
ORDER BY discount;

-- Shipping
SELECT ship_mode,
ROUND(AVG(shipping_days),2) avg_shipping_days
FROM superstore
GROUP BY ship_mode;

-- Top 5 Product per Category
WITH ranked_products AS(
SELECT category,product_name,SUM(sales) total_sales,
ROW_NUMBER() OVER(PARTITION BY category ORDER BY SUM(sales) DESC) rn
FROM superstore
GROUP BY category,product_name)
SELECT * FROM ranked_products WHERE rn<=5;

-- YoY Growth
WITH yearly_sales AS(
SELECT order_year,SUM(sales) total_sales
FROM superstore
GROUP BY order_year)
SELECT order_year,
ROUND(total_sales,2) total_sales,
ROUND(((total_sales-LAG(total_sales) OVER(ORDER BY order_year))
/LAG(total_sales) OVER(ORDER BY order_year))*100,2) yoy_growth
FROM yearly_sales;
