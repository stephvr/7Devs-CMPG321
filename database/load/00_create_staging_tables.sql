/*
   Raw CSV Staging Tables

   These tables match the original supplied CSV structure.
   Data is imported here first, then transformed into the
   normalized 3NF tables.
*/


/* 
   RAW DRIVERS
*/

CREATE TABLE STG_SA_DRIVERS (
    driver_id VARCHAR2(9),
    first_name VARCHAR2(20),
    last_name VARCHAR2(20),
    operating_city VARCHAR2(20),
    platform_affiliation VARCHAR2(20),
    platform_commission_pct NUMBER(3,2),
    driver_rating NUMBER(3,2),
    total_lifetime_trips NUMBER(6),
    onboarding_date DATE
);


/*
   RAW RIDERS
*/

CREATE TABLE STG_SA_RIDERS (
    rider_id VARCHAR2(12),
    first_name VARCHAR2(20),
    last_name VARCHAR2(20),
    mobile_number VARCHAR2(11),
    home_city VARCHAR2(20),
    province VARCHAR2(20),
    preferred_payment VARCHAR2(13),
    account_created_date DATE
);


/*
   RAW PRICING / SURGE ZONES
*/

CREATE TABLE STG_PRICING_SURGE_ZONES (
    zone_id VARCHAR2(21),
    zone_name VARCHAR2(40),
    city VARCHAR2(20),
    base_fare_zar NUMBER(6,2),
    per_km_rate_zar NUMBER(6,2),
    per_min_rate_zar NUMBER(4,2)
);