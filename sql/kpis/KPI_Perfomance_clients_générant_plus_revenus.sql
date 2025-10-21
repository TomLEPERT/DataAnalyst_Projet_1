--  KPI :Clients générant le plus/moins de revenus :
--  Identifier les clients générant le plus de revenus pour mieux les fidéliser


SELECT
    c.customerName,
    COUNT(p.paymentDate) AS 'nombre_Paiements',
    SUM(p.amount) AS 'total_des_revenues',
    AVG(p.amount) AS 'revenus_moyens_desclients'
FROM customers c
JOIN payments p ON c.customerNumber = p.customerNumber
GROUP BY c.customerName
ORDER BY total_des_revenues DESC;