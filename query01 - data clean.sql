WITH DATA_MERGE AS (
  SELECT
    CONCAT( YEAR, '-', RIGHT( CONCAT('00', MONTH), 2), '-', RIGHT( CONCAT('00', DAY), 2) ) AS EVENT_DATE,
    *
  FROM
    `data.flights1`
  UNION ALL
  SELECT
    CONCAT( YEAR, '-', RIGHT( CONCAT('00', MONTH), 2), '-', RIGHT( CONCAT('00', DAY), 2) ) AS EVENT_DATE,
    *
  FROM
    `data.flights2`
  UNION ALL
  SELECT
    CONCAT( YEAR, '-', RIGHT( CONCAT('00', MONTH), 2), '-', RIGHT( CONCAT('00', DAY), 2) ) AS EVENT_DATE,
    *
  FROM
    `data.flights3`
  UNION ALL
  SELECT
    CONCAT( YEAR, '-', RIGHT( CONCAT('00', MONTH), 2), '-', RIGHT( CONCAT('00', DAY), 2) ) AS EVENT_DATE,
    *
  FROM
    `data.flights4`
  UNION ALL
  SELECT
    CONCAT( YEAR, '-', RIGHT( CONCAT('00', MONTH), 2), '-', RIGHT( CONCAT('00', DAY), 2) ) AS EVENT_DATE,
    *
  FROM
    `data.flights5`
  UNION ALL
  SELECT
    CONCAT( YEAR, '-', RIGHT( CONCAT('00', MONTH), 2), '-', RIGHT( CONCAT('00', DAY), 2) ) AS EVENT_DATE,
    *
  FROM
    `data.flights6` ),
  DATA_STEP1 AS (
  SELECT
    CAST( EVENT_DATE AS DATE) AS EVENT_DATE,
    DAY_OF_WEEK,
    AIRLINE,
    FLIGHT_NUMBER,
    TAIL_NUMBER,
    ORIGIN_AIRPORT,
    DESTINATION_AIRPORT,
    CAST( RIGHT( CONCAT('000', SCHEDULED_DEPARTURE), 4) AS STRING) AS SCHEDULED_DEPARTURE,
    CAST( RIGHT( CONCAT('000', DEPARTURE_TIME), 4) AS STRING) AS DEPARTURE_TIME,
    CAST( DEPARTURE_DELAY AS INT64) AS DEPARTURE_DELAY,
    CAST( TAXI_OUT AS INT64) AS TAXI_OUT,
    CAST( RIGHT( CONCAT('000', WHEELS_OFF), 4) AS STRING) AS WHEELS_OFF,
    CAST( SCHEDULED_TIME AS INT64) AS SCHEDULED_TIME,
    CAST( ELAPSED_TIME AS INT64) AS ELAPSED_TIME,
    CAST( AIR_TIME AS INT64) AS AIR_TIME,
    DISTANCE,
    CAST( RIGHT( CONCAT('000', WHEELS_ON), 4) AS STRING) AS WHEELS_ON,
    CAST( TAXI_IN AS INT64) AS TAXI_IN,
    CAST( RIGHT( CONCAT('000', SCHEDULED_ARRIVAL), 4) AS STRING) AS SCHEDULED_ARRIVAL,
    CAST( RIGHT( CONCAT('000', ARRIVAL_TIME), 4) AS STRING) AS ARRIVAL_TIME,
    CAST( ARRIVAL_DELAY AS INT64) AS ARRIVAL_DELAY,
    DIVERTED,
    CANCELLED,
    CANCELLATION_REASON,
    CAST( AIR_SYSTEM_DELAY AS INT64) AS AIR_SYSTEM_DELAY,
    CAST( SECURITY_DELAY AS INT64) AS SECURITY_DELAY,
    CAST( AIRLINE_DELAY AS INT64) AS AIRLINE_DELAY,
    CAST( LATE_AIRCRAFT_DELAY AS INT64) AS LATE_AIRCRAFT_DELAY,
    CAST( WEATHER_DELAY AS INT64) AS WEATHER_DELAY
  FROM
    DATA_MERGE ),
  DATA_STEP2 AS (
  SELECT
    EVENT_DATE,
    DAY_OF_WEEK,
    AIRLINE,
    FLIGHT_NUMBER,
    TAIL_NUMBER,
    ORIGIN_AIRPORT,
    DESTINATION_AIRPORT,
    CONCAT(
    IF
      ( LEFT(SCHEDULED_DEPARTURE, 2) = '24', '00', LEFT(SCHEDULED_DEPARTURE, 2) ), ':', RIGHT(SCHEDULED_DEPARTURE, 2) ) AS SCHEDULED_DEPARTURE_HM,
    CONCAT(
    IF
      ( LEFT(DEPARTURE_TIME, 2) = '24', '00', LEFT(DEPARTURE_TIME, 2) ), ':', RIGHT(DEPARTURE_TIME, 2) ) AS DEPARTURE_TIME_HM,
    DEPARTURE_DELAY,
    TAXI_OUT,
    CONCAT(
    IF
      ( LEFT(WHEELS_OFF, 2) = '24', '00', LEFT(WHEELS_OFF, 2) ), ':', RIGHT(WHEELS_OFF, 2) ) AS WHEELS_OFF_HM,
    SCHEDULED_TIME,
    ELAPSED_TIME,
    AIR_TIME,
    DISTANCE,
    CONCAT(
    IF
      ( LEFT(WHEELS_ON, 2) = '24', '00', LEFT(WHEELS_ON, 2) ), ':', RIGHT(WHEELS_ON, 2) ) AS WHEELS_ON_HM,
    TAXI_IN,
    CONCAT(
    IF
      ( LEFT(SCHEDULED_ARRIVAL, 2) = '24', '00', LEFT(SCHEDULED_ARRIVAL, 2) ), ':', RIGHT(SCHEDULED_ARRIVAL, 2) ) AS SCHEDULED_ARRIVAL_HM,
    CONCAT(
    IF
      ( LEFT(ARRIVAL_TIME, 2) = '24', '00', LEFT(ARRIVAL_TIME, 2) ), ':', RIGHT(ARRIVAL_TIME, 2) ) AS ARRIVAL_TIME_HM,
    ARRIVAL_DELAY,
    DIVERTED,
    CANCELLED,
    CANCELLATION_REASON,
    AIR_SYSTEM_DELAY,
    SECURITY_DELAY,
    AIRLINE_DELAY,
    LATE_AIRCRAFT_DELAY,
    WEATHER_DELAY
  FROM
    DATA_STEP1 )
SELECT
  EVENT_DATE,
  DAY_OF_WEEK,
  AIRLINE,
  FLIGHT_NUMBER,
  TAIL_NUMBER,
  ORIGIN_AIRPORT,
  DESTINATION_AIRPORT,
  CAST( CONCAT( EVENT_DATE, ' ', SCHEDULED_DEPARTURE_HM, ':00') AS DATETIME ) AS SCHEDULED_DEPARTURE,
  CAST( CONCAT(
      CASE
        WHEN CAST( LEFT(SCHEDULED_DEPARTURE_HM,2) AS INT64) < 2 AND CAST( LEFT(DEPARTURE_TIME_HM,2) AS INT64) >= 22 AND IFNULL(DEPARTURE_DELAY,0) <= 0 THEN DATE_SUB( EVENT_DATE, INTERVAL 1 DAY)
        WHEN CAST( LEFT(DEPARTURE_TIME_HM,2) AS INT64) < CAST( LEFT(SCHEDULED_DEPARTURE_HM,2) AS INT64)
      AND CAST( LEFT(SCHEDULED_DEPARTURE_HM,2) AS INT64) - CAST( LEFT(DEPARTURE_TIME_HM,2) AS INT64) >= 2
      AND IFNULL(DEPARTURE_DELAY,0) > 0 THEN DATE_ADD(EVENT_DATE, INTERVAL 1 DAY)
      ELSE
      EVENT_DATE
    END
      , ' ', DEPARTURE_TIME_HM, ':00') AS DATETIME ) AS DEPARTURE_TIME,
  DEPARTURE_DELAY,
  TAXI_OUT,
  CAST( CONCAT(
      CASE
        WHEN CAST( LEFT(SCHEDULED_DEPARTURE_HM,2) AS INT64) < 2 AND CAST( LEFT(WHEELS_OFF_HM,2) AS INT64) >= 22 AND IFNULL(DEPARTURE_DELAY,0) <= 0 THEN DATE_SUB( EVENT_DATE, INTERVAL 1 DAY)
        WHEN CAST( LEFT(WHEELS_OFF_HM,2) AS INT64) < CAST( LEFT(SCHEDULED_DEPARTURE_HM,2) AS INT64)
      AND CAST( LEFT(SCHEDULED_DEPARTURE_HM,2) AS INT64) - CAST( LEFT(WHEELS_OFF_HM,2) AS INT64) >= 2
      AND IFNULL(DEPARTURE_DELAY,0) > 0 THEN DATE_ADD(EVENT_DATE, INTERVAL 1 DAY)
      ELSE
      EVENT_DATE
    END
      , ' ', WHEELS_OFF_HM, ':00') AS DATETIME ) AS WHEELS_OFF,
  SCHEDULED_TIME,
  ELAPSED_TIME,
  AIR_TIME,
  DISTANCE,
  CAST( CONCAT(
      CASE
        WHEN CAST( LEFT(SCHEDULED_ARRIVAL_HM,2) AS INT64) < 2 AND CAST( LEFT(WHEELS_ON_HM,2) AS INT64) >= 22 AND IFNULL(ARRIVAL_DELAY,0) <= 0 THEN DATE_SUB( EVENT_DATE, INTERVAL 1 DAY)
        WHEN CAST( LEFT(WHEELS_ON_HM,2) AS INT64) < CAST( LEFT(SCHEDULED_ARRIVAL_HM,2) AS INT64)
      AND CAST( LEFT(SCHEDULED_ARRIVAL_HM,2) AS INT64) - CAST( LEFT(WHEELS_ON_HM,2) AS INT64) >= 2
      AND IFNULL(ARRIVAL_DELAY,0) > 0 THEN DATE_ADD(EVENT_DATE, INTERVAL 1 DAY)
      ELSE
      EVENT_DATE
    END
      , ' ', WHEELS_ON_HM, ':00') AS DATETIME ) AS WHEELS_ON,
  TAXI_IN,
  CAST( CONCAT(
      CASE
        WHEN CAST( LEFT(SCHEDULED_ARRIVAL_HM,2) AS INT64) < CAST( LEFT(SCHEDULED_DEPARTURE_HM,2) AS INT64) THEN DATE_ADD(EVENT_DATE, INTERVAL 1 DAY)
      ELSE
      EVENT_DATE
    END
      , ' ', SCHEDULED_ARRIVAL_HM, ':00') AS DATETIME ) AS SCHEDULED_ARRIVAL,
  CAST( CONCAT(
      CASE
        WHEN CAST( LEFT(SCHEDULED_ARRIVAL_HM,2) AS INT64) < 2 AND CAST( LEFT(ARRIVAL_TIME_HM,2) AS INT64) >= 22 AND IFNULL(ARRIVAL_DELAY,0) <= 0 THEN DATE_SUB( EVENT_DATE, INTERVAL 1 DAY)
        WHEN CAST( LEFT(ARRIVAL_TIME_HM,2) AS INT64) < CAST( LEFT(SCHEDULED_ARRIVAL_HM,2) AS INT64)
      AND CAST( LEFT(SCHEDULED_ARRIVAL_HM,2) AS INT64) - CAST( LEFT(ARRIVAL_TIME_HM,2) AS INT64) >= 2
      AND IFNULL(ARRIVAL_DELAY,0) > 0 THEN DATE_ADD(EVENT_DATE, INTERVAL 1 DAY)
      ELSE
      EVENT_DATE
    END
      , ' ', ARRIVAL_TIME_HM, ':00') AS DATETIME ) AS ARRIVAL_TIME,
  ARRIVAL_DELAY,
  DIVERTED,
  CANCELLED,
  CANCELLATION_REASON,
  AIR_SYSTEM_DELAY,
  SECURITY_DELAY,
  AIRLINE_DELAY,
  LATE_AIRCRAFT_DELAY,
  WEATHER_DELAY
FROM
  DATA_STEP2