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