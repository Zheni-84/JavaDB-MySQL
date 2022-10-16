DROP DATABASE restaurant_db;
CREATE DATABASE restaurant_db;

USE restaurant_db;

-- 01.	Table Design
CREATE TABLE products
(
    id    INT AUTO_INCREMENT PRIMARY KEY,
    name  VARCHAR(30) NOT NULL UNIQUE,
    type  VARCHAR(30) NOT NULL,
    price DEC(10, 2)  NOT NULL
);

CREATE TABLE clients
(
    id         INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name  VARCHAR(50) NOT NULL,
    birthdate  DATE        NOT NULL,
    card       VARCHAR(50),
    review     TEXT
);

CREATE TABLE tables
(
    id       INT AUTO_INCREMENT PRIMARY KEY,
    floor    INT NOT NULL,
    reserved TINYINT(1),
    capacity INT NOT NULL
);

CREATE TABLE waiters
(
    id         INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name  VARCHAR(50) NOT NULL,
    email      VARCHAR(50) NOT NULL,
    phone      VARCHAR(50),
    salary     DEC(10, 2)
);

CREATE TABLE orders
(
    id           INT AUTO_INCREMENT PRIMARY KEY,
    table_id     INT  NOT NULL,
    waiter_id    INT  NOT NULL,
    order_time   TIME NOT NULL,
    payed_status TINYINT(1),
    CONSTRAINT fk_orders_waiters
        FOREIGN KEY (waiter_id) REFERENCES waiters (id),
    CONSTRAINT fk_orders_tables
        FOREIGN KEY (table_id) REFERENCES tables (id)
);

CREATE TABLE orders_clients
(
    order_id  INT,
    client_id INT,
    KEY pk_orders_clients (order_id, client_id),
    CONSTRAINT fk_orders_clients_client
        FOREIGN KEY (client_id) REFERENCES clients (id),
    CONSTRAINT fk_orders_clients_order
        FOREIGN KEY (order_id) REFERENCES orders (id)
);

CREATE TABLE orders_products
(
    order_id   INT,
    product_id INT,
    KEY pk_orders_clients (order_id, product_id),
    CONSTRAINT fk_orders_products_product
        FOREIGN KEY (product_id) REFERENCES products (id),
    CONSTRAINT fk_orders_products_order
        FOREIGN KEY (order_id) REFERENCES orders (id)
);

-- 02.	Insert
INSERT INTO products (name, type, price)
SELECT CONCAT_WS(' ', last_name, 'specialty'),
       'Cocktail',
       CEILING(salary * 0.01)
FROM waiters
WHERE id > 6;

-- 03. Update
UPDATE orders
SET table_id := table_id - 1
WHERE id BETWEEN 12 AND 23;

-- 04. Delete
DELETE
FROM waiters
WHERE id NOT IN (SELECT waiter_id FROM orders);

-- 05. Clients
SELECT id, first_name, last_name, birthdate, card, review
FROM clients
ORDER BY birthdate DESC, id DESC;

-- 06. Birthdate
SELECT first_name, last_name, birthdate, review
FROM clients
WHERE card IS NULL
  AND YEAR(birthdate) BETWEEN 1978 AND 1993
ORDER BY last_name DESC, id
LIMIT 5;

-- 07. Accounts
SELECT CONCAT(last_name, first_name, LENGTH(first_name), 'Restaurant') `username`,
       REVERSE(SUBSTR(email, 2, 12))                                   `password`
FROM waiters
WHERE salary IS NOT NULL
ORDER BY `password` DESC;

-- 08. Top from menu
SELECT p.id, p.name, COUNT(p.id)
FROM orders o
         JOIN orders_products op on o.id = op.order_id
         JOIN products p on p.id = op.product_id
GROUP BY p.name
HAVING COUNT(p.id) >= 5
ORDER BY COUNT(p.id) DESC, p.name;

-- 09. Availability
SELECT t.id                as table_id,
       t.capacity          as capacity,
       COUNT(oc.client_id) as `count_clients`,
       (CASE
            WHEN t.capacity > COUNT(oc.client_id) THEN 'Free seats'
            WHEN t.capacity = COUNT(oc.client_id) THEN 'Full'
            WHEN t.capacity < COUNT(oc.client_id) THEN 'Extra seats'
           END)            as availability
FROM tables t
         JOIN orders o on t.id = o.table_id
         JOIN orders_clients oc on o.id = oc.order_id
WHERE t.floor = 1
GROUP BY t.id
ORDER BY t.id DESC;

-- 10. Extract bill
DELIMITER $$
CREATE FUNCTION udf_client_bill(full_name VARCHAR(50))
    RETURNS DEC(19, 2)
    DETERMINISTIC
BEGIN
    DECLARE total_order_products DEC(19, 2);
    SET total_order_products :=
            (SELECT SUM(p.price)
             FROM clients c
                      JOIN orders_clients oc on c.id = oc.client_id
                      JOIN orders_products op on oc.order_id = op.order_id
                      JOIN products p on p.id = op.product_id
             WHERE CONCAT(c.first_name, ' ', c.last_name) = full_name
             GROUP BY c.id);
    RETURN total_order_products;
END$$

SELECT c.first_name, c.last_name, udf_client_bill('Silvio Blyth') as 'bill'
FROM clients c
WHERE c.first_name = 'Silvio'
  AND c.last_name = 'Blyth';

-- 11. Happy hour
CREATE PROCEDURE udp_happy_hour(type_in VARCHAR(50))
BEGIN
    UPDATE products
    SET price := price * 0.8
    WHERE price >= 10.0
      AND type = type_in;
END$$

CALL udp_happy_hour ('Cognac');

SELECT SUBSTRING('SoftUni', 1);