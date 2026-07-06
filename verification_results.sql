-- Task 4: Verification Queries.
-- Query your views and label each query with the question it answers.
-- Borough and zone names live in vw_dim_zones, so join on pickup_location_id = location_id.

-- 1. Volume: how many total rows in vw_fact_trips? How many rows per borough?
--    What is the most common pickup/dropoff location combination?
-- TODO
SELECT COUNT(*) AS total_trips
FROM vw_fact_trips;
SELECT
    d.borough,
    COUNT(*) AS trip_count
FROM vw_fact_trips f
JOIN vw_dim_zones d
    ON f.pickup_location_id = d.location_id
GROUP BY d.borough
ORDER BY trip_count DESC;
SELECT
    pickup_location_id,
    dropoff_location_id,
    COUNT(*) AS trip_count
FROM vw_fact_trips
GROUP BY
    pickup_location_id,
    dropoff_location_id
ORDER BY trip_count DESC
LIMIT 1;

-- (Take a screenshot of the per-borough counts and save it as assets/borough_count.png.)


-- 2. Revenue: which pickup zone (name, not ID) generated the highest total fare_amount?
--    Which pickup zone collected the highest total fare_amount on any single day?
-- TODO
SELECT
    d.zone,
    SUM(f.fare_amount) AS total_revenue
FROM vw_fact_trips f
JOIN vw_dim_zones d
    ON f.pickup_location_id = d.location_id
GROUP BY d.zone
ORDER BY total_revenue DESC
LIMIT 1;
SELECT
    d.zone,
    DATE(f.pickup_datetime) AS trip_date,
    SUM(f.fare_amount) AS total_revenue
FROM vw_fact_trips f
JOIN vw_dim_zones d
    ON f.pickup_location_id = d.location_id
GROUP BY
    d.zone,
    DATE(f.pickup_datetime)
ORDER BY total_revenue DESC
LIMIT 1;


-- 3. Geospatial: total number of trips and average trip_distance for each borough.
-- TODO
SELECT
    d.borough,
    COUNT(*) AS total_trips,
    AVG(f.trip_distance) AS average_trip_distance
FROM vw_fact_trips f
JOIN vw_dim_zones d
    ON f.pickup_location_id = d.location_id
GROUP BY d.borough
ORDER BY total_trips DESC;


-- 4. Time patterns: which day of the week had the highest total tip_amount?
--    What hour of the day has the highest average tip?
-- TODO
SELECT
    TO_CHAR(pickup_datetime, 'Day') AS day_of_week,
    SUM(tip_amount) AS total_tips
FROM vw_fact_trips
GROUP BY day_of_week
ORDER BY total_tips DESC
LIMIT 1;

SELECT
    EXTRACT(HOUR FROM pickup_datetime) AS hour_of_day,
    AVG(tip_amount) AS average_tip
FROM vw_fact_trips
GROUP BY hour_of_day
ORDER BY average_tip DESC
LIMIT 1;

SELECT *
FROM vw_fact_trips
LIMIT 1;

