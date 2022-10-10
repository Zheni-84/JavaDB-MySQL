-- 01. One-To-One Relationship
DROP
    DATABASE IF EXISTS homework;
CREATE
    DATABASE homework;
USE
    homework;

CREATE TABLE `passports`
(
    `passport_id`     INT PRIMARY KEY AUTO_INCREMENT,
    `passport_number` CHAR(8) NOT NULL UNIQUE
);
CREATE TABLE `people`
(
    `person_id`   INT PRIMARY KEY AUTO_INCREMENT,
    `first_name`  VARCHAR(20) NOT NULL,
    `salary`      DECIMAL(12, 2),
    `passport_id` INT UNIQUE  NOT NULL
);

INSERT INTO `people`(`first_name`, `salary`, `passport_id`)
VALUES ('Roberto', 43300.00, 102),
       ('Tom', 56100.00, 103),
       ('Yana', 60200.00, 101);

INSERT INTO `passports`
VALUES (101, 'N34FG21B'),
       (102, 'K65LO4R7'),
       (103, 'ZE657QP2');

ALTER TABLE `people`
    ADD CONSTRAINT `fk_people_passports`
        FOREIGN KEY (`passport_id`)
            REFERENCES passports (`passport_id`);

-- 2.	One-To-Many Relationship
CREATE TABLE `manufacturers`
(
    `manufacturer_id` INT PRIMARY KEY UNIQUE,
    `name`            VARCHAR(20) NOT NULL UNIQUE,
    `established_on`  DATE
);

CREATE TABLE `models`
(
    `model_id`        INT PRIMARY KEY AUTO_INCREMENT UNIQUE,
    `name`            VARCHAR(20),
    `manufacturer_id` INT,
    CONSTRAINT fk_model_manufacturer
        FOREIGN KEY (manufacturer_id)
            REFERENCES manufacturers (manufacturer_id)
);

INSERT INTO `manufacturers`
VALUES (1, 'BMW', '1916-03-01'),
       (2, 'Tesla', '2003-01-01'),
       (3, 'Lada', '1966-05-01');

INSERT INTO `models`
VALUES (101, 'X1', 1),
       (102, 'i6', 1),
       (103, 'Model S', 2),
       (104, 'Model X', 2),
       (105, 'Model 3', 2),
       (106, 'Nova', 3);


-- 03. Many-To-Many Relationship
CREATE TABLE `students`
(
    `student_id` INT PRIMARY KEY AUTO_INCREMENT,
    `name`       VARCHAR(50)
);
CREATE TABLE `exams`
(
    `exam_id` INT PRIMARY KEY AUTO_INCREMENT,
    `name`    VARCHAR(50)
);
CREATE TABLE `students_exams`
(
    `student_id` INT NOT NULL,
    `exam_id`    INT NOT NULL,
    CONSTRAINT `pk_students`
        PRIMARY KEY (`student_id`, `exam_id`),
    CONSTRAINT `fk_students`
        FOREIGN KEY (`student_id`)
            REFERENCES `students` (`student_id`),
    CONSTRAINT `fk_exams`
        FOREIGN KEY (`exam_id`)
            REFERENCES `exams` (`exam_id`)
);

INSERT INTO students(`name`)
VALUES ('Mila'),
       ('Toni'),
       ('Ron');

INSERT INTO exams
VALUES (101, 'Spring MVC'),
       (102, 'Neo4j'),
       (103, 'Oracle 11g');

INSERT INTO students_exams
VALUES (1, 101),
       (1, 102),
       (2, 101),
       (3, 103),
       (2, 102),
       (2, 103);


-- 4.	Self-Referencing
DROP TABLE `teachers`;
CREATE TABLE `teachers`
(
    `teacher_id` INT PRIMARY KEY AUTO_INCREMENT,
    `name`       VARCHAR(20),
    `manager_id` INT -- ,
    --  CONSTRAINT fk_manager_teachers
    --      FOREIGN KEY (manager_id)
    --          REFERENCES teachers (teacher_id)
);

INSERT INTO `teachers`
VALUES (101, 'John', NULL),
       (102, 'Maya', 106),
       (103, 'Silvia', 106),
       (104, 'Ted', 105),
       (105, 'Mark', 101),
       (106, 'Greta', 101);

ALTER TABLE `teachers`
    ADD CONSTRAINT fk_manager_teachers
        FOREIGN KEY (manager_id)
            REFERENCES teachers (teacher_id);

-- 5.	Online Store Database

DROP DATABASE IF EXISTS online_store;
CREATE DATABASE online_store;
USE online_store;

