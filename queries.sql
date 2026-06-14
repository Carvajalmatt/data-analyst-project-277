-- Cuenta el número total de clientes registrados en la tabla customers
SELECT COUNT(*) AS customers_count
FROM customers;

-- Reporte 1: Top 10 vendedores con mayor facturación total
SELECT
    TRIM(e.first_name) || ' ' || TRIM(e.last_name) AS seller,
    COUNT(s.sales_id) AS operations,
    FLOOR(SUM(s.quantity * p.price)) AS income
FROM employees e
JOIN sales s ON e.employee_id = s.sales_person_id
JOIN products p ON s.product_id = p.product_id
GROUP BY e.employee_id, e.first_name, e.last_name
ORDER BY income DESC
LIMIT 10;

-- Reporte 2: Vendedores con ingreso promedio por venta por debajo del promedio general
SELECT
    TRIM(e.first_name) || ' ' || TRIM(e.last_name) AS seller,
    FLOOR(AVG(s.quantity * p.price)) AS average_income
FROM employees e
JOIN sales s ON e.employee_id = s.sales_person_id
JOIN products p ON s.product_id = p.product_id
GROUP BY e.employee_id, e.first_name, e.last_name
HAVING AVG(s.quantity * p.price) < (
    SELECT AVG(s2.quantity * p2.price)
    FROM sales s2
    JOIN products p2 ON s2.product_id = p2.product_id
)
ORDER BY average_income ASC;

-- Reporte 3: Ingresos por vendedor y día de la semana
SELECT
    TRIM(e.first_name) || ' ' || TRIM(e.last_name) AS seller,
    LOWER(TO_CHAR(s.sale_date, 'day')) AS day_of_week,
    FLOOR(SUM(s.quantity * p.price)) AS income
FROM employees e
JOIN sales s ON e.employee_id = s.sales_person_id
JOIN products p ON s.product_id = p.product_id
GROUP BY e.employee_id, e.first_name, e.last_name, TO_CHAR(s.sale_date, 'day'), EXTRACT(DOW FROM s.sale_date)
ORDER BY EXTRACT(DOW FROM s.sale_date), seller;

-- Reporte 4: Clientes por grupo de edad
SELECT
    CASE
        WHEN age BETWEEN 16 AND 25 THEN '16-25'
        WHEN age BETWEEN 26 AND 40 THEN '26-40'
        ELSE '40+'
    END AS age_category,
    COUNT(*) AS age_count
FROM customers
GROUP BY age_category
ORDER BY age_category;

-- Reporte 5: Clientes únicos e ingresos por mes
SELECT
    TO_CHAR(s.sale_date, 'YYYY-MM') AS selling_month,
    COUNT(DISTINCT s.customer_id) AS total_customers,
    FLOOR(SUM(s.quantity * p.price)) AS income
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY selling_month
ORDER BY selling_month ASC;

-- Reporte 6: Clientes cuya primera compra fue durante una promoción (precio = 0)
WITH first_purchase AS (
    SELECT customer_id, MIN(sale_date) AS first_date
    FROM sales
    GROUP BY customer_id
)
SELECT DISTINCT
    TRIM(c.first_name) || ' ' || TRIM(c.last_name) AS customer,
    s.sale_date,
    TRIM(e.first_name) || ' ' || TRIM(e.last_name) AS seller
FROM sales s
JOIN customers c ON s.customer_id = c.customer_id
JOIN employees e ON s.sales_person_id = e.employee_id
JOIN products p ON s.product_id = p.product_id
JOIN first_purchase fp ON s.customer_id = fp.customer_id
    AND s.sale_date = fp.first_date
WHERE p.price = 0
ORDER BY s.customer_id;
