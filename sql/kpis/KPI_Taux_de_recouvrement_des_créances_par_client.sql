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