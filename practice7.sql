-- Practice 7: Fixing tables and data
-- Samuel Diaz del Guante Ochoa - A01637592

-- Finding duplicates
-- Identify the columns
-- Use group by and having to select these columns

-- Find missing data (records with null values)
-- Group and count
-- Use null first on the order by

-- Constraints for some columns
-- Ex. zip lenght must be 5
  
-- Steps to fix the data
-- 1. Create a backup table
-- 2. If it is possible create a new column an work in the new column

-- Challenge
-- Add a new column meat_processing (bool)
-- where activities like '%Meat Processing'

ALTER TABLE meat_poultry_egg_establishments
ADD meat_processing bool;

update meat_poultry_egg_establishments
     set meat_processing = true
     where activities like '%Meat Processing%'
     
update meat_poultry_egg_establishments
     set meat_processing = false
     where meat_processing is null;
