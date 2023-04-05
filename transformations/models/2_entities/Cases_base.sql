with Cases_input as (
    select * from {{ ref('Cases_input') }}
),

Cases_base as (
    select
        -- Mandatory
        Cases_input."case_id" as "Case_ID",
        -- Optional
        Cases_input."case" as "Case",
        Cases_input."case_status" as "Case_status",
        Cases_input."case_type" as "Case_type",
        Cases_input."case_value" as "Case_value",
        -- Custom
        {{ custom_fields(ref('Cases_input'), 'case') }}
    from Cases_input
)

select * from Cases_base
