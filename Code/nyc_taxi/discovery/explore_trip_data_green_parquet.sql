USE nyc_taxi_discovery

SELECT
    TOP 100 *
FROM
    OPENROWSET(
        BULK 'trip_data_green_parquet/year=2020/month=01/',
        FORMAT = 'PARQUET',
        DATA_SOURCE = 'nyc_taxi_data_raw'
    ) AS [result]

-- Identify the inferred data types
EXEC sp_describe_first_result_set N'
SELECT
    TOP 100 *
FROM
    OPENROWSET(
        BULK ''trip_data_green_parquet/year=2020/month=01/'',
        FORMAT = ''PARQUET'',
        DATA_SOURCE = ''nyc_taxi_data_raw''
    ) AS [result]'

-- Define columns and data type
SELECT
    TOP 100 *
FROM
    OPENROWSET(
        BULK 'trip_data_green_parquet/year=2020/month=01/',
        FORMAT = 'PARQUET',
        DATA_SOURCE = 'nyc_taxi_data_raw'
    ) WITH(
        VendorID INT,
        lpep_pickup_datetime DATETIME2(7),
        lpep_dropoff_datetime DATETIME2(7),
        store_and_fwd_flag CHAR(1),
        RatecodeID INT,
        PULocationID INT,
        DOLocationID INT,
        passenger_count INT,
        trip_distance FLOAT,
        fare_amount FLOAT,
        extra FLOAT,
        mta_tax FLOAT,
        tip_amount FLOAT,
        tolls_amount FLOAT,
        ehail_fee INT,
        improvement_surcharge FLOAT,
        total_amount FLOAT,
        payment_type INT,
        trip_type INT,
        congestion_surcharge FLOAT
    ) AS [result]

SELECT
    TOP 100 *
FROM
    OPENROWSET(
        BULK 'trip_data_green_parquet/year=2020/month=01/',
        FORMAT = 'PARQUET',
        DATA_SOURCE = 'nyc_taxi_data_raw'
    ) WITH(
        tip_amount FLOAT,
        trip_type INT
    ) AS [result]

-- 1. Query using wildcard characters
SELECT
    TOP 100 *
FROM
    OPENROWSET(
        BULK 'trip_data_green_parquet/year=2020/month=01/*.parquet',
        FORMAT = 'PARQUET',
        DATA_SOURCE = 'nyc_taxi_data_raw'
    ) AS trip_data

-- 2. Get filename
SELECT
    TOP 100
    trip_data.filename() AS file_name,
    trip_data.*
FROM
    OPENROWSET(
        BULK 'trip_data_green_parquet/year=2020/month=01/*.parquet',
        FORMAT = 'PARQUET',
        DATA_SOURCE = 'nyc_taxi_data_raw'
    ) AS trip_data

-- 3. Query from subfolders
SELECT
    TOP 100
    trip_data.filepath() AS file_path,
    trip_data.*
FROM
    OPENROWSET(
        BULK 'trip_data_green_parquet/**',
        FORMAT = 'PARQUET',
        DATA_SOURCE = 'nyc_taxi_data_raw'
    ) AS trip_data

-- 4. Use filepath to target partitions
SELECT
    trip_data.filepath(1) AS year,
    trip_data.filepath(2) AS month,
    COUNT(1) AS record_count
FROM
    OPENROWSET(
        BULK 'trip_data_green_parquet/year=*/month=*/*.parquet',
        FORMAT = 'PARQUET',
        DATA_SOURCE = 'nyc_taxi_data_raw'
    ) AS trip_data
    WHERE trip_data.filepath(1) = '2020'
    AND trip_data.filepath(2) IN ('06', '07', '08')
GROUP BY trip_data.filepath(1), trip_data.filepath(2)
ORDER BY trip_data.filepath(1), trip_data.filepath(2);
