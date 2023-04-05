with Cases_raw as (
    select * from {{ source(var("schema_sources"), 'Cases_raw') }}
),

/* Input table for the cases containing the case properties.
The macro optional() allows for missing columns in your source tables when they are optional.
If an optional attribute is not present, it creates the column with null values. Otherwise, it selects the column from the source data.
The source_table variable refers to the table where to check for the presence of optional attributes.
Convert the non-text fields to the correct data type. */
{% set source_table = source(var("schema_sources"), 'Cases_raw') %}

Cases_input as (
    select
        -- Mandatory
        Cases_raw."case_id",
        -- Optional
        {{ pm_utils.optional(source_table, '"case"') }},
        {{ pm_utils.optional(source_table, '"case_status"') }},
        {{ pm_utils.optional(source_table, '"case_type"') }},
        {{ pm_utils.optional(source_table, '"case_value"', 'double') }},
        -- Custom
        {{ custom_fields(source_table, 'case') }}
    from Cases_raw
)

select * from Cases_input
