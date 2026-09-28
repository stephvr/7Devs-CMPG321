-- =========================================
-- PRIMARY KEYS
-- =========================================

ALTER TABLE SA_DRIVERS
ADD CONSTRAINT pk_sa_drivers
PRIMARY KEY (driver_id);

ALTER TABLE SA_RIDERS
ADD CONSTRAINT pk_sa_riders
PRIMARY KEY (rider_id);

ALTER TABLE PRICING_SURGE_ZONES
ADD CONSTRAINT pk_pricing_zones
PRIMARY KEY (zone_id);

ALTER TABLE VEHICLES
ADD CONSTRAINT pk_vehicles
PRIMARY KEY (vehicle_id);

ALTER TABLE TRIP_HEADERS
ADD CONSTRAINT pk_trip_headers
PRIMARY KEY (trip_id);

ALTER TABLE TRIP_FARE_BREAKDOWN
ADD CONSTRAINT pk_trip_fare
PRIMARY KEY (trip_id);

ALTER TABLE TRIP_REVIEWS
ADD CONSTRAINT pk_trip_reviews
PRIMARY KEY (review_id);


-- =========================================
-- FOREIGN KEYS
-- =========================================

ALTER TABLE VEHICLES
ADD CONSTRAINT fk_vehicle_driver
FOREIGN KEY (driver_id)
REFERENCES SA_DRIVERS(driver_id);

ALTER TABLE TRIP_HEADERS
ADD CONSTRAINT fk_trip_rider
FOREIGN KEY (rider_id)
REFERENCES SA_RIDERS(rider_id);

ALTER TABLE TRIP_HEADERS
ADD CONSTRAINT fk_trip_driver
FOREIGN KEY (driver_id)
REFERENCES SA_DRIVERS(driver_id);

ALTER TABLE TRIP_HEADERS
ADD CONSTRAINT fk_trip_zone
FOREIGN KEY (zone_id)
REFERENCES PRICING_SURGE_ZONES(zone_id);

ALTER TABLE TRIP_FARE_BREAKDOWN
ADD CONSTRAINT fk_fare_trip
FOREIGN KEY (trip_id)
REFERENCES TRIP_HEADERS(trip_id);

ALTER TABLE TRIP_REVIEWS
ADD CONSTRAINT fk_review_trip
FOREIGN KEY (trip_id)
REFERENCES TRIP_HEADERS(trip_id);


-- =========================================
-- UNIQUE CONSTRAINTS
-- =========================================

ALTER TABLE VEHICLES
ADD CONSTRAINT uq_license_plate
UNIQUE (license_plate);

ALTER TABLE TRIP_REVIEWS
ADD CONSTRAINT uq_review_trip
UNIQUE (trip_id);

ALTER TABLE VEHICLES
ADD CONSTRAINT uq_vehicle_driver
UNIQUE (driver_id);


-- =========================================
-- SA_DRIVERS CHECK CONSTRAINTS
-- =========================================

ALTER TABLE SA_DRIVERS
ADD CONSTRAINT chk_platform_affiliation
CHECK (
    platform_affiliation IN (
        'Uber',
        'Bolt',
        'Dual-Platform (Both)'
    )
);

ALTER TABLE SA_DRIVERS
ADD CONSTRAINT chk_commission_rate
CHECK (
    (platform_affiliation = 'Uber'
        AND platform_commission_pct = 0.25)
    OR
    (platform_affiliation = 'Bolt'
        AND platform_commission_pct = 0.20)
    OR
    (platform_affiliation = 'Dual-Platform (Both)'
        AND platform_commission_pct = 0.22)
);

ALTER TABLE SA_DRIVERS
ADD CONSTRAINT chk_driver_rating
CHECK (driver_rating BETWEEN 1 AND 5);

ALTER TABLE SA_DRIVERS
ADD CONSTRAINT chk_lifetime_trips
CHECK (total_lifetime_trips >= 0);


-- =========================================
-- PRICING_SURGE_ZONES CHECK CONSTRAINTS
-- =========================================

ALTER TABLE PRICING_SURGE_ZONES
ADD CONSTRAINT chk_zone_base_fare
CHECK (base_fare_zar > 0);

ALTER TABLE PRICING_SURGE_ZONES
ADD CONSTRAINT chk_zone_km_rate
CHECK (per_km_rate_zar > 0);

ALTER TABLE PRICING_SURGE_ZONES
ADD CONSTRAINT chk_zone_min_rate
CHECK (per_min_rate_zar > 0);


-- =========================================
-- TRIP_HEADERS CHECK CONSTRAINTS
-- =========================================

ALTER TABLE TRIP_HEADERS
ADD CONSTRAINT chk_ride_category
CHECK (
    ride_category IN (
        'Budget (Uber Go/Bolt Go)',
        'Standard (UberX/Bolt)',
        'Comfort (Uber Comfort)',
        'Large Capacity (UberXL/Bolt XL)'
    )
);

ALTER TABLE TRIP_HEADERS
ADD CONSTRAINT chk_trip_status
CHECK (
    trip_status IN (
        'COMPLETED',
        'CANCELLED_BY_RIDER',
        'CANCELLED_BY_DRIVER'
    )
);

ALTER TABLE TRIP_HEADERS
ADD CONSTRAINT chk_cancellation
CHECK (
    (trip_status = 'COMPLETED'
        AND cancellation_reason IS NULL)
    OR
    (trip_status IN (
        'CANCELLED_BY_RIDER',
        'CANCELLED_BY_DRIVER'
    )
        AND cancellation_reason IN (
            'DRIVER_TOO_FAR',
            'TRAFFIC_DELAY',
            'CHANGED_MIND',
            'SAFETY_CONCERN',
            'PRICING_SURGE',
            'RIDER_NO_SHOW'
        )
    )
);


-- =========================================
-- TRIP_FARE_BREAKDOWN CHECK CONSTRAINTS
-- =========================================

ALTER TABLE TRIP_FARE_BREAKDOWN
ADD CONSTRAINT chk_distance
CHECK (distance_km >= 0);

ALTER TABLE TRIP_FARE_BREAKDOWN
ADD CONSTRAINT chk_duration
CHECK (duration_minutes >= 0);

ALTER TABLE TRIP_FARE_BREAKDOWN
ADD CONSTRAINT chk_surge
CHECK (surge_multiplier >= 1);

ALTER TABLE TRIP_FARE_BREAKDOWN
ADD CONSTRAINT chk_base_fare
CHECK (base_fare_zar >= 0);

ALTER TABLE TRIP_FARE_BREAKDOWN
ADD CONSTRAINT chk_tolls
CHECK (tolls_zar >= 0);

ALTER TABLE TRIP_FARE_BREAKDOWN
ADD CONSTRAINT chk_tip
CHECK (tip_zar >= 0);

ALTER TABLE TRIP_FARE_BREAKDOWN
ADD CONSTRAINT chk_total_fare
CHECK (total_fare_zar >= 0);

ALTER TABLE TRIP_FARE_BREAKDOWN
ADD CONSTRAINT chk_platform_comm
CHECK (platform_commission_zar >= 0);

ALTER TABLE TRIP_FARE_BREAKDOWN
ADD CONSTRAINT chk_driver_payout
CHECK (driver_payout_zar >= 0);

ALTER TABLE TRIP_FARE_BREAKDOWN
ADD CONSTRAINT chk_payment_method
CHECK (
    payment_method IN (
        'CREDIT_CARD',
        'DEBIT_CARD',
        'IN_APP_WALLET',
        'CASH',
        'EFT_OZOW'
    )
);


-- =========================================
-- TRIP_REVIEWS CHECK CONSTRAINTS
-- =========================================

ALTER TABLE TRIP_REVIEWS
ADD CONSTRAINT chk_rider_rating
CHECK (rider_rating_of_driver BETWEEN 1 AND 5);

ALTER TABLE TRIP_REVIEWS
ADD CONSTRAINT chk_driver_review_rating
CHECK (driver_rating_of_rider BETWEEN 1 AND 5);