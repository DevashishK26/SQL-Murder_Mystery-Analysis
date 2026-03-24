# 🔍 Investigation Approach – SQL Murder Mystery

This document walks through the complete step-by-step reasoning and SQL queries used to solve the murder case in SQL City.

---

## 🧭 Overview of the Approach

The investigation followed a chain of evidence — each query's output became the input for the next. The process had two major phases:

1. **Identify the Killer** — using crime scene data, witness accounts, gym records, and license plates
2. **Uncover the Mastermind** — using the killer's own interview and cross-referencing event attendance, physical attributes, and vehicle data

---

## Phase 1 — Finding the Killer

### Step 1 — Read the Crime Scene Report

The first step was to pull the crime scene report for a murder in SQL City on January 15, 2018.

```sql
SELECT * FROM crime_scene_report
WHERE type = 'murder'
  AND city = 'SQL City'
  AND date = '20180115'
```

**What we learned:** The report mentioned two witnesses — one living at the last house on Northwestern Dr, and another named Annabel living on Franklin Ave.

---

### Step 2 — Identify Witness 1 (Northwestern Dr)

The "last house" translates to the highest address number on that street.

```sql
SELECT * FROM person
WHERE address_street_name = 'Northwestern Dr'
ORDER BY address_number DESC
LIMIT 1
```

**Result:** `Morty Schapiro` — Person ID `14887`

---

### Step 3 — Identify Witness 2 (Franklin Ave)

The second witness was identified by matching the partial name "Annabel" and street name.

```sql
SELECT * FROM person
WHERE name LIKE '%Annabel%'
  AND address_street_name = 'Franklin Ave'
```

**Result:** `Annabel Miller` — Person ID `16371`

---

### Step 4 — Read Witness Interviews

Both witnesses' interview transcripts were pulled using their person IDs.

```sql
SELECT * FROM interview
WHERE person_id IN (14887, 16371)
```

**Clues extracted from interviews:**

| Clue | Detail |
|------|--------|
| Weapon | Shot with a gun |
| Gym bag | "Get Fit Now" gym bag |
| Membership ID | Starts with `48Z` |
| Membership type | Gold |
| License plate | Contains `H42W` |
| Gym visit date | January 9, 2018 |

---

### Step 5 — Identify the Killer

All clues were combined into a single query joining four tables — gym membership, check-in records, person details, and driver's license.

```sql
SELECT p.name, p.id
FROM get_fit_now_member gfm
LEFT JOIN get_fit_now_check_in gfc
    ON gfm.id = gfc.membership_id
LEFT JOIN person p
    ON p.id = gfm.person_id
LEFT JOIN drivers_license dl
    ON dl.id = p.license_id
WHERE gfm.id LIKE '%48Z%'
  AND gfm.membership_status = 'gold'
  AND gfc.check_in_date = 20180109
  AND dl.plate_number LIKE '%H42W%'
```

**Result:** ✅ `Jeremy Bowers` — Person ID `67318`

---

## Phase 2 — Uncovering the Mastermind

The case didn't end there. Jeremy Bowers was hired — meaning someone else was pulling the strings.

---

### Step 6 — Read the Killer's Interview

The killer's own interview was retrieved to find clues about who hired him.

```sql
SELECT * FROM interview
WHERE person_id = 67318
```

**Clues about the mastermind:**

| Clue | Detail |
|------|--------|
| Gender | Female |
| Wealth | Very wealthy |
| Height | Between 65" and 67" (5'5" – 5'7") |
| Hair color | Red |
| Car | Tesla Model S |
| Event attendance | SQL Symphony Concert — 3 times in December 2017 |

---

### Step 7 — Find the Mastermind

The approach here used a **CTE (Common Table Expression)** to first isolate people who attended the SQL Symphony Concert at least 3 times in December 2017, then filtered them against all physical and vehicle clues from the killer's interview.

```sql
WITH cte AS (
    SELECT person_id, COUNT(*) AS frequency
    FROM facebook_event_checkin
    WHERE date LIKE '201712%'
      AND event_name LIKE '%SQL Symphony%'
    GROUP BY person_id
    HAVING frequency >= 3
)
SELECT p.name, p.id
FROM drivers_license dl
JOIN person p
    ON p.license_id = dl.id
JOIN cte
    ON cte.person_id = p.id
WHERE dl.hair_color = 'red'
  AND dl.gender = 'female'
  AND dl.height BETWEEN 65 AND 67
  AND dl.car_make = 'Tesla'
  AND dl.car_model = 'Model S'
```

**Result:** 🎯 `Miranda Priestly` — Person ID `99716`

---

## 🧠 Key SQL Concepts Used

| Concept | Where It Was Used |
|--------|-------------------|
| `WHERE` + `LIKE` | Filtering partial matches (membership ID, plate, event name) |
| `ORDER BY` + `LIMIT` | Finding the last house on Northwestern Dr |
| Multi-table `JOIN` | Connecting gym, person, and license data to identify the killer |
| `WITH` (CTE) | Isolating frequent concert attendees before joining with other tables |
| `GROUP BY` + `HAVING` | Counting event attendance and filtering for 3+ visits |
| `BETWEEN` | Filtering height range for the mastermind |
| `IN` | Fetching both witnesses' interviews in one query |

---

## 🗺️ Investigation Flow

```
crime_scene_report
        │
        ▼
  Two witnesses identified
        │
   ┌────┴────┐
   ▼         ▼
Morty     Annabel
(14887)   (16371)
   └────┬────┘
        ▼
   Interview transcripts
        │
        ▼
  Gym + License clues
        │
        ▼
   Jeremy Bowers ✅ (Killer)
        │
        ▼
   Killer's interview
        │
        ▼
  CTE → Concert attendance
  + Physical + Vehicle clues
        │
        ▼
Miranda Priestly 🎯 (Mastermind)
```

---

## 💡 Takeaways

- **Join strategy matters** — connecting gym, check-in, person, and license tables in one query was the most efficient way to apply all clues simultaneously.
- **CTEs improve readability** — isolating the concert attendance logic in a CTE made the final mastermind query clean and easy to follow.
- **Partial matching with `LIKE`** — critical for real-world investigative queries where you only have fragments of information (plate numbers, membership IDs, event names).
- **Chain of evidence** — each query's output directly informed the next query, mirroring how a real investigation unfolds.