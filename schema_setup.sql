-- Task 2: Star Schema Views (create these in YOUR OWN schema, not public).
-- CREATE OR REPLACE VIEW lets you re-run this script while you iterate.

-- Dimension: one row per location_id. Treat location_id as the primary key.
-- TODO: complete the SELECT (location_id, zone, borough).
CREATE OR REPLACE VIEW vw_dim_zones AS
SELECT
    rz.location_id,
    rz.zone,
    rz.borough
FROM nyc_taxi.raw_zones ;

;

-- Fact: one row per taxi trip.
--   - Exclude rows where fare_amount is less than 0.
--   - Cast pickup_datetime to TIMESTAMP.
--   - Keep the location IDs so the view can join to vw_dim_zones.
-- TODO: complete the SELECT and the WHERE.
CREATE OR REPLACE VIEW vw_fact_trips AS
SELECT
    vendor_id,
    pickup_datetime::timestamp AS pickup_datetime,
    dropoff_datetime,
    passenger_count,
    pickup_location_id,
    dropoff_location_id,
    trip_distance,
    fare_amount,
    tip_amount,
    payment_type
FROM nyc_taxi.raw_trips
WHERE fare_amount >= 0;

-- Join-readiness test (run after creating the views; it must run without error
-- and return a count close to the vw_fact_trips row count):
-- SELECT COUNT(*) FROM vw_fact_trips f
-- JOIN vw_dim_zones d ON f.pickup_location_id = d.location_id;

select * from vw_fact_trips f
join vw_dim_zones d on f.pickup_location_id = d.location_id;   



