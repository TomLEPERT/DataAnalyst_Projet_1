-- KPI: Ticket moyen
-- ----------------------------------------------------------
-- Description:
-- Montant moyen des commandes sur la période sélectionné.
--
-- Paramètres:
-- :start_date, :end_date (format 'YYYY-MM-DD')
--
-- Usage:
-- remplacer les parametres avant exécution ou utiliser un script qui les injecte.
-- ou supprimer la ligne WHERE pour un panier global.
--
-- ----------------------------------------------------------

SELECT 
    ROUND(SUM(od.quantityOrdered * od.priceEach) / COUNT(DISTINCT o.orderNumber), 2) AS average_order_value
FROM orders o
JOIN orderdetails od ON o.orderNumber = od.orderNumber
WHERE o.orderDate BETWEEN :start_date AND :end_date;
