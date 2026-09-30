/*
   RQ03
   How much of the total fare value do drivers retain after
   deducting platform commission rates?
   How do these rates vary by platform?
 */


/*
   1. DRIVER RETENTION AND PLATFORM COMMISSION BY AFFILIATION
*/

SELECT
    pa.affiliation_name AS platform_affiliation,

    ROUND(pa.commission_pct * 100, 2)
        AS nominal_commission_pct,

    COUNT(*) AS completed_trips,

    ROUND(SUM(f.total_fare_zar), 2)
        AS total_fare_zar,

    ROUND(
        SUM(
            f.total_fare_zar
            - f.tip_zar
            - f.tolls_zar
        ),
        2
    ) AS commissionable_fare_zar,

    ROUND(SUM(f.platform_commission_zar), 2)
        AS platform_commission_zar,

    ROUND(
        SUM(f.platform_commission_zar)
        / SUM(f.total_fare_zar) * 100,
        2
    ) AS effective_commission_pct,

    ROUND(SUM(f.driver_payout_zar), 2)
        AS driver_payout_zar,

    ROUND(
        SUM(f.driver_payout_zar)
        / SUM(f.total_fare_zar) * 100,
        2
    ) AS driver_retention_pct

FROM SA_DRIVERS d

JOIN PLATFORM_AFFILIATION pa
    ON d.affiliation_id = pa.affiliation_id

JOIN TRIP_HEADERS h
    ON d.driver_id = h.driver_id

JOIN TRIP_FARE_BREAKDOWN f
    ON h.trip_id = f.trip_id

WHERE h.trip_status = 'COMPLETED'

GROUP BY
    pa.affiliation_name,
    pa.commission_pct

ORDER BY
    pa.commission_pct;


/*
   2. VALIDATE PLATFORM COMMISSION CALCULATION

   Commission should equal:
   (total fare - tip - tolls) x platform commission rate
*/

SELECT
    pa.affiliation_name AS platform_affiliation,

    COUNT(*) AS completed_trips,

    SUM(
        CASE
            WHEN ABS(
                f.platform_commission_zar
                -
                ROUND(
                    (
                        f.total_fare_zar
                        - f.tip_zar
                        - f.tolls_zar
                    ) * pa.commission_pct,
                    2
                )
            ) <= 0.01
            THEN 1
            ELSE 0
        END
    ) AS matching_commission_rows,

    SUM(
        CASE
            WHEN ABS(
                f.platform_commission_zar
                -
                ROUND(
                    (
                        f.total_fare_zar
                        - f.tip_zar
                        - f.tolls_zar
                    ) * pa.commission_pct,
                    2
                )
            ) > 0.01
            THEN 1
            ELSE 0
        END
    ) AS non_matching_commission_rows

FROM SA_DRIVERS d

JOIN PLATFORM_AFFILIATION pa
    ON d.affiliation_id = pa.affiliation_id

JOIN TRIP_HEADERS h
    ON d.driver_id = h.driver_id

JOIN TRIP_FARE_BREAKDOWN f
    ON h.trip_id = f.trip_id

WHERE h.trip_status = 'COMPLETED'

GROUP BY
    pa.affiliation_name

ORDER BY
    pa.affiliation_name;