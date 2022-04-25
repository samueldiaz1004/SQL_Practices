-- Practice 6: Data index
-- Samuel Díaz del Guante - A01637592

-- Indexes are special lookup tables that the database search engine can use to speed up data retrieval. 
-- An index is a pointer to data in a table.

CREATE TABLE new_york_addresses (
    longitude numeric(9,6),
    latitude numeric(9,6),
    street_number text,
    street text,
    unit text,
    postcode text,
    id integer CONSTRAINT new_york_key PRIMARY KEY
);

-- Import csv file to table
COPY new_york_addresses
FROM 'C:\YourDirectory\city_of_new_york.csv'
WITH (FORMAT CSV, HEADER);

-- Benchmark queries for index performance
EXPLAIN ANALYZE SELECT * FROM new_york_addresses
WHERE street = 'BROADWAY';

EXPLAIN ANALYZE SELECT * FROM new_york_addresses
WHERE street = '52 STREET';

EXPLAIN ANALYZE SELECT * FROM new_york_addresses
WHERE street = 'ZWICKY AVENUE';

-- Creating a index on the new_york_addresses table
-- It improves query performance
CREATE INDEX street_idx ON new_york_addresses (street);