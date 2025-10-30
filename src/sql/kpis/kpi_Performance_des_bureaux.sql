-- KPI 3 - Performance des bureaux
-- Description chiffre d'affaires généré par chaque bureau
-- Paramètre: aucun paramètre, calcul du chiffre d'affaires: SUM(od.quantityOrdered * od.priceEach)
-- Usage: Mesurer le chiffre d'affaires généré par chaque bureau


SELECT
	o.officeCode,
    o.city,
    o.country,
    SUM(od.quantityOrdered * od.priceEach) AS chiffre_affaires
FROM offices o
JOIN employees e ON o.officeCode = e.officeCode
JOIN customers c ON e.employeeNumber = c.salesRepEmployeeNumber
JOIN orders ord ON c.customerNumber = ord.customerNumber
JOIN orderdetails od ON ord.orderNumber = od.orderNumber
GROUP BY o.officeCode, o.city, o.country
ORDER BY chiffre_affaires DESC;