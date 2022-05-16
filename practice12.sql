-- Practice 12 - Views and materialized views
-- Samuel Alejandro Díaz del Guante Ochoa

-- View: the query is stored. It does not need to be updated everytime like the materialized view.
-- Materialized view: the information is stored. It is more efficient and fast than the view but needs to be refreshed periodically

-- Create a view from an existing table
CREATE OR REPLACE VIEW nevada_counties_pop_2019 AS
    SELECT county_name,
           state_fips,
           county_fips,
           pop_est_2019
    FROM us_counties_pop_est_2019
    WHERE state_name = 'Nevada';
    
-- Query the view
SELECT *
FROM nevada_counties_pop_2019
ORDER BY county_fips
LIMIT 5;

-- Update the view
CREATE OR REPLACE VIEW county_pop_change_2019_2010 AS
    SELECT c2019.county_name,
           c2019.state_name,
           c2019.state_fips,
           c2019.county_fips,
           c2019.pop_est_2019 AS pop_2019,
           c2010.estimates_base_2010 AS pop_2010,
           round( (c2019.pop_est_2019::numeric - c2010.estimates_base_2010)
               / c2010.estimates_base_2010 * 100, 1 ) AS pct_change_2019_2010
    FROM us_counties_pop_est_2019 AS c2019
        JOIN us_counties_pop_est_2010 AS c2010
    ON c2019.state_fips = c2010.state_fips
        AND c2019.county_fips = c2010.county_fips;
        
-- Drop the view
DROP VIEW nevada_counties_pop_2019;

-- Create materialized view
CREATE MATERIALIZED VIEW nevada_counties_pop_2019 AS
    SELECT county_name,
           state_fips,
           county_fips,
           pop_est_2019
    FROM us_counties_pop_est_2019
    WHERE state_name = 'Nevada';
    
-- Refresh a materialized view 
REFRESH MATERIALIZED VIEW nevada_counties_pop_2019;

-- Optionally add the CONCURRENTLY keyword to prevent locking out SELECTs
-- while the view refresh is in progress. To use CONCURRENTLY, the view must
-- have at least one UNIQUE index:
CREATE UNIQUE INDEX nevada_counties_pop_2019_fips_idx ON nevada_counties_pop_2019 (state_fips, county_fips);
REFRESH MATERIALIZED VIEW CONCURRENTLY nevada_counties_pop_2019;

-- Drop a materialized view
DROP MATERIALIZED VIEW nevada_counties_pop_2019;

-- Create another view
CREATE OR REPLACE VIEW employees_tax_dept WITH (security_barrier) AS
     SELECT emp_id,
            first_name,
            last_name,
            dept_id
     FROM employees
     WHERE dept_id = 1
     WITH LOCAL CHECK OPTION;
     
-- Changes made in the view will be reflected in the original table
INSERT INTO employees_tax_dept (emp_id, first_name, last_name, dept_id)
VALUES (5, 'Suzanne', 'Legere', 1);

INSERT INTO employees_tax_dept (emp_id, first_name, last_name, dept_id)
VALUES (6, 'Jamil', 'White', 2);

SELECT * FROM employees_tax_dept ORDER BY emp_id;

SELECT * FROM employees ORDER BY emp_id;

-- Update row from the view
UPDATE employees_tax_dept
SET last_name = 'Le Gere'
WHERE emp_id = 5;

-- Delete row from the view
DELETE FROM employees_tax_dept
WHERE emp_id = 5;
