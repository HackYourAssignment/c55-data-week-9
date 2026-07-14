# Data Dictionary

Document both views. State the grain in one sentence, identify the keys, and list the measures (the columns you can aggregate). Replace every TODO.

## vw_fact_trips

- **Grain:** one row per taxi trip that has fare_amount >=0 
- **Primary key:** vendor_id
- **Foreign keys:** pickup_location_id, dropoff_location_id
- **Measures:** fare_amount,trip_distance,tip_amount,passenger_count

## vw_dim_zones

- **Grain:** one zone per day
- **Primary key:** location id
- **Foreign keys:**  ( "none")
- **Measures:**  "none, descriptive attributes only"
