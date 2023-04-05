{%- macro custom_fields(source_table, name, group_by) -%}

{%- set columns = adapter.get_columns_in_relation(source_table) -%}

{# Create list of column names.#}
{%- set column_names = [] -%}
{%- for column in columns -%}
    {%- set column_names = column_names.append('"' + column.name + '"') -%}
{%- endfor -%}

{# Select or create 30 text fields. #}
{% for i in range(30) -%}
    {%- set field = '"custom_' ~ name ~ '_text_' ~ (i + 1) ~ '"' -%}
    {# If field exists in the source table and the group_by parameter is undefined, select the field #}
    {%- if field in column_names and group_by is not defined -%}
        {{ field }},
    {# If field exists in the source table and the group_by parameter is true, select the field with min() #}
    {%- elif field in column_names and group_by is defined -%}
        min({{ field }}) as {{ field }},
    {# If field does not exist in the source table, create the field with null values. #}
    {%- else %}
        {{ pm_utils.to_varchar('null') }} as {{ field }},
    {%- endif -%}
{% endfor -%}

{# Select or create 10 double fields. #}
{% for i in range(10) -%}
    {%- set field = '"custom_' ~ name ~ '_number_' ~ (i + 1) ~ '"' -%}
    {# If field exists in the source table and the group_by parameter is undefined, select the field #}
    {%- if field in column_names and group_by is not defined -%}
        {{ pm_utils.to_double(field) }} as {{ field }},
    {# If field exists in the source table and the group_by parameter is true, select the field with min() #}
    {%- elif field in column_names and group_by is defined -%}
        min({{ pm_utils.to_double(field) }}) as {{ field }},
    {# If field does not exist in the source table, create the field with null values. #}
    {%- else %}
        {{ pm_utils.to_double('null') }} as {{ field }},
    {%- endif -%}
{% endfor -%}

{# Select or create 10 datetime fields. #}
{% for i in range(10) -%}
    {%- set field = '"custom_' ~ name ~ '_datetime_' ~ (i + 1) ~ '"' -%}
    {# If field exists in the source table and the group_by parameter is undefined, select the field #}
    {%- if field in column_names and group_by is not defined -%}
        {{ pm_utils.to_timestamp(field) }} as {{ field }} {{',' if not loop.last }}
    {# If field exists in the source table and the group_by parameter is true, select the field with min() #}
    {%- elif field in column_names and group_by is defined -%}
        min({{ pm_utils.to_timestamp(field) }}) as {{ field }} {{',' if not loop.last }}
    {# If field does not exist in the source table, create the field with null values. #}
    {%- else %}
        {{ pm_utils.to_timestamp('null') }} as {{ field }} {{',' if not loop.last }}
    {%- endif -%}
{% endfor -%}

{%- endmacro -%}
