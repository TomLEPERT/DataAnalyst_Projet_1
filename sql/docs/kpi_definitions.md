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

