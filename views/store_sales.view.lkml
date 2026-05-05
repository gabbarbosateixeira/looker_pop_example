view: store_sales {
  sql_table_name: `gabriel-teixeira-argolis.mock_sales.store_sales` ;;

  dimension: customers {
    type: number
    sql: ${TABLE}.Customers ;;
  }
  dimension: daily_sales_usd {
    type: number
    sql: ${TABLE}.Daily_Sales_USD ;;
  }
  dimension_group: date {
    type: time
    timeframes: [raw, date, week, month, month_name, month_num, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.Date ;;
  }

  dimension: store_name {
    type: string
    sql: ${TABLE}.Store_Name ;;
  }
  dimension: units_sold {
    type: number
    sql: ${TABLE}.Units_Sold ;;
  }

  measure: count {
    type: count
    drill_fields: [store_name]
  }

  dimension: year_string_for_dropdown {
    hidden: yes
    type: string
    sql: CAST(${date_year} AS STRING) ;;
  }

# 1. Dummy filter for the user to select specific years
  filter: analysis_year {
    type: string
    suggest_dimension: year_string_for_dropdown
    description: "Select the years you want to analyze. The system will automatically fetch the previous year."
  }

  # 2. Measure to sum sales
  measure: total_sales_usd {
    type: sum
    sql: ${daily_sales_usd} ;;
    value_format_name: usd
  }

  # 3. Looker native YoY calculation
  measure: yoy_sales {
    label: "% YoY Sales"
    type: percent_of_previous
    sql: ${total_sales_usd} ;;
    value_format: "0.00\%"
  }

}
