view: distribution_centers {
  view_label: "配送センター"
  sql_table_name: looker-private-demo.ecomm.distribution_centers ;;
  dimension: location {
    label: "位置座標"
    type: location
    sql_latitude: ${TABLE}.latitude ;;
    sql_longitude: ${TABLE}.longitude ;;
  }

  dimension: latitude {
    label: "緯度"
    sql: ${TABLE}.latitude ;;
    hidden: yes
  }

  dimension: longitude {
    label: "経度"
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
    label: ""
    sql: ${TABLE}.name ;;
  }
}
