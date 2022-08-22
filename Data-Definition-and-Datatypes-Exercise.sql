DROP DATABASE IF EXISTS `minions`;

CREATE DATABASE `minions`;

USE `minions`;

-- 01. Create Tables
CREATE TABLE `minions`
(
    `id`   INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(50) NOT NULL,
    `age`  INT
);

CREATE TABLE `towns`
(
    `town_id` INT PRIMARY KEY AUTO_INCREMENT,
    `name`    VARCHAR(50)
);


-- 02. Alter Minions Table
ALTER TABLE `towns` RENAME COLUMN `town_id` TO `id`;

ALTER TABLE `minions`
    ADD COLUMN `town_id` INT NOT NULL,
    ADD FOREIGN KEY (`town_id`)
        REFERENCES `towns` (`id`);


-- 03. Insert Records in Both Tables
INSERT INTO `towns`(`id`, `name`)
VALUES (1, 'Sofia'),
       (2, 'Plovdiv'),
       (3, 'Varna');

INSERT INTO `minions`(`id`, `name`, `age`, `town_id`)
VALUES (1, 'Kevin', 22, 1),
       (2, 'Bob', 15, 3),
       (3, 'Steward', NULL, 2);


-- 4. Truncate Table Minions
TRUNCATE TABLE minions;

-- 5.	Drop All Tables
DROP TABLE minions;
DROP TABLE towns;

-- 6.	Create Table People


-- 12.	Car Rental Database
DROP DATABASE IF EXISTS `car_rentals`;
CREATE DATABASE `car_rentals`;
USE `car_rentals`;

CREATE TABLE `categories`
(
    -- categories (id, category, daily_rate, weekly_rate, monthly_rate, weekend_rate)
    `id`           INT PRIMARY KEY AUTO_INCREMENT,
    `category`     VARCHAR(30) NOT NULL,
    `daily_rate`   DECIMAL(12, 2),
    `weekly_rate`  DECIMAL(12, 2),
    `monthly_rate` DECIMAL(12, 2),
    `weekend_rate` DECIMAL(12, 2)
);
INSERT INTO `categories` (`category`, `daily_rate`, `weekly_rate`, `monthly_rate`, `weekend_rate`)
VALUES ('Economy', 80, 400, 1500, 150),
       ('Family', 120, 520, 2000, 210),
       ('Lux', 220, 1040, 3500, 400);

-- •	cars (id, plate_number, make, model, car_year, category_id, doors, picture, car_condition, available)
DROP TABLE `cars`;
CREATE TABLE `cars`
(
    `id`            INT PRIMARY KEY AUTO_INCREMENT,
    `plate_number`  VARCHAR(10) NOT NULL,
    `make`          VARCHAR(20),
    `model`         VARCHAR(20) NOT NULL,
    `car_year`      YEAR,
    `category_id`   INT         NOT NULL,
    `doors`         TINYINT,
    `picture`       BLOB,
    `car_condition` TINYTEXT,
    `available`     BOOLEAN     NOT NULL,
    CONSTRAINT fk_cars_categories FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`)
);
INSERT INTO `cars` (`plate_number`, `make`, `model`, `car_year`, `category_id`, `doors`, `car_condition`, `available`)
VALUES ('CA1111AA', 'Ford', 'Fiesta', 2010, 1, 2, 'Perfect', TRUE),
       ('CA2222BB', 'BMV', '5 series', 2013, 2, 4, 'Good', TRUE),
       ('CA3333CC', 'BMV', 'X5', 2015, 3, 4, 'Perfect', FALSE);

-- •	employees (`id`, `first_name`, `last_name`, `title`, `notes`)
CREATE TABLE `employees`
(
    `id`         INT PRIMARY KEY AUTO_INCREMENT,
    `first_name` VARCHAR(20) NOT NULL,
    `last_name`  VARCHAR(20) NOT NULL,
    `title`      VARCHAR(30) NOT NULL,
    `notes`      TINYTEXT
);
INSERT INTO `employees` (`first_name`, `last_name`, `title`)
VALUES ('Avreli', 'Goshev', 'Seller'),
       ('Miroslav', 'Toshev', 'Seller'),
       ('Ignat', 'Avramov', 'Manager');

-- •	customers (`id`, `driver_licence_number`, `full_name`, `address`, `city`, `zip_code`, `notes`)
CREATE TABLE customers
(
    `id`                    INT PRIMARY KEY AUTO_INCREMENT,
    `driver_licence_number` VARCHAR(20),
    `full_name`             VARCHAR(20),
    `address`               VARCHAR(50),
    `city`                  VARCHAR(20),
    `zip_code`              VARCHAR(5),
    `notes`                 TEXT
);
INSERT INTO `customers` (`driver_licence_number`, `full_name`, `address`, `city`, `zip_code`)
VALUES ('9985113780', 'Pesho Gergov', 'Mladost 1, bl 120, vh.B, ap.44', 'Sofia', '1650'),
       ('2225568690', 'Gosho Mechkata', 'Liulin 10, bl 19, ap.8', 'Sofia', '1340'),
       ('7884561440', 'Angel Todorov', 'Lozenetz, ul.Bqla morava, N40', 'Sofia', '1560');

-- 	rental_orders (id, employee_id, customer_id, car_id, car_condition, tank_level, kilometrage_start, kilometrage_end, total_kilometrage, start_date, end_date, total_days, rate_applied, tax_rate, order_status, notes)
CREATE TABLE rental_orders
(
    `id`                INT PRIMARY KEY AUTO_INCREMENT,
    `employee_id`       INT                                  NOT NULL,
    `customer_id`       INT                                  NOT NULL,
    `car_id`            INT                                  NOT NULL,
    `car_condition`     TEXT,
    `tank_level`        INT,
    `kilometrage_start` INT,
    `kilometrage_end`   INT,
    `total_kilometrage` INT,
    `start_date`        DATE,
    `end_date`          DATE,
    `total_days`        INT,
    `rate_applied`      ENUM ('daily_rate', 'weekly_rate', 'monthly_rate', 'weekend_rate'),
    `tax_rate`          DECIMAL(12, 2),
    `order_status`      ENUM ('NEW', 'WAITING', 'COMPLETED') NOT NULL,
    `notes`             TEXT,
    CONSTRAINT fk_orders_employee FOREIGN KEY (`employee_id`) REFERENCES `employees` (`id`),
    CONSTRAINT fk_orders_customers FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`),
    CONSTRAINT fk_orders_cars FOREIGN KEY (`car_id`) REFERENCES `cars` (`id`)
);
INSERT INTO `rental_orders`(`employee_id`, `customer_id`, `car_id`, `car_condition`, `tank_level`, `kilometrage_start`, `kilometrage_end`,
                            `total_kilometrage`, `start_date`, `end_date`, `total_days`, `rate_applied`, `tax_rate`, `order_status`)
VALUES (1, 1, 1, 'Perfect', 22.5, 1000, 2000, 110565, '2022-08-01', '2022-08-02', 1, 'daily_rate', 80, 'NEW'),
       (1, 2, 2, 'Good', 40.0, 1650, 2000, 150550, '2022-09-01', '2022-09-10', 9, 'weekly_rate', 550, 'WAITING'),
       (2, 3, 3, 'Pristine', 12.0, 3625, 3989, 88680, '2022-06-11', '2022-06-14', 3, 'weekend_rate', 120, 'COMPLETED');