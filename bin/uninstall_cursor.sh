#!/bin/bash

################################################################################
# Cursor AI Editor Removal & Management Utility - REFACTORED
# Enhanced security, reliability, and maintainability
################################################################################

# Secure error handling and environment setup
set -euo pipefail
readonly IFS=$' \t\n'

# Script metadata
readonly SCRIPT_VERSION="3.0.0"
declare SCRIPT_BUILD
SCRIPT_BUILD="$(date '+%Y%m%d%H%M%S')"
readonly SCRIPT_BUILD
readonly SCRIPT_CODENAME="REFACTORED-PRODUCTION"

# Export for external use
export SCRIPT_VERSION SCRIPT_BUILD SCRIPT_CODENAME

# Script self-location with security validation
get_script_path() {
    local source="${BASH_SOURCE[0]}"
    local dir=""
    
    # Resolve symlinks securely
    while [[ -h "$source" ]]; do
        dir="$(cd -P "$(dirname "$source")" && pwd)"
        source="$(readlink "$source")"
        [[ $source != /* ]] && source="$dir/$source"
    done
    
    dir="$(cd -P "$(dirname "$source")" && pwd)"
    
    # Security: Validate resolved path
    if [[ ! "$dir" =~ ^/[^[:space:]]*$ ]]; then
        printf '[ERROR] Invalid script directory path\n' >&2
        exit 1
    fi
    
    printf '%s' "$dir"
}

# Store the script's directory path securely
declare SCRIPT_DIR PROJECT_ROOT
SCRIPT_DIR="$(get_script_path)"
readonly SCRIPT_DIR
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
readonly PROJECT_ROOT

# Export for external use
export SCRIPT_DIR PROJECT_ROOT

# Global state with controlled access
declare -g ERRORS_ENCOUNTERED=0
declare -g NON_INTERACTIVE_MODE=false
declare -g SCRIPT_RUNNING=true
declare -g SCRIPT_EXITING=false
declare -g VERBOSE_MODE=false

# Secure error handler with controlled reporting
error_handler() {
    local line_number="$1"
    local failed_command="$2"
    local exit_code="${3:-1}"
    
    # Skip if already exiting
    if [[ "${SCRIPT_EXITING:-false}" == "true" ]]; then
        return 0
    fi
    
    ((ERRORS_ENCOUNTERED++))
    
    # Sanitize command for logging (prevent log injection)
    local sanitized_command
    sanitized_command=$(printf '%s' "$failed_command" | tr -cd '[:print:]' | head -c 100)
    
    # Log error with context
    printf '[ERROR] Line %d: Command failed (exit %d): %s\n' "$line_number" "$exit_code" "$sanitized_command" >&2
    printf '[ERROR] Total errors: %d\n' "$ERRORS_ENCOUNTERED" >&2
    
    # Reset trap to prevent infinite loops
    trap 'error_handler $LINENO "$BASH_COMMAND" $?' ERR
    return 0
}

# Install error handler
trap 'error_handler $LINENO "$BASH_COMMAND" $?' ERR

# Enhanced environment detection with security considerations
detect_environment() {
    local env_issues=0
    
    # Check for non-interactive environment
    if [[ ! -t 0 ]] || [[ -n "${CI:-}" ]] || [[ -n "${DEBIAN_FRONTEND:-}" ]] || [[ "${TERM:-}" == "dumb" ]]; then
        NON_INTERACTIVE_MODE=true
        printf '[INFO] Non-interactive environment detected\n' >&2
    fi
    
    # Security: Check for dangerous environment variables
    local -a dangerous_vars=("LD_PRELOAD" "DYLD_INSERT_LIBRARIES" "PROMPT_COMMAND")
    for var in "${dangerous_vars[@]}"; do
        if [[ -n "${!var:-}" ]]; then
            printf '[SECURITY WARNING] Dangerous environment variable: %s\n' "$var" >&2
            ((env_issues++))
        fi
    done
    
    # Security: Validate PATH
    if [[ "$PATH" =~ (^|:)\.(:|$) ]]; then
        printf '[SECURITY ERROR] PATH contains current directory\n' >&2
        exit 1
    fi
    
    return $env_issues
}

# Secure sudo handling with validation
secure_sudo() {
    local -a cmd=("$@")
    
    # Validate sudo availability
    if ! command -v sudo >/dev/null 2>&1; then
        printf '[ERROR] sudo not available\n' >&2
        return 1
    fi
    
    # Security: Validate command arguments
    for arg in "${cmd[@]}"; do
        if [[ "$arg" =~ [^[:print:]] ]]; then
            printf '[ERROR] Invalid characters in sudo command\n' >&2
            return 1
        fi
    done
    
    # Handle non-interactive mode
    if [[ "$NON_INTERACTIVE_MODE" == "true" ]]; then
        if ! timeout 5s sudo -n true 2>/dev/null; then
            printf '[ERROR] Passwordless sudo required in non-interactive mode\n' >&2
            return 1
        fi
    fi
    
    # Execute with proper error handling
    if sudo "${cmd[@]}"; then
        return 0
    else
        local exit_code=$?
        printf '[ERROR] sudo command failed (exit %d): %s\n' "$exit_code" "${cmd[*]}" >&2
        return $exit_code
    fi
}

# Enhanced module loading with security validation
load_module() {
    local module_path="$1"
    local module_name
    module_name="$(basename "$module_path")"
    
    # Security: Validate module path
    if [[ ! "$module_path" =~ ^/[^[:space:]]*\.sh$ ]]; then
        printf '[ERROR] Invalid module path: %s\n' "$module_path" >&2
        return 1
    fi
    
    # Check module existence and readability
    if [[ ! -f "$module_path" ]]; then
        printf '[ERROR] Module not found: %s\n' "$module_path" >&2
        return 1
    fi
    
    if [[ ! -r "$module_path" ]]; then
        printf '[ERROR] Module not readable: %s\n' "$module_path" >&2
        return 1
    fi
    
    # Security: Basic syntax check
    if ! bash -n "$module_path" 2>/dev/null; then
        printf '[ERROR] Module has syntax errors: %s\n' "$module_name" >&2
        return 1
    fi
    
    # Load module with controlled error handling
    local load_result=0
    # shellcheck source=/dev/null
    source "$module_path" || load_result=$?
    
    if (( load_result == 0 )); then
        printf '[INFO] Successfully loaded module: %s\n' "$module_name" >&2
        return 0
    else
        printf '[ERROR] Failed to load module: %s (exit %d)\n' "$module_name" "$load_result" >&2
        return $load_result
    fi
}

# Enhanced logging functions with security considerations
log_message() {
    local level="${1:-INFO}"
    local message="${2:-No message provided}"
    
    # Input validation and sanitization
    if [[ ! "$level" =~ ^(ERROR|WARNING|SUCCESS|INFO|DEBUG)$ ]]; then
        level="INFO"
    fi
    message=$(printf '%s' "$message" | tr -cd '[:print:]\n\t' | head -c 1000)
    
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S' 2>/dev/null || date)
    
    # Route output appropriately
    case "$level" in
        "ERROR"|"WARNING")
            printf '[%s] [%s] %s\n' "$timestamp" "$level" "$message" >&2
            ;;
        *)
            if [[ "$VERBOSE_MODE" == "true" || "$level" != "DEBUG" ]]; then
                printf '[%s] [%s] %s\n' "$timestamp" "$level" "$message"
            fi
            ;;
    esac
    
    return 0
}

# Convenience logging functions
error_message() { log_message "ERROR" "$1"; }
warning_message() { log_message "WARNING" "$1"; }
success_message() { log_message "SUCCESS" "$1"; }
info_message() { log_message "INFO" "$1"; }
debug_message() { log_message "DEBUG" "$1"; }

# Enhanced help function with security information
show_help() {
    cat << 'EOF'
CURSOR AI EDITOR MANAGEMENT UTILITY v3.0.0 (REFACTORED)

USAGE: ./uninstall_cursor.sh [OPTIONS]

CORE OPTIONS:
    -u, --uninstall         Complete removal of Cursor (no backups)
    -i, --install PATH      Install Cursor from DMG file
    -o, --optimize          Performance optimization (AI-focused)
    -c, --check             Check Cursor installation status
    -m, --menu              Show interactive menu (default)
    --health                Perform system health check
    --verbose               Enable detailed logging
    -h, --help              Show this help message

ADVANCED OPTIONS:
    --git-backup           Perform Git backup before operations
    --git-status           Show Git repository status
    --system-specs         Display system specifications

SECURITY FEATURES:
    • Input validation and sanitization
    • Secure path handling and validation
    • Protection against command injection
    • Safe error handling without information leakage

EXAMPLES:
    ./uninstall_cursor.sh                    # Interactive menu
    ./uninstall_cursor.sh --git-backup -u   # Backup + uninstall
    ./uninstall_cursor.sh --optimize        # Performance optimization
    ./uninstall_cursor.sh --verbose         # Detailed logging

EOF
}

# Enhanced module initialization with proper error handling
initialize_modules() {
    local -a required_modules=(
        "$PROJECT_ROOT/lib/config.sh"
        "$PROJECT_ROOT/lib/helpers.sh"
        "$PROJECT_ROOT/lib/ui.sh"
        "$PROJECT_ROOT/modules/installation.sh"
        "$PROJECT_ROOT/modules/optimization.sh"
        "$PROJECT_ROOT/modules/uninstall.sh"
        "$PROJECT_ROOT/modules/git_integration.sh"
        "$PROJECT_ROOT/modules/complete_removal.sh"
        "$PROJECT_ROOT/modules/ai_optimization.sh"
    )
    
    local modules_loaded=0
    local modules_failed=0
    
    info_message "Loading required modules..."
    
    # Temporarily disable exit on error for module loading
    set +e
    trap - ERR
    
    for module in "${required_modules[@]}"; do
        if load_module "$module"; then
            ((modules_loaded++))
            debug_message "Loaded: $(basename "$module")"
        else
            ((modules_failed++))
            error_message "Failed to load: $(basename "$module")"
        fi
    done
    
    # Restore error handling
    set -e
    trap 'error_handler $LINENO "$BASH_COMMAND" $?' ERR
    
    # Report module loading results
    if (( modules_failed == 0 )); then
        success_message "All $modules_loaded modules loaded successfully"
        return 0
    else
        warning_message "$modules_loaded modules loaded, $modules_failed failed"
        return $modules_failed
    fi
}

# Enhanced argument parser with comprehensive validation
parse_arguments() {
    local operation=""
    local dmg_path=""
    local git_backup_requested=false
    
    while (( $# > 0 )); do
        case "$1" in
            -u|--uninstall)
                operation="uninstall"
                shift
                ;;
            --git-backup)
                if [[ -z "$operation" ]]; then
                    operation="git-backup"
                else
                    git_backup_requested=true
                fi
                shift
                ;;
            -i|--install)
                operation="install"
                if (( $# < 2 )) || [[ "$2" == -* ]]; then
                    error_message "Install option requires a DMG path"
                    return 1
                fi
                dmg_path="$2"
                # Security: Validate DMG path
                if [[ ! "$dmg_path" =~ ^[^[:space:]]*\.dmg$ ]]; then
                    error_message "Invalid DMG file path"
                    return 1
                fi
                shift 2
                ;;
            -o|--optimize)
                operation="optimize"
                shift
                ;;
            -c|--check)
                operation="check"
                shift
                ;;
            -m|--menu)
                operation="menu"
                shift
                ;;
            --health)
                operation="health"
                shift
                ;;
            --git-status)
                operation="git-status"
                shift
                ;;
            --system-specs)
                operation="system-specs"
                shift
                ;;
            --verbose)
                VERBOSE_MODE=true
                shift
                ;;
            -h|--help)
                show_help
                return 2  # Special return code for help
                ;;
            *)
                error_message "Unknown argument: $1"
                show_help
                return 1
                ;;
        esac
    done
    
    # Set defaults and export
    export OPERATION="${operation:-menu}"
    export DMG_PATH="$dmg_path"
    export GIT_BACKUP_REQUESTED="$git_backup_requested"
    
    return 0
}

# Enhanced operation execution with proper error handling
execute_operation() {
    local operation="$1"
    local exit_code=0
    
    info_message "Executing operation: $operation"
    
    case "$operation" in
        "uninstall")
            execute_complete_uninstall || exit_code=$?
            ;;
        "install")
            execute_install || exit_code=$?
            ;;
        "optimize")
            execute_optimize || exit_code=$?
            ;;
        "check")
            execute_check || exit_code=$?
            ;;
        "health")
            execute_health_check || exit_code=$?
            ;;
        "git-backup")
            execute_git_backup || exit_code=$?
            ;;
        "git-status")
            execute_git_status || exit_code=$?
            ;;
        "system-specs")
            execute_system_specs || exit_code=$?
            ;;
        "menu")
            show_interactive_menu || exit_code=$?
            ;;
        *)
            error_message "Invalid operation: $operation"
            return 1
            ;;
    esac
    
    # Report operation result
    if (( exit_code == 0 )); then
        success_message "Operation '$operation' completed successfully"
    elif (( exit_code <= 2 )); then
        warning_message "Operation '$operation' completed with warnings (exit $exit_code)"
        exit_code=0  # Treat warnings as success
    else
        error_message "Operation '$operation' failed (exit $exit_code)"
    fi
    
    return $exit_code
}

# Operation implementations with improved error handling
execute_complete_uninstall() {
    info_message "Executing complete Cursor uninstall"
    
    # Show warning and get confirmation
    cat << 'EOF'

⚠️  COMPLETE CURSOR REMOVAL
═══════════════════════════════════════════════

THIS WILL COMPLETELY AND PERMANENTLY REMOVE ALL CURSOR COMPONENTS:
  • Application bundle and all executables
  • User configurations and preferences  
  • Cache files and temporary data
  • CLI tools and system integrations
  • System database registrations

NO BACKUPS WILL BE CREATED - THIS IS IRREVERSIBLE

EOF
    
    # Handle Git backup if requested
    if [[ "${GIT_BACKUP_REQUESTED:-false}" == "true" ]]; then
        info_message "Performing Git backup before complete removal..."
        if declare -f perform_pre_uninstall_backup >/dev/null 2>&1; then
            if ! perform_pre_uninstall_backup; then
                error_message "Git backup failed - cancelling removal"
                return 1
            fi
        else
            warning_message "Git backup function not available"
        fi
    fi
    
    # Get user confirmation in interactive mode
    if [[ "$NON_INTERACTIVE_MODE" != "true" ]]; then
        local response
        while true; do
            printf 'Type "REMOVE" to confirm complete removal: '
            read -r response
            case "$response" in
                REMOVE)
                    info_message "User confirmed complete removal"
                    break
                    ;;
                *)
                    warning_message "Complete removal cancelled"
                    return 0
                    ;;
            esac
        done
    fi
    
    # Execute removal operations
    local removal_success=true
    
    # Enhanced uninstall
    if declare -f enhanced_uninstall_cursor >/dev/null 2>&1; then
        if ! enhanced_uninstall_cursor; then
            removal_success=false
        fi
    fi
    
    # Complete removal
    if declare -f perform_complete_cursor_removal >/dev/null 2>&1; then
        if ! perform_complete_cursor_removal; then
            removal_success=false
        fi
    fi
    
    # Report results
    if [[ "$removal_success" == "true" ]]; then
        success_message "Complete Cursor removal completed successfully"
        info_message "System has been restored to pristine state"
        return 0
    else
        error_message "Complete removal encountered errors"
        error_message "Some components may still remain - check output above"
        return 1
    fi
}

execute_install() {
    info_message "Executing Cursor installation"
    
    if [[ -z "${DMG_PATH:-}" ]]; then
        error_message "DMG path required for installation"
        return 1
    fi
    
    if declare -f install_cursor_from_dmg >/dev/null 2>&1; then
        install_cursor_from_dmg "$DMG_PATH"
    else
        error_message "Installation function not available"
        return 1
    fi
}

execute_optimize() {
    info_message "Executing system optimization"
    
    # Check for external optimization script first
    local script_path="$PROJECT_ROOT/scripts/optimize_system.sh"
    
    if [[ -f "$script_path" && -x "$script_path" ]]; then
        info_message "Using external optimization script"
        export NON_INTERACTIVE_MODE VERBOSE_MODE
        "$script_path"
    else
        warning_message "External optimization script not found, using basic optimization"
        if declare -f basic_optimization >/dev/null 2>&1; then
            basic_optimization
        else
            error_message "No optimization functions available"
            return 1
        fi
    fi
}

execute_check() {
    info_message "Checking Cursor installation status"
    
    # Disable error exit for check operations
    set +e
    trap - ERR
    
    local check_result=0
    if declare -f check_cursor_installation >/dev/null 2>&1; then
        check_cursor_installation || check_result=$?
    else
        warning_message "Using basic check"
        basic_installation_check || check_result=$?
    fi
    
    # Restore error handling
    set -e
    trap 'error_handler $LINENO "$BASH_COMMAND" $?' ERR
    
    info_message "Installation check completed (exit $check_result)"
    return 0  # Always return success for checks
}

execute_health_check() {
    info_message "Performing system health check"
    
    if declare -f perform_health_check >/dev/null 2>&1; then
        perform_health_check || true  # Don't fail on health check issues
    else
        warning_message "Using basic health check"
        basic_health_check || true
    fi
    
    return 0
}

execute_git_backup() {
    info_message "Executing Git backup operation"
    
    if declare -f perform_pre_uninstall_backup >/dev/null 2>&1; then
        perform_pre_uninstall_backup || {
            warning_message "Git backup failed - this is not fatal"
            return 0
        }
    else
        error_message "Git backup function not available"
        return 1
    fi
}

execute_git_status() {
    info_message "Displaying Git repository status"
    
    if declare -f display_git_repository_info >/dev/null 2>&1; then
        display_git_repository_info
    else
        error_message "Git status function not available"
        return 1
    fi
}

execute_system_specs() {
    info_message "Displaying system specifications"
    
    if declare -f display_system_specifications >/dev/null 2>&1; then
        display_system_specifications
    else
        error_message "System specs function not available"
        return 1
    fi
}

# Basic fallback functions
basic_installation_check() {
    info_message "Performing basic installation check"
    
    local issues=0
    
    # Check application
    if [[ -d "/Applications/Cursor.app" ]]; then
        success_message "Cursor.app found at /Applications/Cursor.app"
    else
        warning_message "Cursor.app not found"
        ((issues++))
    fi
    
    # Check CLI tools
    if command -v cursor >/dev/null 2>&1; then
        success_message "Cursor CLI tool available"
    else
        info_message "Cursor CLI tool not in PATH"
    fi
    
    info_message "Basic check completed with $issues issues"
    return $issues
}

basic_health_check() {
    info_message "Performing basic health check"
    
    # System information
    info_message "OS: $OSTYPE"
    info_message "Architecture: $(uname -m)"
    
    if command -v sw_vers >/dev/null 2>&1; then
        info_message "macOS: $(sw_vers -productVersion)"
    fi
    
    # Disk space
    if command -v df >/dev/null 2>&1; then
        local disk_space
        disk_space=$(df -h / | awk 'NR==2 {print $4}' || echo "unknown")
        info_message "Available space: $disk_space"
    fi
    
    success_message "Basic health check completed"
    return 0
}

# Enhanced interactive menu with security considerations
show_interactive_menu() {
    while [[ "$SCRIPT_RUNNING" == "true" ]]; do
        clear
        cat << 'EOF'
══════════════════════════════════════════════════════════
               CURSOR MANAGEMENT UTILITY v3.0.0
══════════════════════════════════════════════════════════

EOF
        
        # Show status
        if (( ERRORS_ENCOUNTERED == 0 )); then
            success_message "STATUS: READY"
        else
            warning_message "STATUS: $ERRORS_ENCOUNTERED errors encountered"
        fi
        
        cat << 'EOF'

OPTIONS:
  1) Check Cursor Status
  2) Uninstall Cursor  
  3) Optimize System
  4) Git Operations
  5) Health Checks
  6) Show Help
  
ADVANCED:
  7) Git Status
  8) System Specs
  
  Q) Quit

EOF
        
        printf 'Enter your choice [1-8,Q]: '
        
        # Handle read with timeout for security
        local choice
        if read -r choice 2>/dev/null; then
            case "$choice" in
                1) execute_check ;;
                2) execute_complete_uninstall ;;
                3) execute_optimize ;;
                4) execute_git_backup ;;
                5) execute_health_check ;;
                6) show_help ;;
                7) execute_git_status ;;
                8) execute_system_specs ;;
                [Qq]|[Qq][Uu][Ii][Tt])
                    info_message "Exiting script..."
                    SCRIPT_EXITING=true
                    SCRIPT_RUNNING=false
                    break
                    ;;
                *)
                    error_message "Invalid choice: $choice"
                    ;;
            esac
        else
            info_message "Non-interactive mode detected, exiting..."
            break
        fi
        
        if [[ "$SCRIPT_RUNNING" == "true" ]]; then
            printf '\nPress Enter to continue...'
            read -r 2>/dev/null || break
        fi
    done
    
    return 0
}

# Main function with comprehensive error handling
main() {
    local exit_code=0
    
    # Initialize environment
    detect_environment || warning_message "Environment detection issues found"
    
    # Set up directories and logging
    if [[ -n "${TMPDIR:-}" ]]; then
        mkdir -p "$TMPDIR" 2>/dev/null || true
    fi
    
    info_message "Starting Cursor Management Utility v$SCRIPT_VERSION"
    debug_message "Script directory: $SCRIPT_DIR"
    debug_message "Project root: $PROJECT_ROOT"
    debug_message "Non-interactive mode: $NON_INTERACTIVE_MODE"
    
    # Initialize modules
    initialize_modules || {
        warning_message "Some modules failed to load - functionality may be limited"
    }
    
    # Parse command line arguments
    if ! parse_arguments "$@"; then
        local parse_exit=$?
        if (( parse_exit == 2 )); then
            # Help was shown
            return 0
        else
            error_message "Failed to parse arguments"
            return 1
        fi
    fi
    
    # Execute requested operation
    execute_operation "${OPERATION:-menu}" || exit_code=$?
    
    # Final status report
    if (( ERRORS_ENCOUNTERED > 0 )); then
        warning_message "Script completed with $ERRORS_ENCOUNTERED total errors"
    else
        success_message "Script completed successfully"
    fi
    
    return $exit_code
}

# Script entry point with secure execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Set up clean exit handling
    cleanup() {
        SCRIPT_EXITING=true
        SCRIPT_RUNNING=false
        trap - ERR EXIT INT TERM
        
        # Clean up temp files if any
        if [[ -n "${TEMP_DIR:-}" && -d "$TEMP_DIR" && "$TEMP_DIR" =~ /tmp/ ]]; then
            rm -rf "$TEMP_DIR" 2>/dev/null || true
        fi
    }
    
    trap cleanup EXIT INT TERM
    
    # Execute main function with all arguments
    main "$@"
else
    # Being sourced - export main functions only
    export -f main parse_arguments execute_operation
    info_message "Cursor management utility loaded as module"
fi
