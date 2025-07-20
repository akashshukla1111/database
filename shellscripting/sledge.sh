#!/bin/bash

# Function to extract version from sledge wcnp describe commands
appversion() {
    # Run the command, clean output, extract Labels section, and get the version
    cleaned_output=$(expect -c "
    spawn $*
    expect \">\"
    send \"\r\"
    expect eof
    " | sed -r "s/\x1B\[[0-9;]*[a-zA-Z]//g" | sed 's/\x1B\][0-9];[^\a]*\a//g' | tr -cd '\11\12\15\40-\176')

    # Extract and print only the version
    echo "$cleaned_output" | awk '/Labels/{flag=1; next} /Status/{flag=0} flag' | grep -E 'app.kubernetes.io/version[ ]*:' | head -1 | awk -F: '{gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2}'
}

# Usage examples:
# appversion sledge wcnp describe app allocation-order-service-default-fc-stg -n fc-atlas-ndop
# Or call directly: ./sledge.sh sledge wcnp describe app <app-name> -n <namespace>

# If script is called directly (not sourced), run the function with arguments
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    appversion "$@"
fi