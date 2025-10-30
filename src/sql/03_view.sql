-- FACT_Sales
CREATE VIEW FACT_SALES AS
SELECT 
    o.orderNumber,
    o.orderDate,
    o.shippedDate,
    o.requiredDate,
    e.officeCode,
    od.productCode,
    c.customerNumber,
    e.employeeNumber,
    od.quantityOrdered,
    od.priceEach,
    (od.quantityOrdered * od.priceEach) AS totalAmount
FROM orderdetails od
JOIN orders o 
    ON o.orderNumber = od.orderNumber
JOIN customers c 
    ON o.customerNumber = c.customerNumber
JOIN employees e 
    ON c.salesRepEmployeeNumber = e.employeeNumber
JOIN offices off 
    ON e.officeCode = off.officeCode;


-- DIM_customers
CREATE VIEW DIM_CUSTOMERS AS
SELECT 
    customerNumber,
    customerName,
    country,
    city,
    creditLimit
FROM customers ;

-- DIM_employées
CREATE VIEW DIM_EMPLOYEES AS
SELECT 
    employeeNumber,
    firstName,
    lastName,
    jobTitle
FROM employees ;

-- DIM_dates
CREATE VIEW dim_dates AS
WITH RECURSIVE date_series AS ( 
SELECT DATE('2022-01-21') AS full_date 
UNION ALL SELECT DATE_ADD(full_date, INTERVAL 1 DAY) 
FROM date_series 
WHERE full_date < DATE('2024-03-04') 
) 
SELECT 
full_date AS order_date, 
YEAR(full_date) AS year, 
MONTH(full_date) AS month, 
QUARTER(full_date) AS quarter, 
DATE_FORMAT(full_date, '%M') AS month_name, 
WEEK(full_date, 1) AS week_number, 
DAY(full_date) AS day_of_month, 
DAYNAME(full_date) AS day_name 
FROM date_series;

-- DIM_OFFICES
CREATE VIEW DIM_OFFICES AS
SELECT officeCode, city , country, territory
FROM offices ; 

-- DIM_PRODUCTS :
CREATE VIEW DIM_PRODUCTS AS
SELECT productCode, productName, buyPrice, quantityInStock
FROM products;

-- FACT_PAYMENTS : 
CREATE VIEW fact_payments AS
SELECT 
    c.customerNumber,
    c.customerName,
    p.checkNumber,
    p.paymentDate,
    p.amount
FROM payments p
JOIN customers c ON p.customerNumber = c.customerNumber
WHERE p.paymentDate >= '2022-01-01';