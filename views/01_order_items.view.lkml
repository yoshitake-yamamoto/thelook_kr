view: order_items {
  sql_table_name: looker-private-demo.ecomm.order_items ;;
  view_label: "受注明細"
  ########## IDs, Foreign Keys, Counts ###########

  dimension: id {
    label: "明細ID"
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
    value_format: "00000"
  }

  dimension: inventory_item_id {
    label: "在庫ID"
    type: number
    hidden: yes
    sql: ${TABLE}.inventory_item_id ;;
  }

  dimension: user_id {
    label: "顧客ID"
    type: number
    hidden: yes
    sql: ${TABLE}.user_id ;;
  }

  measure: count {
    label: "明細行数"
    type: count
    drill_fields: [detail*]
  }

  measure: count_last_28d {
    label: "直近28日の受注件数"
    type: count_distinct
    sql: ${id} ;;
    hidden: yes
    filters:
    {field:created_date
      value: "28 days"
    }}

  measure: order_count {
    view_label: "受注履歴"
    label: "受注件数"
    type: count_distinct
    drill_fields: [detail*]
    sql: ${order_id};;
  }

  measure: first_purchase_count {
    view_label: "受注履歴"
    label: "初回受注件数"
    description: "各顧客にとっての初回受注のみをカウント"
    type: count_distinct
    sql: ${order_id} ;;
    filters: {
      field: order_facts.is_first_purchase
      value: "Yes"
    }
    drill_fields: [user_id, users.name, users.email, order_id, created_date, users.traffic_source]
  }

  dimension: order_id_no_actions {
    label: "Order ID No Actions"
    type: number
    hidden: yes
    sql: ${TABLE}.order_id ;;
  }

  dimension: order_id {
    label: "受注ID"
    type: number
    sql: ${TABLE}.order_id ;;
    action: {
      label: "slackチャンネルに送信"
      url: "https://hooks.zapier.com/hooks/catch/1662138/tvc3zj/"
      param: {
        name: "user_dash_link"
        value: "/dashboards/ayalascustomerlookupdb?Email={{ users.email._value}}"
      }
      form_param: {
        name: "Message"
        type: textarea
        default: "お疲れ様です。

        受注ID #{{value}}について確認お願いします。
        ステータスは、「{{status._value}}」となっていますが、
        顧客から問い合わせが来ています。
        ~{{ _user_attributes.first_name}}"
      }
      form_param: {
        name: "送信先"
        type: select
        default: "zevl"
        option: {
          name: "zevl"
          label: "Zev"
        }
        option: {
          name: "slackdemo"
          label: "Slack Demo User"
        }
      }
      form_param: {
        name: "Channel"
        type: select
        default: "cs"
        option: {
          name: "cs"
          label: "Customer Support"
        }
        option: {
          name: "general"
          label: "General"
        }
      }
    }
    action: {
      label: "注文フォーム作成"
      url: "https://hooks.zapier.com/hooks/catch/2813548/oosxkej/"
      form_param: {
        name: "Order ID"
        type: string
        default: "{{ order_id._value }}"
      }

      form_param: {
        name: "Name"
        type: string
        default: "{{ users.name._value }}"
      }

      form_param: {
        name: "Email"
        type: string
        default: "{{ _user_attributes.email }}"
      }

      form_param: {
        name: "Item"
        type: string
        default: "{{ products.item_name._value }}"
      }

      form_param: {
        name: "Price"
        type: string
        default: "{{ sale_price._rendered_value }}"
      }

      form_param: {
        name: "Comments"
        type: string
        default: " Hi {{ users.first_name._value }}, thanks for your business!"
      }
    }
    value_format: "00000"
  }

  ########## Time Dimensions ##########

  dimension_group: returned {
    label: "返品日"
    type: time
    timeframes: [time, date, week, month, raw]
    sql: ${TABLE}.returned_at ;;

  }

  dimension_group: shipped {
    label: "発送日"
    type: time
    timeframes: [date, week, month, raw]
    sql: CAST(${TABLE}.shipped_at AS TIMESTAMP) ;;

  }

  dimension_group: delivered {
    label: "配送日"
    type: time
    timeframes: [date, week, month, raw]
    sql: CAST(${TABLE}.delivered_at AS TIMESTAMP) ;;

  }

  # 受注日の日本語化 --------------------------------------------------------
  dimension: created_year{
    group_label: "受注日"
    group_item_label: "年(YYYY)"
    type: date_year
    sql: ${TABLE}.created_at ;;
  }

  dimension: created_month{
    group_label: "受注日"
    group_item_label: "年月(YYYY-MM)"
    type: date_month
    sql: ${TABLE}.created_at ;;
  }

  dimension: created_month_num{
    group_label: "受注日"
    group_item_label: "月(MM)"
    type: date_month_num
    sql: ${TABLE}.created_at ;;
  }

  dimension: created_date{
    group_label: "受注日"
    group_item_label: "年月日(YYYY-MM-DD)"
    type: date
    sql: ${TABLE}.created_at ;;
  }

  dimension: created_day_of_week{
    group_label: "受注日"
    group_item_label: "曜日"
    type: date_day_of_week
    sql: ${TABLE}.created_at ;;
  }

  dimension: created_hour{
    group_label: "受注日"
    group_item_label: "時間(HH)"
    type: date_hour_of_day
    sql: ${TABLE}.created_at ;;
  }

  dimension: created_time{
    group_label: "受注日"
    group_item_label: "日時"
    type: date_time
    sql: ${TABLE}.created_at ;;
  }

  dimension: created_raw{
    hidden: yes
    group_label: "受注日"
    type: date_raw
    sql: ${TABLE}.created_at ;;
  }


  dimension: created_week{
    group_label: "受注日"
    group_item_label: "週"
    type: date_week
    sql: ${TABLE}.created_at ;;
  }

  dimension: created_week_of_year{
    group_label: "受注日"
    group_item_label: "週番号"
    type: date_week_of_year
    sql: ${TABLE}.created_at ;;
  }

  #---------------------------------------------------------------------------


  dimension: reporting_period_ytd_vs_lytd {
    label: "年初来_当年と昨年の比較"
    sql: CASE
        WHEN EXTRACT(YEAR from ${created_raw}) = EXTRACT(YEAR from CURRENT_TIMESTAMP())
        AND ${created_raw} < CURRENT_TIMESTAMP()
        THEN '当年 年初来'

      WHEN EXTRACT(YEAR from ${created_raw}) + 1 = EXTRACT(YEAR from CURRENT_TIMESTAMP())
      AND CAST(FORMAT_TIMESTAMP('%j', ${created_raw}) AS INT64) <= CAST(FORMAT_TIMESTAMP('%j', CURRENT_TIMESTAMP()) AS INT64)
      THEN '昨年 年初来'

      END
      ;;
  }

  dimension: days_since_sold {
    label: "受注後経過日数"
    hidden: yes
    sql: TIMESTAMP_DIFF(${created_raw},CURRENT_TIMESTAMP(), DAY) ;;
  }

  dimension: months_since_signup {
    label: "会員登録後経過月数"
    view_label: "受注履歴"
    type: number
    sql: CAST(FLOOR(TIMESTAMP_DIFF(${created_raw}, ${users.created_raw}, DAY)/30) AS INT64) ;;
  }

########## Logistics ##########

  dimension: status {
    label: "ステータス"
    sql: ${TABLE}.status ;;
  }


  dimension: days_to_process {
    label: "処理日数"
    type: number
    sql: CASE
        WHEN ${status} = 'Processing' THEN TIMESTAMP_DIFF(CURRENT_TIMESTAMP(), ${created_raw}, DAY)*1.0
        WHEN ${status} IN ('Shipped', 'Complete', 'Returned') THEN TIMESTAMP_DIFF(${shipped_raw}, ${created_raw}, DAY)*1.0
        WHEN ${status} = 'Cancelled' THEN NULL
      END
       ;;
  }


  dimension: shipping_time {
    label: "配送日数"
    type: number
    sql: TIMESTAMP_DIFF(${delivered_raw}, ${shipped_raw}, DAY)*1.0 ;;
  }


  measure: average_days_to_process {
    label: "平均処理日数"
    type: average
    value_format_name: decimal_2
    sql: ${days_to_process} ;;
  }

  measure: average_shipping_time {
    label: "平均配送日数"
    type: average
    value_format_name: decimal_2
    sql: ${shipping_time} ;;
  }

########## Financial Information ##########

  dimension: sale_price {
    label: "売上"
    type: number
    value_format_name: usd
    sql: ${TABLE}.sale_price;;
  }

  dimension: gross_margin {
    label: "粗利"
    type: number
    value_format_name: usd
    sql: ${sale_price} - ${inventory_items.cost};;
  }

  dimension: item_gross_margin_percentage {
    label: "粗利率"
    type: number
    value_format_name: percent_2
    sql: 1.0 * ${gross_margin}/NULLIF(${sale_price},0) ;;
  }

  dimension: item_gross_margin_percentage_tier {
    label: "粗利率ティア"
    type: tier
    sql: 100*${item_gross_margin_percentage} ;;
    tiers: [0, 10, 20, 30, 40, 50, 60, 70, 80, 90]
    style: interval
  }

  measure: total_sale_price {
    label: "合計売上"
    description: "収益の合計金額。受注日を基準とし、受注額を単純に足し合わせたもの"
    type: sum
    value_format_name: usd
    sql: ${sale_price};;
    drill_fields: [detail*]
  }

  measure: total_gross_margin {
    label: "合計粗利"
    type: sum
    value_format_name: usd
    sql: ${gross_margin} ;;
    # drill_fields: [detail*]
    drill_fields: [user_id, average_sale_price, total_gross_margin]
  }

  measure: average_sale_price {
    label: "売上平均額"
    type: average
    value_format_name: usd
    sql: ${sale_price} ;;
    drill_fields: [detail*]
  }

  measure: median_sale_price {
    label: "売上中央値"
    type: median
    value_format_name: usd
    sql: ${sale_price} ;;
    drill_fields: [detail*]
  }

  measure: average_gross_margin {
    label: "粗利平均額"
    type: average
    value_format_name: usd
    sql: ${gross_margin} ;;
    drill_fields: [detail*]
  }

  measure: total_gross_margin_percentage {
    label: "総粗利率"
    type: number
    value_format_name: percent_2
    sql: 1.0 * ${total_gross_margin}/ nullif(${total_sale_price},0) ;;
  }

  measure: average_spend_per_user {
    label: "顧客平均支出"
    description: "売上の合計を顧客人数で割ったもの"
    type: number
    value_format_name: usd
    sql: 1.0 * ${total_sale_price} / nullif(${users.count},0) ;;
    drill_fields: [detail*]
  }

########## Return Information ##########

  dimension: is_returned {
    label: "返品フラグ"
    type: yesno
    sql: ${returned_raw} IS NOT NULL ;;
  }

  measure: returned_count {
    label: "返品件数"
    type: count_distinct
    sql: ${id} ;;
    filters: {
      field: is_returned
      value: "yes"
    }
    drill_fields: [detail*]
  }

  measure: returned_total_sale_price {
    label: "合計返品売上"
    type: sum
    value_format_name: usd
    sql: ${sale_price} ;;
    filters: {
      field: is_returned
      value: "yes"
    }
  }

  measure: return_rate {
    label: "返品率"
    type: number
    value_format_name: percent_2
    sql: 1.0 * ${returned_count} / nullif(${count},0) ;;
    html: {{link}} ;;
  }


########## Repeat Purchase Facts ##########

  dimension: days_until_next_order {
    label: "次回注文までの日数"
    type: number
    view_label: "リピート購入情報"
    sql: TIMESTAMP_DIFF(${created_raw},${repeat_purchase_facts.next_order_raw}, DAY) ;;
  }

  dimension: repeat_orders_within_30d {
    label: "30日以内のリピート有無"
    type: yesno
    view_label: "リピート購入情報"
    sql: ${days_until_next_order} <= 30 ;;
  }

  dimension: repeat_orders_within_15d{
    label: "15日以内のリピート有無"
    type: yesno
    view_label: "リピート購入情報"
    hidden: yes
    sql:  ${days_until_next_order} <= 15;;
  }

  measure: count_with_repeat_purchase_within_30d {
    label: "30日以内のリピート購入件数"
    type: count_distinct
    sql: ${id} ;;
    view_label: "リピート購入情報"

    filters: {
      field: repeat_orders_within_30d
      value: "Yes"
    }
  }

  measure: 30_day_repeat_purchase_rate {
    label: "30日以内のリピート購入率"
    description: "顧客数ベースでリピート購入率を計算"
    view_label: "リピート購入情報"
    type: number
    value_format_name: percent_1
    sql: 1.0 * ${count_with_repeat_purchase_within_30d} / (CASE WHEN ${count} = 0 THEN NULL ELSE ${count} END) ;;
    drill_fields: [products.brand, order_count, count_with_repeat_purchase_within_30d]
  }

########## Dynamic Sales Cohort App ##########

#   filter: cohort_by {
#     type: string
#     hidden: yes
#     suggestions: ["Week", "Month", "Quarter", "Year"]
#   }
#
#   filter: metric {
#     type: string
#     hidden: yes
#     suggestions: ["Order Count", "Gross Margin", "Total Sales", "Unique Users"]
#   }
#
#   dimension_group: first_order_period {
#     type: time
#     timeframes: [date]
#     hidden: yes
#     sql: CAST(DATE_TRUNC({% parameter cohort_by %}, ${user_order_facts.first_order_date}) AS TIMESTAMP)
#       ;;
#   }
#
#   dimension: periods_as_customer {
#     type: number
#     hidden: yes
#     sql: TIMESTAMP_DIFF(${user_order_facts.first_order_date}, ${user_order_facts.latest_order_date}, {% parameter cohort_by %})
#       ;;
#   }
#
#   measure: cohort_values_0 {
#     type: count_distinct
#     hidden: yes
#     sql: CASE WHEN {% parameter metric %} = 'Order Count' THEN ${id}
#         WHEN {% parameter metric %} = 'Unique Users' THEN ${users.id}
#         ELSE null
#       END
#        ;;
#   }
#
#   measure: cohort_values_1 {
#     type: sum
#     hidden: yes
#     sql: CASE WHEN {% parameter metric %} = 'Gross Margin' THEN ${gross_margin}
#         WHEN {% parameter metric %} = 'Total Sales' THEN ${sale_price}
#         ELSE 0
#       END
#        ;;
#   }
#
#   measure: values {
#     type: number
#     hidden: yes
#     sql: ${cohort_values_0} + ${cohort_values_1} ;;
#   }

########## Sets ##########

  set: detail {
    fields: [order_id, status, created_date, sale_price, products.brand, products.item_name, users.portrait, users.name, users.email]
  }
  set: return_detail {
    fields: [id, order_id, status, created_date, returned_date, sale_price, products.brand, products.item_name, users.portrait, users.name, users.email]
  }
}
