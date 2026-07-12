#!/usr/bin/env bash
# Week 9 autograder: static analysis only. All SQL runs against a live shared
# Azure PostgreSQL database that CI cannot reach without secrets. The grader
# therefore verifies SQL *shape* — keywords, patterns, and structure — and
# confirms required documentation artefacts are filled in.
#
# Total points: 100. Passing score: 60.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# shellcheck source=.hyf/grader_lib.sh
source "$SCRIPT_DIR/grader_lib.sh"

# Initialise score.json to 0/fail immediately so a crash leaves a meaningful
# artefact behind instead of a stale score.
cat > "$SCRIPT_DIR/score.json" <<'INIT'
{"score": 0, "pass": false, "passingScore": 60}
INIT

score=0
PASSING=60

# ── Level 1 (10 pts): required files exist ──────────────────────────────────
l1=0
required_files=(
  "validation_queries.sql"
  "schema_setup.sql"
  "data_dictionary.md"
  "verification_results.sql"
  "AI_ASSIST.md"
)
missing=0
for f in "${required_files[@]}"; do
  if [[ -f "$REPO_ROOT/$f" ]]; then
    pass "found $f"
  else
    fail "missing $f"
    missing=$((missing + 1))
  fi
done
if [[ "$missing" -eq 0 ]]; then
  l1=10
fi
score=$((score + l1))
pass "Level 1: required files ($l1/10 pts)"

# Helper: returns true when a file has real content and no *unreplaced* TODO
# placeholder remains. A completed query left below the scaffold's "-- TODO:"
# guide comment still counts as filled: SQL line-comments are stripped before
# the check, so leaving the guide comment in place is harmless. Only a line
# whose content *begins* with TODO (an unreplaced markdown placeholder such as
# "TODO: what did you ask?") marks the file a stub. The instruction line
# "...Replace every TODO." (TODO not at line start) is fine.
file_is_filled() {
  local f="$1"
  [[ -s "$f" ]] || return 1
  # Substantive body: drop SQL line-comments and blank lines.
  local body
  body="$(sed -E 's/--.*$//' "$f" | grep -vE '^[[:space:]]*$')"
  [[ -n "$body" ]] || return 1
  # An unreplaced placeholder is a line whose content starts with TODO,
  # optionally behind markdown heading / quote / list markers.
  if printf '%s\n' "$body" | grep -qiE '^[[:space:]]*([#>*-]+[[:space:]]*)?TODO\b'; then
    return 1
  fi
  return 0
}

# ── Level 2 (20 pts): Task 1 – validation_queries.sql ───────────────────────
l2=0
vq="$REPO_ROOT/validation_queries.sql"
if file_is_filled "$vq"; then
  l2=$((l2 + 4)); pass "validation_queries.sql: file filled (no stub TODOs)"

  # 2a: duplicate check — HAVING COUNT
  if grep -qiE "HAVING[[:space:]]+COUNT" "$vq"; then
    l2=$((l2 + 4)); pass "validation_queries.sql: HAVING COUNT pattern found (duplicate check)"
  else
    fail "validation_queries.sql: missing HAVING COUNT(*) > 1 for the duplicate check (Task 1.1)"
  fi

  # 2b: null integrity — IS NULL
  if grep -qiE "[[:space:]]IS[[:space:]]+NULL" "$vq"; then
    l2=$((l2 + 4)); pass "validation_queries.sql: IS NULL check found (null integrity)"
  else
    fail "validation_queries.sql: missing IS NULL check for null pickup/dropoff location IDs (Task 1.2)"
  fi

  # 2c: range validation — MIN( or MAX( and a negative fare check
  if grep -qiE "MIN\s*\(|MAX\s*\(" "$vq" || grep -qiE "fare_amount[[:space:]]*<[[:space:]]*0" "$vq"; then
    l2=$((l2 + 4)); pass "validation_queries.sql: range check found (MIN/MAX or negative-fare count)"
  else
    fail "validation_queries.sql: missing MIN/MAX or fare_amount < 0 for range validation (Task 1.3)"
  fi

  # 2d: relationship check — LEFT JOIN + IS NULL (or NOT EXISTS)
  # The assignment warns explicitly against NOT IN, so reward the safer pattern.
  if (grep -qiE "LEFT[[:space:]]+JOIN" "$vq" && grep -qiE "[[:space:]]IS[[:space:]]+NULL" "$vq") || grep -qiE "NOT[[:space:]]+EXISTS" "$vq"; then
    l2=$((l2 + 4)); pass "validation_queries.sql: LEFT JOIN … IS NULL / NOT EXISTS orphan check (Task 1.4)"
  else
    fail "validation_queries.sql: missing orphaned-key check — use LEFT JOIN nyc_taxi.raw_zones … WHERE z.location_id IS NULL (or NOT EXISTS). Do not use NOT IN. (Task 1.4)"
  fi
else
  fail "validation_queries.sql: file is empty or still contains unfilled TODO stubs"
fi
score=$((score + l2))
pass "Level 2: Task 1 validation queries ($l2/20 pts)"

# ── Level 3 (30 pts): Task 2 – schema_setup.sql ─────────────────────────────
l3=0
ss="$REPO_ROOT/schema_setup.sql"
if file_is_filled "$ss"; then
  l3=$((l3 + 4)); pass "schema_setup.sql: file filled (no stub TODOs)"

  # 3a: creates vw_dim_zones
  if grep -qiE "VIEW[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*\.)?vw_dim_zones\b" "$ss"; then
    l3=$((l3 + 5)); pass "schema_setup.sql: vw_dim_zones view defined"
  else
    fail "schema_setup.sql: vw_dim_zones view not found — check spelling (Task 2)"
  fi

  # 3b: creates vw_fact_trips
  if grep -qiE "VIEW[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*\.)?vw_fact_trips\b" "$ss"; then
    l3=$((l3 + 5)); pass "schema_setup.sql: vw_fact_trips view defined"
  else
    fail "schema_setup.sql: vw_fact_trips view not found — check spelling (Task 2)"
  fi

  # 3c: negative fare filter — WHERE fare_amount >= 0
  # Also accept 'fare_amount > -1' or 'NOT fare_amount < 0' as equivalent.
  if grep -qiE "fare_amount[[:space:]]*(>=|>[[:space:]]*-)" "$ss" || \
     grep -qiE "NOT[[:space:]]+fare_amount[[:space:]]*<" "$ss" || \
     (grep -qiE "WHERE" "$ss" && grep -qiE "fare_amount" "$ss" && grep -qiE "[><!]=?" "$ss"); then
    # Tighter check: must see fare_amount in a WHERE or filter context
    if grep -iE "WHERE.*fare_amount|fare_amount.*WHERE" "$ss" | grep -qiE "[><!]=?[[:space:]]*0"; then
      l3=$((l3 + 8)); pass "schema_setup.sql: negative fare filter (fare_amount >= 0) present in vw_fact_trips"
    elif grep -qiE "fare_amount[[:space:]]*>=[[:space:]]*0" "$ss"; then
      l3=$((l3 + 8)); pass "schema_setup.sql: negative fare filter (fare_amount >= 0) present in vw_fact_trips"
    else
      fail "schema_setup.sql: vw_fact_trips must filter out negative fares (WHERE fare_amount >= 0) — this is the data cleaning step (Task 2)"
    fi
  else
    fail "schema_setup.sql: vw_fact_trips must filter out negative fares (WHERE fare_amount >= 0) — this is the data cleaning step (Task 2)"
  fi

  # 3d: TIMESTAMP cast on pickup_datetime
  if grep -qiE "pickup_datetime::TIMESTAMP|CAST\s*\([^)]*pickup_datetime[^)]*AS\s+TIMESTAMP" "$ss"; then
    l3=$((l3 + 8)); pass "schema_setup.sql: pickup_datetime::TIMESTAMP cast present in vw_fact_trips"
  else
    fail "schema_setup.sql: vw_fact_trips must cast pickup_datetime as TIMESTAMP (pickup_datetime::TIMESTAMP) — required for time-pattern queries in Task 4 (Task 2)"
  fi
else
  fail "schema_setup.sql: file is empty or still contains unfilled TODO stubs"
fi
score=$((score + l3))
pass "Level 3: Task 2 star schema views ($l3/30 pts)"

# ── Level 4 (15 pts): Task 3 – data_dictionary.md ───────────────────────────
l4=0
dd="$REPO_ROOT/data_dictionary.md"
if file_is_filled "$dd"; then
  l4=$((l4 + 5)); pass "data_dictionary.md: file filled (no stub TODOs)"

  # 4a: grain statement for at least one view
  if grep -qiE "\bGrain\b" "$dd"; then
    l4=$((l4 + 5)); pass "data_dictionary.md: 'Grain' heading/label present"
  else
    fail "data_dictionary.md: missing 'Grain' label — state what one row represents for each view (Task 3)"
  fi

  # 4b: primary key and measure columns documented
  pk_ok=false; meas_ok=false
  grep -qiE "(primary[[:space:]]+key|Primary key)" "$dd" && pk_ok=true
  grep -qiE "(measure|fare_amount|tip_amount|total_amount)" "$dd" && meas_ok=true
  if [[ "$pk_ok" = true ]]; then
    l4=$((l4 + 3)); pass "data_dictionary.md: primary key documented"
  else
    fail "data_dictionary.md: no primary key label found — identify the key column(s) for each view (Task 3)"
  fi
  if [[ "$meas_ok" = true ]]; then
    l4=$((l4 + 2)); pass "data_dictionary.md: measures list includes at least one aggregatable column"
  else
    fail "data_dictionary.md: measures not listed — name the columns you can SUM or AVG (fare_amount, tip_amount, etc.) (Task 3)"
  fi
else
  fail "data_dictionary.md: file is empty or still contains unfilled TODO stubs"
fi
score=$((score + l4))
pass "Level 4: Task 3 data dictionary ($l4/15 pts)"

# ── Level 5 (15 pts): Task 4 – verification_results.sql ─────────────────────
l5=0
vr="$REPO_ROOT/verification_results.sql"
if file_is_filled "$vr"; then
  l5=$((l5 + 3)); pass "verification_results.sql: file filled (no stub TODOs)"

  # 5a: volume / borough query
  if grep -qiE "borough" "$vr"; then
    l5=$((l5 + 4)); pass "verification_results.sql: borough-level query found (Task 4.1)"
  else
    fail "verification_results.sql: no borough query — question 1 asks for row counts per borough via vw_dim_zones (Task 4.1)"
  fi

  # 5b: revenue / fare query
  if grep -qiE "fare_amount" "$vr"; then
    l5=$((l5 + 4)); pass "verification_results.sql: fare_amount revenue query found (Task 4.2)"
  else
    fail "verification_results.sql: no revenue query — question 2 asks for highest total fare_amount by zone (Task 4.2)"
  fi

  # 5c: time pattern — day of week or hour of day
  if grep -qiE "DOW|day_of_week|EXTRACT.*DOW|DATE_PART.*DOW|EXTRACT.*HOUR|DATE_PART.*HOUR|to_char.*D|to_char.*HH" "$vr"; then
    l5=$((l5 + 4)); pass "verification_results.sql: time-pattern query found (DOW or HOUR extraction) (Task 4.4)"
  else
    fail "verification_results.sql: missing time-pattern query — question 4 asks for day-of-week and hour-of-day tip totals using EXTRACT(DOW …) or DATE_PART (Task 4.4)"
  fi
else
  fail "verification_results.sql: file is empty or still contains unfilled TODO stubs"
fi
score=$((score + l5))
pass "Level 5: Task 4 verification queries ($l5/15 pts)"

# ── Level 6 (5 pts): borough screenshot present ─────────────────────────────
l6=0
shot_png="$REPO_ROOT/assets/borough_count.png"
check_screenshot_is_png "$shot_png" && l6=5 || {
  # check_screenshot_is_png already emitted pass/fail/warn — just capture partial credit
  for ext in jpg jpeg; do
    if [[ -s "$REPO_ROOT/assets/borough_count.$ext" ]]; then
      l6=3
      break
    fi
  done
}
score=$((score + l6))
pass "Level 6: borough screenshot ($l6/5 pts)"

# ── Level 7 (5 pts): AI_ASSIST.md filled in ─────────────────────────────────
l7=0
ai="$REPO_ROOT/AI_ASSIST.md"
if file_is_filled "$ai"; then
  # Check all four required section headings from the assignment template
  sections=0
  grep -qiE "^##[[:space:]]+The[[:space:]]+problem" "$ai" && sections=$((sections + 1))
  grep -qiE "^##[[:space:]]+The[[:space:]]+prompt" "$ai" && sections=$((sections + 1))
  grep -qiE "^##[[:space:]]+The[[:space:]]+response" "$ai" && sections=$((sections + 1))
  grep -qiE "^##[[:space:]]+Reflection" "$ai" && sections=$((sections + 1))

  chars=$(wc -c < "$ai" | tr -d ' ')

  if [[ "$sections" -eq 4 && "$chars" -ge 1200 ]]; then
    l7=5
    pass "AI_ASSIST.md: all 4 sections present and filled in (${chars} chars)"
  else
    if [[ "$sections" -lt 4 ]]; then
      fail "AI_ASSIST.md: only ${sections}/4 required sections present (need: '## The problem', '## The prompt', '## The response', '## Reflection') (Task 5)"
    else
      fail "AI_ASSIST.md: sections present but too brief (${chars} chars, target 1200+) — fill in the content (Task 5)"
    fi
  fi
else
  fail "AI_ASSIST.md: file is empty or still contains unfilled TODO stubs"
fi
score=$((score + l7))
pass "Level 7: Task 5 AI log ($l7/5 pts)"

# ── Final result ─────────────────────────────────────────────────────────────
print_results "Week 9 Autograder"
write_score "$score" "$PASSING" "$SCRIPT_DIR/score.json"
