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
        in_stages = in_target = 0
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
      
      # Stages section processing
      /^[ \t]*stages:[ \t]*$/ { in_stages = 1; in_target = 0; stages = "" }
      
      # Stage name extraction (when in stages section)
      in_stages && /^[ \t]*-[ \t]*name:[ \t]*/ {
        current_stage = substr($0, index($0, "name:") + 5)
        gsub(/^[ \t]+|[ \t]+$/, "", current_stage)
        in_target = 0
        stages = (stages == "") ? current_stage : stages "," current_stage
      }
      
      # Target section detection
      in_stages && /^[ \t]*target:[ \t]*$/ { in_target = 1 }
      
      # Cluster ID extraction (optimized for performance)
      in_stages && in_target && /^[ \t]*-[ \t]*cluster_id:[ \t]*/ {
        cluster_line = substr($0, index($0, "cluster_id:") + 11)
        gsub(/^[ \t\[]+|[ \t\]]+$/, "", cluster_line)  # Remove brackets and whitespace
        gsub(/"[ \t]*,[ \t]*"/, ",", cluster_line)     # Clean quoted comma-separated values
        gsub(/^"|"$/, "", cluster_line)                # Remove surrounding quotes
        
        if (cluster_line != "" && current_stage != "") {
          stage_cluster_map = (stage_cluster_map == "") ? current_stage ":" cluster_line : stage_cluster_map ";" current_stage ":" cluster_line
          if (cluster == "") cluster = cluster_line  # Set default cluster
        }
      }
      
      # Reset flags on new sections (optimized)
      /^[ \t]*-[ \t]*name:[ \t]*/ { in_target = 0 }
      /^[ \t]*[a-zA-Z][a-zA-Z0-9]*:[ \t]*/ && !/^[ \t]{4,}/ && $0 !~ /^[ \t]*(stages|target):/ { in_target = 0 }
      
      # Output processing at end of file
      END {
        if (namespace != "" && artifact != "") {
          if (is_show_mode == "true") {
            # Show mode: simple comma-separated output
            if (cluster != "") print namespace "," artifact "," cluster
          } else {
            # Normal mode: detailed stage-cluster mapping
            if (stage_cluster_map != "") {
              n = split(stage_cluster_map, stages_arr, ";")
              for (i = 1; i <= n; i++) {
                if (split(stages_arr[i], stage_cluster, ":") == 2) {
                  stage = stage_cluster[1]
                  cluster_val = stage_cluster[2]
                  if (stage != "" && cluster_val != "") {
                    # Apply environment filter if specified
                    if (env_filter == "" || index(stage, env_filter) > 0) {
                      print namespace "\t" artifact "\t" cluster_val "\t" stage
                    }
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
      echo ""
      
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
    # SLEDGE MODE: Original vk functionality
    # Create temporary file for processing
    local temp_file=$(mktemp)
    
    # Use helper function to extract YAML information
    extract_yaml_info "$file_list" "$env_filter" "$temp_file"
    
    # Display results in a table format
    if [[ -s "$temp_file" ]]; then
      if [[ -n "$env_filter" ]]; then
        echo -e "${STD_PUR}Filtered by: ${STD_YEL}${env_filter}${RST}"
      fi      
      echo ""
      
      # Display table header
      printf "${STD_YEL}%-30s %-30s %-15s %-20s${RST}\n" "NAMESPACE" "ARTIFACT" "ENVIRONMENT" "CLUSTER_ID"
      printf "${STD_YEL}%-30s %-30s %-15s %-20s${RST}\n" "$(printf '%*s' 30 | tr ' ' '-')" "$(printf '%*s' 30 | tr ' ' '-')" "$(printf '%*s' 15 | tr ' ' '-')" "$(printf '%*s' 20 | tr ' ' '-')"
      
      # Display sorted and unique entries
      while IFS=$'\t' read -r namespace artifact cluster environment; do
        [[ -z "$namespace" ]] && continue
        printf "${BRN}%-30s${RST} ${SKY}%-30s${RST} ${STD_CYN}%-15s${RST} ${PUR}%-20s${RST}\n" "$namespace" "$artifact" "$environment" "$cluster"
      done < <(sort -u "$temp_file")
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
    # Run the command, clean output, extract Labels section, and get the version
    cleaned_output=$(expect -c "
    spawn $*
    expect \">\"
    send \"\r\"
    expect eof
    " | sed -r "s/\x1B\[[0-9;]*[a-zA-Z]//g" | sed 's/\x1B\][0-9];[^\a]*\a//g' | tr -cd '\11\12\15\40-\176')

    # Check if output is JSON format (contains --json flag)
    if echo "$*" | grep -q -- "--json"; then
        # Parse JSON output for version
        echo "$cleaned_output" | grep -o '"app\.kubernetes\.io/version"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"app\.kubernetes\.io\/version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/' | head -1
    else
        # Parse text output for version (legacy)
        echo "$cleaned_output" | awk '/Labels/{flag=1; next} /Status/{flag=0} flag' | grep -E 'app.kubernetes.io/version[ ]*:' | head -1 | awk -F: '{gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2}'
    fi
}

appdetails() {
    # Run the command, clean output, and extract dashboard and logging URLs
    cleaned_output=$(expect -c "
    spawn $*
    expect \">\"
    send \"\r\"
    expect eof
    " | sed -r "s/\x1B\[[0-9;]*[a-zA-Z]//g" | sed 's/\x1B\][0-9];[^\a]*\a//g')

    # Parse text output (original functionality)
    version=$(echo "$cleaned_output" | grep "app.kubernetes.io/version" | head -1 | sed 's/.*app\.kubernetes\.io\/version[[:space:]]*:[[:space:]]*//' | sed 's/[[:space:]].*//' | sed 's/[^a-zA-Z0-9.-].*//')
    dashboard_url=$(echo "$cleaned_output" | grep "➤.*Dashboard:" | head -1 | sed 's/.*➤[[:space:]]*Dashboard:[[:space:]]*//')
    logging_output=$(echo "$cleaned_output" | grep "➤.*Logging")
    
    # Output results
    if [[ -n "$version" ]]; then
        echo -e "${STD_CYN}Version:${RST} ${BLK}$version${RST}"
    fi
    if [[ -n "$dashboard_url" ]]; then
        echo -e "${STD_CYN}Dashboard:${RST} ${BLK}$dashboard_url${RST}"
    fi
    if [[ -n "$logging_output" ]]; then
        local counter=1
        while IFS= read -r line; do
            if [[ -n "$line" ]]; then
                # Extract the logging type and URL
                logging_type=$(echo "$line" | sed 's/.*➤[[:space:]]*Logging\([^:]*\):.*/\1/' | sed 's/^_//')
                logging_url=$(echo "$line" | sed 's/.*➤[[:space:]]*Logging[^:]*:[[:space:]]*//')
                
                if [[ -z "$logging_type" || "$logging_type" == "$line" ]]; then
                    echo -e "${STD_CYN}Logging:${RST} ${BLK}$logging_url${RST}"
                else
                    echo -e "${STD_CYN}Logging_$logging_type:${RST} ${BLK}$logging_url${RST}"
                fi
            fi
        done <<< "$logging_output"
    fi
    if [[ -z "$version" && -z "$dashboard_url" && -z "$logging_output" ]]; then
        echo "No details found"
    fi
}

jsonDetails() {
    # Run the command, clean output, and extract JSON details
    cleaned_output=$(expect -c "
    spawn $*
    expect \">\"
    send \"\r\"
    expect eof
    " | sed -r "s/\x1B\[[0-9;]*[a-zA-Z]//g" | sed 's/\x1B\][0-9];[^\a]*\a//g')
    
    # Parse JSON output
    version=$(echo "$cleaned_output" | grep -o '"app\.kubernetes\.io/version"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"app\.kubernetes\.io\/version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/' | head -1)
    dashboard_url=$(echo "$cleaned_output" | grep -o '"Dashboard"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"Dashboard"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/' | head -1)
    logging_urls=$(echo "$cleaned_output" | grep -o '"Logging[^"]*"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"\(Logging[^"]*\)"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1: \2/')
    
    # Output results
    if [[ -n "$version" ]]; then
        echo -e "${STD_CYN}Version:${RST} ${BLK}$version${RST}"
    fi
    if [[ -n "$dashboard_url" ]]; then
        echo -e "${STD_CYN}Dashboard:${RST} ${BLK}$dashboard_url${RST}"
    fi
    if [[ -n "$logging_urls" ]]; then
        while IFS= read -r line; do
            if [[ -n "$line" ]]; then
                if [[ "$line" == *": "* ]]; then
                    logging_type=$(echo "$line" | cut -d':' -f1 | sed 's/^_//')
                    logging_url=$(echo "$line" | cut -d':' -f2- | sed 's/^ *//')
                    if [[ -z "$logging_type" ]]; then
                        echo -e "${STD_CYN}Logging:${RST} ${BLK}$logging_url${RST}"
                    else
                        echo -e "${STD_CYN}Logging_$logging_type:${RST} ${BLK}$logging_url${RST}"
                    fi
                fi
            fi
        done <<< "$logging_urls"
    fi
    if [[ -z "$version" && -z "$dashboard_url" && -z "$logging_urls" ]]; then
        echo "No details found"
    fi
}

# Alias for help
alias help=show_functions
alias ss=search

