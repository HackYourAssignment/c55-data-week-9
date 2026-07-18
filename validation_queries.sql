-- Task 1: Data Quality Audit
-- Run every query against nyc_taxi.raw_trips / nyc_taxi.raw_zones in YOUR OWN schema (not public). -- noqa: LT05
-- The shared pattern is a query that returns the bad rows (or a count).
-- Zero rows back means the check passed.

-- 1. Duplicate check
SELECT
    vendor_id,
    pickup_datetime,
    dropoff_datetime,
    COUNT(*) AS duplicate_count
FROM nyc_taxi.raw_trips
GROUP BY
    vendor_id,
    pickup_datetime,
    dropoff_datetime
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

-- Finding:
-- Duplicate records exist. Some combinations appear 2 times

-- 2. Null integrity
SELECT
    COUNT(*) FILTER (
        WHERE pickup_location_id IS NULL
    ) AS null_pickup_location_id_count,
    COUNT(*) FILTER (
        WHERE dropoff_location_id IS NULL
    ) AS null_dropoff_location_id_count,
    COUNT(*) FILTER (
        WHERE pickup_location_id IS NULL
        OR dropoff_location_id IS NULL
    ) AS rows_with_any_null_location_id
FROM nyc_taxi.raw_trips;

-- Finding:
-- 5 rows have NULL pickup_location_id.
-- 0 rows have NULL dropoff_location_id.
-- In total, 5 rows have at least one missing location ID.


-- 3. Range validation
SELECT
    MIN(fare_amount) AS min_fare_amount,
    MAX(fare_amount) AS max_fare_amount,
    COUNT(*) FILTER (WHERE fare_amount < 0) AS negative_fare_count
FROM nyc_taxi.raw_trips;

-- Finding:
-- fare_amount ranges from -70 to 1422.6.
-- There are 182 rows with negative fare_amount.

-- 4. Relationship check
SELECT
    t.pickup_location_id,
    COUNT(*) AS trip_count
FROM nyc_taxi.raw_trips AS t
LEFT JOIN nyc_taxi.raw_zones AS z
    ON t.pickup_location_id = z.location_id
WHERE
    t.pickup_location_id IS NOT NULL
    AND z.location_id IS NULL
GROUP BY t.pickup_location_id
ORDER BY trip_count DESC;

-- Finding:
-- pickup_location_id 999 appears in 5 trips but does not exist in nyc_taxi.raw_zones. -- noqa: LT05
