-- =========================================
-- 00_schemas.sql
-- Création du schéma de base de données
-- =========================================

-- Créer la base
CREATE DATABASE IF NOT EXISTS toys_and_models;
USE toys_and_models;

-- Désactiver temporairement la vérification des clés étrangères
SET FOREIGN_KEY_CHECKS = 0;

-- =========================================
-- 1. Offices
-- =========================================
CREATE TABLE offices (
    officeCode VARCHAR(10) NOT NULL PRIMARY KEY,
    city VARCHAR(50) NOT NULL,
    phone VARCHAR(50) NOT NULL,
    addressLine1 VARCHAR(50) NOT NULL,
    addressLine2 VARCHAR(50) DEFAULT NULL,
    state VARCHAR(50) DEFAULT NULL,
    country VARCHAR(50) NOT NULL,
    postalCode VARCHAR(15) NOT NULL,
    territory VARCHAR(10) NOT NULL
);

-- =========================================
-- 2. Employees
-- =========================================
CREATE TABLE employees (
    employeeNumber INT NOT NULL PRIMARY KEY,
    lastName VARCHAR(50) NOT NULL,
    firstName VARCHAR(50) NOT NULL,
    extension VARCHAR(10) NOT NULL,
    email VARCHAR(100) NOT NULL,
    officeCode VARCHAR(10) NOT NULL,
    reportsTo INT DEFAULT NULL,
    jobTitle VARCHAR(50) NOT NULL,
    CONSTRAINT fk_employees_officeCode
        FOREIGN KEY (officeCode)
        REFERENCES offices (officeCode)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_employees_reportsTo
        FOREIGN KEY (reportsTo)
        REFERENCES employees (employeeNumber)
        ON UPDATE CASCADE
        ON DELETE SET NULL
);

-- =========================================
-- 3. Customers
-- =========================================
CREATE TABLE customers (
    customerNumber INT NOT NULL PRIMARY KEY,
    customerName VARCHAR(50) NOT NULL,
    contactLastName VARCHAR(50) NOT NULL,
    contactFirstName VARCHAR(50) NOT NULL,
    phone VARCHAR(50) NOT NULL,
    addressLine1 VARCHAR(50) NOT NULL,
    addressLine2 VARCHAR(50) DEFAULT NULL,
    city VARCHAR(50) NOT NULL,
    state VARCHAR(50) DEFAULT NULL,
    postalCode VARCHAR(15) DEFAULT NULL,
    country VARCHAR(50) NOT NULL,
    salesRepEmployeeNumber INT DEFAULT NULL,
    creditLimit DECIMAL(10,2) DEFAULT NULL,
    CONSTRAINT fk_customers_salesRepEmployeeNumber
        FOREIGN KEY (salesRepEmployeeNumber)
        REFERENCES employees (employeeNumber)
        ON UPDATE CASCADE
        ON DELETE SET NULL
);

-- =========================================
-- 4. Productlines
-- =========================================
CREATE TABLE productlines (
    productLine VARCHAR(50) NOT NULL PRIMARY KEY,
    textDescription VARCHAR(4000) DEFAULT NULL,
    htmlDescription MEDIUMTEXT DEFAULT NULL,
    image MEDIUMBLOB DEFAULT NULL
);

-- =========================================
-- 5. Products
-- =========================================
CREATE TABLE products (
    productCode VARCHAR(15) NOT NULL PRIMARY KEY,
    productName VARCHAR(70) NOT NULL,
    productLine VARCHAR(50) NOT NULL,
    productScale VARCHAR(10) NOT NULL,
    productVendor VARCHAR(50) NOT NULL,
    productDescription TEXT NOT NULL,
    quantityInStock SMALLINT NOT NULL,
    buyPrice DECIMAL(10,2) NOT NULL,
    MSRP DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_products_productLine
        FOREIGN KEY (productLine)
        REFERENCES productlines (productLine)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- =========================================
-- 6. Orders
-- =========================================
CREATE TABLE orders (
    orderNumber INT NOT NULL PRIMARY KEY,
    orderDate DATE NOT NULL,
    requiredDate DATE NOT NULL,
    shippedDate DATE DEFAULT NULL,
    status VARCHAR(15) NOT NULL,
    comments TEXT DEFAULT NULL,
    customerNumber INT NOT NULL,
    CONSTRAINT fk_orders_customers
        FOREIGN KEY (customerNumber)
        REFERENCES customers (customerNumber)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- =========================================
-- 7. Orderdetails
-- =========================================
CREATE TABLE orderdetails (
    orderNumber INT NOT NULL,
    productCode VARCHAR(15) NOT NULL,
    quantityOrdered INT NOT NULL,
    priceEach DECIMAL(10,2) NOT NULL,
    orderLineNumber SMALLINT NOT NULL,
    PRIMARY KEY (orderNumber, productCode),
    CONSTRAINT fk_orderdetails_orders
        FOREIGN KEY (orderNumber)
        REFERENCES orders (orderNumber)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_orderdetails_products
        FOREIGN KEY (productCode)
        REFERENCES products (productCode)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- =========================================
-- 8. Payments
-- =========================================
CREATE TABLE payments (
    customerNumber INT NOT NULL,
    checkNumber VARCHAR(50) NOT NULL,
    paymentDate DATE NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (customerNumber, checkNumber),
    CONSTRAINT fk_payments_customers
        FOREIGN KEY (customerNumber)
        REFERENCES customers (customerNumber)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- Réactiver la vérification des clés étrangères
SET FOREIGN_KEY_CHECKS = 1;



