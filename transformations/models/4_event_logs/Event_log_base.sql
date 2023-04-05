with Event_log_input as (
    select * from {{ ref('Event_log_input') }}
),

Activity_configuration_input as (
    select * from {{ ref('Activity_configuration_input') }}
),

Automation_estimates_input as (
    select * from {{ ref('Automation_estimates_input') }}
),

Event_log_base as (
    select
        -- Mandatory
        row_number() over (order by Event_log_input."event_end") as "Event_ID",
        Event_log_input."case_id" as "Case_ID",
        Event_log_input."activity" as "Activity",
        Event_log_input."event_end" as "Event_end",
        -- Optional
        Activity_configuration_input."Activity_order",
        Event_log_input."automated" as "Automated",
        Automation_estimates_input."Event_cost",
        Event_log_input."event_detail" as "Event_detail",
        Automation_estimates_input."Event_processing_time",
        Event_log_input."event_start" as "Event_start",
        Event_log_input."team" as "Team",
        Event_log_input."user" as "User",
        -- Custom
        {{ custom_fields(ref('Event_log_input'), 'event') }}
    from Event_log_input
    left join Activity_configuration_input
        on Event_log_input."activity" = Activity_configuration_input."Activity"
    left join Automation_estimates_input
        on Event_log_input."activity" = Automation_estimates_input."Activity"
)

select * from Event_log_base
