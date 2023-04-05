with Event_log_base as (
    select * from {{ ref('Event_log_base') }}
),

/* Table containing all definitions of the due dates. */
Due_dates_preprocessing as (
    select
        Event_log_base."Event_ID",
        'The name of the due date' as "Due_date",
        Event_log_base."Event_end" as "Actual_date",
        -- Add logic which should be used as the Expected_date timestamp attribute
        null as "Expected_date"
    from Event_log_base
    -- Insert your logic to determine when the due date should be calculated
    where 1 = 0
),

Due_dates as (
    select
        Due_dates_preprocessing."Event_ID",
        Due_dates_preprocessing."Due_date",
        Due_dates_preprocessing."Actual_date",
        Due_dates_preprocessing."Expected_date",
        {{ pm_utils.datediff('millisecond', 'Due_dates_preprocessing."Actual_date"', 'Due_dates_preprocessing."Expected_date"') }} as "Days_late"
    from Due_dates_preprocessing
)

select * from Due_dates
