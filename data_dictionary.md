# Data Dictionary

Document both views. State the grain in one sentence, identify the keys, and list the measures (the columns you can aggregate). Replace every TODO.

## vw_fact_trips

- **Grain:** One row represents one taxi trip.
- **Primary key:** There is no primary key . 
- **Foreign keys:** pickup_location_id and dropoff_location_id and both link to vw_dim_zones.location_id
- **Measures:** fare_amount , trip_distance , tip_amount ,total_amount , passenger_count.

## vw_dim_zones

- **Grain:** One row represents one taxi zone
- **Primary key:** location_id
- **Foreign keys:** None
- **Measures:** None. descriptive attributes only .
