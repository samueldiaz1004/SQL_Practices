-- Practice 11 - Data mining
-- Samuel Alejandro Díaz del Guante Ochoa

-- Regular expressions are a sequence of characters that specifies a search pattern in text. 
-- Usually such patterns are used by string-searching algorithms for "find" or "find and replace" 
-- operations on strings, or for input validation.

-- Test and practice regular expressions
-- https://regex101.com/

-- Regular Expression Matching Examples

-- Any character one or more times
SELECT substring('The game starts at 7 p.m. on May 2, 2024.' from '.+');
-- One or two digits followed by a space and a.m. or p.m. in a noncapture group
SELECT substring('The game starts at 7 p.m. on May 2, 2024.' from '\d{1,2} (?:a.m.|p.m.)');
-- One or more word characters at the start
SELECT substring('The game starts at 7 p.m. on May 2, 2024.' from '^\w+');
-- One or more word characters followed by any character at the end.
SELECT substring('The game starts at 7 p.m. on May 2, 2024.' from '\w+.$');
-- The words May or June
SELECT substring('The game starts at 7 p.m. on May 2, 2024.' from 'May|June');
-- Four digits
SELECT substring('The game starts at 7 p.m. on May 2, 2024.' from '\d{4}');
-- May followed by a space, digit, comma, space, and four digits.
SELECT substring('The game starts at 7 p.m. on May 2, 2024.' from 'May \d, \d{4}');

-- Regular expressions in a WHERE clause with '~*' (like) and '|~' (not)
SELECT county_name
FROM us_counties_pop_est_2019
WHERE county_name ~* '(lade|lare)'
ORDER BY county_name;

SELECT county_name
FROM us_counties_pop_est_2019
WHERE county_name ~* 'ash' AND county_name !~ 'Wash'
ORDER BY county_name;

-- Creating and loading the crime_reports table
CREATE TABLE crime_reports (
    crime_id integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    case_number text,
    date_1 timestamptz,  -- Shortcut for timestamp with time zone
    date_2 timestamptz,  -- Shortcut for timestamp with time zone
    street text,
    city text,
    crime_type text,
    description text,
    original_text text NOT NULL
);

COPY crime_reports (original_text)
FROM '/workspace/sql_practices/crime_reports.csv'
WITH (FORMAT CSV, HEADER OFF, QUOTE '"');

-- Use regexp_match() to find the first date
Using regexp_match() to find the first date
SELECT crime_id,
       regexp_match(original_text, '\d{1,2}\/\d{1,2}\/\d{2}')
FROM crime_reports
ORDER BY crime_id;

-- Use regexp_match() to determine the city
SELECT regexp_match(original_text, '(?:Sq.|Plz.|Dr.|Ter.|Rd.)\n(\w+ \w+|\w+)\n') FROM crime_reports;
-- Use regexp_match() to find case number
SELECT regexp_match(original_text, '(?:C0|SO)[0-9]+)') FROM crime_reports;
