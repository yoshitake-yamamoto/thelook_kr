view: products {
  sql_table_name: looker-private-demo.ecomm.products ;;
  view_label: "商品マスタ"
  ### DIMENSIONS ###

  dimension: id {
    label: "商品ID"
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: category {
    label: "カテゴリー"
    sql: TRIM(${TABLE}.category) ;;
    drill_fields: [department, brand, item_name]
  }

  dimension: item_name {
    label: "商品名"
    sql: TRIM(${TABLE}.name) ;;
    drill_fields: [id]
  }

  dimension: brand {
    label: "ブランド"
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
      label: "{{value}} 分析ダッシュボード"
      url: "/dashboards/thelook_jp::brand_lookup?Brand%20Name={{ value | encode_uri }}"
      #url: "/dashboards/IOlEDOPQ12RFCyuUqk38wB?Brand%20Name={{ value | encode_uri }}"
      icon_url: "https://www.seekpng.com/png/full/138-1386046_google-analytics-integration-analytics-icon-blue-png.png"
    }

    action: {
      label: "ブランドプロモーションメールを送信"
      url: "https://desolate-refuge-53336.herokuapp.com/posts"
      icon_url: "https://sendgrid.com/favicon.ico"
      param: {
        name: "some_auth_code"
        value: "abc123456"
      }
      form_param: {
        name: "Subject"
        required: yes
        default: "ラストチャンス! 20% off {{ value }}"
      }
      form_param: {
        name: "Body"
        type: textarea
        required: yes
        default:
        "お客様各位

        平素は格別のご愛顧を賜り、厚く御礼申し上げます。
        今回は、{{ value }}ブランドの全商品を15%割引でご提供いたします。
        次回のお会計時にコード「{{ value | upcase }}-MANIA」を入力してください。
        "
      }
    }
    action: {
      label: "広告キャンペーンを開始"
      url: "https://desolate-refuge-53336.herokuapp.com/posts"
      icon_url: "https://www.google.com/s2/favicons?domain=www.adwords.google.com"
      param: {
        name: "some_auth_code"
        value: "abc123456"
      }
      form_param: {
        type: select
        label: "キャンペーンタイプ"
        name: "Campaign Type"
        option: { name: "Spend" label: "Spend" }
        option: { name: "Leads" label: "Leads" }
        option: { name: "Website Traffic" label: "Website Traffic" }
        required: yes
      }
      form_param: {
        label: "キャンペーン名"
        name: "Campaign Name"
        type: string
        required: yes
        default: "{{ value }} Campaign"
      }

      form_param: {
        label: "商品カテゴリー"
        name: "Product Category"
        type: string
        required: yes
        default: "{{ value }}"
      }

      form_param: {
        label: "予算"
        name: "Budget"
        type: string
        required: yes
      }

      form_param: {
        label: "キーワード"
        name: "Keywords"
        type: string
        required: yes
        default: "{{ value }}"
      }
    }
  }

  dimension: retail_price {
    label: "小売価格"
    type: number
    sql: ${TABLE}.retail_price ;;
    action: {
      label: "更新価格"
      url: "https://us-central1-sandbox-trials.cloudfunctions.net/ecomm_inventory_writeback"
      param: {
        name: "Price"
        value: "24"
      }
      form_param: {
        name: "Discount"
        label: "割引ティア"
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
    label: "メンズ/ウイメンズ"
    sql: TRIM(${TABLE}.department) ;;
  }

  dimension: sku {
    label: "SKU"
    sql: ${TABLE}.sku ;;
  }

  dimension: distribution_center_id {
    label: "配送センターID"
    type: number
    sql: CAST(${TABLE}.distribution_center_id AS INT64) ;;
  }

  ## MEASURES ##

  measure: count {
    label: "商品数"
    type: count
    drill_fields: [detail*]
  }

  measure: brand_count {
    label: "ブランド数"
    type: count_distinct
    sql: ${brand} ;;
    drill_fields: [brand, detail2*, -brand_count] # show the brand, a bunch of counts (see the set below), don't show the brand count, because it will always be 1
  }

  measure: category_count {
    label: "カテゴリー数"
    alias: [category.count]
    type: count_distinct
    sql: ${category} ;;
    drill_fields: [category, detail2*, -category_count] # don't show because it will always be 1
  }

  measure: department_count {
    label: "部署数"
    alias: [department.count]
    type: count_distinct
    sql: ${department} ;;
    drill_fields: [department, detail2*, -department_count] # don't show because it will always be 1
  }

  measure: prefered_categories {
    hidden: yes
    label: "好みのカテゴリー"
    type: list
    list_field: category
    #order_by_field: order_items.count

  }

  measure: prefered_brands {
    hidden: yes
    label: "好みのブランド"
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
