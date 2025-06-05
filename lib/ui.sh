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
            printf "${GREEN}█${NC}"
        else
            printf "${DIM}░${NC}"
        fi
    done
    
    printf "] ${BOLD}%d%%${NC}" "$percentage"
    
    if ((current >= total)); then
        printf " ${GREEN}✓${NC}\n"
    fi
}

# System display functions (expected by tests)
display_system() {
    local system_info="$1"
    
    printf "${BOLD}${BLUE}System Information${NC}\n"
    printf "${BLUE}==================${NC}\n"
    
    if [[ -f "$system_info" ]]; then
        while IFS= read -r line; do
            printf "${CYAN}%s${NC}\n" "$line"
        done < "$system_info"
    else
        printf "${RED}System information file not found${NC}\n"
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
    printf "${BLUE}╭"
    for ((i=0; i<width-2; i++)); do printf "─"; done
    printf "╮${NC}\n"
    
    # Title line
    printf "${BLUE}│${NC}"
    for ((i=0; i<padding; i++)); do printf " "; done
    printf "${BOLD}%s${NC}" "$title"
    for ((i=0; i<width-title_len-padding-2; i++)); do printf " "; done
    printf "${BLUE}│${NC}\n"
    
    # Separator
    printf "${BLUE}├"
    for ((i=0; i<width-2; i++)); do printf "─"; done
    printf "┤${NC}\n"
    
    # Content lines
    IFS=$'\n' read -d '' -ra lines <<< "$content" || true
    for line in "${lines[@]}"; do
        printf "${BLUE}│${NC} %-$((width-4))s ${BLUE}│${NC}\n" "$line"
    done
    
    # Bottom border
    printf "${BLUE}╰"
    for ((i=0; i<width-2; i++)); do printf "─"; done
    printf "╯${NC}\n"
}

# Spinner animation
show_spinner() {
    local message="$1"
    local pid="${2:-$$}"
    local delay=0.1
    local spinstr='|/-\'
    
    printf "${CYAN}%s${NC} " "$message"
    
    while kill -0 "$pid" 2>/dev/null; do
        local temp=${spinstr#?}
        printf "${YELLOW}[%c]${NC}" "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b"
    done
    
    printf "${GREEN}[✓]${NC}\n"
}

# Menu functions
show_menu() {
    local title="$1"
    shift
    local options=("$@")
    
    echo
    printf "${BOLD}${BLUE}%s${NC}\n" "$title"
    printf "${BLUE}"
    for ((i=0; i<${#title}; i++)); do printf "="; done
    printf "${NC}\n"
    
    for i in "${!options[@]}"; do
        printf "${CYAN}%2d)${NC} %s\n" $((i+1)) "${options[i]}"
    done
    echo
}

# Export UI functions
export -f show_progress display_system confirm show_status
export -f draw_box show_spinner show_menu
