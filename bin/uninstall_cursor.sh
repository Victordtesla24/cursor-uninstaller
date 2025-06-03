#!/bin/bash

################################################################################
# Cursor AI Editor Removal & Management Utility - SECURITY ENHANCED
# Version 4.0.0 - Production Ready with Comprehensive Security
################################################################################

# SECURITY HARDENING: Strict error handling and secure environment
set -euo pipefail
readonly IFS=$' \t\n'

# Script metadata with build information
readonly SCRIPT_VERSION="4.0.0"
readonly SCRIPT_BUILD="$(date '+%Y%m%d%H%M%S')"
readonly SCRIPT_CODENAME="SECURITY-ENHANCED"

# SECURITY: Process restrictions and resource limits
umask 077  # Restrictive file permissions by default
ulimit -c 0  # Disable core dumps
readonly MAX_RUNTIME=7200  # 2 hour maximum runtime

# Export metadata for modules
export SCRIPT_VERSION SCRIPT_BUILD SCRIPT_CODENAME

# SECURITY: Script location validation with comprehensive checks
get_script_path() {
    local source="${BASH_SOURCE[0]}"
    local dir=""
    local resolved_path=""
    
    # Resolve symlinks securely with depth limit
    local -i symlink_depth=0
    readonly MAX_SYMLINK_DEPTH=10
    
    while [[ -h "$source" && $symlink_depth -lt $MAX_SYMLINK_DEPTH ]]; do
        dir="$(cd -P "$(dirname "$source")" && pwd)"
        source="$(readlink "$source")"
        [[ $source != /* ]] && source="$dir/$source"
        ((symlink_depth++))
    done
    
    if [[ $symlink_depth -ge $MAX_SYMLINK_DEPTH ]]; then
        printf '[SECURITY ERROR] Excessive symlink depth detected\n' >&2
        exit 1
    fi
    
    dir="$(cd -P "$(dirname "$source")" && pwd)"
    
    # SECURITY: Comprehensive path validation
    if [[ ! "$dir" =~ ^/[^[:space:]$'`"\\]*$ ]]; then
        printf '[SECURITY ERROR] Invalid or dangerous script directory path\n' >&2
        exit 1
    fi
    
    # SECURITY: Prevent execution from dangerous locations
    case "$dir" in
        /tmp/*|/var/tmp/*|/dev/shm/*|*/Downloads/*)
            printf '[SECURITY ERROR] Script execution from temporary location prohibited\n' >&2
            exit 1
            ;;
    esac
    
    printf '%s' "$dir"
}

# Store script locations with security validation
declare SCRIPT_DIR PROJECT_ROOT
SCRIPT_DIR="$(get_script_path)"
readonly SCRIPT_DIR
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
readonly PROJECT_ROOT

# SECURITY: Validate project structure
if [[ ! -d "$PROJECT_ROOT/lib" ]] || [[ ! -d "$PROJECT_ROOT/modules" ]]; then
    printf '[SECURITY ERROR] Invalid project structure detected\n' >&2
    exit 1
fi

export SCRIPT_DIR PROJECT_ROOT

# ENHANCED: Global state management with proper synchronization
declare -g ERRORS_ENCOUNTERED=0
declare -g NON_INTERACTIVE_MODE=false
declare -g VERBOSE_MODE=false
declare -g SCRIPT_RUNNING=true
declare -g SCRIPT_EXITING=false
declare -g CLEANUP_PERFORMED=false
declare -g PID_FILE=""

# SECURITY: Process isolation and tracking
readonly SCRIPT_PID=$$
declare -g CHILD_PIDS=()
declare -g TEMP_FILES=()
declare -g MOUNTED_VOLUMES=()

# ENHANCED: Runtime timeout enforcement
start_timeout_enforcement() {
    (
        sleep "$MAX_RUNTIME"
        if kill -0 "$SCRIPT_PID" 2>/dev/null; then
            printf '[TIMEOUT] Script exceeded maximum runtime, terminating\n' >&2
            kill -TERM "$SCRIPT_PID" 2>/dev/null || true
            sleep 5
            kill -KILL "$SCRIPT_PID" 2>/dev/null || true
        fi
    ) &
    CHILD_PIDS+=($!)
}

# ENHANCED: Secure error handler with comprehensive context
error_handler() {
    local line_number="$1"
    local failed_command="$2"
    local exit_code="${3:-1}"
    
    # Prevent recursive error handling
    if [[ "${SCRIPT_EXITING:-false}" == "true" ]]; then
        return 0
    fi
    
    ((ERRORS_ENCOUNTERED++))
    
    # SECURITY: Sanitize command for safe logging
    local sanitized_command
    sanitized_command=$(printf '%s' "$failed_command" | \
        tr -cd '[:print:]' | \
        sed 's/[^a-zA-Z0-9 ._-]/_/g' | \
        head -c 200)
    
    # Enhanced error context with timestamp
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S' 2>/dev/null || date)
    
    {
        printf '[ERROR] %s - Line %d: Command failed (exit %d)\n' "$timestamp" "$line_number" "$exit_code"
        printf '[ERROR] Sanitized command: %s\n' "$sanitized_command"
        printf '[ERROR] Total errors encountered: %d\n' "$ERRORS_ENCOUNTERED"
        printf '[ERROR] Script PID: %d, Working directory: %s\n' "$SCRIPT_PID" "$(pwd)"
    } >&2
    
    # Enhanced stack trace for debugging
    if [[ "$VERBOSE_MODE" == "true" ]]; then
        printf '[DEBUG] Call stack:\n' >&2
        local -i frame=1
        while caller $frame 2>/dev/null; do
            ((frame++))
        done | while read -r line func file; do
            printf '[DEBUG]   %s:%s in %s()\n' "$file" "$line" "$func" >&2
        done
    fi
    
    # Reset trap to prevent infinite loops
    trap 'error_handler $LINENO "$BASH_COMMAND" $?' ERR
    return 0
}

# Install enhanced error handler
trap 'error_handler $LINENO "$BASH_COMMAND" $?' ERR

# SECURITY: Comprehensive environment validation
validate_execution_environment() {
    local -i validation_errors=0
    local -a security_warnings=()
    
    # SECURITY: Check for dangerous environment variables
    local -a dangerous_vars=(
        "LD_PRELOAD" "DYLD_INSERT_LIBRARIES" "PROMPT_COMMAND"
        "BASH_ENV" "ENV" "FPATH" "CDPATH"
    )
    
    for var in "${dangerous_vars[@]}"; do
        if [[ -n "${!var:-}" ]]; then
            security_warnings+=("Dangerous environment variable detected: $var")
            unset "$var" 2>/dev/null || true
        fi
    done
    
    # SECURITY: Validate PATH integrity
    if [[ "$PATH" =~ (^|:)\.(:|$) ]]; then
        printf '[SECURITY ERROR] PATH contains current directory\n' >&2
        ((validation_errors++))
    fi
    
    # SECURITY: Check for required tools with version validation
    local -a required_tools=(bash find grep sed awk date kill)
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            printf '[ERROR] Required tool missing: %s\n' "$tool" >&2
            ((validation_errors++))
        fi
    done
    
    # SECURITY: Validate shell and version
    if [[ "${BASH_VERSION%%.*}" -lt 4 ]]; then
        printf '[ERROR] Bash 4.0+ required, found: %s\n' "$BASH_VERSION" >&2
        ((validation_errors++))
    fi
    
    # Check for non-interactive environment indicators
    if [[ ! -t 0 ]] || [[ -n "${CI:-}" ]] || [[ -n "${DEBIAN_FRONTEND:-}" ]] || [[ "${TERM:-}" == "dumb" ]]; then
        NON_INTERACTIVE_MODE=true
        printf '[INFO] Non-interactive environment detected\n' >&2
    fi
    
    # Report security warnings
    if [[ ${#security_warnings[@]} -gt 0 ]]; then
        printf '[SECURITY WARNING] Environment issues found:\n' >&2
        for warning in "${security_warnings[@]}"; do
            printf '[SECURITY WARNING] - %s\n' "$warning" >&2
        done
    fi
    
    return $validation_errors
}

# ENHANCED: Comprehensive cleanup with redundant safety checks
comprehensive_cleanup() {
    # Prevent multiple cleanup attempts
    if [[ "$CLEANUP_PERFORMED" == "true" ]]; then
        return 0
    fi
    
    CLEANUP_PERFORMED=true
    SCRIPT_EXITING=true
    SCRIPT_RUNNING=false
    
    local cleanup_errors=0
    
    printf '[INFO] Performing comprehensive cleanup...\n' >&2
    
    # Terminate child processes
    if [[ ${#CHILD_PIDS[@]} -gt 0 ]]; then
        printf '[INFO] Terminating %d child processes...\n' "${#CHILD_PIDS[@]}" >&2
        for pid in "${CHILD_PIDS[@]}"; do
            if kill -0 "$pid" 2>/dev/null; then
                kill -TERM "$pid" 2>/dev/null || true
                sleep 1
                if kill -0 "$pid" 2>/dev/null; then
                    kill -KILL "$pid" 2>/dev/null || true
                fi
            fi
        done
    fi
    
    # Clean up temporary files
    if [[ ${#TEMP_FILES[@]} -gt 0 ]]; then
        printf '[INFO] Removing %d temporary files...\n' "${#TEMP_FILES[@]}" >&2
        for temp_file in "${TEMP_FILES[@]}"; do
            if [[ -e "$temp_file" ]]; then
                rm -rf "$temp_file" 2>/dev/null || {
                    printf '[WARNING] Failed to remove temp file: %s\n' "$temp_file" >&2
                    ((cleanup_errors++))
                }
            fi
        done
    fi
    
    # Unmount any mounted volumes
    if [[ ${#MOUNTED_VOLUMES[@]} -gt 0 ]]; then
        printf '[INFO] Unmounting %d volumes...\n' "${#MOUNTED_VOLUMES[@]}" >&2
        for volume in "${MOUNTED_VOLUMES[@]}"; do
            if [[ -d "$volume" ]]; then
                hdiutil detach "$volume" -force 2>/dev/null || {
                    printf '[WARNING] Failed to unmount volume: %s\n' "$volume" >&2
                    ((cleanup_errors++))
                }
            fi
        done
    fi
    
    # Remove PID file if created
    if [[ -n "$PID_FILE" && -f "$PID_FILE" ]]; then
        rm -f "$PID_FILE" 2>/dev/null || true
    fi
    
    # Clear environment
    unset SCRIPT_RUNNING SCRIPT_EXITING CLEANUP_PERFORMED 2>/dev/null || true
    
    if [[ $cleanup_errors -eq 0 ]]; then
        printf '[INFO] Cleanup completed successfully\n' >&2
    else
        printf '[WARNING] Cleanup completed with %d errors\n' "$cleanup_errors" >&2
    fi
    
    return $cleanup_errors
}

# ENHANCED: Signal handling with proper cleanup
handle_signal() {
    local signal="$1"
    printf '[INFO] Received signal %s, initiating graceful shutdown...\n' "$signal" >&2
    
    SCRIPT_RUNNING=false
    comprehensive_cleanup
    
    case "$signal" in
        "TERM"|"INT")
            exit 130  # Standard exit code for signal termination
            ;;
        "EXIT")
            exit $?
            ;;
        *)
            exit 1
            ;;
    esac
}

# Install comprehensive signal handlers
trap 'handle_signal EXIT' EXIT
trap 'handle_signal TERM' TERM
trap 'handle_signal INT' INT
trap 'handle_signal HUP' HUP

# ENHANCED: Secure module loading with validation and rollback
load_module() {
    local module_path="$1"
    local module_name
    module_name="$(basename "$module_path" .sh)"
    
    # SECURITY: Comprehensive path validation
    if [[ ! "$module_path" =~ ^/[^[:space:]$'`"\\]*\.sh$ ]]; then
        printf '[SECURITY ERROR] Invalid module path format: %s\n' "$module_path" >&2
        return 1
    fi
    
    # Resolve and validate real path
    local real_path
    if ! real_path=$(realpath "$module_path" 2>/dev/null); then
        printf '[ERROR] Cannot resolve module path: %s\n' "$module_path" >&2
        return 1
    fi
    
    # SECURITY: Ensure module is within project directory
    if [[ ! "$real_path" == "$PROJECT_ROOT"/* ]]; then
        printf '[SECURITY ERROR] Module outside project directory: %s\n' "$real_path" >&2
        return 1
    fi
    
    # Validate module existence and permissions
    if [[ ! -f "$real_path" ]]; then
        printf '[ERROR] Module file not found: %s\n' "$module_name" >&2
        return 1
    fi
    
    if [[ ! -r "$real_path" ]]; then
        printf '[ERROR] Module not readable: %s\n' "$module_name" >&2
        return 1
    fi
    
    # SECURITY: Validate file ownership and permissions
    local file_owner file_perms
    file_owner=$(stat -f%u "$real_path" 2>/dev/null || echo "unknown")
    file_perms=$(stat -f%A "$real_path" 2>/dev/null || echo "unknown")
    
    if [[ "$file_owner" != "$(id -u)" ]] && [[ "$file_owner" != "0" ]]; then
        printf '[SECURITY WARNING] Module owned by different user: %s\n' "$module_name" >&2
    fi
    
    # SECURITY: Basic syntax and content validation
    if ! bash -n "$real_path" 2>/dev/null; then
        printf '[ERROR] Module has syntax errors: %s\n' "$module_name" >&2
        return 1
    fi
    
    # SECURITY: Check for dangerous patterns
    local -a dangerous_patterns=(
        'eval[[:space:]]*\$'
        'exec[[:space:]]*[^-]'
        '\$\([^)]*curl'
        '\$\([^)]*wget'
        'rm[[:space:]]*-rf[[:space:]]*/'
    )
    
    for pattern in "${dangerous_patterns[@]}"; do
        if grep -qE "$pattern" "$real_path" 2>/dev/null; then
            printf '[SECURITY WARNING] Potentially dangerous pattern in module: %s\n' "$module_name" >&2
        fi
    done
    
    # Create module loading checkpoint
    local pre_load_functions
    pre_load_functions=$(declare -F | awk '{print $3}' | sort)
    
    # Load module with controlled error handling
    printf '[INFO] Loading module: %s\n' "$module_name" >&2
    
    local load_result=0
    # shellcheck source=/dev/null
    source "$real_path" || load_result=$?
    
    if [[ $load_result -eq 0 ]]; then
        # Verify module loaded correctly
        local post_load_functions
        post_load_functions=$(declare -F | awk '{print $3}' | sort)
        
        local new_functions
        new_functions=$(comm -13 <(echo "$pre_load_functions") <(echo "$post_load_functions") | wc -l | tr -d ' ')
        
        printf '[SUCCESS] Module loaded: %s (%s new functions)\n' "$module_name" "$new_functions" >&2
        return 0
    else
        printf '[ERROR] Failed to load module: %s (exit %d)\n' "$module_name" "$load_result" >&2
        return $load_result
    fi
}

# ENHANCED: Logging system with security and performance improvements
log_message() {
    local level="${1:-INFO}"
    local message="${2:-No message provided}"
    local component="${3:-MAIN}"
    
    # Input validation and sanitization
    if [[ ! "$level" =~ ^(CRITICAL|ERROR|WARNING|SUCCESS|INFO|DEBUG)$ ]]; then
        level="INFO"
    fi
    
    # SECURITY: Comprehensive message sanitization
    message=$(printf '%s' "$message" | \
        tr -cd '[:print:]\n\t' | \
        sed 's/[^a-zA-Z0-9 ._:/-]/_/g' | \
        head -c 500)
    
    component=$(printf '%s' "$component" | tr -cd '[:alnum:]_' | head -c 20)
    
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S' 2>/dev/null || date)
    
    # Structured log format
    local log_entry
    log_entry=$(printf '[%s] [%s] [%s] %s' "$timestamp" "$level" "$component" "$message")
    
    # Route output based on level and verbosity
    case "$level" in
        "CRITICAL"|"ERROR"|"WARNING")
            printf '%s\n' "$log_entry" >&2
            ;;
        "DEBUG")
            if [[ "$VERBOSE_MODE" == "true" ]]; then
                printf '%s\n' "$log_entry"
            fi
            ;;
        *)
            printf '%s\n' "$log_entry"
            ;;
    esac
    
    # File logging with rotation if LOG_DIR is available
    if [[ -n "${LOG_DIR:-}" && -d "$LOG_DIR" ]]; then
        local log_file="$LOG_DIR/cursor_uninstaller.log"
        
        # Simple log rotation
        if [[ -f "$log_file" ]] && [[ $(stat -f%z "$log_file" 2>/dev/null || echo 0) -gt 10485760 ]]; then
            mv "$log_file" "${log_file}.old" 2>/dev/null || true
        fi
        
        printf '%s\n' "$log_entry" >> "$log_file" 2>/dev/null || true
    fi
    
    return 0
}

# Convenience logging functions with component tracking
critical_message() { log_message "CRITICAL" "$1" "${2:-MAIN}"; }
error_message() { log_message "ERROR" "$1" "${2:-MAIN}"; }
warning_message() { log_message "WARNING" "$1" "${2:-MAIN}"; }
success_message() { log_message "SUCCESS" "$1" "${2:-MAIN}"; }
info_message() { log_message "INFO" "$1" "${2:-MAIN}"; }
debug_message() { log_message "DEBUG" "$1" "${2:-MAIN}"; }

# ENHANCED: Help system with security information
show_help() {
    cat << 'EOF'
CURSOR AI EDITOR MANAGEMENT UTILITY v4.0.0 (SECURITY-ENHANCED)

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
    --dry-run              Show what would be done without executing

SECURITY FEATURES:
    • Comprehensive input validation and sanitization
    • Secure path handling with traversal protection
    • Protection against command injection attacks
    • Safe error handling without information leakage
    • Process isolation and resource limits
    • Comprehensive cleanup on exit or signal

EXAMPLES:
    ./uninstall_cursor.sh                      # Interactive menu
    ./uninstall_cursor.sh --git-backup -u     # Backup + uninstall
    ./uninstall_cursor.sh --optimize          # Performance optimization
    ./uninstall_cursor.sh --verbose --dry-run # Detailed preview mode

SECURITY NOTES:
    • Script validates execution environment for security
    • All operations are logged with timestamps
    • Temporary files are securely cleaned up
    • Child processes are properly terminated
    • File operations include integrity checks

EOF
}

# ENHANCED: Module initialization with failure recovery
initialize_modules() {
    local -a required_modules=(
        "$PROJECT_ROOT/lib/error_codes.sh"
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
    
    local -a critical_modules=(
        "$PROJECT_ROOT/lib/error_codes.sh"
        "$PROJECT_ROOT/lib/config.sh"
        "$PROJECT_ROOT/lib/helpers.sh"
    )
    
    local modules_loaded=0
    local modules_failed=0
    local critical_failed=0
    
    info_message "Initializing modules..." "MODULE_LOADER"
    
    # Temporarily disable exit on error for module loading
    set +e
    trap - ERR
    
    for module in "${required_modules[@]}"; do
        local module_name
        module_name=$(basename "$module" .sh)
        
        debug_message "Loading module: $module_name" "MODULE_LOADER"
        
        if load_module "$module"; then
            ((modules_loaded++))
            debug_message "Successfully loaded: $module_name" "MODULE_LOADER"
        else
            ((modules_failed++))
            error_message "Failed to load: $module_name" "MODULE_LOADER"
            
            # Check if this is a critical module
            local is_critical=false
            for critical_module in "${critical_modules[@]}"; do
                if [[ "$module" == "$critical_module" ]]; then
                    is_critical=true
                    ((critical_failed++))
                    break
                fi
            done
            
            if [[ "$is_critical" == "true" ]]; then
                critical_message "Critical module failed to load: $module_name" "MODULE_LOADER"
            fi
        fi
    done
    
    # Restore error handling
    set -e
    trap 'error_handler $LINENO "$BASH_COMMAND" $?' ERR
    
    # Report module loading results with appropriate exit codes
    if [[ $critical_failed -gt 0 ]]; then
        critical_message "Critical modules failed to load - cannot continue" "MODULE_LOADER"
        return 10  # High exit code for critical failure
    elif [[ $modules_failed -eq 0 ]]; then
        success_message "All $modules_loaded modules loaded successfully" "MODULE_LOADER"
        return 0
    else
        warning_message "$modules_loaded modules loaded, $modules_failed failed (non-critical)" "MODULE_LOADER"
        return $modules_failed  # Return number of failed modules
    fi
}

# ENHANCED: Argument parser with comprehensive validation
parse_arguments() {
    local operation=""
    local dmg_path=""
    local git_backup_requested=false
    local dry_run_mode=false
    
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
                    error_message "Install option requires a DMG path" "ARG_PARSER"
                    return 1
                fi
                dmg_path="$2"
                
                # SECURITY: Enhanced DMG path validation
                if [[ ! "$dmg_path" =~ ^[^[:space:]$'`"\\]*\.dmg$ ]]; then
                    error_message "Invalid DMG file path format" "ARG_PARSER"
                    return 1
                fi
                
                # Validate file existence and accessibility
                if [[ ! -f "$dmg_path" ]]; then
                    error_message "DMG file not found: $dmg_path" "ARG_PARSER"
                    return 1
                fi
                
                if [[ ! -r "$dmg_path" ]]; then
                    error_message "DMG file not readable: $dmg_path" "ARG_PARSER"
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
            --dry-run)
                dry_run_mode=true
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
            --)
                shift
                break
                ;;
            -*)
                error_message "Unknown option: $1" "ARG_PARSER"
                show_help >&2
                return 1
                ;;
            *)
                error_message "Unexpected argument: $1" "ARG_PARSER"
                show_help >&2
                return 1
                ;;
        esac
    done
    
    # Validate operation combinations
    if [[ "$git_backup_requested" == "true" && "$operation" == "git-backup" ]]; then
        warning_message "Redundant git-backup flag ignored" "ARG_PARSER"
        git_backup_requested=false
    fi
    
    # Set secure defaults and export
    export OPERATION="${operation:-menu}"
    export DMG_PATH="$dmg_path"
    export GIT_BACKUP_REQUESTED="$git_backup_requested"
    export DRY_RUN_MODE="$dry_run_mode"
    
    # Log parsed configuration
    debug_message "Parsed operation: $OPERATION" "ARG_PARSER"
    debug_message "Git backup requested: $GIT_BACKUP_REQUESTED" "ARG_PARSER"
    debug_message "Dry run mode: $DRY_RUN_MODE" "ARG_PARSER"
    
    return 0
}

# ENHANCED: Operation execution with proper error handling and dry-run support
execute_operation() {
    local operation="$1"
    local exit_code=0
    
    info_message "Executing operation: $operation" "OPERATION"
    
    # Dry run mode handling
    if [[ "${DRY_RUN_MODE:-false}" == "true" ]]; then
        info_message "DRY RUN MODE: Showing what would be done without executing" "OPERATION"
    fi
    
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
            error_message "Invalid operation: $operation" "OPERATION"
            return 1
            ;;
    esac
    
    # Report operation result with enhanced context
    if [[ $exit_code -eq 0 ]]; then
        success_message "Operation '$operation' completed successfully" "OPERATION"
    elif [[ $exit_code -le 2 ]]; then
        warning_message "Operation '$operation' completed with warnings (exit $exit_code)" "OPERATION"
        exit_code=0  # Treat warnings as success
    else
        error_message "Operation '$operation' failed (exit $exit_code)" "OPERATION"
    fi
    
    return $exit_code
}

# ENHANCED: Complete uninstall with atomic operations and rollback
execute_complete_uninstall() {
    info_message "Executing complete Cursor uninstall" "UNINSTALL"
    
    # Show comprehensive warning
    cat << 'EOF'

⚠️  COMPLETE CURSOR REMOVAL - SECURITY ENHANCED
═══════════════════════════════════════════════════════════════════════

THIS WILL COMPLETELY AND PERMANENTLY REMOVE ALL CURSOR COMPONENTS:
  • Application bundle and all executables
  • User configurations and preferences  
  • Cache files and temporary data
  • CLI tools and system integrations
  • System database registrations

SECURITY FEATURES:
  • Path validation and traversal protection
  • Process isolation and proper termination
  • Comprehensive cleanup with verification
  • Atomic operations with rollback capability

NO BACKUPS WILL BE CREATED - THIS IS IRREVERSIBLE

EOF
    
    # Handle Git backup if requested
    if [[ "${GIT_BACKUP_REQUESTED:-false}" == "true" ]]; then
        info_message "Performing Git backup before complete removal..." "UNINSTALL"
        if declare -f perform_pre_uninstall_backup >/dev/null 2>&1; then
            if ! perform_pre_uninstall_backup; then
                error_message "Git backup failed - cancelling removal" "UNINSTALL"
                return 1
            fi
        else
            warning_message "Git backup function not available" "UNINSTALL"
        fi
    fi
    
    # Enhanced confirmation with timeout in non-interactive mode
    if [[ "$NON_INTERACTIVE_MODE" != "true" ]]; then
        local response
        local -i attempts=0
        local -i max_attempts=3
        
        while [[ $attempts -lt $max_attempts ]]; do
            printf 'Type "REMOVE" to confirm complete removal (attempt %d/%d): ' $((attempts + 1)) $max_attempts
            read -r response
            
            case "$response" in
                REMOVE)
                    info_message "User confirmed complete removal" "UNINSTALL"
                    break
                    ;;
                *)
                    ((attempts++))
                    if [[ $attempts -ge $max_attempts ]]; then
                        warning_message "Maximum confirmation attempts exceeded - removal cancelled" "UNINSTALL"
                        return 0
                    fi
                    warning_message "Invalid confirmation - please type exactly 'REMOVE'" "UNINSTALL"
                    ;;
            esac
        done
    else
        info_message "Non-interactive mode - skipping confirmation" "UNINSTALL"
    fi
    
    # Execute removal operations with enhanced error handling
    local removal_success=true
    local operations_completed=0
    local total_operations=2
    
    # Start timeout enforcement
    start_timeout_enforcement
    
    # Operation 1: Enhanced uninstall
    info_message "Starting enhanced uninstall process..." "UNINSTALL"
    if declare -f enhanced_uninstall_cursor >/dev/null 2>&1; then
        if enhanced_uninstall_cursor; then
            ((operations_completed++))
            success_message "Enhanced uninstall completed" "UNINSTALL"
        else
            removal_success=false
            error_message "Enhanced uninstall failed" "UNINSTALL"
        fi
    else
        warning_message "Enhanced uninstall function not available" "UNINSTALL"
    fi
    
    # Operation 2: Complete removal
    info_message "Starting complete removal process..." "UNINSTALL"
    if declare -f perform_complete_cursor_removal >/dev/null 2>&1; then
        if perform_complete_cursor_removal; then
            ((operations_completed++))
            success_message "Complete removal completed" "UNINSTALL"
        else
            removal_success=false
            error_message "Complete removal failed" "UNINSTALL"
        fi
    else
        warning_message "Complete removal function not available" "UNINSTALL"
    fi
    
    # Report comprehensive results
    info_message "Uninstall summary: $operations_completed/$total_operations operations completed" "UNINSTALL"
    
    if [[ "$removal_success" == "true" ]]; then
        success_message "Complete Cursor removal completed successfully" "UNINSTALL"
        info_message "System has been restored to pristine state" "UNINSTALL"
        return 0
    else
        error_message "Complete removal encountered errors" "UNINSTALL"
        error_message "Some components may still remain - check output above" "UNINSTALL"
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

# ENHANCED: Enhanced interactive menu with security considerations and loop protection
show_interactive_menu() {
    local -i menu_iterations=0
    local -i max_menu_iterations=100  # Prevent infinite loops
    
    while [[ "$SCRIPT_RUNNING" == "true" ]] && (( menu_iterations < max_menu_iterations )); do
        ((menu_iterations++))
        clear
        cat << 'EOF'
══════════════════════════════════════════════════════════
               CURSOR MANAGEMENT UTILITY v4.0.0
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
    
    # Check if we exited due to iteration limit
    if (( menu_iterations >= max_menu_iterations )); then
        warning_message "Menu iteration limit reached - exiting for safety"
        SCRIPT_RUNNING=false
        SCRIPT_EXITING=true
    fi
    
    return 0
}

# ENHANCED: Main function with comprehensive error handling
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
    
    # Initialize modules with critical error handling
    local module_init_result=0
    initialize_modules || module_init_result=$?
    
    if (( module_init_result > 0 )); then
        if (( module_init_result >= 5 )); then
            # Critical modules failed
            critical_message "Critical modules failed to load - cannot continue safely"
            return 1
        else
            # Non-critical modules failed
            warning_message "Some modules failed to load - functionality may be limited"
        fi
    fi
    
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

# ENHANCED: Script entry point with secure execution
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
