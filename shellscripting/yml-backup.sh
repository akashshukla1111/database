#!/bin/zsh
# Define a global variable
# namespaces     artifacts     stages
YML_DATA="fc-atlas-inventory  inv-server-cloud-fc       dev-cell000,qa-cell000,fc-perf-cell000,prod-cell003,prod-cell006,prod-cell028,prod-cell005,prod-cell010
fc-atlas-ndof       fes                       dev,qa,perf,prod-cell028,prod-cell010,prod-cell003
fc-atlas-ndop       allocation-order-service  fc-qa,fc-perf,prod-cell028,prod-eus-scus,prod-cell003
atlas-inventory  inv-server-cloud-us            dev-cell000,qa-cell000,stg-cell000,perf-cell000,witron-cell000,prod-cell000,prod-cell010
atlas-ndof       fulfillment-execution-service  dev,qa,stage,perf,prod,prod-cell004
atlas-ndop       allocation-order-service       qa,stg,perf,prod-scus-wus,prod-cell004
amb-atlas-ndof       fulfillment-service-us    amb-qa,amb-stg,amb-perf,prod-cell002
amb-atlas-ndop       allocation-order-service  amb-qa,amb-stg,amb-perf,stage-cell003,prod-cell002
atlas-inventory  inv-server-cloud-amb      prod-cell004,amb-dev,amb-qa"

namespace() {
  local env="${1-default}"
  # Capture the output into the global variable
  find /Users/a0s01hy/work \( \
    -path "*/allocation-order-service/kitt-config/*" \
    -o -path "*/ndof-trip-execution/kitt-config/*" \
    -o -path "*/inventory-server-cloud/kitt-config/*" \
    \) -type f \( -name "us-wm-${env}.yml" \) -exec grep -H -e "artifact:" -e "matchStages:" -e "namespace:" {} + |
    sed 's/ //g; s/\[//g; s/\]//g' |
    sed 's/:/ /g' |
    awk '
      {
        if ($2 == "artifact") {
            artifact[$1] = $3
        } else if ($2 == "namespace") {
            namespace[$1] = $3
        } else if ($2 == "matchStages") {
            matchStages[$1] = matchStages[$1] $3 ","
        }
      }
      END {
        for (file in artifact) {
            sub(/,$/, "", matchStages[file])
            print namespace[file]"\t" artifact[file]  "\t"  matchStages[file]
        }
      }
    ' | column -t
}

alias ns=namespace

version() {
  if [[ "${1:l}" == "fes" ]]; then
    namespace="atlas-ndof"
  elif [[ "${1:l}" == "aos" ]]; then
    namespace="atlas-ndop"
  elif [[ "${1:l}" == "inv" ]]; then
    namespace="atlas-inventory"
  fi

  if [[ "${3:l}" == "fc" ]]; then
    namespace="fc-${namespace}"
  elif [[ "${3:l}" == "amb" ]]; then
    namespace="amb-${namespace}"
  else
    namespace=${namespace}
  fi

  namespaceValue=""
  app=""
  # Loop through each line of the data
  while var=$'\t' read -r n artifact stages; do
    if [[ "$n" == "$namespace" ]]; then
      namespaceValue=$namespace
      IFS=',' read -r -A stage_array <<<"$stages"
      for stage in "${stage_array[@]}"; do
        if [[ $stage == *"$2"* ]]; then
          app=$artifact-"$stage"
          break
        fi
      done
    fi
  done <<<"$YML_DATA"

  if [[ -z "$namespaceValue" ]]; then
    echo "${BIRed}Error: ${1} Namespace '$namespace' not found. ${BIGreen}Valid app args are [fes, aos, inv].
${BIPurple}RUN:[ version fes qa fc / v fes qa fc ]"
  elif [[ -z "$app" ]]; then
    echo "${BIRed}Error: Stage '$2' not found in namespace '$namespace'."
  else
    echo -e "${IPurple}Running ${BGreen}sledge wcnp describe app ${app} -n ${namespace}"
    sledge wcnp describe app ${app} -n ${namespace}
  fi

}
alias v=version
