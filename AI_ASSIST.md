# AI Assistance Log

Document one session where you used an LLM to help with a query or a design decision while completing Tasks 1-4. Replace every TODO.

> ⚠️ Never paste real customer data or PII into an LLM. The NYC taxi dataset used here is public, so sample rows are safe to share.

## The problem
didnt know how to get the day of the week or the hour for verification
## The prompt

how do i get day of the week from timestamp date in postgresql 
## The response

In PostgreSQL, you can easily get the day of the week from a timestamp using either EXTRACT() / DATE_PART() or TO_CHAR().The best method depends on whether you want the result as a number (e.g., 0-6 or 1-7) or as a text name (e.g., "Monday").Here is how to do both.1. Get the Day of the Week as a NumberYou can use EXTRACT(DOW FROM timestamp) or EXTRACT(ISODOW FROM timestamp). Pay close attention to how they count the days:Standard Day of Week (DOW)Range: 0 (Sunday) to 6 (Saturday).SQLSELECT EXTRACT(DOW FROM TIMESTAMP '2026-07-01'); 
-- Returns 3 (Since July 1, 2026 is a Wednesday)
ISO 8601 Day of Week (ISODOW)Range: 1 (Monday) to 7 (Sunday). This is highly recommended if your weeks strictly start on Monday.SQLSELECT EXTRACT(ISODOW FROM TIMESTAMP '2026-07-01'); 
-- Returns 3 (Wednesday)
💡 Note: You can also use DATE_PART('dow', timestamp) which achieves the exact same result as EXTRACT.2. Get the Day of the Week as text (Name)If you need the actual name of the day, use the TO_CHAR() function with the appropriate template pattern.Full Day Name (Day)SQLSELECT TO_CHAR(TIMESTAMP '2026-07-01', 'Day'); 
-- Returns 'Wednesday ' (padded with spaces)

SELECT TO_CHAR(TIMESTAMP '2026-07-01', 'FMDay'); 
-- Returns 'Wednesday' (FM removes trailing whitespace padding)
Abbreviated Day Name (Dy)SQLSELECT TO_CHAR(TIMESTAMP '2026-07-01', 'FMDy'); 
-- Returns 'Wed'
Quick Reference TableFunction / PatternResult for a WednesdayFormat TypeRange/NotesEXTRACT(DOW FROM ...)3Numeric0 (Sun) - 6 (Sat)EXTRACT(ISODOW FROM ...)3Numeric1 (Mon) - 7 (Sun)TO_CHAR(..., 'FMDay')"Wednesday"TextFull name, capitalizedTO_CHAR(..., 'fmday')"wednesday"TextFull name, lowercaseTO_CHAR(..., 'FMDy')"Wed"Text3-letter abbreviation




it didnt work first try since i used extract first then to_char (t.pickup_datetime, 'D') which gave me only the index of the day so i switched to (t.pickup_datetime, 'Day') which showed the day name
also did the same with the hour
## Reflection

i did understand why and learned few more things to keep in mind considering timestamps and datetime and the use of Day/'HH12 AM'