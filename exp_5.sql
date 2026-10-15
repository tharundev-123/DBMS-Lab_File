-- ============================================================
-- Experiment 5: Views, View Updatability, Recursive CTE
-- Name: Tharun Dev M C | UID: 25LBCS3324
-- Database: CompanyDB (Employee-Department-Project schema)
-- Prerequisite: Employee table must have a manager_id column
--               referencing Employee(emp_id), e.g.:
--   ALTER TABLE Employee ADD COLUMN manager_id INT NULL;
--   ALTER TABLE Employee ADD FOREIGN KEY (manager_id)
--       REFERENCES Employee(emp_id);
-- ============================================================

USE CompanyDB;

-- 1. DEPARTMENT SALARY SUMMARY VIEW
CREATE OR REPLACE VIEW department_salary_summary AS
SELECT
    d.dept_id,
    d.dept_name,
    COUNT(e.emp_id) AS employee_count,
    AVG(e.salary)   AS average_salary,
    MIN(e.salary)   AS minimum_salary,
    MAX(e.salary)   AS maximum_salary,
    SUM(e.salary)   AS total_salary
FROM Department d
JOIN Employee e
    ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name;

SELECT * FROM department_salary_summary;

-- 2. EMPLOYEE HIERARCHY VIEW
CREATE OR REPLACE VIEW employee_hierarchy AS
SELECT
    e.emp_id,
    e.emp_name,
    e.dept_id,
    d.dept_name,
    e.manager_id,
    m.emp_name AS manager_name,
    e.salary
FROM Employee e
JOIN Department d
    ON e.dept_id = d.dept_id
LEFT JOIN Employee m
    ON e.manager_id = m.emp_id;

SELECT * FROM employee_hierarchy;

-- 3. TEST UPDATABILITY OF VIEWS
-- 3a. Update through the join-based hierarchy view
UPDATE employee_hierarchy
SET salary = salary + 1000
WHERE emp_id = 6;

SELECT emp_id, emp_name, salary
FROM Employee
WHERE emp_id = 6;

-- 3b. Update through the grouped/aggregate view
--     (NOT updatable: GROUP BY + aggregate functions)
--     Uncomment to see the error; it will stop the script.
-- UPDATE department_salary_summary
-- SET average_salary = average_salary + 1000
-- WHERE dept_id = 1;

-- 4. RECURSIVE CTE - REPORTING CHAIN
WITH RECURSIVE reporting_chain AS (
    -- Anchor: top-level employees (no manager)
    SELECT
        e.emp_id,
        e.emp_name,
        e.manager_id,
        1 AS level,
        CAST(e.emp_name AS CHAR(500)) AS reporting_path
    FROM Employee e
    WHERE e.manager_id IS NULL

    UNION ALL

    -- Recursive step: employees reporting to the previous level
    SELECT
        e.emp_id,
        e.emp_name,
        e.manager_id,
        rc.level + 1,
        CONCAT(rc.reporting_path, ' -> ', e.emp_name)
    FROM Employee e
    JOIN reporting_chain rc
        ON e.manager_id = rc.emp_id
)
SELECT emp_id, emp_name, manager_id, level, reporting_path
FROM reporting_chain
ORDER BY reporting_path;