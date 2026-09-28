/* ============================================================
   RQ4 - SURGE TIMING AND MULTIPLIER PATTERNS
   ============================================================ */


/* ============================================================
   QUERY 1: Surge patterns by hour of day
   ============================================================ */

SELECT
    EXTRACT(HOUR FROM h.request_timestamp) AS trip_hour,

    COUNT(*) AS completed_trips,

    SUM(
        CASE
            WHEN f.surge_multiplier > 1
            THEN 1
            ELSE 0
        END
    ) AS surge_trips,

    ROUND(
        SUM(
            CASE
                WHEN f.surge_multiplier > 1
                THEN 1
                ELSE 0
            END
        ) / COUNT(*) * 100,
        2
    ) AS surge_trip_pct,

    ROUND(AVG(f.surge_multiplier), 2)
        AS avg_surge_multiplier,

    ROUND(MAX(f.surge_multiplier), 2)
        AS max_surge_multiplier

FROM TRIP_HEADERS h
JOIN TRIP_FARE_BREAKDOWN f
    ON h.trip_id = f.trip_id

WHERE h.trip_status = 'COMPLETED'

GROUP BY EXTRACT(HOUR FROM h.request_timestamp)

ORDER BY trip_hour;


/* ============================================================
   QUERY 2: Surge multiplier by city and operating period
   ============================================================ */

WITH surge_periods AS (
    SELECT
        z.city,
        f.surge_multiplier,

        CASE
            WHEN EXTRACT(HOUR FROM h.request_timestamp)
                 BETWEEN 7 AND 9
                THEN 'Morning Peak'

            WHEN EXTRACT(HOUR FROM h.request_timestamp)
                 BETWEEN 16 AND 19
                THEN 'Afternoon Peak'

            WHEN EXTRACT(HOUR FROM h.request_timestamp)
                 BETWEEN 21 AND 23
                THEN 'Late Evening'

            ELSE 'Off-Peak'
        END AS operating_period

    FROM TRIP_HEADERS h
    JOIN TRIP_FARE_BREAKDOWN f
        ON h.trip_id = f.trip_id
    JOIN PRICING_SURGE_ZONES z
        ON h.zone_id = z.zone_id

    WHERE h.trip_status = 'COMPLETED'
)

SELECT
    city,
    operating_period,

    COUNT(*) AS completed_trips,

    SUM(
        CASE
            WHEN surge_multiplier > 1
            THEN 1
            ELSE 0
        END
    ) AS surge_trips,

    ROUND(
        SUM(
            CASE
                WHEN surge_multiplier > 1
                THEN 1
                ELSE 0
            END
        ) / COUNT(*) * 100,
        2
    ) AS surge_trip_pct,

    ROUND(AVG(surge_multiplier), 2)
        AS avg_surge_multiplier,

    ROUND(MAX(surge_multiplier), 2)
        AS max_surge_multiplier

FROM surge_periods

GROUP BY
    city,
    operating_period

ORDER BY
    city,
    CASE operating_period
        WHEN 'Morning Peak' THEN 1
        WHEN 'Afternoon Peak' THEN 2
        WHEN 'Late Evening' THEN 3
        ELSE 4
    END;