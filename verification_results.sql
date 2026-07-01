-- Task 4: Verification Queries.
-- Query your views and label each query with the question it answers.
-- Borough and zone names live in vw_dim_zones, so join on pickup_location_id = location_id.

-- 1. Volume: how many total rows in vw_fact_trips? How many rows per borough?
--    What is the most common pickup/dropoff location combination?
SELECT
    COUNT(*) AS total_rows
FROM vw_fact_trips;

SELECT
    z.borough,
    COUNT(*) AS row_count
FROM vw_fact_trips AS t
JOIN vw_dim_zones AS z
    ON t.pickup_location_id = z.location_id
GROUP BY
    z.borough
ORDER BY
    row_count DESC;

SELECT
    pickup_zones.zone AS pickup_zone,
    dropoff_zones.zone AS dropoff_zone,
    COUNT(*) AS row_count
FROM vw_fact_trips AS t
JOIN vw_dim_zones AS pickup_zones
    ON t.pickup_location_id = pickup_zones.location_id
JOIN vw_dim_zones AS dropoff_zones
    ON t.dropoff_location_id = dropoff_zones.location_id
GROUP BY
    pickup_zones.zone,
    dropoff_zones.zone
ORDER BY
    row_count DESC
LIMIT 1

-- (Take a screenshot of the per-borough counts and save it as assets/borough_count.png.)


-- 2. Revenue: which pickup zone (name, not ID) generated the highest total fare_amount?
--    Which pickup zone collected the highest total fare_amount on any single day?
SELECT
    z.zone AS pickup_zone,
    SUM(t.fare_amount) AS total_fare_amount
FROM vw_fact_trips AS t
JOIN vw_dim_zones AS z
    ON t.pickup_location_id = z.location_id
GROUP BY
    z.zone
ORDER BY
    total_fare_amount DESC
LIMIT 1;

SELECT
    CAST(t.pickup_datetime AS DATE) AS pickup_date,
    z.zone AS pickup_zone,
    SUM(t.fare_amount) AS total_fare_amount
FROM vw_fact_trips AS t
JOIN vw_dim_zones AS z
    ON t.pickup_location_id = z.location_id
GROUP BY
    CAST(t.pickup_datetime AS DATE),
    z.zone
ORDER BY
    total_fare_amount DESC
LIMIT 1;


-- 3. Geospatial: total number of trips and average trip_distance for each borough.
SELECT
    z.borough,
    COUNT(*) AS total_trips,
    AVG(t.trip_distance) AS avg_trip_distance
FROM vw_fact_trips AS t
JOIN vw_dim_zones AS z
    ON t.pickup_location_id = z.location_id
GROUP BY
    z.borough
ORDER BY
    total_trips DESC;


-- 4. Time patterns: which day of the week had the highest total tip_amount?
--    What hour of the day has the highest average tip?
SELECT
    TO_CHAR(pickup_datetime, 'Day') AS day_of_week,
    SUM(tip_amount) AS total_tip_amount
FROM vw_fact_trips
GROUP BY
    TO_CHAR(pickup_datetime, 'Day')
ORDER BY
    total_tip_amount DESC
LIMIT 1;

SELECT
    EXTRACT(HOUR FROM pickup_datetime) AS pickup_hour,
    AVG(tip_amount) AS avg_tip_amount
FROM vw_fact_trips
GROUP BY
    EXTRACT(HOUR FROM pickup_datetime)
ORDER BY
    avg_tip_amount DESC
LIMIT 1;
