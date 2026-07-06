# AI Assistance Log

Document one session where you used an LLM to help with a query or a design decision while completing Tasks 1-4. Replace every TODO.

> ⚠️ Never paste real customer data or PII into an LLM. The NYC taxi dataset used here is public, so sample rows are safe to share.

## The problem

TODO: What were you trying to solve? Paste the relevant SQL or schema fragment.

CREATE OR REPLACE VIEW vw_dim_zones AS
SELECT
    location_id,
    zone
    borough
FROM nyc_taxi.raw_zones;
## The prompt

TODO: What did you ask the AI? Include the context you provided.
why this query was giving me a syntax error in PostgreSQL?
## The response

TODO: What did it suggest? Did it work first try?

AI pointed out that i forgot a comma after zone .
## Reflection

TODO: Did you understand *why* the suggestion worked, or did you accept it blindly?
I understood why the error happened and i added comma .