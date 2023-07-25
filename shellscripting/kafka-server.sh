echo 'running zookeeper server'; nohup zookeeper-server-start /opt/homebrew/etc/kafka/zookeeper.properties > zookeeperlog.log &
#echo 'running kafka server'; nohup kafka-server-start /opt/homebrew/etc/kafka/server.properties > kafkaserver.log &

#kafka-topics --create --bootstrap-server localhost:9092 --replication-factor 1 --partitions 1 --topic hawkeye-dev-amr-hvfc-fulfillment-response-status-update
#
#kafka-console-producer --broker-list localhost:9092 --topic hawkeye-dev-amr-hvfc-fulfillment-response-status-update
#
#kafka-console-consumer --bootstrap-server localhost:9092 --topic hawkeye-dev-amr-hvfc-fulfillment-response-status-update --from-beginning

#docker run -it -p 8080:8080 -e DYNAMIC_CONFIG_ENABLED=true provectuslabs/kafka-ui

#kafka-topics --bootstrap-server=localhost:9092 --list


