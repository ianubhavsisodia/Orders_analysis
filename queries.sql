--find top 10 highest reveue generating products 

SELECT TOP 10 
    product_id, 
    SUM(sale_price) AS sales
FROM 
    data_orders
GROUP BY 
    product_id
ORDER BY 
    sales DESC;





--find top 5 highest selling products in each region

WITH product_sales AS (
    SELECT 
        region,
        product_id,
        SUM(sale_price) AS sales,
        ROW_NUMBER() OVER (PARTITION BY region ORDER BY SUM(sale_price) DESC) AS rn
    FROM 
        data_orders
    GROUP BY 
        region, product_id
)
SELECT 
    region,
    product_id,
    sales
FROM 
    product_sales
WHERE 
    rn <= 5
ORDER BY 
    region, sales DESC;





--find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023

SELECT 
    MONTH(order_date) AS order_month,
    SUM(CASE WHEN YEAR(order_date) = 2022 THEN sale_price ELSE 0 END) AS sales_2022,
    SUM(CASE WHEN YEAR(order_date) = 2023 THEN sale_price ELSE 0 END) AS sales_2023
FROM 
    data_orders
WHERE 
    YEAR(order_date) IN (2022, 2023)
GROUP BY 
    MONTH(order_date)
ORDER BY 
    order_month;





--for each category which month had highest sales 

WITH sales_per_month AS (
    SELECT 
        category,
        FORMAT(order_date, 'yyyy-MM') AS order_year_month,
        SUM(sale_price) AS total_sales
    FROM 
        data_orders
    GROUP BY 
        category, FORMAT(order_date, 'yyyy-MM')
)
SELECT 
    category,
    order_year_month,
    total_sales
FROM 
    sales_per_month AS spm
WHERE 
    total_sales = (
        SELECT MAX(total_sales)
        FROM sales_per_month
        WHERE category = spm.category
    );







--which 5 sub categories had highest growth by profit in 2023 compare to 2022

WITH sales_cte AS (
    SELECT 
        sub_category,
        year(order_date) AS order_year,
        SUM(sale_price) AS total_sales
    FROM 
        data_orders
    GROUP BY 
        sub_category, year(order_date)
),
growth_cte AS (
    SELECT 
        sub_category,
        SUM(CASE WHEN order_year = 2022 THEN total_sales ELSE 0 END) AS sales_2022,
        SUM(CASE WHEN order_year = 2023 THEN total_sales ELSE 0 END) AS sales_2023,
        SUM(CASE WHEN order_year = 2023 THEN total_sales ELSE 0 END) - SUM(CASE WHEN order_year = 2022 THEN total_sales ELSE 0 END) AS sales_growth
    FROM 
        sales_cte
    GROUP BY 
        sub_category
)
SELECT 
    TOP 5 sub_category, sales_2022, sales_2023, sales_growth
FROM 
    growth_cte
ORDER BY 
    sales_growth DESC;





-- year over year sales growth
WITH category_sales AS (
    SELECT 
        category,
        YEAR(order_date) AS order_year,
        SUM(sale_price) AS total_sales
    FROM 
        data_orders
    GROUP BY 
        category, YEAR(order_date)
)
SELECT 
--COALESCE is a SQL function used to return the first non-null value from a list of expressions. 
--It is especially useful when you want to handle NULL values and replace them with a default value (like 0) in query results.
    cs2023.category,
    COALESCE(cs2022.total_sales, 0) AS sales_2022,
    cs2023.total_sales AS sales_2023,
    CASE 
        WHEN COALESCE(cs2022.total_sales, 0) = 0 THEN NULL  -- Avoid division by zero
        ELSE ((cs2023.total_sales - cs2022.total_sales) / cs2022.total_sales) * 100 
    END AS sales_growth_percentage
FROM 
    category_sales cs2023
LEFT JOIN 
    category_sales cs2022
    ON cs2023.category = cs2022.category
    AND cs2022.order_year = 2022
WHERE 
    cs2023.order_year = 2023
ORDER BY 
    sales_growth_percentage DESC;



-- Monthly Sales Growth
WITH monthly_sales AS (
    SELECT 
        FORMAT(order_date, 'yyyy-MM') AS year_month,
        YEAR(order_date) AS order_year,
        MONTH(order_date) AS order_month,
        SUM(sale_price) AS total_sales
    FROM 
        data_orders
    GROUP BY 
        FORMAT(order_date, 'yyyy-MM'),
        YEAR(order_date),
        MONTH(order_date)
),
ranked_sales AS (
    SELECT 
        year_month,
        order_year,
        order_month,
        total_sales,
--The LAG function in SQL is a window function that allows to access data from a preceding row in the result set without the need for a self-join or subquery
        LAG(total_sales) OVER (ORDER BY order_year, order_month) AS previous_month_sales
    FROM 
        monthly_sales
)
SELECT 
    year_month,
    total_sales,
    previous_month_sales,
    CASE 
        WHEN previous_month_sales IS NULL THEN NULL
        ELSE ((total_sales - previous_month_sales) / previous_month_sales) * 100 
    END AS monthly_growth_percentage
FROM 
    ranked_sales
ORDER BY 
    order_year, order_month;
