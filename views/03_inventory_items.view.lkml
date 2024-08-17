view: inventory_items {
  sql_table_name: looker-private-demo.ecomm.inventory_items ;;
  view_label: "재고상품"
  ## DIMENSIONS ##

  dimension: id {
    label: "재고ID"
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: cost {
    label: "비용"
    type: number
    value_format_name: usd
    sql: ${TABLE}.cost ;;
  }

  dimension_group: created {
    label: "재고등록일"
    type: time
    timeframes: [time, date, week, month, raw]
    #sql: cast(CASE WHEN ${TABLE}.created_at = "\\N" THEN NULL ELSE ${TABLE}.created_at END as timestamp) ;;
    sql: CAST(${TABLE}.created_at AS TIMESTAMP) ;;
  }

  dimension: product_id {
    label: "상품ID"
    type: number
    hidden: yes
    sql: ${TABLE}.product_id ;;
  }

  dimension_group: sold {
    label: "판매일"
    type: time
    timeframes: [time, date, week, month, raw]
#    sql: cast(CASE WHEN ${TABLE}.sold_at = "\\N" THEN NULL ELSE ${TABLE}.sold_at END as timestamp) ;;
    sql: ${TABLE}.sold_at ;;
  }

  dimension: is_sold {
    label: "판매플래그"
    type: yesno
    sql: ${sold_raw} is not null ;;
  }

  dimension: days_in_inventory {
    label: "재고일수"
    description: "재고로 등록된 이후 판매될 때까지(또는 현재까지) 일 수"
    type: number
    sql: TIMESTAMP_DIFF(coalesce(${sold_raw}, CURRENT_TIMESTAMP()), ${created_raw}, DAY) ;;
  }

  dimension: days_in_inventory_tier {
    label: "재고일수티어"
    type: tier
    sql: ${days_in_inventory} ;;
    style: integer
    tiers: [0, 5, 10, 20, 40, 80, 160, 360]
  }

  dimension: days_since_arrival {
    label: "등록후경과일수"
    description: "days since created - useful when filtering on sold yesno for items still in inventory"
    type: number
    sql: TIMESTAMP_DIFF(CURRENT_TIMESTAMP(), ${created_raw}, DAY) ;;
  }

  dimension: days_since_arrival_tier {
    label: "등록후결과일수티어"
    type: tier
    sql: ${days_since_arrival} ;;
    style: integer
    tiers: [0, 5, 10, 20, 40, 80, 160, 360]
  }

  dimension: product_distribution_center_id {
    label: "상품배송센터ID"
    hidden: yes
    sql: ${TABLE}.product_distribution_center_id ;;
  }

  ## MEASURES ##

  measure: sold_count {
    label: "판매건수"
    type: count
    drill_fields: [detail*]

    filters: {
      field: is_sold
      value: "Yes"
    }
  }

  measure: sold_percent {
    label: "판매된비율"
    type: number
    value_format_name: percent_2
    sql: 1.0 * ${sold_count}/(CASE WHEN ${count} = 0 THEN NULL ELSE ${count} END) ;;
  }

  measure: total_cost {
    label: "총비용"
    type: sum
    value_format_name: usd
    sql: ${cost} ;;
  }

  measure: average_cost {
    label: "평균비용"
    type: average
    value_format_name: usd
    sql: ${cost} ;;
  }

  measure: count {
    label: "재고상품수"
    type: count
    drill_fields: [detail*]
  }

  measure: number_on_hand {
    label: "미판매재고건수"
    type: count
    drill_fields: [detail*]

    filters: {
      field: is_sold
      value: "No"
    }
  }

  measure: stock_coverage_ratio {
    label: "재고커버리지"
    type:  number
    description: "미판매재고 vs 28일이내의판매건수"
    sql:  1.0 * ${number_on_hand} / nullif(${order_items.count_last_28d}*20.0,0) ;;
    value_format_name: decimal_2
    html: <p style="color: black; background-color: rgba({{ value | times: -100.0 | round | plus: 250 }},{{value | times: 100.0 | round | plus: 100}},100,80); font-size:100%; text-align:center">{{ rendered_value }}</p> ;;
  }

  set: detail {
    fields: [id, products.item_name, products.category, products.brand, products.department, cost, created_time, sold_time]
  }
}
