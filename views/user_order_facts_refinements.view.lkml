include: "12_user_order_facts.view"
include: "01_order_items.view"

view: +user_order_facts {

  dimension: currently_active_customer {
    label: "활성 사용자 여부"
    type: yesno
    sql: ${latest_order_date} >= DATE_ADD(CURRENT_DATE, INTERVAL -30 DAY) ;;
  }

  measure: active_user_count {
    label: "활성 사용자 수"
    type: sum
    filters: [lifetime_orders: "< 2", first_order_date: "before 30 days ago"]
    sql: ${user_id} ;;
  }


}

# view: +order_items {



# }



# dimension: repeat_customer {
#   description: "Lifetime Count of Orders > 1"
#   type: yesno
#   sql: ${lifetime_orders} > 1 ;;
# }
