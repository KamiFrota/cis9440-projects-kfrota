{% macro clean_street_suffixes(column_name) %}
{# Define mapping of suffixes short vs long form #}
{%- set suffixes = [
('AVE', 'AVENUE'), ('ST', 'STREET'), ('RD', 'ROAD'), 
        ('BLVD', 'BOULEVARD'), ('DR', 'DRIVE'), ('PL', 'PLACE'), 
        ('LN', 'LANE'), ('PKWY', 'PARKWAY'), ('CT', 'COURT'),
        ('EXPY', 'EXPRESSWAY'), ('TER', 'TERRACE')
    ] -%}

    {# Start with the base column #}
    {%- set ns = namespace(str="UPPER(TRIM(" ~ column_name ~ "))") -%}

    {# Loop through and wrap the string in a new REGEXP_REPLACE for each suffix #}
    {%- for short, long in suffixes -%}
        {%- set ns.str = "REGEXP_REPLACE(" ~ ns.str ~ ", r'\\b" ~ short ~ "$', '" ~ long ~ "')" -%}
    {%- endfor -%}

    {{ ns.str }}
{% endmacro %}