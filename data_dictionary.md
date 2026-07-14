# Data Dictionary

This file documents the two analytical views created for the Week 9 NYC Taxi star schema.

## vw_fact_trips

- **Grain:** One row represents one NYC green taxi trip from the raw trips table after removing rows where `fare_amount < 0`.
- **Primary key:** No explicit primary key is available in this view. The raw trips table does not provide a single unique trip identifier. `vendor_id` is not a primary key because the same vendor can appear in many trips.
- **Foreign keys:**
  - `pickup_location_id` references `vw_dim_zones.location_id`
  - `dropoff_location_id` references `vw_dim_zones.location_id`
- **Measures:**
  - `passenger_count`
  - `trip_distance`
  - `fare_amount`
  - `tip_amount`
  - `total_amount`

## vw_dim_zones

- **Grain:** One row represents one NYC taxi zone.
- **Primary key:** `location_id`
- **Foreign keys:** None.
- **Measures:** None. This view contains descriptive attributes only:
  - `location_id`
  - `zone`
  - `borough`
