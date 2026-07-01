-- Task 4: Verification Queries.

-- 1a. Volume: total rows in vw_fact_trips
SELECT COUNT(*) AS total_trips
FROM vw_fact_trips;


-- 1b. Volume: rows per pickup borough
-- Screenshot this result and save it as assets/borough_count.png.
SELECT
    COALESCE(z.borough, 'Unknown') AS borough,
    COUNT(*) AS trip_count
FROM vw_fact_trips AS t
LEFT JOIN vw_dim_zones AS z
    ON t.pickup_location_id = z.location_id
GROUP BY COALESCE(z.borough, 'Unknown')
ORDER BY trip_count DESC;


-- 1c. Volume: most common pickup/dropoff location combination
SELECT
    z_pickup.zone AS pickup_zone,
    z_dropoff.zone AS dropoff_zone,
    COUNT(*) AS trip_count
FROM vw_fact_trips AS t
INNER JOIN vw_dim_zones AS z_pickup
    ON t.pickup_location_id = z_pickup.location_id
INNER JOIN vw_dim_zones AS z_dropoff
    ON t.dropoff_location_id = z_dropoff.location_id
GROUP BY
    z_pickup.zone,
    z_dropoff.zone
ORDER BY trip_count DESC
LIMIT 1;


-- 2a. Revenue: pickup zone with highest total fare_amount
SELECT
    z.zone AS pickup_zone,
    SUM(t.fare_amount) AS total_fare
FROM vw_fact_trips AS t
INNER JOIN vw_dim_zones AS z
    ON t.pickup_location_id = z.location_id
GROUP BY z.zone
ORDER BY total_fare DESC
LIMIT 1;


-- 2b. Revenue: pickup zone with highest total fare_amount on any single day
SELECT
    z.zone AS pickup_zone,
    DATE(t.pickup_datetime) AS trip_date,
    SUM(t.fare_amount) AS total_fare
FROM vw_fact_trips AS t
INNER JOIN vw_dim_zones AS z
    ON t.pickup_location_id = z.location_id
GROUP BY
    z.zone,
    DATE(t.pickup_datetime)
ORDER BY total_fare DESC
LIMIT 1;


-- 3. Geospatial: total number of trips and average trip_distance for each pickup borough -- noqa: LT05
SELECT
    COALESCE(z.borough, 'Unknown') AS borough,
    COUNT(*) AS total_trips,
    AVG(t.trip_distance) AS avg_trip_distance
FROM vw_fact_trips AS t
LEFT JOIN vw_dim_zones AS z
    ON t.pickup_location_id = z.location_id
GROUP BY COALESCE(z.borough, 'Unknown')
ORDER BY total_trips DESC;


-- 4a. Time patterns: day of the week with the highest total tip_amount
SELECT
    TO_CHAR(t.pickup_datetime, 'Day') AS day_of_week,
    EXTRACT(DOW FROM t.pickup_datetime) AS day_num,
    SUM(t.tip_amount) AS total_tip_amount
FROM vw_fact_trips AS t
GROUP BY
    TO_CHAR(t.pickup_datetime, 'Day'),
    EXTRACT(DOW FROM t.pickup_datetime)
ORDER BY total_tip_amount DESC
LIMIT 1;


-- 4b. Time patterns: hour of the day with the highest average tip_amount
SELECT
    EXTRACT(HOUR FROM t.pickup_datetime) AS hour_of_day,
    AVG(t.tip_amount) AS avg_tip_amount,
    COUNT(*) AS trip_count
FROM vw_fact_trips AS t
GROUP BY EXTRACT(HOUR FROM t.pickup_datetime)
ORDER BY avg_tip_amount DESC
LIMIT 1;
