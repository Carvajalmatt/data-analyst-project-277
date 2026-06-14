-- Cuenta el número total de clientes registrados en la tabla customers
-- El resultado se muestra en una columna llamada customers_count
SELECT COUNT(*) AS customers_count
FROM customers;

-- Reporte 1: Top 10 vendedores con mayor facturación total
-- Une employees con sales y products para calcular ingresos (quantity * price)
-- Ordena de mayor a menor ingreso y limita a 10 resultados
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
-- Calcula el promedio de ingresos por venta de cada vendedor
-- Filtra solo los que están por debajo del promedio global
-- Ordena de menor a mayor ingreso promedio
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
-- Muestra el ingreso total de cada vendedor agrupado por día de la semana
-- El día se muestra en inglés en minúsculas (monday, tuesday, etc.)
-- Ordena primero por día de la semana y luego por nombre del vendedor
SELECT
    TRIM(e.first_name) || ' ' || TRIM(e.last_name) AS seller,
    LOWER(TO_CHAR(s.sale_date, 'day')) AS day_of_week,
    FLOOR(SUM(s.quantity * p.price)) AS income
FROM employees e
JOIN sales s ON e.employee_id = s.sales_person_id
JOIN products p ON s.product_id = p.product_id
GROUP BY e.employee_id, e.first_name, e.last_name, TO_CHAR(s.sale_date, 'day'), EXTRACT(DOW FROM s.sale_date)
ORDER BY EXTRACT(DOW FROM s.sale_date), seller;
