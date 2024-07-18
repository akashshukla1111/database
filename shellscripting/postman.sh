function createInventoryQA() {
  echo "calling createInventoryQA"
  curl --location --request POST 'https://inventory-server.test.prod.us.walmart.net/inventory/inventories/containers' \
    --header 'facilityNum: 32898' \
    --header 'facilityCountryCode: US' \
    --header 'WMT-UserId: aa00mn0' \
    --header 'Content-Type: application/json' \
    --data-raw $1
}

function getContainer() {
  echo "calling getContainer"
  curl --location --request GET 'https://inventory-server.test.prod.us.walmart.net/inventory/inventories/containers/$1' \
    --header 'facilityNum: 32898' \
    --header 'facilityCountryCode: US' \
    --header 'WMT-correlationId: a0s01hy'
}

function getBulkContainerPROD() {
  curl --location --request POST 'https://inventory-server.prod.us.walmart.net/inventory/inventories/containers/bulk/search' \
    --header 'facilityNum: 4034' \
    --header 'facilityCountryCode: US' \
    --header 'WMT-correlationId: d49ad269-6aad-4e84-a347-eb69dd4e02ed' \
    --header 'Content-Type: application/json' \
    --data-raw '["55567402878131851502",
                 "55589597171566980589",
                 "55520279199484022186",
                 "55549017679528407978",
                 "55511154961060158839",
                 "55549023662153179636",
                 "55566782814535789705",
                 "55550480722437217906",
                 "55535957928823345109",
                 "55538829638857187384",
                 "55537153927914157272",
                 "55522827054233313478",
                 "55537153927914157272",
                 "55569407769200379629",
                 "55570367156102064550",
                 "55570025549536016217",
                 "55524040911600487390",
                 "55555172186174484370",
                 "55513212069760423915",
                 "55548852160367088933",
                 "55546789558029749894",
                 "55546179867874954230",
                 "55519115311397180170",
                 "55542921365974963787",
                 "55556806957094579027"
]'
}


function getBulkContainerDev() {
  curl --location --request POST 'https://inventory-server.dev.prod.us.walmart.net/inventory/inventories/delete/containers/bulk' \
    --header 'facilityNum: 4034' \
    --header 'facilityCountryCode: US' \
    --header 'WMT-correlationId: d49ad269-6aad-4e84-a347-eb69dd4e02ed' \
    --header 'Content-Type: application/json' \
    --data-raw '["55567402878131851502"
]'
}

getBulkContainerDev
