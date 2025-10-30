--KPI 016 Durée moyenne de traitement des commandes + commandes au-dessus de la moyenne
--Description :- Mesurer l’efficacité opérationnelle en analysant le temps entre la date de commande et la date d’expédition.
SELECT 
    orderNumber,
    orderDate,
    shippedDate,
    DATEDIFF(shippedDate, orderDate) AS duree_traitement,
    (SELECT AVG(DATEDIFF(shippedDate, orderDate)) FROM orders) AS moyenne_globale
FROM orders
WHERE DATEDIFF(shippedDate, orderDate) > (
    SELECT AVG(DATEDIFF(shippedDate, orderDate)) FROM orders
)
ORDER BY duree_traitement DESC;
