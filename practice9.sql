-- Practice 9: Subquery
-- Samuel Diaz del Guante Ochoa - A01637592

-- Use subqueries in the WHERE clause
SELECT county_name,
       state_name,
       pop_est_2019
FROM us_counties_pop_est_2019
WHERE pop_est_2019 >= (
    SELECT percentile_cont(.9) WITHIN GROUP (ORDER BY pop_est_2019)
    FROM us_counties_pop_est_2019
    )
ORDER BY pop_est_2019 DESC;

-- Use subqueries in FROM
SELECT round(calcs.average, 0) as average,
       calcs.median,
       round(calcs.average - calcs.median, 0) AS median_average_diff
FROM (
     SELECT avg(pop_est_2019) AS average,
            percentile_cont(.5)
                WITHIN GROUP (ORDER BY pop_est_2019)::numeric AS median
     FROM us_counties_pop_est_2019
     )
AS calcs;

-- Use subqueries in JOIN
SELECT census.state_name AS st,
       census.pop_est_2018,
       est.establishment_count,
       round((est.establishment_count/census.pop_est_2018::numeric) * 1000, 1)
           AS estabs_per_thousand
FROM
    (
         SELECT st,
                sum(establishments) AS establishment_count
         FROM cbp_naics_72_establishments
         GROUP BY st
    )
    AS est
JOIN
    (
        SELECT state_name,
               sum(pop_est_2018) AS pop_est_2018
        FROM us_counties_pop_est_2019
        GROUP BY state_name
    )
    AS census
ON est.st = census.state_name
ORDER BY estabs_per_thousand DESC;

-- Use subqueries as part of a calculation
SELECT county_name,
       state_name AS st,
       pop_est_2019,
       pop_est_2019 - (SELECT percentile_cont(.5) WITHIN GROUP (ORDER BY pop_est_2019)
                       FROM us_counties_pop_est_2019) AS diff_from_median
FROM us_counties_pop_est_2019
WHERE (pop_est_2019 - (SELECT percentile_cont(.5) WITHIN GROUP (ORDER BY pop_est_2019)
                       FROM us_counties_pop_est_2019))
       BETWEEN -1000 AND 1000;
       
-- Create and fill the retirees table
CREATE TABLE retirees (
    id int,
    first_name text,
    last_name text
);

INSERT INTO retirees
VALUES (2, 'Janet', 'King'),
       (4, 'Michael', 'Taylor');
       
-- Check if employees are in the table rettirees
SELECT first_name, last_name
FROM employees
WHERE emp_id IN (
    SELECT id
    FROM retirees)
ORDER BY emp_id;

-- 'EXISTS' is similar to the 'IN' operator but covers the edge case of NULL values
SELECT first_name, last_name
FROM employees
WHERE EXISTS (
    SELECT id
    FROM retirees
    WHERE id = employees.emp_id);
    
SELECT first_name, last_name
FROM employees
WHERE NOT EXISTS (
    SELECT id
    FROM retirees
    WHERE id = employees.emp_id);

-- Example of a LATERAL subqueries in the FROM clause
SELECT county_name,
       state_name,
       pop_est_2018,
       pop_est_2019,
       raw_chg,
       round(pct_chg * 100, 2) AS pct_chg
FROM us_counties_pop_est_2019,
     LATERAL (SELECT pop_est_2019 - pop_est_2018 AS raw_chg) rc,
     LATERAL (SELECT raw_chg / pop_est_2018::numeric AS pct_chg) pc
ORDER BY pct_chg DESC;

-- Common table expressions are temporal tables created as a subquery

-- WITH temporal_table_name(c1,c2,c3...)
-- (subquery)
-- SELECT...

-- Example: Counties and establishments tables are temporary
-- Once the query ends; the counties and establishments tables will dissapear
-- Improves performance since each query runs async
WITH
    counties (st, pop_est_2018) AS
    (SELECT state_name, sum(pop_est_2018)
     FROM us_counties_pop_est_2019
     GROUP BY state_name),

    establishments (st, establishment_count) AS
    (SELECT st, sum(establishments) AS establishment_count
     FROM cbp_naics_72_establishments
     GROUP BY st)

SELECT counties.st,
       pop_est_2018,
       establishment_count,
       round((establishments.establishment_count / 
              counties.pop_est_2018::numeric(10,1)) * 1000, 1)
           AS estabs_per_thousand
FROM counties JOIN establishments
ON counties.st = establishments.st
ORDER BY estabs_per_thousand DESC;
