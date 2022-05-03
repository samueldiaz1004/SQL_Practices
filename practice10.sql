-- Practice 10 - Extensions
-- Samuel Alejandro Díaz del Guante Ochoa

-- An extension adds new functions to perform more queries or simplify an existing query

-- Add an extension "Cross tabulations"
CREATE EXTENSION tablefunc;

-- Create dataset
CREATE TABLE ice_cream_survey (
    response_id integer PRIMARY KEY,
    office text,
    flavor text
);

COPY ice_cream_survey
FROM '/workspace/sql_practices/ice_cream_survey.csv'
WITH (FORMAT CSV, HEADER);

-- Example of the extension in use
-- Anchor a pivot to organize columns and rows
-- Columm: office, Row: flavor
SELECT *
FROM crosstab('SELECT office,
                      flavor,
                      count(*)
               FROM ice_cream_survey
               GROUP BY office, flavor
               ORDER BY office',

              'SELECT flavor
               FROM ice_cream_survey
               GROUP BY flavor
               ORDER BY flavor')

AS (office text,
    chocolate bigint,
    strawberry bigint,
    vanilla bigint);
    
-- Columm: flavor, Row: office
SELECT *
FROM crosstab('SELECT flavor,
                      office,
                      count(*)
               FROM ice_cream_survey
               GROUP BY flavor, office
               ORDER BY flavor',

              'SELECT office
               FROM ice_cream_survey
               GROUP BY office
               ORDER BY office')

AS (flavor text,
    Downtown bigint,
    Midtown bigint,
    Uptown bigint);

-- Create temperature readings table
CREATE TABLE temperature_readings (
    station_name text,
    observation_date date,
    max_temp integer,
    min_temp integer,
    CONSTRAINT temp_key PRIMARY KEY (station_name, observation_date)
);

COPY temperature_readings
FROM '/workspace/sql_practices/temperature_readings.csv'
WITH (FORMAT CSV, HEADER);

-- Example of another crosstab in use
SELECT *
FROM crosstab('SELECT
                  station_name,
                  date_part(''month'', observation_date),
                  percentile_cont(.5)
                      WITHIN GROUP (ORDER BY max_temp)
               FROM temperature_readings
               GROUP BY station_name,
                        date_part(''month'', observation_date)
               ORDER BY station_name',

              'SELECT month
               FROM generate_series(1,12) month')

AS (station text,
    jan numeric(3,0),
    feb numeric(3,0),
    mar numeric(3,0),
    apr numeric(3,0),
    may numeric(3,0),
    jun numeric(3,0),
    jul numeric(3,0),
    aug numeric(3,0),
    sep numeric(3,0),
    oct numeric(3,0),
    nov numeric(3,0),
    dec numeric(3,0)
);
