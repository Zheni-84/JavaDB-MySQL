-- 1.	 Records' Count
USE gringotts;

SELECT COUNT(id)
FROM wizzard_deposits;

-- 2.	 Longest Magic Wand
SELECT MAX(magic_wand_size) as `maximum_magic_wand_size`
FROM wizzard_deposits;

-- 3. Longest Magic Wand Per Deposit Groups
SELECT deposit_group, MAX(magic_wand_size) as `maximum_magic_wand_size`
FROM wizzard_deposits
GROUP BY deposit_group
ORDER BY `maximum_magic_wand_size`, deposit_group;

-- 4. Smallest Deposit Group Per Magic Wand Size *
SELECT deposit_group
FROM wizzard_deposits
GROUP BY deposit_group
ORDER BY AVG(magic_wand_size)
LIMIT 1;

-- 5. Deposits Sum
SELECT deposit_group, SUM(deposit_amount) `total_sum`
FROM wizzard_deposits
GROUP BY deposit_group
ORDER BY `total_sum`;

-- 6. Deposits Sum for Ollivander Family
SELECT deposit_group, SUM(deposit_amount) `total_sum`
FROM wizzard_deposits
WHERE magic_wand_creator = 'Ollivander family'
GROUP BY deposit_group
ORDER BY deposit_group;

-- 7.	Deposits Filter
SELECT deposit_group, SUM(deposit_amount) `total_sum`
FROM wizzard_deposits
WHERE magic_wand_creator = 'Ollivander family'
GROUP BY deposit_group
HAVING `total_sum` < 150000
ORDER BY `total_sum` DESC;

-- 8. Deposit Charge
SELECT deposit_group, magic_wand_creator, MIN(deposit_charge)
FROM wizzard_deposits
GROUP BY deposit_group, magic_wand_creator
ORDER BY magic_wand_creator, deposit_group;

-- 9. Age Groups
SELECT (CASE
            WHEN age <= 10 THEN '[0-10]'
            WHEN age <= 20 THEN '[11-20]'
            WHEN age <= 30 THEN '[21-30]'
            WHEN age <= 40 THEN '[31-40]'
            WHEN age <= 50 THEN '[41-50]'
            WHEN age <= 60 THEN '[51-60]'
            ELSE '[61+]'
    END)         AS `age_group`,
       COUNT(id) AS `wizard_count`
FROM wizzard_deposits
GROUP BY `age_group`
ORDER BY `wizard_count`;

-- 10. First Letter
SELECT LEFT(first_name, 1) AS `first_letter`
FROM wizzard_deposits
WHERE deposit_group LIKE 'Troll Chest'
GROUP BY `first_letter`
ORDER BY `first_letter`;

-- v2
SELECT DISTINCT (LEFT(first_name, 1)) AS `first_letter`
FROM wizzard_deposits
WHERE deposit_group LIKE 'Troll Chest'
ORDER BY `first_letter`;


-- 11.	Average Interest
SELECT deposit_group, is_deposit_expired, AVG(deposit_interest)
FROM wizzard_deposits
WHERE deposit_start_date > '1985/01/01'
GROUP BY deposit_group, is_deposit_expired
ORDER BY deposit_group DESC , is_deposit_expired;

-- 12.	 Employees Minimum Salaries
USE soft_uni;

SELECT department_id, MIN(salary)
FROM employees
WHERE department_id IN (2, 5, 7) AND hire_date > '2000/01/01'
GROUP BY department_id
ORDER BY department_id;

-- 13.	Employees Average Salaries
SELECT department_id, IF(department_id = 1 , AVG(salary) + 5000, AVG(salary)) AS `avg_salary`
FROM employees
WHERE salary > 30000 AND manager_id !=42
GROUP BY department_id
ORDER BY department_id;

-- 14. Employees Maximum Salaries
SELECT department_id, MAX(salary) AS `max_salary`
FROM employees
GROUP BY department_id
HAVING `max_salary` NOT BETWEEN 30000 AND 70000
ORDER BY department_id;

-- 15.	Employees Count Salaries
SELECT COUNT(salary)
FROM employees
WHERE manager_id IS NULL;

-- 16.	3rd Highest Salary*
SELECT department_id,
       (SELECT DISTINCT salary
        FROM employees as e2
        WHERE e1.department_id = e2.department_id
        ORDER BY salary desc
        LIMIT 2, 1
           ) AS `third_highest_salary`
FROM employees as e1
GROUP BY department_id
HAVING `third_highest_salary` IS NOT NULL
ORDER BY department_id;

-- 17.	 Salary Challenge**
SELECT first_name, last_name, department_id
FROM employees as e1
WHERE salary > (
    SELECT AVG(salary)
    FROM employees as e2
    WHERE e1.department_id = e2.department_id
    LIMIT 1
    )
ORDER BY department_id, employee_id
LIMIT 10;


