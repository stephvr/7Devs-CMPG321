

/*
   PRIMARY KEYS
*/

ALTER TABLE PROVINCES
ADD CONSTRAINT pk_provinces
PRIMARY KEY (province_id);

ALTER TABLE CITIES
ADD CONSTRAINT pk_cities
PRIMARY KEY (city_id);

ALTER TABLE PLATFORM_AFFILIATION
ADD CONSTRAINT pk_platform_affiliation
PRIMARY KEY (affiliation_id);

ALTER TABLE SA_DRIVERS
ADD CONSTRAINT pk_sa_drivers
PRIMARY KEY (driver_id);

ALTER TABLE SA_RIDERS
ADD CONSTRAINT pk_sa_riders
PRIMARY KEY (rider_id);

ALTER TABLE PRICING_SURGE_ZONES
ADD CONSTRAINT pk_pricing_surge_zones
PRIMARY KEY (zone_id);

ALTER TABLE VEHICLES
ADD CONSTRAINT pk_vehicles
PRIMARY KEY (vehicle_id);

ALTER TABLE TRIP_HEADERS
ADD CONSTRAINT pk_trip_headers
PRIMARY KEY (trip_id);

ALTER TABLE TRIP_FARE_BREAKDOWN
ADD CONSTRAINT pk_trip_fare_breakdown
PRIMARY KEY (trip_id);

ALTER TABLE TRIP_REVIEWS
ADD CONSTRAINT pk_trip_reviews
PRIMARY KEY (review_id);


/*
   FOREIGN KEYS
*/

ALTER TABLE CITIES
ADD CONSTRAINT fk_cities_province
FOREIGN KEY (province_id)
REFERENCES PROVINCES(province_id);

ALTER TABLE SA_DRIVERS
ADD CONSTRAINT fk_driver_affiliation
FOREIGN KEY (affiliation_id)
REFERENCES PLATFORM_AFFILIATION(affiliation_id);

ALTER TABLE SA_DRIVERS
ADD CONSTRAINT fk_driver_city
FOREIGN KEY (city_id)
REFERENCES CITIES(city_id);

ALTER TABLE SA_RIDERS
ADD CONSTRAINT fk_rider_city
FOREIGN KEY (city_id)
REFERENCES CITIES(city_id);

ALTER TABLE PRICING_SURGE_ZONES
ADD CONSTRAINT fk_zone_city
FOREIGN KEY (city_id)
REFERENCES CITIES(city_id);

ALTER TABLE VEHICLES
ADD CONSTRAINT fk_vehicle_driver
FOREIGN KEY (driver_id)
REFERENCES SA_DRIVERS(driver_id);

ALTER TABLE TRIP_HEADERS
ADD CONSTRAINT fk_trip_driver
FOREIGN KEY (driver_id)
REFERENCES SA_DRIVERS(driver_id);

ALTER TABLE TRIP_HEADERS
ADD CONSTRAINT fk_trip_rider
FOREIGN KEY (rider_id)
REFERENCES SA_RIDERS(rider_id);

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


/*
   UNIQUE CONSTRAINTS
*/

ALTER TABLE PROVINCES
ADD CONSTRAINT uq_province_name
UNIQUE (province_name);

ALTER TABLE CITIES
ADD CONSTRAINT uq_city_name
UNIQUE (city_name);

ALTER TABLE PLATFORM_AFFILIATION
ADD CONSTRAINT uq_affiliation_name
UNIQUE (affiliation_name);

ALTER TABLE VEHICLES
ADD CONSTRAINT uq_vehicle_driver
UNIQUE (driver_id);

ALTER TABLE VEHICLES
ADD CONSTRAINT uq_license_plate
UNIQUE (license_plate);

ALTER TABLE TRIP_REVIEWS
ADD CONSTRAINT uq_review_trip
UNIQUE (trip_id);


/*
   CHECK CONSTRAINTS
*/

ALTER TABLE PLATFORM_AFFILIATION
ADD CONSTRAINT chk_affiliation_commission
CHECK (
    (affiliation_name = 'Uber' AND commission_pct = 0.25)
    OR
    (affiliation_name = 'Bolt' AND commission_pct = 0.20)
    OR
    (affiliation_name = 'Dual-Platform (Both)' AND commission_pct = 0.22)
);

ALTER TABLE SA_DRIVERS
ADD CONSTRAINT chk_driver_rating
CHECK (driver_rating BETWEEN 1 AND 5);

ALTER TABLE SA_DRIVERS
ADD CONSTRAINT chk_lifetime_trips
CHECK (total_lifetime_trips >= 0);

ALTER TABLE PRICING_SURGE_ZONES
ADD CONSTRAINT chk_zone_base_fare
CHECK (base_fare_zar > 0);

ALTER TABLE PRICING_SURGE_ZONES
ADD CONSTRAINT chk_zone_per_km
CHECK (per_km_rate_zar > 0);

ALTER TABLE PRICING_SURGE_ZONES
ADD CONSTRAINT chk_zone_per_min
CHECK (per_min_rate_zar > 0);

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
ADD CONSTRAINT chk_cancellation_reason
CHECK (
    cancellation_reason IS NULL
    OR cancellation_reason IN (
        'CHANGED_MIND',
        'DRIVER_TOO_FAR',
        'PRICING_SURGE',
        'RIDER_NO_SHOW',
        'SAFETY_CONCERN',
        'TRAFFIC_DELAY'
    )
);

ALTER TABLE TRIP_HEADERS
ADD CONSTRAINT chk_status_cancellation
CHECK (
    (trip_status = 'COMPLETED' AND cancellation_reason IS NULL)
    OR
    (
        trip_status IN ('CANCELLED_BY_RIDER', 'CANCELLED_BY_DRIVER')
        AND cancellation_reason IS NOT NULL
    )
);

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
ADD CONSTRAINT chk_fare_base
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
ADD CONSTRAINT chk_platform_commission
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

ALTER TABLE SA_RIDERS
ADD CONSTRAINT chk_preferred_payment
CHECK (
    preferred_payment IN (
        'CREDIT_CARD',
        'DEBIT_CARD',
        'IN_APP_WALLET',
        'CASH',
        'EFT_OZOW'
    )
);

ALTER TABLE TRIP_REVIEWS
ADD CONSTRAINT chk_rider_rating_driver
CHECK (rider_rating_of_driver BETWEEN 1 AND 5);

ALTER TABLE TRIP_REVIEWS
ADD CONSTRAINT chk_driver_rating_rider
CHECK (driver_rating_of_rider BETWEEN 1 AND 5);