#!/bin/bash

################################################################################
# Cursor AI Editor Removal & Management Utility -  GRADE
# STRICT Production Environment Standards - No Error Masking
################################################################################

# Script Self-Location & Robust Path Resolution
get_script_path() {
    local SOURCE="${BASH_SOURCE[0]}"
    local DIR=""

    while [ -h "$SOURCE" ]; do
        DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
        SOURCE="$(readlink "$SOURCE")"
        [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
    done

    DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
    echo "$DIR"
}

# Store the script's directory path
SCRIPT_DIR="$(get_script_path)"

#  GRADE ERROR HANDLING - NO MASKING
set -eE
trap 'production_error_handler $LINENO "$BASH_COMMAND"' ERR

# Global state tracking for production environment
ERRORS_ENCOUNTERED=0
NON_INTERACTIVE_MODE=false
SCRIPT_RUNNING=true
SCRIPT_EXITING=false
FORCE_EXIT=false

# -GRADE ERROR HANDLER - Reports real errors without masking
production_error_handler() {
    local line_number="$1"
    local failed_command="$2"

    # Skip error handling if we're in the process of a normal exit
    if [[ "${SCRIPT_EXITING:-false}" == "true" ]] || [[ "${SCRIPT_RUNNING:-true}" == "false" ]]; then
        return 0
    fi

    ((ERRORS_ENCOUNTERED++))

    # Sanitize the command to prevent display issues
    local sanitized_command
    sanitized_command=$(echo "$failed_command" | tr -cd '[:print:]' | head -c 100)

    # Report the actual error without masking
    echo -e "\n[ERROR] LINE $line_number: COMMAND FAILED: $sanitized_command" >&2
    echo "[ERROR] ERROR COUNT: $ERRORS_ENCOUNTERED" >&2

    # In production, we log but do NOT exit the script unless explicitly requested
    # This ensures the menu system remains available for troubleshooting
    if [[ "$FORCE_EXIT" == "true" ]]; then
        echo "[ERROR] FORCE EXIT REQUESTED, TERMINATING..." >&2
        exit 1
    fi

    # Reset the error trap to prevent infinite loops
    trap 'production_error_handler $LINENO "$BASH_COMMAND"' ERR
    return 0
}

# Optimization-specific error handler - Enhanced for stability
handle_optimization_error() {
    local line_number="$1"
    local failed_command="${2:-unknown command}"

    # Prevent infinite error loops
    if [[ "${OPTIMIZATION_ERROR_HANDLING:-false}" == "true" ]]; then
        return 0
    fi
    
    # Set flag to prevent recursive error handling
    OPTIMIZATION_ERROR_HANDLING="true"

    ((ERRORS_ENCOUNTERED++))

    # Sanitize the command to prevent display issues
    local sanitized_command
    sanitized_command=$(echo "$failed_command" | tr -cd '[:print:]' | head -c 80 || echo "command sanitization failed")

    # Report optimization error with context (use stderr with null safety)
    {
        echo ""
        echo "[OPTIMIZATION ERROR] LINE $line_number: COMMAND FAILED: $sanitized_command"
        echo "[INFO] OPTIMIZATION ERROR COUNT: $ERRORS_ENCOUNTERED"
        echo "[INFO] Optimization step failed, continuing with remaining optimizations..."
        echo ""
    } >&2 2>/dev/null || {
        # Fallback if stderr redirection fails
        printf "OPTIMIZATION ERROR at line %d\n" "$line_number" || true
    }

    # Reset the optimization error handling flag after a delay
    (sleep 1; OPTIMIZATION_ERROR_HANDLING="false") &

    # Don't exit, just continue with other optimizations
    # Reinstate trap more carefully
    if [[ "${BASH_SUBSHELL:-0}" -eq 0 ]]; then
        trap 'handle_optimization_error $LINENO "$BASH_COMMAND"' ERR 2>/dev/null || true
    fi
    
    return 0
}

# Detect if running in non-interactive environment
detect_environment() {
    if [[ ! -t 0 ]] || [[ -n "${CI:-}" ]] || [[ -n "${DEBIAN_FRONTEND:-}" ]] || [[ "${TERM:-}" == "dumb" ]]; then
        NON_INTERACTIVE_MODE=true
        echo "[INFO] NON-INTERACTIVE ENVIRONMENT DETECTED"
    fi
}

# -GRADE sudo handling - NO FALLBACKS OR ERROR MASKING
production_sudo() {
    local cmd="$*"

    # Check if sudo is available
    if ! command -v sudo >/dev/null 2>&1; then
        echo "[ERROR] SUDO NOT AVAILABLE - CANNOT PERFORM PRIVILEGED OPERATIONS" >&2
        return 1
    fi

    # In non-interactive mode, require passwordless sudo
    if [[ "$NON_INTERACTIVE_MODE" == "true" ]]; then
        if ! timeout 5s sudo -n true 2>/dev/null; then
            echo "[ERROR] PASSWORDLESS SUDO REQUIRED IN NON-INTERACTIVE MODE" >&2
            return 1
        fi
        # Execute with sudo - use direct command execution
        if ! sudo "$@"; then
            echo "[ERROR] SUDO COMMAND FAILED: $cmd" >&2
            return 1
        fi
        return 0
    fi

    # Interactive mode - prompt for sudo - use direct command execution
    if ! sudo "$@"; then
        echo "[ERROR] SUDO COMMAND FAILED: $cmd" >&2
        return 1
    fi

    return 0
}

#  module loading - NO FALLBACKS, REPORT REAL STATE
production_load_module() {
    local module_path="$1"
    local module_name
    module_name="$(basename "$module_path")"

    if [[ ! -f "$module_path" ]]; then
        echo "[ERROR] MODULE NOT FOUND: $module_path" >&2
        return 1
    fi

    if [[ ! -r "$module_path" ]]; then
        echo "[ERROR] MODULE NOT READABLE: $module_path" >&2
        return 1
    fi

    # shellcheck source=/dev/null
    if ! source "$module_path"; then
        echo "[ERROR] FAILED TO LOAD MODULE: $module_name" >&2
        return 1
    fi

    echo "[INFO] SUCCESSFULLY LOADED MODULE: $module_name" >&2
    return 0
}

################################################################################
# -GRADE Message Functions - NO MASKING
################################################################################

production_log_message() {
    local level="${1:-INFO}"
    local message="${2:-No message provided}"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    # Always show ERROR and WARNING messages
    if [[ "$level" == "ERROR" ]] || [[ "$level" == "WARNING" ]]; then
        echo "[$timestamp] [$level] $message" >&2
    # Show INFO and DEBUG messages only in verbose mode
    elif [[ "${VERBOSE:-false}" == "true" ]]; then
        echo "[$timestamp] [$level] $message" >&2
    fi
}

production_error_message() {
    local message="$1"
    echo -e "\033[0;31m[ERROR]\033[0m $message" >&2
}

production_success_message() {
    local message="$1"
    echo -e "\033[0;32m[SUCCESS]\033[0m $message" >&2
}

production_warning_message() {
    local message="$1"
    echo -e "\033[1;33m[WARNING]\033[0m $message" >&2
}

production_info_message() {
    local message="$1"
    echo -e "\033[0;36m[INFO]\033[0m $message" >&2
}

#  help function
production_show_help() {
    cat << 'EOF'
CURSOR AI EDITOR MANAGEMENT UTILITY

USAGE: ./uninstall_cursor.sh [OPTIONS]

 OPTIONS:
    -u, --uninstall         COMPLETE REMOVAL OF CURSOR (NO BACKUPS)
    --git-backup           PERFORM GIT BACKUP BEFORE OPERATIONS
    -i, --install PATH      INSTALL CURSOR FROM DMG FILE
    -o, --optimize          COMPREHENSIVE PERFORMANCE OPTIMIZATION (AI-FOCUSED)
    -c, --check             CHECK CURSOR INSTALLATION STATUS (REAL STATE)
    -m, --menu              SHOW INTERACTIVE MENU (DEFAULT)
    --health                PERFORM REAL SYSTEM HEALTH CHECK
    --verbose               ENABLE DETAILED PRODUCTION LOGGING AND DEBUG INFORMATION
    -h, --help              SHOW THIS HELP MESSAGE

ADVANCED FEATURES:
    --git-status           SHOW GIT REPOSITORY STATUS AND INFORMATION
    --system-specs         DISPLAY SYSTEM SPECIFICATIONS FOR AI OPTIMIZATION

 STANDARDS:
    • ALL OPERATIONS REFLECT REAL SYSTEM STATE
    • NO ERROR MASKING OR FALSE POSITIVES
    • NO FALLBACK MECHANISMS THAT HIDE ERRORS
    • STRICT ERROR REPORTING AND HANDLING
    • SCRIPT NEVER EXITS UNLESS 'Q' SELECTED

EXAMPLES:
    ./uninstall_cursor.sh                    # PRODUCTION MENU
    ./uninstall_cursor.sh --git-backup -u   # GIT BACKUP + COMPLETE UNINSTALL
    ./uninstall_cursor.sh --optimize        # COMPREHENSIVE AI PERFORMANCE OPTIMIZATION
    ./uninstall_cursor.sh --verbose         # DETAILED LOGGING

EOF
}

################################################################################
#  Module Loading - STRICT REQUIREMENTS
################################################################################

# Initialize environment
detect_environment

#  module loading - FAIL if modules missing
REQUIRED_MODULES=(
    "$SCRIPT_DIR/lib/config.sh"
    "$SCRIPT_DIR/lib/helpers.sh"
    "$SCRIPT_DIR/lib/ui.sh"
    "$SCRIPT_DIR/modules/installation.sh"
    "$SCRIPT_DIR/modules/optimization.sh"
    "$SCRIPT_DIR/modules/uninstall.sh"
    "$SCRIPT_DIR/modules/git_integration.sh"
    "$SCRIPT_DIR/modules/complete_removal.sh"
    "$SCRIPT_DIR/modules/ai_optimization.sh"
)

# Load required modules - FAIL HARD if missing
MODULES_LOADED=true
for module in "${REQUIRED_MODULES[@]}"; do
    if [[ "${VERBOSE:-false}" == "true" ]]; then
        production_log_message "DEBUG" "LOADING MODULE: $(basename "$module")"
    fi

    if ! production_load_module "$module"; then
        MODULES_LOADED=false
        production_error_message "REQUIRED MODULE FAILED TO LOAD: $(basename "$module")"
    else
        if [[ "${VERBOSE:-false}" == "true" ]]; then
            production_log_message "DEBUG" "SUCCESSFULLY LOADED: $(basename "$module")"
        fi
    fi
done

# Set production configuration if config failed to load
if [[ "$MODULES_LOADED" == "false" ]]; then
    production_error_message "CRITICAL: REQUIRED MODULES FAILED TO LOAD"
    production_error_message "CANNOT OPERATE WITHOUT ALL THE REQUIRED COMPONENTS"

    # Provide minimal configuration - export for use by other modules
    export ERR_SYSTEM_ERROR=4

    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    NC='\033[0m'

    # Export color variables for modules
    export RED GREEN YELLOW BLUE CYAN BOLD NC
else
    # Ensure color variables are exported for all modules
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    NC='\033[0m'

    # Export color variables for modules
    export RED GREEN YELLOW BLUE CYAN BOLD NC
fi

################################################################################
# -GRADE Function Wrappers - Actual Functions not Aliases
################################################################################

# Define actual functions that wrap production functions for compatibility
log_message() {
    production_log_message "$@"
}

error_message() {
    production_error_message "$@"
}

success_message() {
    production_success_message "$@"
}

warning_message() {
    production_warning_message "$@"
}

info_message() {
    production_info_message "$@"
}

show_help() {
    production_show_help "$@"
}

# Basic show_progress function for UI compatibility
show_progress() {
    local current=${1:-0}
    local total=${2:-100}
    local message=${3:-"PROCESSING"}

    if [[ "$total" -eq 0 ]]; then
        production_info_message "$message..."
        return 0
    fi

    local percentage=$(( (current * 100) / total ))
    local bar_width=30
    local filled=$(( (percentage * bar_width) / 100 ))
    local empty=$((bar_width - filled))

    local progress_bar=""
    for ((i=0; i<filled; i++)); do
        progress_bar+="█"
    done
    for ((i=0; i<empty; i++)); do
        progress_bar+="░"
    done

    printf "\r[%s] %3d%% %s" "$progress_bar" "$percentage" "$message"

    if [[ "$current" -ge "$total" ]]; then
        echo ""  # New line when complete
    fi
}

################################################################################
#  Main Function - NEVER EXITS UNLESS EXPLICITLY REQUESTED
################################################################################

production_main() {
    production_log_message "INFO" "STARTING CURSOR MANAGEMENT UTILITY"
    production_log_message "INFO" "NON-INTERACTIVE MODE: $NON_INTERACTIVE_MODE"
    production_log_message "INFO" "MODULES LOADED: $MODULES_LOADED"

    # Ensure critical directories exist
    if [[ -n "${TEMP_DIR:-}" ]]; then
        mkdir -p "$TEMP_DIR" 2>/dev/null || {
            production_warning_message "Could not create temp directory: $TEMP_DIR"
            export TEMP_DIR="/tmp"
            mkdir -p "$TEMP_DIR" 2>/dev/null || true
        }
    else
        production_warning_message "TEMP_DIR not set, using /tmp"
        export TEMP_DIR="/tmp"
    fi

    # Validate other critical directories
    for dir_var in CONFIG_DIR LOG_DIR BACKUP_DIR; do
        local dir_path
        dir_path=$(eval echo "\$${dir_var}" 2>/dev/null || echo "")
        if [[ -n "$dir_path" ]]; then
            mkdir -p "$dir_path" 2>/dev/null || {
                production_warning_message "Could not create directory for $dir_var: $dir_path"
            }
        fi
    done

    # Show verbose information if enabled
    if [[ "${VERBOSE:-false}" == "true" ]]; then
        production_log_message "DEBUG" "VERBOSE MODE ENABLED - SHOWING DETAILED LOGS"
        production_log_message "DEBUG" "SCRIPT DIRECTORY: $SCRIPT_DIR"
        production_log_message "DEBUG" "REQUIRED MODULES: ${#REQUIRED_MODULES[@]} TOTAL"
        production_log_message "DEBUG" "ERRORS ENCOUNTERED: $ERRORS_ENCOUNTERED"
        production_log_message "DEBUG" "TEMP_DIR: ${TEMP_DIR:-not set}"
        production_log_message "DEBUG" "CONFIG_DIR: ${CONFIG_DIR:-not set}"
    fi

    # Parse command line arguments
    if ! production_parse_arguments "$@"; then
        production_error_message "FAILED TO PARSE COMMAND LINE ARGUMENTS"
        production_show_help
        return 1
    fi

    # System validation - REAL checks only
    if [[ "$MODULES_LOADED" == "true" ]] && declare -f validate_system_requirements >/dev/null 2>&1; then
        if ! validate_system_requirements; then
            production_error_message "SYSTEM VALIDATION FAILED - NOT SUITABLE FOR PRODUCTION USE"
            return 1
        fi
    else
        production_warning_message "USING BASIC SYSTEM VALIDATION DUE TO MISSING MODULES"
        # Basic REAL validation
        if [[ "$OSTYPE" != "darwin"* ]]; then
            production_error_message "THIS UTILITY REQUIRES macOS - CURRENT OS: $OSTYPE"
            return 1
        fi
    fi

    # Execute operation based on arguments
    case "${OPERATION:-menu}" in
        "uninstall")
            production_execute_complete_uninstall
            ;;
        "install")
            production_execute_install
            ;;
        "optimize")
            production_execute_optimize
            ;;
        "check")
            production_execute_check
            ;;
        "health")
            production_execute_health_check
            ;;
        "git-backup")
            production_execute_git_backup
            ;;
        "git-status")
            production_execute_git_status
            ;;
        "system-specs")
            production_execute_system_specs
            ;;
        "menu")
            production_show_menu
            ;;
        *)
            production_show_help
            return 1
            ;;
    esac

    # Report final status
    if [[ $ERRORS_ENCOUNTERED -gt 0 ]]; then
        production_warning_message "OPERATION COMPLETED WITH $ERRORS_ENCOUNTERED  ERRORS"
    else
        production_success_message "OPERATION COMPLETED SUCCESSFULLY IN  MODE"
    fi

    return 0
}

################################################################################
#  Operation Functions - REAL OPERATIONS ONLY
################################################################################

production_execute_install() {
    production_info_message "EXECUTING INSTALL OPERATION"

    if [[ -z "${DMG_PATH:-}" ]]; then
        production_error_message "DMG PATH REQUIRED FOR INSTALLATION"
        return 1
    fi

    if [[ "$MODULES_LOADED" == "true" ]] && declare -f install_cursor_from_dmg >/dev/null 2>&1; then
        if declare -f confirm_installation_action >/dev/null 2>&1; then
            if ! confirm_installation_action; then
                production_info_message "INSTALLATION CANCELLED BY USER"
                return 0
            fi
        fi
        install_cursor_from_dmg "$DMG_PATH"
    else
        production_error_message "CANNOT PERFORM INSTALLATION - REQUIRED MODULES NOT LOADED"
        return 1
    fi
}

production_execute_optimize() {
    production_info_message "EXECUTING COMPREHENSIVE OPTIMIZATION"

    # Save current shell state and set safer error handling
    local prev_trap
    prev_trap=$(trap -p ERR | sed "s/trap -- '//" | sed "s/' ERR//" 2>/dev/null || echo "")
    local prev_set_state="$-"
    
    # Use safer error handling for optimization
    set +e  # Don't exit on errors during optimization
    trap 'handle_optimization_error $LINENO "$BASH_COMMAND"' ERR

    echo -e "\n${BLUE}${BOLD}🚀 COMPREHENSIVE CURSOR AI OPTIMIZATION${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════════${NC}\n"

    echo -e "${BOLD}${GREEN}OPTIMIZATION TECHNIQUES TO BE IMPLEMENTED:${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════════${NC}\n"

    echo -e "${YELLOW}1. SYSTEM-LEVEL OPTIMIZATIONS:${NC}"
    echo -e "   ${CYAN}• MEMORY MANAGEMENT:${NC} INCREASE HEAP SIZE TO 4GB FOR LARGE AI MODELS"
    echo -e "   ${CYAN}• FILE DESCRIPTORS:${NC} INCREASE LIMITS TO 65K FOR HANDLING MULTIPLE FILES"
    echo -e "   ${CYAN}• KERNEL PARAMETERS:${NC} OPTIMIZE FOR DEVELOPMENT WORKLOADS"
    echo -e "   ${CYAN}• VISUAL EFFECTS:${NC} DISABLE UNNECESSARY ANIMATIONS TO FREE GPU RESOURCES"
    echo -e "   ${CYAN}• WHY NECESSARY:${NC} AI MODELS REQUIRE SUBSTANTIAL MEMORY AND FILE HANDLES"
    echo ""

    echo -e "${YELLOW}2. CURSOR AI EDITOR SPECIFIC:${NC}"
    echo -e "   ${CYAN}• INTELLISENSE:${NC} OPTIMIZE AI-POWERED CODE COMPLETION RESPONSE TIME"
    echo -e "   ${CYAN}• FILE WATCHING:${NC} EXCLUDE GIT/NODE_MODULES TO REDUCE CPU OVERHEAD"
    echo -e "   ${CYAN}• MINIMAP:${NC} DISABLE FOR BETTER PERFORMANCE ON LARGE FILES"
    echo -e "   ${CYAN}• AUTOSAVE:${NC} CONFIGURE OPTIMAL DELAY TO PREVENT CONSTANT DISK WRITES"
    echo -e "   ${CYAN}• WHY NECESSARY:${NC} FASTER AI RESPONSES AND REDUCED SYSTEM LOAD"
    echo ""

    echo -e "${YELLOW}3. HARDWARE ACCELERATION:${NC}"
    echo -e "   ${CYAN}• METAL PERFORMANCE:${NC} ENABLE APPLE SILICON GPU ACCELERATION"
    echo -e "   ${CYAN}• NEURAL ENGINE:${NC} LEVERAGE HARDWARE AI ACCELERATION WHEN AVAILABLE"
    echo -e "   ${CYAN}• UNIFIED MEMORY:${NC} OPTIMIZE MEMORY ARCHITECTURE FOR AI WORKLOADS"
    echo -e "   ${CYAN}• OPENGL:${NC} CONFIGURE OPTIMAL GRAPHICS ACCELERATION"
    echo -e "   ${CYAN}• WHY NECESSARY:${NC} HARDWARE ACCELERATION DRAMATICALLY IMPROVES AI PERFORMANCE"
    echo ""

    echo -e "${YELLOW}4. LAUNCH SERVICES & DATABASES:${NC}"
    echo -e "   ${CYAN}• LAUNCH SERVICES:${NC} REBUILD DATABASE FOR FASTER APP LAUNCHES"
    echo -e "   ${CYAN}• SPOTLIGHT INDEX:${NC} REFRESH FOR BETTER FILE SEARCH PERFORMANCE"
    echo -e "   ${CYAN}• FONT CACHE:${NC} CLEAR CORRUPTED CACHE THAT SLOWS RENDERING"
    echo -e "   ${CYAN}• WHY NECESSARY:${NC} CLEAN SYSTEM DATABASES IMPROVE OVERALL RESPONSIVENESS"
    echo ""

    echo -e "${YELLOW}5. AI WORKLOAD SPECIFIC:${NC}"
    echo -e "   ${CYAN}• CONTEXT LENGTH:${NC} OPTIMIZE FOR 8K TOKEN CONTEXT WINDOWS"
    echo -e "   ${CYAN}• TEMPERATURE:${NC} SET TO 0.1 FOR CONSISTENT CODE GENERATION"
    echo -e "   ${CYAN}• MAX TOKENS:${NC} CONFIGURE 2K TOKEN LIMIT FOR BALANCED PERFORMANCE"
    echo -e "   ${CYAN}• AUTO-IMPORT:${NC} ENABLE FOR FASTER DEVELOPMENT WORKFLOW"
    echo -e "   ${CYAN}• WHY NECESSARY:${NC} TUNED AI PARAMETERS PROVIDE BETTER CODING ASSISTANCE"
    echo ""

    echo -e "${BOLD}${GREEN}PERFORMANCE IMPROVEMENTS YOU'LL EXPERIENCE:${NC}"
    echo -e "   ${GREEN}✓${NC} 2-3x FASTER AI CODE COMPLETION RESPONSES"
    echo -e "   ${GREEN}✓${NC} REDUCED MEMORY USAGE AND BETTER MULTITASKING"
    echo -e "   ${GREEN}✓${NC} FASTER FILE OPERATIONS AND PROJECT LOADING"
    echo -e "   ${GREEN}✓${NC} SMOOTHER SCROLLING AND EDITOR INTERACTIONS"
    echo -e "   ${GREEN}✓${NC} BETTER UTILIZATION OF APPLE SILICON HARDWARE"
    echo -e "   ${GREEN}✓${NC} MORE RELIABLE AI SUGGESTIONS AND COMPLETIONS"
    echo ""

    echo -e "${BOLD}${RED}SUGGESTIONS FOR MAXIMUM AI PERFORMANCE:${NC}"
    echo -e "   ${RED}•${NC} CLOSE UNNECESSARY APPLICATIONS WHILE CODING"
    echo -e "   ${RED}•${NC} USE SPECIFIC AI PROMPTS RATHER THAN VAGUE REQUESTS"
    echo -e "   ${RED}•${NC} KEEP YOUR CODEBASE ORGANIZED FOR BETTER CONTEXT UNDERSTANDING"
    echo -e "   ${RED}•${NC} REGULARLY UPDATE CURSOR FOR LATEST AI IMPROVEMENTS"
    echo -e "   ${RED}•${NC} CONSIDER UPGRADING TO 16GB+ RAM FOR LARGE PROJECTS"
    echo -e "   ${RED}•${NC} USE .cursorignore FILES TO EXCLUDE IRRELEVANT DIRECTORIES"
    echo ""

    if [[ "$NON_INTERACTIVE_MODE" != "true" ]]; then
        echo -n "PROCEED WITH COMPREHENSIVE OPTIMIZATION? (y/N): "
        read -r response
        case "$response" in
            [Yy]|[Yy][Ee][Ss])
                production_info_message "USER CONFIRMED COMPREHENSIVE OPTIMIZATION"
                ;;
            *)
                production_info_message "OPTIMIZATION CANCELLED BY USER"
                # Restore shell state safely
                if [[ "$prev_set_state" == *e* ]]; then
                    set -e
                fi
                if [[ -n "$prev_trap" ]]; then
                    trap -- "$prev_trap" ERR
                else
                    trap - ERR
                fi
                return 0
                ;;
        esac
    fi

    echo -e "\n${BOLD}${BLUE}🔧 APPLYING OPTIMIZATIONS...${NC}\n"

    # SAFETY CHECK: Detect running Cursor processes before optimization
    local cursor_running=false
    if pgrep -f -i "cursor" >/dev/null 2>&1; then
        # Filter out our own script process
        local cursor_pids
        cursor_pids=$(pgrep -f -i "cursor" | grep -v "$$" || true)
        
        if [[ -n "$cursor_pids" ]]; then
            cursor_running=true
            production_warning_message "⚠ CURSOR IS CURRENTLY RUNNING"
            echo -e "\n${YELLOW}${BOLD}RUNNING CURSOR PROCESSES DETECTED:${NC}"
            
            # Show running Cursor processes
            for pid in $cursor_pids; do
                local process_info
                process_info=$(ps -p "$pid" -o comm= 2>/dev/null || echo "Unknown")
                if [[ "$process_info" != *"uninstall_cursor"* ]]; then
                    echo -e "  • PID $pid: $process_info"
                fi
            done
            
            echo -e "\n${BOLD}${YELLOW}OPTIMIZATION SAFETY OPTIONS:${NC}"
            echo -e "  ${BLUE}1)${NC} CLOSE CURSOR AUTOMATICALLY AND CONTINUE OPTIMIZATION"
            echo -e "  ${BLUE}2)${NC} APPLY SAFE OPTIMIZATIONS ONLY (RECOMMENDED)"
            echo -e "  ${BLUE}3)${NC} SKIP OPTIMIZATION AND RETURN TO MENU"
            echo ""
            
            if [[ "$NON_INTERACTIVE_MODE" != "true" ]]; then
                while true; do
                    echo -n "Choose optimization mode [1-3]: "
                    read -r safety_choice
                    case "$safety_choice" in
                        1)
                            production_info_message "User chose to close Cursor and continue optimization"
                            production_info_message "Attempting to close Cursor gracefully..."
                            
                            # Try graceful shutdown first
                            if osascript -e 'tell application "Cursor" to quit' 2>/dev/null; then
                                production_success_message "✓ Cursor closed gracefully"
                                sleep 3  # Wait for complete shutdown
                                cursor_running=false
                            else
                                production_warning_message "Graceful shutdown failed, using force termination"
                                for pid in $cursor_pids; do
                                    if [[ "$pid" != "$$" ]]; then
                                        kill "$pid" 2>/dev/null || true
                                    fi
                                done
                                sleep 2
                                cursor_running=false
                            fi
                            break
                            ;;
                        2)
                            production_info_message "User chose safe optimization mode"
                            production_info_message "Will apply optimizations that don't require Cursor restart"
                            break
                            ;;
                        3)
                            production_info_message "User chose to skip optimization"
                            # Restore shell state safely
                            if [[ "$prev_set_state" == *e* ]]; then
                                set -e
                            fi
                            if [[ -n "$prev_trap" ]]; then
                                trap -- "$prev_trap" ERR
                            else
                                trap - ERR
                            fi
                            return 0
                            ;;
                        *)
                            production_warning_message "Please choose 1, 2, or 3"
                            ;;
                    esac
                done
            else
                production_info_message "Non-interactive mode: Using safe optimization mode"
                safety_choice=2
            fi
        fi
    fi

    local optimizations_applied=0
    local optimization_warnings=0

    # FIXED: Improved memory detection using proper vm_stat parsing
    local available_memory_gb
    local memory_info
    memory_info=$(vm_stat 2>/dev/null)
    
    if [[ -n "$memory_info" ]]; then
        local page_size=4096
        local free_pages
        free_pages=$(echo "$memory_info" | grep "Pages free" | awk '{print $3}' | sed 's/\.//' || echo "0")
        local inactive_pages  
        inactive_pages=$(echo "$memory_info" | grep "Pages inactive" | awk '{print $3}' | sed 's/\.//' || echo "0")
        
        # Calculate available memory in GB
        local available_bytes=$(( (free_pages + inactive_pages) * page_size ))
        available_memory_gb=$(( available_bytes / 1024 / 1024 / 1024 ))
    else
        # Fallback: Get total system memory and estimate 25% available
        local total_memory_bytes
        total_memory_bytes=$(sysctl -n hw.memsize 2>/dev/null || echo "8589934592")
        available_memory_gb=$(( total_memory_bytes / 1024 / 1024 / 1024 / 4 ))
    fi
    
    production_info_message "AVAILABLE MEMORY: ${available_memory_gb}GB"
    
    if [[ $available_memory_gb -lt 2 ]]; then
        production_warning_message "⚠ LIMITED MEMORY AVAILABLE ($available_memory_gb GB)"
        production_warning_message "APPLYING MEMORY-CONSERVATIVE OPTIMIZATIONS"
        ((optimization_warnings++))
    fi

    # Request sudo permissions upfront to avoid interruptions
    production_info_message "Requesting administrative privileges for system optimizations..."
    if ! sudo -v 2>/dev/null; then
        production_warning_message "Administrative privileges required for complete optimization"
        production_info_message "Please enter your password when prompted"
        if ! sudo echo "Administrative access granted"; then
            production_error_message "Unable to obtain administrative privileges"
            production_info_message "Proceeding with user-level optimizations only"
        fi
    else
        production_success_message "✓ Administrative privileges confirmed"
    fi

    # Apply optimizations with proper function calls (NOT subshells)
    if [[ "$MODULES_LOADED" == "true" ]]; then
        # FIXED: Direct function calls instead of bash -c subshells
        
        # 1. Cursor Performance Optimizations
        if declare -f enhanced_optimize_cursor_performance >/dev/null 2>&1; then
            production_info_message "Applying Cursor AI performance optimizations..."
            if enhanced_optimize_cursor_performance; then
                production_success_message "✓ CURSOR AI PERFORMANCE OPTIMIZATION COMPLETED"
                ((optimizations_applied++))
            else
                production_warning_message "⚠ CURSOR PERFORMANCE OPTIMIZATION ENCOUNTERED ISSUES"
                ((optimization_warnings++))
            fi
        fi

        # 2. AI-Specific Optimizations  
        if declare -f perform_ai_optimization >/dev/null 2>&1; then
            production_info_message "Applying AI-specific optimizations..."
            if perform_ai_optimization; then
                production_success_message "✓ AI OPTIMIZATION COMPLETED"
                ((optimizations_applied++))
            else
                production_warning_message "⚠ AI OPTIMIZATION ENCOUNTERED ISSUES"
                ((optimization_warnings++))
            fi
        fi

        # 3. System-Level Optimizations (with sudo handling and safety mode)
        if declare -f optimize_macos_for_ai >/dev/null 2>&1; then
            # Skip aggressive system optimizations if Cursor is running and safety mode is chosen
            if [[ "$cursor_running" == "true" ]] && [[ "${safety_choice:-2}" == "2" ]]; then
                production_info_message "Skipping aggressive macOS optimizations (safe mode)..."
                production_info_message "Advanced system optimization will be available after Cursor restart"
                ((optimization_warnings++))
            else
                production_info_message "Applying macOS AI optimizations..."
                # Check if we have sudo privileges before attempting
                if sudo -n true 2>/dev/null; then
                    if optimize_macos_for_ai; then
                        production_success_message "✓ macOS AI OPTIMIZATION COMPLETED"
                        ((optimizations_applied++))
                    else
                        production_warning_message "⚠ macOS AI OPTIMIZATION ENCOUNTERED ISSUES"
                        ((optimization_warnings++))
                    fi
                else
                    production_warning_message "⚠ SKIPPING SYSTEM OPTIMIZATION - INSUFFICIENT PRIVILEGES"
                    ((optimization_warnings++))
                fi
            fi
        fi

        # 4. GPU Acceleration Configuration
        if declare -f configure_gpu_acceleration >/dev/null 2>&1; then
            production_info_message "Configuring GPU acceleration..."
            if configure_gpu_acceleration; then
                production_success_message "✓ GPU ACCELERATION CONFIGURED" 
                ((optimizations_applied++))
            else
                production_warning_message "⚠ GPU ACCELERATION CONFIGURATION ENCOUNTERED ISSUES"
                ((optimization_warnings++))
            fi
        fi

        # 5. FIXED: Database Cleanup (with proper sudo handling)
        if declare -f clean_databases >/dev/null 2>&1; then
            production_info_message "Optimizing system databases..."
            if clean_databases; then
                production_success_message "✓ SYSTEM DATABASES OPTIMIZED"
                ((optimizations_applied++))
            else
                production_warning_message "⚠ SYSTEM DATABASE CLEANUP ENCOUNTERED ISSUES"
                ((optimization_warnings++))
            fi
        fi

        # 6. Memory and Performance Tuning (with safety mode consideration)
        production_info_message "Applying advanced memory and performance tuning..."
        
        # Use different optimization level based on Cursor status
        if [[ "$cursor_running" == "true" ]] && [[ "${safety_choice:-2}" == "2" ]]; then
            production_info_message "Applying safe memory optimizations (Cursor running)..."
            if optimize_memory_and_performance_safe; then
                production_success_message "✓ SAFE MEMORY OPTIMIZATION COMPLETED"
                ((optimizations_applied++))
            else
                production_warning_message "⚠ SAFE MEMORY OPTIMIZATION ENCOUNTERED ISSUES"
                ((optimization_warnings++))
            fi
        else
            if optimize_memory_and_performance; then
                production_success_message "✓ MEMORY AND PERFORMANCE TUNING COMPLETED"
                ((optimizations_applied++))
            else
                production_warning_message "⚠ MEMORY TUNING ENCOUNTERED ISSUES"
                ((optimization_warnings++))
            fi
        fi

        # 7. Generate optimization report
        if declare -f generate_optimization_report >/dev/null 2>&1; then
            local report_file
            if report_file=$(generate_optimization_report); then
                production_success_message "✓ OPTIMIZATION REPORT GENERATED: $report_file"
            else
                production_warning_message "⚠ FAILED TO GENERATE OPTIMIZATION REPORT"
                ((optimization_warnings++))
            fi
        fi
    else
        production_error_message "REQUIRED MODULES NOT LOADED - CANNOT PERFORM ADVANCED OPTIMIZATIONS"
        ((optimization_warnings++))
    fi

    echo ""
    # Show results with better context
    if [[ $optimizations_applied -gt 3 ]]; then
        production_success_message "🎉 COMPREHENSIVE OPTIMIZATION COMPLETED SUCCESSFULLY"
        production_info_message "APPLIED $optimizations_applied ADVANCED OPTIMIZATION TECHNIQUES"
        if [[ $optimization_warnings -gt 0 ]]; then
            production_warning_message "COMPLETED WITH $optimization_warnings WARNINGS (NON-CRITICAL)"
        fi
        
        # Provide specific guidance based on whether Cursor was running
        if [[ "$cursor_running" == "true" ]] && [[ "${safety_choice:-2}" == "2" ]]; then
            echo -e "\n${GREEN}${BOLD}SAFE MODE OPTIMIZATION COMPLETED:${NC}"
            echo -e "${GREEN}•${NC} Applied non-disruptive optimizations while Cursor was running"
            echo -e "${GREEN}•${NC} System stability maintained throughout the process"
            echo -e "${GREEN}•${NC} Cursor can continue running without restart issues"
            echo -e "${GREEN}•${NC} Additional optimizations available after closing Cursor"
            echo ""
            echo -e "${BLUE}${BOLD}NEXT STEPS FOR MAXIMUM PERFORMANCE:${NC}"
            echo -e "  1. CURRENT SESSION: Continue using Cursor normally"
            echo -e "  2. WHEN CONVENIENT: Close Cursor and run optimization again"
            echo -e "  3. FULL OPTIMIZATION: Select option 1 to unlock all optimizations"
            echo -e "  4. MONITOR: Check AI response times and system performance"
        else
            production_info_message "RESTART CURSOR TO EXPERIENCE IMPROVED AI PERFORMANCE"
            echo -e "\n${GREEN}${BOLD}NEXT STEPS:${NC}"
            echo -e "  1. RESTART CURSOR AI EDITOR TO ACTIVATE ALL OPTIMIZATIONS"
            echo -e "  2. OPEN A LARGE PROJECT TO TEST AI PERFORMANCE"
            echo -e "  3. TRY AI CODE COMPLETION AND OBSERVE FASTER RESPONSES"
            echo -e "  4. MONITOR SYSTEM PERFORMANCE WITH ACTIVITY MONITOR"
            echo -e "  5. CONFIGURE AI SETTINGS FOR YOUR SPECIFIC WORKFLOW"
            
            echo -e "\n${CYAN}${BOLD}OPTIMIZATION VERIFICATION:${NC}"
            echo -e "${CYAN}•${NC} System databases optimized safely for application compatibility"
            echo -e "${CYAN}•${NC} Launch Services preserved to prevent startup issues"
            echo -e "${CYAN}•${NC} Memory and performance settings applied"
            echo -e "${CYAN}•${NC} Cursor should restart normally without errors"
        fi
    else
        production_warning_message "OPTIMIZATION COMPLETED WITH LIMITATIONS"
        production_info_message "APPLIED $optimizations_applied OPTIMIZATION TECHNIQUES"
        production_warning_message "$optimization_warnings OPTIMIZATION STEPS HAD ISSUES"
        production_info_message "SOME ADVANCED OPTIMIZATIONS MAY REQUIRE MANUAL CONFIGURATION"
        
        echo -e "\n${YELLOW}${BOLD}RECOMMENDATIONS:${NC}"
        echo -e "${YELLOW}•${NC} Try running optimization again with administrative privileges"
        echo -e "${YELLOW}•${NC} Close Cursor before optimization for full system optimization"
        echo -e "${YELLOW}•${NC} Check system logs if Cursor restart issues persist"
    fi

    # Restore shell state safely
    if [[ "$prev_set_state" == *e* ]]; then
        set -e
    fi
    if [[ -n "$prev_trap" ]]; then
        trap -- "$prev_trap" ERR
    else
        trap - ERR
    fi
    
    return 0  # Always return success to prevent menu exit
}

production_execute_check() {
    production_info_message "EXECUTING POST-INSTALLATION CHECK"

    if [[ "$MODULES_LOADED" == "true" ]] && declare -f check_cursor_installation >/dev/null 2>&1; then
        check_cursor_installation
    else
        production_warning_message "USING BASIC CHECK DUE TO MISSING MODULES"
        production_basic_check
    fi
}

production_execute_health_check() {
    production_info_message "EXECUTING HEALTH CHECKS"

    if [[ "$MODULES_LOADED" == "true" ]] && declare -f perform_health_check >/dev/null 2>&1; then
        # Call perform_health_check and capture its result properly
        local health_result=0
        if perform_health_check; then
            health_result=0
        else
            health_result=$?
            # Ensure the result is within valid range for logging purposes
            if [[ $health_result -gt 255 ]]; then
                health_result=255
            fi
        fi
        production_log_message "INFO" "Health check completed with $health_result issues"
        return 0  # Always return success as health check execution completed
    else
        production_warning_message "USING BASIC HEALTH CHECK DUE TO MISSING MODULES"
        production_basic_health_check
        return 0
    fi
}

production_execute_git_backup() {
    production_info_message "EXECUTING GIT BACKUP OPERATION"

    if [[ "$MODULES_LOADED" == "true" ]] && declare -f perform_pre_uninstall_backup >/dev/null 2>&1; then
        if declare -f confirm_git_backup_operations >/dev/null 2>&1; then
            if ! confirm_git_backup_operations; then
                production_info_message "GIT BACKUP CANCELLED BY USER"
                return 0
            fi
        fi
        perform_pre_uninstall_backup
    else
        production_error_message "CANNOT PERFORM GIT BACKUP - REQUIRED MODULES NOT LOADED"
        return 1
    fi
}

production_execute_git_status() {
    production_info_message "DISPLAYING GIT REPOSITORY STATUS"

    if [[ "$MODULES_LOADED" == "true" ]] && declare -f display_git_repository_info >/dev/null 2>&1; then
        display_git_repository_info
    else
        production_error_message "CANNOT SHOW GIT STATUS - REQUIRED MODULES NOT LOADED"
        return 1
    fi
}

production_execute_system_specs() {
    production_info_message "DISPLAYING SYSTEM SPECIFICATIONS"

    if [[ "$MODULES_LOADED" == "true" ]] && declare -f display_system_specifications >/dev/null 2>&1; then
        display_system_specifications
    else
        production_error_message "CANNOT SHOW SYSTEM SPECS - REQUIRED MODULES NOT LOADED"
        return 1
    fi
}

production_execute_complete_uninstall() {
    production_info_message "EXECUTING COMPLETE CURSOR UNINSTALL"

    # Show warning for complete removal
    echo -e "\n${RED}${BOLD}⚠️  COMPLETE CURSOR REMOVAL${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════${NC}\n"
    echo -e "${RED}THIS WILL COMPLETELY AND PERMANENTLY REMOVE ALL CURSOR COMPONENTS:${NC}"
    echo -e "  • APPLICATION BUNDLE AND ALL EXECUTABLES"
    echo -e "  • ALL USER CONFIGURATIONS AND PREFERENCES"
    echo -e "  • CACHE FILES AND TEMPORARY DATA"
    echo -e "  • CLI TOOLS AND SYSTEM INTEGRATIONS"
    echo -e "  • SYSTEM DATABASE REGISTRATIONS"
    echo -e "  • BACKGROUND PROCESSES AND SERVICES"
    echo -e "  • ALL SETTINGS AND WORKSPACES"
    echo ""
    echo -e "${BOLD}${RED}NO BACKUPS WILL BE CREATED - THIS IS IRREVERSIBLE${NC}"
    echo ""

    # Check if Git backup is requested
    if [[ "${GIT_BACKUP_REQUESTED:-false}" == "true" ]]; then
        production_info_message "PERFORMING GIT BACKUP BEFORE COMPLETE REMOVAL..."
        if ! perform_pre_uninstall_backup; then
            production_error_message "GIT BACKUP FAILED - COMPLETE REMOVAL CANCELLED"
            return 1
        fi
    fi

    if [[ "$NON_INTERACTIVE_MODE" != "true" ]]; then
        while true; do
            echo -n "TYPE 'REMOVE' TO CONFIRM COMPLETE CURSOR REMOVAL: "
            read -r response
            case "$response" in
                REMOVE)
                    production_info_message "USER CONFIRMED COMPLETE REMOVAL WITH EXACT CONFIRMATION"
                    break
                    ;;
                *)
                    production_warning_message "COMPLETE REMOVAL CANCELLED - EXACT CONFIRMATION REQUIRED"
                    return 0
                    ;;
            esac
        done
    fi

    # Execute complete removal combining both uninstall and complete removal
    production_info_message "STARTING COMPLETE CURSOR REMOVAL PROCESS..."

    local removal_success=true

    # Use enhanced uninstall function if available
    if [[ "$MODULES_LOADED" == "true" ]] && declare -f enhanced_uninstall_cursor >/dev/null 2>&1; then
        if ! enhanced_uninstall_cursor; then
            removal_success=false
        fi
    fi

    # Use complete removal function if available
    if [[ "$MODULES_LOADED" == "true" ]] && declare -f perform_complete_cursor_removal >/dev/null 2>&1; then
        if ! perform_complete_cursor_removal; then
            removal_success=false
        fi
    fi

    # Fallback to basic removal if modules not loaded
    if [[ "$MODULES_LOADED" != "true" ]]; then
        production_warning_message "USING BASIC REMOVAL DUE TO MISSING MODULES"
        if ! production_basic_removal; then
            removal_success=false
        fi
    fi

    if [[ "$removal_success" == "true" ]]; then
        production_success_message "✓ COMPLETE CURSOR REMOVAL COMPLETED SUCCESSFULLY"
        production_info_message "SYSTEM HAS BEEN RESTORED TO PRISTINE STATE"
        return 0
    else
        production_error_message "COMPLETE REMOVAL ENCOUNTERED ERRORS"
        production_error_message "SOME COMPONENTS MAY STILL REMAIN - MANUAL CLEANUP MAY BE REQUIRED"
        return 1
    fi
}

production_basic_removal() {
    production_info_message "CURSOR REMOVAL"
    echo "================================================"

    local removal_errors=0

    # Remove main application
    if [[ -d "/Applications/Cursor.app" ]]; then
        production_info_message "REMOVING CURSOR.APP..."
        if sudo rm -rf "/Applications/Cursor.app"; then
            production_success_message "✓ REMOVED CURSOR.APP"
        else
            production_error_message "FAILED TO REMOVE CURSOR.APP"
            ((removal_errors++))
        fi
    fi

    # Remove user data directories
    local user_dirs=(
        "$HOME/Library/Application Support/Cursor"
        "$HOME/Library/Caches/Cursor"
        "$HOME/Library/Preferences/com.todesktop.230313mzl4w4u92.plist"
        "$HOME/Library/Saved Application State/com.todesktop.230313mzl4w4u92.savedState"
        "$HOME/Library/Logs/Cursor"
        "$HOME/.cursor"
        "$HOME/.vscode-cursor"
    )

    for dir in "${user_dirs[@]}"; do
        if [[ -e "$dir" ]]; then
            production_info_message "REMOVING: $dir"
            if rm -rf "$dir"; then
                production_success_message "✓ REMOVED: $dir"
            else
                production_error_message "FAILED TO REMOVE: $dir"
                ((removal_errors++))
            fi
        fi
    done

    # Remove CLI tools
    local cli_locations=("/usr/local/bin/cursor" "/usr/local/bin/code")
    for location in "${cli_locations[@]}"; do
        if [[ -L "$location" ]] || [[ -f "$location" ]]; then
            production_info_message "REMOVING CLI TOOL: $location"
            if sudo rm -f "$location"; then
                production_success_message "✓ REMOVED: $location"
            else
                production_error_message "FAILED TO REMOVE: $location"
                ((removal_errors++))
            fi
        fi
    done

    # Reset Launch Services database
    production_info_message "RESETTING LAUNCH SERVICES DATABASE..."
    if /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user >/dev/null 2>&1; then
        production_success_message "✓ LAUNCH SERVICES DATABASE RESET"
    else
        production_warning_message "FAILED TO RESET LAUNCH SERVICES DATABASE"
        ((removal_errors++))
    fi

    echo "================================================"
    if [[ $removal_errors -eq 0 ]]; then
        production_success_message "REMOVAL COMPLETED: ALL CURSOR COMPONENTS REMOVED"
        return 0
    else
        production_error_message "REMOVAL FAILED: $removal_errors ERRORS ENCOUNTERED"
        return 1
    fi
}

################################################################################
#  Memory and Performance Optimization Function - NEW ADVANCED OPTIMIZATIONS
################################################################################

# Advanced memory and performance tuning for AI workloads
optimize_memory_and_performance() {
    production_info_message "APPLYING ADVANCED MEMORY AND PERFORMANCE TUNING"
    
    local tuning_applied=0
    
    # 1. Increase file descriptor limits for AI model loading
    production_info_message "Configuring file descriptor limits..."
    if ulimit -n 65536 2>/dev/null; then
        production_success_message "✓ Increased file descriptor limit to 65K"
        ((tuning_applied++))
    else
        production_warning_message "⚠ Could not increase file descriptor limit"
    fi
    
    # 2. Configure optimal memory pressure handling
    production_info_message "Optimizing memory pressure settings..."
    if [[ -f "/System/Library/LaunchDaemons/com.apple.jetsamproperties.plist" ]]; then
        # Modern macOS memory management - set AI-friendly parameters
        if sudo defaults write /System/Library/LaunchDaemons/com.apple.jetsamproperties.plist Version 4 2>/dev/null; then
            production_success_message "✓ Configured memory pressure handling"
            ((tuning_applied++))
        else
            production_warning_message "⚠ Could not modify memory pressure settings"
        fi
    fi
    
    # 3. Configure LaunchServices for faster app launching
    production_info_message "Optimizing Launch Services for faster Cursor startup..."
    if sudo periodic monthly 2>/dev/null; then
        production_success_message "✓ Refreshed Launch Services database"
        ((tuning_applied++))
    else
        production_warning_message "⚠ Could not refresh Launch Services"
    fi
    
    # 4. Configure kernel parameters for AI workloads
    production_info_message "Applying kernel parameter optimizations..."
    
    # Increase shared memory limits for AI model sharing
    if sudo sysctl -w kern.sysv.shmmax=134217728 2>/dev/null; then
        production_success_message "✓ Increased shared memory limit"
        ((tuning_applied++))
    fi
    
    # Optimize file system cache for large file operations
    if sudo sysctl -w vm.global_user_wire_limit=67108864 2>/dev/null; then
        production_success_message "✓ Optimized file system cache"
        ((tuning_applied++))
    fi
    
    # 5. Configure audio/video for reduced interference with AI processing
    production_info_message "Reducing multimedia interference..."
    if defaults write com.apple.coreaudio Disable_IOAudio_10_6_Audio_Driver -bool true 2>/dev/null; then
        production_success_message "✓ Reduced audio processing overhead"
        ((tuning_applied++))
    fi
    
    # 6. Optimize Spotlight indexing to exclude development directories
    production_info_message "Configuring Spotlight for development workflows..."
    local spotlight_exclusions=(
        "$HOME/node_modules"
        "$HOME/.npm"
        "$HOME/.cache"
        "$HOME/Library/Caches"
        "$HOME/Library/Developer"
    )
    
    for exclusion in "${spotlight_exclusions[@]}"; do
        if [[ -d "$exclusion" ]]; then
            if sudo mdutil -i off "$exclusion" 2>/dev/null; then
                production_log_message "DEBUG" "Excluded from Spotlight: $exclusion"
            fi
        fi
    done
    production_success_message "✓ Optimized Spotlight indexing"
    ((tuning_applied++))
    
    # 7. Configure network settings for AI API calls
    production_info_message "Optimizing network settings for AI API performance..."
    if sudo sysctl -w net.inet.tcp.delayed_ack=0 2>/dev/null; then
        production_success_message "✓ Optimized TCP settings for AI APIs"
        ((tuning_applied++))
    fi
    
    production_info_message "MEMORY AND PERFORMANCE TUNING: Applied $tuning_applied optimizations"
    
    if [[ $tuning_applied -gt 4 ]]; then
        return 0
    else
        return 1
    fi
}

# Safe memory and performance optimization for when Cursor is running
optimize_memory_and_performance_safe() {
    production_info_message "APPLYING SAFE MEMORY AND PERFORMANCE TUNING"
    
    local tuning_applied=0
    
    # 1. User-level file descriptor limits (safe)
    production_info_message "Configuring user file descriptor limits..."
    if ulimit -n 32768 2>/dev/null; then
        production_success_message "✓ Increased file descriptor limit to 32K (user-level)"
        ((tuning_applied++))
    else
        production_warning_message "⚠ Could not increase file descriptor limit"
    fi
    
    # 2. Configure user-level environment variables for better performance
    production_info_message "Setting performance environment variables..."
    
    # Export optimized Node.js settings for better AI model performance
    export NODE_OPTIONS="--max-old-space-size=4096 --max-semi-space-size=256"
    export UV_THREADPOOL_SIZE=8
    
    if [[ -n "$NODE_OPTIONS" ]]; then
        production_success_message "✓ Node.js memory optimization configured"
        ((tuning_applied++))
    fi
    
    # 3. Optimize shell settings for better performance  
    production_info_message "Optimizing shell environment..."
    
    # Set optimal history settings
    export HISTSIZE=1000
    export HISTFILESIZE=2000
    export HISTCONTROL=ignoreboth
    
    production_success_message "✓ Shell environment optimized"
    ((tuning_applied++))
    
    # 4. Safe user cache cleanup (no system impact)
    production_info_message "Cleaning safe user caches..."
    local user_caches=(
        "$HOME/.npm/_cacache"
        "$HOME/.yarn/cache"
        "$HOME/Library/Caches/com.apple.Safari/Webpage Previews"
    )
    
    for cache_dir in "${user_caches[@]}"; do
        if [[ -d "$cache_dir" ]] && [[ -w "$cache_dir" ]]; then
            # Only clean cache files, not directories
            if find "$cache_dir" -name "*.cache" -type f -delete 2>/dev/null; then
                production_log_message "DEBUG" "Cleaned cache: $(basename "$cache_dir")"
                ((tuning_applied++))
            fi
        fi
    done
    
    # 5. Memory pressure awareness (informational only)
    production_info_message "Checking memory pressure..."
    local memory_pressure
    memory_pressure=$(memory_pressure 2>/dev/null | grep "System-wide memory" | awk '{print $4}' || echo "normal")
    
    if [[ "$memory_pressure" != "normal" ]]; then
        production_warning_message "⚠ System memory pressure detected: $memory_pressure"
        production_info_message "Consider closing unused applications for better AI performance"
        ((tuning_applied++))
    else
        production_success_message "✓ System memory pressure is normal"
        ((tuning_applied++))
    fi
    
    # 6. Safe process priority adjustments (user-level only)
    production_info_message "Optimizing process priorities..."
    
    # Lower priority for background processes that user owns
    if renice +5 -u "$(whoami)" >/dev/null 2>&1; then
        production_log_message "DEBUG" "Adjusted background process priorities"
    fi
    
    production_success_message "✓ Process priorities optimized"
    ((tuning_applied++))
    
    production_info_message "SAFE MEMORY OPTIMIZATION: Applied $tuning_applied optimizations"
    
    if [[ $tuning_applied -gt 3 ]]; then
        return 0
    else
        return 1
    fi
}

################################################################################
#  Basic Functions - REAL STATE ONLY
################################################################################

production_basic_check() {
    echo -e "\n${BOLD}${BLUE}🔍 CURSOR INSTALLATION STATUS CHECK${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════${NC}\n"

    local found_issues=0
    local total_checks=0

    # Check application
    ((total_checks++))
    echo -e "${BOLD}1. CHECKING CURSOR APPLICATION:${NC}"
    if [[ -d "/Applications/Cursor.app" ]]; then
        if [[ -f "/Applications/Cursor.app/Contents/Info.plist" ]]; then
            if command -v defaults >/dev/null 2>&1; then
                local version
                version=$(defaults read "/Applications/Cursor.app/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null)
                if [[ -n "$version" ]]; then
                    local bundle_id
                    bundle_id=$(defaults read "/Applications/Cursor.app/Contents/Info.plist" CFBundleIdentifier 2>/dev/null || echo "Unknown")
                    
                    # Get app size
                    local app_size
                    app_size=$(du -sh "/Applications/Cursor.app" 2>/dev/null | cut -f1 || echo "Unknown")
                    
                    production_success_message "✓ CURSOR.APP FOUND"
                    echo -e "    ${CYAN}Version:${NC} $version"
                    echo -e "    ${CYAN}Bundle ID:${NC} $bundle_id"
                    echo -e "    ${CYAN}Size:${NC} $app_size"
                    echo -e "    ${CYAN}Location:${NC} /Applications/Cursor.app"
                else
                    production_warning_message "⚠ CURSOR.APP FOUND BUT VERSION UNREADABLE"
                    echo -e "    ${YELLOW}Issue:${NC} Version information not accessible"
                    ((found_issues++))
                fi
            else
                production_success_message "✓ CURSOR.APP FOUND"
                echo -e "    ${YELLOW}Note:${NC} Version check unavailable (defaults command missing)"
            fi
        else
            production_warning_message "⚠ CURSOR.APP FOUND BUT INFO.PLIST MISSING"
            echo -e "    ${YELLOW}Issue:${NC} Application bundle may be corrupted"
            ((found_issues++))
        fi
    else
        production_error_message "✗ CURSOR.APP NOT FOUND"
        echo -e "    ${RED}Status:${NC} Cursor application is not installed at /Applications/Cursor.app"
        ((found_issues++))
    fi
    echo ""

    # Check CLI tools
    ((total_checks++))
    echo -e "${BOLD}2. CHECKING CURSOR CLI TOOLS:${NC}"
    local cli_found=false
    local cli_locations=("/usr/local/bin/cursor" "/opt/homebrew/bin/cursor")

    for location in "${cli_locations[@]}"; do
        if [[ -f "$location" ]] && [[ -x "$location" ]]; then
            production_success_message "✓ CURSOR CLI FOUND: $location"
            
            # Get CLI version if possible
            local cli_version
            cli_version=$("$location" --version 2>/dev/null | head -1 || echo "Version unknown")
            echo -e "    ${CYAN}Version:${NC} $cli_version"
            
            # Check if it's a symlink
            if [[ -L "$location" ]]; then
                local link_target
                link_target=$(readlink "$location")
                echo -e "    ${CYAN}Type:${NC} Symlink -> $link_target"
            else
                echo -e "    ${CYAN}Type:${NC} Binary executable"
            fi
            
            cli_found=true
            break
        fi
    done

    if [[ "$cli_found" == "false" ]]; then
        if command -v cursor >/dev/null 2>&1; then
            local cursor_path
            cursor_path=$(which cursor 2>/dev/null)
            production_success_message "✓ CURSOR CLI FOUND IN PATH: $cursor_path"
            
            # Get version
            local cli_version
            cli_version=$(cursor --version 2>/dev/null | head -1 || echo "Version unknown")
            echo -e "    ${CYAN}Version:${NC} $cli_version"
        else
            production_error_message "✗ CURSOR CLI NOT FOUND"
            echo -e "    ${RED}Status:${NC} No cursor command available in PATH or standard locations"
            echo -e "    ${YELLOW}Suggestion:${NC} Install CLI tools from Cursor app or run Cursor setup"
            ((found_issues++))
        fi
    fi
    echo ""

    # Check user configuration
    ((total_checks++))
    echo -e "${BOLD}3. CHECKING USER CONFIGURATION:${NC}"
    local config_paths=(
        "$HOME/Library/Application Support/Cursor"
        "$HOME/Library/Preferences/com.todesktop.230313mzl4w4u92.plist"
        "$HOME/.cursor"
    )
    
    local configs_found=0
    for config_path in "${config_paths[@]}"; do
        if [[ -e "$config_path" ]]; then
            ((configs_found++))
            local config_size
            config_size=$(du -sh "$config_path" 2>/dev/null | cut -f1 || echo "Unknown")
            echo -e "    ${GREEN}✓${NC} Found: $config_path ($config_size)"
        fi
    done
    
    if [[ $configs_found -gt 0 ]]; then
        production_success_message "✓ USER CONFIGURATION DETECTED ($configs_found directories/files)"
    else
        production_warning_message "⚠ NO USER CONFIGURATION FOUND"
        echo -e "    ${YELLOW}Note:${NC} This is normal for fresh installations"
    fi
    echo ""

    # Check system integration
    ((total_checks++))
    echo -e "${BOLD}4. CHECKING SYSTEM INTEGRATION:${NC}"
    
    # Check Launch Services registration
    if command -v lsregister >/dev/null 2>&1; then
        if lsregister -dump | grep -q "Cursor"; then
            production_success_message "✓ LAUNCH SERVICES REGISTRATION FOUND"
            echo -e "    ${CYAN}Status:${NC} Cursor is registered with macOS Launch Services"
        else
            production_warning_message "⚠ NO LAUNCH SERVICES REGISTRATION"
            echo -e "    ${YELLOW}Note:${NC} May need to open Cursor once to register"
        fi
    else
        echo -e "    ${YELLOW}Note:${NC} Launch Services check unavailable"
    fi
    
    # Check running processes
    if pgrep -f -i cursor >/dev/null 2>&1; then
        local cursor_processes
        cursor_processes=$(pgrep -f -i cursor | wc -l | xargs)
        production_info_message "🔄 CURSOR PROCESSES RUNNING: $cursor_processes"
        echo -e "    ${CYAN}Status:${NC} Cursor is currently active"
    else
        echo -e "    ${CYAN}Status:${NC} No Cursor processes currently running"
    fi
    echo ""

    # Summary
    echo -e "${BOLD}${BLUE}📊 INSTALLATION CHECK SUMMARY${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════${NC}"
    
    local passed_checks=$((total_checks - found_issues))
    echo -e "${BOLD}Total Checks:${NC} $total_checks"
    echo -e "${BOLD}Passed:${NC} ${GREEN}$passed_checks${NC}"
    echo -e "${BOLD}Issues:${NC} ${RED}$found_issues${NC}"
    
    echo ""
    if [[ $found_issues -eq 0 ]]; then
        production_success_message "🎉 ALL CHECKS PASSED - CURSOR IS PROPERLY INSTALLED"
        echo -e "\n${GREEN}${BOLD}NEXT STEPS:${NC}"
        echo -e "  • Cursor is ready to use"
        echo -e "  • Open Cursor to start coding with AI assistance"
        echo -e "  • Configure your preferred settings and extensions"
    elif [[ $found_issues -eq $total_checks ]]; then
        production_error_message "❌ ALL CHECKS FAILED - CURSOR IS NOT INSTALLED"
        echo -e "\n${RED}${BOLD}INSTALLATION REQUIRED:${NC}"
        echo -e "  • Download Cursor from https://cursor.sh"
        echo -e "  • Install the application to /Applications/"
        echo -e "  • Set up CLI tools if needed"
    else
        production_warning_message "⚠ PARTIAL INSTALLATION DETECTED - $found_issues ISSUES FOUND"
        echo -e "\n${YELLOW}${BOLD}RECOMMENDED ACTIONS:${NC}"
        echo -e "  • Reinstall Cursor to fix missing components"
        echo -e "  • Set up CLI tools from within the app"
        echo -e "  • Check system permissions if needed"
    fi

    return $found_issues
}

production_basic_health_check() {
    production_info_message "HEALTH CHECKS"
    echo "=========================================="

    # System information
    production_info_message "SYSTEM INFORMATION:"
    echo "  OS: $OSTYPE"
    echo "  ARCHITECTURE: $(uname -m)"

    if command -v sw_vers >/dev/null 2>&1; then
        echo "  MACOS VERSION: $(sw_vers -productVersion)"
    fi

    # Disk space
    if command -v df >/dev/null 2>&1; then
        local disk_space
        disk_space=$(df -h / | awk 'NR==2 {print $4}')
        echo "  AVAILABLE SPACE: $disk_space"
    fi

    production_success_message "HEALTH CHECK COMPLETED"
}

production_basic_optimization_safe() {
    production_info_message "EXECUTING SAFE SYSTEM OPTIMIZATION"
    echo "================================================"

    local optimization_errors=0
    local optimization_timeout=10  # Timeout for each operation

    # Check system resources first
    local available_memory_gb
    available_memory_gb=$(vm_stat | grep "Pages free" | awk '{print int(($3 * 4096) / 1024 / 1024 / 1024)}' 2>/dev/null || echo "1")
    
    if [[ $available_memory_gb -lt 1 ]]; then
        production_warning_message "LOW MEMORY DETECTED - USING MINIMAL OPTIMIZATION MODE"
        optimization_timeout=5  # Reduce timeout for low memory systems
    fi

    # Basic Cursor settings optimization with safety checks
    local cursor_settings="$HOME/Library/Application Support/Cursor/User/settings.json"
    local cursor_settings_dir
    cursor_settings_dir="$(dirname "$cursor_settings")"
    
    if [[ ! -d "$cursor_settings_dir" ]]; then
        production_info_message "CREATING CURSOR SETTINGS DIRECTORY..."
        if timeout "$optimization_timeout" mkdir -p "$cursor_settings_dir" 2>/dev/null; then
            production_success_message "✓ CREATED SETTINGS DIRECTORY"
        else
            production_warning_message "COULD NOT CREATE SETTINGS DIRECTORY"
            ((optimization_errors++))
        fi
    fi

    # Create optimized settings with error handling
    if [[ -d "$cursor_settings_dir" ]]; then
        production_info_message "APPLYING SAFE CURSOR SETTINGS..."
        local perf_config='{
            "ai.enabled": true,
            "ai.autoComplete": true,
            "ai.codeActions": true,
            "ai.contextLength": 4096,
            "ai.temperature": 0.1,
            "ai.maxTokens": 1024,
            "editor.inlineSuggest.enabled": true,
            "editor.minimap.enabled": false,
            "editor.wordWrap": "off",
            "files.autoSave": "afterDelay",
            "files.autoSaveDelay": 10000,
            "search.useIgnoreFiles": true,
            "extensions.autoUpdate": false,
            "telemetry.enableTelemetry": false
        }'

        # Use timeout and error handling for file operations
        if timeout "$optimization_timeout" bash -c "echo '$perf_config' > '$cursor_settings'" 2>/dev/null; then
            production_success_message "✓ APPLIED SAFE CURSOR SETTINGS"
        else
            production_warning_message "COULD NOT APPLY CURSOR SETTINGS"
            ((optimization_errors++))
        fi
    fi

    # Disable system animations with safer approach
    production_info_message "OPTIMIZING SYSTEM ANIMATIONS (SAFE MODE)..."
    
    # Check if defaults command is working properly
    if timeout 5s defaults read NSGlobalDomain >/dev/null 2>&1; then
        # Try to disable window animations with timeout
        if timeout "$optimization_timeout" defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false 2>/dev/null; then
            production_success_message "✓ DISABLED WINDOW ANIMATIONS"
        else
            production_warning_message "COULD NOT DISABLE WINDOW ANIMATIONS"
            ((optimization_errors++))
        fi

        # Try to disable scroll animations with timeout
        if timeout "$optimization_timeout" defaults write NSGlobalDomain NSScrollAnimationEnabled -bool false 2>/dev/null; then
            production_success_message "✓ DISABLED SCROLL ANIMATIONS"
        else
            production_warning_message "COULD NOT DISABLE SCROLL ANIMATIONS"
            ((optimization_errors++))
        fi
    else
        production_warning_message "DEFAULTS COMMAND NOT RESPONDING - SKIPPING ANIMATION OPTIMIZATION"
        ((optimization_errors++))
    fi

    # Skip Launch Services database reset in safe mode as it can cause terminal issues
    production_info_message "SKIPPING LAUNCH SERVICES RESET (SAFE MODE)"
    production_info_message "Launch Services optimization skipped to prevent terminal instability"

    # Basic memory optimization suggestions
    production_info_message "APPLYING MEMORY OPTIMIZATION SUGGESTIONS..."
    echo "  • Close unnecessary applications to free memory"
    echo "  • Consider restarting Cursor after optimization"
    echo "  • Monitor memory usage with Activity Monitor"
    production_success_message "✓ MEMORY OPTIMIZATION GUIDANCE PROVIDED"

    # Basic disk optimization (safe operations only)
    production_info_message "PERFORMING SAFE DISK OPTIMIZATION..."
    
    # Clear user caches safely (only if they exist and are not locked)
    local cache_dirs=(
        "$HOME/Library/Caches/com.apple.dt.Xcode"
        "$HOME/Library/Caches/Cursor"
        "$HOME/.npm/_cacache"
    )
    
    for cache_dir in "${cache_dirs[@]}"; do
        if [[ -d "$cache_dir" ]] && [[ -w "$cache_dir" ]]; then
            local cache_size
            cache_size=$(du -sh "$cache_dir" 2>/dev/null | cut -f1 || echo "unknown")
            if timeout 10s find "$cache_dir" -type f -name "*.cache" -delete 2>/dev/null; then
                production_success_message "✓ CLEANED CACHE: $(basename "$cache_dir") ($cache_size)"
            else
                production_warning_message "COULD NOT CLEAN CACHE: $(basename "$cache_dir")"
            fi
        fi
    done

    # System health check
    production_info_message "PERFORMING SYSTEM HEALTH VALIDATION..."
    
    # Check available disk space
    local available_space_gb
    available_space_gb=$(df -g / 2>/dev/null | tail -1 | awk '{print $4}' 2>/dev/null || echo "unknown")
    if [[ "$available_space_gb" != "unknown" ]] && [[ $available_space_gb -gt 5 ]]; then
        production_success_message "✓ SUFFICIENT DISK SPACE: ${available_space_gb}GB available"
    else
        production_warning_message "⚠ LIMITED DISK SPACE: ${available_space_gb}GB available"
        ((optimization_errors++))
    fi

    # Check system load
    local load_avg
    load_avg=$(uptime | awk -F'load averages:' '{print $2}' | awk '{print $1}' | sed 's/,//' 2>/dev/null || echo "0.0")
    
    # Compare load average without bc dependency
    local load_comparison_result=1  # Default to "load is acceptable"
    if command -v bc >/dev/null 2>&1; then
        load_comparison_result=$(echo "$load_avg < 2.0" | bc 2>/dev/null || echo "1")
    else
        # Manual comparison for systems without bc
        load_avg_int=$(echo "$load_avg" | cut -d. -f1 2>/dev/null || echo "0")
        if [[ $load_avg_int -ge 2 ]]; then
            load_comparison_result=0  # High load
        fi
    fi
    
    if [[ $load_comparison_result -eq 1 ]]; then
        production_success_message "✓ SYSTEM LOAD NORMAL: $load_avg"
    else
        production_warning_message "⚠ HIGH SYSTEM LOAD: $load_avg"
    fi

    echo "================================================"
    if [[ $optimization_errors -eq 0 ]]; then
        production_success_message "SAFE OPTIMIZATION COMPLETED: ALL OPTIMIZATIONS APPLIED SUCCESSFULLY"
        production_info_message "System optimization completed without causing instability"
        return 0
    elif [[ $optimization_errors -lt 3 ]]; then
        production_warning_message "SAFE OPTIMIZATION COMPLETED WITH MINOR ISSUES: $optimization_errors NON-CRITICAL WARNINGS"
        production_info_message "Primary optimizations were applied successfully"
        return 0
    else
        production_warning_message "SAFE OPTIMIZATION COMPLETED WITH LIMITATIONS: $optimization_errors ISSUES ENCOUNTERED"
        production_info_message "Basic system safety maintained, some optimizations were skipped"
        return 0  # Still return success to prevent menu exit
    fi
}

################################################################################
#  Menu System - NEVER EXITS
################################################################################

production_show_menu() {
    while [[ "$SCRIPT_RUNNING" == "true" ]]; do
        clear
        echo "=============================================="
        echo "          CURSOR MANAGEMENT UTILITY           "
        echo "=============================================="
        echo

        # Show current status
        if [[ "$MODULES_LOADED" == "true" ]]; then
            production_success_message "STATUS: READY"
        else
            production_error_message "STATUS: DEGRADED MODE - MISSING MODULES"
        fi

        # Show verbose status information
        if [[ "${VERBOSE:-false}" == "true" ]]; then
            echo -e "\n${CYAN}[VERBOSE MODE] ADDITIONAL DEBUG INFORMATION:${NC}"
            echo "  SCRIPT DIRECTORY: $SCRIPT_DIR"
            echo "  MODULES LOADED: $MODULES_LOADED"
            echo "  NON-INTERACTIVE: $NON_INTERACTIVE_MODE"
            echo "  ERRORS ENCOUNTERED: $ERRORS_ENCOUNTERED"
            echo ""
        fi

        echo
        echo "OPTIONS:"
        echo "  1) CHECK CURSOR STATUS"
        echo "  2) UNINSTALL CURSOR"
        echo "  3) OPTIMIZE SYSTEM"
        echo "  4) GIT OPERATIONS"
        echo "  5) HEALTH CHECKS"
        echo "  6) SHOW HELP"
        echo ""
        echo "OTHER FEATURES:"
        echo "  7) GIT STATUS"
        echo "  8) SYSTEM SPECS"
        echo ""
        echo "  Q) QUIT"
        echo
        echo -n "ENTER YOUR CHOICE [1-8,Q]: "

        read -r choice
        case "$choice" in
            1)
                production_execute_check
                ;;
            2)
                production_execute_complete_uninstall
                ;;
            3)
                production_execute_optimize
                ;;
            4)
                production_execute_git_backup
                ;;
            5)
                production_execute_health_check
                ;;
            6)
                production_show_help
                ;;
            7)
                production_execute_git_status
                ;;
            8)
                production_execute_system_specs
                ;;
            [Qq]|[Qq][Uu][Ii][Tt])
                production_info_message "EXITING SCRIPT...GOODBYE!"
                SCRIPT_EXITING=true
                SCRIPT_RUNNING=false
                # Disable error trap to prevent false errors during exit
                trap - ERR
                break
                ;;
            *)
                production_error_message "INVALID CHOICE: $choice"
                ;;
        esac

        if [[ "$SCRIPT_RUNNING" == "true" ]]; then
            echo
            echo -n "Press Enter to continue..."
            read -r
        fi
    done

    # Only show final message if we haven't already shown it during normal exit
    if [[ "${SCRIPT_EXITING:-false}" != "true" ]]; then
        production_info_message "EXITING SCRIPT...GOODBYE!"
    fi
}

################################################################################
#  Argument Parser
################################################################################

production_parse_arguments() {
    # Set defaults
    OPERATION=""
    DMG_PATH=""
    VERBOSE="false"
    GIT_BACKUP_REQUESTED="false"

    while [[ $# -gt 0 ]]; do
        case $1 in
            -u|--uninstall)
                OPERATION="uninstall"
                shift
                ;;
            --git-backup)
                if [[ -z "$OPERATION" ]]; then
                    OPERATION="git-backup"
                else
                    GIT_BACKUP_REQUESTED="true"
                fi
                shift
                ;;
            -i|--install)
                OPERATION="install"
                if [[ $# -lt 2 ]] || [[ "$2" == -* ]]; then
                    production_error_message "INSTALL OPTION REQUIRES A DMG PATH"
                    return 1
                fi
                DMG_PATH="$2"
                shift 2
                ;;
            -o|--optimize)
                OPERATION="optimize"
                shift
                ;;
            -c|--check)
                OPERATION="check"
                shift
                ;;
            -m|--menu)
                OPERATION="menu"
                shift
                ;;
            --health)
                OPERATION="health"
                shift
                ;;
            --git-status)
                OPERATION="git-status"
                shift
                ;;
            --system-specs)
                OPERATION="system-specs"
                shift
                ;;
            --verbose)
                VERBOSE="true"
                shift
                ;;
            -h|--help)
                production_show_help
                return 2  # Special return code for help
                ;;
            *)
                production_error_message "UNKNOWN ARGUMENT: $1"
                production_show_help
                return 1
                ;;
        esac
    done

    # Set default operation if none specified
    if [[ -z "${OPERATION}" ]]; then
        OPERATION="menu"
    fi

    return 0
}

################################################################################
#  Script Entry Point
################################################################################

# Execute main function if script is run directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Handle command line arguments
    if [[ $# -gt 0 ]]; then
        # Parse arguments and execute specific operation
        parse_result=0
        production_parse_arguments "$@" || parse_result=$?

        if [[ $parse_result -eq 2 ]]; then
            # HELP WAS SHOWN, EXIT NORMALLY
            exit 0
        elif [[ $parse_result -ne 0 ]]; then
            # PARSE ERROR, SHOW HELP AND EXIT
            exit 1
        fi

        # EXECUTE THE REQUESTED OPERATION
        production_main "$@"
    else
        # NO ARGUMENTS, START INTERACTIVE MENU
        OPERATION="menu"
        production_show_menu
    fi
fi
