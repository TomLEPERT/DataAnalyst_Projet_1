-- KPI: Moyenne des jours pour payer par client
-- Description: Pour chaque client, calcul de la moyenne des jours entre orderDate et le 1er paiement >= orderDate
-- Params: aucun.

WITH delays AS (
    SELECT
        o.orderNumber,
        o.customerNumber,
        o.orderDate,
    (
        SELECT MIN(p.paymentDate)
        FROM payments p
        WHERE p.customerNumber = o.customerNumber
        AND p.paymentDate >= o.orderDate
    ) AS first_payment_date,
    DATEDIFF(
        (SELECT MIN(p.paymentDate) FROM payments p WHERE p.customerNumber = o.customerNumber AND p.paymentDate >= o.orderDate),
        o.orderDate
    ) AS days_to_pay
    FROM orders o
)
SELECT
    d.customerNumber,
    c.customerName,
    COUNT(d.orderNumber) AS nb_orders_considered,
    COUNT(CASE WHEN d.days_to_pay IS NOT NULL THEN 1 END) AS nb_orders_with_payment,
    ROUND(AVG(d.days_to_pay), 2) AS avg_days_to_pay
FROM delays d
LEFT JOIN customers c ON c.customerNumber = d.customerNumber
GROUP BY d.customerNumber, c.customerName
ORDER BY avg_days_to_pay DESC;