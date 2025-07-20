#!/bin/bash

source .helper.sh

# Default values
DEFAULT_DIR="~/work"
SEARCH_DIR=""
FOLDER_SPECS=()
FILE_PATTERNS=()
OPEN_OPTION=false
RECURSIVE=false
STRICT_SEARCH=false

# Function to display usage
show_help() {
    echo -e "${BLUE}File Search Script - Smart Folder Parsing${NC}"
    echo -e "${YELLOW}Usage: $0 [OPTIONS] [filename]${NC}"
    echo ""
    echo -e "${GREEN}Options:${NC}"
    echo "  -d <directory>    Search directory (default: ~/work)"
    echo "  -f <folder>       Folder specification (comma-separated)"
    echo "  -r                Enable recursive search"
    echo "  -s                Enable strict search (exact filename matches only)"
    echo "  -o                Enable interactive file opening"
    echo "  -h                Show this help message"
    echo ""
    echo -e "${GREEN}Folder Syntax:${NC}"
    echo "  a,b,c/x,y/p,r               - Multi-level hierarchical expansion"
    echo "                                 Searches: a/x/p, a/x/r, a/y/p, a/y/r, b/x/p, b/x/r, etc."
    echo "  base1,base2/nested1,nested2  - Two-level hierarchical expansion"
    echo "  hierarchical/path            - Simple hierarchical search"
    echo "  folder1,folder2              - Multiple folder search"
    echo ""
    echo -e "${GREEN}Examples:${NC}"
    echo "  fs -fr aos,os/default-fc,us-wm-fc/stages qa.yml,stg.yml"
    echo "  fs -frs op,web/aos,os/default-fc,us-wm-fc qa-config.yml"
    echo "  fs -s -f aos/us-wm-fc us-wm-fc.yml"
    echo "  fs -ro -f os config"
}

# Convert acronym to folder pattern
convert_acronym_to_pattern() {
    local acronym="$1"
    
    # Only do pattern conversion for 2-4 character all-letter strings
    if [[ ${#acronym} -ge 2 ]] && [[ ${#acronym} -le 4 ]] && [[ "$acronym" =~ ^[a-zA-Z]+$ ]]; then
        # Generate separated pattern for acronym matching
        local pattern=""
        for ((i=0; i<${#acronym}; i++)); do
            char="${acronym:$i:1}"
            if [[ $i -eq 0 ]]; then
                pattern="${char}[^-_]*"
            else
                pattern="${pattern}[-_]${char}[^-_]*"
            fi
        done
        echo "$pattern"
    else
        echo "$acronym"
    fi
}

# Parse folder specification with multi-level nested parsing
parse_folder_spec() {
    local spec="$1"
    
    # Check if spec contains slash - indicates hierarchical structure
    if [[ "$spec" == *"/"* ]]; then
        # Split by slashes to get all levels
        IFS='/' read -ra levels <<< "$spec"
        
        # Parse each level into arrays
        local level_arrays=()
        for level in "${levels[@]}"; do
            local level_items=()
            if [[ "$level" == *","* ]]; then
                IFS=',' read -ra level_parts <<< "$level"
                for item in "${level_parts[@]}"; do
                    item=$(echo "$item" | xargs)
                    [[ -n "$item" ]] && level_items+=("$item")
                done
            else
                level_items+=("$level")
            fi
            
            # Join level items with comma and add to level_arrays
            local level_str=$(IFS=','; echo "${level_items[*]}")
            level_arrays+=("$level_str")
        done
        
        # Return results in format: "level1|level2|level3"
        local result=$(IFS='|'; echo "${level_arrays[*]}")
        echo "$result"
    else
        # No slash - single level with comma-separated items
        local items=()
        if [[ "$spec" == *","* ]]; then
            IFS=',' read -ra item_parts <<< "$spec"
            for item in "${item_parts[@]}"; do
                item=$(echo "$item" | xargs)
                [[ -n "$item" ]] && items+=("$item")
            done
        else
            items+=("$spec")
        fi
        
        local result=$(IFS=','; echo "${items[*]}")
        echo "$result"
    fi
}

# Smart folder search with multi-level hierarchical expansion
smart_folder_search() {
    local search_path="$1"
    local folder_spec="$2"
    
    # Parse the folder specification
    local parsed=$(parse_folder_spec "$folder_spec")
    
    # Check if this is a hierarchical structure (contains pipe separators)
    if [[ "$parsed" == *"|"* ]]; then
        # Multi-level hierarchical search
        IFS='|' read -ra levels <<< "$parsed"
        local current_paths=("$search_path")
        
        # Process each level
        for level in "${levels[@]}"; do
            [[ -z "$level" ]] && continue
            local next_paths=()
            
            # For each current path, search for all items in this level
            for current_path in "${current_paths[@]}"; do
                IFS=',' read -ra level_items <<< "$level"
                for item in "${level_items[@]}"; do
                    [[ -z "$item" ]] && continue
                    
                    local pattern=$(convert_acronym_to_pattern "$item")
                    local found_dirs
                    
                    # Use deeper search for flexible directory finding
                    local search_depth=5
                    
                    # First try acronym pattern matching
                    if [[ "$pattern" == *"*"* ]]; then
                        found_dirs=$(find "$current_path" -maxdepth $search_depth -type d -name "$pattern" -not -path "*/.*" -not -path "*/node_modules/*" -not -path "*/target/*" -not -path "*/build/*" -not -path "*/.git/*" 2>/dev/null)
                    else
                        found_dirs=""
                    fi
                    
                    # Always try partial/full name matching as well to ensure we don't miss exact matches
                    local partial_dirs=$(find "$current_path" -maxdepth $search_depth -type d -name "*$item*" -not -path "*/.*" -not -path "*/node_modules/*" -not -path "*/target/*" -not -path "*/build/*" -not -path "*/.git/*" 2>/dev/null)
                    
                    # Combine results from both searches
                    if [[ -n "$found_dirs" ]] && [[ -n "$partial_dirs" ]]; then
                        found_dirs=$(echo -e "$found_dirs\n$partial_dirs" | sort -u)
                    elif [[ -n "$partial_dirs" ]]; then
                        found_dirs="$partial_dirs"
                    fi
                    
                    while IFS= read -r dir; do
                        [[ -n "$dir" ]] && next_paths+=("$dir")
                    done <<< "$found_dirs"
                done
            done
            
            current_paths=("${next_paths[@]}")
            [[ ${#current_paths[@]} -eq 0 ]] && break
        done
        
        printf '%s\n' "${current_paths[@]}"
    else
        # Single level search
        IFS=',' read -ra items <<< "$parsed"
        local found_paths=()
        
        for item in "${items[@]}"; do
            [[ -z "$item" ]] && continue
            
            local pattern=$(convert_acronym_to_pattern "$item")
            local found_dirs
            
            # Use deeper search for flexible directory finding
            local search_depth=5
            
            # First try acronym pattern matching
            if [[ "$pattern" == *"*"* ]]; then
                found_dirs=$(find "$search_path" -maxdepth $search_depth -type d -name "$pattern" -not -path "*/.*" -not -path "*/node_modules/*" -not -path "*/target/*" -not -path "*/build/*" -not -path "*/.git/*" 2>/dev/null)
            else
                found_dirs=""
            fi
            
            # Always try partial/full name matching as well to ensure we don't miss exact matches
            local partial_dirs=$(find "$search_path" -maxdepth $search_depth -type d -name "*$item*" -not -path "*/.*" -not -path "*/node_modules/*" -not -path "*/target/*" -not -path "*/build/*" -not -path "*/.git/*" 2>/dev/null)
            
            # Combine results from both searches
            if [[ -n "$found_dirs" ]] && [[ -n "$partial_dirs" ]]; then
                found_dirs=$(echo -e "$found_dirs\n$partial_dirs" | sort -u)
            elif [[ -n "$partial_dirs" ]]; then
                found_dirs="$partial_dirs"
            fi
            
            while IFS= read -r dir; do
                [[ -n "$dir" ]] && found_paths+=("$dir")
            done <<< "$found_dirs"
        done
        
        printf '%s\n' "${found_paths[@]}"
    fi
}

# Extract file extension and create smart search patterns
create_smart_file_patterns() {
    local file_patterns=("$@")
    local smart_patterns=()
    
    for pattern in "${file_patterns[@]}"; do
        # Check if pattern has an extension
        if [[ "$pattern" == *.* ]]; then
            local basename="${pattern%.*}"
            local extension="${pattern##*.}"
            
            # Create search patterns for files with extensions:
            # 1. Exact match
            smart_patterns+=("^${pattern}$")
            
            # 2. Files that contain the basename and have the same extension
            smart_patterns+=(".*${basename}.*\\.${extension}$")
            
        else
            # No extension - treat as partial filename match
            smart_patterns+=(".*${pattern}.*")
        fi
    done
    
    printf '%s\n' "${smart_patterns[@]}"
}

# Maximum performance search with smart folder parsing
max_performance_search() {
    local search_path="$1"
    shift
    local file_patterns=("$@")
    
    # Set maxdepth
    local maxdepth=15
    if [[ "$RECURSIVE" == false ]]; then
        maxdepth=2
    fi
    
    # Build file name pattern - use smart patterns for extensions
    local regex_pattern=""
    if [[ ${#file_patterns[@]} -gt 0 ]]; then
        # Get smart patterns for better file matching
        local smart_patterns
        smart_patterns=$(create_smart_file_patterns "${file_patterns[@]}")
        
        local patterns_array=()
        while IFS= read -r line; do
            [[ -n "$line" ]] && patterns_array+=("$line")
        done <<< "$smart_patterns"
        
        if [[ ${#patterns_array[@]} -gt 0 ]]; then
            regex_pattern="("
            for ((i=0; i<${#patterns_array[@]}; i++)); do
                local pattern="${patterns_array[$i]}"
                regex_pattern="${regex_pattern}${pattern}"
                if [[ $i -lt $((${#patterns_array[@]}-1)) ]]; then
                    regex_pattern="${regex_pattern}|"
                fi
            done
            regex_pattern="${regex_pattern})"
        fi
    fi
    
    # Build folder search paths
    local search_paths=()
    if [[ ${#FOLDER_SPECS[@]} -gt 0 ]]; then
        # Process each folder specification
        for folder_spec in "${FOLDER_SPECS[@]}"; do
            local found_paths
            found_paths=$(smart_folder_search "$search_path" "$folder_spec")
            
            while IFS= read -r path; do
                [[ -n "$path" ]] && search_paths+=("$path")
            done <<< "$found_paths"
        done
        
        # If no folders found, return empty
        [[ ${#search_paths[@]} -eq 0 ]] && return 1
        
        # Search files in all found folders
        local results_file=$(mktemp)
        
        for folder_path in "${search_paths[@]}"; do
            local search_maxdepth=5
            
            if [[ -n "$regex_pattern" ]]; then
                # Use find with -name pattern for better filename matching
                for pattern in "${file_patterns[@]}"; do
                    if [[ "$pattern" == *.* ]]; then
                        local basename="${pattern%.*}"
                        local extension="${pattern##*.}"
                        
                        if [[ "$STRICT_SEARCH" == true ]]; then
                            # Strict search - only exact filename matches
                            find "$folder_path" -maxdepth "$search_maxdepth" -type f -name "$pattern" -not -path "*/.*" -not -path "*/node_modules/*" -not -path "*/target/*" -not -path "*/build/*" -not -path "*/.git/*" 2>/dev/null >> "$results_file"
                        else
                            # Regular search - exact match and partial matches
                            find "$folder_path" -maxdepth "$search_maxdepth" -type f -name "$pattern" -not -path "*/.*" -not -path "*/node_modules/*" -not -path "*/target/*" -not -path "*/build/*" -not -path "*/.git/*" 2>/dev/null >> "$results_file"
                            # Search for files containing basename with same extension
                            find "$folder_path" -maxdepth "$search_maxdepth" -type f -name "*${basename}*.${extension}" -not -path "*/.*" -not -path "*/node_modules/*" -not -path "*/target/*" -not -path "*/build/*" -not -path "*/.git/*" 2>/dev/null >> "$results_file"
                        fi
                    else
                        if [[ "$STRICT_SEARCH" == true ]]; then
                            # Strict search - only exact filename matches
                            find "$folder_path" -maxdepth "$search_maxdepth" -type f -name "$pattern" -not -path "*/.*" -not -path "*/node_modules/*" -not -path "*/target/*" -not -path "*/build/*" -not -path "*/.git/*" 2>/dev/null >> "$results_file"
                        else
                            # Regular search - partial filename match
                            find "$folder_path" -maxdepth "$search_maxdepth" -type f -name "*${pattern}*" -not -path "*/.*" -not -path "*/node_modules/*" -not -path "*/target/*" -not -path "*/build/*" -not -path "*/.git/*" 2>/dev/null >> "$results_file"
                        fi
                    fi
                done
            else
                find "$folder_path" -maxdepth "$search_maxdepth" -type f -not -path "*/.*" -not -path "*/node_modules/*" -not -path "*/target/*" -not -path "*/build/*" -not -path "*/.git/*" 2>/dev/null >> "$results_file"
            fi
        done
        
        # Sort and deduplicate results
        sort -u "$results_file"
        rm -f "$results_file"
    else
        # Search entire directory
        if [[ -n "$regex_pattern" ]]; then
            if [[ "$STRICT_SEARCH" == true ]]; then
                # Strict search - only exact filename matches
                for pattern in "${file_patterns[@]}"; do
                    find "$search_path" -maxdepth "$maxdepth" -type f -name "$pattern" -not -path "*/.*" -not -path "*/node_modules/*" -not -path "*/target/*" -not -path "*/build/*" -not -path "*/.git/*" 2>/dev/null
                done
            else
                # Regular search with regex pattern
                find "$search_path" -maxdepth "$maxdepth" -type f -not -path "*/.*" -not -path "*/node_modules/*" -not -path "*/target/*" -not -path "*/build/*" -not -path "*/.git/*" 2>/dev/null | grep -E "$regex_pattern"
            fi
        else
            find "$search_path" -maxdepth "$maxdepth" -type f -not -path "*/.*" -not -path "*/node_modules/*" -not -path "*/target/*" -not -path "*/build/*" -not -path "*/.git/*" 2>/dev/null
        fi
    fi
}

# Main search function
search_files() {
    local search_path="$1"
    shift
    local file_patterns=("$@")
    
    # Start loading animation
    start_loading "Searching for files..."
    
    # Call maximum performance search
    local results
    results=$(max_performance_search "$search_path" "${file_patterns[@]}")
    
    # Stop loading animation
    stop_loading
    
    if [[ -z "$results" ]]; then
        echo -e "${RED}No files found matching the criteria.${NC}"
        return 1
    fi
    
    # Convert to array for display
    local results_array=()
    while IFS= read -r line; do
        [[ -n "$line" ]] && results_array+=("$line")
    done <<< "$results"
    
    # Display results
    echo -e "${GREEN}Found ${#results_array[@]} file(s):${NC}"
    echo ""
    
    local i=1
    for file in "${results_array[@]}"; do
        if [[ "$OPEN_OPTION" == true ]]; then
            echo -e "${YELLOW}[$i]${NC} $file"
            ((i++))
        else
            echo "$file"
        fi
    done
    
    # Interactive selection if -o flag is used
    if [[ "$OPEN_OPTION" == true ]]; then
        echo ""
        echo -e "${BLUE}Select a file to open (1-${#results_array[@]}), or press Enter to exit:${NC}"
        
        read -p "Enter your choice: " choice
        
        if [[ -z "$choice" ]]; then
            return 0
        fi
        
        if [[ "$choice" =~ ^[0-9]+$ ]] && [[ "$choice" -ge 1 ]] && [[ "$choice" -le "${#results_array[@]}" ]]; then
            local selected_file="${results_array[$((choice-1))]}"
            echo -e "${GREEN}Opening: $selected_file${NC}"
            
            if command -v code &> /dev/null; then
                code "$selected_file"
            elif command -v vim &> /dev/null; then
                vim "$selected_file"
            elif command -v nano &> /dev/null; then
                nano "$selected_file"
            elif command -v open &> /dev/null; then
                open "$selected_file"
            else
                echo -e "${RED}No suitable editor found. File path: $selected_file${NC}"
            fi
        else
            echo -e "${RED}Invalid choice. Exiting.${NC}"
        fi
    fi
}

# Simple argument parsing
while [[ $# -gt 0 ]]; do
    case $1 in
        -d)
            SEARCH_DIR="$2"
            shift 2
            ;;
        -f)
            FOLDER_SPECS+=("$2")
            shift 2
            ;;
        -fr|-rf)
            RECURSIVE=true
            # Parse folder specification - can be multi-level like "a,b,c/x,y/p,r"
            folder_input="$2"
            
            # Check if this is a multi-level specification (multiple slashes)
            if [[ "$folder_input" == *"/"* ]]; then
                # Single multi-level specification
                FOLDER_SPECS+=("$folder_input")
            else
                # Handle space-separated multiple specifications
                folder_parts=()
                
                # Handle space-separated parts
                read -ra space_parts <<< "$folder_input"
                for part in "${space_parts[@]}"; do
                    if [[ "$part" == *","* ]]; then
                        # Split comma-separated parts
                        IFS=',' read -ra comma_parts <<< "$part"
                        for comma_part in "${comma_parts[@]}"; do
                            comma_part=$(echo "$comma_part" | xargs)
                            [[ -n "$comma_part" ]] && folder_parts+=("$comma_part")
                        done
                    else
                        part=$(echo "$part" | xargs)
                        [[ -n "$part" ]] && folder_parts+=("$part")
                    fi
                done
                
                # Add all parsed folder parts
                for folder_part in "${folder_parts[@]}"; do
                    FOLDER_SPECS+=("$folder_part")
                done
            fi
            shift 2
            ;;
        -frs|-fsr|-rfs|-rsf|-sfr|-srf)
            RECURSIVE=true
            STRICT_SEARCH=true
            # Parse folder specification - can be multi-level like "a,b,c/x,y/p,r"
            folder_input="$2"
            
            # Check if this is a multi-level specification (multiple slashes)
            if [[ "$folder_input" == *"/"* ]]; then
                # Single multi-level specification
                FOLDER_SPECS+=("$folder_input")
            else
                # Handle space-separated multiple specifications
                folder_parts=()
                
                # Handle space-separated parts
                read -ra space_parts <<< "$folder_input"
                for part in "${space_parts[@]}"; do
                    if [[ "$part" == *","* ]]; then
                        # Split comma-separated parts
                        IFS=',' read -ra comma_parts <<< "$part"
                        for comma_part in "${comma_parts[@]}"; do
                            comma_part=$(echo "$comma_part" | xargs)
                            [[ -n "$comma_part" ]] && folder_parts+=("$comma_part")
                        done
                    else
                        part=$(echo "$part" | xargs)
                        [[ -n "$part" ]] && folder_parts+=("$part")
                    fi
                done
                
                # Add all parsed folder parts
                for folder_part in "${folder_parts[@]}"; do
                    FOLDER_SPECS+=("$folder_part")
                done
            fi
            shift 2
            ;;
        -r)
            RECURSIVE=true
            shift
            ;;
        -s)
            STRICT_SEARCH=true
            shift
            ;;
        -o)
            OPEN_OPTION=true
            shift
            ;;
        -h)
            show_help
            exit 0
            ;;
        *)
            # Handle file patterns
            if [[ "$1" == *","* ]]; then
                IFS=',' read -ra pattern_array <<< "$1"
                for pattern in "${pattern_array[@]}"; do
                    pattern=$(echo "$pattern" | xargs)
                    [[ -n "$pattern" ]] && FILE_PATTERNS+=("$pattern")
                done
            else
                FILE_PATTERNS+=("$1")
            fi
            shift
            ;;
    esac
done

# Set default search directory
if [[ -z "$SEARCH_DIR" ]]; then
    SEARCH_DIR="$DEFAULT_DIR"
    SEARCH_DIR="${SEARCH_DIR/#\~/$HOME}"
fi

# Validate directory
if [[ ! -d "$SEARCH_DIR" ]]; then
    echo -e "${RED}Error: Directory '$SEARCH_DIR' does not exist.${NC}"
    exit 1
fi

# Start loading for directory resolution
start_loading "Initializing search directory..."
SEARCH_DIR=$(cd "$SEARCH_DIR" && pwd)
stop_loading

# Display search parameters
echo -e "${BLUE}Directory:${NC} $SEARCH_DIR ${BLUE}|${NC} ${GREEN}Folder Specs:${NC} ${FOLDER_SPECS[*]:-'(none)'} ${BLUE}|${NC} ${GREEN}Files:${NC} ${FILE_PATTERNS[*]:-'(none)'} ${BLUE}|${NC} ${GREEN}Recursive:${NC} $RECURSIVE ${BLUE}|${NC} ${GREEN}Strict:${NC} $STRICT_SEARCH"
echo ""

# Perform the search
search_files "$SEARCH_DIR" "${FILE_PATTERNS[@]}"
search_exit_code=$?

exit $search_exit_code
