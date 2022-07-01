import groovy.sql.Sql

class Properties {
    static var OT_DB = ['jdbc:sqlserver://azrilbglsotdr.cloud.wal-mart.com:14482;database=order_tracker', 'glsot', 'NHc>34GwK']
    static var OP_DB = ['jdbc:sqlserver://azrilbGLSOprod1.cloud.wal-mart.com:14482;database=order_alloc', 'glsop', 'NHc>34GwK']
    static var FES_DB = ['jdbc:sqlserver://atlas-of-prod-5f531ccf-failover-group.secondary.database.windows.net:1433;database=NDOF_TRIP_EXEC', 'ofpbylprod', 'bvZZYe"1Q%U^']


    static String OT_SQL = """select pick_id,
       CASE
           WHEN order_track_status_desc = 'ASSIGNED' THEN 'PLANNED'
           WHEN order_track_status_desc = 'LOADED' THEN 'PACKED'
           WHEN order_track_status_desc = 'SHIPPED' THEN 'PACKED'
           else order_track_status_desc END
from order_pick_reference
where estimated_ship_date > '2021-10-25 05:00:00.000' and estimated_ship_date < '2021-10-26 04:59:59.000'
  and facility_nbr = 4034
  and facility_cntry_code = 'US'
"""

    static String OP_SQL = """select pick_id,
       CASE
           WHEN pick_status_code = 2 THEN 'ATR'
           WHEN pick_status_code = 8 THEN 'ATP' END
from fulfillment_pick where expected_ship_date > '2021-10-25 05:00:00.0000000' and expected_ship_date < '2021-10-26 04:59:59.0000000' and pick_status_code in (2, 8)
  AND facility_nbr = 4034
  and facility_cntry_code = 'US'
"""

    static String FES_SQL = """select pick_id, pick_status
from pick
where ESTIMATED_SHIPPING_TS > '2021-10-22 00:00:00.0000000' and ESTIMATED_SHIPPING_TS < '2021-10-26 23:59:00.0000000' and pick_status in ('PLANNED', 'PICKED', 'PACKED')
  and facility_num = 4034
  and facility_country_code = 'US'
"""
}

static void main(String[] args) {
    Map resultot = getSQL(Properties.OT_DB, Properties.OT_SQL)
    Map result = getSQL(Properties.OP_DB, Properties.OP_SQL)
//    Map result = getOTSQL(Properties.FES_DB,Properties.FES_SQL)
    Map out = [:]
    List list = []
    resultot.forEach((k, v) -> {
        if (result.containsKey(k) && result.get(k) != resultot.get(k)) {
            out.put(k, [resultot.get(k), result.get(k), result.get(k) == resultot.get(k)])
        }
    })

    result.forEach((k, v) -> {
        if (!resultot.containsKey(k)) {
            list.add(k)
        }
    })
    println 'picks status check'
    println out
    println 'picks only present in Other system(OP/FES)'
    println list

}

static Map getSQL(var propInput, String sqlQ) {
    def sql = Sql.newInstance(propInput[0], propInput[1], propInput[2], 'com.microsoft.sqlserver.jdbc.SQLServerDriver')
    Map<String, Object> result = [:]
    sql.eachRow(sqlQ) { row ->
        result.put(row[0], row[1])
    }
    sql.close()
    return result
}
