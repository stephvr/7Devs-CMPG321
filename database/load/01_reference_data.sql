/*
   Reference Data

   Populates provinces, cities and platform affiliations
   required by the normalized 3NF schema.
*/


/*
   PROVINCES
*/

INSERT INTO PROVINCES (province_id, province_name)
VALUES (1, 'Eastern Cape');

INSERT INTO PROVINCES (province_id, province_name)
VALUES (2, 'Gauteng');

INSERT INTO PROVINCES (province_id, province_name)
VALUES (3, 'KwaZulu-Natal');

INSERT INTO PROVINCES (province_id, province_name)
VALUES (4, 'North West');

INSERT INTO PROVINCES (province_id, province_name)
VALUES (5, 'Western Cape');


/* ============================================================
   CITIES
   ============================================================ */

INSERT INTO CITIES (city_id, city_name, province_id)
VALUES (1, 'Cape Town', 5);

INSERT INTO CITIES (city_id, city_name, province_id)
VALUES (2, 'Durban', 3);

INSERT INTO CITIES (city_id, city_name, province_id)
VALUES (3, 'Gqeberha', 1);

INSERT INTO CITIES (city_id, city_name, province_id)
VALUES (4, 'Johannesburg', 2);

INSERT INTO CITIES (city_id, city_name, province_id)
VALUES (5, 'Potchefstroom', 4);

INSERT INTO CITIES (city_id, city_name, province_id)
VALUES (6, 'Pretoria', 2);

INSERT INTO CITIES (city_id, city_name, province_id)
VALUES (7, 'Vanderbijlpark', 2);


/* ============================================================
   PLATFORM AFFILIATIONS
   ============================================================ */

INSERT INTO PLATFORM_AFFILIATION
    (affiliation_id, affiliation_name, commission_pct)
VALUES
    (1, 'Uber', 0.25);

INSERT INTO PLATFORM_AFFILIATION
    (affiliation_id, affiliation_name, commission_pct)
VALUES
    (2, 'Bolt', 0.20);

INSERT INTO PLATFORM_AFFILIATION
    (affiliation_id, affiliation_name, commission_pct)
VALUES
    (3, 'Dual-Platform (Both)', 0.22);


/* ============================================================
   SAVE REFERENCE DATA
   ============================================================ */

COMMIT;