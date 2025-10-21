## KPI 6 - marge_brute_par_produit_et_par_categorie

**Nom interne:** 
`kpi_marge_brute_par_produit_et_par_categorie`
**fichier sql:**
`sql/kpis/kpi_marge_brute_par_produit_et_par_categorie.sql`
**Objectif Metier:**
>Dans un premier temps, Mesurer la marge brute des produits par catégories afin d'en déduire les produits par catégories les plus/moins rentable. 
Dans un second temps, Mesurer la marge brute par produits et par catégories afin d'enduire les produits les plus/moins rentable et les catégories les plus/moins rentable.

**Formule / logique calcul:**
```sql
-- Marge brute par produit et par catégorie
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

-- Marge brute par produits: du plus ou moins rentables
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


-- Marge brute par catégorie: du plus ou moins rentables
SELECT 
    pl.productLine,
    SUM(od.quantityOrdered * (od.priceEach - p.buyPrice)) AS marge_brute
FROM products p
JOIN productlines pl ON p.productLine = pl.productLine
JOIN orderdetails od ON p.productCode = od.productCode
GROUP BY pl.productLine
ORDER BY marge_brute DESC;
```

