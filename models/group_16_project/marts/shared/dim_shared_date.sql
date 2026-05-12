WITH dates AS (
   -- Get dates (dates, no time included) from 311 requests
   SELECT DISTINCT 
    CAST(created_date AS DATE) AS full_date,
    FORMAT_TIMESTAMP('%H', created_date) AS hour_of_day --Line updated
   FROM {{ ref('stg_nyc_311_vehicle_complaints') }}
   WHERE created_date IS NOT NULL

   UNION DISTINCT

    SELECT DISTINCT 
    CAST(crash_date AS DATE) AS full_date,
    FORMAT_TIME('%H', SAFE.PARSE_TIME('%H:%M', crash_time)) AS hour_of_day
    FROM {{ ref('stg_nyc_vehicle_crashes') }}
    WHERE crash_date IS NOT NULL
    AND crash_time IS NOT NULL --- NEW LINE ADDED TO TRY TO FIX THE HOUR PROBLEM
),    
final AS (

    SELECT
        {{ dbt_utils.generate_surrogate_key(['full_date', 'hour_of_day']) }} AS date_key, ---line updated

        full_date,
        EXTRACT(YEAR FROM full_date) AS year,
        EXTRACT(MONTH FROM full_date) AS month,
        EXTRACT(DAY FROM full_date) AS day,
        FORMAT_DATE('%A', full_date) AS day_of_week,
        FORMAT_DATE('%B', full_date) AS month_name,
        EXTRACT(DAYOFWEEK FROM full_date) IN (1, 7) AS is_weekend,
        hour_of_day,
          
    -- create logic for single schema field for AM/PM times
     CASE
       WHEN hour_of_day < "12:00" THEN "AM"
       ELSE "PM"
    END AS time_of_day
    

    FROM dates

)

SELECT * FROM final