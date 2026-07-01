-- Task 4: Verification Queries.
-- Query your views and label each query with the question it answers.
-- Borough and zone names live in vw_dim_zones, so join on pickup_location_id = location_id.

-- 1. Volume: how many total rows in vw_fact_trips? How many rows per borough?
--    What is the most common pickup/dropoff location combination?
SELECT
    COUNT(*) AS total_fact_trip_rows
FROM vw_fact_trips;
-- (Take a screenshot of the per-borough counts and save it as assets/borough_count.png.)

SELECT
    d.borough,
    COUNT(*) AS trip_count
FROM vw_fact_trips AS f
JOIN vw_dim_zones AS d
    ON f.pickup_location_id = d.location_id
GROUP BY d.borough
ORDER BY trip_count DESC;

SELECT 
    pickup_zone.zone AS pickup_zone,
    dropoff_zone.zone AS dropoff_zone,
    COUNT(*) AS trip_count
FROM vw_fact_trips AS f
JOIN vw_dim_zones AS pickup_zone
    ON f.pickup_location_id = pickup_zone.location_id
JOIN vw_dim_zones AS dropoff_zone
    ON f.dropoff_location_id = dropoff_zone.location_id
GROUP BY
    pickup_zone.zone,
    dropoff_zone.zone
ORDER BY trip_count DESC
LIMIT 1;

-- 2. Revenue: which pickup zone (name, not ID) generated the highest total fare_amount?
--    Which pickup zone collected the highest total fare_amount on any single day?
SELECT 
    d.zone AS pickup_zone,
    d.borough AS pickup_borough,
    SUM(f.fare_amount) AS total_fare_amount
FROM vw_fact_trips AS f
JOIN vw_dim_zones AS d
    ON f.pickup_location_id = d.location_id
GROUP BY
    d.zone,
    d.borough
ORDER BY total_fare_amount DESC
LIMIT 1;

SELECT 
    DATE(f.pickup_datetime) AS pickup_date,
    d.zone AS pickup_zone,
    d.borough AS pickup_borough,
    SUM(f.fare_amount) AS daily_total_fare_amount
FROM vw_fact_trips AS f
JOIN vw_dim_zones AS d
    ON f.pickup_location_id = d.location_id
GROUP BY
    DATE(f.pickup_datetime),
    d.zone,
    d.borough
ORDER BY daily_total_fare_amount DESC
LIMIT 1;


-- 3. Geospatial: total number of trips and average trip_distance for each borough.
SELECT
    d.borough,
    COUNT(*) AS trip_count,
    AVG(f.trip_distance) AS avg_trip_distance
FROM vw_fact_trips AS f
JOIN vw_dim_zones AS d
    ON f.pickup_location_id = d.location_id
GROUP BY d.borough
ORDER BY trip_count DESC;


-- 4. Time patterns: which day of the week had the highest total tip_amount?
--    What hour of the day has the highest average tip?
SELECT
    TO_CHAR(pickup_datetime, 'Day') AS day_of_week,
    SUM(tip_amount) AS total_tip_amount
FROM vw_fact_trips
GROUP BY TO_CHAR(pickup_datetime, 'Day')
ORDER BY total_tip_amount DESC
LIMIT 1;

SELECT
    DATE_PART('hour', pickup_datetime) AS pickup_hour,
    AVG(tip_amount) AS avg_tip_amount
FROM vw_fact_trips
GROUP BY DATE_PART('hour', pickup_datetime)
ORDER BY avg_tip_amount DESC
LIMIT 1;