/* 
   RQ3 - DRIVER COMMISSION RATE
   

   Research Question:
   How much of the total fare value do drivers retain after
   deducting platform commission rates?

   How do these rates vary by platform?
*/


/* 
   QUERY 1: Driver retention and commission by platform
*/

WITH completed_trip_financials AS (
    SELECT
        d.platform_affiliation,
        d.platform_commission_pct,
        f.total_fare_zar,
        f.tip_zar,
        f.tolls_zar,
        f.platform_commission_zar,
        f.driver_payout_zar
    FROM SA_DRIVERS d
    JOIN TRIP_HEADERS h
        ON d.driver_id = h.driver_id
    JOIN TRIP_FARE_BREAKDOWN f
        ON h.trip_id = f.trip_id
    WHERE h.trip_status = 'COMPLETED'
)
SELECT
    platform_affiliation,

    ROUND(AVG(platform_commission_pct) * 100, 2)
        AS nominal_commission_pct,

    COUNT(*) AS completed_trips,

    ROUND(SUM(total_fare_zar), 2)
        AS total_fare_zar,

    ROUND(SUM(total_fare_zar - tip_zar - tolls_zar), 2)
        AS commissionable_fare_zar,

    ROUND(SUM(platform_commission_zar), 2)
        AS platform_commission_zar,

    ROUND(
        SUM(platform_commission_zar)
        / NULLIF(SUM(total_fare_zar), 0) * 100,
        2
    ) AS effective_commission_pct,

    ROUND(SUM(driver_payout_zar), 2)
        AS driver_payout_zar,

    ROUND(
        SUM(driver_payout_zar)
        / NULLIF(SUM(total_fare_zar), 0) * 100,
        2
    ) AS driver_retention_pct

FROM completed_trip_financials
GROUP BY platform_affiliation
ORDER BY driver_retention_pct DESC;


/* 
   QUERY 2: Validate the commission calculation
   Confirms whether commission is calculated on total fare
   excluding tips and tolls
 */

SELECT
    d.platform_affiliation,

    COUNT(*) AS completed_trips,

    SUM(
        CASE
            WHEN ABS(
                f.platform_commission_zar -
                ROUND(
                    (f.total_fare_zar - f.tip_zar - f.tolls_zar)
                    * d.platform_commission_pct,
                    2
                )
            ) <= 0.01
            THEN 1
            ELSE 0
        END
    ) AS matching_trips,

    SUM(
        CASE
            WHEN ABS(
                f.platform_commission_zar -
                ROUND(
                    (f.total_fare_zar - f.tip_zar - f.tolls_zar)
                    * d.platform_commission_pct,
                    2
                )
            ) > 0.01
            THEN 1
            ELSE 0
        END
    ) AS non_matching_trips

FROM SA_DRIVERS d
JOIN TRIP_HEADERS h
    ON d.driver_id = h.driver_id
JOIN TRIP_FARE_BREAKDOWN f
    ON h.trip_id = f.trip_id
WHERE h.trip_status = 'COMPLETED'
GROUP BY d.platform_affiliation
ORDER BY d.platform_affiliation;