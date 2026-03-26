-- Clean and standardize nyc open restaurant apps data
-- One row per restaurant seating application

WITH source AS (
   SELECT * FROM {{ source('raw', 'source_nyc_open_restaurant_apps') }}
), -- Easier to refer to the dbt reference to a long name table this way

cleaned AS (
   SELECT
       -- Get all columns from source, except ones we're transforming below
       -- To do cleaning on them or explicitly cast them as types just in case
       * EXCEPT (
           objectid,
           time_of_submission,
           sidewalk_dimensions_length,
           sidewalk_dimensions_width,
           sidewalk_dimensions_area,
           roadway_dimensions_length,
           roadway_dimensions_width,
           roadway_dimensions_area,
           zip,
           borough,
           latitude,
           longitude
       ),

       -- Identifiers
       CAST(objectid AS STRING) AS app_id,

       -- Date/Time
       CAST(time_of_submission AS TIMESTAMP) AS time_of_submission,

       -- Application numerical dimensions
       CAST(sidewalk_dimensions_length AS INTEGER) AS sidewalk_dimensions_length,
       CAST(sidewalk_dimensions_width AS INTEGER) AS side_walk_dimensions_width,
       CAST(sidewalk_dimensions_area AS INTEGER) AS sidewalk_dimensions_area,
       CAST(roadway_dimensions_length AS INTEGER) AS roadway_dimensions_length,
       CAST(roadway_dimensions_width AS INTEGER) AS roadway_dimensions_width,
       CAST(roadway_dimensions_area AS INTEGER) AS roadway_dimensions_area,

       -- Location - clean zip code, handling several common zip code data problems
       CASE
           WHEN UPPER(TRIM(CAST(zip AS STRING))) IN ('N/A', 'NA') THEN NULL
           WHEN UPPER(TRIM(CAST(zip AS STRING))) = 'ANONYMOUS' THEN 'Anonymous'
           WHEN LENGTH(CAST(zip AS STRING)) = 5 THEN CAST(zip AS STRING)
           WHEN LENGTH(CAST(zip AS STRING)) = 9 THEN CAST(zip AS STRING)
           WHEN LENGTH(CAST(zip AS STRING)) = 10
               AND REGEXP_CONTAINS(CAST(zip AS STRING), r'^\d{5}-\d{4}')
           THEN CAST(zip AS STRING)
           ELSE NULL
       END AS zip,

       -- Location - standardized borough, just in case
       CASE
           WHEN UPPER(TRIM(borough)) IN ('MANHATTAN', 'NEW YORK COUNTY') THEN 'Manhattan'
           WHEN UPPER(TRIM(borough)) IN ('BRONX', 'THE BRONX') THEN 'Bronx'
           WHEN UPPER(TRIM(borough)) IN ('BROOKLYN', 'KINGS COUNTY') THEN 'Brooklyn'
           WHEN UPPER(TRIM(borough)) IN ('QUEENS', 'QUEEN', 'QUEENS COUNTY') THEN 'Queens'
           WHEN UPPER(TRIM(borough)) IN ('STATEN ISLAND', 'RICHMOND COUNTY') THEN 'Staten Island'
           ELSE 'UNKNOWN or CITYWIDE'
       END AS borough,

       CAST(latitude AS DECIMAL) AS latitude,
       CAST(longitude AS DECIMAL) AS longitude,

       -- Clearer column name as well for this one
       CAST(food_service_establishment AS STRING) AS food_service_establishment_permit_num,

       -- Metadata
       CURRENT_TIMESTAMP() AS _stg_loaded_at

   FROM source

   -- Filters
   WHERE objectid IS NOT NULL
   AND time_of_submission IS NOT NULL
   AND borough IS NOT NULL

   -- Deduplicate
   QUALIFY ROW_NUMBER() OVER (PARTITION BY objectid ORDER BY time_of_submission DESC) = 1
)

SELECT * FROM cleaned
-- All should be part of this table: stg_nyc_open_restaurant_apps
