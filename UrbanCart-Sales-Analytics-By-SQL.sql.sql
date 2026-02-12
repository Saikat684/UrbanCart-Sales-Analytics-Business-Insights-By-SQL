
-- Q A 1

SELECT COUNT(*) AS total_orders      FROM "FactOrder";


-- Q A 2 

SELECT COUNT(DISTINCT customer_id) AS unique_customers  
FROM "FactOrder";


-- Q A 3

SELECT 
    c.city,
    COUNT(o.order_id) AS total_orders
FROM "FactOrder" o
JOIN "DimCustomers" c 
    ON o.customer_id::text = c.customers_id::text
GROUP BY c.city
ORDER BY total_orders DESC;


-- Q A 4

SELECT 
    COUNT(*) FILTER (WHERE order_count > 1) * 100.0 / COUNT(*) AS repeat_customer_percentage
FROM (
    SELECT customer_id, COUNT(*) AS order_count
    FROM "FactOrder"
    GROUP BY customer_id
) t;


-- Q A 5

SELECT 
    DATE_TRUNC('month', "order_date") AS month,
    COUNT("order_id") AS total_orders
FROM "FactOrder"
GROUP BY DATE_TRUNC('month', "order_date")
ORDER BY month;

SELECT 
    p.product_id,
    p.product_name,
    p.stock,
    SUM(oi."Quantity"::int) AS total_sold
FROM "DimProduct" p
JOIN "FactOrderItems" oi 
    ON p.product_id = oi.product_id
GROUP BY 
    p.product_id, 
    p.product_name, 
    p.stock
HAVING 
    SUM(oi."Quantity"::int) > p.stock::int
ORDER BY 
    total_sold DESC;


-- Q A 6

SELECT 
    SUM(oi."Quantity"::int * p."unit_price"::numeric) AS total_revenue
FROM "FactOrderItems" oi
JOIN "DimProduct" p
    ON oi.product_id = p.product_id;


-- Q A 7 

SELECT 
    p."category",
    SUM(oi."Quantity"::int * p."unit_price"::numeric) AS category_revenue
FROM "FactOrderItems" oi
JOIN "DimProduct" p
    ON oi.product_id = p.product_id
GROUP BY p."category"
ORDER BY category_revenue DESC;


-- Q A 8

SELECT 
    p.product_id,
    p.product_name,
    SUM(oi."Quantity"::int * p."unit_price"::numeric) AS product_revenue
FROM "FactOrderItems" oi
JOIN "DimProduct" p
    ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY product_revenue DESC
limit 10 ;


-- Q A 9

-- Average Order Value (AOV) and Average Basket Size

SELECT 
    AVG(order_total) AS average_order_value,
    AVG(basket_size) AS average_basket_size
FROM (
    SELECT 
        oi."order_id",
        SUM(oi."Quantity"::int * p."unit_price"::numeric) AS order_total,
        SUM(oi."Quantity"::int) AS basket_size
    FROM "FactOrderItems" oi
    JOIN "DimProduct" p
        ON oi.product_id = p.product_id
    GROUP BY oi."order_id"
) sub_table;


-- Q A  10

SELECT 
    p.product_id,
    p.product_name,
    p.stock,
    SUM(oi."Quantity"::int) AS total_sold
FROM "DimProduct" p
JOIN "FactOrderItems" oi
    ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name, p.stock
HAVING SUM(oi."Quantity"::int) >= p.stock::int
ORDER BY total_sold DESC;


-- Q A  11

SELECT 
    c.customers_id,
    c.full_name,
    SUM(oi."Quantity"::numeric * p.unit_price::numeric) AS total_revenue
FROM "DimCustomers" c
JOIN "FactOrder" o 
    ON c.customers_id::text = o.customer_id
JOIN "FactOrderItems" oi 
    ON o.order_id = oi.order_id::text
JOIN "DimProduct" p
    ON oi.product_id = p.product_id
GROUP BY 
    c.customers_id, 
    c.full_name
ORDER BY 
    total_revenue DESC
limit 20;


-- Q A 12

SELECT 
    AVG(order_product_count) AS avg_products_per_order
FROM (
    SELECT 
        o.order_id,
        SUM(oi."Quantity"::numeric) AS order_product_count
    FROM "FactOrder" o
    JOIN "FactOrderItems" oi 
        ON o.order_id = oi.order_id::text
    GROUP BY 
        o.order_id
)


-- Q A 13

SELECT 
    c.gender,
    p.category,
    SUM(oi."Quantity"::numeric) AS total_quantity,
    SUM(oi."Quantity"::numeric * p.unit_price::numeric) AS total_revenue
FROM "DimCustomers" c
JOIN "FactOrder" o 
    ON c.customers_id::text = o.customer_id
JOIN "FactOrderItems" oi 
    ON o.order_id = oi.order_id::text
JOIN "DimProduct" p
    ON oi.product_id = p.product_id
GROUP BY 
    c.gender,
    p.category
ORDER BY 
    p.category,
    total_revenue DESC;


-- Q A 14

SELECT 
    c.city,
    AVG(order_total) AS avg_order_value
FROM (
    SELECT 
        o.order_id,
        o.customer_id,
        SUM(oi."Quantity"::numeric * p.unit_price::numeric) AS order_total
    FROM "FactOrder" o
    JOIN "FactOrderItems" oi 
        ON o.order_id = oi.order_id::text
    JOIN "DimProduct" p
        ON oi.product_id = p.product_id
    GROUP BY o.order_id, o.customer_id
) AS order_summaries
JOIN "DimCustomers" c
    ON order_summaries.customer_id = c.customers_id::text
GROUP BY c.city
ORDER BY avg_order_value DESC;


-- Q A 15

SELECT 
    DATE_PART('month', AGE(o.order_date, c."created_at"::date)) AS months_since_signup,
    COUNT(o.order_id) AS total_orders,
    SUM(oi."Quantity"::numeric * p.unit_price::numeric) AS total_revenue,
    AVG(oi."Quantity"::numeric * p.unit_price::numeric) AS avg_order_value
FROM "FactOrder" o
JOIN "DimCustomers" c
    ON o.customer_id = c.customers_id::text
JOIN "FactOrderItems" oi
    ON o.order_id = oi.order_id::text
JOIN "DimProduct" p
    ON oi.product_id = p.product_id
GROUP BY months_since_signup
ORDER BY months_since_signup;


-- Q A 16

SELECT 
method,
COUNT(*) AS usage_count
FROM "FactPayment"
GROUP BY method
ORDER BY usage_count DESC;


-- Q A 17 

SELECT 
    p.method AS payment_method,
    o.status AS order_status,
    COUNT(*) AS total_orders
FROM "FactOrder" o
JOIN "FactPayment" p ON o.order_id = p.order_id
GROUP BY p.method, o.status
ORDER BY p.method, o.status;


-- Q A 18

SELECT 
    c.city,
    p.method AS payment_method,
    COUNT(*) AS total_orders
FROM "FactOrder" o
JOIN "FactPayment" p
    ON o.order_id = p.order_id
JOIN "DimCustomers" c
    ON o.customer_id::text = c.customers_id::text   
GROUP BY c.city, p.method
ORDER BY c.city, total_orders DESC;


-- Q A 19 

WITH order_totals AS (
    SELECT 
        fo.order_id,
        fp.method AS payment_method,
        SUM(dp.unit_price) AS order_total
    FROM "FactOrderItems" fo
    JOIN "DimProduct" dp
        ON fo.product_id = dp.product_id
    JOIN "FactPayment" fp
        ON fo.order_id::text = fp.order_id
    GROUP BY fo.order_id, fp.method
),
avg_total AS (
    SELECT AVG(order_total) AS avg_order_value
    FROM order_totals
)

SELECT 
    payment_method,
    COUNT(*) AS high_value_orders,
    AVG(order_total) AS avg_high_value_order
FROM order_totals
WHERE order_total > (SELECT avg_order_value FROM avg_total)
GROUP BY payment_method
ORDER BY high_value_orders DESC;


-- Q A  20 

WITH items_per_order AS (
    SELECT
        fo.order_id,
        fp.method AS payment_method,
        COUNT(fo.product_id) AS total_items
    FROM "FactOrderItems" fo
    JOIN "FactPayment" fp
        ON fo.order_id::text = fp.order_id
    GROUP BY fo.order_id, fp.method
)

SELECT
    payment_method,
    AVG(total_items)::numeric(10,2) AS avg_items_per_order
FROM items_per_order
GROUP BY payment_method
ORDER BY avg_items_per_order DESC;


-- Q A 21

SELECT 
    fo1.product_id AS product_1_id,
    dp1.product_name AS product_1_name,
    fo2.product_id AS product_2_id,
    dp2.product_name AS product_2_name,
    COUNT(*) AS times_ordered_together
FROM "FactOrderItems" fo1
JOIN "FactOrderItems" fo2
    ON fo1.order_id = fo2.order_id
    AND fo1.product_id < fo2.product_id  
JOIN "DimProduct" dp1
    ON fo1.product_id = dp1.product_id
JOIN "DimProduct" dp2
    ON fo2.product_id = dp2.product_id
GROUP BY 
    fo1.product_id, dp1.product_name,
    fo2.product_id, dp2.product_name
ORDER BY times_ordered_together DESC
LIMIT 10;   

 

-- Q A 22 

SELECT 
    fo1.product_id AS product_1_id,
    dp1.product_name AS product_1_name,
    fo2.product_id AS product_2_id,
    dp2.product_name AS product_2_name,
    COUNT(*) AS times_ordered_together
FROM "FactOrderItems" fo1
JOIN "FactOrderItems" fo2
    ON fo1.order_id = fo2.order_id
    AND fo1.product_id < fo2.product_id  
JOIN "DimProduct" dp1
    ON fo1.product_id = dp1.product_id
JOIN "DimProduct" dp2
    ON fo2.product_id = dp2.product_id
GROUP BY 
    fo1.product_id, dp1.product_name,
    fo2.product_id, dp2.product_name
ORDER BY times_ordered_together DESC
LIMIT 10;  


-- Q A  23

WITH order_totals AS (
    SELECT 
        fo.order_id,
        SUM(dp.unit_price) AS order_total
    FROM "FactOrderItems" fo
    JOIN "DimProduct" dp
        ON fo.product_id = dp.product_id
    GROUP BY fo.order_id
),
product_pairs AS (
    SELECT 
        fo1.order_id,
        fo1.product_id AS product_1_id,
        dp1.product_name AS product_1_name,
        fo2.product_id AS product_2_id,
        dp2.product_name AS product_2_name,
        ot.order_total
    FROM "FactOrderItems" fo1
    JOIN "FactOrderItems" fo2
        ON fo1.order_id = fo2.order_id
        AND fo1.product_id < fo2.product_id  
    JOIN "DimProduct" dp1
        ON fo1.product_id = dp1.product_id
    JOIN "DimProduct" dp2
        ON fo2.product_id = dp2.product_id
    JOIN order_totals ot
        ON fo1.order_id = ot.order_id
)
SELECT
    product_1_id,
    product_1_name,
    product_2_id,
    product_2_name,
    COUNT(*) AS times_ordered_together,
    AVG(order_total)::numeric(10,2) AS avg_order_value
FROM product_pairs
GROUP BY product_1_id, product_1_name, product_2_id, product_2_name
ORDER BY avg_order_value DESC, times_ordered_together DESC
LIMIT 10;  

 

-- Q A  24

WITH order_totals AS (
    SELECT 
        fo.order_id,
        SUM(dp.unit_price) AS order_total
    FROM "FactOrderItems" fo
    JOIN "DimProduct" dp
        ON fo.product_id = dp.product_id
    GROUP BY fo.order_id
),
product_pairs AS (
    SELECT 
        fo1.order_id,
        fo1.product_id AS product_1_id,
        dp1.product_name AS product_1_name,
        fo2.product_id AS product_2_id,
        dp2.product_name AS product_2_name,
        ot.order_total
    FROM "FactOrderItems" fo1
    JOIN "FactOrderItems" fo2
        ON fo1.order_id = fo2.order_id
        AND fo1.product_id < fo2.product_id  -- avoids self-pairing & duplicates
    JOIN "DimProduct" dp1
        ON fo1.product_id = dp1.product_id
    JOIN "DimProduct" dp2
        ON fo2.product_id = dp2.product_id
    JOIN order_totals ot
        ON fo1.order_id = ot.order_id
)
SELECT
    product_1_id,
    product_1_name,
    product_2_id,
    product_2_name,
    COUNT(*) AS times_ordered_together,
    AVG(order_total)::numeric(10,2) AS avg_order_value
FROM product_pairs
GROUP BY product_1_id, product_1_name, product_2_id, product_2_name
HAVING COUNT(*) >= 5  -- only pairs ordered at least 5 times
ORDER BY avg_order_value DESC, times_ordered_together DESC
LIMIT 10;  -- top 10 recommended bundles


-- Q A  25

WITH order_totals AS (
    SELECT 
        fo.order_id,
        SUM(dp.unit_price) AS order_total
    FROM "FactOrderItems" fo
    JOIN "DimProduct" dp
        ON fo.product_id = dp.product_id
    GROUP BY fo.order_id
),
product_pairs AS (
    SELECT 
        fo1.order_id,
        fo1.product_id AS product_1_id,
        dp1.product_name AS product_1_name,
        fo2.product_id AS product_2_id,
        dp2.product_name AS product_2_name,
        ot.order_total
    FROM "FactOrderItems" fo1
    JOIN "FactOrderItems" fo2
        ON fo1.order_id = fo2.order_id
        AND fo1.product_id < fo2.product_id  -- avoids self-pairing & duplicates
    JOIN "DimProduct" dp1
        ON fo1.product_id = dp1.product_id
    JOIN "DimProduct" dp2
        ON fo2.product_id = dp2.product_id
    JOIN order_totals ot
        ON fo1.order_id = ot.order_id
)
SELECT
    product_1_id,
    product_1_name,
    product_2_id,
    product_2_name,
    COUNT(*) AS times_ordered_together,
    AVG(order_total)::numeric(10,2) AS avg_order_value
FROM product_pairs
GROUP BY product_1_id, product_1_name, product_2_id, product_2_name
HAVING COUNT(*) >= 5  -- only frequent pairs
ORDER BY times_ordered_together DESC, avg_order_value DESC
LIMIT 20;  -- top 20 recommended cross-selling pairs

