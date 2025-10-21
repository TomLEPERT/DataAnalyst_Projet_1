-- KPI: Taux de retour des clients (Repeat Customer Rate)
-- Description: Pourcentage de clients ayant passé au moins deux commandes sur la période donnée
-- Params: :start_date, :end_date (format 'YYYY-MM-DD')
-- Usage: remplacer les parametres avant exécution ou utiliser un script qui les injecte.

SELECT 
    ROUND(
        (COUNT(DISTINCT CASE WHEN nb_orders > 1 THEN customerNumber END) 
         / COUNT(DISTINCT customerNumber)) * 100, 
        2
    ) AS repeat_customer_rate
FROM (
    SELECT 
        c.customerNumber,
        COUNT(o.orderNumber) AS nb_orders
    FROM customers c
    JOIN orders o ON c.customerNumber = o.customerNumber
    WHERE o.orderDate BETWEEN :start_date AND :end_date
    GROUP BY c.customerNumber
) AS t;