msgfile='/Users/a0s01hy/work/of/database/shellscripting/msg/void.json'
#FMS_OT_BROKER='kafka-498637915-1-1282813190.scus.kafka-atlas-uwms-stg.ms-df-messaging.prod.us.walmart.net:9092,kafka-498637915-2-1282813193.scus.kafka-atlas-uwms-stg.ms-df-messaging.prod.us.walmart.net:9092,kafka-498637915-3-1282813196.scus.kafka-atlas-uwms-stg.ms-df-messaging.prod.us.walmart.net:9092'
#PUBLISHER_BROKER='kafka-498637915-1-1282813190.scus.kafka-atlas-uwms-stg.ms-df-messaging.prod.us.walmart.net:9092,kafka-498637915-2-1282813193.scus.kafka-atlas-uwms-stg.ms-df-messaging.prod.us.walmart.net:9092,kafka-498637915-3-1282813196.scus.kafka-atlas-uwms-stg.ms-df-messaging.prod.us.walmart.net:9092'
#PROD_ATLAS_BROKER='kafka-420262885-4-988143933.prod-southcentralus-az.kafka-atlas-prod.ms-df-messaging.prod-az-southcentralus-2.prod.us.walmart.net:9092,kafka-420262885-5-988143940.prod-southcentralus-az.kafka-atlas-prod.ms-df-messaging.prod-az-southcentralus-2.prod.us.walmart.net:9092,kafka-420262885-2-988143922.prod-southcentralus-az.kafka-atlas-prod.ms-df-messaging.prod-az-southcentralus-2.prod.us.walmart.net:9092,kafka-420262885-3-988143927.prod-southcentralus-az.kafka-atlas-prod.ms-df-messaging.prod-az-southcentralus-2.prod.us.walmart.net:9092,kafka-420262885-1-988143917.prod-southcentralus-az.kafka-atlas-prod.ms-df-messaging.prod-az-southcentralus-2.prod.us.walmart.net:9092,kafka-420262885-6-988143945.prod-southcentralus-az.kafka-atlas-prod.ms-df-messaging.prod-az-southcentralus-2.prod.us.walmart.net:9092'
#PUBLISHER_BROKER='kafka-420262885-4-988143933.prod-southcentralus-az.kafka-atlas-prod.ms-df-messaging.prod-az-southcentralus-2.prod.us.walmart.net:9092,kafka-420262885-5-988143940.prod-southcentralus-az.kafka-atlas-prod.ms-df-messaging.prod-az-southcentralus-2.prod.us.walmart.net:9092,kafka-420262885-2-988143922.prod-southcentralus-az.kafka-atlas-prod.ms-df-messaging.prod-az-southcentralus-2.prod.us.walmart.net:9092,kafka-420262885-3-988143927.prod-southcentralus-az.kafka-atlas-prod.ms-df-messaging.prod-az-southcentralus-2.prod.us.walmart.net:9092,kafka-420262885-1-988143917.prod-southcentralus-az.kafka-atlas-prod.ms-df-messaging.prod-az-southcentralus-2.prod.us.walmart.net:9092,kafka-420262885-6-988143945.prod-southcentralus-az.kafka-atlas-prod.ms-df-messaging.prod-az-southcentralus-2.prod.us.walmart.net:9092'
PUBLISHER_BROKER='localhost:9092'
#PUBLISHER_BROKER='kafka-1052450285-1-1269647919.scus.kafka-v2-atlas-scus-wus-prod.ms-df-messaging.prod-az-southcentralus-25.prod.us.walmart.net:9093,kafka-1052450285-2-1269647922.scus.kafka-v2-atlas-scus-wus-prod.ms-df-messaging.prod-az-southcentralus-25.prod.us.walmart.net:9093,kafka-1052450285-3-1269647925.scus.kafka-v2-atlas-scus-wus-prod.ms-df-messaging.prod-az-southcentralus-25.prod.us.walmart.net:9093,kafka-1052450285-4-1269647928.scus.kafka-v2-atlas-scus-wus-prod.ms-df-messaging.prod-az-southcentralus-25.prod.us.walmart.net:9093,kafka-1052450285-5-1269647931.scus.kafka-v2-atlas-scus-wus-prod.ms-df-messaging.prod-az-southcentralus-25.prod.us.walmart.net:9093,kafka-1052450285-6-1269647934.scus.kafka-v2-atlas-scus-wus-prod.ms-df-messaging.prod-az-southcentralus-25.prod.us.walmart.net:9093'
#PUBLISHER_BROKER='kafka-1301504412-1-1334708561.scus.kafka-v2-atlas-secured-stg.ms-df-messaging.stg-az-southcentralus-10.prod.us.walmart.net:9093,kafka-1301504412-2-1334708564.scus.kafka-v2-atlas-secured-stg.ms-df-messaging.stg-az-southcentralus-10.prod.us.walmart.net:9093,kafka-1301504412-3-1334708567.scus.kafka-v2-atlas-secured-stg.ms-df-messaging.stg-az-southcentralus-10.prod.us.walmart.net:9093'

OP_TO_FES(){
   echo `cat $msgfile`
    kafkacat -b $PUBLISHER_BROKER -H facilityNum=4034 -H facilityCountryCode=US  -H userId=akashshukla -t hawkeye-dev-rdc-putaway-response -P $msgfile
    echo "message sent"
}

OT_TO_FMS_ECOM_ACK() {
  echo `cat $msgfile`
  echo $PUBLISHER_BROKER
  jq -c '.[]' msgfile | while read i; do
      echo $i
  done
#  kafkacat -b $PUBLISHER_BROKER -H facilityNum=4034 -H facilityCountryCode=US -t ATLAS_WMSOP_FMS_ORDERS_ACK_PROD -P $msgfile
#  echo "message sent"
}


FES_TO_OT_PICKING() {
  echo $msgfile
  kafkacat -b $PUBLISHER_BROKER -H facilityNum=4034 -H dcNumber=4034 -H countryCode=US -H facilityCountryCode=US -t yms2-gate-out -P $msgfile
  echo "message sent"
}

FES_TO_ACL() {
  echo $msgfile
  echo $$PUBLISHER_BROKER
  kafkacat -b $PUBLISHER_BROKER -H facilityNum=4034 -H facilityCountryCode=US -H eventId=testingeventId -t hawkeye-dev-egm-label-verification-response -P $msgfile
  echo "message sent"
}

YMS_TO_OT_LOADING() {
  echo `cat $msgfile`
  kafkacat -b $PUBLISHER_BROKER  -H facilityNum=4034 -H facilityCountryCode=US  -H userId=akashshukla -t watcher-loading-package-event-p3 -P $msgfile
  echo "message sent"
}

YMS_TO_OT_GATEOUT() {
  echo $msgfile
  kafkacat -b $PUBLISHER_BROKER -H facilityNum=4034 -H facilityCountryCode=US -H WMT_EventType=GATE_OUT_TEST_6 -H dcNumber=4034 -H countryCode=US -t yms2-gate-out -P $msgfile
}

FES_TO_WATCHER_SORTER() {
  echo $msgfile
  kafkacat -b $PUBLISHER_BROKER -H site_name= -H WMT_CorrelationId=a660bff7-3788-404b-ab45-1e8344461248 -H dc_number=4034 -H country=US -H event_id=eca57b43-059b-485d-92b1-3b1b8e87bbe0 -H schema_id= -H event_name=shipping_label_generation -H producer_id= -H facilityCountryCode=US -H bu_type=MCC -H facilityNum=4034 -H timestamp=1629818382536 -t ATLAS_FC_OF_YMS_SHIPLABELGENERATION_STG -P $msgfile
  echo "message sent"
}

FES_TO_INVENTORY_MSG() {
  echo $msgfile
  kafkacat -b $PUBLISHER_BROKER -H facilityNum=4034 -H facilityCountryCode=US -H WMT_CorrelationId=testak22 -H WMT_EventType=PickTransferredToConsolidation -H WMT_IdempotencyKey=test-b18-753f-4ae7-91bb-4b4a6643077fPW001B011 -t ATLAS_FC_OF_INVENTORYUPDATE_QA -P $msgfile
  echo "message sent"
}

kafkaProducer-dev() {
  echo $msgfile
  kafkacat -b $PUBLISHER_BROKER -H facilityNum=4034 -H facilityCountryCode=US -H WMT_EventType=InvAdjusted -H WMT_IdempotencyKey=pickid-1-InvAdjusted -t ATLAS_FC_OF_INVENTORYUPDATE_QA -P $msgfile
  echo "message sent"
}

kafkaConsumer() {
  echo $msgfile
  kafkacat -b $PUBLISHER_BROKER -t CSII_NGOF_FULFILLMENTEVENT_DEV -C
}

createKafkaTopic() {
  kafka-topics --create --topic ATLAS_FC_OF_HAWKEYE_ACL_4034_DEV --bootstrap-server $PUBLISHER_BROKER
}

prod_OF_publish() {
  echo `cat $msgfile`
      kafkacat -P -b $PUBLISHER_BROKER -H eventType=FULFILLMENT_UPDATE -H WMT_UserId=h0s07ef -H WMT_EventTs=2022-04-14 00:05:37.343 -H WMT_CorrelationId=test3e2e-500a-470c-b61e-54bcd264ba43 -H facilityNum=4034 -H facilityCountryCode=US -t GLS_ATLAS_WMSOF_FULFILLMENT_PROD $msgfile
      echo "message sent"
}

#kafka-consumer-groups --bootstrap-server localhost:9092 --describe --group dev-ot-group --state


nonpord_OP(){
  echo $PUBLISHER_BROKER
  echo `cat $msgfile` |  kafkacat -P -b $PUBLISHER_BROKER -H eventType='FULFILLMENT_UPDATE' -H WMT_UserId='h0s07ef' -H WMT_EventTs='2022-04-14 00:05:37.343' -H WMT_CorrelationId='test3e2e-500a-470c-b61e-54bcd264ba43' -H facilityNum=4034 -H facilityCountryCode=US -t gls_atlas_wmsof_fulfillment_qa -X "security.protocol=SSL" -X "ssl.keystore.location=/etc/secrets/gls-atlas-fes-api-kafka.nonprod.walmart.com.jks" -X "ssl.keystore.password=Walmart@1234" -X "ssl.key.password=Walmart@1234"
}

#kafka-console-producer --bootstrap-server 'kafka-1301504412-1-1334708561.scus.kafka-v2-atlas-secured-stg.ms-df-messaging.stg-az-southcentralus-10.prod.us.walmart.net:9093,kafka-1301504412-2-1334708564.scus.kafka-v2-atlas-secured-stg.ms-df-messaging.stg-az-southcentralus-10.prod.us.walmart.net:9093,kafka-1301504412-3-1334708567.scus.kafka-v2-atlas-secured-stg.ms-df-messaging.stg-az-southcentralus-10.prod.us.walmart.net:9093' --producer.config=/etc/secrets/secrets-qa.properties -topic gls_atlas_wmsof_fulfillment_qa

#kafkacat -P -b 'kafka-1301504412-1-1334708561.scus.kafka-v2-atlas-secured-stg.ms-df-messaging.stg-az-southcentralus-10.prod.us.walmart.net:9093,kafka-1301504412-2-1334708564.scus.kafka-v2-atlas-secured-stg.ms-df-messaging.stg-az-southcentralus-10.prod.us.walmart.net:9093,kafka-1301504412-3-1334708567.scus.kafka-v2-atlas-secured-stg.ms-df-messaging.stg-az-southcentralus-10.prod.us.walmart.net:9093' --producer.config=/etc/secrets/secrets-qa.properties -t gls_atlas_wmsof_fulfillment_qa



FES_TO_OT_PICKING