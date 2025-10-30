-- KPI: Chiffre d affaires par mois et par region taux d evolution mensuel
-- Description:
--   Pour chaque région et chaque mois, calcule le chiffre d'affaires total
--   et le taux d'évolution par rapport au mois précédent.
-- Params: aucun

WITH ca_mensuel AS (
    SELECT
        c.country AS region,
        YEAR(o.orderDate) AS annee,
        MONTH(o.orderDate) AS mois_num,
        SUM(od.quantityOrdered * od.priceEach) AS chiffre_affaires
    FROM orders o
    JOIN orderdetails od ON o.orderNumber = od.orderNumber
    JOIN customers c ON o.customerNumber = c.customerNumber
    GROUP BY c.country, YEAR(o.orderDate), MONTH(o.orderDate)
)
SELECT
    actuel.region,
    CONCAT(actuel.annee, '-', LPAD(actuel.mois_num, 2, '0')) AS mois,  -- affichage format YYYY-MM
    actuel.chiffre_affaires,
    ROUND(
        ((actuel.chiffre_affaires - avant.chiffre_affaires) / avant.chiffre_affaires) * 100,
        2
    ) AS taux_evolution
FROM ca_mensuel AS actuel
LEFT JOIN ca_mensuel AS avant
    ON actuel.region = avant.region
    AND (actuel.annee * 12 + actuel.mois_num - 1) = (avant.annee * 12 + avant.mois_num)
ORDER BY actuel.region, actuel.annee, actuel.mois_num;