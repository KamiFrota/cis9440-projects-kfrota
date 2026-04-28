WITH locations AS (

    SELECT DISTINCT
        borough,
        zip_code

    FROM {{ ref('stg_nyc_311_vehicle_complaints') }}

    WHERE borough IS NOT NULL
       OR zip_code IS NOT NULL

),

final AS (

    SELECT
        ROW_NUMBER() OVER (ORDER BY borough, zip_code) AS location_key,
        borough,
        zip_code

    FROM locations

)

SELECT * FROM final