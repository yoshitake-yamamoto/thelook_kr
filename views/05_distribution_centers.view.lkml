view: distribution_centers {
  view_label: "배송센터"
  sql_table_name: looker-private-demo.ecomm.distribution_centers ;;
  dimension: location {
    label: "위치좌표"
    type: location
    sql_latitude: ${TABLE}.latitude ;;
    sql_longitude: ${TABLE}.longitude ;;
  }

  dimension: latitude {
    label: "위도"
    sql: ${TABLE}.latitude ;;
    hidden: yes
  }

  dimension: longitude {
    label: "경도"
    sql: ${TABLE}.longitude ;;
    hidden: yes
  }

  dimension: id {
    label: "ID"
    type: number
    primary_key: yes
    sql: ${TABLE}.id ;;
  }

  dimension: name {
    label: "이름"
    sql: ${TABLE}.name ;;
  }
}
