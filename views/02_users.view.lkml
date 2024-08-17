view: users {
  sql_table_name: looker-private-demo.ecomm.users ;;
  view_label: "고객"
  ## Demographics ##

  dimension: id {
    label: "고객ID"
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
    tags: ["user_id"]
  }

  dimension: first_name {
    label: "이름"
    hidden: yes
    sql: CONCAT(UPPER(SUBSTR(${TABLE}.first_name,1,1)), LOWER(SUBSTR(${TABLE}.first_name,2))) ;;

  }

  dimension: last_name {
    label: "성"
    hidden: yes
    sql: CONCAT(UPPER(SUBSTR(${TABLE}.last_name,1,1)), LOWER(SUBSTR(${TABLE}.last_name,2))) ;;
  }

  dimension: name {
    label: "이름"
    sql: concat(${first_name}, ' ', ${last_name}) ;;
  }

  dimension: age {
    label: "나이"
    type: number
    sql: ${TABLE}.age ;;
  }

  dimension: over_21 {
    label: "21세이상"
    type: yesno
    sql:  ${age} > 21;;
  }

  dimension: age_tier {
    label: "연령대"
    type: tier
    tiers: [0, 10, 20, 30, 40, 50, 60, 70]
    style: integer
    sql: ${age} ;;
  }

  dimension: gender {
    label: "성별"
    sql: ${TABLE}.gender ;;
  }

  dimension: gender_short {
    hidden: yes
    label: "성별（단축）"
    sql: LOWER(SUBSTR(${gender},1,1)) ;;
  }

  dimension: user_image {
    label: "유저이미지"
    sql: ${image_file} ;;
    html: <img src="{{ value }}" width="220" height="220"/>;;
  }

  dimension: email {
    label: "이메일"
    sql: ${TABLE}.email ;;
    tags: ["email"]

    link: {
      label: "유저분석대시보드"

      url: "/dashboards/thelook_jp::customer_lookup?Email={{ value | encode_uri }}"
      icon_url: "https://cdn.icon-icons.com/icons2/2248/PNG/512/monitor_dashboard_icon_136391.png"
    }
    action: {
      label: "홍보이메일작성"
      url: "https://desolate-refuge-53336.herokuapp.com/posts"
      icon_url: "https://sendgrid.com/favicon.ico"
      param: {
        name: "some_auth_code"
        value: "abc123456"
      }
      form_param: {
        name: "Subject"
        required: yes
        default: "{{ users.name._value }}님에게드리는 쇼핑몰10%할인쿠폰혜택!"
      }
      form_param: {
        name: "Body"
        type: textarea
        required: yes
        default:
        "{{ users.first_name._value }}님

        항상 저희 쇼핑몰을 이용해 주셔서 진심으로 감사합니다.
        다음번 쇼핑 시 사용하실 수 있는10%할인 쿠폰을 발급해드립니다.
        쿠폰코드 LOYAL
        결제 시 쿠폰 코드를 입력하시면 할인 혜택을 받으실 수 있습니다.
        감사합니다.

        "
      }
    }
    required_fields: [name, first_name]
  }


  dimension: promo_email {
    label: "AI생성이메일(Action)"
    description: "Use this with the user email if you want to send the email - action"
    action: {
      label: "Generate Email Promotion to Customer"
      url: "https://desolate-refuge-53336.herokuapp.com/posts"
      icon_url: "https://upload.wikimedia.org/wikipedia/commons/thumb/f/f0/Google_Bard_logo.svg/1200px-Google_Bard_logo.svg.png?20230425130013"
      param: {
        name: "some_auth_code"
        value: "abc123456"
      }
      form_param: {
        name: "Subject"
        required: yes
        default: "Thank you {{ users.name._value }}"
      }
      form_param: {
        name: "Body"
        type: textarea
        required: yes
        default:
        "{{ promo_email.generated_text._value }}

        TheLook Team"
      }
    }
    sql: "Generate Promo Email" ;;
    html:
    <div style="
    color: #4285f4;
    background: rgba( 255 , 255 , 255 , 0.25 );
    box-shadow: 0 2px 8px 0 rgba( 31 , 38 , 135 , 0.37 );
    border-radius: 10px;
    border: 1px solid rgba( 255 , 255 , 255 , 0.18 );
    font-weight: 400;
    text-align: center;
    vertical-align: middle;
    cursor: pointer;
    padding: 10px;
    margin: 5px;
    font-size: 1rem;
    line-height: 1.5;
    width: auto;
    font-color: black;
    color: gray;"
    >
    <span><img src='https://upload.wikimedia.org/wikipedia/commons/thumb/f/f0/Google_Bard_logo.svg/1200px-Google_Bard_logo.svg.png?20230425130013' width="80" height="80" alt="Generative AI"/>{{linked_value}}</span>
    </div>;;
  }

  dimension: image_file {
    label: "이미지파일"
    hidden: yes
    sql: concat('https://docs.looker.com/assets/images/',${gender_short},'.jpg') ;;
  }

  ## Demographics ##

  dimension: city {
    label: "시군구"
    sql: ${TABLE}.city ;;
    drill_fields: [zip]
  }

  dimension: state {
    label: "도"
    sql: ${TABLE}.state ;;
    map_layer_name: us_states
    drill_fields: [zip, city]
  }

  dimension: zip {
    label: "우편번호"
    type: zipcode
    sql: ${TABLE}.zip ;;
  }

  dimension: uk_postcode {
    label: "우편번호(영)"
    sql: case when ${TABLE}.country = 'UK' then regexp_replace(${zip}, '[0-9]', '') else null end;;
    map_layer_name: uk_postcode_areas
    drill_fields: [city, zip]
  }

  dimension: country {
    label: "국가"
    map_layer_name: countries
    drill_fields: [state, city]
    sql: CASE WHEN ${TABLE}.country = 'UK' THEN 'United Kingdom'
           ELSE ${TABLE}.country
           END
       ;;
  }

  dimension: location {
    label: "주소"

    type: location
    sql_latitude: ${TABLE}.latitude ;;
    sql_longitude: ${TABLE}.longitude ;;
  }

  dimension: approx_latitude {
    label: "경도"
    type: number
    sql: round(${TABLE}.latitude,1) ;;
  }

  dimension: approx_longitude {
    label: "위도"
    type: number
    sql:round(${TABLE}.longitude,1) ;;
  }

  dimension: approx_location {
    label: "주소좌표(근사)"
    #hidden: yes
    type: location
    drill_fields: [location]
    sql_latitude: ${approx_latitude} ;;
    sql_longitude: ${approx_longitude} ;;
    link: {
      label: "Google Directions from {{ distribution_centers.name._value }}"
      url: "{% if distribution_centers.location._in_query %}https://www.google.com/maps/dir/'{{ distribution_centers.latitude._value }},{{ distribution_centers.longitude._value }}'/'{{ approx_latitude._value }},{{ approx_longitude._value }}'{% endif %}"
      icon_url: "http://www.google.com/s2/favicons?domain=www.google.com"
    }

  }

  ## Other User Information ##

  dimension_group: created {
    label: "등록일"
    type: time
#     timeframes: [time, date, week, month, raw]
    sql: ${TABLE}.created_at ;;
  }

  dimension: history {
    label: "이력"
    sql: ${TABLE}.id ;;
    html: <a href="/explore/thelook_event/order_items?fields=order_items.detail*&f[users.id]={{ value }}">Order History</a>
      ;;
  }

  dimension: traffic_source {
    label: "트래픽소스"
    sql: ${TABLE}.traffic_source ;;
  }

  dimension: ssn {
    label: "SSN"
    # dummy field used in next dim, generate 4 random numbers to be the last 4 digits
    hidden: yes
    type: string
    sql: CONCAT(CAST(FLOOR(10*RAND()) AS INT64),CAST(FLOOR(10*RAND()) AS INT64),
      CAST(FLOOR(10*RAND()) AS INT64),CAST(FLOOR(10*RAND()) AS INT64));;
  }

  dimension: ssn_last_4 {
    label: "주민등록번호(뒷네자리)"
    description: "Only users with sufficient permissions will see this data"
    type: string
    # sql: CASE WHEN '{{_user_attributes["can_see_sensitive_data"]}}' = 'Yes'
    #             THEN ${ssn}
    #             ELSE '####' END;;

    sql: ${ssn} ;;
  }

  ## MEASURES ##

  measure: count {
    label: "인원수"
    type: count
    drill_fields: [detail*]
  }

  measure: count_percent_of_total {
    label: "인원수 전체비율"
    type: percent_of_total
    sql: ${count} ;;
    drill_fields: [detail*]
  }

  measure: average_age {
    label: "평균연령"
    type: average
    value_format_name: decimal_2
    sql: ${age} ;;
    drill_fields: [detail*]
  }

  set: detail {
    fields: [id, name, email, age, created_date, orders.count, order_items.count]
  }
}

# If necessary, uncomment the line below to include explore_source.
# include: "thelook.model.lkml"

# view: first_table {
#   derived_table: {
#     explore_source: order_items {
#       column: order_count {}
#       column: name { field: distribution_centers.name }
#     }
#   }
#   dimension: order_count {
#     label: "주문건수"
#     description: ""
#     type: number
#   }
#   dimension: name {
#     label: "배송센터명"
#     description: ""
#   }
# }
