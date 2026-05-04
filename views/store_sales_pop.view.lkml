view: store_sales_pop {
  sql_table_name: `gabriel-teixeira-argolis.mock_sales.store_sales` ;;

  # ==========================================================
  # 0. BASE DIMENSIONS
  # ==========================================================

  dimension_group: date {
    type: time
    timeframes: [raw, date, week, month, year]
    sql: ${TABLE}.Date ;;
  }

  dimension: store_name {
    type: string
    view_label: "📅 Dynamic Matrix"
    label: "Loja"
    sql: ${TABLE}.Store_Name ;;
  }

  # ==========================================================
  # 1. THE PARAMETERS (Pulling from Date Dimension)
  # ==========================================================

  parameter: comparison_year {
    type: number
    suggest_dimension: date_year
    view_label: "📅 Dynamic Matrix"
    label: "1. Select First Year (Comparison)"
  }

  parameter: base_year {
    type: number
    suggest_dimension: date_year
    view_label: "📅 Dynamic Matrix"
    label: "2. Select Second Year (Base)"
  }

  # --- Hidden dimensions to apply the SQL filters ---
  dimension: is_comparison_year {
    hidden: yes
    type: yesno
    sql: EXTRACT(YEAR FROM CAST(${TABLE}.Date AS TIMESTAMP)) = {% parameter comparison_year %} ;;
  }

  dimension: is_base_year {
    hidden: yes
    type: yesno
    sql: EXTRACT(YEAR FROM CAST(${TABLE}.Date AS TIMESTAMP)) = {% parameter base_year %} ;;
  }

  # ==========================================================
  # 2. COMPARISON YEAR MEASURES (First Selected Year)
  # ==========================================================

  measure: sales_s_ipi_comp {
    type: sum
    view_label: "📅 Dynamic Matrix"
    sql: ${TABLE}.Daily_Sales_USD * 0.9 ;; # Mock logic for s/ IPI
    filters: [is_comparison_year: "yes"]
    value_format_name: usd
    label: "R$ Vendas s/ IPI ({{ comparison_year._parameter_value }})"
  }

  measure: sales_c_ipi_comp {
    type: sum
    view_label: "📅 Dynamic Matrix"
    sql: ${TABLE}.Daily_Sales_USD ;;
    filters: [is_comparison_year: "yes"]
    value_format_name: usd
    label: "R$ Vendas c/ IPI ({{ comparison_year._parameter_value }})"
  }

  measure: items_comp {
    type: sum
    view_label: "📅 Dynamic Matrix"
    sql: ${TABLE}.Units_Sold ;;
    filters: [is_comparison_year: "yes"]
    label: "(Qtd) Itens ({{ comparison_year._parameter_value }})"
  }

  measure: meta_comp {
    type: sum
    view_label: "📅 Dynamic Matrix"
    sql: ${TABLE}.Daily_Sales_USD * 1.1 ;; # Mock target logic
    filters: [is_comparison_year: "yes"]
    value_format_name: usd
    label: "R$ Meta ({{ comparison_year._parameter_value }})"
  }

  # ==========================================================
  # 3. BASE YEAR MEASURES (Second Selected Year)
  # ==========================================================

  measure: sales_s_ipi_base {
    type: sum
    view_label: "📅 Dynamic Matrix"
    sql: ${TABLE}.Daily_Sales_USD * 0.9 ;;
    filters: [is_base_year: "yes"]
    value_format_name: usd
    label: "R$ Vendas s/ IPI ({{ base_year._parameter_value }})"
  }

  measure: sales_c_ipi_base {
    type: sum
    view_label: "📅 Dynamic Matrix"
    sql: ${TABLE}.Daily_Sales_USD ;;
    filters: [is_base_year: "yes"]
    value_format_name: usd
    label: "R$ Vendas c/ IPI ({{ base_year._parameter_value }})"
  }

  measure: items_base {
    type: sum
    view_label: "📅 Dynamic Matrix"
    sql: ${TABLE}.Units_Sold ;;
    filters: [is_base_year: "yes"]
    label: "(Qtd) Itens ({{ base_year._parameter_value }})"
  }

  measure: meta_base {
    type: sum
    view_label: "📅 Dynamic Matrix"
    sql: ${TABLE}.Daily_Sales_USD * 1.1 ;;
    filters: [is_base_year: "yes"]
    value_format_name: usd
    label: "R$ Meta ({{ base_year._parameter_value }})"
  }

  # ==========================================================
  # 4. YOY VARIANCES
  # ==========================================================

  measure: sales_yoy_variance {
    type: number
    view_label: "📅 Dynamic Matrix"
    label: "R$ Vendas % YoY"
    sql: 1.0 * (${sales_c_ipi_base} - ${sales_c_ipi_comp}) / NULLIF(${sales_c_ipi_comp}, 0) ;;
    value_format_name: percent_2
    html:
      {% if value > 0 %}
        <span style="color: #228B22; font-weight: bold;">▲ {{ rendered_value }}</span>
      {% elsif value < 0 %}
        <span style="color: #B22222; font-weight: bold;">▼ {{ rendered_value }}</span>
      {% else %}
        <span style="color: #DAA520; font-weight: bold;">▬ {{ rendered_value }}</span>
      {% endif %} ;;
  }

  measure: items_yoy_variance {
    type: number
    view_label: "📅 Dynamic Matrix"
    label: "(%_Qtd) YoY"
    sql: 1.0 * (${items_base} - ${items_comp}) / NULLIF(${items_comp}, 0) ;;
    value_format_name: percent_2
    html:
      {% if value > 0 %}
        <span style="color: #228B22; font-weight: bold;">▲ {{ rendered_value }}</span>
      {% elsif value < 0 %}
        <span style="color: #B22222; font-weight: bold;">▼ {{ rendered_value }}</span>
      {% else %}
        <span style="color: #DAA520; font-weight: bold;">▬ {{ rendered_value }}</span>
      {% endif %} ;;
  }
}
