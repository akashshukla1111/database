import groovy.json.JsonBuilder
import groovy.json.JsonSlurper
import org.apache.kafka.clients.consumer.ConsumerConfig
import org.apache.kafka.common.serialization.StringDeserializer
import org.apache.kafka.common.serialization.StringSerializer

import java.nio.file.Files
import java.nio.file.Paths
import java.util.stream.Collectors

import static java.util.Objects.nonNull
import static java.util.Optional.ofNullable
import static org.apache.kafka.clients.consumer.ConsumerConfig.AUTO_OFFSET_RESET_CONFIG
import static org.apache.kafka.clients.consumer.ConsumerConfig.GROUP_ID_CONFIG
import static org.apache.kafka.clients.consumer.ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG
import static org.apache.kafka.clients.consumer.ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG
import static org.apache.kafka.clients.producer.ProducerConfig.ACKS_CONFIG
import static org.apache.kafka.clients.producer.ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG
import static org.apache.kafka.clients.producer.ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG

class PropertiesUtil {


    public static final String CONSUMER_DIE_TIME_SEC = 'consumer.die.time.sec'

    static void loadConfig() {
        def properties = readPropertiesFile()
        properties[ACKS_CONFIG] = properties[ACKS_CONFIG] ?: 'all'
        properties[KEY_SERIALIZER_CLASS_CONFIG] = properties[KEY_SERIALIZER_CLASS_CONFIG] ?: StringSerializer.name
        properties[VALUE_SERIALIZER_CLASS_CONFIG] = properties[VALUE_SERIALIZER_CLASS_CONFIG] ?: StringSerializer.name

        properties[KEY_DESERIALIZER_CLASS_CONFIG] = properties[KEY_DESERIALIZER_CLASS_CONFIG] ?: StringDeserializer.name
        properties[VALUE_DESERIALIZER_CLASS_CONFIG] = properties[VALUE_DESERIALIZER_CLASS_CONFIG] ?: StringDeserializer.name
        properties[AUTO_OFFSET_RESET_CONFIG] = properties[AUTO_OFFSET_RESET_CONFIG] ?: 'latest'
        properties[CONSUMER_DIE_TIME_SEC] = properties[CONSUMER_DIE_TIME_SEC] ?: '300'
        System.setProperties(properties)
    }

    private static def readPropertiesFile(){
        def properties = System.getProperties()
        def propertiesFile = Files.walk(Paths.get(System.getProperty('user.dir')), 1).
                filter(Files::isRegularFile).
                filter(t -> t.toString().endsWith('.properties')).
                collect(Collectors.toList())
        if (propertiesFile) {
            propertiesFile.forEach(p -> p.toFile().withInputStream { properties.load it })
        }
        if (!propertiesFile) {
            def kafkaPropertiesFilePath = getProperty('config.additional-location')
            if (nonNull(kafkaPropertiesFilePath) && Files.exists(Paths.get(kafkaPropertiesFilePath))) {
                new File(kafkaPropertiesFilePath).withInputStream {
                    properties.load it
                }
            } else {
                println "[looking for kafka properties on location ${System.getProperty('user.dir')}  ] \t AND  \t [ looking for kafka properties on location pass by -Dconfig.additional-location ] -->  but non found :("
                println "    ****    please make sure you are passing the properties through VM args  *** "
            }
        }
        properties;
    }

    static def readEventJsonFile() {
        def fileName = ofNullable(getProperty('fileName')).orElse('kafka')
        def propertiesFile = Files.walk(Paths.get(System.getProperty('user.dir')), 4).
                filter(Files::isRegularFile).
                filter(t -> t.last().toString().startsWith(fileName)).
                filter(t -> t.toString().endsWith('.json')).
                collect(Collectors.toList())
        println "user dir path ${System.getProperty('user.dir')}"
        println "events files ${propertiesFile}"
        if (propertiesFile.isEmpty()) {
            def formatString = """
              {"topic":"","headers":{},"body":"json_payload"}
             """
            throw new RuntimeException("please create file with prefix ${fileName}  and create message event json file, File Fromat: " + formatString)
        }
        return propertiesFile;
    }

    static List getRecords(List paths) {
        def jsonSlurper = new JsonSlurper()
        def collect = paths.stream().map(t -> jsonSlurper.parse(t)).collect(Collectors.toList())
        return collect
    }

    static convertToString(def input) {
        return new JsonBuilder(input).toString()
    }

    static String getProperty(String key) {
        return nonNull(System.getenv(key)) ? System.getenv(key) : nonNull(System.getProperty(key)) ? System.getProperty(key) : null
    }
}
