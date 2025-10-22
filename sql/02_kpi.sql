--------------------------------------------------------------
--
-- SOMMAIRE
--
--------------------------------------------------------------

--------------------------------------------------------------
--
-- KPI: Performance des représentants commerciaux
-- KPI: Ratio commandes/paiements par représentant commercial
-- KPI: Performance des bureaux
-- KPI: Chiffre d affaires par mois et par region taux d evolution mensuel
-- KPI: Produits les plus vendus par catégorie
-- KPI: marge_brute_par_produit_et_par_categorie
-- KPI: Taux evolution mensuel ventes categorie
-- KPI: Ticket moyen
-- KPI: Taux de retour des clients (Repeat Customer Rate)
-- KPI: Clients générant le plus/moins de revenus
-- KPI: Moyenne des jours pour payer par client
-- KPI: Croissance trimestrielle du chiffre d'affaires
-- KPI: Ratio commandes/paiements par représentant commercial
-- KPI: Moyenne des jours pour payer par client
-- KPI: Stock des produits sous seuil critique
-- KPI: Taux d'écoulement (approximation si pas de snapshot/purchases)
--
-------------------------------------------------------------




--------------------------------------------------------------
--
-- KPI
--
--------------------------------------------------------------

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

-- Produits les plus vendus par catégorie
SELECT
    t.productLine AS categorie,
    t.productName AS produit,
    t.total_vendu
FROM (
    -- Sous-requête : total vendu par produit
    SELECT
        p.productLine,
        p.productName,
        SUM(od.quantityOrdered) AS total_vendu
    FROM products p
    JOIN orderdetails od ON p.productCode = od.productCode
    GROUP BY p.productLine, p.productName
) AS t
JOIN (
    -- Sous-requête : maximum vendu par catégorie
    SELECT
        productLine,
        MAX(total_vendu) AS max_vendu
    FROM (
        SELECT
            p.productLine,
            SUM(od.quantityOrdered) AS total_vendu
        FROM products p
        JOIN orderdetails od ON p.productCode = od.productCode
        GROUP BY p.productLine, p.productName
    ) AS s
    GROUP BY productLine
) AS m
ON t.productLine = m.productLine AND t.total_vendu = m.max_vendu
ORDER BY t.productLine, t.total_vendu DESC;
-- Produits les moins vendus par catégorie
SELECT
    t.productLine AS categorie,
    t.productName AS produit,
    t.total_vendu
FROM (
    -- Sous-requête : total vendu par produit
    SELECT
        p.productLine,
        p.productName,
        SUM(od.quantityOrdered) AS total_vendu
    FROM products p
    JOIN orderdetails od ON p.productCode = od.productCode
    GROUP BY p.productLine, p.productName
) AS t
JOIN (
    -- Sous-requête : minimum vendu par catégorie
    SELECT
        productLine,
        MIN(total_vendu) AS min_vendu
    FROM (
        SELECT
            p.productLine,
            SUM(od.quantityOrdered) AS total_vendu
        FROM products p
        JOIN orderdetails od ON p.productCode = od.productCode
        GROUP BY p.productLine, p.productName
    ) AS s
    GROUP BY productLine
) AS m
ON t.productLine = m.productLine AND t.total_vendu = m.min_vendu
ORDER BY t.productLine, t.total_vendu ASC;

-- KPI 6: marge_brute_par_produit_et_par_categorie
-- Description: dans un premier temps marge brute des produits par catégorie. dans un second temps, marge brute par produits et marge brute par catégorie.
-- Params: Aucun paramètre nécessaire
-- Usage: Visualiser la marge brute des produits par catégorie pour en déduire les produits par catégorie les plus et les moins rentables.
-- Egalement, visualiser la marge brute par produits pour en déduire les produits toute catégorie confondue, les plus ou moins rentables. 
-- Pour finir, visualiser la marge brute des catégories pour en déduire les catégories les plus ou moins rentables. 

-- Marge brute des produits par catégorie, du produit par catégorie le plus ou moins rentables
SELECT
  p.productCode,
  p.productName,
  pl.productLine,
  -- Marge brute du produit
  SUM(od.quantityOrdered * (od.priceEach - p.buyPrice)) AS marge_produit,
  -- Marge brute de la catégorie 
  (SELECT
     SUM(od2.quantityOrdered * (od2.priceEach - p2.buyPrice))
   FROM products p2
   JOIN orderdetails od2 ON p2.productCode = od2.productCode
   WHERE p2.productLine = p.productLine
  ) AS marge_categorie
FROM products p
JOIN productlines pl ON p.productLine = pl.productLine
JOIN orderdetails od ON p.productCode = od.productCode
GROUP BY p.productCode, p.productName, pl.productLine
ORDER BY marge_categorie DESC, marge_produit DESC;

-- Marge brute par produits du plus au moins rentables
SELECT 
    p.productCode,
    p.productName,
    pl.productLine,
    SUM(od.quantityOrdered * (od.priceEach - p.buyPrice)) AS marge_brute
FROM products p
JOIN productlines pl ON p.productLine = pl.productLine
JOIN orderdetails od ON p.productCode = od.productCode
GROUP BY p.productCode, p.productName, pl.productLine
ORDER BY marge_brute DESC;


-- Marge brute par catégorie du plus au moins rentables
SELECT 
    pl.productLine,
    SUM(od.quantityOrdered * (od.priceEach - p.buyPrice)) AS marge_brute
FROM products p
JOIN productlines pl ON p.productLine = pl.productLine
JOIN orderdetails od ON p.productCode = od.productCode
GROUP BY pl.productLine
ORDER BY marge_brute DESC;

-- kpi Taux evolution mensuel ventes categorie
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

-- KPI: Taux de retour des clients (Repeat Customer Rate)
-- Description: Pourcentage de clients ayant passé au moins deux commandes sur la période donnée
-- Params: :start_date, :end_date (format 'YYYY-MM-DD')
-- Usage: remplacer les parametres avant exécution ou utiliser un script qui les injecte.

SELECT 
    ROUND(
        (COUNT(DISTINCT CASE WHEN nb_orders > 1 THEN customerNumber END) 
         / COUNT(DISTINCT customerNumber)) * 100, 
        2
    ) AS repeat_customer_rate
FROM (
    SELECT 
        c.customerNumber,
        COUNT(o.orderNumber) AS nb_orders
    FROM customers c
    JOIN orders o ON c.customerNumber = o.customerNumber
    WHERE o.orderDate BETWEEN :start_date AND :end_date
    GROUP BY c.customerNumber
) AS t;

--  KPI :Clients générant le plus/moins de revenus
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

-- KPI: Moyenne des jours pour payer par client
-- Description: Pour chaque client, calcul de la moyenne des jours entre orderDate
--              et le 1er paiement dont paymentDate >= orderDate.
-- Params: aucun.

SELECT 
    SELECT 
    c.customerNumber,                   
    c.customerName,                      
    SUM(od.quantityOrdered * od.priceEach) AS total_commandes, 
    p.total_paye AS total_paye,          
    SUM(od.quantityOrdered * od.priceEach) - p.total_paye AS montant_non_paye 
FROM customers c                        
JOIN orders o 
    ON c.customerNumber = o.customerNumber  
JOIN orderdetails od 
    ON o.orderNumber = od.orderNumber     
LEFT JOIN (
    SELECT 
        customerNumber,               
        SUM(amount) AS total_paye        
    FROM payments
    GROUP BY customerNumber               
) p 
    ON c.customerNumber = p.customerNumber  
GROUP BY c.customerNumber, c.customerName, p.total_paye 
ORDER BY montant_non_paye DESC;

-- KPI: Croissance trimestrielle du chiffre d'affaires
-- Description:
--   Pour chaque trimestre, calcule le chiffre d'affaires total et le taux de croissance
--   par rapport au trimestre précédent.
-- Params:
--   :start_date - date de début de la période analysée
--   :end_date   - date de fin de la période analysée

WITH quarterly_sales AS (
    SELECT
        YEAR(o.orderDate) AS year,
        QUARTER(o.orderDate) AS quarter,
        SUM(od.quantityOrdered * od.priceEach) AS total_sales
    FROM orders o
    JOIN orderdetails od ON o.orderNumber = od.orderNumber
    WHERE o.orderDate BETWEEN :start_date AND :end_date
    GROUP BY YEAR(o.orderDate), QUARTER(o.orderDate)
)
SELECT 
    curr.year,
    curr.quarter,
    curr.total_sales,
    ROUND(
        ((curr.total_sales - prev.total_sales) / prev.total_sales) * 100,
        2
    ) AS growth_rate
FROM quarterly_sales curr
LEFT JOIN quarterly_sales prev
    ON (curr.year = prev.year AND curr.quarter = prev.quarter + 1)
    OR (curr.year = prev.year + 1 AND curr.quarter = 1 AND prev.quarter = 4)
ORDER BY curr.year, curr.quarter;

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

-- KPI: Moyenne des jours pour payer par client
-- Description: Pour chaque client, calcul de la moyenne des jours entre orderDate et le 1er paiement >= orderDate
-- Params: aucun.

WITH delays AS (
    SELECT
        o.orderNumber,
        o.customerNumber,
        o.orderDate,
    (
        SELECT MIN(p.paymentDate)
        FROM payments p
        WHERE p.customerNumber = o.customerNumber
        AND p.paymentDate >= o.orderDate
    ) AS first_payment_date,
    DATEDIFF(
        (SELECT MIN(p.paymentDate) FROM payments p WHERE p.customerNumber = o.customerNumber AND p.paymentDate >= o.orderDate),
        o.orderDate
    ) AS days_to_pay
    FROM orders o
)
SELECT
    d.customerNumber,
    c.customerName,
    COUNT(d.orderNumber) AS nb_orders_considered,
    COUNT(CASE WHEN d.days_to_pay IS NOT NULL THEN 1 END) AS nb_orders_with_payment,
    ROUND(AVG(d.days_to_pay), 2) AS avg_days_to_pay
FROM delays d
LEFT JOIN customers c ON c.customerNumber = d.customerNumber
GROUP BY d.customerNumber, c.customerName
ORDER BY avg_days_to_pay DESC;

-- Stock des produits sous seuil critique : 
--Identifier les produits dont le stock est faible pour éviter les ruptures.
-- J'ai regardé dans la table des produit pour vérifier les quantitiés de stock
-- J'ai fais le trie par quantité en ordre croissant  et cela permet de voir les quantité moins élevée au plus élevée.
-- Cela permettra d'anciper les cmmmandes afin d'éviter les ruptures. 

SELECT
	productCode,
    productName,
    quantityInStock
FROM 
	products
WHERE quantityInStock
ORDER BY quantityInStock ASC;

-- KPI: Taux d'écoulement (approximation si pas de snapshot/purchases)
-- Params: :start_date, :end_date
-- Usage :
-- remplacer les parametres avant exécution ou utiliser un script qui les injecte.
-- ou supprimer la ligne WHERE.

WITH sales AS (
  SELECT
    od.productCode,
    SUM(od.quantityOrdered) AS units_sold
  FROM orderdetails od
  JOIN orders o ON od.orderNumber = o.orderNumber
  WHERE o.orderDate BETWEEN :start_date AND :end_date
  GROUP BY od.productCode
)
SELECT
  p.productCode,
  p.productName,
  COALESCE(s.units_sold, 0) AS units_sold,
  p.quantityInStock AS qty_end,
  ROUND(p.quantityInStock + COALESCE(s.units_sold,0)/2, 2) AS approx_avg_inventory,
  CASE
    WHEN (p.quantityInStock + COALESCE(s.units_sold,0)/2) = 0 THEN NULL
    ELSE ROUND(s.units_sold / (p.quantityInStock + s.units_sold/2), 4)
  END AS turnover_rate,
  CASE
    WHEN s.units_sold = 0 OR (s.units_sold / NULLIF((p.quantityInStock + s.units_sold/2),0)) = 0 THEN NULL
    ELSE ROUND(DATEDIFF(:end_date, :start_date) / (s.units_sold / NULLIF((p.quantityInStock + s.units_sold/2),0)), 2)
  END AS estimated_days_of_inventory
FROM products p
LEFT JOIN sales s ON p.productCode = s.productCode
ORDER BY turnover_rate DESC;