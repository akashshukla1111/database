import groovy.sql.Sql

static void main(String[] args) {
    def sql = Sql.newInstance('jdbc:informix-sqli://localhost:9088/order_track:INFORMIXSERVER=informix',
            'informix', 'in4mix', 'com.informix.jdbc.IfxDriver')

    sql.eachRow("SELECT * FROM systables where tabname='enrich_order_reference'", {
        println it
    })
    sql.close()
}




