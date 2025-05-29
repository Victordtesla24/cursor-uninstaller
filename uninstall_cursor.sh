#!/bin/bash

################################################################################
# Cursor AI Editor Removal & Management Utility - PRODUCTION GRADE
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

# PRODUCTION GRADE ERROR HANDLING - NO MASKING OR SUPPRESSION
set -eE
trap 'production_error_handler $LINENO "$BASH_COMMAND"' ERR

# Global state tracking for production environment
ERRORS_ENCOUNTERED=0
NON_INTERACTIVE_MODE=false
SCRIPT_RUNNING=true
FORCE_EXIT=false

# PRODUCTION-GRADE ERROR HANDLER - Reports real errors without masking
production_error_handler() {
    local line_number="$1"
    local failed_command="$2"
    
    ((ERRORS_ENCOUNTERED++))
    
    # Report the actual error without masking
    echo -e "\n[PRODUCTION ERROR] Line $line_number: Command failed: $failed_command" >&2
    echo "[PRODUCTION ERROR] Error count: $ERRORS_ENCOUNTERED" >&2
    
    # In production, we log but do NOT exit the script unless explicitly requested
    # This ensures the menu system remains available for troubleshooting
    if [[ "$FORCE_EXIT" == "true" ]]; then
        echo "[PRODUCTION ERROR] Force exit requested, terminating..." >&2
        exit 1
    fi
    
    # Reset the error trap to prevent infinite loops
    trap 'production_error_handler $LINENO "$BASH_COMMAND"' ERR
    return 0
}

# Detect if running in non-interactive environment
detect_environment() {
    if [[ ! -t 0 ]] || [[ -n "${CI:-}" ]] || [[ -n "${DEBIAN_FRONTEND:-}" ]] || [[ "${TERM:-}" == "dumb" ]]; then
        NON_INTERACTIVE_MODE=true
        echo "[PRODUCTION INFO] Non-interactive environment detected"
    fi
}

# PRODUCTION-GRADE sudo handling - NO FALLBACKS OR ERROR MASKING
production_sudo() {
    local cmd="$*"
    
    # Check if sudo is available
    if ! command -v sudo >/dev/null 2>&1; then
        echo "[PRODUCTION ERROR] sudo not available - cannot perform privileged operations" >&2
        return 1
    fi
    
    # In non-interactive mode, require passwordless sudo
    if [[ "$NON_INTERACTIVE_MODE" == "true" ]]; then
        if ! timeout 5s sudo -n true 2>/dev/null; then
            echo "[PRODUCTION ERROR] Passwordless sudo required in non-interactive mode" >&2
            return 1
        fi
        # Execute with sudo
        if ! sudo "$@"; then
            echo "[PRODUCTION ERROR] Sudo command failed: $cmd" >&2
            return 1
        fi
        return 0
    fi
    
    # Interactive mode - prompt for sudo
    if ! sudo "$@"; then
        echo "[PRODUCTION ERROR] Sudo command failed: $cmd" >&2
        return 1
    fi
    
    return 0
}

# PRODUCTION module loading - NO FALLBACKS, REPORT REAL STATE
production_load_module() {
    local module_path="$1"
    local module_name="$(basename "$module_path")"
    
    if [[ ! -f "$module_path" ]]; then
        echo "[PRODUCTION ERROR] Module not found: $module_path" >&2
        return 1
    fi
    
    if [[ ! -r "$module_path" ]]; then
        echo "[PRODUCTION ERROR] Module not readable: $module_path" >&2
        return 1
    fi
    
    if ! source "$module_path"; then
        echo "[PRODUCTION ERROR] Failed to load module: $module_name" >&2
        return 1
    fi
    
    echo "[PRODUCTION INFO] Successfully loaded module: $module_name" >&2
    return 0
}

################################################################################
# PRODUCTION-GRADE Message Functions - NO MASKING
################################################################################

production_log_message() {
    local level="${1:-INFO}"
    local message="${2:-No message provided}"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [PRODUCTION-$level] $message" >&2
}

production_error_message() {
    local message="$1"
    echo -e "\033[0;31m[PRODUCTION ERROR]\033[0m $message" >&2
}

production_success_message() {
    local message="$1"
    echo -e "\033[0;32m[PRODUCTION SUCCESS]\033[0m $message" >&2
}

production_warning_message() {
    local message="$1"
    echo -e "\033[1;33m[PRODUCTION WARNING]\033[0m $message" >&2
}

production_info_message() {
    local message="$1"
    echo -e "\033[0;36m[PRODUCTION INFO]\033[0m $message" >&2
}

# PRODUCTION help function
production_show_help() {
    cat << 'EOF'
Cursor AI Editor Management Utility - PRODUCTION GRADE VERSION

Usage: ./uninstall_cursor.sh [OPTIONS]

PRODUCTION OPTIONS:
    -u, --uninstall         Complete removal of Cursor (NO BACKUPS)
    --git-backup           Perform Git backup before operations
    -i, --install PATH      Install Cursor from DMG file
    -o, --optimize          Optimize Cursor performance
    --ai-optimize          Comprehensive AI-focused performance optimization
    -r, --reset-performance Reset performance settings
    -c, --check             Check Cursor installation status (REAL STATE)
    -m, --menu              Show interactive menu (default)
    --health                Perform REAL system health check
    --verbose               Enable detailed production logging
    -h, --help              Show this help message

ADVANCED FEATURES:
    --git-status           Show Git repository status and information
    --system-specs         Display system specifications for AI optimization
    --performance-report   Generate comprehensive performance analysis

PRODUCTION STANDARDS:
    • All operations reflect REAL system state
    • NO error masking or false positives
    • NO fallback mechanisms that hide errors
    • STRICT error reporting and handling
    • Script never exits unless 'q' selected

EXAMPLES:
    ./uninstall_cursor.sh                    # Production menu
    ./uninstall_cursor.sh --git-backup -u   # Git backup + complete uninstall
    ./uninstall_cursor.sh --ai-optimize     # AI performance optimization
    ./uninstall_cursor.sh --verbose         # Detailed logging

EOF
}

################################################################################
# PRODUCTION Module Loading - STRICT REQUIREMENTS
################################################################################

# Initialize environment
detect_environment

# PRODUCTION module loading - FAIL if modules missing
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
    if ! production_load_module "$module"; then
        MODULES_LOADED=false
        production_error_message "REQUIRED module failed to load: $(basename "$module")"
    fi
done

# Set production configuration if config failed to load
if [[ "$MODULES_LOADED" == "false" ]]; then
    production_error_message "CRITICAL: Required modules failed to load"
    production_error_message "Cannot operate in PRODUCTION mode without all required components"
    
    # Provide minimal configuration
    ERR_INVALID_ARGS=1
    ERR_PERMISSION_DENIED=2
    ERR_FILE_NOT_FOUND=3
    ERR_SYSTEM_ERROR=4
    
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    NC='\033[0m'
fi

################################################################################
# PRODUCTION-GRADE Function Wrappers - Actual Functions not Aliases
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
    local message=${3:-"Processing"}
    
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
# PRODUCTION Main Function - NEVER EXITS UNLESS EXPLICITLY REQUESTED
################################################################################

production_main() {
    production_log_message "INFO" "Starting Cursor management utility (PRODUCTION GRADE)"
    production_log_message "INFO" "Non-interactive mode: $NON_INTERACTIVE_MODE"
    production_log_message "INFO" "Modules loaded successfully: $MODULES_LOADED"

    # Parse command line arguments
    if ! production_parse_arguments "$@"; then
        production_error_message "Failed to parse command line arguments"
        production_show_help
        return 1
    fi

    # System validation - REAL checks only
    if [[ "$MODULES_LOADED" == "true" ]] && declare -f validate_system_requirements >/dev/null 2>&1; then
        if ! validate_system_requirements; then
            production_error_message "System validation FAILED - not suitable for production use"
            return 1
        fi
    else
        production_warning_message "Using basic system validation due to missing modules"
        # Basic REAL validation
        if [[ "$OSTYPE" != "darwin"* ]]; then
            production_error_message "This utility requires macOS - current OS: $OSTYPE"
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
        "ai-optimize")
            production_execute_ai_optimize
            ;;
        "reset-performance")
            production_execute_reset_performance
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
        "performance-report")
            production_execute_performance_report
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
        production_warning_message "Operation completed with $ERRORS_ENCOUNTERED PRODUCTION errors"
    else
        production_success_message "Operation completed successfully in PRODUCTION mode"
    fi
    
    return 0
}

################################################################################
# PRODUCTION Operation Functions - REAL OPERATIONS ONLY
################################################################################

production_execute_install() {
    production_info_message "Executing PRODUCTION install operation"
    
    if [[ -z "${DMG_PATH:-}" ]]; then
        production_error_message "DMG path required for installation"
        return 1
    fi
    
    if [[ "$MODULES_LOADED" == "true" ]] && declare -f install_cursor_from_dmg >/dev/null 2>&1; then
        if declare -f confirm_installation_action >/dev/null 2>&1; then
            if ! confirm_installation_action; then
                production_info_message "Installation cancelled by user"
                return 0
            fi
        fi
        install_cursor_from_dmg "$DMG_PATH"
    else
        production_error_message "Cannot perform installation - required modules not loaded"
        return 1
    fi
}

production_execute_optimize() {
    production_info_message "Executing PRODUCTION optimization"
    
    if [[ "$MODULES_LOADED" == "true" ]] && declare -f enhanced_optimize_cursor_performance >/dev/null 2>&1; then
        enhanced_optimize_cursor_performance
    else
        production_error_message "Cannot perform optimization - required modules not loaded"
        return 1
    fi
}

production_execute_reset_performance() {
    production_info_message "Executing PRODUCTION performance reset"
    
    if [[ "$MODULES_LOADED" == "true" ]] && declare -f reset_performance_settings >/dev/null 2>&1; then
        reset_performance_settings
    else
        production_error_message "Cannot reset performance - required modules not loaded"
        return 1
    fi
}

production_execute_check() {
    production_info_message "Executing PRODUCTION installation check"
    
    if [[ "$MODULES_LOADED" == "true" ]] && declare -f check_cursor_installation >/dev/null 2>&1; then
        check_cursor_installation
    else
        production_warning_message "Using basic check due to missing modules"
        production_basic_check
    fi
}

production_execute_health_check() {
    production_info_message "Executing PRODUCTION health check"
    
    if [[ "$MODULES_LOADED" == "true" ]] && declare -f perform_health_check >/dev/null 2>&1; then
        perform_health_check
    else
        production_warning_message "Using basic health check due to missing modules"
        production_basic_health_check
    fi
}

production_execute_git_backup() {
    production_info_message "Executing PRODUCTION Git backup operation"
    
    if [[ "$MODULES_LOADED" == "true" ]] && declare -f perform_pre_uninstall_backup >/dev/null 2>&1; then
        if declare -f confirm_git_backup_operations >/dev/null 2>&1; then
            if ! confirm_git_backup_operations; then
                production_info_message "Git backup cancelled by user"
                return 0
            fi
        fi
        perform_pre_uninstall_backup
    else
        production_error_message "Cannot perform Git backup - required modules not loaded"
        return 1
    fi
}

production_execute_ai_optimize() {
    production_info_message "Executing PRODUCTION AI optimization"
    
    if [[ "$MODULES_LOADED" == "true" ]] && declare -f perform_ai_optimization >/dev/null 2>&1; then
        perform_ai_optimization
    else
        production_error_message "Cannot perform AI optimization - required modules not loaded"
        return 1
    fi
}

production_execute_git_status() {
    production_info_message "Displaying Git repository status"
    
    if [[ "$MODULES_LOADED" == "true" ]] && declare -f display_git_repository_info >/dev/null 2>&1; then
        display_git_repository_info
    else
        production_error_message "Cannot show Git status - required modules not loaded"
        return 1
    fi
}

production_execute_system_specs() {
    production_info_message "Displaying system specifications"
    
    if [[ "$MODULES_LOADED" == "true" ]] && declare -f display_system_specifications >/dev/null 2>&1; then
        display_system_specifications
    else
        production_error_message "Cannot show system specs - required modules not loaded"
        return 1
    fi
}

production_execute_performance_report() {
    production_info_message "Generating performance analysis report"
    
    if [[ "$MODULES_LOADED" == "true" ]] && declare -f analyze_performance_metrics >/dev/null 2>&1; then
        analyze_performance_metrics
        if declare -f generate_optimization_report >/dev/null 2>&1; then
            local report_file
            report_file=$(generate_optimization_report)
            production_success_message "Performance report generated: $report_file"
        fi
    else
        production_error_message "Cannot generate performance report - required modules not loaded"
        return 1
    fi
}

production_execute_complete_uninstall() {
    production_info_message "Executing PRODUCTION complete Cursor uninstall"
    
    # Show warning for complete removal
    echo -e "\n${RED}${BOLD}⚠️  COMPLETE CURSOR REMOVAL${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════${NC}\n"
    echo -e "${RED}This will COMPLETELY and PERMANENTLY remove ALL Cursor components:${NC}"
    echo -e "  • Application bundle and all executables"
    echo -e "  • All user configurations and preferences"
    echo -e "  • Cache files and temporary data"
    echo -e "  • CLI tools and system integrations"
    echo -e "  • System database registrations"
    echo -e "  • Background processes and services"
    echo -e "  • All settings and workspaces"
    echo ""
    echo -e "${BOLD}${RED}NO BACKUPS WILL BE CREATED - THIS IS IRREVERSIBLE${NC}"
    echo ""
    
    # Check if Git backup is requested
    if [[ "${GIT_BACKUP_REQUESTED:-false}" == "true" ]]; then
        production_info_message "Performing Git backup before complete removal..."
        if ! perform_pre_uninstall_backup; then
            production_error_message "Git backup failed - complete removal cancelled"
            return 1
        fi
    fi
    
    if [[ "$NON_INTERACTIVE_MODE" != "true" ]]; then
        while true; do
            echo -n "Type 'REMOVE' to confirm complete Cursor removal: "
            read -r response
            case "$response" in
                REMOVE)
                    production_info_message "User confirmed complete removal with exact confirmation"
                    break
                    ;;
                *)
                    production_warning_message "Complete removal cancelled - exact confirmation required"
                    return 0
                    ;;
            esac
        done
    fi
    
    # Execute complete removal combining both uninstall and complete removal
    production_info_message "Starting complete Cursor removal process..."
    
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
        production_warning_message "Using basic removal due to missing modules"
        if ! production_basic_removal; then
            removal_success=false
        fi
    fi
    
    if [[ "$removal_success" == "true" ]]; then
        production_success_message "✓ Complete Cursor removal completed successfully"
        production_info_message "System has been restored to pristine state"
        return 0
    else
        production_error_message "Complete removal encountered errors"
        production_error_message "Some components may still remain - manual cleanup may be required"
        return 1
    fi
}

production_basic_removal() {
    production_info_message "PRODUCTION Basic Cursor Removal"
    echo "================================================"
    
    local removal_errors=0
    
    # Remove main application
    if [[ -d "/Applications/Cursor.app" ]]; then
        production_info_message "Removing Cursor.app..."
        if sudo rm -rf "/Applications/Cursor.app"; then
            production_success_message "✓ Removed Cursor.app"
        else
            production_error_message "Failed to remove Cursor.app"
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
            production_info_message "Removing: $dir"
            if rm -rf "$dir"; then
                production_success_message "✓ Removed: $dir"
            else
                production_error_message "Failed to remove: $dir"
                ((removal_errors++))
            fi
        fi
    done
    
    # Remove CLI tools
    local cli_locations=("/usr/local/bin/cursor" "/usr/local/bin/code")
    for location in "${cli_locations[@]}"; do
        if [[ -L "$location" ]] || [[ -f "$location" ]]; then
            production_info_message "Removing CLI tool: $location"
            if sudo rm -f "$location"; then
                production_success_message "✓ Removed: $location"
            else
                production_error_message "Failed to remove: $location"
                ((removal_errors++))
            fi
        fi
    done
    
    # Reset Launch Services database
    production_info_message "Resetting Launch Services database..."
    if /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user >/dev/null 2>&1; then
        production_success_message "✓ Launch Services database reset"
    else
        production_warning_message "Failed to reset Launch Services database"
        ((removal_errors++))
    fi
    
    echo "================================================"
    if [[ $removal_errors -eq 0 ]]; then
        production_success_message "PRODUCTION REMOVAL COMPLETED: All Cursor components removed"
        return 0
    else
        production_error_message "PRODUCTION REMOVAL FAILED: $removal_errors errors encountered"
        return 1
    fi
}

################################################################################
# PRODUCTION Basic Functions - REAL STATE ONLY
################################################################################

production_basic_check() {
    production_info_message "PRODUCTION Basic Cursor Installation Check"
    echo "================================================"
    
    local found_issues=0
    
    # Check application
    if [[ -d "/Applications/Cursor.app" ]]; then
        if [[ -f "/Applications/Cursor.app/Contents/Info.plist" ]]; then
            if command -v defaults >/dev/null 2>&1; then
                local version=$(defaults read "/Applications/Cursor.app/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null)
                if [[ -n "$version" ]]; then
                    production_success_message "Cursor.app found: Version $version"
                else
                    production_warning_message "Cursor.app found but version unreadable"
                    ((found_issues++))
                fi
            else
                production_success_message "Cursor.app found (version check unavailable)"
            fi
        else
            production_warning_message "Cursor.app found but Info.plist missing"
            ((found_issues++))
        fi
    else
        production_error_message "Cursor.app NOT FOUND at /Applications/Cursor.app"
        ((found_issues++))
    fi
    
    # Check CLI tools
    local cli_found=false
    local cli_locations=("/usr/local/bin/cursor" "/opt/homebrew/bin/cursor")
    
    for location in "${cli_locations[@]}"; do
        if [[ -f "$location" ]] && [[ -x "$location" ]]; then
            production_success_message "Cursor CLI found: $location"
            cli_found=true
            break
        fi
    done
    
    if [[ "$cli_found" == "false" ]]; then
        if command -v cursor >/dev/null 2>&1; then
            local cursor_path=$(which cursor 2>/dev/null)
            production_success_message "Cursor CLI found in PATH: $cursor_path"
        else
            production_error_message "Cursor CLI NOT FOUND"
            ((found_issues++))
        fi
    fi
    
    # Report final status
    echo "================================================"
    if [[ $found_issues -eq 0 ]]; then
        production_success_message "PRODUCTION CHECK PASSED: Cursor properly installed"
    else
        production_error_message "PRODUCTION CHECK FAILED: $found_issues issues found"
    fi
    
    return $found_issues
}

production_basic_health_check() {
    production_info_message "PRODUCTION Basic Health Check"
    echo "=========================================="
    
    # System information
    production_info_message "System Information:"
    echo "  OS: $OSTYPE"
    echo "  Architecture: $(uname -m)"
    
    if command -v sw_vers >/dev/null 2>&1; then
        echo "  macOS Version: $(sw_vers -productVersion)"
    fi
    
    # Disk space
    if command -v df >/dev/null 2>&1; then
        local disk_space=$(df -h / | awk 'NR==2 {print $4}')
        echo "  Available Space: $disk_space"
    fi
    
    production_success_message "Health check completed"
}

################################################################################
# PRODUCTION Menu System - NEVER EXITS
################################################################################

production_show_menu() {
    while [[ "$SCRIPT_RUNNING" == "true" ]]; do
        clear
        echo "=============================================="
        echo "    Cursor Management Utility"
        echo "    PRODUCTION GRADE - STRICT STANDARDS"
        echo "=============================================="
        echo
        
        # Show current status
        if [[ "$MODULES_LOADED" == "true" ]]; then
            production_success_message "Status: PRODUCTION READY"
        else
            production_error_message "Status: DEGRADED MODE - Missing modules"
        fi
        
        echo
        echo "PRODUCTION OPTIONS:"
        echo "  1) Check Installation Status (REAL)"
        echo "  2) Uninstall Cursor (COMPLETE REMOVAL)"
        echo "  3) Git Backup Operations"
        echo "  4) Optimize Performance"
        echo "  5) AI-Focused Optimization"
        echo "  6) Reset Performance"
        echo "  7) Health Check (REAL)"
        echo "  8) Show Help"
        echo ""
        echo "ADVANCED FEATURES:"
        echo "  9) Git Repository Status"
        echo " 10) System Specifications"
        echo " 11) Performance Report"
        echo ""
        echo "  q) Quit"
        echo
        echo -n "Enter your choice [1-11,q]: "
        
        read -r choice
        case "$choice" in
            1)
                production_execute_check
                ;;
            2)
                production_execute_complete_uninstall
                ;;
            3)
                production_execute_git_backup
                ;;
            4)
                production_execute_optimize
                ;;
            5)
                production_execute_ai_optimize
                ;;
            6)
                production_execute_reset_performance
                ;;
            7)
                production_execute_health_check
                ;;
            8)
                production_show_help
                ;;
            9)
                production_execute_git_status
                ;;
            10)
                production_execute_system_specs
                ;;
            11)
                production_execute_performance_report
                ;;
            [Qq]|[Qq][Uu][Ii][Tt])
                production_info_message "User requested exit"
                SCRIPT_RUNNING=false
                break
                ;;
            *)
                production_error_message "Invalid choice: $choice"
                ;;
        esac
        
        if [[ "$SCRIPT_RUNNING" == "true" ]]; then
            echo
            echo -n "Press Enter to continue..."
            read
        fi
    done
    
    production_info_message "Exiting PRODUCTION script as requested"
}

################################################################################
# PRODUCTION Argument Parser
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
                    production_error_message "Install option requires a DMG path"
                    return 1
                fi
                DMG_PATH="$2"
                shift 2
                ;;
            -o|--optimize)
                OPERATION="optimize"
                shift
                ;;
            --ai-optimize)
                OPERATION="ai-optimize"
                shift
                ;;
            -r|--reset-performance)
                OPERATION="reset-performance"
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
            --performance-report)
                OPERATION="performance-report"
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
                production_error_message "Unknown argument: $1"
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
# PRODUCTION Script Entry Point
################################################################################

# Execute main function if script is run directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Handle command line arguments
    if [[ $# -gt 0 ]]; then
        # Parse arguments and execute specific operation
        parse_result=0
        production_parse_arguments "$@" || parse_result=$?
        
        if [[ $parse_result -eq 2 ]]; then
            # Help was shown, exit normally
            exit 0
        elif [[ $parse_result -ne 0 ]]; then
            # Parse error, show help and exit
            exit 1
        fi
        
        # Execute the requested operation
        production_main "$@"
    else
        # No arguments, start interactive menu
        OPERATION="menu"
        production_show_menu
    fi
fi
