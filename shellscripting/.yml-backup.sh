#!/bin/zsh

# Color definitions
RED='\033[1;91m'        # Bold Intense Red
GRN='\033[1;92m'        # Bold Intense Green
YEL='\033[1;93m'        # Bold Intense Yellow
BLU='\033[1;94m'        # Bold Intense Blue
PUR='\033[1;95m'        # Bold Intense Purple
CYN='\033[1;96m'        # Bold Intense Cyan
WHT='\033[1;97m'        # Bold Intense White
IPR='\033[0;95m'        # Intense Purple
BGR='\033[1;32m'        # Bold Green (alternative)
BRN='\033[1;33m'        # Bold Brown (for artifact)
SKY='\033[1;96m'        # Bold Sky Blue (for namespace)
RST='\033[0m'           # Reset/No Color

# Standard (non-bold) color definitions for help functions
STD_RED='\033[0;31m'    # Standard Red
STD_GRN='\033[0;32m'    # Standard Green
STD_YEL='\033[0;33m'    # Standard Yellow
STD_BLU='\033[0;34m'    # Standard Blue
STD_PUR='\033[0;35m'    # Standard Purple
STD_CYN='\033[0;36m'    # Standard Cyan
STD_WHT='\033[0;37m'    # Standard White

# Global loading animation variables
LOADING_PID=""
LOADING_ACTIVE=false
LOADING_START_TIME=0

# Global loading spinner function - simplified version
show_loading() {
    local message="$1"
    local spinner_chars="|/-\\"
    local i=0
    local start_time=$(date +%s)
    echo "this is show laoding big"
    while kill -0 $$ 2>/dev/null; do
        local current_time=$(date +%s)
        local elapsed=$((current_time - start_time))

        # Format time display - ensure clean formatting
        local time_str="${elapsed}s"
        if [[ $elapsed -ge 60 ]]; then
            local minutes=$((elapsed / 60))
            local remaining_seconds=$((elapsed % 60))
            time_str="${minutes}m ${remaining_seconds}s"
        fi

        # Clean the time string of any potential extra characters
        time_str=$(echo "$time_str" | tr -d '\n\r')

        # Get terminal width and calculate position for right-aligned time
        local term_width=$(tput cols 2>/dev/null || echo 80)
        local message_with_spinner="${spinner_chars:$i:1} ${message}"
        local message_length=$(echo -n "${message_with_spinner}" | wc -c)
        local time_length=$(echo -n "${time_str}" | wc -c)
        local spaces_needed=$((term_width - message_length - time_length - 2))

        # Ensure we don't go negative
        if [[ $spaces_needed -lt 1 ]]; then
            spaces_needed=1
        fi

        local spaces=$(printf "%*s" $spaces_needed "")

        printf "\r${CYN}%s${RST} %s%s${YEL}%s${RST}" "${spinner_chars:$i:1}" "${message}" "${spaces}" "${time_str}"
        i=$(((i + 1) % ${#spinner_chars}))
        sleep 0.2
    done
}

# Global start loading animation function
start_loading() {
    local message="$1"
    if [[ "$LOADING_ACTIVE" == false ]]; then
        LOADING_ACTIVE=true
        LOADING_START_TIME=$(date +%s)
        # Disable job control messages
        set +m
        (
            trap 'exit 0' TERM
            show_loading "$message"
        ) &
        LOADING_PID=$!
        # Re-enable job control messages
        set -m
    fi
}

# Global stop loading animation function
stop_loading() {
    if [[ "$LOADING_ACTIVE" == true ]]; then
        LOADING_ACTIVE=false
        # Disable job control messages
        set +m
        if [[ -n "$LOADING_PID" ]]; then
            kill -TERM "$LOADING_PID" 2>/dev/null
            wait "$LOADING_PID" 2>/dev/null
        fi
        # Re-enable job control messages
        set -m

        # Show final execution time at the right end
        local current_time=$(date +%s)
        local elapsed=$((current_time - LOADING_START_TIME))

        # Format time display - ensure clean formatting
        local time_str="${elapsed}s"
        if [[ $elapsed -ge 60 ]]; then
            local minutes=$((elapsed / 60))
            local remaining_seconds=$((elapsed % 60))
            time_str="${minutes}m ${remaining_seconds}s"
        fi

        # Clean the time string of any potential extra characters
        time_str=$(echo "$time_str" | tr -d '\n\r')

        # Get terminal width and calculate position for right-aligned time
        local term_width=$(tput cols 2>/dev/null || echo 80)
        local completed_text="✓ Completed"
        local completed_length=$(echo -n "${completed_text}" | wc -c)
        local time_length=$(echo -n "${time_str}" | wc -c)
        local spaces_needed=$((term_width - completed_length - time_length - 1))

        # Ensure we don't go negative
        if [[ $spaces_needed -lt 1 ]]; then
            spaces_needed=1
        fi

        local spaces=$(printf "%*s" $spaces_needed "")

        printf "\r${GRN}✓ Completed${RST}%s${YEL}%s${RST}\n" "${spaces}" "${time_str}"
        LOADING_PID=""
    fi
}

# Global cleanup function for script exit
cleanup() {
    if [[ "$LOADING_ACTIVE" == true ]]; then
        LOADING_ACTIVE=false
        # Disable job control messages
        set +m
        if [[ -n "$LOADING_PID" ]]; then
            kill -TERM "$LOADING_PID" 2>/dev/null
            wait "$LOADING_PID" 2>/dev/null
        fi
        # Re-enable job control messages
        set -m
        printf "\r${YEL}✓${RST} Operation interrupted\n"
    fi
}

# Set up trap for cleanup on exit
trap cleanup EXIT INT TERM

# Function to show available functions
show_functions() {
    echo ""
    echo -e "${STD_YEL}namespace(ns)${RST}    - Extract namespace, artifact, and stages from kitt-config files"
    echo -e "${STD_YEL}version(v)${RST}       - Get version information for specific applications"
    echo -e "${STD_YEL}search${RST}           - Search and extract information from kitt files"
    echo ""
    echo -e "${STD_GRN}For detailed help on specific commands:${RST}"
    echo -e "${STD_CYN}  ns -h${RST}         # Namespace command help"
    echo -e "${STD_CYN}  v -h${RST}          # Version command help"
    echo -e "${STD_CYN}  search -h${RST}     # Search command help"
    echo ""
}

# Individual help functions
show_namespace_help() {
    echo ""
    echo -e "${STD_YEL}Description:${RST}"
    echo -e "  Extract namespace, artifact, and stages information from kitt-config files"
    echo ""
    echo -e "${STD_YEL}Usage:${RST}"
    echo -e "  ${STD_CYN}ns [market_type]${RST}"
    echo ""
    echo -e "${STD_YEL}Examples:${RST}"
    echo -e "  ${STD_CYN}ns fc${RST}                    # Show fc environment namespaces"
    echo -e "  ${STD_CYN}ns fc,default${RST}            # Show fc and default environments"
    echo ""
    echo -e "${STD_YEL}Output:${RST}"
    echo -e "  Displays a table with Namespace, Artifact, and Stages columns"
    echo ""
}

show_version_help() {
    echo ""
    echo -e "${STD_YEL}Description:${RST}"
    echo -e "  Get version information for specific applications using sledge commands"
    echo ""
    echo -e "${STD_YEL}Usage:${RST}"
    echo -e "  ${STD_CYN}v <app> <stage> [environment_type]${RST}"
    echo ""
    echo -e "${STD_YEL}Parameters:${RST}"
    echo -e "  app                 Application name (fes, aos/os, inv, loading/lod, slotting/slot, gdm, location/loc)"
    echo -e "  stage               Environment stage (qa, dev, prod, stg, etc.)"
    echo -e "  environment_type    Optional: fc, amb (default: none)"
    echo ""
    echo -e "${STD_YEL}Examples:${RST}"
    echo -e "  ${STD_CYN}v fes qa fc${RST}              # Get FES version in QA FC environment"
    echo ""
}

show_search_help() {
    echo ""
    echo -e "${STD_YEL}Description:${RST}"
    echo -e "  Extract and display information from kitt files with optional filtering"
    echo ""
    echo -e "${STD_YEL}Usage:${RST}"
    echo -e "  ${STD_CYN}search <file_paths> [environment_filter|search_keys] [-s]${RST}"
    echo -e "  ${STD_CYN}<command> | search [environment_filter|search_keys] [-s]${RST}"
    echo ""
    echo -e "${STD_YEL}Parameters:${RST}"
    echo -e "  file_paths           File paths or command substitution result"
    echo -e "  environment_filter   Filter by environment (qa, dev, prod, etc.) - used with -s flag"
    echo -e "  search_keys          Search for specific keys in YAML files - used without -s flag"
    echo -e "  -s, --sledge         Run sledge commands for version information"
    echo ""
    echo -e "${STD_YEL}Modes:${RST}"
    echo -e "  ${STD_GRN}Key-Value Search Mode (default):${RST}"
    echo -e "    Search for key-value pairs in YAML files"
    echo -e "  ${STD_GRN}Sledge Command Mode (-s flag):${RST}"
    echo -e "    Extract version information using sledge commands"
    echo ""
    echo -e "${STD_YEL}Examples:${RST}"
    echo -e "  ${STD_GRN}Key-Value Search Mode:${RST}"
    echo -e "  ${STD_CYN}search \"\$(fs -fr aos,os/default-fc stg-config.yml)\" java_opts${RST}      # Search for 'java_opts' key"
    echo -e "  ${STD_CYN}search \"\$(fs -fr aos,os/default-fc stg-config.yml)\"${RST}               # Show all keys"
    echo -e "  ${STD_CYN}fs -fr aos,os/default-fc stg-config.yml | search${RST}                    # Show all keys"
    echo -e "  ${STD_CYN}fs -fr aos,os/default-fc stg-config.yml | search java_opts${RST}          # Search key in files"
    echo ""
    echo -e "  ${STD_GRN}Sledge Command Mode:${RST}"
    echo -e "  ${STD_CYN}search \"\$(fs -fr aos,os/default-fc pre-main)\" stg -s${RST}            # Run sledge commands for stg"
    echo -e "  ${STD_CYN}search \"\$(fs -fr gdm/default-fc pre-main)\" -s${RST}                   # No filter, show all"
    echo -e "  ${STD_CYN}fs -fr fes/default-fc pre-main | search stg -s${RST}                     # Use with pipe"
    echo -e "  ${STD_CYN}search \"\$(fs -fr nte/default-fc pre-main)\" -s${RST}                   # No filter, show all"
    echo ""
}

# Alias for help
alias help=show_functions

# Define a global variable
# namespaces     artifacts     stages
YML_DATA="gls-ndop                   wave-release                   qa,stg,perf,prod,prod-cell004
          'fc-atlas-smart-slotting'  icqa-us-fc                     qa,stage,prod-cell003,prod-cell006,prod-cell028,prod-cell005
          fc-atlas-receiving-api     uwms-receiving-fc              qa-cell000,prod-cell028,default-fc-stg,stg-cell000,prod-cell010,perf-cell000,dev-cell000,prod-cell003
          atlas-return-api           return-api                     dev-cell000,qa-cell000,stage-cell000,prod-cell000
          gdc-atlas-inventory        rapid-relayer-test             dev
          atlas-gdm-us-fc            gdm-adapter-us-wm-fc           prod-003,stage-us-fc,dev-us-fc,default-fc-stg,prod-028,perf-us-fc,qa-us-fc
          atlas-ndof                 fulfillment-execution-service  qa,stage,prod,perf,prod-cell004,dev
          fc-atlas-peacemaker        rapid-relayer-pcmkr-fc         dev,prod
          atlas-inventory-core       rapid-relayer-invt-default     dev,qa
          atlas-gdm-core             app-001-gdm-adapter            dev,qa,stage,perf,prod
          atlas-egls-migration       relayer-common-fc              dev,qa,auto-qa,stg,perf,prod-cell028,prod-cell003,prod-cell010,prod-cell005,prod-cell006
          fc-atlas-ndop              allocation-order-service       prod-cell028,default-fc-stg,fc-dev,fc-perf,prod-eus-scus,prod-cell003,prod-cell005,fc-qa,prod-cell006
          fc-atlas-smart-slotting    slotting                       qa-cell000,prod-cell028,default-fc-stg,stg-cell000,prod-cell010,perf-cell000,dev-cell000,prod-cell003
          fc-atlas-ndof              fes                            qa,prod-cell028,default-fc-stg,prod-cell010,perf,prod-cell003,prod-cell005,prod-cell006,dev
          fc-atlas-location          gls-location-fc                qa-cell000,prod-cell028,default-fc-stg,stg-cell000,prod-cell010,perf-cell000,dev-cell000,prod-cell003,prod-cell005,prod-cell006
          atlas-receiving            rapid-relayer-rcv              qa-cell000,prod-cell000
          atlas-ndop                 order-services                 qa,stg,perf,prod-scus-wus,prod-cell004,dev
          atlas-gdm-core             gdm-core-000                   dev,qa,stage,prod-004,prod-000,prod-001,prod-010,prod-011,perf
          atlas-ot                   order-tracker                  dev-cell000,qa-cell000,stage-cell000,perf-cell000,prod-cell000,prod-cell010,prod-cell003,prod-cell004
          atlas-ndop                 allocation-order-service-fc    dev,qa,prod-cell003
          atlas-gdm-us-fc            gdm-core-us-fc                 prod-003,stage-us-fc,dev-us-fc,default-fc-stg,prod-028,perf-us-fc,qa-us-fc
          fc-atlas-loading           uwms-loading-server-fc         qa,stg,perf,prod-cell028-fc,prod-cell003-fc,prod-cell010-fc,prod-cell005-fc,prod-cell006-fc
          fc-atlas-loading           uwms-loading-int               fc-default-stg
          fc-atlas-ndop              order-services-fc              prod-cell028,default-fc-stg,fc-dev,fc-perf,prod-eus-scus,prod-cell003,prod-cell005,fc-qa,prod-cell006
          atlas-ndop                 allocation-order-service       qa,stg,perf,prod-scus-wus,prod-cell004,dev
          atlas-smart-slotting       smart-slotting-us              dev-cell000,qa-cell000,stgint,perf-cell000,prod-cell000
          fc-atlas-receiving-api     rapid-relayer-rcv-fc           dev,qa"

namespace() {
  # Check for help flag
  if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_namespace_help
    return 0
  fi

  local env_list="${1:-default}"
  local temp_file=$(mktemp)

  # Start loading animation
  start_loading "Searching for kitt-config files..."

  # Split the comma-separated environments and process each one
  IFS=',' read -r -A env_array <<<"$env_list"

  for env in "${env_array[@]}"; do
    # Trim whitespace
    env=$(echo "$env" | xargs)

    # Determine the file pattern based on the environment name
    local file_pattern
    if [[ "$env" == *"-"* ]]; then
      # If env contains hyphens, treat it as a full filename (like fc-pre-main-merge)
      file_pattern="${env}.yml"
    else
      # Otherwise, use the standard us-wm-{env} pattern (like default, fc)
      file_pattern="us-wm-${env}.yml"
    fi

    # Process each environment
    find /Users/a0s01hy/work \( \
      -path "*/kitt-config/*" \
      \) -type f \( -name "$file_pattern" \) -exec awk -v filename="{}" -v environment="$env" '
        BEGIN {
          in_lbRoutings = 0;
          stages = "";
          artifact = "";
          namespace = ""
        }
        /^[[:space:]]*artifact:[[:space:]]*/ {
          gsub(/^[[:space:]]*artifact:[[:space:]]*/, "");
          artifact = $0
        }
        /^[[:space:]]*namespace:[[:space:]]*/ {
          gsub(/^[[:space:]]*namespace:[[:space:]]*/, "");
          namespace = $0
        }
        /^[[:space:]]*lbRoutings:[[:space:]]*$/ {
          in_lbRoutings = 1;
          next
        }
        in_lbRoutings && /^[[:space:]]{6}[a-zA-Z0-9-]+:[[:space:]]*$/ {
          stage = $1;
          gsub(/^[[:space:]]*/, "", stage);
          gsub(/:/, "", stage);
          if (stages == "") {
            stages = stage
          } else {
            stages = stages "," stage
          }
        }
        /^[[:space:]]*[a-zA-Z][a-zA-Z0-9]*:[[:space:]]*/ && !/^[[:space:]]{4,}/ {
          if (in_lbRoutings && $0 !~ /^[[:space:]]*lbRoutings:/) {
            in_lbRoutings = 0
          }
        }
        END {
          if (artifact && namespace && stages) {
            print namespace "\t" artifact "\t" stages
          }
        }
      ' {} \; >> "$temp_file"
  done

  # Stop loading animation before displaying results
  stop_loading

  # Sort and combine stages for same namespace+artifact combinations
  # Then format the output nicely in table format
  if [[ -s "$temp_file" ]]; then
    echo ""
    echo -e "${BRN}Namespace${RST}                    ${BRN}Artifact${RST}                     ${BRN}Stages${RST}"
    echo -e "${STD_GRN}--------------                    -----------                     -------------${RST}"

    sort "$temp_file" | awk '
      {
        key = $1 "\t" $2
        if (key in stages) {
          # Combine stages, avoiding duplicates
          split(stages[key], existing_stages, ",")
          split($3, new_stages, ",")

          # Create associative array to track unique stages
          delete unique_stages
          for (i in existing_stages) {
            if (existing_stages[i] != "") {
              unique_stages[existing_stages[i]] = 1
            }
          }
          for (i in new_stages) {
            if (new_stages[i] != "") {
              unique_stages[new_stages[i]] = 1
            }
          }

          # Rebuild comma-separated list
          combined = ""
          for (stage in unique_stages) {
            if (combined == "") {
              combined = stage
            } else {
              combined = combined "," stage
            }
          }
          stages[key] = combined
        } else {
          stages[key] = $3
        }
        namespaces[key] = $1
        artifacts[key] = $2
      }
      END {
        # Output each entry in a formatted way
        for (key in stages) {
          printf "%-27s  %-25s  %s\n", namespaces[key], artifacts[key], stages[key]
        }
      }
    '
  else
    echo -e "${RED}No matching kitt-config files found.${RST}"
  fi

  # Clean up temp file
  rm -f "$temp_file"
}

alias ns=namespace

version() {
  # Check for help flag
  if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_version_help
    return 0
  fi

  if [[ "${1:l}" == "fes" ]]; then
    namespace="atlas-ndof"
  elif [[ "${1:l}" == "aos" || "${1:l}" == "os" ]]; then
    namespace="atlas-ndop"
  elif [[ "${1:l}" == "inv" ]]; then
    namespace="atlas-inventory"
  elif [[ "${1:l}" == "loading" || "${1:l}" == "lod" ]]; then
    namespace="atlas-loading"
  elif [[ "${1:l}" == "slotting" || "${1:l}" == "slot" ]]; then
      namespace="atlas-smart-slotting"
  elif [[ "${1:l}" == "gdm" || "${1:l}" == "gdm-core" ]]; then
        namespace="atlas-gdm-us-fc"
  elif [[ "${1:l}" == "location" || "${1:l}" == "loc" ]]; then
    namespace="atlas-location"
  fi

  if [[ "${3:l}" == "fc" ]]; then
    namespace="fc-${namespace}"
  elif [[ "${3:l}" == "amb" ]]; then
    namespace="amb-${namespace}"
  else
    namespace=${namespace}
  fi

  namespaceValue=""
  declare -a matching_apps
  declare -a matching_artifacts

  # Loop through each line of the data to find all matching artifacts
  while var=$'\t' read -r n artifact stages; do
    if [[ "$n" == "$namespace" ]]; then
      namespaceValue=$namespace
      IFS=',' read -r -A stage_array <<<"$stages"
      for stage in "${stage_array[@]}"; do
        if [[ $stage == *"$2"* ]]; then
          matching_apps+=("$artifact-$stage")
          matching_artifacts+=("$artifact")
          break
        fi
      done
    fi
  done <<<"$YML_DATA"

  if [[ -z "$namespaceValue" ]]; then
    echo "${STD_RED}Error: ${1} Namespace '$namespace' not found. ${STD_GRN}Valid app args are [fes, aos/os, inv, loading, location].
${STD_PUR}RUN:[ version fes qa fc / v fes qa fc ]"
  elif [[ ${#matching_apps[@]} -eq 0 ]]; then
    echo "${STD_RED}Error: Stage '$2' not found in namespace '$namespace'."
  elif [[ ${#matching_apps[@]} -eq 1 ]]; then
    # Only one match, proceed directly
    app=${matching_apps[1]}
    echo -e "${IPR}Running ${BGR}sledge wcnp describe app ${app} -n ${namespace}${RST}"
    start_loading "Fetching version information for ${app}..."
    sledge wcnp describe app ${app} -n ${namespace}
    stop_loading
  else
    # Multiple matches, present selection menu
    echo "${STD_YEL}Multiple artifacts found in namespace '$namespace' with stage '$2':"
    echo ""
    for i in {1..${#matching_apps[@]}}; do
      echo "${STD_CYN}[$i] ${STD_GRN}${matching_artifacts[$i]} ${STD_WHT}-> ${STD_BLU}${matching_apps[$i]}"
    done
    echo ""
    echo -n "${STD_PUR}Select an option [1-${#matching_apps[@]}]: ${RST}"
    read selection

    if [[ "$selection" =~ ^[0-9]+$ ]] && [[ $selection -ge 1 ]] && [[ $selection -le ${#matching_apps[@]} ]]; then
      app=${matching_apps[$selection]}
      echo -e "${IPR}Running ${BGR}sledge wcnp describe app ${app} -n ${namespace}${RST}"
      start_loading "Fetching version information for ${app}..."
      sledge wcnp describe app ${app} -n ${namespace}
      stop_loading
    else
      echo "${STD_RED}Invalid selection. Please choose a number between 1 and ${#matching_apps[@]}."
    fi
  fi

}
alias v=version

# Function to get version information from kitt files
search() {
  # Check for help flag
  if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_search_help
    return 0
  fi

  local file_list=""
  local env_filter=""
  local search_keys=""
  local run_sledge=false

  # Check for -s flag at the end (backward compatibility)
  if [[ "${@: -1}" == "-s" || "${@: -1}" == "--sledge" ]]; then
    run_sledge=true
    # Remove the last argument (-s flag) from the argument list
    set -- "${@:1:$(($#-1))}"
  fi

  # Handle piped input
  if [[ ! -t 0 ]]; then
    # Read from stdin
    local piped_data=$(cat)
    if [[ $# -eq 0 ]]; then
      file_list="$piped_data"
    elif [[ $# -eq 1 ]]; then
      file_list="$piped_data"
      if [[ "$run_sledge" == true ]]; then
        env_filter="$1"
      else
        search_keys="$1"
      fi
    elif [[ $# -eq 2 ]]; then
      file_list="$piped_data"
      if [[ "$run_sledge" == true ]]; then
        env_filter="$1"
      else
        search_keys="$1"
        env_filter="$2"
      fi
    fi
  else
    # Handle arguments (backward compatible)
    if [[ $# -eq 0 ]]; then
      echo -e "${STD_RED}Usage: search <file_paths> [environment_filter|search_keys] [-s]"
      echo -e "${STD_GRN}Example: search \"\$(fs -fr aos/default-fc pre-main)\" qa -s     # Run sledge commands"
      echo -e "${STD_GRN}Example: search \"\$(fs -fr aos/default-fc pre-main)\" qa        # Search key-values for qa"
      echo -e "${STD_GRN}Example: search \"\$(fs -fr aos/default-fc pre-main)\" artifact  # Search for 'artifact' key"
      return 1
    elif [[ $# -eq 1 ]]; then
      file_list="$1"
    elif [[ $# -eq 2 ]]; then
      file_list="$1"
      if [[ "$run_sledge" == true ]]; then
        env_filter="$2"
      else
        search_keys="$2"
      fi
    elif [[ $# -eq 3 ]]; then
      file_list="$1"
      if [[ "$run_sledge" == true ]]; then
        env_filter="$2"
      else
        search_keys="$2"
        env_filter="$3"
      fi
    fi
  fi

  # If no input provided, show usage
  if [[ -z "$file_list" ]]; then
    echo -e "${STD_RED}Usage: search <file_paths> [environment_filter|search_keys] [-s]"
    echo -e "${STD_GRN}Example: search \"\$(fs -fr aos/default-fc pre-main)\" qa -s     # Run sledge commands"
    echo -e "${STD_GRN}Example: search \"\$(fs -fr aos/default-fc pre-main)\" qa        # Search key-values for qa"
    echo -e "${STD_GRN}Example: search \"\$(fs -fr aos/default-fc pre-main)\" artifact  # Search for 'artifact' key"
    return 1
  fi

  # Choose the appropriate processing mode
  if [[ "$run_sledge" == true ]]; then
    # SLEDGE MODE: Original vk functionality
    # Create temporary file for processing
    local temp_file=$(mktemp)

    # Start loading animation for file processing
    start_loading "Processing YAML files..."

    # Process each file path for sledge commands
    while IFS= read -r file_path; do
      # Skip empty lines or lines that don't look like file paths
      [[ -z "$file_path" ]] && continue
      [[ "$file_path" == *"Found"* ]] && continue
      [[ "$file_path" == *"Directory:"* ]] && continue
      [[ "$file_path" == *"Searching"* ]] && continue
      [[ "$file_path" == *"Completed"* ]] && continue

      # Extract information from the file path
      if [[ "$file_path" == *".yml" ]] && [[ -f "$file_path" ]]; then
        # Parse the YAML file to extract namespace, artifact, and lbRoutings
        local yaml_info=$(awk '
          BEGIN {
            in_lbRoutings = 0;
            stages = "";
            artifact = "";
            namespace = ""
          }
          /^[[:space:]]*artifact:[[:space:]]*/ {
            gsub(/^[[:space:]]*artifact:[[:space:]]*/, "");
            artifact = $0
          }
          /^[[:space:]]*namespace:[[:space:]]*/ {
            gsub(/^[[:space:]]*namespace:[[:space:]]*/, "");
            namespace = $0
          }
          /^[[:space:]]*lbRoutings:[[:space:]]*$/ {
            in_lbRoutings = 1;
            next
          }
          in_lbRoutings && /^[[:space:]]{6}[a-zA-Z0-9-]+:[[:space:]]*$/ {
            stage = $1;
            gsub(/^[[:space:]]*/, "", stage);
            gsub(/:/, "", stage);
            if (stages == "") {
              stages = stage
            } else {
              stages = stages "," stage
            }
          }
          /^[[:space:]]*[a-zA-Z][a-zA-Z0-9]*:[[:space:]]*/ && !/^[[:space:]]{4,}/ {
            if (in_lbRoutings && $0 !~ /^[[:space:]]*lbRoutings:/) {
              in_lbRoutings = 0
            }
          }
          END {
            if (artifact && namespace && stages) {
              print namespace "\t" artifact "\t" stages
            }
          }
        ' "$file_path" 2>/dev/null)

        if [[ -n "$yaml_info" ]]; then
          # Parse the extracted information
          IFS=$'\t' read -r namespace artifact environments <<< "$yaml_info"

          # Split environments and create entries for each
          IFS=',' read -r -A env_array <<< "$environments"
          for env in "${env_array[@]}"; do
            env=$(echo "$env" | xargs)  # Trim whitespace

            # If environment filter is specified, only include matching environments
            if [[ -n "$env_filter" ]]; then
              # Split the filter into an array
              IFS=',' read -r -A filter_array <<< "$env_filter"
              local env_matched=false

              for filter in "${filter_array[@]}"; do
                filter=$(echo "$filter" | xargs)  # Trim whitespace
                if [[ "$env" == *"$filter"* ]]; then
                  env_matched=true
                  break
                fi
              done

              # Only add if environment matches the filter
              if [[ "$env_matched" == true ]]; then
                echo "$namespace	$artifact	$env" >> "$temp_file"
              fi
            else
              # No filter, include all environments
              [[ -n "$env" ]] && echo "$namespace	$artifact	$env" >> "$temp_file"
            fi
          done
        fi
      fi
    done <<< "$file_list"

    # Stop loading animation silently
    if [[ "$LOADING_ACTIVE" == true ]]; then
      LOADING_ACTIVE=false
      set +m
      if [[ -n "$LOADING_PID" ]]; then
        kill -TERM "$LOADING_PID" 2>/dev/null
        wait "$LOADING_PID" 2>/dev/null
      fi
      set -m
      # Clear the loading line without showing completion
      printf "\r\033[K"
      LOADING_PID=""
    fi

    # Display results in a clean format
    if [[ -s "$temp_file" ]]; then
      if [[ -n "$env_filter" ]]; then
        echo -e "${STD_PUR}Filtered by environments: ${STD_YEL}${env_filter}${RST}"
      fi
      echo -e "${PUR}========================${RST}"
      echo ""

      # First, show all sledge commands without executing them
      local commands=()
      local namespaces=()
      local artifacts=()
      local environments=()

      while IFS=$'\t' read -r namespace artifact environment; do
        [[ -z "$namespace" ]] && continue

        # Create the sledge command with colors
        local colored_command="${BLU}sledge wcnp describe app ${BRN}${artifact}${RST}-${RED}${environment}${RST} ${BLU}-n ${SKY}${namespace}${RST}"
        local plain_command="sledge wcnp describe app ${artifact}-${environment} -n ${namespace}"

        # Store command details for later use
        commands+=("$plain_command")
        namespaces+=("$namespace")
        artifacts+=("$artifact")
        environments+=("$environment")

        # Display the command without version
        echo -e "${colored_command}"

      done < <(sort -u "$temp_file")

      echo ""
      echo -n "${STD_PUR}Load versions? (y/yes to load, Enter to exit): ${RST}"
      read load_versions </dev/tty

      if [[ "${load_versions:l}" == "y" || "${load_versions:l}" == "yes" ]]; then
        # Clear the screen area where commands were displayed
        local num_commands=${#commands[@]}
        for ((j=0; j<num_commands+2; j++)); do
          echo -ne "\033[1A\033[K"  # Move up one line and clear it
        done

        # First, show all applications to be queried
        echo -e "${STD_GRN}Loading version information for ${#commands[@]} application(s)...${RST}"
        for i in {1..${#commands[@]}}; do
          local namespace="${namespaces[$i]}"
          local artifact="${artifacts[$i]}"
          local environment="${environments[$i]}"
          echo -e "${BLU}sledge ${RST}wcnp describe app ${BRN}${artifact}${RST}-${RED}${environment}${RST} ${STD_CYN}-n ${SKY}${namespace}${RST}"
        done
        echo ""

        # Now execute commands and show results in compact format
        for i in {1..${#commands[@]}}; do
          local namespace="${namespaces[$i]}"
          local artifact="${artifacts[$i]}"
          local environment="${environments[$i]}"
          local plain_command="${commands[$i]}"

          # Start individual timing
          local cmd_start_time=$(date +%s)

          # Execute the command and extract version (suppress output)
          local temp_output=$(mktemp)
          eval "$plain_command" > "$temp_output" 2>&1
          local exit_code=$?

          # Calculate execution time
          local cmd_end_time=$(date +%s)
          local cmd_elapsed=$((cmd_end_time - cmd_start_time))

          local version_info=""
          if [[ $exit_code -eq 0 ]]; then
            # Extract version information from output
            version_info=$(grep "app.kubernetes.io/version" "$temp_output" | sed 's/.*app\.kubernetes\.io\/version[[:space:]]*:[[:space:]]*//' | sed 's/[[:space:]]*│.*$//' | sed 's/\.\.$//' | tail -1)

            # If no app.kubernetes.io/version found, try version: pattern
            if [[ -z "$version_info" || "$version_info" == *"│"* || "$version_info" == *"="* ]]; then
              version_info=$(grep -E "│.*version[[:space:]]*:[[:space:]]*v" "$temp_output" | sed 's/.*version[[:space:]]*:[[:space:]]*//' | sed 's/[[:space:]]*│.*$//' | sed 's/\.\.$//' | tail -1)
            fi

            # Clean up version info
            if [[ -n "$version_info" && "$version_info" != *"│"* && "$version_info" != *"="* ]]; then
              version_info=$(echo "$version_info" | sed 's/^v//')
            else
              version_info="Not found"
            fi
          else
            version_info="Command failed"
          fi

          # Display result in compact format
          printf "${CYN}[${i}/${#commands[@]}] ${BRN}%-25s${RST} ${RED}%-15s${RST} ${STD_GRN}[%s]${RST} ${STD_CYN}[%ss]${RST}\n" \
            "$artifact" "$environment" "$version_info" "$cmd_elapsed"

          # Clean up temp file
          rm -f "$temp_output"
        done
      else
        echo -e "${STD_YEL}Exiting without loading versions.${RST}"
      fi

    else
      echo -e "${STD_RED}No matching YAML files found or unable to extract information.${RST}"
    fi

    # Clean up temp file
    rm -f "$temp_file"

  else
    # KEY-VALUE SEARCH MODE: Similar to findkey functionality
    local files=()

    # Parse file list into array
    while IFS= read -r line; do
      # Skip lines that don't look like file paths
      [[ -z "$line" ]] && continue
      [[ "$line" == *"Completed"* ]] && continue
      [[ "$line" == *"Directory:"* ]] && continue
      [[ "$line" == *"Searching"* ]] && continue
      [[ "$line" == *"Found"* ]] && continue
      [[ "$line" == *"files"* ]] && continue
      [[ "$line" =~ "^\|" ]] && continue
      [[ "$line" =~ "^-" ]] && continue
      [[ -f "$line" ]] && files+=("$line")
    done <<< "$file_list"

    if [[ ${#files[@]} -eq 0 ]]; then
      echo "No YAML file(s) found." >&2
      return 1
    fi

    # Filter files by environment if env_filter is specified
    if [[ -n "$env_filter" ]]; then
      local filtered_files=()
      for yml_file in "${files[@]}"; do
        # Check if file matches environment filter
        local file_matches=false
        IFS=',' read -r -A filter_array <<< "$env_filter"
        for filter in "${filter_array[@]}"; do
          filter=$(echo "$filter" | xargs)  # Trim whitespace
          if [[ "$yml_file" == *"$filter"* ]]; then
            file_matches=true
            break
          fi
        done

        if [[ "$file_matches" == true ]]; then
          filtered_files+=("$yml_file")
        fi
      done
      files=("${filtered_files[@]}")

      if [[ ${#files[@]} -eq 0 ]]; then
        echo -e "${STD_RED}No YAML files found matching environment filter: ${env_filter}${RST}" >&2
        return 1
      fi
    fi

    for yml_file in "${files[@]}"; do
      echo -e "\n${BLU}File:${RST} ${yml_file}"
      if [[ -z "$search_keys" ]]; then
        # Show all keys if no specific keys requested
        grep -E '^[ \t]*[a-zA-Z0-9_-]+[ \t]*:' "$yml_file" | while IFS= read -r line; do
          k=$(echo "$line" | sed -E 's/^[ \t]*([a-zA-Z0-9_-]+)[ \t]*:.*/\1/')
          v=$(echo "$line" | sed -E 's/^[ \t]*[a-zA-Z0-9_-]+[ \t]*:[ \t]*//')
          v=$(echo "$v" | sed -E 's/^"(.*)"$/\1/')
          for part in ${(z)v}; do
            if [[ "$part" == *"="* ]]; then
              subk="${part%%=*}"
              subval="${part#*=}"
              echo -e "  ${BRN}${subk}${RST}=${subval}"
            else
              echo -e "  ${BRN}${k}${RST}=${STD_WHT}${part}${RST}"
            fi
          done
        done
      else
        # Search for specific keys
        IFS=',' read -r -A keys <<< "$search_keys"
        for key in "${keys[@]}"; do
          # Find line numbers for the key (case-insensitive) - allow any amount of indentation
          key_lines=()
          while IFS= read -r linenum; do
            key_lines+=("$linenum")
          done < <(grep -inE "^[[:space:]]*${key}[[:space:]]*:" "$yml_file" | cut -d: -f1)
          if [[ ${#key_lines[@]} -eq 0 ]]; then
            echo -e "  ${STD_RED}Key '${key}' not found in ${yml_file}.${RST}"
            continue
          fi
          for lnum in "${key_lines[@]}"; do
            # Get the line content
            line=$(sed -n "${lnum}p" "$yml_file")
            # Check if value is block scalar (| or >)
            if echo "$line" | grep -qE ':[[:space:]]*[|>]'; then
              # Get indentation
              indent=$(echo "$line" | grep -oE '^[[:space:]]*')
              next_lnum=$((lnum+1))
              value=""
              while :; do
                next_line=$(sed -n "${next_lnum}p" "$yml_file")
                # Stop if next line is not more indented
                if [[ -z "$next_line" ]] || [[ ! "$next_line" =~ ^${indent}[[:space:]]+ ]]; then
                  break
                fi
                # Remove leading indentation
                clean_line=$(echo "$next_line" | sed -E "s/^${indent}[[:space:]]+//")
                value+="$clean_line "
                next_lnum=$((next_lnum+1))
              done
              # Parse the value for key=value pairs
              for part in ${(z)value}; do
                if [[ "$part" == *"="* ]]; then
                  k="${part%%=*}"
                  val="${part#*=}"
                  echo -e "  ${STD_YEL}${k}${RST}=${val}"
                else
                  echo -e "  ${STD_WHT}${part}${RST}"
                fi
              done
            else
              # Single-line value
              v=$(echo "$line" | sed -E 's/^[[:space:]]*[^:]+:[[:space:]]*//')
              v=$(echo "$v" | sed -E 's/^"(.*)"$/\1/')
              for part in ${(z)v}; do
                if [[ "$part" == *"="* ]]; then
                  k="${part%%=*}"
                  val="${part#*=}"
                  echo -e "  ${STD_YEL}${k}${RST}=${val}"
                else
                  echo -e "  ${STD_WHT}${part}${RST}"
                fi
              done
            fi
          done
        done
      fi
    done
  fi
}

