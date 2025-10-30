-- KPI: Ratio commandes/paiements par représentant commercial
-- ----------------------------------------------------------
-- Description:
-- Ce KPI permet d’évaluer la performance de chaque représentant commercial
-- en comparant le montant total des commandes passées par ses clients
-- avec le montant total des paiements réellement reçus.
-- Il met en évidence les écarts potentiels entre les ventes facturées et
-- les encaissements effectifs, indiquant ainsi la qualité du suivi client
-- et la rapidité des règlements.
--
-- Formule:
--   (Total des paiements reçus / Total des commandes passées) * 100
--
-- Interprétation:
--   - 100% : Tous les paiements ont été reçus pour les commandes émises.
--   - <100% : Des paiements manquent ou sont en attente.
--   - >100% : Des paiements anticipés ou corrections comptables.
--
-- Paramètres:
--   Aucun (calcul sur l’ensemble des ventes enregistrées).
--
-- Usage:
--   Utilisé dans les tableaux de bord de performance commerciale pour
--   identifier les représentants ayant des écarts significatifs entre
--   les commandes et les paiements.
--
-- ----------------------------------------------------------

SELECT
    e.employeeNumber AS rep_id,
    CONCAT(e.firstName, ' ', e.lastName) AS rep_name,
    COALESCE(o_tot.total_orders, 0) AS total_orders_amount,
    COALESCE(p_tot.total_payments, 0) AS total_payments_amount,
    ROUND( COALESCE(p_tot.total_payments, 0) / o_tot.total_orders * 100, 2 ) AS pct_payments_over_orders
FROM employees e
LEFT JOIN (
    SELECT
        c.salesRepEmployeeNumber AS rep_emp_no,
        SUM(od.quantityOrdered * od.priceEach) AS total_orders
    FROM orders o
    JOIN orderdetails od ON o.orderNumber = od.orderNumber
    JOIN customers c ON o.customerNumber = c.customerNumber
    GROUP BY c.salesRepEmployeeNumber
) o_tot ON e.employeeNumber = o_tot.rep_emp_no
LEFT JOIN (
    SELECT
        c.salesRepEmployeeNumber AS rep_emp_no,
        SUM(p.amount) AS total_payments
    FROM customers c
    JOIN payments p ON c.customerNumber = p.customerNumber
    GROUP BY c.salesRepEmployeeNumber
) p_tot ON e.employeeNumber = p_tot.rep_emp_no
WHERE COALESCE(o_tot.total_orders, 0) > 0
ORDER BY pct_payments_over_orders ASC;