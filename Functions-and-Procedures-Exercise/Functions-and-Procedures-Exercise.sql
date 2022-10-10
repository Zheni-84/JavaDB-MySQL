DROP DATABASE soft_uni;

-- Part I – Queries for SoftUni Database
USE soft_uni;
DELIMITER $$
-- 1.	Employees with Salary Above 35000
CREATE PROCEDURE usp_get_employees_salary_above_35000()
BEGIN
    SELECT first_name, last_name
    FROM employees
    WHERE salary > 35000
    ORDER BY first_name, last_name, employee_id DESC;
END$$

call usp_get_employees_salary_above_35000();

-- 2.	Employees with Salary Above Number
DROP PROCEDURE usp_get_employees_salary_above$$
CREATE PROCEDURE usp_get_employees_salary_above(min_salary DECIMAL(16, 4))
BEGIN
    SELECT first_name, last_name
    FROM employees
    WHERE salary >= min_salary
    ORDER BY first_name, last_name, employee_id;
END$$

call usp_get_employees_salary_above(45000)$$

-- 3.	Town Names Starting With
DROP PROCEDURE usp_get_towns_starting_with$$
CREATE PROCEDURE usp_get_towns_starting_with(starting_text VARCHAR(50))
BEGIN
    SELECT name
    FROM towns
    WHERE name LIKE CONCAT(starting_text, '%')
    ORDER BY name;
END$$

call usp_get_towns_starting_with('b');

-- 4.	Employees from Town
CREATE PROCEDURE usp_get_employees_from_town(town_name VARCHAR(50))
BEGIN
    SELECT e.first_name, e.last_name
    FROM employees e
             JOIN addresses a USING (address_id)
             JOIN towns t USING (town_id)
    WHERE t.name = town_name
    ORDER BY e.first_name, e.last_name, e.employee_id;
END$$
call usp_get_employees_from_town('Sofia')$$

-- 5.	Salary Level Function
CREATE FUNCTION ufn_get_salary_level(salary DECIMAL(19, 4))
    RETURNS VARCHAR(10)
    DETERMINISTIC
BEGIN
    DECLARE salary_level VARCHAR(10);
    IF salary < 30000 THEN
        SET salary_level := 'Low';
    ELSEIF salary <= 50000 THEN
        SET salary_level := 'Average';
    ELSE
        SET salary_level := 'High';
    END IF;
    RETURN salary_level;
END$$ # for Judge submission remove $$ and add ;

set @salary = 480000.0;
select ufn_get_salary_level(@salary);

-- 6.	Employees by Salary Level
DROP PROCEDURE usp_get_employees_by_salary_level;
CREATE PROCEDURE usp_get_employees_by_salary_level(salary_level VARCHAR(10))
BEGIN
    SELECT first_name, last_name
    FROM employees
    WHERE ufn_get_salary_level(salary) = salary_level
    ORDER BY first_name DESC, last_name DESC;
END$$ # for Judge submission remove $$ and add ;

set @salary_level = 'High';
call usp_get_employees_by_salary_level(@salary_level)$$

-- 7.	Define Function
CREATE FUNCTION ufn_is_word_comprised(set_of_letters varchar(50), word varchar(50))
    RETURNS INT
    DETERMINISTIC
BEGIN
    RETURN word REGEXP (CONCAT('^[', set_of_letters, ']+$'));
END$$

set @set_of_letters = 'oistmiahf';
set @word = 'Sofia';
select ufn_is_word_comprised(
               @set_of_letters,
               @word
           ) result$$

-- PART II – Queries for Bank Database
-- 8.	Find Full Name
CREATE PROCEDURE usp_get_holders_full_name()
BEGIN
    SELECT CONCAT_WS(' ', first_name, last_name) full_name
    FROM account_holders
    ORDER BY full_name, id;
END$$

call usp_get_holders_full_name();

-- 9.	People with Balance Higher Than
CREATE PROCEDURE usp_get_holders_with_balance_higher_than(having_balance DECIMAL(19, 4))
BEGIN
    SELECT ah.first_name, ah.last_name
    FROM account_holders ah
             JOIN accounts a ON ah.id = a.account_holder_id
    GROUP BY ah.id
    HAVING sum(a.balance) > having_balance;
END$$

-- 10.	Future Value Function
CREATE FUNCTION ufn_calculate_future_value(sum DECIMAL(19, 4), yearly_rate DOUBLE, years INT)
    RETURNS DECIMAL(19, 4)
    DETERMINISTIC
BEGIN
    DECLARE future_sum DECIMAL(19, 4);
    SET future_sum := sum * POW(1 + yearly_rate, years);
    RETURN future_sum;
END$$

set @sum = 1000.0;
set @yearly_rate = 0.5;
set @years = 5;
select ufn_calculate_future_value(@sum, @yearly_rate, @years)$$

-- 11.	Calculating Interest
CREATE PROCEDURE usp_calculate_future_value_for_account(account_id INT, interest_rate DOUBLE(19, 4))
BEGIN
    SELECT a.id                                                    account_id,
           ah.first_name,
           ah.last_name,
           a.balance                                               current_balance,
           ufn_calculate_future_value(a.balance, interest_rate, 5) balance_in_5_years
    FROM accounts as a
             JOIN account_holders as ah ON a.account_holder_id = ah.id
    WHERE a.id = account_id;
END$$

