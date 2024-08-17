view: order_items_share_of_wallet {
  view_label: "구매비중"
  #
  #   - measure: total_sale_price
  #     type: sum
  #     value_format: '$#,###'
  #     sql: ${sale_price}
  #


  ########## Comparison for Share of Wallet ##########

  filter: item_name {
    label: "아이템이름"
    view_label: "구매비중(아이템레벨)"
    suggest_dimension: products.item_name
    suggest_explore: orders_with_share_of_wallet_application
  }

  filter: brand {
    label: "브랜드"
    view_label: "구매비중(브랜드레벨)"
    suggest_dimension: products.brand
    suggest_explore: orders_with_share_of_wallet_application
  }

  dimension: primary_key {
    label: "Primary Key"
    sql: ${order_items.id} ;;
    primary_key: yes
    hidden: yes
  }

  dimension: item_comparison {
    label: "아이템비교"
    view_label: "구매비중 (아이템레벨)"
    description: "선택한 항목을 브랜드의 다른 항목과 비교하고 다른 모든 브랜드와 비교합니다"
    sql: CASE
      WHEN {% condition item_name %} rtrim(ltrim(products.item_name)) {% endcondition %}
      THEN concat('(1) ',${products.item_name})
      WHEN  {% condition brand %} rtrim(ltrim(products.brand)) {% endcondition %}
      THEN concat('(2) Rest of ', ${products.brand})
      ELSE '(3) Rest of Population'
      END
       ;;
  }

  dimension: brand_comparison {
    label: "브랜드비교"
    view_label: "구매비중 (브랜드레벨)"
    description: "선택한 브랜드와 다른 모든 브랜드를 비교"
    sql: CASE
      WHEN  {% condition brand %} rtrim(ltrim(products.brand)) {% endcondition %}
      THEN concat('(1) ',${products.brand})
      ELSE '(2) Rest of Population'
      END
       ;;
  }

  measure: total_sale_price_this_item {
    label: "이 항목의 총 판매 가격"
    view_label: "구매비중(아이템레벨)"
    type: sum
    hidden: yes
    sql: ${order_items.sale_price} ;;
    value_format_name: usd

    filters: {
      field: order_items_share_of_wallet.item_comparison
      value: "(1)%"
    }
  }

  measure: total_sale_price_this_brand {
    label: "해당 브랜드 총 매출"
    view_label: "Share of Wallet (Item Level)"
    type: sum
    hidden: yes
    value_format_name: usd
    sql: ${order_items.sale_price} ;;

    filters: {
      field: order_items_share_of_wallet.item_comparison
      value: "(2)%,(1)%"
    }
  }

  measure: total_sale_price_brand_v2 {
    view_label: "구매비중(브랜드레벨)"
    label: "총매출-해당브랜드"
    type: sum
    value_format_name: usd
    sql: ${order_items.sale_price} ;;

    filters: {
      field: order_items_share_of_wallet.brand_comparison
      value: "(1)%"
    }
  }

  measure: item_share_of_wallet_within_brand {
    view_label: "구매비중(아이템레벨)"
    type: number
    description: "This item sales over all sales for same brand"
    #     view_label: 'Share of Wallet'
    value_format_name: percent_2
    sql: ${total_sale_price_this_item}*1.0 / nullif(${total_sale_price_this_brand},0) ;;
  }

  measure: item_share_of_wallet_within_company {
    view_label: "구매비중(아이템레벨)"
    description: "This item sales over all sales across website"
    value_format_name: percent_2
    #     view_label: 'Share of Wallet'
    type: number
    sql: ${total_sale_price_this_item}*1.0 / nullif(${order_items.total_sale_price},0) ;;
  }

  measure: brand_share_of_wallet_within_company {
    label: "해당 브랜드 매출 점유율"
    view_label: "Share of Wallet (Brand Level)"
    description: "This brand's sales over all sales across website"
    value_format_name: percent_2
    #     view_label: 'Share of Wallet'
    type: number
    sql: ${total_sale_price_brand_v2}*1.0 / nullif(${order_items.total_sale_price},0) ;;
  }
}
