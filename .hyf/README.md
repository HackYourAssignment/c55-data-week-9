# Auto grade tool

## How it works
1. The auto grade tool runs the `test.sh` script located in this directory.
2. `test.sh` writes to `score.json` with the following JSON format:
   ```json
   {
     "score": <number>,
     "passingScore": <number>,
     "pass": "<boolean>"
   }
   ```
   All scores are out of 100. Passing score is 60.
3. The auto grade runs via a GitHub Action on PR creation and updates the PR with the score.

## What is graded

This is a **static analysis only** grader — it cannot connect to the Azure PostgreSQL database. It verifies:

| Level | Task | Points |
|-------|------|--------|
| 1 | All 5 required files present | 10 |
| 2 | Task 1: validation_queries.sql — 4 checks (duplicates, NULLs, range, orphans) | 20 |
| 3 | Task 2: schema_setup.sql — views defined, fare filter, TIMESTAMP cast | 30 |
| 4 | Task 3: data_dictionary.md — grain, primary key, measures | 15 |
| 5 | Task 4: verification_results.sql — borough, revenue, time-pattern queries | 15 |
| 6 | Task 4: assets/borough_count.png screenshot present | 5 |
| 7 | Task 5: AI_ASSIST.md — 4 sections filled | 5 |

The **final grade is teacher review** against the assignment rubric — the teacher runs the SQL and checks that findings match the real NYC taxi data.
