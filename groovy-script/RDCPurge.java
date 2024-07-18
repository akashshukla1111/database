//import java.sql.*;
//import java.util.*;
//import java.util.concurrent.Callable;
//import java.util.concurrent.ExecutorService;
//import java.util.concurrent.Executors;
//import java.util.concurrent.Future;
//import java.util.stream.Collectors;
//
//class ConfigurationDB {
//
//    public static String URL = "jdbc:informix-sqli://dsinfmx.s0%site%.us.wal-mart.com:23300/order_track:INFORMIXSERVER=dsinfmx;IFX_LOCK_MODE_WAIT=2";
//    public static String PWD = "z00keep";
//    public static String USER = "dcregdev";
//
//
//    public static int batch_size = 5000;
//    public static int retentionInDays = 700;
//
//    public static String PURGE_IDs_TO_TEMP = "SELECT enrich_order_reference_id FROM enrich_order_reference WHERE order_prcsg_ts < (CURRENT - " + retentionInDays + " UNITS DAY) INTO TEMP TEMP_TABLE";
//    public static String SELECT_IDs_ENRICH_TABLE = "SELECT count(enrich_order_reference_id) count FROM enrich_order_reference WHERE order_prcsg_ts < (CURRENT - " + retentionInDays + " UNITS DAY)";
//    public static String PURGE_IDs_TO_COUNT = "select COUNT(*) as count from TEMP_TABLE";
//    public static String DELETE_FROM_TABLE = "DELETE FROM enrich_order_reference WHERE enrich_order_reference_id in (select * from (select first " + batch_size + " *  from TEMP_TABLE))";
//    public static String DELETE_FROM_TEMP = "delete from TEMP_TABLE WHERE enrich_order_reference_id in (select * from (select first " + batch_size + " *  from TEMP_TABLE))";
//    public static String DELETE_TEMP = "DROP TABLE TEMP_TABLE;";
//
//    public static List<String> sites = Arrays.asList("6031");
//    public static List<String> RDCs = Arrays.asList("6006", "6009", "6010", "6011", "6012", "6016", "6017", "6018", "6019", "6020", "6021", "6023", "6024", "6025", "6026", "6027", "6030", "6031", "6035", "6036", "6037", "6038", "6039", "6040", "6043", "6048", "6054", "6066", "6068", "6069", "6070", "6080", "6092", "6094", "7026", "7033", "7034", "7035", "7036", "7038", "7039", "7045");
//
//}
//
//class InformixDbQuery {
//
//    private static Map<String, Connection> connectionMap = new HashMap<>();
//    ExecutorService executor = Executors.newFixedThreadPool(42);
//    public List<Map<String, Object>> result = new ArrayList<>();
//
//    public static void main(String[] args) throws Exception {
//        InformixDbQuery informixDbQuery = new InformixDbQuery();
//        ConfigurationDB.retentionInDays = args.length > 0 ? Math.max(Integer.parseInt(args[0]), ConfigurationDB.retentionInDays) : ConfigurationDB.retentionInDays;
//        ConfigurationDB.sites = args.length > 1 ? Arrays.asList(args[1].split(",")) : ConfigurationDB.sites;
//        ConfigurationDB.sites = ConfigurationDB.sites.stream().filter(s -> ConfigurationDB.RDCs.contains(s)).map(String::trim).collect(Collectors.toList());
//        boolean deleteFlag = args.length > 2 && ("DEL".equalsIgnoreCase(args[2]));
//        if (ConfigurationDB.sites.size() > 0) {
//            if (deleteFlag) {
//                System.out.println("calling purge script for retentionInDays " + ConfigurationDB.retentionInDays + " for RDCs => " + ConfigurationDB.sites);
//                informixDbQuery.jobToPrugeData();
//            }
//            System.out.println("calling get script for retentionInDays " + ConfigurationDB.retentionInDays + " for all the RDCs => " + ConfigurationDB.sites);
//            informixDbQuery.jobToSelectData();
//        } else {
//            System.out.println("Not RDC sites");
//        }
//        informixDbQuery.closeExecutor();
//    }
//
//    private void closeExecutor() {
//        executor.shutdown();
//    }
//
//
//    private void jobToSelectData() throws Exception {
//        List<Callable<Map<String, List<Map<String, Object>>>>> callables = new ArrayList<>();
//        for (String site : ConfigurationDB.sites) {
//            checkForLocalDb(site);
//            createConnection(site);
//            Callable<Map<String, List<Map<String, Object>>>> tempTable = () -> readQuery(site, ConfigurationDB.SELECT_IDs_ENRICH_TABLE);
//            callables.add(tempTable);
//        }
//        List<Future<Map<String, List<Map<String, Object>>>>> futures = executor.invokeAll(callables);
//        for (Future<Map<String, List<Map<String, Object>>>> future : futures) {
//            long startTime = System.currentTimeMillis();
//            Map<String, List<Map<String, Object>>> stringListMap = future.get();
//            stringListMap.forEach((k, v) -> {
//                System.out.println(k + " ==> " + v.get(0).get("count"));
//            });
//            System.out.println(stringListMap.keySet().stream().findFirst().orElse("") + " site has teken select execution Sec " + (System.currentTimeMillis() - startTime)/(1000.00));
//        }
//    }
//
//    private void jobToPrugeData() throws Exception {
//        if (ConfigurationDB.retentionInDays < 60) {
//            System.out.println("We can only delete more than 90 days old data for RDCs (ex: retentionInDays=90)");
//            return;
//        }
//        List<Callable<Map<String, Integer>>> callables = new ArrayList<>();
//        for (String site : ConfigurationDB.sites) {
//            checkForLocalDb(site);
//            createConnection(site);
//            writeQuery(site, ConfigurationDB.DELETE_TEMP);
//            Callable<Map<String, Integer>> tempTable = () -> writeQuery(site, ConfigurationDB.PURGE_IDs_TO_TEMP);
//            callables.add(tempTable);
//        }
//        List<Future<Map<String, Integer>>> futures = executor.invokeAll(callables);
//
//        for (Future<Map<String, Integer>> future : futures) {
//            try {
//                executor.submit(() -> {
//                    try {
//                        long startTime = System.currentTimeMillis();
//                        Map<String, Integer> stringIntegerMap = future.get();
//                        stringIntegerMap.forEach((sit, updateRow) -> {
//                            readQuery(sit, ConfigurationDB.PURGE_IDs_TO_COUNT).forEach((si, rows) -> {
//                                Integer size = Integer.parseInt(rows.get(0).get("count").toString());
//                                for (int i = 0; i <= size / ConfigurationDB.batch_size; i++) {
//                                    writeQuery(sit, ConfigurationDB.DELETE_FROM_TABLE);
//                                    System.out.println("successfully deleted " + i + " - " + ConfigurationDB.batch_size);
//                                    writeQuery(sit, ConfigurationDB.DELETE_FROM_TEMP);
//                                }
//                                writeQuery(sit, ConfigurationDB.DELETE_TEMP);
//                            });
//                        });
//                        System.out.println(stringIntegerMap.keySet().stream().findFirst().orElse("") + " site has teken delete data Sec " + (System.currentTimeMillis() - startTime)/(1000.00));
//                    } catch (Exception e) {
//                        e.printStackTrace();
//                    }
//
//                });
//            }
//            catch (Exception e) {
//            }
//        }
//    }
//
//    private Map<String, List<Map<String, Object>>> readQuery(String site, String SQL) {
//        try {
////            System.out.println("start creating STATEMENT for site " + site);
//            Statement stmt = connectionMap.get(site).createStatement();
//            ResultSet resultSet = stmt.executeQuery(SQL);
//            List<Map<String, Object>> rows = resultSetToArrayList(resultSet);
//            Map<String, List<Map<String, Object>>> rowsWithSite = new HashMap<>();
//            rowsWithSite.put(site, rows);
//            stmt.close();
//            return rowsWithSite;
//        } catch (Exception e) {
//            System.out.println(e.getMessage());
//            return new HashMap<>();
//        }
//    }
//
//    private Map<String, Integer> writeQuery(String site, String SQL) {
//        Map<String, Integer> updateRows = new HashMap<>();
//        updateRows.put(site, 0);
////        System.out.println("start creating STATEMENT for site " + site);
//        try {
//            Statement stmt = connectionMap.get(site).createStatement();
//            updateRows.put(site, stmt.executeUpdate(SQL));
//            stmt.close();
//        } catch (SQLException e) {
//            System.out.println(e.getMessage());
//        }
//        return updateRows;
//    }
//
//    private void checkForLocalDb(String site) {
//        if (Objects.isNull(site) || site.contains("localhost")) {
//            ConfigurationDB.URL = "jdbc:informix-sqli://localhost:9088/order_track:INFORMIXSERVER=informix";
//            ConfigurationDB.USER = "informix";
//            ConfigurationDB.PWD = "in4mix";
//        }
//    }
//
//
//    private static void createConnection(String site) throws Exception {
//        Connection connection = connectionMap.get(site);
//        if (Objects.isNull(connection)) {
//            Class.forName("com.informix.jdbc.IfxDriver");
//            DriverManager.registerDriver((com.informix.jdbc.IfxDriver) Class.forName("com.informix.jdbc.IfxDriver").newInstance());
//            String url = ConfigurationDB.URL.replace("%site%", site);
//            connection = DriverManager.getConnection(url, ConfigurationDB.USER, ConfigurationDB.PWD);
//            System.out.println("Connection Successful for site " + site);
//            connectionMap.put(site, connection);
//        }
//    }
//
//    public static List<Map<String, Object>> resultSetToArrayList(ResultSet rs) throws SQLException {
//        ResultSetMetaData md = rs.getMetaData();
//        int columns = md.getColumnCount();
//        List<Map<String, Object>> list = new ArrayList(50);
//        while (rs.next()) {
//            Map<String, Object> row = new HashMap(columns);
//            for (int i = 1; i <= columns; ++i) {
//                row.put(md.getColumnName(i), rs.getObject(i));
//            }
//            list.add(row);
//        }
//        return list;
//    }
//}