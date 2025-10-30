-- KPI: Performance des représentants commerciaux
-- Description: chiffre d’affaires généré par chaque représentant commercial
-- Params: Aucun paramètre nécessaire, calcul sur toutes les ventes enregistrées
-- Usage: exécuter directement pour obtenir le chiffre d’affaires total par Sales Rep

SELECT 
    e.employeeNumber,
    e.firstName,
    e.lastName,
    SUM(od.quantityOrdered * od.priceEach) AS total_sales
FROM employees e
JOIN customers c ON e.employeeNumber = c.salesRepEmployeeNumber
JOIN orders o ON c.customerNumber = o.customerNumber
JOIN orderdetails od ON o.orderNumber = od.orderNumber
WHERE e.jobTitle = 'Sales Rep'
GROUP BY e.employeeNumber, e.firstName, e.lastName
ORDER BY total_sales DESC;
