#!/bin/bash

################################################################################
# Production UI Functions for Cursor AI Editor Management Utility
# ENHANCED USER INTERFACE WITH ACCESSIBILITY AND RESPONSIVE DESIGN
################################################################################

# Strict error handling
set -euo pipefail

# UI Constants and Configuration
readonly UI_BAR_WIDTH=50
readonly UI_ANIMATION_DELAY=0.1
readonly UI_SPINNER_CHARS="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"

# Terminal capability detection
detect_terminal_capabilities() {
    local capabilities=()
    
    # Check for color support
    if [[ -t 1 ]] && [[ "${TERM:-}" != "dumb" ]] && [[ -z "${NO_COLOR:-}" ]]; then
        if command -v tput >/dev/null 2>&1; then
            local colors
            colors=$(tput colors 2>/dev/null || echo "0")
            if [[ $colors -ge 8 ]]; then
                capabilities+=("color")
            fi
            if [[ $colors -ge 256 ]]; then
                capabilities+=("256color")
            fi
        fi
    fi
    
    # Check for Unicode support
    if [[ "${LANG:-}" =~ UTF-8 ]] || [[ "${LC_ALL:-}" =~ UTF-8 ]]; then
        capabilities+=("unicode")
    fi
    
    # Check terminal width
    local term_width
    term_width=$(tput cols 2>/dev/null || echo "80")
    export TERM_WIDTH="$term_width"
    
    # Export capabilities
    export TERMINAL_CAPABILITIES="${capabilities[*]:-}"
    
    log_with_level "DEBUG" "Terminal capabilities detected: ${TERMINAL_CAPABILITIES:-none}"
}

# Enhanced progress display with adaptive rendering
show_progress() {
    local current=${1:-0}
    local total=${2:-100}
    local message=${3:-"Processing"}
    local show_bar=${4:-true}
    local show_percentage=${5:-true}
    local show_eta=${6:-false}
    local start_time=${7:-$(date +%s)}

    # Validate inputs
    if [[ $total -eq 0 ]]; then
        echo "[INFO] $message..."
        return 0
    fi
    
    if [[ $current -gt $total ]]; then
        current=$total
    fi

    local percentage=$(( (current * 100) / total ))
    
    # Calculate progress bar components
    local output=""
    
    if [[ "$show_bar" == "true" ]] && [[ "$TERMINAL_CAPABILITIES" =~ unicode ]]; then
        local bar_width=${UI_BAR_WIDTH}
        
        # Adjust bar width for smaller terminals
        if [[ ${TERM_WIDTH:-80} -lt 100 ]]; then
            bar_width=$(( TERM_WIDTH / 3 ))
        fi
        
        local filled=$(( (percentage * bar_width) / 100 ))
        local empty=$((bar_width - filled))

        local progress_bar=""
        local fill_char="█"
        local empty_char="░"
        
        # Use ASCII fallback if Unicode not supported
        if [[ ! "$TERMINAL_CAPABILITIES" =~ unicode ]]; then
            fill_char="="
            empty_char="-"
        fi
        
        for ((i=0; i<filled; i++)); do
            progress_bar+="$fill_char"
        done
        for ((i=0; i<empty; i++)); do
            progress_bar+="$empty_char"
        done

        output+="[${progress_bar}]"
    fi
    
    if [[ "$show_percentage" == "true" ]]; then
        output+=" ${percentage}%"
    fi
    
    # Add ETA calculation
    if [[ "$show_eta" == "true" && $current -gt 0 ]]; then
        local elapsed=$(($(date +%s) - start_time))
        local rate=$(( current / (elapsed + 1) ))
        local remaining=$(( (total - current) / (rate + 1) ))
        
        if [[ $remaining -gt 60 ]]; then
            local minutes=$((remaining / 60))
            output+=" ETA: ${minutes}m"
        elif [[ $remaining -gt 0 ]]; then
            output+=" ETA: ${remaining}s"
        fi
    fi
    
    output+=" $message"
    
    # Use color if available
    if [[ "$TERMINAL_CAPABILITIES" =~ color ]]; then
        if [[ $percentage -ge 100 ]]; then
            printf "\r${GREEN}%s${NC}" "$output"
        elif [[ $percentage -ge 75 ]]; then
            printf "\r${CYAN}%s${NC}" "$output"
        elif [[ $percentage -ge 50 ]]; then
            printf "\r${YELLOW}%s${NC}" "$output"
        else
            printf "\r%s" "$output"
        fi
    else
        printf "\r%s" "$output"
    fi

    if [[ "$current" -ge "$total" ]]; then
        echo ""  # New line when complete
    fi
}

# Animated spinner for indeterminate progress
show_spinner() {
    local message="$1"
    local duration="${2:-5}"
    local spinner_pid="${3:-}"
    
    if [[ "$TERMINAL_CAPABILITIES" =~ unicode ]]; then
        local spinner_chars="$UI_SPINNER_CHARS"
    else
        local spinner_chars="|/-\\"
    fi
    
    echo -n "$message "
    
    if [[ -n "$spinner_pid" ]]; then
        # Monitor existing process
        local char_index=0
        while kill -0 "$spinner_pid" 2>/dev/null; do
            local char="${spinner_chars:$char_index:1}"
            printf "\b%s" "$char"
            char_index=$(( (char_index + 1) % ${#spinner_chars} ))
            sleep "$UI_ANIMATION_DELAY"
        done
    else
        # Fixed duration spinner
        local iterations=$((duration * 10))
        for ((i=0; i<iterations; i++)); do
            local char_index=$((i % ${#spinner_chars}))
            local char="${spinner_chars:$char_index:1}"
            printf "\b%s" "$char"
            sleep "$UI_ANIMATION_DELAY"
        done
    fi
    
    printf "\b✅\n"
}

# Enhanced system information display with responsive layout
display_system_specifications() {
    local show_detailed="${1:-false}"
    local format="${2:-table}"
    
    echo -e "\n${BOLD}${BLUE}🖥️  SYSTEM SPECIFICATIONS${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════${NC}\n"
    
    # Get comprehensive system info
    local system_info
    system_info=$(get_system_specs)
    
    if [[ "$format" == "json" ]]; then
        # JSON output for programmatic use
        echo "{"
        local first=true
        while IFS=': ' read -r key value; do
            if [[ -n "$key" && -n "$value" ]]; then
                if [[ "$first" != "true" ]]; then
                    echo ","
                fi
                printf '  "%s": "%s"' "$key" "$value"
                first=false
            fi
        done <<< "$system_info"
        echo ""
        echo "}"
        return 0
    fi
    
    # Calculate optimal column width
    local max_key_length=0
    while IFS=': ' read -r key value; do
        if [[ ${#key} -gt $max_key_length ]]; then
            max_key_length=${#key}
        fi
    done <<< "$system_info"
    
    local key_width=$((max_key_length + 2))
    
    # Display formatted information
    while IFS=': ' read -r key value; do
        if [[ -n "$key" && -n "$value" ]]; then
            printf "%-${key_width}s %s\n" "${BOLD}${key}:${NC}" "$value"
        fi
    done <<< "$system_info"
    
    # AI Optimization readiness assessment
    echo -e "\n${BOLD}${GREEN}🤖 AI OPTIMIZATION READINESS${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════${NC}"
    
    local readiness_score=0
    local max_score=5
    
    # Memory assessment
    local memory_gb
    memory_gb=$(echo "$system_info" | grep "^Total Memory:" | awk '{print $3}' | sed 's/GB//' || echo "0")
    local memory_status="❌"
    local memory_desc="Insufficient"
    
    if [[ $memory_gb -ge 32 ]]; then
        memory_status="✅"
        memory_desc="Excellent"
        readiness_score=$((readiness_score + 2))
    elif [[ $memory_gb -ge 16 ]]; then
        memory_status="✅"
        memory_desc="Very Good"
        readiness_score=$((readiness_score + 2))
    elif [[ $memory_gb -ge 8 ]]; then
        memory_status="⚠️"
        memory_desc="Good"
        readiness_score=$((readiness_score + 1))
    fi
    
    printf "%-20s %s %s (%s for AI workloads)\n" "Memory:" "$memory_status" "${memory_gb}GB" "$memory_desc"
    
    # Disk space assessment
    local disk_gb
    disk_gb=$(echo "$system_info" | grep "^Disk Available:" | awk '{print $3}' | sed 's/G.*//' || echo "0")
    local disk_status="❌"
    local disk_desc="Critical"
    
    if [[ $disk_gb -ge 100 ]]; then
        disk_status="✅"
        disk_desc="Excellent"
        readiness_score=$((readiness_score + 1))
    elif [[ $disk_gb -ge 50 ]]; then
        disk_status="⚠️"
        disk_desc="Good"
    fi
    
    printf "%-20s %s %s (%s space available)\n" "Storage:" "$disk_status" "${disk_gb}GB" "$disk_desc"
    
    # Architecture assessment
    local arch
    arch=$(echo "$system_info" | grep "^Architecture:" | awk '{print $2}' || echo "unknown")
    local arch_status="❌"
    local arch_desc="Compatibility issues"
    
    if [[ "$arch" == "arm64" ]]; then
        arch_status="✅"
        arch_desc="Optimal for Apple Silicon"
        readiness_score=$((readiness_score + 2))
    elif [[ "$arch" == "x86_64" ]]; then
        arch_status="⚠️"
        arch_desc="Intel compatible"
        readiness_score=$((readiness_score + 1))
    fi
    
    printf "%-20s %s %s (%s)\n" "Architecture:" "$arch_status" "$arch" "$arch_desc"
    
    # Overall readiness
    echo ""
    if [[ $readiness_score -ge 4 ]]; then
        echo -e "${GREEN}${BOLD}🚀 OVERALL READINESS: EXCELLENT (${readiness_score}/${max_score})${NC}"
        echo -e "${GREEN}Your system is optimally configured for AI development${NC}"
    elif [[ $readiness_score -ge 2 ]]; then
        echo -e "${YELLOW}${BOLD}⚠️ OVERALL READINESS: GOOD (${readiness_score}/${max_score})${NC}"
        echo -e "${YELLOW}Your system supports AI with some limitations${NC}"
    else
        echo -e "${RED}${BOLD}❌ OVERALL READINESS: NEEDS IMPROVEMENT (${readiness_score}/${max_score})${NC}"
        echo -e "${RED}Consider hardware upgrades for optimal AI performance${NC}"
    fi
    
    if [[ "$show_detailed" == "true" ]]; then
        display_optimization_recommendations
    fi
    
    echo ""
}

# Enhanced confirmation dialog with timeout and accessibility
confirm_operation() {
    local message="$1"
    local timeout="${2:-30}"
    local default_response="${3:-n}"
    local require_exact="${4:-false}"
    local exact_phrase="${5:-}"
    
    # Display confirmation prompt with enhanced formatting
    echo -e "\n${YELLOW}${BOLD}⚠️  CONFIRMATION REQUIRED${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════${NC}"
    echo -e "${BOLD}$message${NC}"
    echo ""
    
    # Non-interactive mode handling
    if [[ "$NON_INTERACTIVE_MODE" == "true" ]]; then
        if [[ "$require_exact" == "true" ]]; then
            log_with_level "ERROR" "Exact confirmation required but running in non-interactive mode"
            return 1
        fi
        
        log_with_level "INFO" "Non-interactive mode: Using default response '$default_response'"
        case "$default_response" in
            [Yy]|[Yy][Ee][Ss]) return 0 ;;
            *) return 1 ;;
        esac
    fi
    
    # Exact phrase confirmation
    if [[ "$require_exact" == "true" && -n "$exact_phrase" ]]; then
        echo -e "${RED}${BOLD}Type '$exact_phrase' to confirm:${NC}"
        echo -n "> "
        
        local response
        if read -t "$timeout" -r response 2>/dev/null; then
            if [[ "$response" == "$exact_phrase" ]]; then
                return 0
            else
                echo -e "\n${RED}Confirmation phrase does not match. Operation cancelled.${NC}"
                return 1
            fi
        else
            echo -e "\n${YELLOW}Timeout reached. Operation cancelled.${NC}"
            return 1
        fi
    fi
    
    # Standard yes/no confirmation
    echo -n "Continue? (y/N): "
    
    local response
    if read -t "$timeout" -r response 2>/dev/null; then
        case "$response" in
            [Yy]|[Yy][Ee][Ss]) return 0 ;;
            *) return 1 ;;
        esac
    else
        echo ""
        log_with_level "INFO" "Timeout reached, using default response '$default_response'"
        case "$default_response" in
            [Yy]|[Yy][Ee][Ss]) return 0 ;;
            *) return 1 ;;
        esac
    fi
}

# Enhanced operation summary with visual indicators
display_operation_summary() {
    local operation="$1"
    local success_count="$2"
    local warning_count="$3"
    local error_count="$4"
    local total_count="$5"
    local duration="${6:-0}"
    
    echo -e "\n${BOLD}${BLUE}📊 OPERATION SUMMARY${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════${NC}"
    echo -e "${BOLD}Operation:${NC} $operation"
    echo -e "${BOLD}Duration:${NC} ${duration}s"
    echo -e "${BOLD}Total Steps:${NC} $total_count"
    echo ""
    
    # Progress visualization
    if [[ $total_count -gt 0 ]]; then
        local success_width=$(( (success_count * 30) / total_count ))
        local warning_width=$(( (warning_count * 30) / total_count ))
        local error_width=$(( (error_count * 30) / total_count ))
        
        local progress_bar=""
        for ((i=0; i<success_width; i++)); do progress_bar+="█"; done
        for ((i=0; i<warning_width; i++)); do progress_bar+="▓"; done
        for ((i=0; i<error_width; i++)); do progress_bar+="░"; done
        
        if [[ "$TERMINAL_CAPABILITIES" =~ color ]]; then
            echo -e "Progress: ${GREEN}${progress_bar:0:$success_width}${YELLOW}${progress_bar:$success_width:$warning_width}${RED}${progress_bar:$((success_width+warning_width)):$error_width}${NC}"
        else
            echo -e "Progress: [$progress_bar]"
        fi
        echo ""
    fi
    
    # Detailed counts with icons
    if [[ $success_count -gt 0 ]]; then
        echo -e "${GREEN}✅ Successful:${NC} $success_count"
    fi
    
    if [[ $warning_count -gt 0 ]]; then
        echo -e "${YELLOW}⚠️  Warnings:${NC} $warning_count"
    fi
    
    if [[ $error_count -gt 0 ]]; then
        echo -e "${RED}❌ Errors:${NC} $error_count"
    fi
    
    echo ""
    
    # Overall status with enhanced messaging
    local success_rate=0
    if [[ $total_count -gt 0 ]]; then
        success_rate=$(( (success_count * 100) / total_count ))
    fi
    
    if [[ $error_count -eq 0 && $warning_count -eq 0 ]]; then
        echo -e "${GREEN}${BOLD}✅ OPERATION COMPLETED SUCCESSFULLY (100% Success Rate)${NC}"
        echo -e "${GREEN}All steps completed without issues${NC}"
    elif [[ $error_count -eq 0 ]]; then
        echo -e "${YELLOW}${BOLD}⚠️  OPERATION COMPLETED WITH WARNINGS (${success_rate}% Success Rate)${NC}"
        echo -e "${YELLOW}Please review warnings above for potential issues${NC}"
    elif [[ $success_rate -ge 75 ]]; then
        echo -e "${YELLOW}${BOLD}⚠️  OPERATION MOSTLY SUCCESSFUL (${success_rate}% Success Rate)${NC}"
        echo -e "${YELLOW}Some errors encountered but core functionality preserved${NC}"
    else
        echo -e "${RED}${BOLD}❌ OPERATION COMPLETED WITH SIGNIFICANT ERRORS (${success_rate}% Success Rate)${NC}"
        echo -e "${RED}Review errors above and consider manual intervention${NC}"
    fi
    
    echo ""
}

# Enhanced help display with sectioned information
display_help_section() {
    local section_title="$1"
    local section_content="$2"
    local show_border="${3:-true}"
    
    if [[ "$show_border" == "true" ]]; then
        echo -e "\n${BOLD}${BLUE}$section_title${NC}"
        local border_length=${#section_title}
        local border=""
        for ((i=0; i<border_length; i++)); do
            border+="═"
        done
        echo -e "${BOLD}$border${NC}"
    else
        echo -e "\n${BOLD}$section_title${NC}"
    fi
    
    echo -e "$section_content"
}

# Directory tree visualization with enhanced formatting
display_tree_structure() {
    local root_path="$1"
    local max_depth="${2:-3}"
    local show_hidden="${3:-false}"
    local show_sizes="${4:-false}"
    
    if [[ ! -d "$root_path" ]]; then
        log_with_level "ERROR" "Directory does not exist: $root_path"
        return 1
    fi
    
    echo -e "\n${BOLD}${BLUE}📁 Directory Structure: $root_path${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════${NC}"
    
    # Use tree command if available
    if command -v tree >/dev/null 2>&1; then
        local tree_args=("-L" "$max_depth" "-C")
        
        if [[ "$show_hidden" == "true" ]]; then
            tree_args+=("-a")
        fi
        
        if [[ "$show_sizes" == "true" ]]; then
            tree_args+=("-s")
        fi
        
        if ! tree "${tree_args[@]}" "$root_path" 2>/dev/null; then
            log_with_level "WARNING" "Tree command failed, using fallback"
            display_tree_fallback "$root_path" "$max_depth" "$show_hidden"
        fi
    else
        display_tree_fallback "$root_path" "$max_depth" "$show_hidden"
    fi
}

# Fallback tree display using find
display_tree_fallback() {
    local root_path="$1"
    local max_depth="$2"
    local show_hidden="$3"
    
    local find_args=("$root_path" "-maxdepth" "$max_depth")
    
    if [[ "$show_hidden" != "true" ]]; then
        find_args+=("-not" "-path" "*/.*")
    fi
    
    find "${find_args[@]}" -type d 2>/dev/null | head -50 | while read -r dir; do
        local relative_path="${dir#"$root_path"}"
        local depth
        depth=$(echo "$relative_path" | tr -cd '/' | wc -c)
        local indent=""
        
        for ((i=0; i<depth; i++)); do
            if [[ "$TERMINAL_CAPABILITIES" =~ unicode ]]; then
                indent+="│   "
            else
                indent+="|   "
            fi
        done
        
        local basename_dir
        basename_dir=$(basename "$dir")
        
        if [[ "$depth" -eq 0 ]]; then
            echo "$basename_dir/"
        else
            if [[ "$TERMINAL_CAPABILITIES" =~ unicode ]]; then
                echo "${indent}├── $basename_dir/"
            else
                echo "${indent}+-- $basename_dir/"
            fi
        fi
    done
}

# Header display for major operations with responsive design
display_operation_header() {
    local operation_name="$1"
    local operation_description="$2"
    local show_system_info="${3:-false}"
    
    clear
    
    # Calculate header width based on terminal
    local header_width=${TERM_WIDTH:-80}
    if [[ $header_width -lt 50 ]]; then
        header_width=50
    fi
    
    # Create border
    local border=""
    for ((i=0; i<header_width; i++)); do
        border+="═"
    done
    
    # Display header
    echo -e "${BOLD}${BLUE}$border${NC}"
    
    # Center the operation name
    local name_length=${#operation_name}
    local padding=$(( (header_width - name_length) / 2 ))
    local padded_name=""
    
    for ((i=0; i<padding; i++)); do
        padded_name+=" "
    done
    padded_name+="$operation_name"
    
    echo -e "${BOLD}${BLUE}$padded_name${NC}"
    echo -e "${BOLD}${BLUE}$border${NC}"
    
    if [[ -n "$operation_description" ]]; then
        echo -e "\n${CYAN}$operation_description${NC}\n"
    fi
    
    if [[ "$show_system_info" == "true" ]]; then
        echo -e "${BOLD}System:${NC} $(uname -s) $(uname -r) ($(uname -m))"
        echo -e "${BOLD}Time:${NC} $(date '+%Y-%m-%d %H:%M:%S')"
        echo ""
    fi
}

# Display optimization recommendations
display_optimization_recommendations() {
    echo -e "\n${BOLD}${CYAN}💡 OPTIMIZATION RECOMMENDATIONS${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════${NC}\n"
    
    echo -e "${BOLD}Hardware Recommendations:${NC}"
    echo "• 16GB+ RAM for large AI models and complex projects"
    echo "• Apple Silicon (M1/M2/M3/M4) for optimal AI performance"
    echo "• SSD storage with 500GB+ free space for fast operations"
    echo "• High-speed internet for AI model downloads"
    echo ""
    
    echo -e "${BOLD}Software Optimizations:${NC}"
    echo "• Close resource-intensive applications during AI tasks"
    echo "• Enable GPU acceleration in Cursor settings"
    echo "• Keep Cursor and system updated to latest versions"
    echo "• Configure appropriate swap/virtual memory settings"
    echo ""
    
    echo -e "${BOLD}Workflow Best Practices:${NC}"
    echo "• Use specific, detailed prompts for better AI results"
    echo "• Organize code in smaller, focused files for AI context"
    echo "• Implement .cursorignore to exclude irrelevant files"
    echo "• Provide clear comments for AI understanding"
    echo "• Regular code formatting and cleanup"
    echo ""
}

# Initialize UI system
init_ui() {
    # Detect terminal capabilities
    detect_terminal_capabilities
    
    # Set up color scheme if not already done
    if [[ -z "${NC:-}" ]]; then
        setup_color_scheme
    fi
    
    log_with_level "DEBUG" "UI system initialized with terminal width: ${TERM_WIDTH:-unknown}"
}

# UI functions loaded confirmation
export UI_LOADED=true

# Initialize UI when sourced
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    init_ui
fi

log_with_level "DEBUG" "Enhanced UI functions loaded successfully" 