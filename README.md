# 7Devs CMPG321 Project

Oracle database environment for the CMPG321 Phase 2 project.

## Requirements

Recommended:

- Docker Desktop
- Oracle SQL Developer
- Git

## 1. Clone the repository

```bash
git clone https://github.com/stephvr/7Devs-CMPG321.git
cd 7Devs-CMPG321
```

## 2. Start Oracle with Docker

```bash
docker compose up -d
```

Check that the container is running:

```bash
docker ps
```

Container name:

```text
cmpg321-oracle
```

## 3. SQL Developer connection

Connect to the Oracle container using:

```text
Host: localhost
Port: 1522
Service Name: FREEPDB1
Username: system
Password: cmpg321
```

## 4. Create the project user

Run the following while connected as `SYSTEM`:

```sql
CREATE USER cmpg321 IDENTIFIED BY cmpg321;

GRANT CREATE SESSION TO cmpg321;
GRANT CREATE TABLE TO cmpg321;
GRANT CREATE VIEW TO cmpg321;
GRANT CREATE SEQUENCE TO cmpg321;
GRANT CREATE PROCEDURE TO cmpg321;
GRANT CREATE TRIGGER TO cmpg321;

ALTER USER cmpg321 QUOTA UNLIMITED ON USERS;
```

Then create a second SQL Developer connection:

```text
Connection Name: CMPG321 Project
Username: cmpg321
Password: cmpg321
Host: localhost
Port: 1522
Service Name: FREEPDB1
```

Use this connection for the project tables and queries rather than `SYSTEM`.

## 5. Create the database schema

Open:

```text
database/schema/00_setup.sql
```

Run it using **Run Script (F5)** in Oracle SQL Developer.

The setup script executes:

```text
01_create_tables.sql
02_constraints.sql
```

The schema contains the following seven tables:

- `SA_DRIVERS`
- `SA_RIDERS`
- `PRICING_SURGE_ZONES`
- `VEHICLES`
- `TRIP_HEADERS`
- `TRIP_FARE_BREAKDOWN`
- `TRIP_REVIEWS`

## 6. Load the data

Import the CSV files from:

```text
database/data/
```

Load the tables in this order so that foreign-key dependencies are satisfied:

1. `SA_DRIVERS`
2. `SA_RIDERS`
3. `PRICING_SURGE_ZONES`
4. `VEHICLES`
5. `TRIP_HEADERS`
6. `TRIP_FARE_BREAKDOWN`
7. `TRIP_REVIEWS`

### Import notes

For `SA_DRIVERS.onboarding_date` and `SA_RIDERS.account_created_date`, use:

```text
YYYY/MM/DD
```

For `TRIP_HEADERS.request_timestamp`, use:

```text
YYYY-MM-DD HH24:MI:SS
```

For completed trips, `cancellation_reason` should be imported as `NULL`. The cleaned trip-header CSV should therefore be used if the original file contains `N/A` for completed trips.

## 7. Verify the imported data

Run:

```sql
SELECT 'SA_DRIVERS' AS table_name, COUNT(*) AS row_count FROM SA_DRIVERS
UNION ALL
SELECT 'SA_RIDERS', COUNT(*) FROM SA_RIDERS
UNION ALL
SELECT 'PRICING_SURGE_ZONES', COUNT(*) FROM PRICING_SURGE_ZONES
UNION ALL
SELECT 'VEHICLES', COUNT(*) FROM VEHICLES
UNION ALL
SELECT 'TRIP_HEADERS', COUNT(*) FROM TRIP_HEADERS
UNION ALL
SELECT 'TRIP_FARE_BREAKDOWN', COUNT(*) FROM TRIP_FARE_BREAKDOWN
UNION ALL
SELECT 'TRIP_REVIEWS', COUNT(*) FROM TRIP_REVIEWS;
```

Expected row counts:

| Table | Rows |
|---|---:|
| `SA_DRIVERS` | 800 |
| `SA_RIDERS` | 1200 |
| `PRICING_SURGE_ZONES` | 9 |
| `VEHICLES` | 800 |
| `TRIP_HEADERS` | 50000 |
| `TRIP_FARE_BREAKDOWN` | 50000 |
| `TRIP_REVIEWS` | 25055 |

## 8. Stop or restart the database

Stop Oracle:

```bash
docker compose stop
```

Start it again:

```bash
docker compose start
```

Stop and remove the container while preserving the named database volume:

```bash
docker compose down
```

Do **not** use `docker compose down -v` unless you intentionally want to delete the stored Oracle database data.

## Project structure

```text
7Devs-CMPG321/
├── database/
│   ├── data/
│   │   ├── sa_drivers.csv
│   │   ├── sa_riders.csv
│   │   ├── pricing_surge_zones.csv
│   │   ├── vehicles.csv
│   │   ├── trip_headers_clean.csv
│   │   ├── trip_fare_breakdown.csv
│   │   └── trip_reviews.csv
│   ├── schema/
│   │   ├── 00_setup.sql
│   │   ├── 01_create_tables.sql
│   │   └── 02_constraints.sql
│   └── queries/
├── docker-compose.yml
├── .gitignore
└── README.md
```

## Team workflow

Before starting work:

```bash
git pull
```

After making changes:

```bash
git add .
git commit -m "Describe the change"
git push
```

Database schema changes should be committed as SQL files so that every team member can reproduce the same database structure.
