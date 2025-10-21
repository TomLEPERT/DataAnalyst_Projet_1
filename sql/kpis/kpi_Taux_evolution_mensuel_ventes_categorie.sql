-- Création d'une CTE (Common Table Expression) du nom de monthly
-- Elle va contenir le chiffre d'affaire mensuel par catégorie


WITH monthly AS (
    SELECT
        -- Catégorie de chaque produit
        p.productLine,
        -- On transforme la date en format année mois
        DATE_FORMAT(o.orderDate, '%Y-%m') AS mois,
        -- On calcule le montant total vendu par mois
        SUM(od.quantityOrdered * od.priceEach) AS monthly_revenue
    -- On join les tables order, orderdetails, products
    FROM orders o
    JOIN orderdetails od ON o.orderNumber = od.orderNumber
    JOIN products p ON od.productCode = p.productCode
    -- On ignore les commande sans date 
    WHERE o.orderDate IS NOT NULL
    -- On regroupe les ventes par catégorie de produit et par mois
    GROUP BY p.productLine, DATE_FORMAT(o.orderDate, '%Y-%m')
    -- Chaque ligne du résultat représente une catégorie + un mois. 
    -- Table CTE monthly avec productLine | mois | monthly_revenue
)
-- On exploite la table monthly
-- On selectionne productLine | mois | monthly_revenue
SELECT
    productLine,
    mois,
    monthly_revenue,
    -- LAG fonction qui regarde la ligne précédente
    -- LAG(monthly_revenue), donne la valeur du mois précédent
    -- PARTITION BY productLine, on sépare le calcul par catégorie
    -- ORDER BY mois, on trie les mois dans l’ordre chronologique
    LAG(monthly_revenue) OVER (PARTITION BY productLine ORDER BY mois) AS prev_month_revenue,
    -- On calcule la variation en % entre le mois actuel et le mois précédent
    ROUND(
        -- CASE WHEN ... THEN ... ELSE ... END, évite les erreurs de division, si le mois précédent est NULL ou 0, on renvoie NULL
        CASE WHEN LAG(monthly_revenue) OVER (PARTITION BY productLine ORDER BY mois) IS NULL
            OR LAG(monthly_revenue) OVER (PARTITION BY productLine ORDER BY mois) = 0
        THEN NULL
        ELSE (monthly_revenue - LAG(monthly_revenue) OVER (PARTITION BY productLine ORDER BY mois))
            / LAG(monthly_revenue) OVER (PARTITION BY productLine ORDER BY mois) * 100
        END, 2) AS pct_mom_change
-- On affiche les résultats de la CTE monthly
-- On trie les lignes par catégorie, puis par mois croissant.
FROM monthly
ORDER BY productLine, mois;