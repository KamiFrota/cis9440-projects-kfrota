WITH dates AS (

    SELECT
        date_day AS full_date
    FROM UNNEST(GENERATE_DATE_ARRAY('2015-01-01', '2030-12-31')) AS date_day

),

final AS (

    SELECT
        FORMAT_DATE('%Y%m%d', full_date) AS date_key,
        full_date,
        EXTRACT(YEAR FROM full_date) AS year,
        EXTRACT(MONTH FROM full_date) AS month,
        EXTRACT(DAY FROM full_date) AS day,
        FORMAT_DATE('%A', full_date) AS day_of_week,
        FORMAT_DATE('%B', full_date) AS month_name

    FROM dates

)

SELECT * FROM final