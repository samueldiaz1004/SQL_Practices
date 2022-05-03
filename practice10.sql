-- Practice 10 - Extensions
-- Samuel Alejandro Díaz del Guante Ochoa

-- Add an extension
CREATE EXTENSION tablefunc;

-- Create dataset
CREATE TABLE ice_cream_survey (
    response_id integer PRIMARY KEY,
    office text,
    flavor text
);

COPY ice_cream_survey
FROM 'C:\YourDirectory\ice_cream_survey.csv'
WITH (FORMAT CSV, HEADER);
