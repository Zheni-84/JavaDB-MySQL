USE soft_uni;

-- 1.	Employee Address
SELECT e.employee_id, e.job_title, e.address_id, a.address_text
FROM employees e
         JOIN addresses a
              ON a.address_id = e.address_id
ORDER BY address_id
LIMIT 5;

-- 2.	Addresses with Towns
SELECT e.first_name, e.last_name, t.name, a.address_text
FROM employees e
         JOIN addresses a ON a.address_id = e.address_id
         JOIN towns t ON a.town_id = t.town_id
ORDER BY first_name, last_name
LIMIT 5;

-- 3.	Sales Employee
SELECT e.employee_id, e.first_name, e.last_name, d.name
FROM employees e
         JOIN departments d ON d.department_id = e.department_id
WHERE d.name = 'Sales'
ORDER BY e.employee_id DESC;

-- 4.	Employee Departments
SELECT e.employee_id, e.first_name, e.salary, d.name
FROM employees e
         JOIN departments d ON d.department_id = e.department_id
WHERE e.salary > 15000
ORDER BY d.department_id DESC
LIMIT 5;

-- 5.	Employees Without Project
SELECT e.employee_id, e.first_name
FROM employees e
         LEFT JOIN employees_projects ep USING (employee_id)
WHERE ep.project_id IS NULL
ORDER BY e.employee_id DESC
LIMIT 3;

-- 6.	Employees Hired After
SELECT e.first_name, e.last_name, e.hire_date, d.name
FROM employees e
         JOIN departments d USING (department_id)
WHERE e.hire_date > '1999/01/01'
  AND d.name IN ('Sales', 'Finance')
ORDER BY e.hire_date;

-- 7.	Employees with Project
SELECT e.employee_id, e.first_name, p.name
FROM employees e
         JOIN employees_projects ep USING (employee_id)
         JOIN projects p USING (project_id)
WHERE DATE(p.start_date) > '2002/08/13'
  AND p.end_date IS NULL
ORDER BY e.first_name, p.name
LIMIT 5;

-- 8.	Employee 24
SELECT e.employee_id,
       e.first_name,
       IF(YEAR(p.`start_date`) >= 2005, NULL, p.`name`) as `p_name`
FROM employees e
         JOIN employees_projects ep USING (employee_id)
         JOIN projects p USING (project_id)
WHERE e.employee_id = 24
ORDER BY `p_name`;

-- 9.	Employee Manager
SELECT e.employee_id, e.first_name, e.manager_id, m.first_name
FROM employees e
         JOIN employees m ON e.manager_id = m.employee_id
WHERE e.manager_id IN (3, 7)
ORDER BY e.first_name;

-- 10.	Employee Summary
SELECT e.employee_id, CONCAT_WS(' ', e.first_name, e.last_name), CONCAT_WS(' ', m.first_name, m.last_name), d.name
FROM employees e
         JOIN employees m ON e.manager_id = m.employee_id
         JOIN departments d ON e.department_id = d.department_id
ORDER BY e.employee_id
LIMIT 5;

-- 11.	Min Average Salary
SELECT AVG(salary) AS `min_average_salary`
FROM employees
GROUP BY department_id
ORDER BY `min_average_salary`
LIMIT 1;

-- 12.	Highest Peaks in Bulgaria
USE geography;

SELECT mc.country_code, m.mountain_range, p.peak_name, p.elevation
FROM peaks AS p
         JOIN mountains AS m ON p.mountain_id = m.id
         JOIN mountains_countries AS mc ON m.id = mc.mountain_id
WHERE mc.country_code = 'BG'
  AND p.elevation > 2835
ORDER BY p.elevation DESC;

-- 13.	Count Mountain Ranges
SELECT mc.country_code, COUNT(m.mountain_range) as mountain_range
FROM mountains AS m
         JOIN mountains_countries AS mc ON m.id = mc.mountain_id
WHERE mc.country_code IN ('US', 'RU', 'BG')
GROUP BY mc.country_code
ORDER BY mountain_range DESC;

-- 14.	Countries with Rivers
SELECT c.country_name, r.river_name
FROM countries AS c
         LEFT JOIN countries_rivers cr ON c.country_code = cr.country_code
         LEFT JOIN rivers AS r ON cr.river_id = r.id
WHERE c.continent_code = 'AF'
ORDER BY c.country_name
LIMIT 5;

-- 15.	*Continents and Currencies
SELECT c.continent_code,
       c.currency_code,
       COUNT(c.currency_code) AS `currency_usage`
FROM countries as c
GROUP BY c.continent_code, c.currency_code
HAVING currency_usage = (SELECT COUNT(ci.currency_code) AS all_currency_usage
                                 FROM countries as ci
                                 WHERE ci.continent_code = c.continent_code
                                 GROUP BY ci.continent_code, ci.currency_code
                                 ORDER BY all_currency_usage DESC
                                 LIMIT 1)
   AND currency_usage > 1
ORDER BY c.continent_code, c.currency_code;

-- 16.  Countries Without Any Mountains
SELECT COUNT(c.country_name)
FROM countries c
         LEFT JOIN mountains_countries mc ON c.country_code = mc.country_code
WHERE mc.country_code IS NULL;

-- 17.  Highest Peak and Longest River by Country
SELECT c.country_name, MAX(p.elevation) max_elevation, MAX(r.length) max_length
FROM countries c
         LEFT JOIN mountains_countries mc on c.country_code = mc.country_code
         LEFT JOIN peaks p on mc.mountain_id = p.mountain_id
         LEFT JOIN countries_rivers cr on c.country_code = cr.country_code
         LEFT JOIN rivers r on r.id = cr.river_id
GROUP BY c.country_name
ORDER BY max_elevation DESC, max_length DESC, c.country_name
LIMIT 5;