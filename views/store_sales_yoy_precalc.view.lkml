view: store_sales_yoy_precalc {
  derived_table: {
    sql:
      WITH aggregated AS (
        SELECT
          Store_Name,
          Year,
          SUM(Daily_Sales_USD) as total_sales
        FROM `gabriel-teixeira-argolis.mock_sales.store_sales`
        GROUP BY 1, 2
      )
      SELECT
        Store_Name,
        Year,
        total_sales,
        LAG(total_sales) OVER (PARTITION BY Store_Name ORDER BY Year) as prev_year_sales
      FROM aggregated
    ;;
  }

  dimension: primary_key {
    primary_key: yes
    hidden: yes
    sql: CONCAT(${store_name}, CAST(${date_year} AS STRING)) ;;
  }

  dimension: store_name {
    type: string
    hidden: yes
    sql: ${TABLE}.Store_Name ;;
  }

  dimension: date_year {
    type: number
    hidden: yes
    sql: ${TABLE}.Year ;;
  }

  measure: total_sales_usd {
    type: sum
    sql: ${TABLE}.total_sales ;;
    value_format_name: usd
  }

  measure: prev_year_sales_usd {
    type: sum
    hidden: yes
    sql: ${TABLE}.prev_year_sales ;;
  }

  measure: yoy_sales_calc {
    label: "% YoY Sales (Pre-calculated)"
    type: number
    sql: SAFE_DIVIDE((${total_sales_usd} - ${prev_year_sales_usd}), ${prev_year_sales_usd}) ;;
    value_format_name: percent_2
  }
}
