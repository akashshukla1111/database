#kubectl config current-context
#kubectl config get-contexts
#kubectl config set-context scus-stage-a5 --namespace atlas-ndof --cluster scus-dev-a3 #for creating new context
#kubectl config set-context scus-prod-a59 --namespace atlas-ot                       #updating the context
#kubectl config use-context scus-prod-a19
#kubectl config unset contexts.atlas-testing-ndof # for removing the context
#kubectl config view
#kubectl scale -n atlas-ndof deployment fulfillment-execution-service-dev --replicas=0
#kafka-consumer-groups --bootstrap-server 'localhost:9092' --describe --all-groups  --members
#kafka-consumer-groups --bootstrap-server 'kafka-498637915-1-1282813190.scus.kafka-atlas-uwms-stg.ms-df-messaging.prod.us.walmart.net:9092' --describe --all-groups  --members
#kafka-consumer-groups --bootstrap-server 'localhost:9092' --describe --group=FES_BATCH_EVNT_CG1  --members
#kafka-consumer-groups --bootstrap-server 'kafka-498637915-1-1282813190.scus.kafka-atlas-uwms-stg.ms-df-messaging.prod.us.walmart.net:9092,kafka-498637915-2-1282813193.scus.kafka-atlas-uwms-stg.ms-df-messaging.prod.us.walmart.net:9092,kafka-498637915-3-1282813196.scus.kafka-atlas-uwms-stg.ms-df-messaging.prod.us.walmart.net:9092' --describe --group watcher-fes-broker-qa --members --verbose

# Get commands with basic output
#kubectl get kub                          # List all services in the namespace
#kubectl get pods --all-namespaces             # List all pods in all namespaces
#kubectl get pods -o wide                      # List all pods in the current namespace, with more details
#kubectl get deployment my-dep                 # List a particular deployment
#kubectl get pods                              # List all pods in the namespace
#kubectl get pod my-pod -o yaml                # Get a pod's YAML
# kubectl get services -o wide  --namespace us-06009

#sledge connect
#kubectl get rs -n us-06009 --selector=app=ndof-event-audit-trail
#kubectl scale -n us-06009 deployment ndof-event-audit-trail --replicas=0
#kubectl get rs -n us-06009 --selector=app=ndof-event-audit-trail

#pmcgee

#sledge connect scus-prod-a19 && kubectl get pods -A --selector=app=fulfillment-execution-service-prod -o jsonpath='{.items[*].metadata.labels}' | jq -c | jtbl
#sledge connect scus-prod-a59 &&  kubectl get pods -A --selector=app==order-tracker-prod-cell000 -o jsonpath='{.items[*].metadata.labels}' | jq -c | jtbl
#sledge connect scus-dev-a3 && kubectl get pods -n atlas-ndof --selector app.kubernetes.io/name=fulfillment-execution-service   -o jsonpath='{.items[*].metadata.labels}' | jq -c  | jtbl
#sledge connect scus-prod-a19 && kubectl get pods -n atlas-ndof --selector app.kubernetes.io/name=fulfillment-execution-service   -o jsonpath='{.items[*].metadata.labels}' | jq -c  | jtbl


#sledge connect scus-dev-a2 && kubectl get pods -n atlas-ot --selector app.kubernetes.io/name=order-tracker  -o jsonpath='{.items[*].metadata.labels}' | jq -c  | jtbl




#kafka-console-consumer --bootstrap-server 'kafka-1229450061-1-1334609249.scus.kafka-v2-yms-cluster-prod.ms-df-messaging.prod-az-southcentralus-28.prod.us.walmart.net:9093,kafka-1229450061-6-1334609264.scus.kafka-v2-yms-cluster-prod.ms-df-messaging.prod-az-southcentralus-28.prod.us.walmart.net:9093,kafka-1229450061-4-1334609258.scus.kafka-v2-yms-cluster-prod.ms-df-messaging.prod-az-southcentralus-28.prod.us.walmart.net:9093,kafka-1229450061-5-1334609261.scus.kafka-v2-yms-cluster-prod.ms-df-messaging.prod-az-southcentralus-28.prod.us.walmart.net:9093,kafka-1229450061-3-1334609255.scus.kafka-v2-yms-cluster-prod.ms-df-messaging.prod-az-southcentralus-28.prod.us.walmart.net:9093,kafka-1229450061-2-1334609252.scus.kafka-v2-yms-cluster-prod.ms-df-messaging.prod-az-southcentralus-28.prod.us.walmart.net:9093' --topic watcher-loading-package-event-p32 --group GLS-FES-PROD-LOAD-1 --consumer.config /etc/secrets/secrets.properties


#kubectl exec -n atlas-ot -it order-tracker-qa-cell000-6d78fc76f4-8gcjg -- /bin/sh
#kubectl exec -n atlas-ot -it order-tracker-stage-cell000-bcb6c68c7-8bfsx -- /bin/sh
#kubectl exec -n atlas-egls-migration -it egls-migrator-prod-cell000-65fcdcfd8d-qwcqz -- /bin/sh
#kubectl get deploy
#kubectl describe deploy order-tracker-qa-cell000
#kubectl get pods -n atlas-ot
#kubectl get pods -l app=order-tracker-qa-cell000
#kubectl describe pod order-tracker-qa-cell000-6d78fc76f4-8gcjg

# duplicate remove --> ^(.*)(\r?\n\1)+$

#kafka-topics --create --zookeeper localhost:2181 --replication-factor 1 --partitions 3 --topic hawkeye-dev-amr-hvfc-fulfillment-response-status-update
#kafka-consumer-groups --bootstrap-server 'localhost:9092' --describe --group GLS-FES-DEV-GO-STATUS-UPDATE --members --verbose


#sledge connect uscentral-stage-wmt-001 && kubectl get pods -n atlas-ot --selector app.kubernetes.io/name=order-tracker  -o jsonpath='{.items[*].metadata.labels}' | jq -c  | jtbl



#kafka-console-producer --broker-list 'kafka-1052450285-1-1269647919.scus.kafka-v2-atlas-scus-wus-prod.ms-df-messaging.prod-az-southcentralus-25.prod.us.walmart.net:9093,kafka-1052450285-2-1269647922.scus.kafka-v2-atlas-scus-wus-prod.ms-df-messaging.prod-az-southcentralus-25.prod.us.walmart.net:9093,kafka-1052450285-3-1269647925.scus.kafka-v2-atlas-scus-wus-prod.ms-df-messaging.prod-az-southcentralus-25.prod.us.walmart.net:9093,kafka-1052450285-4-1269647928.scus.kafka-v2-atlas-scus-wus-prod.ms-df-messaging.prod-az-southcentralus-25.prod.us.walmart.net:9093,kafka-1052450285-5-1269647931.scus.kafka-v2-atlas-scus-wus-prod.ms-df-messaging.prod-az-southcentralus-25.prod.us.walmart.net:9093,kafka-1052450285-6-1269647934.scus.kafka-v2-atlas-scus-wus-prod.ms-df-messaging.prod-az-southcentralus-25.prod.us.walmart.net:9093' --producer.config /private/etc/secrets/kafka-secure-producer.properties --topic EGLS_CUTOVER_INV_PROD


grep -r --include '*default.yml' 'cluster_id' ~/work/
#sledge connect uscentral-stage-az-12 && kubectl get pods -n atlas-ndop --selector app.kubernetes.io/name=order-services -o jsonpath='{.items[*].metadata.labels}' | jq -c
#sledge connect uscentral-stage-wmt-001 && kubectl get pods -n atlas-ndop --selector app.kubernetes.io/name=allocation-order-service -o jsonpath='{.items[*].metadata.labels}' | jq -c | jtbl
#sledge connect uscentral-stage-wmt-001

#sledge wcnp describe cluster eus2-prod-a52
#sledge wcnp describe namespace atlas-ndof
#sledge wcnp describe app fulfillment-execution-service -n atlas-ndof -c scus-dev-a3
#sledge wcnp describe app allocation-order-service -n atlas-ndof