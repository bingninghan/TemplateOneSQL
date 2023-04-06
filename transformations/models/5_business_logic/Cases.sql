with Cases_base as (
    select * from {{ ref('Cases_base') }}
),
Event_log_base as (
    select * from {{ ref('Event_log_base') }}
),
Tags as (
    select * from {{ ref('Tags') }}
),

-- Aggregate of the event log table to define case properties based on events data.
Cases_from_event_log as (
    select
        Event_log_base."Case_ID",
        min(Event_log_base."Event_end") as "Case_start",
        count(Event_log_base."Case_ID") as "Number_of_events",
        {{ datediff('millisecond', 'min(Event_log_base."Event_end")', 'max(Event_log_base."Event_end")') }} as "Throughput_time"
    from Event_log_base
    group by Event_log_base."Case_ID"
),

-- Aggregate of the tags table to define which cases have a tag.
Cases_with_tags as (
    select
        Tags."Case_ID"
    from Tags
    group by Tags."Case_ID"
),

-- Generate the variant attribute.
{{ pm_utils.generate_variant(
    table_name = 'Cases_with_variant',
    event_log_model = 'Event_log',
    case_ID = 'Case_ID',
    activity = 'Activity',
    event_order = 'Event_order')
}},

Cases as (
    select
        -- Mandatory
        Cases_base."Case_ID",
        -- Optional
        coalesce(Cases_base."Case", Cases_base."Case_ID") as "Case",
        Cases_base."Case_status",
        NULL as "Case_type",
        Cases_base."Case_value",
        case
            when Cases_base."Case_value" >= 1000000
            then '>= 1M'
            when Cases_base."Case_value" >= 100000
            then '100k - 1M'
            when Cases_base."Case_value" >= 10000
            then '10k - 100k'
            when Cases_base."Case_value" >= 1000
            then '1k - 10k'
            when Cases_base."Case_value" >= 500
            then '500 - 1k'
            when Cases_base."Case_value" >= 250
            then '250 - 500'
            when Cases_base."Case_value" >= 100
            then '100 - 250'
            when Cases_base."Case_value" is not NULL
            then '< 100'
        end as "Case_value_group",
        -- Properties based on event data
        Cases_from_event_log."Case_start",
        Cases_from_event_log."Number_of_events",
        Cases_from_event_log."Throughput_time",
        -- Property whether the case has a tag
        case
            when Cases_with_tags."Case_ID" is not NULL
            then {{ to_boolean('true') }}
            else {{ to_boolean('false') }}
        end as "Case_has_tag",
        -- Variant attribute
        Cases_with_variant."Variant"
    from Cases_base
    left join Cases_from_event_log
        on Cases_base."Case_ID" = Cases_from_event_log."Case_ID"
    left join Cases_with_tags
        on Cases_base."Case_ID" = Cases_with_tags."Case_ID"
    left join Cases_with_variant
        on Cases_base."Case_ID" = Cases_with_variant."Case_ID"
)

select * from Cases
