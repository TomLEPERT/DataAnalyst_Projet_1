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
