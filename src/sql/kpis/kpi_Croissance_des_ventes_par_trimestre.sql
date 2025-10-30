-- KPI: Croissance trimestrielle du chiffre d'affaires
-- Description:
--   Pour chaque trimestre, calcule le chiffre d'affaires total et le taux de croissance
--   par rapport au trimestre précédent.
-- Params:
--   :start_date - date de début de la période analysée
--   :end_date   - date de fin de la période analysée

WITH quarterly_sales AS (
    SELECT
        YEAR(o.orderDate) AS year,
        QUARTER(o.orderDate) AS quarter,
        SUM(od.quantityOrdered * od.priceEach) AS total_sales
    FROM orders o
    JOIN orderdetails od ON o.orderNumber = od.orderNumber
    WHERE o.orderDate BETWEEN :start_date AND :end_date
    GROUP BY YEAR(o.orderDate), QUARTER(o.orderDate)
)
SELECT 
    curr.year,
    curr.quarter,
    curr.total_sales,
    ROUND(
        ((curr.total_sales - prev.total_sales) / prev.total_sales) * 100,
        2
    ) AS growth_rate
FROM quarterly_sales curr
LEFT JOIN quarterly_sales prev
    ON (curr.year = prev.year AND curr.quarter = prev.quarter + 1)
    OR (curr.year = prev.year + 1 AND curr.quarter = 1 AND prev.quarter = 4)
ORDER BY curr.year, curr.quarter;