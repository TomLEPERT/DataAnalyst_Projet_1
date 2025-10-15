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
