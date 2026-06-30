-- Task 1: Data Quality Audit
-- Run every query against nyc_taxi.raw_trips / nyc_taxi.raw_zones in YOUR OWN schema (not public).
-- The shared pattern is a query that returns the bad rows (or a count).
-- Zero rows back means the check passed.

-- 1. Duplicate check: are there rows with the same vendor_id, pickup_datetime, dropoff_datetime?
-- TODO: GROUP BY the three columns and keep only groups with HAVING COUNT(*) > 1.
select rt.vendor_id , rt.pickup_datetime , rt.dropoff_datetime , COUNT(*) AS copies
from nyc_taxi.raw_trips rt 
group by rt.vendor_id , rt.pickup_datetime , rt.dropoff_datetime 
having count(*)>1
ORDER BY copies DESC;
-- 2. Null integrity: how many rows have a NULL pickup_location_id or dropoff_location_id?
-- TODO: count the NULLs (COUNT(*) FILTER (WHERE ... IS NULL) is handy for several columns at once).
select 
	COUNT(*) filter(where rt.pickup_location_id is null) as null_pickup_location,
	COUNT(*) filter(where rt.dropoff_location_id is null)as null_dropoff_location
from nyc_taxi.raw_trips rt;

-- 3. Range validation: what are the min and max fare_amount? Are there negative values?
-- TODO: SELECT MIN(fare_amount), MAX(fare_amount), and a count of rows where fare_amount < 0.
select 
	MIN(rt.fare_amount) as min_fare_amount, 
	MAX(rt.fare_amount) as max_fare_amount, 
	COUNT(*) FILTER (WHERE rt.fare_amount < 0) AS negative_fares_count
from nyc_taxi.raw_trips rt;

-- 4. Relationship check: which pickup_location_id values in nyc_taxi.raw_trips do NOT exist in nyc_taxi.raw_zones?
-- TODO: LEFT JOIN nyc_taxi.raw_zones ... WHERE z.location_id IS NULL  (or NOT EXISTS).
-- Do NOT use NOT IN: a single NULL in the subquery hides every orphan.
select rt.pickup_location_id
from nyc_taxi.raw_trips rt 
left join nyc_taxi.raw_zones rz on rt.pickup_location_id = rz.location_id 
where rz.location_id  is null;