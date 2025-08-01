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


BRI_BLK='\033[1;30m'    # Bright Black (Gray)
BRI_RED='\033[1;31m'    # Bright Red
BRI_GRN='\033[1;32m'    # Bright Green
BRI_YEL='\033[1;33m'    # Bright Yellow
BRI_BLU='\033[1;34m'    # Bright Blue
BRI_PUR='\033[1;35m'    # Bright Purple
BRI_CYN='\033[1;36m'    # Bright Cyan
BRI_WHT='\033[1;37m'    # Bright White



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

