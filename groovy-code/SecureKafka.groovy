import org.apache.kafka.clients.consumer.ConsumerConfig
import org.apache.kafka.clients.consumer.KafkaConsumer
import org.apache.kafka.clients.producer.KafkaProducer
import org.apache.kafka.clients.producer.ProducerRecord
import org.apache.kafka.clients.producer.RecordMetadata
import org.apache.kafka.common.header.Headers
import org.apache.kafka.common.header.internals.RecordHeader

import java.time.Duration

import static PropertiesUtil.CONSUMER_DIE_TIME_SEC
import static PropertiesUtil.readEventJsonFile
import static PropertiesUtil.convertToString
import static PropertiesUtil.getRecords
import static PropertiesUtil.loadConfig
import static java.lang.Integer.parseInt

class SecureKafka {

    static void main(String[] args) {
        SecureKafka sk = new SecureKafka()
        if (!args) throw new RuntimeException("please pass proper arguments. for producer -P , for consumer -C")
        loadConfig()
        if ("-P".equalsIgnoreCase(args[0])) {
            sk.publishKafkaMsg()
        } else if ("-C".equalsIgnoreCase(args[0])) {
            if (args.size() < 2) throw new RuntimeException("please pass the topic as 2nd argument and group id 3rd, [ ex: java -jar your_jar.jar -C your_topic group_id(optional) ] ")
            sk.consumerMessage(args[1], (args.size() > 2) ? args[2] : "${args[1]}_groupId")
        }
    }

    private void publishKafkaMsg() {
        def records = getRecords readEventJsonFile()
        boolean hasMoreMsg = hasProceed(records)
        if (hasMoreMsg) records.forEach((record) -> {
            try {
                def producer = new KafkaProducer<String, String>(System.getProperties())
                producer.withCloseable {
                    String topic = record['topic']
                    String key = record['key'] ?: ''
                    String body = convertToString record['body']
                    Map<String, Object> headers = record['headers']

                    println "Producing record: $topic\t $key\t $body\n $headers"
                    def producerRecord = new ProducerRecord<String, String>(topic, key, body)
                    Headers hd = producerRecord.headers();
                    headers.forEach((k, value) -> hd.add(new RecordHeader(k, String.valueOf(value).getBytes())));
                    producer.send producerRecord, { RecordMetadata metadata, Exception e ->
                        if (e) {
                            e.printStackTrace()
                        } else {
                            println "Produced record to topic ${metadata.topic()} partition [${metadata.partition()}] @ offset ${metadata.offset()}\n"
                        }
                    }
                    producer.flush()
                }
            } catch (Exception e) {
                def msg = """
                     -Dssl.truststore.location=/etc/secrets/gls-atlas-fes-api-kafka.nonprod.walmart.com.jks
                     -Dssl.truststore.password=Walmart@1234
                     -Dssl.keystore.location=/etc/secrets/gls-atlas-fes-api-kafka.nonprod.walmart.com.jks
                     -Dssl.keystore.password=Walmart@1234
                     -Dssl.key.password=Walmart@1234
                     -Dbootstrap.servers=''
                     -Dsecurity.protocol=SSL
                """
                println "please check kafka config: Either pass by VM args \t ${msg}\t\t OR file location -Dconfig.additional-location='your_file_location'"
                println e.getMessage()
            }
        })

    }

    private boolean hasProceed(List records) {
        def hasMoreMsg = true;
        if (records.size() > 1) {
            Scanner scn = new Scanner(System.in)
            println "please confirm we you are publishing ${records.size()} events to kafka server, please enter [true/false or t/f] \n othewise please give the specific fileName -Dfilename=yourfile"
            def inp = scn.next()
            hasMoreMsg = 'true'.equalsIgnoreCase(inp) || 't'.equalsIgnoreCase(inp)
        }
        hasMoreMsg
    }

    private void consumerMessage(def topic, def groupId) {
        System.setProperty(ConsumerConfig.GROUP_ID_CONFIG, groupId)
        def consumer = new KafkaConsumer<String, String>(System.getProperties())
        consumer.subscribe([topic] as List<String>)
        def aheadTime = parseInt(System.getProperty(CONSUMER_DIE_TIME_SEC))
        def currentTimeWithNextMin = System.currentTimeSeconds() + aheadTime
        println "start consuming from ${topic} and group ${groupId}, Idle consumer will die in next ${aheadTime} sec"
        consumer.withCloseable {
            while (currentTimeWithNextMin >= System.currentTimeSeconds()) {
                try {
                    def records = consumer.poll Duration.ofMillis(2000)
                    records.forEach(t -> {
                        currentTimeWithNextMin = System.currentTimeSeconds() + aheadTime
                        println "Consumed record with key ${t.key()} and value ${t.value()}\n"
                    })
                } catch (Exception e) {
                    println e.getMessage()
                }
            }
        }
    }

}
