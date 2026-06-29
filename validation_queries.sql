-- Task 1: Data Quality Audit
-- Run every query against nyc_taxi.raw_trips / nyc_taxi.raw_zones in YOUR OWN schema (not public).
-- The shared pattern is a query that returns the bad rows (or a count).
-- Zero rows back means the check passed.

-- 1. Duplicate check: are there rows with the same vendor_id, pickup_datetime, dropoff_datetime?
-- TODO: GROUP BY the three columns and keep only groups with HAVING COUNT(*) > 1.


-- 2. Null integrity: how many rows have a NULL pickup_location_id or dropoff_location_id?
-- TODO: count the NULLs (COUNT(*) FILTER (WHERE ... IS NULL) is handy for several columns at once).


-- 3. Range validation: what are the min and max fare_amount? Are there negative values?
-- TODO: SELECT MIN(fare_amount), MAX(fare_amount), and a count of rows where fare_amount < 0.


-- 4. Relationship check: which pickup_location_id values in nyc_taxi.raw_trips do NOT exist in nyc_taxi.raw_zones?
-- TODO: LEFT JOIN nyc_taxi.raw_zones ... WHERE z.location_id IS NULL  (or NOT EXISTS).
-- Do NOT use NOT IN: a single NULL in the subquery hides every orphan.
