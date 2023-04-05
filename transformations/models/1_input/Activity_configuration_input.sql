with Activity_configuration as (
    select * from {{ ref('Activity_configuration') }}
),

/* Input table for the activity configuration seeds file */
Activity_configuration_input as (
    select
        -- Convert all fields to the correct data type.
        {{ pm_utils.to_varchar('Activity_configuration."Activity"') }} as "Activity",
        {{ pm_utils.to_integer('Activity_configuration."Activity_order"') }} as "Activity_order"
    from Activity_configuration
)

select * from Activity_configuration_input
