//import org.apache.activemq.ActiveMQConnectionFactory
//import org.apache.activemq.command.ActiveMQQueue
//
//static void main(String[] args) {
//    int index = 1;
//    def vms = ["06048":"us06048-ndp2","06024":"us06024-ndp2","06009":"us06009-ndp2","06010":"us06010-ndp2","06011":"us06011-ndp2","06012":"us06012-ndp2","06016":"us06016-ndp2","06017":"us06017-ndp2","06018":"us06018-ndp2","06019":"us06019-ndp2","06020":"us06020-vdp2","06021":"us06021-ndp2","06023":"us06023-ndp2","06025":"us06025-ndp2","06026":"us06026-vdp2","06027":"us06027-vdp2","06031":"us06031-vdp2","06035":"us06035-ndp2","06036":"us06036-vdp2","06037":"us06037-vdp2","06038":"us06038-ndp2","06039":"us06039-vdp2","06040":"us06040-ndp2","06043":"us06043-ndp1","06043":"us06043-ndp1","06043":"us06043-vdp2","06054":"us06054-ndp2","06066":"us06066-vdp2","06068":"us06068-vdp2","06069":"us06069-ndp2","06070":"us06070-vdp2","06080":"us06080-ndp2","06092":"us06092-vdp2","06094":"us06094-ndp1","06094":"us06094-vdp2","07026":"us07026-vdp2","07033":"us07033-ndp2","07035":"us07035-ndp2","07036":"us07036-vdp2","07038":"us07038-ndp2","07039":"us07039-ndp2"]
//
//    vms.forEach((site,v) -> {
//        println "#${index++}-${site}   VM " + v
//        println "sledge connect ${v}\n" +
//                "kubectl get rs -n us-${site} --selector=app=ndof-event-audit-trail\n" +
//                "kubectl scale -n us-${site} deployment ndof-event-audit-trail --replicas=0\n" +
//                "kubectl get rs -n us-${site} --selector=app=ndof-event-audit-trail"
////                distroyQueues(site)
//    })
//}
//
//private static void distroyQueues(site) {
//    def amqURL = "failover:tcp://us${site}s4000d0a.s${site}.us.wal-mart.com:61616"
//    println "Connecting to ActiveMQ at URL " + amqURL
//    def connFactory = new ActiveMQConnectionFactory(amqURL)
//    def conn = connFactory.createConnection()
//    conn.start()
//    conn.destroyDestination(new ActiveMQQueue("Consumer.AUDITTRAIL.VirtualTopic.DELIVERYUPDATES"));
//    conn.destroyDestination(new ActiveMQQueue("Consumer.AUDITTRAIL.VirtualTopic.WMSOF.DELIVERYXDOCKPROCESSED"));
//    conn.destroyDestination(new ActiveMQQueue("Consumer.AUDITTRAIL.VirtualTopic.WMSOF.FM.DELIVERYFULFILLED"));
//    conn.destroyDestination(new ActiveMQQueue("Consumer.AUDITTRAIL.VirtualTopic.WMSOF.FULFILLMENTDELIVERYSTATUS"));
//    conn.destroyDestination(new ActiveMQQueue("Consumer.AUDITTRAIL.VirtualTopic.WMSOF.FULFILLMENTUNITSTATUS"));
//    conn.destroyDestination(new ActiveMQQueue("Consumer.AUDITTRAIL.VirtualTopic.WMSOF.FULFILLMENT"));
//    conn.destroyDestination(new ActiveMQQueue("Consumer.AUDITTRAIL.VirtualTopic.WMSOF.OFFLINEDELIVERYRECEIVED"));
//    conn.destroyDestination(new ActiveMQQueue("Consumer.AUDITTRAIL.VirtualTopic.YMS.To.IDM"));
//    conn.close()
//    println "successfully removed all queues for ${site}"
//}
