 Taux de commandes livrées en retard : 
-- Identifier les problèmes logistiques et améliorer les délais de livraison.
    
SELECT 
    o.orderNumber,
    o.customerNumber,
    c.country,
    o.orderDate,
    o.requiredDate,
    o.shippedDate,
    od.productCode,
    p.productName,
    od.quantityOrdered,
    od.priceEach,
    ROUND(
        (SELECT COUNT(*) FROM orders WHERE shippedDate > requiredDate) * 100.0 /
        (SELECT COUNT(*) FROM orders WHERE shippedDate IS NOT NULL),
        2
    ) AS taux_retard
FROM orders o
JOIN customers c ON o.customerNumber = c.customerNumber
JOIN orderdetails od ON o.orderNumber = od.orderNumber
JOIN products p ON od.productCode = p.productCode
WHERE o.shippedDate > o.requiredDate
ORDER BY o.shippedDate > o.requiredDate DESC;

