USE nyc_taxi_discovery;

-- Check for duplicates in the taxi zone data
SELECT
    location_id,
    COUNT(1) AS number_of_records
FROM
    OPENROWSET(
        BULK 'abfss://nyc-taxi-data@synapsedatalakes.dfs.core.windows.net/raw/taxi_zone.csv',
        FORMAT = 'CSV',
        PARSER_VERSION = '2.0',
        FIRST_ROW = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '\n'
    ) WITH (
        location_id SMALLINT 1,
        borough VARCHAR(15) 2,
        zone VARCHAR(50) 3,
        service_zone VARCHAR(15)
    ) AS [result]
GROUP BY location_id
HAVING COUNT(1) > 1;

SELECT
    borough,
    COUNT(1) AS number_of_records
FROM
    OPENROWSET(
        BULK 'abfss://nyc-taxi-data@synapsedatalakes.dfs.core.windows.net/raw/taxi_zone.csv',
        FORMAT = 'CSV',
        PARSER_VERSION = '2.0',
        FIRST_ROW = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '\n'
    ) WITH (
        location_id SMALLINT 1,
        borough VARCHAR(15) 2,
        zone VARCHAR(50) 3,
        service_zone VARCHAR(15)
    ) AS [result]
GROUP BY borough
HAVING COUNT(1) > 1;