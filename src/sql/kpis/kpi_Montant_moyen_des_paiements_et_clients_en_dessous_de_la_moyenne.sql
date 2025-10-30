-- KPI: Montant moyen des paiements (par paiement)
-- Description: Montant moyen d'une transaction (paiement)
-- Params: :start_date, :end_date  (format 'YYYY-MM-DD')
-- Usage: 
-- Remplacer les parametres ou les injecter depuis ton script
-- Ou supprimer la ligne WHERE

SELECT
    ROUND(AVG(p.amount), 2) AS avg_payment_amount
FROM payments p
WHERE p.paymentDate BETWEEN :start_date AND :end_date;

-- KPI: Clients en dessous de la moyenne (total payé vs moyenne des totaux par client)
-- Description: Identifie les clients dont le total payé sur la période est < moyenne des totaux par client
-- Params: :start_date, :end_date
-- Usage: 
-- Remplacer les parametres ou les injecter depuis ton script
-- Ou supprimer la ligne WHERE

WITH totals_by_customer AS (
    SELECT
        p.customerNumber,
        ROUND(SUM(p.amount), 2) AS total_paid
    FROM payments p
    WHERE p.paymentDate BETWEEN :start_date AND :end_date
    GROUP BY p.customerNumber
),
avg_total AS (
    SELECT ROUND(AVG(t.total_paid), 2) AS avg_total_per_customer
    FROM totals_by_customer t
)
SELECT
    t.customerNumber,
    c.customerName,
    t.total_paid,
    a.avg_total_per_customer
FROM totals_by_customer t
JOIN avg_total a ON 1=1
LEFT JOIN customers c ON c.customerNumber = t.customerNumber
WHERE t.total_paid < a.avg_total_per_customer
ORDER BY (a.avg_total_per_customer - t.total_paid) DESC;