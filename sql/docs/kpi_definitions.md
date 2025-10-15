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