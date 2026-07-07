# AI Assistance Log

Document one session where you used an LLM to help with a query or a design decision while completing Tasks 1-4. Replace every TODO.

> ⚠️ Never paste real customer data or PII into an LLM. The NYC taxi dataset used here is public, so sample rows are safe to share.

## The problem

-- 3. Range validation: what are the min and max fare_amount? Are there negative values?
-- TODO: SELECT MIN(fare_amount), MAX(fare_amount), and a count of rows where fare_amount < 0.
select 
	MIN(rt.fare_amount), 
	MAX(rt.fare_amount), 
	COUNT(*) 
where rt.fare_amount < 0,
from nyc_taxi.raw_trips rt;
Syntax error:

## The prompt
why i got syntax error here and should i apply filter (where) ?

## The response
You got a syntax error because of how the SQL engine processes queries and where components must be placed.

Here is exactly why your query failed and why using a **`FILTER`** clause is the best approach here:

---

### 1. Why you got a Syntax Error

There are two structural mistakes in your original query:

* **Placement of `FROM` and `WHERE`:** In SQL, the `FROM` clause must always come *before* the `WHERE` clause. You placed a comma after your `WHERE` condition and then wrote `FROM`, which completely confuses the database parser.
* **The comma inside `WHERE`:** You wrote `WHERE rt.fare_amount < 0,`. A `WHERE` clause cannot end with a comma.

---

### 2. Should you apply a regular `WHERE` at the bottom?

**No**, you shouldn't use a regular `WHERE` clause at the bottom of this query.

If you put `WHERE rt.fare_amount < 0` at the end of the query, **the database will filter the entire table first**. This means your `MIN()` and `MAX()` functions would *only* look at the negative rows.

* Your `MIN` would show the worst negative number.
* Your `MAX` would show the highest negative number (something close to `0`), **not** the true maximum fare paid by a real customer (which could be hundreds of dollars).

---

### 3. The Solution: Use the `FILTER` clause

To get the true minimum, the true maximum, and the count of bad rows all in a single pass, you must use the `FILTER` clause inside the `COUNT(*)` function. This acts as a mini-conditional statement just for that specific counter.

Here is the correct way to write it:

```sql
SELECT 
    MIN(rt.fare_amount) AS min_fare, 
    MAX(rt.fare_amount) AS max_fare, 
    COUNT(*) FILTER (WHERE rt.fare_amount < 0) AS negative_fares_count
FROM nyc_taxi.raw_trips rt;

```

### Why this works perfectly:

* `MIN(rt.fare_amount)` and `MAX(rt.fare_amount)` scan the **entire table** to find the absolute lowest and highest values.
* `COUNT(*) FILTER (WHERE rt.fare_amount < 0)` looks at every row but only increments the counter when the fare is negative.

Run this updated query in your editor, and it will return a clean, one-row report without any errors!
## Reflection
Yes, I understand the response, and I noticed that the order of "where" before "from" is wrong, and also the comma, and using "filter" is better.
