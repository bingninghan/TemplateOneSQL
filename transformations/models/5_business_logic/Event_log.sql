with Event_log_base as (
    select * from {{ ref('Event_log_base') }}
),

Event_log_with_event_order as (
    select
        Event_log_base."Event_ID",
        Event_log_base."Case_ID",
        Event_log_base."Event_end",
        row_number() over (order by 
            Event_log_base."Case_ID",
            Event_log_base."Event_end",
            Event_log_base."Activity") as "Event_order"
    from Event_log_base
),

Event_log_with_previous_event_end as (
    select
        Event_log_with_event_order."Event_ID",
        lag(Event_log_with_event_order."Event_end") over (partition by
            Event_log_with_event_order."Case_ID" order by
            Event_log_with_event_order."Event_order") as "Previous_event_end"
    from Event_log_with_event_order
),

Event_log as (
    select
        -- Mandatory
        Event_log_base."Event_ID",
        Event_log_base."Case_ID",
        Event_log_base."Activity",
        Event_log_base."Event_end",
        -- Optional
        NULL as "Automated",
        NULL as "Event_cost",
        Event_log_base."Event_detail",
        Event_log_with_event_order."Event_order",
        NULL as "Event_processing_time",
        NULL as "Event_start",
        case
            when Event_log_with_previous_event_end."Previous_event_end" is NULL
            then 0
            else  {{ datediff('millisecond', 'Event_log_with_previous_event_end."Previous_event_end"', 'Event_log_base."Event_end"') }}
        end as "Event_throughput_time",
        NULL as "Manual_event_cost",
        NULL as "Manual_event_processing_time",
        Event_log_base."Team",
        Event_log_base."User"
    from Event_log_base
    left join Event_log_with_event_order
        on Event_log_base."Event_ID" = Event_log_with_event_order."Event_ID"
    left join Event_log_with_previous_event_end
        on Event_log_base."Event_ID" = Event_log_with_previous_event_end."Event_ID"
)

select * from Event_log
