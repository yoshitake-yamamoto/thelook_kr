view: discounts {
  sql_table_name: looker-private-demo.ecomm.discounts;;
  view_label: "割引情報"

  measure: count {
    label: "割引件数"
    type: count
    drill_fields: [detail*]
  }

  dimension: product_id {
    label: "商品ID"
    type: number
    sql: ${TABLE}.product_id ;;
  }

  dimension: pk {
    hidden: yes
    primary_key: yes
    type: number
    sql: CONCAT(${TABLE}.inventory_item_id, ${date_raw}) ;;
  }


  dimension: inventory_item_id {
    # primary_key: yes
    label: "在庫商品ID"
    type: number
    sql: ${TABLE}.inventory_item_id ;;
  }

  dimension: retail_price {
    label: "小売価格"
    type: number
    sql: ${TABLE}.retail_price ;;
  }

  dimension: discount_price {
    label: "値引き後価格"
    type: number
    sql: ${TABLE}.discount_price ;;
  }

  dimension: discount_amount {
    label: "割引率"
    type: number
    sql: ${TABLE}.discount_amount ;;
  }

  dimension_group: date {
    label: "割引適用日"
    type: time
    sql: ${TABLE}.date ;;
  }

  measure: average_discount {
    label: "平均割引率"
    type: average
    sql: ${TABLE}.discount_amount ;;
    value_format_name: percent_2
  }

  set: detail {
    fields: [
      product_id,
      inventory_item_id,
      retail_price,
      discount_price,
      discount_amount,
      date_time
    ]
  }
}
