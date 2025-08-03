#!/bin/zsh

source .helper.sh

# Alias for file search script
alias fs='./.fileSearch.sh'

show_search_help() {
    echo ""
    echo -e "${STD_YEL}Description:${RST}"
    echo -e "  Extract and display information from kitt files with optional filtering"
    echo ""
    echo -e "${STD_YEL}Usage:${RST}"
    echo -e "  ${STD_CYN}search <file_paths> [environment_filter|search_keys] [-s|-kv|-y|-sy|-details|-show]${RST}"
    echo -e "  ${STD_CYN}<command> | search [environment_filter|search_keys] [-s|-kv|-y|-sy|-details|-show]${RST}"
    echo ""
    echo -e "${STD_YEL}Parameters:${RST}"
    echo -e "  file_paths           File paths or command substitution result"
    echo -e "  environment_filter   Filter by environment (qa, dev, prod, etc.) - used with -s flag"
    echo -e "  search_keys          Search for specific keys in files - used with -kv flag"
    echo -e "  -s, --sledge         Run sledge commands for version information"
    echo -e "  -kv, --key-value     Explicitly enable key-value search mode"
    echo -e "  -y, -sy, --yes       Auto-execute sledge commands without prompt"
    echo -e "  -details, --details  Extract detailed information (version, dashboard, logging URLs)"
    echo -e "  -show, --show        Display extracted information in tabular format"
    echo ""
    echo -e "${STD_YEL}Modes:${RST}"
    echo -e "  ${STD_GRN}String Search Mode (default):${RST}"
    echo -e "    Search for input string in files when no mode flags are specified"
    echo -e "  ${STD_GRN}Key-Value Search Mode (-kv flag):${RST}"
    echo -e "    Search for key-value pairs in configuration files"
    echo -e "  ${STD_GRN}Sledge Command Mode (-s flag):${RST}"
    echo -e "    Extract version information using sledge commands"
    echo -e "  ${STD_GRN}Details Mode (-details flag):${RST}"
    echo -e "    Extract detailed information including version, dashboard and logging URLs"
    echo -e "  ${STD_GRN}Show Mode (-show flag):${RST}"
    echo -e "    Display extracted namespace, artifact, environment, and cluster_id in tabular format"
    echo -e "  ${STD_GRN}Auto-Execute Mode (-y/-sy flags):${RST}"
    echo -e "    Automatically execute sledge commands without user confirmation"
    echo ""
    echo -e "${STD_YEL}Examples:${RST}"
    echo -e "  ${STD_GRN}String Search Mode (default):${RST}"
    echo -e "  ${STD_CYN}search \"\$(fs -fr aos,os/default-fc stg-config.yml)\" java_opts${RST}      # Search for 'java_opts' string"
    echo -e "  ${STD_CYN}search \"\$(fs -fr aos,os/default-fc stg-config.yml)\"${RST}               # Show file contents"
    echo ""
    echo -e "  ${STD_GRN}Key-Value Search Mode:${RST}"
    echo -e "  ${STD_CYN}search \"\$(fs -fr aos,os/default-fc stg-config.yml)\" java_opts -kv${RST}  # Search for 'java_opts' key"
    echo -e "  ${STD_CYN}search \"\$(fs -fr aos,os/default-fc stg-config.yml)\" -kv${RST}           # Show all keys"
    echo -e "  ${STD_CYN}fs -fr aos,os/default-fc stg-config.yml | search -kv${RST}                # Show all keys"
    echo -e "  ${STD_CYN}fs -fr aos,os/default-fc stg-config.yml | search java_opts -kv${RST}      # Search key in files"
    echo ""
    echo -e "  ${STD_GRN}Sledge Command Mode:${RST}"
    echo -e "  ${STD_CYN}search \"\$(fs -fr aos,os/default-fc pre-main)\" stg -s${RST}            # Run sledge commands for stg"
    echo -e "  ${STD_CYN}search \"\$(fs -fr gdm/default-fc pre-main)\" -s${RST}                   # No filter, show all"
    echo -e "  ${STD_CYN}search \"\$(fs -fr nte/default-fc pre-main)\" stg -y${RST}              # Auto-execute for stg"
    echo -e "  ${STD_CYN}fs -fr nte/default-fc pre-main | search stg -s${RST}                     # Use with pipe"
    echo -e "  ${STD_CYN}search \"\$(fs -fr nte/default-fc pre-main)\" -sy${RST}                  # Auto-execute all"
    echo ""
    echo -e "  ${STD_GRN}Details Mode:${RST}"
    echo -e "  ${STD_CYN}search \"\$(fs -fr aos,os/default-fc pre-main)\" stg -details${RST}      # Get detailed info for stg"
    echo -e "  ${STD_CYN}search \"\$(fs -fr gdm/default-fc pre-main)\" -details${RST}             # Get details for all"
    echo -e "  ${STD_CYN}fs -fr nte/default-fc pre-main | search -details${RST}                   # Details with pipe"
    echo ""
    echo -e "  ${STD_GRN}Show Mode:${RST}"
    echo -e "  ${STD_CYN}search \"\$(fs -fr aos,os/default-fc pre-main)\" stg -show${RST}         # Show table for stg"
    echo -e "  ${STD_CYN}search \"\$(fs -fr gdm/default-fc pre-main)\" -show${RST}                # Show table for all"
    echo -e "  ${STD_CYN}fs -fr nte/default-fc pre-main | search -show${RST}                      # Table with pipe"
    echo ""
}

# Helper function to extract YAML information from files
extract_yaml_info() {
  local file_list="$1"
  local env_filter="$2"
  local temp_file="$3"
  
  # Quick check if we have any input at all
  [[ -z "$file_list" ]] && return 1
  
  # Collect all valid YAML files first (optimized filtering)
  local yaml_files=()
  while IFS= read -r file_path; do
    # Skip empty lines and common non-file patterns in one check
    [[ -z "$file_path" || "$file_path" == *"Found"* || "$file_path" == *"Directory:"* || "$file_path" == *"Searching"* || "$file_path" == *"Completed"* ]] && continue
    
    # Only add valid YAML files (check extension and existence)
    [[ "$file_path" == *".yml" && -f "$file_path" ]] && yaml_files+=("$file_path")
  done <<< "$file_list"
  
  # Early return if no valid files found
  [[ ${#yaml_files[@]} -eq 0 ]] && return 1
  
  # Determine output mode based on temp file name (show_mode detection)
  local is_show_mode=false
  [[ "$temp_file" == *"show_mode"* ]] && is_show_mode=true
  
  # Process each file individually for better compatibility and performance
  for yaml_file in "${yaml_files[@]}"; do
    awk -v env_filter="$env_filter" -v is_show_mode="$is_show_mode" '
      BEGIN {
        in_gslb = in_lbRoutings = in_stages = in_target = 0
        current_stage = stages = artifact = namespace = cluster = stage_cluster_map = ""
      }
      
      # Core field extraction (optimized patterns)
      /^[ \t]*artifact:[ \t]*/ { 
        artifact = substr($0, index($0, ":") + 1)
        gsub(/^[ \t]+|[ \t]+$/, "", artifact)
      }
      /^[ \t]*namespace:[ \t]*/ { 
        namespace = substr($0, index($0, ":") + 1)
        gsub(/^[ \t]+|[ \t]+$/, "", namespace)
      }
      
      # GSLB lbRoutings section processing - extract env and matchStages
      /^[ \t]*gslb:[ \t]*$/ { in_gslb = 1 }
      in_gslb && /^[ \t]*lbRoutings:[ \t]*$/ { in_lbRoutings = 1 }
      in_gslb && in_lbRoutings && /^[ \t]*[a-zA-Z0-9-]+:[ \t]*$/ {
        env_name = $0
        gsub(/^[ \t]+|[ \t]+$/, "", env_name)
        gsub(/:.*$/, "", env_name)
        if (env_name != "lbRoutings" && env_name != "stages" && env_name != "cnames" && env_name != "helm" && env_name != "") {
          current_gslb_env = env_name
          if (stages == "") {
            stages = env_name
          } else {
            stages = stages "," env_name
          }
        }
      }
      
      # Extract matchStages for current gslb environment
      in_gslb && in_lbRoutings && current_gslb_env != "" && /^[ \t]*matchStages:[ \t]*\[/ {
        match_stages_line = $0
        gsub(/^[ \t]*matchStages:[ \t]*\[/, "", match_stages_line)
        gsub(/\].*$/, "", match_stages_line)
        gsub(/[ \t"]+/, "", match_stages_line)
        # Store the mapping: gslb_env -> match_stages
        if (match_stages_line != "") {
          gslb_to_stages[current_gslb_env] = match_stages_line
        }
      }
      
      # Stages section processing - to get cluster_id for matchStages
      /^[ \t]*stages:[ \t]*$/ { 
        in_stages = 1
        in_target = 0
        in_gslb = 0
        in_lbRoutings = 0
        current_gslb_env = ""
      }
      
      # Stage name extraction (when in stages section)
      in_stages && /^[ \t]*-[ \t]*name:[ \t]*/ {
        current_stage = substr($0, index($0, "name:") + 5)
        gsub(/^[ \t]+|[ \t]+$/, "", current_stage)
        in_target = 0
      }
      
      # Target section detection
      in_stages && /^[ \t]*target:[ \t]*$/ { in_target = 1 }
      
      # Cluster ID extraction (to map stages to cluster_ids)
      in_stages && in_target && /^[ \t]*-[ \t]*cluster_id:[ \t]*/ {
        cluster_line = substr($0, index($0, "cluster_id:") + 11)
        gsub(/^[ \t\[]+|[ \t\]]+$/, "", cluster_line)  # Remove brackets and whitespace
        gsub(/"[ \t]*,[ \t]*"/, ",", cluster_line)     # Clean quoted comma-separated values
        gsub(/^"|"$/, "", cluster_line)                # Remove surrounding quotes
        
        if (cluster_line != "" && current_stage != "") {
          # Store stage -> cluster mapping
          stage_to_cluster[current_stage] = cluster_line
        }
      }
      
      # Reset flags on new sections (optimized)
      /^[ \t]*[a-zA-Z][a-zA-Z0-9]*:[ \t]*/ && !/^[ \t]{4,}/ && $0 !~ /^[ \t]*(gslb|lbRoutings):/ { 
        in_gslb = 0
        in_lbRoutings = 0
      }
      
      # Output processing at end of file
      END {
        if (namespace != "" && artifact != "") {
          if (is_show_mode == "true") {
            # Show mode: simple comma-separated output
            if (cluster != "") print namespace "," artifact "," cluster
          } else {
            # Normal mode: map gslb environments to their cluster_ids via matchStages
            if (stages != "") {
              n = split(stages, gslb_envs, ",")
              for (i = 1; i <= n; i++) {
                gslb_env = gslb_envs[i]
                if (gslb_env in gslb_to_stages) {
                  match_stage = gslb_to_stages[gslb_env]
                  if (match_stage in stage_to_cluster) {
                    cluster_val = stage_to_cluster[match_stage]
                    # Apply environment filter if specified (handle comma-separated filters)
                    should_include = 0
                    if (env_filter == "") {
                      should_include = 1
                    } else {
                      # Split env_filter by comma and check each filter
                      n_filters = split(env_filter, filter_array, ",")
                      for (f = 1; f <= n_filters; f++) {
                        filter_term = filter_array[f]
                        gsub(/^[ \t]+|[ \t]+$/, "", filter_term)  # Trim whitespace
                        if (index(gslb_env, filter_term) > 0) {
                          should_include = 1
                          break
                        }
                      }
                    }
                    if (should_include) {
                      print namespace "\t" artifact "\t" cluster_val "\t" gslb_env
                    }
                  } else {
                    # If no matching stage found, use default cluster
                    should_include = 0
                    if (env_filter == "") {
                      should_include = 1
                    } else {
                      # Split env_filter by comma and check each filter
                      n_filters = split(env_filter, filter_array, ",")
                      for (f = 1; f <= n_filters; f++) {
                        filter_term = filter_array[f]
                        gsub(/^[ \t]+|[ \t]+$/, "", filter_term)  # Trim whitespace
                        if (index(gslb_env, filter_term) > 0) {
                          should_include = 1
                          break
                        }
                      }
                    }
                    if (should_include) {
                      print namespace "\t" artifact "\tdefault-cluster\t" gslb_env
                    }
                  }
                } else {
                  # If no matchStages found, use default cluster
                  should_include = 0
                  if (env_filter == "") {
                    should_include = 1
                  } else {
                    # Split env_filter by comma and check each filter
                    n_filters = split(env_filter, filter_array, ",")
                    for (f = 1; f <= n_filters; f++) {
                      filter_term = filter_array[f]
                      gsub(/^[ \t]+|[ \t]+$/, "", filter_term)  # Trim whitespace
                      if (index(gslb_env, filter_term) > 0) {
                        should_include = 1
                        break
                      }
                    }
                  }
                  if (should_include) {
                    print namespace "\t" artifact "\tdefault-cluster\t" gslb_env
                  }
                }
              }
            }
          }
        }
      }
    ' "$yaml_file" >> "$temp_file"
  done
}

# Helper function to execute command with loading animation
execute_command_with_loading() {
    local cmd="$1"
    local cmd_num="$2"
    local cmd_namespace="$3"
    local cmd_artifact="$4"
    local cmd_environment="$5"
    local cmd_cluster="$6"
    local mode="$7"  # New parameter for mode (sledge or details)
    
    # local loading_message="${STG_CYN}${cmd_num}${RST} ${BRN}Namespace:${RST} ${cmd_namespace} | ${SKY}Artifact:${RST} ${cmd_artifact} | ${STG_CYN}Environment:${RST} ${cmd_environment} | ${PUR}Cluster:${RST} ${cmd_cluster}"
    local loading_message=$'\033[0;36m'"${cmd_num}"$'\033[0m Namespace: \033[0;36m'"${cmd_namespace}"$'\033[0m | App: \033[1;96m'"${cmd_artifact}"$'\033[0m-\033[0;36m'"${cmd_environment}"$'\033[0m | Cluster: \033[1;95m'"${cmd_cluster}"$'\033[0m'
    
    # Start loading animation (will automatically detect if in terminal/pipe context)
    start_loading "$loading_message"
    
    # Execute the command and capture details based on mode
    if [[ "$mode" == "details" ]]; then
        # For details mode: show version, dashboard, and logging
        # Execute the command and capture output using temp file to avoid subshell issues
        local temp_output=$(mktemp)
        eval "$cmd" > "$temp_output" 2>/dev/null
        local details=""
        if [[ -s "$temp_output" ]]; then
            details=$(cat "$temp_output" | jsonExtract "" "app.kubernetes.io/version,dashboard,logging,availableReplicas,Pipelines,cNameEndpoints")
        fi
        rm -f "$temp_output"
        
        # Stop loading animation and clear the line
        stop_loading
        
        # Show final result with basic info (with colors)
        # echo -e "${STD_CYN}${cmd_num}${RST} Namespace: ${STD_CYN}${cmd_namespace}${RST} | App: ${SKY}${cmd_artifact}${RST}-${STD_CYN}${cmd_environment}${RST} | Cluster: ${PUR}${cmd_cluster}${RST}"
        printf "\r\033[K${YEL}✓${RST} %ss | ${STD_CYN}%s${RST} Namespace: ${STD_CYN}%s${RST} | App: ${SKY}%s${RST}-${STD_CYN}%s${RST} | Cluster: ${PUR}%s${RST}\n" "$(($(date +%s) - LOADING_START_TIME))" "${cmd_num}" "${cmd_namespace}" "${cmd_artifact}" "${cmd_environment}" "${cmd_cluster}"
        echo "--------------------------------------------------------------------------------------------------"
        # Show detailed information
        echo "$details"
        echo ""
    else
        # For sledge mode: show only version
        # Execute the command and capture output using temp file to avoid subshell issues
        local temp_output=$(mktemp)
        eval "$cmd" > "$temp_output" 2>/dev/null
        local version=""
        if [[ -s "$temp_output" ]]; then
            local version_line=$(cat "$temp_output" | jsonExtract "" "app.kubernetes.io/version" | head -1)
            if [[ -n "$version_line" ]]; then
                version=$(echo "$version_line" | cut -d'=' -f2)
            fi
        fi
        rm -f "$temp_output"
        
        # Stop loading animation and clear the line
        stop_loading
        
        # Show final result with checkmark, time and version in one line (overwrite the stop_loading output)
        printf "\r\033[K${YEL}✓${RST} %ss | ${STD_CYN}%s${RST} Namespace: ${STD_CYN}%s${RST} | App: ${SKY}%s${RST}-${STD_CYN}%s${RST} | Cluster: ${PUR}%s${RST} | Version: ${STD_GRN}%s${RST}\n" "$(($(date +%s) - LOADING_START_TIME))" "${cmd_num}" "${cmd_namespace}" "${cmd_artifact}" "${cmd_environment}" "${cmd_cluster}" "${version}"
    fi
}

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
  local auto_execute=false
  local key_value_mode=false
  local details_mode=false
  local show_mode=false
  
  # Check for flags anywhere in arguments
  local args=("$@")
  local new_args=()
  
  for arg in "${args[@]}"; do
    case "$arg" in
      -s|--sledge)
        run_sledge=true
        ;;
      -kv|--key-value)
        key_value_mode=true
        ;;
      -y|--yes)
        auto_execute=true
        ;;
      -sy|--sledge-yes)
        run_sledge=true
        auto_execute=true
        ;;
      -details|--details)
        details_mode=true
        run_sledge=true
        ;;
      -show|--show)
        show_mode=true
        ;;
      *)
        new_args+=("$arg")
        ;;
    esac
  done
  
  # Update positional parameters with filtered args
  set -- "${new_args[@]}"
  
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
      elif [[ "$key_value_mode" == true ]]; then
        search_keys="$1"
      else
        search_keys="$1"  # Default string search
      fi
    elif [[ $# -eq 2 ]]; then
      file_list="$piped_data"
      if [[ "$run_sledge" == true || "$show_mode" == true ]]; then
        env_filter="$1"
      elif [[ "$key_value_mode" == true ]]; then
        search_keys="$1"
        env_filter="$2"
      else
        search_keys="$1"  # Default string search
        env_filter="$2"
      fi
    fi
  else
    # Handle arguments (backward compatible)
    if [[ $# -eq 0 ]]; then
      echo -e "${STD_RED}Usage: search <file_paths> [environment_filter|search_keys] [-s|-kv|-y|-sy]"
      echo -e "${STD_GRN}Example: search \"\$(fs -fr aos/default-fc pre-main)\" qa -s     # Run sledge commands"
      echo -e "${STD_GRN}Example: search \"\$(fs -fr aos/default-fc pre-main)\" qa -y     # Auto-execute for qa"
      echo -e "${STD_GRN}Example: search \"\$(fs -fr aos/default-fc pre-main)\" artifact -kv  # Search for 'artifact' key"
      echo -e "${STD_GRN}Example: search \"\$(fs -fr aos/default-fc pre-main)\" artifact  # Search for 'artifact' string"
      return 1
    elif [[ $# -eq 1 ]]; then
      file_list="$1"
    else
      file_list="$1"
      if [[ "$run_sledge" == true || "$show_mode" == true ]]; then
        # For sledge/show mode, second argument (if exists) is environment filter
        if [[ $# -eq 2 ]]; then
          env_filter="$2"
        fi
      elif [[ "$key_value_mode" == true ]]; then
        # For key-value mode, second argument is search keys
        search_keys="$2"
        # Third argument (if exists) is environment filter
        if [[ $# -eq 3 ]]; then
          env_filter="$3"
        fi
      else
        # For default string search mode, second argument is search string
        search_keys="$2"
        # Third argument (if exists) is environment filter
        if [[ $# -eq 3 ]]; then
          env_filter="$3"
        fi
      fi
    fi
  fi
  
  # If no input provided, show usage
  if [[ -z "$file_list" ]]; then
    echo -e "${STD_RED}Usage: search <file_paths> [environment_filter|search_keys] [-s|-kv|-y|-sy|-show]"
    echo -e "${STD_GRN}Example: search \"\$(fs -fr aos/default-fc pre-main)\" qa -s     # Run sledge commands"
    echo -e "${STD_GRN}Example: search \"\$(fs -fr aos/default-fc pre-main)\" qa -y     # Auto-execute for qa"
    echo -e "${STD_GRN}Example: search \"\$(fs -fr aos/default-fc pre-main)\" artifact -kv  # Search for 'artifact' key"
    echo -e "${STD_GRN}Example: search \"\$(fs -fr aos/default-fc pre-main)\" artifact  # Search for 'artifact' string"
    echo -e "${STD_GRN}Example: search \"\$(fs -fr aos/default-fc pre-main)\" qa -show  # Show table format"
    return 1
  fi
  
  # Choose the appropriate processing mode
  if [[ "$show_mode" == true ]]; then
    # SHOW MODE: Display extracted information in tabular format
    # Create temporary file for processing (with special name to trigger grouping)
    local temp_file=$(mktemp)
    
    # Use helper function to extract YAML information (grouped clusters)
    extract_yaml_info "$file_list" "$env_filter" "$temp_file"
    
    # Display results in tabular format
    if [[ -s "$temp_file" ]]; then
      if [[ -n "$env_filter" ]]; then
        echo -e "${STD_PUR}Filtered by: ${STD_YEL}${env_filter}${RST}"
      fi      
      
      # Display table header
      printf "${STD_YEL}%-30s %-30s %-15s %-40s${RST}\n" "NAMESPACE" "ARTIFACT" "ENVIRONMENT" "CLUSTER_ID"
      printf "${STD_YEL}%-30s %-30s %-15s %-40s${RST}\n" "$(printf '%*s' 30 | tr ' ' '-')" "$(printf '%*s' 30 | tr ' ' '-')" "$(printf '%*s' 15 | tr ' ' '-')" "$(printf '%*s' 40 | tr ' ' '-')"
      
      # Display sorted and unique entries
      while IFS=$'\t' read -r namespace artifact cluster environment; do
        [[ -z "$namespace" ]] && continue
        printf "${BRN}%-30s${RST} ${SKY}%-30s${RST} ${STD_CYN}%-15s${RST} ${PUR}%-40s${RST}\n" "$namespace" "$artifact" "$environment" "$cluster"
      done < <(sort -u "$temp_file")
    else
      echo -e "${STD_RED}No matching YAML files found or unable to extract information.${RST}"
    fi
    
    # Clean up temp file
    rm -f "$temp_file"
    
  elif [[ "$run_sledge" == true ]]; then
    # SLEDGE MODE: Generate and execute sledge commands
    # Create temporary file for processing
    local temp_file=$(mktemp)
    
    # Use helper function to extract YAML information
    extract_yaml_info "$file_list" "$env_filter" "$temp_file"
    
    # Check if we have data to work with
    if [[ -s "$temp_file" ]]; then
      if [[ -n "$env_filter" ]]; then
        echo -e "${STD_PUR}Filtered by: ${STD_YEL}${env_filter}${RST}"
      fi      
      
      # Create temporary files to store commands and details
      local commands_file=$(mktemp)
      local details_file=$(mktemp)
      local command_count=0
      
      # Generate sledge commands
      while IFS=$'\t' read -r namespace artifact cluster environment; do
        [[ -z "$namespace" ]] && continue
        
        # Get first cluster ID for the command
        first_cluster=$(echo "$cluster" | cut -d',' -f1)
        
        # Build sledge command
        sledge_cmd="sledge wcnp describe app ${artifact}-${environment} -n ${namespace} -c ${first_cluster} --json"
        echo "$sledge_cmd" >> "$commands_file"
        echo "${namespace}|${artifact}|${environment}|${first_cluster}" >> "$details_file"
        ((command_count++))
      done < <(sort -u "$temp_file")
      
      if [[ $command_count -eq 0 ]]; then
        echo -e "${STD_RED}No sledge commands to generate.${RST}"
        rm -f "$temp_file" "$commands_file" "$details_file"
        return 1
      fi
      
      # Display all sledge commands with numbers and colors matching the table
      # echo -e "${STD_YEL}Generated Sledge Commands:${RST}"
      echo ""
      
      local cmd_num=1
      while IFS= read -r cmd && IFS='|' read -r cmd_namespace cmd_artifact cmd_environment cmd_cluster <&3; do
        # Create colored version of the command
        echo -e "${STD_CYN}${cmd_num}.${RST} ${STD_GRN}sledge${RST} wcnp describe app ${SKY}${cmd_artifact}${RST}-${STD_CYN}${cmd_environment}${RST} -n ${BRN}${cmd_namespace}${RST} -c ${PUR}${cmd_cluster}${RST} --json"
        ((cmd_num++))
      done < "$commands_file" 3< "$details_file"
      
      # Auto-execute if auto_execute flag is set
      if [[ "$auto_execute" == true ]]; then
        echo ""
        
        cmd_num=1
        while IFS= read -r cmd && IFS='|' read -r cmd_namespace cmd_artifact cmd_environment cmd_cluster <&3; do
          # Execute command with loading animation and simplified output
          local mode_param="sledge"
          if [[ "$details_mode" == true ]]; then
            mode_param="details"
          fi
          execute_command_with_loading "$cmd" "$cmd_num" "$cmd_namespace" "$cmd_artifact" "$cmd_environment" "$cmd_cluster" "$mode_param"
          ((cmd_num++))
        done < "$commands_file" 3< "$details_file"
      else
        # Interactive mode - prompt user for selection
        while true; do
          echo -e "${STD_YEL}Choose to execute [ ${STD_GRN}y/yes${STD_YEL} : all | ${STD_CYN}1-4${STD_YEL} : range | ${STD_CYN}1,3,4${STD_YEL} : multiple select | ${STD_RED}enter${STD_YEL} to exit ]${RST} : \c"
          read -r user_selection < /dev/tty
          
          # Handle empty input (exit)
          if [[ -z "$user_selection" || "$user_selection" == "q" ]]; then
            echo -e "${STD_YEL}Exiting sledge mode.${RST}"
            break
          fi
          
          # Handle "all" selection
          if [[ "$user_selection" =~ ^(y|yes|Y|YES)$ ]]; then
            echo ""
            
            cmd_num=1
            while IFS= read -r cmd && IFS='|' read -r cmd_namespace cmd_artifact cmd_environment cmd_cluster <&3; do
              # Execute command with loading animation and simplified output
              local mode_param="sledge"
              if [[ "$details_mode" == true ]]; then
                mode_param="details"
              fi
              execute_command_with_loading "$cmd" "$cmd_num" "$cmd_namespace" "$cmd_artifact" "$cmd_environment" "$cmd_cluster" "$mode_param"
              ((cmd_num++))
            done < "$commands_file" 3< "$details_file"
            break
          fi
          
          # Handle range selection (e.g., "1-3")
          if [[ "$user_selection" =~ ^[0-9]+-[0-9]+$ ]]; then
            start_num=$(echo "$user_selection" | cut -d'-' -f1)
            end_num=$(echo "$user_selection" | cut -d'-' -f2)
            
            # Validate range
            if [[ $start_num -ge 1 && $end_num -le $command_count && $start_num -le $end_num ]]; then
              echo ""
              
              cmd_num=1
              while IFS= read -r cmd && IFS='|' read -r cmd_namespace cmd_artifact cmd_environment cmd_cluster <&3; do
                if [[ $cmd_num -ge $start_num && $cmd_num -le $end_num ]]; then
                  # Execute command with loading animation and simplified output
                  local mode_param="sledge"
                  if [[ "$details_mode" == true ]]; then
                    mode_param="details"
                  fi
                  execute_command_with_loading "$cmd" "$cmd_num" "$cmd_namespace" "$cmd_artifact" "$cmd_environment" "$cmd_cluster" "$mode_param"
                fi
                ((cmd_num++))
              done < "$commands_file" 3< "$details_file"
              break
            else
              echo -e "${STD_RED}Invalid range. Please enter a valid range (1-${command_count}).${RST}"
              continue
            fi
          fi
          
          # Handle multiple selection (e.g., "1,3,5")
          if [[ "$user_selection" =~ ^[0-9,]+$ ]]; then
            IFS=',' read -r -A selected_nums <<< "$user_selection"
            valid_selection=true
            
            # Validate all selected numbers
            for num in "${selected_nums[@]}"; do
              num=$(echo "$num" | xargs)  # Trim whitespace
              if [[ ! ($num -ge 1 && $num -le $command_count) ]]; then
                echo -e "${STD_RED}Invalid selection: ${num}. Please enter numbers between 1 and ${command_count}.${RST}"
                valid_selection=false
                break
              fi
            done
            
            if [[ "$valid_selection" == true ]]; then
              echo ""
              
              cmd_num=1
              while IFS= read -r cmd && IFS='|' read -r cmd_namespace cmd_artifact cmd_environment cmd_cluster <&3; do
                # Check if current command number is in selection
                for selected_num in "${selected_nums[@]}"; do
                  selected_num=$(echo "$selected_num" | xargs)
                  if [[ $cmd_num -eq $selected_num ]]; then
                    # Execute command with loading animation and simplified output
                    local mode_param="sledge"
                    if [[ "$details_mode" == true ]]; then
                      mode_param="details"
                    fi
                    execute_command_with_loading "$cmd" "$cmd_num" "$cmd_namespace" "$cmd_artifact" "$cmd_environment" "$cmd_cluster" "$mode_param"
                    break
                  fi
                done
                ((cmd_num++))
              done < "$commands_file" 3< "$details_file"
              break
            else
              continue
            fi
          fi
          
          # Invalid input
          echo -e "${STD_RED}Invalid input. Please try again.${RST}"
        done
      fi
      
      # Clean up temp files
      rm -f "$commands_file" "$details_file"
    else
      echo -e "${STD_RED}No matching YAML files found or unable to extract information.${RST}"
    fi
    
    # Clean up temp file
    rm -f "$temp_file"
    
  elif [[ "$key_value_mode" == true ]]; then
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
      echo "No files found." >&2
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
        echo -e "${STD_RED}No files found matching environment filter: ${env_filter}${RST}" >&2
        return 1
      fi
    fi
    
    for yml_file in "${files[@]}"; do
      echo -e "\n${BLU}File:${RST} ${yml_file}"
      if [[ -z "$search_keys" ]]; then
        # Show all key=value pairs found anywhere in the file
        echo -e "${STD_YEL}Searching for all key=value pairs in file...${RST}"
        
        # Create a temporary file to collect all key=value pairs and avoid duplicates
        local temp_kv_file=$(mktemp)
        
        # Search for key=value patterns throughout the entire file
        grep -n -E '[a-zA-Z0-9_.-]+=[a-zA-Z0-9_./:-]+' "$yml_file" | while IFS= read -r line; do
          line_num=$(echo "$line" | cut -d: -f1)
          content=$(echo "$line" | cut -d: -f2-)
          
          # Extract all key=value pairs from this line
          echo "$content" | grep -oE '[a-zA-Z0-9_.-]+=[a-zA-Z0-9_./:-]+' | while IFS= read -r pair; do
            if [[ "$pair" == *"="* && "$pair" != *"://"* ]]; then
              key="${pair%%=*}"
              value="${pair#*=}"
              echo "${key}=${value}|line ${line_num}" >> "$temp_kv_file"
            fi
          done
        done 2>/dev/null
        
        # Also search for key=value patterns in quoted strings
        grep -n -E '"[^"]*[a-zA-Z0-9_.-]+=[a-zA-Z0-9_./:-]+[^"]*"' "$yml_file" | while IFS= read -r line; do
          line_num=$(echo "$line" | cut -d: -f1)
          content=$(echo "$line" | cut -d: -f2-)
          
          # Extract quoted content and find key=value pairs within
          echo "$content" | sed -n 's/.*"\([^"]*\)".*/\1/p' | grep -oE '[a-zA-Z0-9_.-]+=[a-zA-Z0-9_./:-]+' | while IFS= read -r pair; do
            if [[ "$pair" == *"="* && "$pair" != *"://"* ]]; then
              key="${pair%%=*}"
              value="${pair#*=}"
              echo "${key}=${value}|line ${line_num} (quoted)" >> "$temp_kv_file"
            fi
          done
        done 2>/dev/null
        
        # Sort and display unique results
        if [[ -s "$temp_kv_file" ]]; then
          sort -u "$temp_kv_file" | while IFS='|' read -r pair location; do
            if [[ -n "$pair" && "$pair" == *"="* ]]; then
              key="${pair%%=*}"
              value="${pair#*=}"
              echo -e "  ${STD_GRN}${key}${RST}=${value}"
            fi
          done
        else
          echo -e "  ${STD_YEL}No key=value pairs found in the file${RST}"
        fi
        
        # Clean up temp file
        rm -f "$temp_kv_file"
      else
        # Search for specific keys in both YAML format and key=value format
        IFS=',' read -r -A keys <<< "$search_keys"
        for key in "${keys[@]}"; do
          key=$(echo "$key" | xargs)  # Trim whitespace
          echo -e "\n${STD_YEL}Searching for key '${key}'...${RST}"
          
          # Search for key=value patterns containing the key (partial match)
          local kv_results=$(grep -n -E "[a-zA-Z0-9_.-]*${key}[a-zA-Z0-9_.-]*=" "$yml_file" 2>/dev/null)
          if [[ -n "$kv_results" ]]; then
            echo "$kv_results" | while IFS= read -r line; do
              line_num=$(echo "$line" | cut -d: -f1)
              content=$(echo "$line" | cut -d: -f2-)
              
              # Extract all key=value pairs that match our key (partial match)
              echo "$content" | grep -oE "[a-zA-Z0-9_.-]*${key}[a-zA-Z0-9_.-]*=[a-zA-Z0-9_./:-]+" | while IFS= read -r pair; do
                if [[ "$pair" == *"="* ]]; then
                  found_key="${pair%%=*}"
                  value="${pair#*=}"
                  echo -e "  ${STD_GRN}${found_key}${RST}=${value}"
                fi
              done
            done
          fi
          
          # Search for YAML keys (partial match)
          local yaml_results=$(grep -n -E "^[[:space:]]*[a-zA-Z0-9_.-]*${key}[a-zA-Z0-9_.-]*[[:space:]]*:" "$yml_file" 2>/dev/null)
          if [[ -n "$yaml_results" ]]; then
            echo "$yaml_results" | while IFS= read -r line; do
              line_num=$(echo "$line" | cut -d: -f1)
              content=$(echo "$line" | cut -d: -f2-)
              yaml_key=$(echo "$line" | sed 's/^[0-9]*://g' | sed -n 's/^[[:space:]]*\([a-zA-Z0-9_.-]*\):.*/\1/p')
              if [[ -n "$yaml_key" ]]; then
                echo -e "  ${STD_GRN}${yaml_key}${RST}"
              fi
            done
          fi
          
          # If nothing found, show not found message
          if [[ -z "$kv_results" && -z "$yaml_results" ]]; then
            echo -e "  ${STD_RED}Key '${key}' not found in ${yml_file}.${RST}"
          fi
        done
      fi
    done
  else
    # DEFAULT STRING SEARCH MODE: Simple string search in files
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
      echo "No files found." >&2
      return 1
    fi
    
    # Filter files by environment if env_filter is specified
    if [[ -n "$env_filter" ]]; then
      local filtered_files=()
      for file in "${files[@]}"; do
        # Check if file matches environment filter
        local file_matches=false
        IFS=',' read -r -A filter_array <<< "$env_filter"
        for filter in "${filter_array[@]}"; do
          filter=$(echo "$filter" | xargs)  # Trim whitespace
          if [[ "$file" == *"$filter"* ]]; then
            file_matches=true
            break
          fi
        done
        
        if [[ "$file_matches" == true ]]; then
          filtered_files+=("$file")
        fi
      done
      files=("${filtered_files[@]}")
      
      if [[ ${#files[@]} -eq 0 ]]; then
        echo -e "${STD_RED}No files found matching environment filter: ${env_filter}${RST}" >&2
        return 1
      fi
    fi
    
    for file in "${files[@]}"; do
      echo -e "\n${BLU}File:${RST} ${file}"
      if [[ -z "$search_keys" ]]; then
        # Show file contents if no search string specified
        cat "$file"
      else
        # Search for the string in the file
        IFS=',' read -r -A search_terms <<< "$search_keys"
        for term in "${search_terms[@]}"; do
          term=$(echo "$term" | xargs)  # Trim whitespace
          echo -e "\n${STD_YEL}Searching for: ${term}${RST}"
          # Set grep colors to use green for matches
          GREP_COLORS='ms=01;32' grep -n -i --color=always "$term" "$file" || echo -e "  ${STD_RED}String '${term}' not found in ${file}.${RST}"
        done
      fi
    done
  fi
}


appversion() {
    # Simple direct command execution with output capture
    local output=""
    
    # Execute the sledge command directly and capture all output
    if command -v sledge >/dev/null 2>&1; then
        # Run the command with timeout and capture output
        output=$(timeout 30s bash -c "$*" 2>/dev/null | sed -r "s/\x1B\[[0-9;]*[a-zA-Z]//g" | sed 's/\x1B\][0-9];[^\a]*\a//g' | tr -cd '\11\12\15\40-\176')
    else
        echo "N/A"
        return 1
    fi

    # Check if output is JSON format (contains --json flag)
    if echo "$*" | grep -q -- "--json"; then
        # Parse JSON output for version
        echo "$output" | grep '"app\.kubernetes\.io/version"' | sed 's/.*"app\.kubernetes\.io\/version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/' | head -1
    else
        # Parse text output for version (legacy)
        echo "$output" | awk '/Labels/{flag=1; next} /Status/{flag=0} flag' | grep -E 'app.kubernetes.io/version[ ]*:' | head -1 | awk -F: '{gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2}'
    fi
}


jsonExtract() {
    local input="$1"
    local key_pattern="$2"
    
    # Check if input is a file, JSON string, or stdin
    local json_content=""
    
    # If no arguments provided and stdin is available, read from stdin
    if [[ $# -eq 0 ]] || [[ -z "$input" ]] && [[ ! -t 0 ]]; then
        json_content=$(cat)
    elif [[ -f "$input" ]]; then
        json_content=$(cat "$input")
    else
        json_content="$input"
    fi
    
    # Validate JSON
    if ! echo "$json_content" | jq . >/dev/null 2>&1; then
        echo "Error: Invalid JSON input" >&2
        return 1
    fi

    # Function to recursively flatten JSON
    flatten_json() {
        local json="$1"
        local prefix="$2"
        
        echo "$json" | jq -r --arg prefix "$prefix" '
            def flatten:
                . as $in
                | reduce paths(scalars) as $path (
                    {};
                    . + { ($path | map(tostring) | join(".")): $in | getpath($path) }
                );
            flatten | to_entries[] | 
            if $prefix == "" then
                "\(.key)=\(.value)"
            else
                # Support multiple patterns separated by comma, case-insensitive
                ($prefix | split(",") | map(. | gsub("^\\s+|\\s+$";"")) | .[]) as $pattern |
                if (.key | test($pattern; "i")) then
                    "\(.key)=\(.value)"
                else
                    empty
                end
            end
        ' | while IFS='=' read -r key value; do
            # Plain output without colors for version extraction            
            echo "${IPR}${key}${RST}=${value}"
        done
    }
    
    # Extract key-value pairs
    if [[ -z "$key_pattern" ]]; then
        # Extract all key-value pairs
        flatten_json "$json_content" ""
    else
        # Extract specific key pattern
        flatten_json "$json_content" "$key_pattern"
    fi
}

# Alias for help
alias help=show_functions
alias ss=search

