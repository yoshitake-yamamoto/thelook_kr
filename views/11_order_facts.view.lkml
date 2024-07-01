include: "/models/**/thelook_jp.model.lkml"
view: order_facts {
  view_label: "受注履歴"
  derived_table: {
    explore_source: order_items {
      column: order_id {field: order_items.order_id_no_actions }
      column: items_in_order { field: order_items.count }
      column: order_amount { field: order_items.total_sale_price }
      column: order_cost { field: inventory_items.total_cost }
      column: user_id {field: order_items.user_id }
      column: created_at {field: order_items.created_raw}
      column: order_gross_margin {field: order_items.total_gross_margin}
      derived_column: order_sequence_number {
        sql: RANK() OVER (PARTITION BY user_id ORDER BY created_at) ;;
      }
    }
    #datagroup_trigger: ecommerce_etl_modified
  }

  dimension: order_id {
    label: "受注ID"
    type: number
    hidden: yes
    primary_key: yes
    sql: ${TABLE}.order_id ;;
  }

  dimension: items_in_order {
    label: "受注商品数"
    description: "一回の受注IDに含まれる商品の種類数"
    type: number
    sql: ${TABLE}.items_in_order ;;
  }

  dimension: order_amount {
    label: "受注金額"
    type: number
    value_format_name: usd
    sql: ${TABLE}.order_amount ;;
  }

  dimension: order_cost {
    label: "コスト"
    type: number
    value_format_name: usd
    sql: ${TABLE}.order_cost ;;
  }

  dimension: order_gross_margin {
    label: "受注粗利"
    type: number
    value_format_name: usd
  }

  dimension: order_sequence_number {
    label: "顧客別受注番号"
    description: "その顧客にとって何回目の受注かを示す連番"
    type: number
    sql: ${TABLE}.order_sequence_number ;;
  }

  dimension: is_first_purchase {
    label: "初回受注フラグ"
    type: yesno
    sql: ${order_sequence_number} = 1 ;;
  }
}
