-- ============================================================
-- Experiment 4: Joins, Subqueries, EXISTS, Simulated
--               INTERSECT / EXCEPT, EXPLAIN
-- Name: Tharun Dev M C | UID: 25LBCS3324
-- Prerequisite: Experiment 3 schema + data (EmployeeDB)
-- ============================================================

USE EmployeeDB;

-- 1. INNER JOIN
SELECT e.emp_name, d.dept_name
FROM Employee e
INNER JOIN Department d
    ON e.dept_id = d.dept_id;

-- 2. LEFT JOIN
SELECT d.dept_name, e.emp_name
FROM Department d
LEFT JOIN Employee e
    ON d.dept_id = e.dept_id;

-- 3. SELF JOIN (pairs of employees in the same department)
SELECT
    e1.emp_name AS employee_1,
    e2.emp_name AS employee_2,
    e1.dept_id
FROM Employee e1
JOIN Employee e2
    ON e1.dept_id = e2.dept_id
   AND e1.emp_id < e2.emp_id;

-- 4. 3-WAY JOIN
SELECT e.emp_name, d.dept_name, p.project_name, e.salary
FROM Employee e
JOIN Department d
    ON e.dept_id = d.dept_id
JOIN Project p
    ON e.project_id = p.project_id;

-- 5. CORRELATED SUBQUERY (salary above own department average)
SELECT e.emp_name, e.salary, e.dept_id
FROM Employee e
WHERE e.salary >
(
    SELECT AVG(e2.salary)
    FROM Employee e2
    WHERE e2.dept_id = e.dept_id
);

-- 6. EXISTS (departments having an employee earning > 90000)
SELECT d.dept_id, d.dept_name
FROM Department d
WHERE EXISTS
(
    SELECT 1
    FROM Employee e
    WHERE e.dept_id = d.dept_id
      AND e.salary > 90000
);

-- 7. SIMULATED INTERSECT (dept 2 AND salary > 70000)
SELECT e.emp_id, e.emp_name
FROM Employee e
WHERE e.dept_id = 2
  AND e.emp_id IN
(
    SELECT emp_id
    FROM Employee
    WHERE salary > 70000
);

-- 8. SIMULATED EXCEPT (dept 2 but NOT salary > 70000)
SELECT emp_id, emp_name
FROM Employee
WHERE dept_id = 2
  AND emp_id NOT IN
(
    SELECT emp_id
    FROM Employee
    WHERE salary > 70000
);

-- 9. EXPLAIN - INNER JOIN
EXPLAIN
SELECT e.emp_name, d.dept_name
FROM Employee e
INNER JOIN Department d
    ON e.dept_id = d.dept_id;

-- 10. EXPLAIN - LEFT JOIN
EXPLAIN
SELECT d.dept_name, e.emp_name
FROM Department d
LEFT JOIN Employee e
    ON d.dept_id = e.dept_id;