# Data Dictionary

## vw_fact_trips

- **Grain:** One row represents one NYC taxi trip after basic cleaning, where trips with negative `fare_amount` have been excluded.
- **Primary key:** No declared primary key is included in this view. I checked the database constraints for `nyc_taxi.raw_trips`, and no primary key or unique constraint was returned. The view is at trip-event grain, but the selected columns do not provide a guaranteed unique trip identifier. A possible natural key could be a combination of attributes such as `vendor_id`, `pickup_datetime`, `dropoff_datetime`, `pickup_location_id`, and `dropoff_location_id`, but this should not be treated as guaranteed unique without further validation.
- **Foreign keys:** `pickup_location_id` and `dropoff_location_id` reference `vw_dim_zones.location_id`.
- **Measures:** `passenger_count`, `trip_distance`, `fare_amount`, `extra`, `mta_tax`, `tip_amount`, `tolls_amount`, `improvement_surcharge`, and `total_amount`.

## vw_dim_zones

- **Grain:** One row represents one NYC taxi zone/location.
- **Primary key:** `location_id`.
- **Foreign keys:** none.
- **Measures:** none, descriptive attributes only. The descriptive columns are `borough`, `zone`, and `service_zone`.
