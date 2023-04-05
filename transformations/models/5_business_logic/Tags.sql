with Cases_base as (
    select * from {{ ref('Cases_base') }}
),

Event_log_base as (
    select * from {{ ref('Event_log_base') }}
),

-- This is a template for generating supporting attributes for tags logic
Event_log_base_tag_preprocessing as (
    -- Create new attributes to determine if a tag occurs
    select
        Event_log_base."Case_ID"
    from Event_log_base
    -- Determine the applicable filtering
    where 1 = 0
    group by Event_log_base."Case_ID"
),

/* Table containing all definitions of the tags.
A subset of the table has a specific tag. Define the subsets with the where statement where applicable.
Tags defined on cases or events should then be unioned. */
Tags_preprocessing as (
    select
        Cases_base."Case_ID",
        'The name of the tag' as "Tag"
    from Cases_base
    -- Insert your logic to determine when the tag should trigger
    where 1 = 0
    union all
    select
        Event_log_base_tag_preprocessing."Case_ID",
        'The name of the tag' as "Tag"
    from Event_log_base_tag_preprocessing
    -- Insert your logic to determine when the tag should trigger
    where 1 = 0
),

Tags as (
    select
        row_number() over (order by Tags_preprocessing."Case_ID") as "Tag_ID",
        Tags_preprocessing."Case_ID",
        Tags_preprocessing."Tag"
    from Tags_preprocessing
)

select * from Tags
