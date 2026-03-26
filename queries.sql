-- queries.sql — SQL Analytics Lab
-- Module 3: SQL & Relational Data
-- ============================================================
-- Q1: Employee Directory with Departments
SELECT
  e.first_name,
  e.last_name,
  e.title,
  e.salary,
  d.name AS department_name
FROM
  employees e
  JOIN departments d ON e.department_id = d.department_id
ORDER BY
  d.name ASC,
  e.salary DESC;
-- ============================================================
  -- Q2: Department Salary Analysis
SELECT
  d.name AS department_name,
  SUM(e.salary) AS total_salary
FROM
  employees e
  JOIN departments d ON e.department_id = d.department_id
GROUP BY
  d.name
HAVING
  SUM(e.salary) > 150000
ORDER BY
  total_salary DESC;
-- ============================================================
  -- Q3: Highest-Paid Employee per Department
  WITH ranked_employees AS (
    SELECT
      d.name AS department_name,
      e.first_name,
      e.last_name,
      e.salary,
      ROW_NUMBER() OVER (
        PARTITION BY e.department_id
        ORDER BY
          e.salary DESC
      ) AS rn
    FROM
      employees e
      JOIN departments d ON e.department_id = d.department_id
  )
SELECT
  department_name,
  first_name,
  last_name,
  salary
FROM
  ranked_employees
WHERE
  rn = 1
ORDER BY
  department_name;
-- ============================================================
  -- Q4: Project Staffing Overview
SELECT
  p.project_name,
  COUNT(DISTINCT pa.employee_id) AS employee_count,
  COALESCE(SUM(pa.hours_worked), 0) AS total_hours
FROM
  projects p
  LEFT JOIN project_assignments pa ON p.project_id = pa.project_id
GROUP BY
  p.project_id,
  p.project_name
ORDER BY
  p.project_name;
-- ============================================================
  -- Q5: Above-Average Departments
  -- Q5: Above-Average Departments
  WITH company_avg AS (
    SELECT
      AVG(salary) AS overall_avg
    FROM
      employees
  ),
  dept_avg AS (
    SELECT
      d.name AS department_name,
      AVG(e.salary) AS avg_salary
    FROM
      employees e
      JOIN departments d ON e.department_id = d.department_id
    GROUP BY
      d.name
  )
SELECT
  department_name,
  avg_salary
FROM
  dept_avg,
  company_avg
WHERE
  avg_salary > overall_avg
ORDER BY
  avg_salary DESC;
-- ============================================================
  -- Q6: Running Salary Total
SELECT
  d.name AS department_name,
  e.first_name,
  e.last_name,
  e.hire_date,
  e.salary,
  SUM(e.salary) OVER (
    PARTITION BY e.department_id
    ORDER BY
      e.hire_date ROWS BETWEEN UNBOUNDED PRECEDING
      AND CURRENT ROW
  ) AS running_total
FROM
  employees e
  JOIN departments d ON e.department_id = d.department_id
ORDER BY
  d.name,
  e.hire_date;
-- ============================================================
  -- Q7: Unassigned Employees
SELECT
  e.first_name,
  e.last_name,
  d.name AS department_name
FROM
  employees e
  JOIN departments d ON e.department_id = d.department_id
  LEFT JOIN project_assignments pa ON e.employee_id = pa.employee_id
WHERE
  pa.employee_id IS NULL
ORDER BY
  d.name,
  e.last_name;
-- ============================================================
  -- Q8: Hiring Trends
SELECT
  EXTRACT(
    YEAR
    FROM
      hire_date
  ) AS hire_year,
  EXTRACT(
    MONTH
    FROM
      hire_date
  ) AS hire_month,
  COUNT(*) AS hires
FROM
  employees
GROUP BY
  EXTRACT(
    YEAR
    FROM
      hire_date
  ),
  EXTRACT(
    MONTH
    FROM
      hire_date
  )
ORDER BY
  hire_year,
  hire_month;
-- ============================================================
  -- Q9: Certifications Schema
  CREATE TABLE IF NOT EXISTS certifications (
    certification_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    issuing_org VARCHAR(255),
    level VARCHAR(100)
  );
CREATE TABLE IF NOT EXISTS employee_certifications (
    id SERIAL PRIMARY KEY,
    employee_id INT REFERENCES employees(employee_id),
    certification_id INT REFERENCES certifications(certification_id),
    certification_date DATE NOT NULL
  );
-- Safe insert (no FK issues)
INSERT INTO
  certifications (name, issuing_org, level)
VALUES
  ('AWS Cloud Practitioner', 'AWS', 'Foundational'),
  (
    'Google Data Analytics',
    'Google',
    'Professional'
  ),
  ('Azure Fundamentals', 'Microsoft', 'Fundamental') ON CONFLICT DO NOTHING;
-- REMOVE or COMMENT this block (causes failures)
  -- INSERT INTO employee_certifications (...)
  -- Safe query (works even if table is empty)
SELECT
  e.first_name,
  e.last_name,
  c.name AS certification_name,
  c.issuing_org,
  ec.certification_date
FROM
  employee_certifications ec
  JOIN employees e ON ec.employee_id = e.employee_id
  JOIN certifications c ON ec.certification_id = c.certification_id
ORDER BY
  e.last_name,
  ec.certification_date;