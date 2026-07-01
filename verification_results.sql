-- Task 4: Verification Queries.
-- Query your views and label each query with the question it answers.
-- Borough and zone names live in vw_dim_zones, so join on pickup_location_id = location_id.

-- 1. Volume: how many total rows in vw_fact_trips? How many rows per borough?
--    What is the most common pickup/dropoff location combination?
SELECT COUNT(*) AS total_rows
FROM dev_bader.vw_fact_trips t;


SELECT z.borough, COUNT(*) AS borough_count
FROM dev_bader.vw_fact_trips t
JOIN dev_bader.vw_dim_zones z ON t.pickup_location_id = z.location_id
GROUP BY z.borough
ORDER BY borough_count DESC;

SELECT 
    z1.zone AS pickup_zone,
    z2.zone AS dropoff_zone,
    COUNT(*) AS trip_count
FROM dev_bader.vw_fact_trips t
JOIN dev_bader.vw_dim_zones z1 ON t.pickup_location_id = z1.location_id
JOIN dev_bader.vw_dim_zones z2 ON t.dropoff_location_id = z2.location_id
GROUP BY z1.zone, z2.zone
ORDER BY trip_count DESC
LIMIT 1;
-- (Take a screenshot of the per-borough counts and save it as assets/borough_count.png.)


-- 2. Revenue: which pickup zone (name, not ID) generated the highest total fare_amount?
--    Which pickup zone collected the highest total fare_amount on any single day?
SELECT 
    z.zone AS pickup_zone,
    SUM(f.fare_amount) AS total_fare
FROM dev_bader.vw_fact_trips t
JOIN dev_bader.vw_dim_zones z ON t.pickup_location_id = z.location_id
GROUP BY z.zone
ORDER BY total_fare DESC
LIMIT 1;


SELECT 
    z.zone AS pickup_zone,
    t.pickup_datetime::date AS trip_date,
    SUM(t.fare_amount) AS total_fare
FROM dev_bader.vw_fact_trips t
JOIN dev_bader.vw_dim_zones z ON t.pickup_location_id = z.location_id
GROUP BY z.zone, t.pickup_datetime::date
ORDER BY total_fare DESC
LIMIT 1;
-- 3. Geospatial: total number of trips and average trip_distance for each borough.
SELECT 
    z.borough,
    COUNT(*) AS total_trips,
    AVG(t.trip_distance) AS avg_trip_distance
FROM dev_bader.vw_fact_trips t
JOIN dev_bader.vw_dim_zones z ON t.pickup_location_id = z.location_id
GROUP BY z.borough
ORDER BY total_trips DESC;


-- 4. Time patterns: which day of the week had the highest total tip_amount?
--    What hour of the day has the highest average tip?
SELECT 
    TO_CHAR(t.pickup_datetime, 'Day') AS day_of_week,
    SUM(t.tip_amount) AS total_tip
FROM dev_bader.vw_fact_trips t
GROUP BY day_of_week
ORDER BY total_tip DESC
LIMIT 1;

SELECT 
    TO_CHAR(t.pickup_datetime, 'HH12 AM') AS pickup_hour,
    AVG(t.tip_amount) AS avg_tip
FROM dev_bader.vw_fact_trips t
GROUP BY pickup_hour
ORDER BY avg_tip DESC
LIMIT 1;