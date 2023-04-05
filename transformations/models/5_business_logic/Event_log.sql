with Event_log_base as (
    select * from {{ ref('Event_log_base') }}
),

/* The macros optional() and custom_fields() allow for missing columns in your tables.
If the field is not present, the macro creates the field with null values. Otherwise, it selects the field from the referenced table. */
Event_log_preprocessing as (
    select
        -- Mandatory
        Event_log_base."Event_ID",
        Event_log_base."Case_ID",
        Event_log_base."Activity",
        Event_log_base."Event_end",
        -- Optional
        {{ pm_utils.optional(ref('Event_log_base'), '"Activity_order"', 'integer') }},
        {{ pm_utils.optional(ref('Event_log_base'), '"Automated"', 'boolean') }},
        {{ pm_utils.optional(ref('Event_log_base'), '"Event_cost"', 'double') }},
        {{ pm_utils.optional(ref('Event_log_base'), '"Event_detail"') }},
        {{ pm_utils.optional(ref('Event_log_base'), '"Event_processing_time"', 'integer') }},
        {{ pm_utils.optional(ref('Event_log_base'), '"Event_start"', 'datetime') }},
        {{ pm_utils.optional(ref('Event_log_base'), '"Team"') }},
        {{ pm_utils.optional(ref('Event_log_base'), '"User"') }},
        -- Custom
        {{ custom_fields(ref('Event_log_base'), 'event') }}
    from Event_log_base
),

Event_log_with_event_order as (
    select
        Event_log_preprocessing."Event_ID",
        Event_log_preprocessing."Case_ID",
        Event_log_preprocessing."Event_end",
        row_number() over (order by 
            Event_log_preprocessing."Case_ID",
            Event_log_preprocessing."Event_end",
            Event_log_preprocessing."Event_start",
            Event_log_preprocessing."Activity_order",
            Event_log_preprocessing."Activity") as "Event_order"
    from Event_log_preprocessing
),

Event_log_with_previous_event_end as (
    select
        Event_log_with_event_order."Event_ID",
        lag(Event_log_with_event_order."Event_end") over (partition by
            Event_log_with_event_order."Case_ID" order by
            Event_log_with_event_order."Event_order") as "Previous_event_end"
    from Event_log_with_event_order
),

First_events_of_activity as (
    select
        min(Event_log_base."Event_ID") as "Event_ID"
    from Event_log_base
    group by Event_log_base."Case_ID", Event_log_base."Activity"
),

Event_log as (
    select
        -- Mandatory
        Event_log_preprocessing."Event_ID",
        Event_log_preprocessing."Case_ID",
        Event_log_preprocessing."Activity",
        Event_log_preprocessing."Event_end",
        -- Optional
        Event_log_preprocessing."Automated",
        Event_log_preprocessing."Event_cost",
        Event_log_preprocessing."Event_detail",
        Event_log_preprocessing."Event_processing_time",
        Event_log_preprocessing."Event_start",
        case
            when Event_log_preprocessing."Automated" = {{ pm_utils.to_boolean('false') }}
            then Event_log_preprocessing."Event_cost"
        end as "Manual_event_cost",
        case
            when Event_log_preprocessing."Automated" = {{ pm_utils.to_boolean('false') }}
            then Event_log_preprocessing."Event_processing_time"
        end as "Manual_event_processing_time",
        case
            when Event_log_preprocessing."Automated" = {{ pm_utils.to_boolean('false') }}
            then Event_log_preprocessing."Event_ID"
        end as "Manual_event_ID",
        Event_log_preprocessing."Team",
        Event_log_preprocessing."User",
        -- Field indicating the execution order of events
        Event_log_with_event_order."Event_order",
        -- Fields for metrics
        1 as "Event_recordcount",
        case
            when Event_log_with_previous_event_end."Previous_event_end" is NULL
            then 0
            else {{ pm_utils.datediff('millisecond', 'Event_log_with_previous_event_end."Previous_event_end"', 'Event_log_preprocessing."Event_end"') }}
        end as "Event_throughput_time",
        -- Field for optimization hints
        case
            when First_events_of_activity."Event_ID" is not null
            then 1
            else null
        end as "Unique_case_graph",
        -- Custom
        {{ custom_fields(ref('Event_log_base'), 'event') }}
    from Event_log_preprocessing
    left join Event_log_with_event_order
        on Event_log_preprocessing."Event_ID" = Event_log_with_event_order."Event_ID"
    left join Event_log_with_previous_event_end
        on Event_log_preprocessing."Event_ID" = Event_log_with_previous_event_end."Event_ID"
    left join First_events_of_activity
        on Event_log_preprocessing."Event_ID" = First_events_of_activity."Event_ID"
)

select * from Event_log
