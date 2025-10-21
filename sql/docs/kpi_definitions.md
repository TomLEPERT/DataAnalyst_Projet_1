# Catalogue des KPI du projet

Ce document regroupe les définitions des indicateurs (KPI) calculés à partir de la base de données MySQL.

---

## KPI 1 — Performance des représentant cormerciaux

**Nom interne :** `kpi_performance_representant_comerciaux`  
**Fichier SQL :** `sql/kpis/kpi_performance_representant_comerciaux.sql`  
**Objectif métier :**
> Calculer le chiffre d’affaires généré par chaque employé chargé des ventes et le trie par ordre décroissant.

**Formule / logique de calcul :**
```sql
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
```


## KPI 2 — Ratio commandes/paiements par représentant commercial

**Nom interne :** `kpi_Ratio_commandes_paiements_par_representant_cormercial`  
**Fichier SQL :** `sql/kpis/kpi_Ratio_commandes_paiements_par_representant_cormercial.sql`  
**Objectif métier :**
Mesurer l’efficacité commerciale et financière de chaque représentant en comparant le montant total des commandes passées par leurs clients avec le montant total des paiements réellement reçus.
Il met en évidence :
    les écarts potentiels entre ventes enregistrées et paiements encaissés,
    les retards ou impayés selon les portefeuilles clients,
    et permet de suivre la performance du recouvrement et la qualité de la relation client.

Un ratio proche de 100 % indique une bonne gestion du suivi client et un encaissement complet des commandes, tandis qu’un ratio faible peut signaler des problèmes de facturation, de solvabilité ou de suivi commercial.

**Formule / logique de calcul :**
```sql
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
```

## KPI 3 - Performance des bureaux

**Nom Interne:** `kpi_performance_des_bureaux`
**Fichier SQL :**`sql/kpis/kpi_performance_des_bureaux.sql`
**Objectif métier :**
> Mesurer le chiffre d'affaires généré par chaque bureau afin d'identifier les bureaux les plus performants sur le mois.

 **Formule / logique de calcul :**
 ```sql
SELECT
	o.officeCode,
    o.city,
    o.country,
    SUM(od.quantityOrdered * od.priceEach) AS total_sales
FROM offices o
JOIN employees e ON o.officeCode = e.officeCode
JOIN customers c ON e.employeeNumber = c.salesRepEmployeeNumber
JOIN orders ord ON c.customerNumber = ord.customerNumber
JOIN orderdetails od ON ord.orderNumber = od.orderNumber
GROUP BY o.officeCode, o.city, o.country
ORDER BY total_sales DESC;
```

## KPI 4 Chiffre_d_affaires_par_mois_et_par_region_taux_d_evolution_mensuel.sql

**Nom interne:** `kpi_Chiffre_d_affaires_par_mois_et_par_region_taux_d_evolution_mensuel`
**Fichier sql:** `sql/kpis/kpi_Chiffre_d_affaires_par_mois_et_par_region_taux_d_evolution_mensuel`
**Objectif métier:**
>  Suivre les revenus générés par région et par mois pour identifier les tendandances géographique
Lorsqu'il n'y a pas de chiffres d'affaires générés sur le mois précédent le taux d'évolution mensuel sera nul. 

**Formule / logique de calcul:**
```sql
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
```

## KPI 7 — kpi_Taux_evolution_mensuel_ventes_categorie

**Nom interne :** `kpi_Taux_evolution_mensuel_ventes_categorie`  
**Fichier SQL :** `sql/kpis/kpi_Taux_evolution_mensuel_ventes_categorie.sql`  
**Objectif métier :**
Mesure la variation mensuelle du chiffre d’affaires par ligne de produit. Elle fournit le taux d’évolution (en %) du revenu d’un mois à l’autre pour chaque catégorie de produit, afin de suivre la dynamique commerciale au niveau catégorie.

**Formule / logique de calcul :**
```sql
WITH monthly AS (
    SELECT
        p.productLine,
        DATE_FORMAT(o.orderDate, '%Y-%m') AS mois,
        SUM(od.quantityOrdered * od.priceEach) AS monthly_revenue
    FROM orders o
    JOIN orderdetails od ON o.orderNumber = od.orderNumber
    JOIN products p ON od.productCode = p.productCode
    WHERE o.orderDate IS NOT NULL
    GROUP BY p.productLine, DATE_FORMAT(o.orderDate, '%Y-%m')
)
SELECT
    productLine,
    mois,
    monthly_revenue,
    LAG(monthly_revenue) OVER (PARTITION BY productLine ORDER BY mois) AS prev_month_revenue,
    ROUND(
        CASE WHEN LAG(monthly_revenue) OVER (PARTITION BY productLine ORDER BY mois) IS NULL
            OR LAG(monthly_revenue) OVER (PARTITION BY productLine ORDER BY mois) = 0
        THEN NULL
        ELSE (monthly_revenue - LAG(monthly_revenue) OVER (PARTITION BY productLine ORDER BY mois))
            / LAG(monthly_revenue) OVER (PARTITION BY productLine ORDER BY mois) * 100
        END, 2) AS pct_mom_change
FROM monthly
ORDER BY productLine, mois;
```

## KPI 8 — Ticket moyen

**Nom interne :** `kpi_Ticket_moyen`  
**Fichier SQL :** `sql/kpis/kpi_Ticket_moyen.sql`  
**Objectif métier :**
Calcule le panier moyen des commande sur une periode donnée.

**Formule / logique de calcul :**
```sql
SELECT 
    ROUND(SUM(od.quantityOrdered * od.priceEach) / COUNT(DISTINCT o.orderNumber), 2) AS average_order_value
FROM orders o
JOIN orderdetails od ON o.orderNumber = od.orderNumber
WHERE o.orderDate BETWEEN :start_date AND :end_date;
```
## KPI 9 — Taux de retour des clients

**Nom interne :** `kpi_Taux_de_retour_des_clients`  
**Fichier SQL :** `sql/kpis/kpi_Taux_de_retour_des_clients.sql`  
**Objectif métier :**
Calcule le pourcentage de client qui ont passer une deuxième commande dans une periode donnée.

**Formule / logique de calcul :**
```sql
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
```

## KPI 10 — Client générant plus de revenus

**Nom interne :** `KPI_Perfomance_clients_générant_plus_revenus`  
**Fichier SQL :** `sql/kpis/kPI_Perfomance_clients_générant_plus_revenus.sql`  
**Objectif métier :** 
> Conaitre les clients qui génèrent plus des revenus dans le but de les fidéliser

**Formule / logique de calcul :**
```sql
SELECT
    c.customerName,
    COUNT(p.paymentDate) AS 'nombre_Paiements',
    SUM(p.amount) AS 'total_des_revenues',
    AVG(p.amount) AS 'revenus_moyens_desclients'
FROM customers c
JOIN payments p ON c.customerNumber = p.customerNumber
GROUP BY c.customerName
ORDER BY total_des_revenues DESC;
```

## KPI 12 — Croissance des ventes par trimestre

**Nom interne :** `kpi_Croissance_des_ventes_par_trimestre`  
**Fichier SQL :** `sql/kpis/kpi_Croissance_des_ventes_par_trimestre.sql`  
**Objectif métier :**
Calcule le taux de croissance du chiffre d’affaires d’un trimestre à l’autre

**Formule / logique de calcul :**
```sql
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
```

## KPI 13 — Ratio commandes/paiements par représentant commercial

**Nom interne :** `kpi_Montant_moyen_des_paiements_et_clients_en_dessous_de_la_moyenne`  
**Fichier SQL :** `sql/kpis/kpi_Montant_moyen_des_paiements_et_clients_en_dessous_de_la_moyenne.sql`  
**Objectif métier :**
Calcule le montant moyen d'une transaction.
Identifie les clients dont le total payé sur la période est inferieure moyenne des totaux par client

**Formule / logique de calcul :**
```sql
SELECT
    ROUND(AVG(p.amount), 2) AS avg_payment_amount
FROM payments p
WHERE p.paymentDate BETWEEN :start_date AND :end_date;
```
```sql
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
```

## KPI 14 — Taux de paiement par delai

**Nom interne :** `kpi_Taux_de_paiement_par_delai`  
**Fichier SQL :** `sql/kpis/kpi_Taux_de_paiement_par_delai.sql`  
**Objectif métier :**
Pour chaque client, calcul de la moyenne des jours entre orderDate et le 1er paiement >= orderDate

**Formule / logique de calcul :**
```sql
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
```
