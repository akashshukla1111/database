#!/bin/zsh

source .helper.sh

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
    echo -e "  ${STD_CYN}search <file_paths> [environment_filter|search_keys] [-s|-y|-sy]${RST}"
    echo -e "  ${STD_CYN}<command> | search [environment_filter|search_keys] [-s|-y|-sy]${RST}"
    echo ""
    echo -e "${STD_YEL}Parameters:${RST}"
    echo -e "  file_paths           File paths or command substitution result"
    echo -e "  environment_filter   Filter by environment (qa, dev, prod, etc.) - used with -s flag"
    echo -e "  search_keys          Search for specific keys in YAML files - used without -s flag"
    echo -e "  -s, --sledge         Run sledge commands for version information"
    echo -e "  -y, -sy, --yes       Auto-execute sledge commands without prompt"
    echo ""
    echo -e "${STD_YEL}Modes:${RST}"
    echo -e "  ${STD_GRN}Key-Value Search Mode (default):${RST}"
    echo -e "    Search for key-value pairs in YAML files"
    echo -e "  ${STD_GRN}Sledge Command Mode (-s flag):${RST}"
    echo -e "    Extract version information using sledge commands"
    echo -e "  ${STD_GRN}Auto-Execute Mode (-y/-sy flags):${RST}"
    echo -e "    Automatically execute sledge commands without user confirmation"
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
    echo -e "  ${STD_CYN}search \"\$(fs -fr fes/default-fc pre-main)\" stg -y${RST}              # Auto-execute for stg"
    echo -e "  ${STD_CYN}fs -fr fes/default-fc pre-main | search stg -s${RST}                     # Use with pipe"
    echo -e "  ${STD_CYN}search \"\$(fs -fr nte/default-fc pre-main)\" -sy${RST}                  # Auto-execute all"
    echo ""
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
  
  # Check for flags anywhere in arguments
  local args=("$@")
  local new_args=()
  
  for arg in "${args[@]}"; do
    case "$arg" in
      -s|--sledge)
        run_sledge=true
        ;;
      -y|--yes)
        auto_execute=true
        ;;
      -sy|--sledge-yes)
        run_sledge=true
        auto_execute=true
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
      echo -e "${STD_RED}Usage: search <file_paths> [environment_filter|search_keys] [-s|-y|-sy]"
      echo -e "${STD_GRN}Example: search \"\$(fs -fr aos/default-fc pre-main)\" qa -s     # Run sledge commands"
      echo -e "${STD_GRN}Example: search \"\$(fs -fr aos/default-fc pre-main)\" qa -y     # Auto-execute for qa"
      echo -e "${STD_GRN}Example: search \"\$(fs -fr aos/default-fc pre-main)\" artifact  # Search for 'artifact' key"
      return 1
    elif [[ $# -eq 1 ]]; then
      file_list="$1"
    else
      file_list="$1"
      if [[ "$run_sledge" == true ]]; then
        # For sledge mode, second argument (if exists) is environment filter
        if [[ $# -eq 2 ]]; then
          env_filter="$2"
        fi
      else
        # For key-value mode, second argument is search keys
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
    echo -e "${STD_RED}Usage: search <file_paths> [environment_filter|search_keys] [-s|-y|-sy]"
    echo -e "${STD_GRN}Example: search \"\$(fs -fr aos/default-fc pre-main)\" qa -s     # Run sledge commands"
    echo -e "${STD_GRN}Example: search \"\$(fs -fr aos/default-fc pre-main)\" qa -y     # Auto-execute for qa"
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
        echo -e "${STD_PUR}Filtered by: ${STD_YEL}${env_filter}${RST}"
      fi      
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
        
        # Display the command with number
        echo -e "${STD_CYN}[${#commands[@]}]${RST} ${colored_command}"
        
      done < <(sort -u "$temp_file")
      
      # Helper function to execute a single sledge command
      execute_single_sledge_command() {
        local i="$1"
        local namespace="${namespaces[$i]}"
        local artifact="${artifacts[$i]}"
        local environment="${environments[$i]}"
        local plain_command="${commands[$i]}"
        
        # Start individual timing
        local cmd_start_time=$(date +%s)
        
        # Create unique temp files for this command
        local temp_output="/tmp/sledge_output_$$_${i}"
        local temp_exit="/tmp/sledge_exit_$$_${i}"
        
        # Start background process using a temporary script file
        local temp_script="/tmp/sledge_script_$$_${i}"
        cat > "$temp_script" << EOF
#!/bin/zsh
source .helper.sh
appversion() {
    cleaned_output=\$(expect -c "
    spawn \$*
    expect \">\"
    send \"\r\"
    expect eof
    " | sed -r "s/\x1B\[[0-9;]*[a-zA-Z]//g" | sed 's/\x1B\][0-9];[^\a]*\a//g' | tr -cd '\11\12\15\40-\176')
    echo "\$cleaned_output" | awk '/Labels/{flag=1; next} /Status/{flag=0} flag' | grep -E 'app.kubernetes.io/version[ ]*:' | head -1 | awk -F: '{gsub(/^[ \t]+|[ \t]+\$/, "", \$2); print \$2}'
}
result=\$(appversion $plain_command 2>/dev/null)
exit_status=\$?
echo "\$result" > "$temp_output"
echo \$exit_status > "$temp_exit"
rm -f "$temp_script"
EOF
        chmod +x "$temp_script"
        "$temp_script" >/dev/null 2>&1 &
        local cmd_pid=$!
        
        # Simple timer animation - update same line
        local elapsed=0
        while kill -0 $cmd_pid 2>/dev/null; do
          printf "\r${STD_CYN}[%ss]${RST} ${BRN}%-25s${RST} ${RED}%-15s${RST} ${STD_YEL}Running ${RST}" \
            "$elapsed" "$artifact" "$environment"
          sleep 1
          elapsed=$((elapsed + 1))
        done
        
        # Wait for the background process to complete
        wait $cmd_pid >/dev/null 2>&1
        
        # Get the result
        local version_info=""
        local exit_code=1
        if [[ -f "$temp_output" ]]; then
          version_info=$(cat "$temp_output")
        fi
        if [[ -f "$temp_exit" ]]; then
          exit_code=$(cat "$temp_exit")
        fi
        
        # Calculate final execution time
        local cmd_end_time=$(date +%s)
        local cmd_elapsed=$((cmd_end_time - cmd_start_time))
        
        # Handle result
        if [[ $exit_code -eq 0 && -n "$version_info" ]]; then
          # Clean up version info if needed
          version_info=$(echo "$version_info" | sed 's/^v//' | xargs)
          [[ -z "$version_info" ]] && version_info="Not found"
        else
          version_info="Command failed"
        fi
        
        # Clear the loading line and display final result
        printf "\r${STD_CYN}[%ss]${RST} ${BRN}%-25s${RST} ${RED}%-15s${RST} ${STD_GRN}%s${RST}\n" \
          "$cmd_elapsed" "$artifact" "$environment" "$version_info"
        
        # Clean up temp files
        rm -f "$temp_output" "$temp_exit"
      }
      
      # Helper function to execute all commands
      execute_all_commands() {
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
          echo -e "${STD_CYN}[${i}]${RST} ${BLU}sledge ${RST}wcnp describe app ${BRN}${artifact}${RST}-${RED}${environment}${RST} ${STD_CYN}-n ${SKY}${namespace}${RST}"
        done
        echo ""
        
        # Disable job control notifications temporarily
        set +m
        # Execute all commands
        for i in {1..${#commands[@]}}; do
          execute_single_sledge_command "$i"
        done
        # Re-enable job control
        set -m
      }
      
      # Helper function to execute specific command
      execute_specific_command() {
        local cmd_num="$1"
        
        # Clear the screen area where commands were displayed
        local num_commands=${#commands[@]}
        for ((j=0; j<num_commands+2; j++)); do
          echo -ne "\033[1A\033[K"  # Move up one line and clear it
        done
        
        # Show the specific command being executed
        local namespace="${namespaces[$cmd_num]}"
        local artifact="${artifacts[$cmd_num]}"
        local environment="${environments[$cmd_num]}"
        echo -e "${STD_GRN}Loading version information for command ${cmd_num}...${RST}"
        echo -e "${STD_CYN}[${cmd_num}]${RST} ${BLU}sledge ${RST}wcnp describe app ${BRN}${artifact}${RST}-${RED}${environment}${RST} ${STD_CYN}-n ${SKY}${namespace}${RST}"
        echo ""
        
        # Disable job control notifications temporarily
        set +m
        # Execute the specific command
        execute_single_sledge_command "$cmd_num"
        # Re-enable job control
        set -m
      }
      
      echo ""
      
      local load_versions=""
      if [[ "$auto_execute" == true ]]; then
        # Auto-execute all commands without asking
        load_versions="y"
        echo -e "${STD_PUR}Auto-executing all commands...${RST}"
      else
        # Show prompt and allow number selection
        echo -n "${STD_PUR}Load versions? (y/yes to load all, 1-${#commands[@]} to load specific, Enter to exit): ${RST}"
        read load_versions </dev/tty
      fi
      
      if [[ "${load_versions:l}" == "y" || "${load_versions:l}" == "yes" ]]; then
        # Execute all commands
        execute_all_commands
      elif [[ "$load_versions" =~ ^[0-9]+$ ]] && [[ "$load_versions" -ge 1 ]] && [[ "$load_versions" -le "${#commands[@]}" ]]; then
        # Execute specific command by number
        execute_specific_command "$load_versions"
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

# Alias for help
alias help=show_functions
alias ss=search

