//import com.mongodb.MongoClient
//import com.mongodb.MongoClientURI
//import com.mongodb.client.MongoDatabase
//import com.mongodb.client.result.DeleteResult
//import org.bson.Document
//
//static void main(String[] args) {
//    println "this is first script"
//    var sites = ["6006","6009","6010","6011","6012","6016","6017","6018","6019","6020","6021","6023","6024","6025","6026","6027","6030","6031","6035","6036","6037","6038","6039","6040","6043","6048","6054","6066","6068","6069","6070","6080","6092","6094","7026","7033","7034","7035","7036","7038","7039","7045"]
////    var sites = ["7034"]
//
//    sites.forEach(site -> {
//        try {
//            def URL = "mongodb://MrMongo:pass123@us0${site}s5900d0a.s0${site}.us.wal-mart.com:25105,us0${site}s5900d0b.s0${site}.us.wal-mart.com:25105,us0${site}s5900d0c.s0${site}.us.wal-mart.com:25105/?authSource=admin&readPreference=primaryPreferred&replicaSet=dc${site}us"
//
//            MongoClientURI uri = new MongoClientURI(URL);
//            MongoClient  mongoClient = new MongoClient(uri);
//            MongoDatabase database = mongoClient.getDatabase("eventaudittrail")
////             database.getCollection("events_log").find(t-> {
////                 println site + "=> " + t.countDocuments()
////             })
//            DeleteResult r= database.getCollection("events_log").deleteMany(new Document());
//            println r.getDeletedCount()
//
//        } catch (Exception e) {
//            println e.getMessage()
//        }
//    })
//}
