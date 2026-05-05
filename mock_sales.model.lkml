connection: "default_bigquery_connection"

include: "/views/*.view.lkml"                # include all views in the views/ folder in this project

explore: store_sales {
  sql_always_where:
    {% if store_sales.analysis_year._is_filtered %}
      -- Match year (casted to string for the string filter)
      {% condition store_sales.analysis_year %} CAST(${store_sales.date_year} AS STRING) {% endcondition %}
      OR
      -- Fetch 1 year prior (add 1, then cast to string)
      {% condition store_sales.analysis_year %} CAST(${store_sales.date_year} + 1 AS STRING) {% endcondition %}
    {% else %}
      1=1
    {% endif %}
  ;;
}

explore: store_sales_new {

  join: store_sales_yoy_precalc {
    type: left_outer
    relationship: many_to_one
    sql_on:
      ${store_sales_new.store_name} = ${store_sales_yoy_precalc.store_name} AND
      ${store_sales_new.date_year} = ${store_sales_yoy_precalc.date_year}
    ;;
  }
}
