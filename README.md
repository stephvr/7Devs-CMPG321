# Uber & Bolt Operations Analysis

CMPG321 Phase 2 database project analysing driver earnings, platform commission, surge pricing and operational patterns across selected South African cities.

## Project Focus

The database supports analysis of driver earnings, platform commission, surge pricing, trip completion and cancellation patterns, rider and driver activity, vehicle information, and trip-level fare and review data.

## Database

The project uses **Oracle Database** running in Docker and is accessed through **Oracle SQL Developer**.

| Setting | Value |
|---|---|
| Username | `CMPG321` |
| Password | `cmpg321` |
| Host | `localhost` |
| Port | `1522` |
| Service name | `FREEPDB1` |

## Repository Structure

```text
database/
├── data/
│   └── original project CSV files
├── schema/
│   ├── 00_setup.sql
│   ├── 01_create_tables.sql
│   └── 02_constraints.sql
├── load/
│   ├── 00_create_staging_tables.sql
│   ├── 01_reference_data.sql
│   └── 02_transform_staging.sql
└── queries/
    ├── RQ01_...
    ├── RQ02_...
    ├── RQ03_driver_commission_rate.sql
    ├── RQ04_surge_timing_patterns.sql
    └── ...
```

## Final 3NF Schema

The implemented database contains **10 final tables**:

1. `PROVINCES`
2. `CITIES`
3. `PLATFORM_AFFILIATION`
4. `SA_DRIVERS`
5. `SA_RIDERS`
6. `VEHICLES`
7. `PRICING_SURGE_ZONES`
8. `TRIP_HEADERS`
9. `TRIP_FARE_BREAKDOWN`
10. `TRIP_REVIEWS`

The original source data contains repeated geographic and platform information. These values are normalized into lookup tables.

```text
CITIES → PROVINCES
SA_DRIVERS → CITIES
SA_DRIVERS → PLATFORM_AFFILIATION
SA_RIDERS → CITIES
PRICING_SURGE_ZONES → CITIES
```

## Rebuilding the Database

Run these scripts in SQL Developer using **Run Script (F5)**:

```text
1. database/schema/00_setup.sql
2. database/schema/01_create_tables.sql
3. database/schema/02_constraints.sql
4. database/load/00_create_staging_tables.sql
5. database/load/01_reference_data.sql
```

## Importing Source Data

These three source files must first be imported into staging tables:

| Source file | Import into |
|---|---|
| `sa_drivers.csv` | `STG_SA_DRIVERS` |
| `sa_riders.csv` | `STG_SA_RIDERS` |
| `pricing_surge_zones.csv` | `STG_PRICING_SURGE_ZONES` |

Import **all columns** from each CSV.

Expected staging row counts:

```text
STG_SA_DRIVERS             800
STG_SA_RIDERS             1200
STG_PRICING_SURGE_ZONES      9
```

Then run:

```text
database/load/02_transform_staging.sql
```

Expected normalized row counts:

```text
SA_DRIVERS             800
SA_RIDERS             1200
PRICING_SURGE_ZONES      9
```

## Remaining Direct Imports

| Source file | Final table | Expected rows |
|---|---|---:|
| `vehicles.csv` | `VEHICLES` | 800 |
| `trip_headers_clean.csv` | `TRIP_HEADERS` | 50,000 |
| `trip_fare_breakdown.csv` | `TRIP_FARE_BREAKDOWN` | 50,000 |
| `trip_reviews.csv` | `TRIP_REVIEWS` | 25,055 |

Use `trip_headers_clean.csv` rather than the original trip header file so completed trips have a proper `NULL` cancellation reason.

For `request_timestamp`, use the timestamp format matching the CSV values during SQL Developer import.

## Main Relationships

```text
PROVINCES 1 ─── 0..* CITIES

CITIES 1 ─── 0..* SA_DRIVERS
CITIES 1 ─── 0..* SA_RIDERS
CITIES 1 ─── 0..* PRICING_SURGE_ZONES

PLATFORM_AFFILIATION 1 ─── 0..* SA_DRIVERS

SA_DRIVERS 1 ─── 0..1 VEHICLES
SA_DRIVERS 1 ─── 0..* TRIP_HEADERS

SA_RIDERS 1 ─── 0..* TRIP_HEADERS

PRICING_SURGE_ZONES 1 ─── 0..* TRIP_HEADERS

TRIP_HEADERS 1 ─── 1 TRIP_FARE_BREAKDOWN
TRIP_HEADERS 1 ─── 0..1 TRIP_REVIEWS
```

## Research Queries

Research-question SQL files are stored under:

```text
database/queries/
```

### RQ03 — Driver Earnings and Platform Commission

`RQ03_driver_commission_rate.sql`

Analyses total fare value, nominal and effective commission rates, platform commission, driver payout and driver retention by platform affiliation.

### RQ04 — Surge Timing Patterns

`RQ04_surge_timing_patterns.sql`

Analyses surge occurrence by hour and operating period, with comparison across cities.

## Validation

```sql
SELECT COUNT(*) FROM SA_DRIVERS;
SELECT COUNT(*) FROM SA_RIDERS;
SELECT COUNT(*) FROM VEHICLES;
SELECT COUNT(*) FROM PRICING_SURGE_ZONES;
SELECT COUNT(*) FROM TRIP_HEADERS;
SELECT COUNT(*) FROM TRIP_FARE_BREAKDOWN;
SELECT COUNT(*) FROM TRIP_REVIEWS;
```

Expected:

```text
SA_DRIVERS                800
SA_RIDERS                1200
VEHICLES                  800
PRICING_SURGE_ZONES         9
TRIP_HEADERS            50000
TRIP_FARE_BREAKDOWN     50000
TRIP_REVIEWS            25055
```

## Docker

Start Oracle:

```powershell
docker compose start
```

Stop Oracle:

```powershell
docker compose stop
```

The Oracle data remains in the Docker named volume when the container is stopped.

Avoid `docker compose down -v` unless the database volume should intentionally be deleted.
