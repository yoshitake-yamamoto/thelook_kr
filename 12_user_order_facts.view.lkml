view: user_order_facts {
  view_label: "顧客マスタ"
  derived_table: {
    sql:
    SELECT
        user_id
        , COUNT(DISTINCT order_id) AS lifetime_orders
        , SUM(sale_price) AS lifetime_revenue
        , CAST(MIN(created_at)  AS TIMESTAMP) AS first_order
        , CAST(MAX(created_at)  AS TIMESTAMP)  AS latest_order
        , COUNT(DISTINCT FORMAT_TIMESTAMP('%Y%m', created_at))  AS number_of_distinct_months_with_orders
        --, FIRST_VALUE(CONCAT(uniform(2, 9, random(1)),uniform(0, 9, random(2)),uniform(0, 9, random(3)),'-',uniform(0, 9, random(4)),uniform(0, 9, random(5)),uniform(0, 9, random(6)),'-',uniform(0, 9, random(7)),uniform(0, 9, random(8)),uniform(0, 9, random(9)),uniform(0, 9, random(10)))) OVER (PARTITION BY user_id ORDER BY user_id) AS phone_number
      FROM looker-private-demo.ecomm.order_items
      GROUP BY user_id
    ;;
    #datagroup_trigger: ecommerce_etl_modified
  }

  dimension: user_id {
    label: "顧客ID"
    primary_key: yes
    hidden: yes
    sql: ${TABLE}.user_id ;;
  }

#   dimension: phone_number {
#     type: string
#     tags: ["phone"]
#     sql: ${TABLE}.phone_number ;;
#   }


  ##### Time and Cohort Fields ######

  dimension_group: first_order {
    label: "初回受注"
    type: time
    timeframes: [date, week, month, year]
    sql: ${TABLE}.first_order ;;
  }

  dimension_group: latest_order {
    label: "最新受注"
    type: time
    timeframes: [date, week, month, year]
    sql: ${TABLE}.latest_order ;;
  }


  dimension: days_as_customer {
    label: "継続日数"
    description: "最新受注日と初回受注日の日数差"
    type: number
    sql: TIMESTAMP_DIFF(${TABLE}.latest_order, ${TABLE}.first_order, DAY)+1 ;;
  }

  dimension: days_as_customer_tiered {
    label: "継続日数ティア"
    type: tier
    tiers: [0, 1, 7, 14, 21, 28, 30, 60, 90, 120]
    sql: ${days_as_customer} ;;
    style: integer
  }

  ##### Lifetime Behavior - Order Counts ######

  dimension: lifetime_orders {
    label: "累計受注回数"
    type: number
    sql: ${TABLE}.lifetime_orders ;;
  }

  dimension: repeat_customer {
    label: "リピート顧客フラグ"
    description: "累計受注回数 > 1　か否か"
    type: yesno
    sql: ${lifetime_orders} > 1 ;;
  }

  dimension: lifetime_orders_tier {
    label: "累計受注回数ティア"
    type: tier
    tiers: [0, 1, 2, 3, 5, 10]
    sql: ${lifetime_orders} ;;
    style: integer
  }

  measure: average_lifetime_orders {
    label: "平均受注回数"
    type: average
    value_format_name: decimal_2
    sql: ${lifetime_orders} ;;
  }

  dimension: distinct_months_with_orders {
    label: "ユニーク受注月数"
    type: number
    sql: ${TABLE}.number_of_distinct_months_with_orders ;;
  }

  ##### Lifetime Behavior - Revenue ######

  dimension: lifetime_revenue {
    label: "累計収益"
    type: number
    value_format_name: usd
    sql: ${TABLE}.lifetime_revenue ;;
  }

  dimension: lifetime_revenue_tier {
    label: "累計収益ティア"
    type: tier
    tiers: [0, 25, 50, 100, 200, 500, 1000]
    sql: ${lifetime_revenue} ;;
    style: integer
  }

  measure: average_lifetime_revenue {
    label: "平均収益"
    type: average
    value_format_name: usd
    sql: ${lifetime_revenue} ;;
  }
}
