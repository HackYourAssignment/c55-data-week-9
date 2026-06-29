# Data Track Week 9 Assignment: SQL for Analytics

HackYourFuture Data Track, Week 9. The full brief (scenario, tasks, and grading) lives in the curriculum: **Week 9 → Assignment** in the HackYourFuture learning platform. This repo holds the starter files you fill in.

You audit the raw NYC taxi data, model it as a star schema of SQL **views**, and document it. Run every query against **your own assigned schema** on the shared Azure PostgreSQL instance, not the shared `public` schema. The data is two tables: `nyc_taxi.raw_trips` (~57K green-taxi trips, January 2024) and `nyc_taxi.raw_zones` (265 location lookups).

## What you submit

Fill in these files (starters are provided). Keep them at the repo root and do not rename them.

| File | Task | What it holds |
|---|---|---|
| `validation_queries.sql` | Task 1 | Data-quality audit: duplicates, nulls, range, orphaned keys |
| `schema_setup.sql` | Task 2 | `CREATE OR REPLACE VIEW vw_dim_zones` and `vw_fact_trips` |
| `data_dictionary.md` | Task 3 | Grain, keys, and measures for both views |
| `verification_results.sql` | Task 4 | Verification queries (volume, revenue, geospatial, time patterns) |
| `assets/borough_count.png` | Task 4 | Screenshot of the per-borough row-count result |
| `AI_ASSIST.md` | Task 5 | One documented LLM session |

## Tasks (summary)

1. **Data Quality Audit** (`validation_queries.sql`): find duplicate trips, count NULL pickup/dropoff location IDs, check the `fare_amount` range for negatives, and find `pickup_location_id` values not present in `nyc_taxi.raw_zones`.
2. **Star Schema Views** (`schema_setup.sql`): `vw_dim_zones` (one row per `location_id`, the primary key) and `vw_fact_trips` (one row per trip; exclude `fare_amount < 0`; cast `pickup_datetime` to `TIMESTAMP`; keep the location IDs so it joins to `vw_dim_zones`).
3. **Data Dictionary** (`data_dictionary.md`): state each view's grain in one sentence, identify keys, list measures.
4. **Verification Queries** (`verification_results.sql`): query the views for volume, revenue, geospatial, and time-pattern questions, joining through `vw_dim_zones` for any borough/zone name. Save a screenshot of the per-borough counts to `assets/borough_count.png`.
5. **AI Assistance Log** (`AI_ASSIST.md`): document one LLM session honestly.

## How you are graded

- **Auto-grade (on PR creation):** a **completeness** smoke check confirms every required deliverable exists, is non-empty, and contains the expected views and checks. It does **not** run SQL against a database and is **not** your final grade.
- **Teacher review:** your teacher grades correctness against the rubric: do the queries run, do findings match the real data, does `vw_fact_trips` filter negatives and join cleanly, is the grain stated precisely.

## Submit

1. Work on a branch in your copy of this repo.
2. Fill in each deliverable file.
3. Commit, push, and open a Pull Request against `main`. The auto-grade runs on PR creation and posts a completeness score.
4. Share the PR URL with your teacher.

> ⚠️ Never paste real customer data or PII into an LLM. The NYC taxi dataset used here is public and safe to share.
