-- KPI: Taux d'écoulement (approximation si pas de snapshot/purchases)
-- Params: :start_date, :end_date
-- Usage :
-- remplacer les parametres avant exécution ou utiliser un script qui les injecte.
-- ou supprimer la ligne WHERE.

WITH sales AS (
  SELECT
    od.productCode,
    SUM(od.quantityOrdered) AS units_sold
  FROM orderdetails od
  JOIN orders o ON od.orderNumber = o.orderNumber
  WHERE o.orderDate BETWEEN :start_date AND :end_date
  GROUP BY od.productCode
)
SELECT
  p.productCode,
  p.productName,
  COALESCE(s.units_sold, 0) AS units_sold,
  p.quantityInStock AS qty_end,
  ROUND(p.quantityInStock + COALESCE(s.units_sold,0)/2, 2) AS approx_avg_inventory,
  CASE
    WHEN (p.quantityInStock + COALESCE(s.units_sold,0)/2) = 0 THEN NULL
    ELSE ROUND(s.units_sold / (p.quantityInStock + s.units_sold/2), 4)
  END AS turnover_rate,
  CASE
    WHEN s.units_sold = 0 OR (s.units_sold / NULLIF((p.quantityInStock + s.units_sold/2),0)) = 0 THEN NULL
    ELSE ROUND(DATEDIFF(:end_date, :start_date) / (s.units_sold / NULLIF((p.quantityInStock + s.units_sold/2),0)), 2)
  END AS estimated_days_of_inventory
FROM products p
LEFT JOIN sales s ON p.productCode = s.productCode
ORDER BY turnover_rate DESC;