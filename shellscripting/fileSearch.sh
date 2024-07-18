#!/bin/bash
# Define a function to process YAML files with multiple filenames
#searchYml() {
#
#    find /Users/a0s01hy/work \( -path "*/allocation-order-service/kitt-config/*" -o -path "*/ndof-trip-execution/kitt-config/*" -o -path "*/inventory-server-cloud/kitt-config/*" \) -type f \( -name "us-wm-fc.yml" -o -name "us-wm-ambient.yml" -o -name "us-wm-default.yml" \) -exec grep -H -e "artifact:" -e "matchStages:" -e "namespace:" {} + | sed 's/ //g; s/\[//g; s/\]//g' | sed 's/:/ /g' | awk 'BEGIN {
#}
#{
#    if ($2 == "artifact") {
#        artifact[$1] = $3
#    } else if ($2 == "namespace") {
#        namespace[$1] = $3
#    } else if ($2 == "matchStages") {
#        matchStages[$1] = matchStages[$1] $3 ","
#    }
#}
#END {
#    for (file in artifact) {
#        sub(/,$/, "", matchStages[file])
#        print artifact[file] "\t" namespace[file] "\t"  matchStages[file]
#    }
#}' | column -t
#}

searchYml() {
  if [ $# -eq 0 ]; then
    find_args="-name us-wm-default.yml"
  else
    find_args=""
    for i in "$@"; do
      find_args+="-name us-wm-$i.yml -o "
    done
    find_args="${find_args%-o }" # Remove the trailing '-o'
  fi

  find /Users/a0s01hy/work \( -path "*/allocation-order-service/kitt-config/*" -o -path "*/ndof-trip-execution/kitt-config/*" -o -path "*/inventory-server-cloud/kitt-config/*" \) -type f \( $find_args \) -exec grep -H -e "artifact:" -e "matchStages:" -e "namespace:" {} + |
    sed 's/ //g; s/\[//g; s/\]//g' |
    sed 's/:/ /g' |
    awk 'BEGIN {} {
        if ($2 == "artifact") {
            artifact[$1] = $3
        } else if ($2 == "namespace") {
            namespace[$1] = $3
        } else if ($2 == "matchStages") {
            matchStages[$1] = matchStages[$1] $3 ","
        }
    } END {
        for (file in artifact) {
            sub(/,$/, "", matchStages[file])
            print artifact[file] "\t" namespace[file] "\t"  matchStages[file]
        }
    }' | column -t
}

# Usage example: Call the function with the filenames as arguments
searchYml fc ambient
