SELECT 
    c.customerNumber,
    c.customerName,
    SUM(od.quantityOrdered * od.priceEach) AS total_commandes,
    SUM(p.amount) AS total_paye,
    (SUM(od.quantityOrdered * od.priceEach) - SUM(p.amount)) AS montant_non_paye
FROM customers c
JOIN orders o 
    ON c.customerNumber = o.customerNumber
JOIN orderdetails od 
    ON o.orderNumber = od.orderNumber
JOIN payments p 
    ON c.customerNumber = p.customerNumber
GROUP BY c.customerNumber, c.customerName
ORDER BY montant_non_paye DESC;