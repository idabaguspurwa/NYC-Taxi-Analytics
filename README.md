# NYC Taxi Analytics Project

A comprehensive data analytics solution for NYC taxi trip data using Azure Synapse Analytics, implementing a complete data lake architecture with bronze, silver, and gold layers.

## Project Overview

This project demonstrates end-to-end data processing and analytics on NYC taxi trip data using modern cloud-based data engineering practices. The solution processes various data formats (CSV, Parquet, JSON, Delta) and implements a medallion architecture for data quality and organization.

## Author

**Ida Bagus Gede Purwa Manik Adiputra**

## Architecture

### Data Lake Structure
```
nyc-taxi-data/
├── raw/           # Bronze layer - raw data ingestion
├── silver/        # Silver layer - cleaned and validated data
├── gold/          # Gold layer - business-ready aggregated data
└── rejections/    # Data quality rejection handling
```

### Technology Stack
- **Azure Synapse Analytics** - Data platform and orchestration
- **Serverless SQL Pool** - Query processing and data exploration
- **Apache Spark** - Data transformation and aggregation
- **Azure Data Lake Storage** - Scalable data storage
- **Azure Data Factory Pipelines** - ETL orchestration

## Data Sources

The project processes multiple NYC taxi-related datasets:

- **Trip Data**: Green taxi trip records (CSV, Parquet, Delta formats)
- **Reference Data**: 
  - Taxi zones and boroughs
  - Payment types
  - Rate codes
  - Vendor information
  - Trip types
  - Calendar dimensions

## Key Features

### 1. Multi-Format Data Processing
- CSV files with header row handling
- Parquet files for optimized analytics
- JSON files for reference data
- Delta Lake format support

### 2. Data Quality Management
- Rejection handling for malformed data
- Data type validation and conversion
- Duplicate detection and handling

### 3. Medallion Architecture Implementation

#### Bronze Layer (Code/nyc_taxi/ldw/create_bronze_table.sql)
- Raw data ingestion from various sources
- External tables for structured access
- Minimal transformation applied

#### Silver Layer (Code/nyc_taxi/ldw/create_silver_*.sql)
- Data cleansing and standardization
- Column renaming and type casting
- Partitioned by year and month for performance

#### Gold Layer (Code/nyc_taxi/ldw/create_gold_*.sql)
- Business-ready aggregated datasets
- Trip analytics by borough, date, payment type
- Performance metrics and KPIs

### 4. Automated Pipeline Processing

The project includes comprehensive data pipelines:

- **Silver Data Creation**: `pl_create_silver_trip_data_green`
- **Gold Data Aggregation**: `pl_create_gold_trip_data_green`
- **Master Pipeline**: `pl_execute_all_pipelines`

## Data Exploration and Analysis

### Discovery Queries
The [`Code/nyc_taxi/discovery`](Code/nyc_taxi/discovery) folder contains exploratory analysis:

- **Trip data exploration**: Analysis of green taxi trips across different formats
- **Payment type analysis**: Understanding payment patterns
- **Geographic analysis**: Borough-wise trip distribution
- **Data quality checks**: Identifying and handling data anomalies

### Sample Analytics

#### Trip Volume by Borough
```sql
SELECT 
    tz.borough,
    COUNT(1) AS total_trips,
    AVG(td.trip_distance) AS avg_distance,
    AVG(td.fare_amount) AS avg_fare
FROM silver.vw_trip_data_green td
JOIN silver.taxi_zone tz ON td.pu_location_id = tz.location_id
GROUP BY tz.borough
```

#### Payment Method Analysis
```sql
SELECT 
    pt.description,
    COUNT(1) AS trip_count,
    ROUND(COUNT(1) * 100.0 / SUM(COUNT(1)) OVER(), 2) AS percentage
FROM silver.vw_trip_data_green td
JOIN silver.payment_type pt ON td.payment_type = pt.payment_type
GROUP BY pt.description
```

## Stored Procedures

### Data Processing Automation
- [`usp_silver_trip_data_green`](Code/nyc_taxi/ldw/usp/usp_silver_trip_data_green.sql) - Silver layer data creation
- [`usp_gold_trip_data_green`](Code/nyc_taxi/ldw/usp/usp_gold_trip_data_green.sql) - Gold layer aggregations
- [`usp_silver_payment_type`](Code/nyc_taxi/ldw/usp/usp_create_silver_payment_type.sql) - Reference data processing

## Configuration

### External Data Sources
```sql
CREATE EXTERNAL DATA SOURCE nyc_taxi_src
WITH (
    LOCATION = 'https://synapsedatalakes.dfs.core.windows.net/nyc-taxi-data'
);
```

### File Formats
- **CSV**: Parser version 2.0 with header row support
- **Parquet**: Snappy compression for optimal performance
- **Delta**: Version control and ACID transactions

## Getting Started

1. **Setup Azure Synapse Workspace**
   - Configure linked services (`linkedService/`)
   - Set up integration runtime (`integrationRuntime/`)

2. **Create External Resources**
   ```sql
   -- Run setup scripts
   USE nyc_taxi_ldw;
   EXEC [Code/nyc_taxi/ldw/create_external_data_sources.sql]
   EXEC [Code/nyc_taxi/ldw/create_external_file_formats.sql]
   ```

3. **Deploy Pipelines**
   - Import pipeline definitions from [`Pipelines`](Pipelines)
   - Configure pipeline parameters for your environment

4. **Run Data Processing**
   ```sql
   -- Process silver layer
   EXEC silver.usp_silver_trip_data_green '2020', '01'
   
   -- Create gold aggregations
   EXEC gold.usp_gold_trip_data_green '2020', '01'
   ```

## Performance Optimizations

- **Partitioning**: Data partitioned by year/month for query performance
- **File Formats**: Parquet and Delta for columnar storage benefits
- **Batch Processing**: Pipeline batch processing with configurable parallelism
- **Resource Management**: Serverless scaling for cost optimization

## Monitoring and Troubleshooting

- **Data Quality**: Rejection files stored in [`nyc-taxi-data/rejections`](nyc-taxi-data/rejections)
- **Pipeline Monitoring**: Azure Synapse pipeline monitoring and alerting
- **Query Performance**: Use of `EXPLAIN` and execution plans for optimization

## Reports and Visualization

The [`Reports`](Reports) folder contains business intelligence dashboards and analytical reports built on the gold layer data.

## Contributing

1. Follow the established naming conventions for database objects
2. Document all stored procedures and complex queries
3. Test data quality with sample datasets before production deployment
4. Update pipeline configurations for new data sources

## License

This project is for educational and demonstration purposes, showcasing modern data engineering practices with Azure Synapse Analytics.