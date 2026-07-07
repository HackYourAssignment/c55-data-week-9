# AI Assistance Log

Document one session where you used an LLM to help with a query or a design decision while completing Tasks 1-4. Replace every TODO.

> ⚠️ Never paste real customer data or PII into an LLM. The NYC taxi dataset used here is public, so sample rows are safe to share.

## The problem

I was creating the `vw_dim_zones` view for the star schema. The starter comment suggested selecting `location_id`, `zone`, and `borough`, but when I tried to run the view with this column order, PostgreSQL returned an error.

Relevant SQL:

```sql
CREATE OR REPLACE VIEW vw_dim_zones AS
SELECT
    location_id,
    zone,
    borough
FROM nyc_taxi.raw_zones;
```

The error was:

```text
ERROR: cannot change name of view column "borough" to "zone"
Hint: Use ALTER VIEW ... RENAME COLUMN ... to change name of view column instead.
```

## The prompt

I asked the LLM why this query failed and whether the issue was related to the `zone` column being highlighted in DBeaver.

I provided the context that this was a PostgreSQL view for the NYC Taxi assignment, based on `nyc_taxi.raw_zones`, and that the existing view seemed to work when I used this order:

```sql
CREATE OR REPLACE VIEW vw_dim_zones AS
SELECT
    location_id,
    borough,
    zone
FROM nyc_taxi.raw_zones;
```

## The response

The LLM explained that the problem was not the DBeaver highlighting of `zone`. The issue was that `CREATE OR REPLACE VIEW` in PostgreSQL does not allow changing the names/order of existing view columns in a way that would rename an existing column.

The view had already been created with this column order:

```text
location_id, borough, zone
```

So trying to replace it with this order:

```text
location_id, zone, borough
```

made PostgreSQL interpret the second column as being renamed from `borough` to `zone`.

The LLM suggested either dropping and recreating the view, or keeping the existing column order. I kept the existing column order:

```sql
CREATE OR REPLACE VIEW vw_dim_zones AS
SELECT
    location_id,
    borough,
    zone
FROM nyc_taxi.raw_zones;
```

This worked.

## Reflection

I understood why the suggestion worked. The problem was not with the raw data or with the `zone` column name itself. The problem was how PostgreSQL handles `CREATE OR REPLACE VIEW`: it can replace the query behind a view, but it does not freely allow changing the existing view column names by reordering columns.

Keeping the same column order solved the issue because PostgreSQL no longer interpreted the replacement as a column rename. In this case, the view still contains all required dimension columns: `location_id`, `borough`, and `zone`, so the star schema remains valid.
