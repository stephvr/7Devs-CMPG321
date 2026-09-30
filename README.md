# Database Setup Instructions

These instructions are for the current normalized Oracle database used by the project.

There are **two setup paths**:

- **Clean install** — use this if you have never set up the project database before.
- **Update an existing install** — use this if you already set up the older version of the project database.

> **Docker is optional, but recommended.**
>
> The repository includes a Docker configuration so that everyone can use the same Oracle environment.
>
> If you are **not using Docker**, do not follow the Docker-specific commands or Docker connection values below. Use your own Oracle installation and connection details instead. The SQL scripts and CSV import steps are still the same.

---

# Prerequisites

You need:

- Git
- Oracle SQL Developer
- Oracle Database
- Docker Desktop **only if you choose the recommended Docker setup**

---

# A. Clean Install

Use this section if you have **not created the project database before**.

## 1. Clone the repository

```powershell
git clone https://github.com/stephvr/uber-bolt-operations-analysis.git
cd uber-bolt-operations-analysis
```

If you already cloned the repository but have not created the database yet:

```powershell
git switch main
git pull
```

---

## 2. Start Oracle

### Recommended: Docker

Make sure Docker Desktop is running.

From the repository root:

```powershell
docker compose up -d
```

The first run may take a while because Docker may need to download the Oracle image.

Check that the container is running:

```powershell
docker ps
```

For the Docker setup used by this project:

```text
Host:         localhost
Port:         1522
Service name: FREEPDB1
SYSTEM password: cmpg321
```

### If you are not using Docker

Skip all Docker commands.

Start your own Oracle Database installation and use its own:

```text
Host
Port
Service name / SID
SYSTEM password
```

Do not use the Docker connection values unless your own Oracle installation happens to use the same values.

---

## 3. Create the CMPG321 database user

Open Oracle SQL Developer and connect as `SYSTEM`.

### Docker connection

```text
Username:     SYSTEM
Password:     cmpg321
Hostname:     localhost
Port:         1522
Service name: FREEPDB1
```

If you are using your own Oracle installation, use your own `SYSTEM` connection details instead.

Run:

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

---

## 4. Connect as CMPG321

Create a new SQL Developer connection.

### Docker connection

```text
Username:     CMPG321
Password:     cmpg321
Hostname:     localhost
Port:         1522
Service name: FREEPDB1
```

If you are not using Docker, use the connection details for your own Oracle installation.

All remaining SQL scripts must be run while connected as `CMPG321`.

---

## 5. Create the database structure

Run the following files in this exact order using **Run Script (F5)**:

```text
1. database/schema/00_setup.sql
2. database/schema/01_create_tables.sql
3. database/schema/02_constraints.sql
4. database/load/00_create_staging_tables.sql
5. database/load/01_reference_data.sql
```

What these scripts do:

```text
00_setup.sql
    Removes old project/staging tables if they exist.

01_create_tables.sql
    Creates the normalized project tables.

02_constraints.sql
    Adds primary keys, foreign keys, unique constraints and checks.

00_create_staging_tables.sql
    Creates temporary staging tables that match the original CSV structure.

01_reference_data.sql
    Inserts the province, city and platform-affiliation lookup data.
```

Do not import any CSV files before these scripts have completed successfully.

---

## 6. Import the three staging CSV files

The following three source files cannot be imported directly into the final normalized tables.

Use SQL Developer's **Import Data** option and import **all columns**.

| Source file | Import into |
|---|---|
| `sa_drivers.csv` | `STG_SA_DRIVERS` |
| `sa_riders.csv` | `STG_SA_RIDERS` |
| `pricing_surge_zones.csv` | `STG_PRICING_SURGE_ZONES` |

Important:

- Import into the `STG_...` tables, **not** the final tables.
- Keep the CSV header enabled.
- Map each source column to the matching staging-table column.
- `onboarding_date` and `account_created_date` are Oracle `DATE` columns. Set the import date mask to match the values shown in the CSV preview.
- `pricing_surge_zones.csv` has no date field.

Verify the imports:

```sql
SELECT COUNT(*) AS drivers
FROM STG_SA_DRIVERS;

SELECT COUNT(*) AS riders
FROM STG_SA_RIDERS;

SELECT COUNT(*) AS zones
FROM STG_PRICING_SURGE_ZONES;
```

Expected:

```text
STG_SA_DRIVERS             800
STG_SA_RIDERS             1200
STG_PRICING_SURGE_ZONES      9
```

Do not continue if these counts are wrong.

---

## 7. Transform the staging data

Run:

```text
database/load/02_transform_staging.sql
```

Use **Run Script (F5)**.

This converts the denormalized city, province and platform values into the foreign-key IDs used by the normalized schema.

Verify:

```sql
SELECT COUNT(*) AS drivers
FROM SA_DRIVERS;

SELECT COUNT(*) AS riders
FROM SA_RIDERS;

SELECT COUNT(*) AS zones
FROM PRICING_SURGE_ZONES;
```

Expected:

```text
SA_DRIVERS             800
SA_RIDERS             1200
PRICING_SURGE_ZONES      9
```

---

## 8. Import the remaining CSV files

Import these files directly into their final tables in this order:

| Order | Source file | Import into | Expected rows |
|---:|---|---|---:|
| 1 | `vehicles.csv` | `VEHICLES` | 800 |
| 2 | `trip_headers_clean.csv` | `TRIP_HEADERS` | 50,000 |
| 3 | `trip_fare_breakdown.csv` | `TRIP_FARE_BREAKDOWN` | 50,000 |
| 4 | `trip_reviews.csv` | `TRIP_REVIEWS` | 25,055 |

Import **all columns**.

Important:

- Use `trip_headers_clean.csv`, **not** the original `trip_headers.csv`.
- Blank `cancellation_reason` values must remain `NULL`.
- `TRIP_HEADERS.request_timestamp` is an Oracle `TIMESTAMP`. In the import wizard, set the timestamp mask to match the value shown in the CSV preview.
- Import `TRIP_HEADERS` before fare breakdowns and reviews because those tables reference trips.

---

## 9. Final validation

Run:

```sql
SELECT COUNT(*) AS provinces FROM PROVINCES;
SELECT COUNT(*) AS cities FROM CITIES;
SELECT COUNT(*) AS affiliations FROM PLATFORM_AFFILIATION;
SELECT COUNT(*) AS drivers FROM SA_DRIVERS;
SELECT COUNT(*) AS riders FROM SA_RIDERS;
SELECT COUNT(*) AS vehicles FROM VEHICLES;
SELECT COUNT(*) AS zones FROM PRICING_SURGE_ZONES;
SELECT COUNT(*) AS trips FROM TRIP_HEADERS;
SELECT COUNT(*) AS fares FROM TRIP_FARE_BREAKDOWN;
SELECT COUNT(*) AS reviews FROM TRIP_REVIEWS;
```

Expected:

```text
PROVINCES                  5
CITIES                     7
PLATFORM_AFFILIATION       3
SA_DRIVERS               800
SA_RIDERS               1200
VEHICLES                  800
PRICING_SURGE_ZONES         9
TRIP_HEADERS            50000
TRIP_FARE_BREAKDOWN     50000
TRIP_REVIEWS            25055
```

If these counts match, the database setup is complete.

---

# B. Updating an Existing Install

Use this section if you already created and populated the **older project database**.

This update **rebuilds the project tables**. The old project data will be removed and then imported again using the new normalized schema.

## 1. Update your local repository

First make sure you do not have unfinished local changes:

```powershell
git status
```

If the working tree is clean:

```powershell
git switch main
git pull
```

If `git status` shows local changes, save or commit your work before pulling.

The setup instructions assume that the current database changes have already been merged into `main`.

---

## 2. Start Oracle

### Existing Docker setup

Make sure Docker Desktop is running, then from the repository root run:

```powershell
docker compose up -d
```

This works whether the project container is already stopped or needs to be created.

Check:

```powershell
docker ps
```

Do **not** run:

```powershell
docker compose down -v
```

That deletes the Oracle data volume.

### Existing non-Docker setup

Start your own Oracle Database normally.

Ignore the Docker commands and continue using your existing Oracle connection details.

---

## 3. Connect as CMPG321

If you originally used the project Docker setup:

```text
Username:     CMPG321
Password:     cmpg321
Hostname:     localhost
Port:         1522
Service name: FREEPDB1
```

If you use your own Oracle installation, connect using your existing details.

You do **not** need to recreate the `CMPG321` user.

---

## 4. Rebuild the project schema

> **Warning:** `00_setup.sql` drops the existing project and staging tables.

While connected as `CMPG321`, run these files in this exact order using **Run Script (F5)**:

```text
1. database/schema/00_setup.sql
2. database/schema/01_create_tables.sql
3. database/schema/02_constraints.sql
4. database/load/00_create_staging_tables.sql
5. database/load/01_reference_data.sql
```

After this step, the old project tables have been replaced by the normalized schema.

---

## 5. Re-import the three staging CSV files

Import **all columns**:

| Source file | Import into |
|---|---|
| `sa_drivers.csv` | `STG_SA_DRIVERS` |
| `sa_riders.csv` | `STG_SA_RIDERS` |
| `pricing_surge_zones.csv` | `STG_PRICING_SURGE_ZONES` |

Verify:

```sql
SELECT COUNT(*) FROM STG_SA_DRIVERS;
SELECT COUNT(*) FROM STG_SA_RIDERS;
SELECT COUNT(*) FROM STG_PRICING_SURGE_ZONES;
```

Expected:

```text
800
1200
9
```

Then run:

```text
database/load/02_transform_staging.sql
```

using **Run Script (F5)**.

---

## 6. Re-import the remaining source files

Import in this order:

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

Expected:

```text
VEHICLES                  800
TRIP_HEADERS            50000
TRIP_FARE_BREAKDOWN     50000
TRIP_REVIEWS            25055
```

Use `trip_headers_clean.csv`, not the original trip-header file.

---

## 7. Run the final validation

Run the same validation query from the clean-install section:

```sql
SELECT COUNT(*) AS provinces FROM PROVINCES;
SELECT COUNT(*) AS cities FROM CITIES;
SELECT COUNT(*) AS affiliations FROM PLATFORM_AFFILIATION;
SELECT COUNT(*) AS drivers FROM SA_DRIVERS;
SELECT COUNT(*) AS riders FROM SA_RIDERS;
SELECT COUNT(*) AS vehicles FROM VEHICLES;
SELECT COUNT(*) AS zones FROM PRICING_SURGE_ZONES;
SELECT COUNT(*) AS trips FROM TRIP_HEADERS;
SELECT COUNT(*) AS fares FROM TRIP_FARE_BREAKDOWN;
SELECT COUNT(*) AS reviews FROM TRIP_REVIEWS;
```

Expected:

```text
PROVINCES                  5
CITIES                     7
PLATFORM_AFFILIATION       3
SA_DRIVERS               800
SA_RIDERS               1200
VEHICLES                  800
PRICING_SURGE_ZONES         9
TRIP_HEADERS            50000
TRIP_FARE_BREAKDOWN     50000
TRIP_REVIEWS            25055
```

If these counts match, the update is complete.

---

# Docker Reference

These commands apply **only if you chose the Docker setup**.

Start/create Oracle:

```powershell
docker compose up -d
```

Stop Oracle without deleting it:

```powershell
docker compose stop
```

Start a stopped container:

```powershell
docker compose start
```

Remove the container but keep the named database volume:

```powershell
docker compose down
```

Do **not** use this unless you intentionally want to erase the database volume:

```powershell
docker compose down -v
```
