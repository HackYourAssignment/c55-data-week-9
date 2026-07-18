# AI Assistance Log

## The problem

I was working on Task 4, question 1b, where I needed to count the number of trips per pickup borough. Borough names are stored in `vw_dim_zones`, while trip records are stored in `vw_fact_trips`, so I needed to join the fact view to the dimension view.

My first version used an inner join:

```sql
SELECT
    z.borough,
    COUNT(*) AS trip_count
FROM vw_fact_trips AS t
INNER JOIN vw_dim_zones AS z
    ON t.pickup_location_id = z.location_id
GROUP BY z.borough;
```

## The prompt

I am completing an analytics engineering SQL assignment using NYC taxi data in PostgreSQL. I created a fact view called `vw_fact_trips` and a dimension view called `vw_dim_zones`. For Task 4, question 1b, I need to count rows per pickup borough.
My first idea was to use this query:

```sql
SELECT
    z.borough,
    COUNT(*) AS trip_count
FROM vw_fact_trips AS t
INNER JOIN vw_dim_zones AS z
    ON t.pickup_location_id = z.location_id
GROUP BY z.borough;
```

However, my validation queries showed that some trips have `NULL` `pickup_location_id`, and `pickup_location_id = 999` exists in the trips table but does not exist in the zones table. Is my query still a good choice for the borough count, or would it hide some data-quality issues? What would be a better way to write this query for analytics reporting, and why?

## The response

The AI explained that my original `INNER JOIN` query would run, but it would hide trips where the pickup location does not match a row in `vw_dim_zones`. This includes trips with `NULL` `pickup_location_id` and trips with invalid pickup IDs such as `999`.

The AI suggested changing the query to use a `LEFT JOIN` so that all rows from `vw_fact_trips` are kept in the result. It also introduced `COALESCE(z.borough, 'Unknown') AS borough`, which replaces a missing borough value with `Unknown` instead of leaving it as `NULL`.

The suggested query was:

```sql
SELECT
    COALESCE(z.borough, 'Unknown') AS borough,
    COUNT(*) AS trip_count
FROM vw_fact_trips AS t
LEFT JOIN vw_dim_zones AS z
    ON t.pickup_location_id = z.location_id
GROUP BY COALESCE(z.borough, 'Unknown')
ORDER BY trip_count DESC;
```

## Reflection

I understood why the suggestion worked after comparing it with my validation results. Before this, I was thinking only about joining the fact view to the dimension view, so an `INNER JOIN` seemed normal. However, the validation step showed that some pickup locations were missing or invalid.

Using an `INNER JOIN` would silently remove those trips from the borough count. Using a `LEFT JOIN` keeps all fact rows, and `COALESCE(z.borough, 'Unknown')` makes unmatched rows visible and readable in the result. This is better for analytics reporting because it shows the data-quality issue instead of hiding it. I did not accept the suggestion blindly; I checked it against the data issues found in Task 1 and understood why it was a better choice for this query.
