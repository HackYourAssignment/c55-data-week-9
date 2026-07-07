-- Task 4: Verification Queries.
-- Query your views and label each query with the question it answers.
-- Borough and zone names live in vw_dim_zones, so join on pickup_location_id = location_id.

-- 1. Volume: how many total rows in vw_fact_trips? How many rows per borough?
--    What is the most common pickup/dropoff location combination?
-- TODO
-- (Take a screenshot of the per-borough counts and save it as assets/borough_count.png.)
SELECT COUNT(*) AS total_trips 
FROM vw_fact_trips;

SELECT 
    d.borough, 
    COUNT(*) AS trip_count
FROM vw_fact_trips f
JOIN vw_dim_zones d ON f.pickup_location_id = d.location_id
GROUP BY d.borough
ORDER BY trip_count DESC;

SELECT 
    p.zone AS pickup_zone, 
    d.zone AS dropoff_zone, 
    COUNT(*) AS combination
FROM vw_fact_trips f
JOIN vw_dim_zones p ON f.pickup_location_id = p.location_id
JOIN vw_dim_zones d ON f.dropoff_location_id = d.location_id
GROUP BY p.zone, d.zone
ORDER BY combination DESC
LIMIT 1;


-- 2. Revenue: which pickup zone (name, not ID) generated the highest total fare_amount?
--    Which pickup zone collected the highest total fare_amount on any single day?
-- TODO
SELECT 
    d.zone AS zone_name,
    SUM(f.fare_amount) AS total_revenue
FROM vw_fact_trips f
INNER JOIN vw_dim_zones d 
    ON f.pickup_location_id = d.location_id
GROUP BY d.zone
ORDER BY total_revenue DESC
LIMIT 1;


SELECT 
    d.zone AS zone_name,
    DATE(f.pickup_datetime_clean) AS trip_date,
    SUM(f.fare_amount) AS total_money
FROM vw_fact_trips f
JOIN vw_dim_zones d 
    ON f.pickup_location_id = d.location_id
GROUP BY d.zone, DATE(f.pickup_datetime_clean)
ORDER BY total_money DESC
LIMIT 1;

-- 3. Geospatial: total number of trips and average trip_distance for each borough.
-- TODO
SELECT 
    d.borough,
    COUNT(*) AS total_trips,
    AVG(f.trip_distance) AS avg_distance      
FROM vw_fact_trips f
JOIN vw_dim_zones d ON f.pickup_location_id = d.location_id
GROUP BY d.borough                            
ORDER BY total_trips DESC;

-- 4. Time patterns: which day of the week had the highest total tip_amount?
--    What hour of the day has the highest average tip?
-- TODO
SELECT  
    EXTRACT(DOW FROM f.pickup_datetime_clean) AS day_number, 
    SUM(f.tip_amount) AS total_tips
FROM vw_fact_trips f
GROUP BY day_number
ORDER BY total_tips DESC
LIMIT 1;

SELECT 
    EXTRACT(HOUR FROM f.pickup_datetime_clean) AS trip_hour, 
    ROUND(AVG(f.tip_amount)::numeric, 2) AS avg_tip
FROM vw_fact_trips f
GROUP BY trip_hour
ORDER BY avg_tip DESC
LIMIT 1;
