with Event_log_raw as (
    select * from {{ source(var("schema_sources"), 'Event_log_raw') }}
),

/* Input table for the event log containing event properties.
The macro optional() allows for missing columns in your source tables when they are optional.
If an optional attribute is not present, it creates the column with null values. Otherwise, it selects the column from the source data.
The source_table variable refers to the table where to check for the presence of optional attributes.
Convert the non-text fields to the correct data type. */
{% set source_table = source(var("schema_sources"), 'Event_log_raw') %}

Event_log_input as (
    select
        -- Mandatory
        Event_log_raw."activity",
        Event_log_raw."case_id",
        {{ pm_utils.to_timestamp('Event_log_raw."event_end"') }} as "event_end",
        -- Optional
        {{ pm_utils.optional(source_table, '"automated"', 'boolean') }},
        {{ pm_utils.optional(source_table, '"event_detail"') }},
        {{ pm_utils.optional(source_table, '"event_start"', 'datetime') }},
        {{ pm_utils.optional(source_table, '"team"') }},
        {{ pm_utils.optional(source_table, '"user"') }},
        -- Custom
        {{ custom_fields(source_table, 'event') }}
    from Event_log_raw
)

select * from Event_log_input
