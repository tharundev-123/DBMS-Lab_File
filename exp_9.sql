-- EXPERIMENT 9
-- Railway Booking Database
-- Single-column and Composite Index Benchmarking

-- Step 1: Create database and table

CREATE DATABASE RailwayDB;
USE RailwayDB;

CREATE TABLE Railway_Booking (
    booking_id INT PRIMARY KEY,
    passenger_name VARCHAR(50) NOT NULL,
    train_no INT NOT NULL,
    source_station VARCHAR(30) NOT NULL,
    destination_station VARCHAR(30) NOT NULL,
    journey_date DATE NOT NULL,
    travel_class VARCHAR(5),
    seat_no INT,
    fare DECIMAL(8,2),
    booking_status VARCHAR(15)
);

-- Step 2: Insert 6000 records

SET SESSION cte_max_recursion_depth = 10000;

INSERT INTO Railway_Booking
(booking_id, passenger_name, train_no, source_station,
 destination_station, journey_date, travel_class,
 seat_no, fare, booking_status)

WITH RECURSIVE seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM seq WHERE n < 6000
)

SELECT
    n,
    CONCAT('Passenger_', n),
    12000 + MOD(n * 7, 50),
    ELT(MOD(n, 10) + 1,
        'Delhi','Mumbai','Kolkata','Chennai','Lucknow',
        'Kanpur','Jaipur','Bhopal','Patna','Ahmedabad'),
    ELT(MOD(n * 3 + 1, 10) + 1,
        'Delhi','Mumbai','Kolkata','Chennai','Lucknow',
        'Kanpur','Jaipur','Bhopal','Patna','Ahmedabad'),
    DATE_ADD('2026-01-01', INTERVAL MOD(n, 365) DAY),
    ELT(MOD(FLOOR(n / 7), 5) + 1, 'SL','3A','2A','1A','CC'),
    1 + MOD(n * 11, 72),
    300 + MOD(n * 37, 2700),
    ELT(MOD(FLOOR(n / 3), 3) + 1, 'Confirmed','Waiting','Cancelled')
FROM seq;

-- Step 3: Verify data

-- Total records
SELECT COUNT(*) AS total_records
FROM Railway_Booking;

-- Sample records
SELECT * FROM Railway_Booking
LIMIT 5;

-- Queries used for benchmarking

-- Query 1: Search by train number
SELECT * FROM Railway_Booking
WHERE train_no = 12038;

-- Query 2: Search by train number and journey date
SELECT * FROM Railway_Booking
WHERE train_no = 12038
AND journey_date = '2026-05-20';

-- Query 3: Search by journey date only
SELECT * FROM Railway_Booking
WHERE journey_date = '2026-05-20';


-- STAGE 1: BEFORE CREATING INDEXES

-- 1.1 EXPLAIN Query 1
EXPLAIN
SELECT * FROM Railway_Booking
WHERE train_no = 12038;

-- 1.2 EXPLAIN ANALYZE Query 1
EXPLAIN ANALYZE
SELECT * FROM Railway_Booking
WHERE train_no = 12038;

-- 1.3 EXPLAIN Query 2
EXPLAIN
SELECT * FROM Railway_Booking
WHERE train_no = 12038
AND journey_date = '2026-05-20';

-- 1.4 EXPLAIN ANALYZE Query 2
EXPLAIN ANALYZE
SELECT * FROM Railway_Booking
WHERE train_no = 12038
AND journey_date = '2026-05-20';


-- STAGE 2: SINGLE-COLUMN INDEX

-- Create index on train_no
CREATE INDEX idx_train_no
ON Railway_Booking(train_no);

ANALYZE TABLE Railway_Booking;

SHOW INDEX FROM Railway_Booking;

-- 2.2 EXPLAIN Query 1
EXPLAIN
SELECT * FROM Railway_Booking
WHERE train_no = 12038;

-- 2.3 EXPLAIN ANALYZE Query 1
EXPLAIN ANALYZE
SELECT * FROM Railway_Booking
WHERE train_no = 12038;

-- 2.4 EXPLAIN Query 2
EXPLAIN
SELECT * FROM Railway_Booking
WHERE train_no = 12038
AND journey_date = '2026-05-20';

-- 2.5 EXPLAIN ANALYZE Query 2
EXPLAIN ANALYZE
SELECT * FROM Railway_Booking
WHERE train_no = 12038
AND journey_date = '2026-05-20';


-- STAGE 3: COMPOSITE INDEX

-- Create composite index on train_no and journey_date
CREATE INDEX idx_train_date
ON Railway_Booking(train_no, journey_date);

ANALYZE TABLE Railway_Booking;

SHOW INDEX FROM Railway_Booking;

-- 3.2 EXPLAIN Query 2
EXPLAIN
SELECT * FROM Railway_Booking
WHERE train_no = 12038
AND journey_date = '2026-05-20';

-- 3.3 EXPLAIN ANALYZE Query 2
EXPLAIN ANALYZE
SELECT * FROM Railway_Booking
WHERE train_no = 12038
AND journey_date = '2026-05-20';

-- 3.4 EXPLAIN Query 3 (Leftmost-prefix rule)
EXPLAIN
SELECT * FROM Railway_Booking
WHERE journey_date = '2026-05-20';

-- 3.5 EXPLAIN ANALYZE Query 3
EXPLAIN ANALYZE
SELECT * FROM Railway_Booking
WHERE journey_date = '2026-05-20';
