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
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.Date ;;
  }
  dimension: day_of_week {
    type: string
    sql: ${TABLE}.Day_of_Week ;;
  }
  dimension: month {
    type: string
    sql: ${TABLE}.Month ;;
  }
  dimension: store_name {
    type: string
    sql: ${TABLE}.Store_Name ;;
  }
  dimension: units_sold {
    type: number
    sql: ${TABLE}.Units_Sold ;;
  }
  dimension: year {
    type: number
    sql: ${TABLE}.Year ;;
  }
  measure: count {
    type: count
    drill_fields: [store_name]
  }
}
