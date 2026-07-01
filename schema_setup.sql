-- Task 2: Star Schema Views (create these in YOUR OWN schema, not public).
-- CREATE OR REPLACE VIEW lets you re-run this script while you iterate.

-- Dimension: one row per location_id. Treat location_id as the primary key.
CREATE OR REPLACE VIEW vw_dim_zones AS
SELECT
    location_id,
    borough,
    zone,
    service_zone
FROM nyc_taxi.raw_zones;

-- Fact: one row per taxi trip.
-- Negative fare_amount rows are excluded.
-- pickup_datetime is explicitly cast as TIMESTAMP.
CREATE OR REPLACE VIEW vw_fact_trips AS
SELECT
    vendor_id,
    pickup_datetime::TIMESTAMP AS pickup_datetime,
    dropoff_datetime::TIMESTAMP AS dropoff_datetime,
    passenger_count,
    trip_distance,
    pickup_location_id,
    dropoff_location_id,
    fare_amount,
    extra,
    mta_tax,
    tip_amount,
    tolls_amount,
    improvement_surcharge,
    total_amount,
    payment_type,
    trip_type
FROM nyc_taxi.raw_trips
WHERE fare_amount >= 0;


-- Verification: fact view row count after removing negative fares.
SELECT COUNT(*) AS fact_trip_count
FROM vw_fact_trips;


-- Verification: join-readiness test.
SELECT COUNT(*) AS joined_trip_count
FROM vw_fact_trips AS f
INNER JOIN vw_dim_zones AS d
    ON f.pickup_location_id = d.location_id;
