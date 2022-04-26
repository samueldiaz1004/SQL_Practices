-- Practice 7: Fixing tables and data
-- Samuel Diaz del Guante Ochoa - A01637592

-- Create and import table data
CREATE TABLE meat_poultry_egg_establishments (
    establishment_number text CONSTRAINT est_number_key PRIMARY KEY,
    company text,
    street text,
    city text,
    st text,
    zip text,
    phone text,
    grant_date date,
    activities text,
    dbas text
);

COPY meat_poultry_egg_establishments
FROM 'C:\YourDirectory\MPI_Directory_by_Establishment_Name.csv'
WITH (FORMAT CSV, HEADER);

CREATE INDEX company_idx ON meat_poultry_egg_establishments (company);

-- Finding duplicates
-- Identify the columns
-- Use group by and having to select these columns
SELECT company,
       street,
       city,
       st,
       count(*) AS address_count
FROM meat_poultry_egg_establishments
GROUP BY company, street, city, st
HAVING count(*) > 1
ORDER BY company, street, city, st;

-- Find missing data (records with null values)
-- Group and count
-- Use null first on the order by
SELECT establishment_number,
       company,
       city,
       st,
       zip
FROM meat_poultry_egg_establishments
WHERE st IS NULL;

-- Constraints for some columns
-- Ex. zip lenght must be 5
SELECT st,
       count(*) AS st_count
FROM meat_poultry_egg_establishments
WHERE length(zip) < 5
GROUP BY st
ORDER BY st ASC;
  
-- Steps to fix the data

-- 1. Create a backup table
CREATE TABLE meat_poultry_egg_establishments_backup AS
SELECT * FROM meat_poultry_egg_establishments;

-- 2. If it is possible create a new column an work in the new column
ALTER TABLE meat_poultry_egg_establishments ADD COLUMN st_copy text;

UPDATE meat_poultry_egg_establishments
SET st_copy = st;

-- Update column values
UPDATE meat_poultry_egg_establishments
SET st = 'MN'
WHERE establishment_number = 'V18677A';

UPDATE meat_poultry_egg_establishments
SET st = 'AL'
WHERE establishment_number = 'M45319+P45319';

UPDATE meat_poultry_egg_establishments
SET st = 'WI'
WHERE establishment_number = 'M263A+P263A+V263A'
RETURNING establishment_number, company, city, st, zip;

-- Restoring from the table backup
UPDATE meat_poultry_egg_establishments original
SET st = backup.st
FROM meat_poultry_egg_establishments_backup backup
WHERE original.establishment_number = backup.establishment_number; 

-- Challenge
-- Add a new column meat_processing (bool)
-- where activities like '%Meat Processing'

-- My solution
ALTER TABLE meat_poultry_egg_establishments
ADD meat_processing bool;

update meat_poultry_egg_establishments
     set meat_processing = true
     where activities like '%Meat Processing%'
     
update meat_poultry_egg_establishments
     set meat_processing = false
     where meat_processing is null;
    
-- Second Example
-- Creating and filling a state_regions table
CREATE TABLE state_regions (
    st text CONSTRAINT st_key PRIMARY KEY,
    region text NOT NULL
);

COPY state_regions
FROM '/workspace/sql_practices/practical-sql-2/Chapter_10/state_regions.csv'
WITH (FORMAT CSV, HEADER);

-- Adding and updating an inspection_deadline column

ALTER TABLE meat_poultry_egg_establishments
    ADD COLUMN inspection_deadline timestamp with time zone;

UPDATE meat_poultry_egg_establishments establishments
SET inspection_deadline = '2022-12-01 00:00 EST'
WHERE EXISTS (SELECT state_regions.region
              FROM state_regions
              WHERE establishments.st = state_regions.st 
                    AND state_regions.region = 'New England');
                    
-- Deleting rows matching an expression

DELETE FROM meat_poultry_egg_establishments
WHERE st IN('AS','GU','MP','PR','VI');

-- Removing a column from a table using DROP

ALTER TABLE meat_poultry_egg_establishments DROP COLUMN zip_copy;

-- Removing a table from a database using DROP

DROP TABLE meat_poultry_egg_establishments_backup;

-- TRANSACTIONS

-- Use transactions everytime you are updating your data
-- Start transaction and perform update
START TRANSACTION;

UPDATE meat_poultry_egg_establishments
SET company = 'AGRO Merchantss Oakland LLC'
WHERE company = 'AGRO Merchants Oakland, LLC';

-- view changes
SELECT company
FROM meat_poultry_egg_establishments
WHERE company LIKE 'AGRO%'
ORDER BY company;

-- Revert changes
ROLLBACK;

-- See restored state
SELECT company
FROM meat_poultry_egg_establishments
WHERE company LIKE 'AGRO%'
ORDER BY company;

-- Alternately, commit changes at the end:
START TRANSACTION;

UPDATE meat_poultry_egg_establishments
SET company = 'AGRO Merchants Oakland LLC'
WHERE company = 'AGRO Merchants Oakland, LLC';

COMMIT;

-- Backing up a table while adding and filling a new column
CREATE TABLE meat_poultry_egg_establishments_backup AS
SELECT *,
       '2023-02-14 00:00 EST'::timestamp with time zone AS reviewed_date
FROM meat_poultry_egg_establishments;

-- Swapping table names using ALTER TABLE
ALTER TABLE meat_poultry_egg_establishments 
    RENAME TO meat_poultry_egg_establishments_temp;
ALTER TABLE meat_poultry_egg_establishments_backup 
    RENAME TO meat_poultry_egg_establishments;
ALTER TABLE meat_poultry_egg_establishments_temp 
    RENAME TO meat_poultry_egg_establishments_backup;
