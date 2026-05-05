view: store_sales_new {
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
  timeframes: [raw, date, week, month, quarter, year]
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

  dimension: year_string_for_dropdown {
    hidden: yes
    type: string
    sql: CAST(${date_year} AS STRING) ;;
  }

  dimension: year_dropdown {
    label: "Date Year (Dropdown)"
    type: string
    sql: CAST(${date_year} AS STRING) ;;
    suggest_dimension: year_string_for_dropdown
    description: "Use this field to filter the year with a standard dropdown menu."
  }

measure: count {
  type: count
  drill_fields: [store_name]
}
}
