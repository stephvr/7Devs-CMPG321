



/*
   SA_DRIVERS
   Convert operating_city and platform_affiliation to foreign keys
 */

INSERT INTO SA_DRIVERS (
    driver_id,
    affiliation_id,
    city_id,
    first_name,
    last_name,
    driver_rating,
    total_lifetime_trips,
    onboarding_date
)
SELECT
    s.driver_id,
    pa.affiliation_id,
    c.city_id,
    s.first_name,
    s.last_name,
    s.driver_rating,
    s.total_lifetime_trips,
    s.onboarding_date
FROM STG_SA_DRIVERS s
JOIN PLATFORM_AFFILIATION pa
    ON pa.affiliation_name = s.platform_affiliation
JOIN CITIES c
    ON c.city_name = s.operating_city;


/*
   SA_RIDERS
   Convert home_city to city_id.
   Province is obtained through CITIES -> PROVINCES.
*/

INSERT INTO SA_RIDERS (
    rider_id,
    city_id,
    first_name,
    last_name,
    mobile_number,
    preferred_payment,
    account_created_date
)
SELECT
    s.rider_id,
    c.city_id,
    s.first_name,
    s.last_name,
    s.mobile_number,
    s.preferred_payment,
    s.account_created_date
FROM STG_SA_RIDERS s
JOIN CITIES c
    ON c.city_name = s.home_city
JOIN PROVINCES p
    ON p.province_id = c.province_id
   AND p.province_name = s.province;


/*
   PRICING_SURGE_ZONES
   Convert city name to city_id
*/

INSERT INTO PRICING_SURGE_ZONES (
    zone_id,
    city_id,
    zone_name,
    base_fare_zar,
    per_km_rate_zar,
    per_min_rate_zar
)
SELECT
    s.zone_id,
    c.city_id,
    s.zone_name,
    s.base_fare_zar,
    s.per_km_rate_zar,
    s.per_min_rate_zar
FROM STG_PRICING_SURGE_ZONES s
JOIN CITIES c
    ON c.city_name = s.city;




COMMIT;