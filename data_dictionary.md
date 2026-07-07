# Data Dictionary

Document both views. State the grain in one sentence, identify the keys, and list the measures (the columns you can aggregate). Replace every TODO.

## vw_fact_trips

- **Grain:** One row per individual valid taxi trip with a non-negative fare amount.
- **Primary key:** The raw data doesn't have a single primary key column, but we can use vendor_id and pickup_datetime together as a team (a composite key) to identify each unique row.
- **Foreign keys:** pickup_location_id, dropoff_location_id (both link to vw_dim_zones)
- **Measures:** fare_amount, tip_amount, total_amount,trip_distance

## vw_dim_zones

- **Grain:** One row per unique taxi zone location ID
- **Primary key:** location_id
- **Foreign keys:** none
- **Measures:** none, "descriptive attributes only"
