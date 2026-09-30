/*
   RQ04
   During which hours or operating periods does surge pricing
   occur, and how do surge multipliers vary across cities?
*/


/*
   1. SURGE PRICING BY HOUR
*/

SELECT
    EXTRACT(HOUR FROM h.request_timestamp) AS request_hour,

    COUNT(*) AS completed_trips,

    SUM(
        CASE
            WHEN f.surge_multiplier > 1
            THEN 1
            ELSE 0
        END
    ) AS surge_trips,

    ROUND(
        100 *
        SUM(
            CASE
                WHEN f.surge_multiplier > 1
                THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS surge_trip_pct,

    ROUND(AVG(f.surge_multiplier), 2)
        AS avg_surge_multiplier,

    MAX(f.surge_multiplier)
        AS max_surge_multiplier

FROM TRIP_HEADERS h

JOIN TRIP_FARE_BREAKDOWN f
    ON h.trip_id = f.trip_id

WHERE h.trip_status = 'COMPLETED'

GROUP BY
    EXTRACT(HOUR FROM h.request_timestamp)

ORDER BY
    request_hour;


/*
   2. SURGE PRICING BY CITY AND OPERATING PERIOD
 */

WITH trip_periods AS (
    SELECT
        c.city_name,

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
        END AS operating_period,

        f.surge_multiplier

    FROM TRIP_HEADERS h

    JOIN TRIP_FARE_BREAKDOWN f
        ON h.trip_id = f.trip_id

    JOIN PRICING_SURGE_ZONES z
        ON h.zone_id = z.zone_id

    JOIN CITIES c
        ON z.city_id = c.city_id

    WHERE h.trip_status = 'COMPLETED'
)

SELECT
    city_name,
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
        100 *
        SUM(
            CASE
                WHEN surge_multiplier > 1
                THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS surge_trip_pct,

    ROUND(AVG(surge_multiplier), 2)
        AS avg_surge_multiplier,

    MAX(surge_multiplier)
        AS max_surge_multiplier

FROM trip_periods

GROUP BY
    city_name,
    operating_period

ORDER BY
    city_name,
    CASE operating_period
        WHEN 'Morning Peak' THEN 1
        WHEN 'Afternoon Peak' THEN 2
        WHEN 'Late Evening' THEN 3
        WHEN 'Off-Peak' THEN 4
    END;