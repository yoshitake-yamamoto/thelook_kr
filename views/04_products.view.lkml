view: products {
  sql_table_name: looker-private-demo.ecomm.products ;;
  view_label: "상품 마스터"
  ### DIMENSIONS ###

  dimension: id {
    label: "상품ID"
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: category {
    label: "카테고리"
    sql: TRIM(${TABLE}.category) ;;
    drill_fields: [department, brand, item_name]
  }

  dimension: item_name {
    label: "상품명"
    sql: TRIM(${TABLE}.name) ;;
    drill_fields: [id]
  }

  dimension: brand {
    label: "브랜드"
    sql: TRIM(${TABLE}.brand) ;;
    drill_fields: [item_name]
    link: {
      label: "Website"
      url: "http://www.google.com/search?q={{ value | encode_uri }}+clothes&btnI"
      icon_url: "http://www.google.com/s2/favicons?domain=www.{{ value | encode_uri }}.com"
    }
    link: {
      label: "Facebook"
      url: "http://www.google.com/search?q=site:facebook.com+{{ value | encode_uri }}+clothes&btnI"
      icon_url: "https://upload.wikimedia.org/wikipedia/commons/c/c2/F_icon.svg"
    }
    link: {
      label: "{{value}}  분석 대시보드"
      url: "/dashboards/thelook_jp::brand_lookup?Brand%20Name={{ value | encode_uri }}"
      #url: "/dashboards/IOlEDOPQ12RFCyuUqk38wB?Brand%20Name={{ value | encode_uri }}"
      icon_url: "https://www.seekpng.com/png/full/138-1386046_google-analytics-integration-analytics-icon-blue-png.png"
    }

    action: {
      label: "브랜드 프로모션 메일 발송"
      url: "https://desolate-refuge-53336.herokuapp.com/posts"
      icon_url: "https://sendgrid.com/favicon.ico"
      param: {
        name: "some_auth_code"
        value: "abc123456"
      }
      form_param: {
        name: "Subject"
        required: yes
        default: "마지막 기회! 20% off {{ value }}"
      }
      form_param: {
        name: "Body"
        type: textarea
        required: yes
        default:
        "고객 여러분

        평소 특별한 애정을 보내주셔서 진심으로 감사드립니다.。
        고객님께 {{ value }}브랜드의 모든 상품을 15% 할인된 가격으로 제공해 드립니다.
        다음 결제 시 코드「{{ value | upcase }}-MANIA」를 입력해 주세요.
        "
      }
    }
    action: {
      label: "광고 캠페인 시작"
      url: "https://desolate-refuge-53336.herokuapp.com/posts"
      icon_url: "https://www.google.com/s2/favicons?domain=www.adwords.google.com"
      param: {
        name: "some_auth_code"
        value: "abc123456"
      }
      form_param: {
        type: select
        label: "캠페인 유형"
        name: "Campaign Type"
        option: { name: "Spend" label: "Spend" }
        option: { name: "Leads" label: "Leads" }
        option: { name: "Website Traffic" label: "Website Traffic" }
        required: yes
      }
      form_param: {
        label: "캠페인명"
        name: "Campaign Name"
        type: string
        required: yes
        default: "{{ value }} Campaign"
      }

      form_param: {
        label: "상품 카테고리"
        name: "Product Category"
        type: string
        required: yes
        default: "{{ value }}"
      }

      form_param: {
        label: "예산"
        name: "Budget"
        type: string
        required: yes
      }

      form_param: {
        label: "키워드"
        name: "Keywords"
        type: string
        required: yes
        default: "{{ value }}"
      }
    }
  }

  dimension: retail_price {
    label: "소매 가격"
    type: number
    sql: ${TABLE}.retail_price ;;
    action: {
      label: "가격 업데이트"
      url: "https://us-central1-sandbox-trials.cloudfunctions.net/ecomm_inventory_writeback"
      param: {
        name: "Price"
        value: "24"
      }
      form_param: {
        name: "Discount"
        label: "할인 티어"
        type: select
        option: {
          name: "5% off"
        }
        option: {
          name: "10% off"
        }
        option: {
          name: "20% off"
        }
        option: {
          name: "30% off"
        }
        option: {
          name: "40% off"
        }
        option: {
          name: "50% off"
        }
        default: "20% off"
      }
      param: {
        name: "retail_price"
        value: "{{ retail_price._value }}"
      }
      param: {
        name: "inventory_item_id"
        value: "{{ inventory_items.id._value }}"
      }
      param: {
        name: "product_id"
        value: "{{ id._value }}"
      }
      param: {
        name: "security_key"
        value: "googledemo"
      }
    }
  }

  dimension: department {
    label: "남성/여성"
    sql: TRIM(${TABLE}.department) ;;
  }

  dimension: sku {
    label: "SKU"
    sql: ${TABLE}.sku ;;
  }

  dimension: distribution_center_id {
    label: "배송 센터ID"
    type: number
    sql: CAST(${TABLE}.distribution_center_id AS INT64) ;;
  }

  ## MEASURES ##

  measure: count {
    label: "상품수"
    type: count
    drill_fields: [detail*]
  }

  measure: brand_count {
    label: "브랜드수"
    type: count_distinct
    sql: ${brand} ;;
    drill_fields: [brand, detail2*, -brand_count] # show the brand, a bunch of counts (see the set below), don't show the brand count, because it will always be 1
  }

  measure: category_count {
    label: "카테고리수"
    alias: [category.count]
    type: count_distinct
    sql: ${category} ;;
    drill_fields: [category, detail2*, -category_count] # don't show because it will always be 1
  }

  measure: department_count {
    label: "부서수"
    alias: [department.count]
    type: count_distinct
    sql: ${department} ;;
    drill_fields: [department, detail2*, -department_count] # don't show because it will always be 1
  }

  measure: prefered_categories {
    hidden: yes
    label: "선호카테고리"
    type: list
    list_field: category
    #order_by_field: order_items.count

  }

  measure: prefered_brands {
    hidden: yes
    label: "선호브랜드"
    type: list
    list_field: brand
    #order_by_field: count
  }

  set: detail {
    fields: [id, item_name, brand, category, department, retail_price, customers.count, orders.count, order_items.count, inventory_items.count]
  }

  set: detail2 {
    fields: [category_count, brand_count, department_count, count, customers.count, orders.count, order_items.count, inventory_items.count, products.count]
  }
}
