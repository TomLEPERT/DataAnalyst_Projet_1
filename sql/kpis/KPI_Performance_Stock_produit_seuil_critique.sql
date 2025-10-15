SELECT
	productCode,
    productName,
    quantityInStock
FROM 
	products
WHERE quantityInStock
ORDER BY quantityInStock ASC;
