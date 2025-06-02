#!/bin/bash

################################################################################
# Production UI Functions for Cursor AI Editor Management Utility
# CONSISTENT MESSAGING AND PROGRESS DISPLAY
################################################################################

# Enhanced progress display function
show_progress() {
    local current=${1:-0}
    local total=${2:-100} 
    local message=${3:-"PROCESSING"}
    local show_bar=${4:-true}

    if [[ "$total" -eq 0 ]]; then
        echo "[INFO] $message..."
        return 0
    fi

    local percentage=$(( (current * 100) / total ))
    
    if [[ "$show_bar" == "true" ]]; then
        local bar_width=40
        local filled=$(( (percentage * bar_width) / 100 ))
        local empty=$((bar_width - filled))

        local progress_bar=""
        for ((i=0; i<filled; i++)); do
            progress_bar+="█"
        done
        for ((i=0; i<empty; i++)); do
            progress_bar+="░"
        done

        printf "\r${CYAN}[%s] %3d%% ${NC}%s" "$progress_bar" "$percentage" "$message"
    else
        printf "\r${CYAN}%3d%% ${NC}%s" "$percentage" "$message"
    fi

    if [[ "$current" -ge "$total" ]]; then
        echo ""  # New line when complete
    fi
}

# Display system information in formatted table
display_system_specifications() {
    echo -e "\n${BOLD}${BLUE}🖥️  SYSTEM SPECIFICATIONS${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════${NC}\n"
    
    # Get system info
    local cpu_info memory_gb macos_version arch disk_space
    
    cpu_info=$(sysctl -n machdep.cpu.brand_string 2>/dev/null || echo "Unknown CPU")
    memory_gb=$(sysctl -n hw.memsize 2>/dev/null | awk '{print int($1/1024/1024/1024)}' || echo "Unknown")
    arch=$(uname -m)
    disk_space=$(df -h / 2>/dev/null | tail -1 | awk '{print $4}' || echo "Unknown")
    
    if command -v sw_vers >/dev/null 2>&1; then
        macos_version=$(sw_vers -productVersion)
    else
        macos_version="Unknown"
    fi
    
    # Display formatted information
    printf "%-20s %s\n" "${BOLD}CPU:${NC}" "$cpu_info"
    printf "%-20s %s\n" "${BOLD}Memory:${NC}" "${memory_gb}GB"
    printf "%-20s %s\n" "${BOLD}macOS Version:${NC}" "$macos_version" 
    printf "%-20s %s\n" "${BOLD}Architecture:${NC}" "$arch"
    printf "%-20s %s\n" "${BOLD}Available Space:${NC}" "$disk_space"
    
    # AI Optimization recommendations
    echo -e "\n${BOLD}${GREEN}AI OPTIMIZATION READINESS:${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════${NC}"
    
    local memory_check="❌"
    local disk_check="❌"
    local arch_check="❌"
    
    if [[ $memory_gb -ge 16 ]]; then
        memory_check="✅"
    elif [[ $memory_gb -ge 8 ]]; then
        memory_check="⚠️"
    fi
    
    local disk_gb
    disk_gb=$(df -g / 2>/dev/null | tail -1 | awk '{print $4}' || echo "0")
    if [[ $disk_gb -ge 50 ]]; then
        disk_check="✅"
    elif [[ $disk_gb -ge 10 ]]; then
        disk_check="⚠️"
    fi
    
    if [[ "$arch" == "arm64" ]]; then
        arch_check="✅"
    elif [[ "$arch" == "x86_64" ]]; then
        arch_check="⚠️"
    fi
    
    printf "%-20s %s %s\n" "Memory for AI:" "$memory_check" "$memory_gb GB (16GB+ recommended)"
    printf "%-20s %s %s\n" "Disk Space:" "$disk_check" "$disk_space available (50GB+ recommended)"
    printf "%-20s %s %s\n" "Apple Silicon:" "$arch_check" "$arch (ARM64 optimal for AI)"
    
    echo ""
}

# Confirmation dialog with timeout
confirm_operation() {
    local message="$1"
    local timeout="${2:-30}"
    local default_response="${3:-n}"
    
    echo -e "\n${YELLOW}${BOLD}⚠️  CONFIRMATION REQUIRED${NC}"
    echo -e "${BOLD}$message${NC}"
    echo ""
    
    if [[ "$NON_INTERACTIVE_MODE" == "true" ]]; then
        echo "[INFO] Non-interactive mode: Using default response '$default_response'"
        case "$default_response" in
            [Yy]|[Yy][Ee][Ss]) return 0 ;;
            *) return 1 ;;
        esac
    fi
    
    echo -n "Continue? (y/N): "
    
    if read -t "$timeout" -r response 2>/dev/null; then
        case "$response" in
            [Yy]|[Yy][Ee][Ss]) return 0 ;;
            *) return 1 ;;
        esac
    else
        echo ""
        echo "[INFO] Timeout reached, using default response '$default_response'"
        case "$default_response" in
            [Yy]|[Yy][Ee][Ss]) return 0 ;;
            *) return 1 ;;
        esac
    fi
}

# Display operation summary
display_operation_summary() {
    local operation="$1"
    local success_count="$2"
    local warning_count="$3"
    local error_count="$4"
    local total_count="$5"
    
    echo -e "\n${BOLD}${BLUE}📊 OPERATION SUMMARY${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════${NC}"
    echo -e "${BOLD}Operation:${NC} $operation"
    echo -e "${BOLD}Total Steps:${NC} $total_count"
    echo ""
    
    if [[ $success_count -gt 0 ]]; then
        echo -e "${GREEN}✅ Successful:${NC} $success_count"
    fi
    
    if [[ $warning_count -gt 0 ]]; then
        echo -e "${YELLOW}⚠️ Warnings:${NC} $warning_count"
    fi
    
    if [[ $error_count -gt 0 ]]; then
        echo -e "${RED}❌ Errors:${NC} $error_count"
    fi
    
    echo ""
    
    # Overall status
    if [[ $error_count -eq 0 ]] && [[ $warning_count -eq 0 ]]; then
        echo -e "${GREEN}${BOLD}✅ OPERATION COMPLETED SUCCESSFULLY${NC}"
    elif [[ $error_count -eq 0 ]]; then
        echo -e "${YELLOW}${BOLD}⚠️ OPERATION COMPLETED WITH WARNINGS${NC}"
    else
        echo -e "${RED}${BOLD}❌ OPERATION COMPLETED WITH ERRORS${NC}"
    fi
    
    echo ""
}

# Display help information in formatted sections
display_help_section() {
    local section_title="$1"
    local section_content="$2"
    
    echo -e "\n${BOLD}${BLUE}$section_title${NC}"
    # Use seq command for variable range expansion - shellcheck SC2051 fix
    echo -e "${BOLD}$(printf '═%.0s' $(seq 1 ${#section_title}))${NC}"
    echo -e "$section_content"
}

# Show animated spinner for long operations
show_spinner() {
    local message="$1"
    local duration="${2:-5}"
    
    # Fix single quote escaping - shellcheck SC1003 fix  
    local spinstr="|/-\\"
    local temp
    
    echo -n "$message "
    
    for ((i=0; i<duration*4; i++)); do
        temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        spinstr=$temp${spinstr%"$temp"}
        sleep 0.25
        printf "\b\b\b\b\b\b"
    done
    
    printf "    \b\b\b\b"
    echo " ✅"
}

# Display file/directory tree structure
display_tree_structure() {
    local root_path="$1"
    local max_depth="${2:-3}"
    
    if ! command -v tree >/dev/null 2>&1; then
        echo "[INFO] Tree command not available, using basic listing"
        find "$root_path" -maxdepth "$max_depth" -type d 2>/dev/null | head -20
        return 0
    fi
    
    tree -L "$max_depth" -C "$root_path" 2>/dev/null || {
        echo "[INFO] Using fallback directory listing"
        find "$root_path" -maxdepth "$max_depth" -type d 2>/dev/null | head -20
    }
}

# Header display for major operations
display_operation_header() {
    local operation_name="$1"
    local operation_description="$2"
    
    clear
    echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${BLUE}           $operation_name${NC}"
    echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════${NC}"
    
    if [[ -n "$operation_description" ]]; then
        echo -e "\n${CYAN}$operation_description${NC}\n"
    fi
}

# UI functions loaded confirmation
export UI_LOADED=true 