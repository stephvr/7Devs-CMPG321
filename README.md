# Setup Instructions

Use the section that matches your situation:

- **Clean installation** — you have not set up the project database before.
- **Updating an existing installation** — you already set up the previous database version.

The current database uses the normalized 3NF schema.

---

# A. Clean Installation

## 1. Clone the Repository

```powershell
git clone https://github.com/stephvr/uber-bolt-operations-analysis.git
cd uber-bolt-operations-analysis
```

If you already cloned the repository but have never created the database, simply pull the latest version:

```powershell
git pull
```

---

## 2. Start Oracle

From the repository root:

```powershell
docker compose up -d
```

Check that the container is running:

```powershell
docker ps
```

Oracle is exposed on host port `1522`.

---

## 3. Create the CMPG321 Oracle User

Connect in SQL Developer as `SYSTEM`.

Use:

```text
Username:     SYSTEM
Password:     cmpg321
Hostname:     localhost
Port:         1522
Service name: FREEPDB1
```

Create the project user:

```sql
CREATE USER CMPG321 IDENTIFIED BY cmpg321;

GRANT CREATE SESSION,
      CREATE TABLE,
      CREATE VIEW,
      CREATE SEQUENCE,
      CREATE PROCEDURE,
      CREATE TRIGGER
TO CMPG321;

ALTER USER CMPG321 QUOTA UNLIMITED ON USERS;
```

If the user already exists, skip this step.

---

## 4. Connect as CMPG321

Create a SQL Developer connection with:

```text
Username:     CMPG321
Password:     cmpg321
Hostname:     localhost
Port:         1522
Service name: FREEPDB1
```

---

## 5. Create the Database Structure

While connected as `CMPG321`, run these files using **Run Script (F5)** in this order:

```text
database/schema/00_setup.sql
database/schema/01_create_tables.sql
database/schema/02_constraints.sql
database/load/00_create_staging_tables.sql
database/load/01_reference_data.sql
```

---

## 6. Import the Three Staging CSV Files

Use SQL Developer's **Import Data** option.

Import **all columns**.

```text
sa_drivers.csv
→ STG_SA_DRIVERS

sa_riders.csv
→ STG_SA_RIDERS

pricing_surge_zones.csv
→ STG_PRICING_SURGE_ZONES
```

For date columns, use the date format matching the CSV values.

Expected row counts:

```text
STG_SA_DRIVERS             800
STG_SA_RIDERS             1200
STG_PRICING_SURGE_ZONES      9
```

Verify with:

```sql
SELECT COUNT(*) FROM STG_SA_DRIVERS;
SELECT COUNT(*) FROM STG_SA_RIDERS;
SELECT COUNT(*) FROM STG_PRICING_SURGE_ZONES;
```

---

## 7. Transform the Staging Data

Run:

```text
database/load/02_transform_staging.sql
```

Verify:

```sql
SELECT COUNT(*) FROM SA_DRIVERS;
SELECT COUNT(*) FROM SA_RIDERS;
SELECT COUNT(*) FROM PRICING_SURGE_ZONES;
```

Expected:

```text
SA_DRIVERS             800
SA_RIDERS             1200
PRICING_SURGE_ZONES      9
```

---

## 8. Import the Remaining CSV Files

Import these directly into the final tables:

```text
vehicles.csv
→ VEHICLES

trip_headers_clean.csv
→ TRIP_HEADERS

trip_fare_breakdown.csv
→ TRIP_FARE_BREAKDOWN

trip_reviews.csv
→ TRIP_REVIEWS
```

Import all columns.

For `TRIP_HEADERS.request_timestamp`, use the timestamp format matching the CSV values.

Use `trip_headers_clean.csv`, not the original trip headers file.

Expected row counts:

```text
VEHICLES                  800
TRIP_HEADERS            50000
TRIP_FARE_BREAKDOWN     50000
TRIP_REVIEWS            25055
```

---

# B. Updating an Existing Installation

Use this section if you already created and populated the previous 7-table database.

## 1. Save Any Work You Need

The new schema replaces the previous database structure.

`database/schema/00_setup.sql` drops the existing project tables before rebuilding them.

If you have personal test data or SQL that is not stored in Git, save it before continuing.

---

## 2. Update the Repository

Check that your own work is committed or saved first:

```powershell
git status
```

Then update your local repository:

```powershell
git switch main
git pull
```

If your team is using the normalization branch before it is merged, switch to that branch instead:

```powershell
git switch database/normalize-schema
git pull
```

---

## 3. Start the Existing Oracle Container

```powershell
docker compose start
```

If the container is not currently created, use:

```powershell
docker compose up -d
```

Check:

```powershell
docker ps
```

Do **not** delete the Docker volume.

---

## 4. Connect as CMPG321

Use the existing connection:

```text
Username:     CMPG321
Password:     cmpg321
Hostname:     localhost
Port:         1522
Service name: FREEPDB1
```

There is no need to recreate the `CMPG321` user.

---

## 5. Rebuild the Database

Run these scripts with **Run Script (F5)** in this order:

```text
database/schema/00_setup.sql
database/schema/01_create_tables.sql
database/schema/02_constraints.sql
database/load/00_create_staging_tables.sql
database/load/01_reference_data.sql
```

This removes the old project tables and creates the new normalized schema.

---

## 6. Re-import the Three Staging CSV Files

Import all columns:

```text
sa_drivers.csv
→ STG_SA_DRIVERS

sa_riders.csv
→ STG_SA_RIDERS

pricing_surge_zones.csv
→ STG_PRICING_SURGE_ZONES
```

Expected:

```text
STG_SA_DRIVERS             800
STG_SA_RIDERS             1200
STG_PRICING_SURGE_ZONES      9
```

Then run:

```text
database/load/02_transform_staging.sql
```

---

## 7. Re-import the Remaining CSV Files

```text
vehicles.csv
→ VEHICLES

trip_headers_clean.csv
→ TRIP_HEADERS

trip_fare_breakdown.csv
→ TRIP_FARE_BREAKDOWN

trip_reviews.csv
→ TRIP_REVIEWS
```

Expected row counts:

```text
VEHICLES                  800
TRIP_HEADERS            50000
TRIP_FARE_BREAKDOWN     50000
TRIP_REVIEWS            25055
```

---

# Final Validation

Run:

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

---

# Docker Commands

Start the existing container:

```powershell
docker compose start
```

Stop the container:

```powershell
docker compose stop
```

Create/start the container if it does not exist:

```powershell
docker compose up -d
```

Remove the container while keeping the database volume:

```powershell
docker compose down
```

Do **not** use:

```powershell
docker compose down -v
```

unless you intentionally want to delete the Oracle data volume.
