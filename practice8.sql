-- Practice 8: Date and time
-- Samuel Diaz del Guante Ochoa - A01637592

-- Extracting components of a timestamp value using date_part()
-- Some interesting values are timezone_hour and epoch (seconds)
SELECT
    date_part('year', '2022-12-01 18:37:12 EST'::timestamptz) AS year,
    date_part('month', '2022-12-01 18:37:12 EST'::timestamptz) AS month,
    date_part('day', '2022-12-01 18:37:12 EST'::timestamptz) AS day,
    date_part('hour', '2022-12-01 18:37:12 EST'::timestamptz) AS hour,
    date_part('minute', '2022-12-01 18:37:12 EST'::timestamptz) AS minute,
    date_part('seconds', '2022-12-01 18:37:12 EST'::timestamptz) AS seconds,
    date_part('timezone_hour', '2022-12-01 18:37:12 EST'::timestamptz) AS tz,
    date_part('week', '2022-12-01 18:37:12 EST'::timestamptz) AS week,
    date_part('quarter', '2022-12-01 18:37:12 EST'::timestamptz) AS quarter,
    date_part('epoch', '2022-12-01 18:37:12 EST'::timestamptz) AS epoch;
    
-- Make a date (format 2022-02-22)
SELECT make_date(2022, 2, 22);
-- Make a time (format 18:04:30.3)
SELECT make_time(18, 4, 30.3);
-- Make a timestamp with time zone (Combine previous two formats)
SELECT make_timestamptz(2022, 2, 22, 18, 4, 30.3, 'Europe/Lisbon');

-- Insert multiple current_timestamp and clock_timestamp and compare their format
CREATE TABLE current_time_example (
    time_id integer GENERATED ALWAYS AS IDENTITY,
    current_timestamp_col timestamptz,
    clock_timestamp_col timestamptz
);

INSERT INTO current_time_example
            (current_timestamp_col, clock_timestamp_col)
    (SELECT current_timestamp,
            clock_timestamp()
     FROM generate_series(1,1000));

SELECT * FROM current_time_example;

-- Show timezone names and abbreviations
SELECT * FROM pg_timezone_abbrevs ORDER BY abbrev;
SELECT * FROM pg_timezone_names ORDER BY name;

-- Find a specific timezone range
SELECT * FROM pg_timezone_names
WHERE name LIKE 'Europe%'
ORDER BY name;

-- Timezone inserts can change dinamically depending on the set timezone
SET TIME ZONE 'US/Pacific';

CREATE TABLE time_zone_test (
    test_date timestamptz
);
INSERT INTO time_zone_test VALUES ('2023-01-01 4:00');

SELECT test_date
FROM time_zone_test;

SET TIME ZONE 'US/Eastern';

SELECT test_date
FROM time_zone_test;

SELECT test_date AT TIME ZONE 'Asia/Seoul'
FROM time_zone_test;

-- Do math operations with dates
-- Operate two different dates
SELECT '1929-09-30'::date - '1929-09-27'::date;
-- Operate a date by adding/substracting days/months/years/etc
SELECT '1929-09-30'::date + '5 years'::interval;

-- Create a table and importing NYC yellow taxi data and indexing it
CREATE TABLE nyc_yellow_taxi_trips (
    trip_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    vendor_id text NOT NULL,
    tpep_pickup_datetime timestamptz NOT NULL,
    tpep_dropoff_datetime timestamptz NOT NULL,
    passenger_count integer NOT NULL,
    trip_distance numeric(8,2) NOT NULL,
    pickup_longitude numeric(18,15) NOT NULL,
    pickup_latitude numeric(18,15) NOT NULL,
    rate_code_id text NOT NULL,
    store_and_fwd_flag text NOT NULL,
    dropoff_longitude numeric(18,15) NOT NULL,
    dropoff_latitude numeric(18,15) NOT NULL,
    payment_type text NOT NULL,
    fare_amount numeric(9,2) NOT NULL,
    extra numeric(9,2) NOT NULL,
    mta_tax numeric(5,2) NOT NULL,
    tip_amount numeric(9,2) NOT NULL,
    tolls_amount numeric(9,2) NOT NULL,
    improvement_surcharge numeric(9,2) NOT NULL,
    total_amount numeric(9,2) NOT NULL
);

COPY nyc_yellow_taxi_trips (
    vendor_id,
    tpep_pickup_datetime,
    tpep_dropoff_datetime,
    passenger_count,
    trip_distance,
    pickup_longitude,
    pickup_latitude,
    rate_code_id,
    store_and_fwd_flag,
    dropoff_longitude,
    dropoff_latitude,
    payment_type,
    fare_amount,
    extra,
    mta_tax,
    tip_amount,
    tolls_amount,
    improvement_surcharge,
    total_amount
   )
FROM '/workspace/sql_practices/nyc_yellow_taxi_trips.csv'
WITH (FORMAT CSV, HEADER);

CREATE INDEX tpep_pickup_idx
ON nyc_yellow_taxi_trips (tpep_pickup_datetime);

-- Set a timezone that corresponds with the local nyc timezone
SET TIME ZONE 'US/Eastern';

-- Query taxi pickups per hour
SELECT
	date_part('hour', tpep_pickup_datetime) AS trip_hour,
	count(*)
FROM nyc_yellow_taxi_trips
GROUP BY trip_hour
ORDER BY trip_hour

-- Query the median trip time by hour
-- Postgres does not have a median function but it can be achived using 'percentile_cont(.5)'
SELECT
    date_part('hour', tpep_pickup_datetime) AS trip_hour,
    percentile_cont(.5)
        WITHIN GROUP (ORDER BY
            tpep_dropoff_datetime - tpep_pickup_datetime) AS median_trip
FROM nyc_yellow_taxi_trips
GROUP BY trip_hour
ORDER BY trip_hour;

-- CHALLENGE
-- Calculate the duration of each ride and query from shortest from the longest to the shortest

-- My solution
SELECT trip_id, (tpep_dropoff_datetime - tpep_pickup_datetime) as ride_duration
from nyc_yellow_taxi_trips
order by ride_duration desc;
