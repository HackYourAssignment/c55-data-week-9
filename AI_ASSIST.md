# AI Assistance Log

Document one session where you used an LLM to help with a query or a design decision while completing Tasks 1-4. Replace every TODO.

> ⚠️ Never paste real customer data or PII into an LLM. The NYC taxi dataset used here is public, so sample rows are safe to share.

## The problem

I was confused about the meaning of primary keys and foreign keys in the Week 9 data model. In particular, I did not understand whether `vendor_id` could be used as the primary key in `vw_fact_trips`.

The relevant views were:

```sql
CREATE OR REPLACE VIEW dev_halyna.vw_dim_zones AS
SELECT
    location_id,
    zone,
    borough
FROM nyc_taxi.raw_zones;

CREATE OR REPLACE VIEW dev_halyna.vw_fact_trips AS
SELECT
    vendor_id,
    pickup_datetime::TIMESTAMP AS pickup_datetime,
    dropoff_datetime,
    pickup_location_id,
    dropoff_location_id,
    passenger_count,
    trip_distance,
    fare_amount,
    tip_amount,
    total_amount,
    payment_type
FROM nyc_taxi.raw_trips
WHERE fare_amount >= 0;
```

## The prompt

I asked the AI to explain the two views in beginner-friendly language and to clarify whether vendor_id is a primary key.

I also asked what should be written in the data dictionary for:

- the grain of each view
- the primary key
- the foreign keys
- the measures

## The response

The AI explained that vendor_id is not a primary key because it does not identify one unique trip. The same vendor can appear in many different taxi trips.

The AI explained the difference between the two views:

vw_fact_trips is the fact view. One row represents one cleaned taxi trip. It contains measurable values such as passenger_count, trip_distance, fare_amount, tip_amount, and total_amount.
vw_dim_zones is the dimension view. One row represents one taxi zone. It contains descriptive information such as location_id, zone, and borough.

The AI also explained that:

vw_fact_trips has no explicit primary key because the raw trips table does not provide a single unique trip identifier.
pickup_location_id and dropoff_location_id are foreign keys because they refer to vw_dim_zones.location_id.
vw_dim_zones.location_id can be treated as the primary key because each taxi zone has one unique location ID.

## Reflection

I understood why vendor_id is not a primary key. A primary key must uniquely identify one row, but many trips can have the same vendor_id. Therefore, vendor_id only describes the vendor, not the individual trip.

I also understood the role of the two views in the star schema. The fact view stores trip events and numeric measures. The dimension view stores descriptive zone information. The fact view can be joined to the dimension view using pickup_location_id or dropoff_location_id.

This helped me understand the data model, not just copy the SQL.
