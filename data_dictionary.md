# Data Dictionary

Document both views. State the grain in one sentence, identify the keys, and list the measures (the columns you can aggregate). Replace every TODO.

## vw_fact_trips

- **Grain:** One row per taxi trip from `nyc_taxi.raw_trips`, excluding rows where `fare_amount` is less than 0
- **Primary key:** No declared primary key. The source table does not provide a unique trip ID
- **Foreign keys:** `pickup_location_id` and `dropoff_location_id` reference `vw_dim_zones.location_id`
- **Measures:** `passenger_count`, `trip_distance`, `fare_amount`, `extra`, `mta_tax`, `tip_amount`, `tolls_amount`, `improvement_surcharge`, `total_amount`, `congestion_surcharge`

## vw_dim_zones

- **Grain:** One row per taxi zone location
- **Primary key:** `location_id`
- **Foreign keys:** None
- **Measures:** None, descriptive attributes only
