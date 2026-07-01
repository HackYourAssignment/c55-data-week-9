-- Task 4: Verification Queries.
-- Query your views and label each query with the question it answers.
-- Borough and zone names live in vw_dim_zones, so join on pickup_location_id = location_id.

-- 1. Volume: how many total rows in vw_fact_trips? How many rows per borough?

SELECT COUNT(*) AS total_rows FROM vw_fact_trips;


--    What is the most common pickup/dropoff location combination?

Select d.borough, COUNT(*) AS rows_per_borough
from vw_fact_trips f
join vw_dim_zones d on f.pickup_location_id = d.location_id
group by d.borough
order by rows_per_borough desc;


-- TODO
-- (Take a screenshot of the per-borough counts and save it as assets/borough_count.png.)



-- 2. Revenue: which pickup zone (name, not ID) generated the highest total fare_amount?

SELECT d.zone, SUM(f.fare_amount) AS total_fare
FROM vw_fact_trips f
JOIN vw_dim_zones d ON f.pickup_location_id = d.location_id
GROUP BY d.zone
ORDER BY total_fare DESC
LIMIT 1;
--    Which pickup zone collected the highest total fare_amount on any single day?
-- TODO
SELECT d.zone, f.pickup_datetime::date AS pickup_date, SUM(f.fare_amount) AS total_fare
FROM vw_fact_trips f
JOIN vw_dim_zones d ON f.pickup_location_id = d.location_id
GROUP BY d.zone, pickup_date
ORDER BY total_fare DESC
LIMIT 1;


-- 3. Geospatial: total number of trips and average trip_distance for each borough.
-- TODO
SELECT d.borough, COUNT(*) AS total_trips, AVG(f.trip_distance) AS avg_trip_distance
FROM vw_fact_trips f
JOIN vw_dim_zones d ON f.pickup_location_id = d.location_id
GROUP BY d.borough
ORDER BY total_trips DESC;

-- 4. Time patterns: which day of the week had the highest total tip_amount?

SELECT EXTRACT(DOW FROM f.pickup_datetime) AS day_of_week, SUM(f.tip_amount) AS total_tip
FROM vw_fact_trips f
GROUP BY day_of_week
ORDER BY total_tip DESC
LIMIT 1;
--    What hour of the day has the highest average tip?
-- TODO
SELECT EXTRACT(HOUR FROM f.pickup_datetime) AS hour_of_day, AVG(f.tip_amount) AS avg_tip
FROM vw_fact_trips f
GROUP BY hour_of_day
ORDER BY avg_tip DESC
LIMIT 1;
