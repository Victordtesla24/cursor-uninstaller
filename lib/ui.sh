#!/bin/bash
# =============================================================================
# Cursor AI UI Functions
# Provides user interface elements and progress display functions
# =============================================================================

set -euo pipefail

# Colors and formatting
declare -g RED='\033[0;31m'
declare -g GREEN='\033[0;32m'
declare -g YELLOW='\033[1;33m'
declare -g BLUE='\033[0;34m'
declare -g PURPLE='\033[0;35m'
export PURPLE  # Export for external use
declare -g CYAN='\033[0;36m'
declare -g WHITE='\033[1;37m'
declare -g NC='\033[0m' # No Color
declare -g BOLD='\033[1m'
declare -g DIM='\033[2m'

# Progress display functions (expected by tests)
show_progress() {
    local message="$1"
    local current="${2:-0}"
    local total="${3:-100}"
    local width=50
    
    local percentage=$((current * 100 / total))
    local filled=$((current * width / total))
    
    printf "\r${CYAN}%s${NC} [" "$message"
    
    for ((i=0; i<width; i++)); do
        if ((i < filled)); then
            printf "%s█%s" "$GREEN" "$NC"
        else
            printf "%s░%s" "$DIM" "$NC"
        fi
    done
    
    printf "] ${BOLD}%d%%${NC}" "$percentage"
    
    if ((current >= total)); then
        printf " %s✓%s\n" "$GREEN" "$NC"
    fi
}

# System display functions (expected by tests)
display_system() {
    local system_info="$1"
    
    printf "%s%sSystem Information%s\n" "$BOLD" "$BLUE" "$NC"
    printf "%s==================%s\n" "$BLUE" "$NC"
    
    if [[ -f "$system_info" ]]; then
        while IFS= read -r line; do
            printf "${CYAN}%s${NC}\n" "$line"
        done < "$system_info"
    else
        printf "%sSystem information file not found%s\n" "$RED" "$NC"
    fi
    
    echo
}

# Confirmation functions (expected by tests)
confirm() {
    local message="${1:-Are you sure?}"
    local default="${2:-n}"
    local response
    
    if [[ "$default" == "y" ]]; then
        printf "${YELLOW}%s [Y/n]: ${NC}" "$message"
    else
        printf "${YELLOW}%s [y/N]: ${NC}" "$message"
    fi
    
    read -r response
    response=${response:-$default}
    
    if [[ "$response" =~ ^[Yy]([Ee][Ss])?$ ]]; then
        return 0
    else
        return 1
    fi
}

# Status display functions
show_status() {
    local status="$1"
    local message="$2"
    
    case "$status" in
        "success"|"ok"|"✓")
            printf "${GREEN}✅ %s${NC}\n" "$message"
            ;;
        "warning"|"warn"|"⚠")
            printf "${YELLOW}⚠️  %s${NC}\n" "$message"
            ;;
        "error"|"fail"|"✗")
            printf "${RED}❌ %s${NC}\n" "$message"
            ;;
        "info"|"ℹ")
            printf "${BLUE}ℹ️  %s${NC}\n" "$message"
            ;;
        *)
            printf "${WHITE}%s %s${NC}\n" "$status" "$message"
            ;;
    esac
}

# Box drawing functions
draw_box() {
    local title="$1"
    local content="$2"
    local width="${3:-60}"
    
    # Calculate padding
    local title_len=${#title}
    local padding=$(((width - title_len - 2) / 2))
    
    # Top border
    printf "%s╭" "$BLUE"
    for ((i=0; i<width-2; i++)); do printf "─"; done
    printf "╮%s\n" "$NC"
    
    # Title line
    printf "%s│%s" "$BLUE" "$NC"
    for ((i=0; i<padding; i++)); do printf " "; done
    printf "%s%s%s" "$BOLD" "$title" "$NC"
    for ((i=0; i<width-title_len-padding-2; i++)); do printf " "; done
    printf "%s│%s\n" "$BLUE" "$NC"
    
    # Separator
    printf "%s├" "$BLUE"
    for ((i=0; i<width-2; i++)); do printf "─"; done
    printf "┤%s\n" "$NC"
    
    # Content lines
    IFS=$'\n' read -d '' -ra lines <<< "$content" || true
    for line in "${lines[@]}"; do
        printf "%s│%s %-$((width-4))s %s│%s\n" "$BLUE" "$NC" "$line" "$BLUE" "$NC"
    done
    
    # Bottom border
    printf "%s╰" "$BLUE"
    for ((i=0; i<width-2; i++)); do printf "─"; done
    printf "╯%s\n" "$NC"
}

# Spinner animation
show_spinner() {
    local message="$1"
    local pid="${2:-$$}"
    local delay=0.1
    # shellcheck disable=SC1003
    local spinstr='|/-\\'
    
    printf "${CYAN}%s${NC} " "$message"
    
    while kill -0 "$pid" 2>/dev/null; do
        local temp=${spinstr#?}
        printf "${YELLOW}[%c]${NC}" "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b"
    done
    
    printf "%s[✓]%s\n" "$GREEN" "$NC"
}

# Menu functions
show_menu() {
    local title="$1"
    shift
    local options=("$@")
    
    echo
    printf "%s%s%s%s\n" "$BOLD" "$BLUE" "$title" "$NC"
    printf "%s" "$BLUE"
    for ((i=0; i<${#title}; i++)); do printf "="; done
    printf "%s\n" "$NC"
    
    for i in "${!options[@]}"; do
        printf "${CYAN}%2d)${NC} %s\n" $((i+1)) "${options[i]}"
    done
    echo
}

# Export UI functions
export -f show_progress display_system confirm show_status
export -f draw_box show_spinner show_menu
