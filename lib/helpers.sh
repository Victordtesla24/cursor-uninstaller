#!/bin/bash

################################################################################
# Helper Functions Library for Cursor Management Utility
# Provides robust utility functions with production-grade error handling
################################################################################

# Set strict error handling
set -eE

# Global configuration variables  
HELPERS_VERSION="1.0.0"
HELPERS_DEBUG="${HELPERS_DEBUG:-false}"

################################################################################
# Logging and Message Functions
################################################################################

# Enhanced logging with timestamp and context
log_with_context() {
    local level="${1:-INFO}"
    local message="${2:-No message provided}"
    local context="${3:-GENERAL}"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "[$timestamp] [$level] [$context] $message" >&2
}

# Production-grade error handler
handle_error() {
    local line_number="$1"
    local error_code="$2"
    local failed_command="$3"
    
    log_with_context "ERROR" "Command failed at line $line_number: $failed_command" "ERROR_HANDLER"
    log_with_context "ERROR" "Exit code: $error_code" "ERROR_HANDLER"
    
    # Don't exit, just report - let calling function decide
    return "$error_code"
}

################################################################################
# System Validation Functions
################################################################################

# Validate file existence with proper error handling
validate_file_exists() {
    local file_path="$1"
    local description="${2:-file}"
    
    if [[ -z "$file_path" ]]; then
        log_with_context "ERROR" "No file path provided for validation" "FILE_VALIDATION"
        return 1
    fi
    
    if [[ -f "$file_path" ]]; then
        log_with_context "DEBUG" "File exists: $file_path" "FILE_VALIDATION"
        return 0
    else
        log_with_context "WARNING" "File not found: $file_path ($description)" "FILE_VALIDATION"
        return 1
    fi
}

# Validate directory existence with proper error handling  
validate_directory_exists() {
    local dir_path="$1"
    local description="${2:-directory}"
    
    if [[ -z "$dir_path" ]]; then
        log_with_context "ERROR" "No directory path provided for validation" "DIR_VALIDATION"
        return 1
    fi
    
    if [[ -d "$dir_path" ]]; then
        log_with_context "DEBUG" "Directory exists: $dir_path" "DIR_VALIDATION"
        return 0
    else
        log_with_context "WARNING" "Directory not found: $dir_path ($description)" "DIR_VALIDATION"
        return 1
    fi
}

# Safe application existence check
validate_application_exists() {
    local app_path="$1"
    
    if [[ -z "$app_path" ]]; then
        log_with_context "ERROR" "No application path provided" "APP_VALIDATION"
        return 1
    fi
    
    # Use proper conditional syntax - FIXED ERROR
    if [[ -d "$app_path" ]]; then
        log_with_context "INFO" "Application found: $app_path" "APP_VALIDATION"
        return 0
    else
        log_with_context "WARNING" "Application not found: $app_path" "APP_VALIDATION"
        return 1
    fi
}

################################################################################
# System Configuration Functions  
################################################################################

# Safe sysctl parameter handling - FIXES LINE 144 ERRORS
apply_sysctl_parameter() {
    local parameter="$1"
    local value="$2"
    local description="${3:-system parameter}"
    
    if [[ -z "$parameter" ]] || [[ -z "$value" ]]; then
        log_with_context "ERROR" "Missing parameter or value for sysctl" "SYSCTL"
        return 1
    fi
    
    # Check if parameter is valid format
    if [[ ! "$parameter" =~ ^[a-zA-Z0-9._]+$ ]]; then
        log_with_context "ERROR" "Invalid sysctl parameter format: $parameter" "SYSCTL"
        return 1
    fi
    
    # Apply the sysctl parameter safely
    if sudo sysctl "$parameter=$value" >/dev/null 2>&1; then
        log_with_context "SUCCESS" "Applied $description: $parameter=$value" "SYSCTL"
        return 0
    else
        log_with_context "ERROR" "Failed to apply $description: $parameter=$value" "SYSCTL"
        return 1
    fi
}

# Safe plist file handling - FIXES PLIST PATH ERRORS
handle_plist_file() {
    local plist_path="$1"
    local action="${2:-read}"
    local key="${3:-}"
    local value="${4:-}"
    
    if [[ -z "$plist_path" ]]; then
        log_with_context "ERROR" "No plist path provided" "PLIST_HANDLER"
        return 1
    fi
    
    # Use proper conditional syntax - FIXED ERROR  
    if [[ -f "$plist_path" ]]; then
        log_with_context "DEBUG" "Plist file exists: $plist_path" "PLIST_HANDLER"
    else
        log_with_context "WARNING" "Plist file not found: $plist_path" "PLIST_HANDLER"
        return 1
    fi
    
    case "$action" in
        "read")
            if [[ -n "$key" ]]; then
                if defaults read "$plist_path" "$key" 2>/dev/null; then
                    return 0
                else
                    log_with_context "WARNING" "Could not read key '$key' from $plist_path" "PLIST_HANDLER"
                    return 1
                fi
            else
                log_with_context "ERROR" "No key specified for plist read operation" "PLIST_HANDLER"
                return 1
            fi
            ;;
        "write")
            if [[ -n "$key" ]] && [[ -n "$value" ]]; then
                if defaults write "$plist_path" "$key" "$value" 2>/dev/null; then
                    log_with_context "SUCCESS" "Updated $key in $plist_path" "PLIST_HANDLER"
                    return 0
                else
                    log_with_context "ERROR" "Failed to write $key to $plist_path" "PLIST_HANDLER"
                    return 1
                fi
            else
                log_with_context "ERROR" "Key or value missing for plist write operation" "PLIST_HANDLER"
                return 1
            fi
            ;;
        *)
            log_with_context "ERROR" "Unknown plist action: $action" "PLIST_HANDLER"
            return 1
            ;;
    esac
}

################################################################################
# Process and Service Management
################################################################################

# Safe process termination
terminate_process_safely() {
    local process_name="$1"
    local timeout="${2:-10}"
    
    if [[ -z "$process_name" ]]; then
        log_with_context "ERROR" "No process name provided" "PROCESS_MGMT"
        return 1
    fi
    
    # Check if process is running
    if pgrep -f "$process_name" >/dev/null 2>&1; then
        log_with_context "INFO" "Attempting to terminate process: $process_name" "PROCESS_MGMT"
        
        # Try graceful termination first
        if pkill -f "$process_name"; then
            # Wait for graceful shutdown
            local count=0
            while [[ $count -lt $timeout ]] && pgrep -f "$process_name" >/dev/null 2>&1; do
                sleep 1
                ((count++))
            done
            
            # Check if process is still running
            if pgrep -f "$process_name" >/dev/null 2>&1; then
                log_with_context "WARNING" "Process still running after graceful termination, using force" "PROCESS_MGMT"
                pkill -9 -f "$process_name"
            fi
            
            log_with_context "SUCCESS" "Process terminated: $process_name" "PROCESS_MGMT"
            return 0
        else
            log_with_context "ERROR" "Failed to terminate process: $process_name" "PROCESS_MGMT"
            return 1
        fi
    else
        log_with_context "INFO" "Process not running: $process_name" "PROCESS_MGMT"
        return 0
    fi
}

################################################################################
# Utility Functions
################################################################################

# Safe command execution with output capture
execute_command_safely() {
    local command="$1"
    local description="${2:-command}"
    local allow_failure="${3:-false}"
    
    if [[ -z "$command" ]]; then
        log_with_context "ERROR" "No command provided for execution" "COMMAND_EXEC"
        return 1
    fi
    
    log_with_context "DEBUG" "Executing $description: $command" "COMMAND_EXEC"
    
    local output
    local exit_code
    
    output=$(eval "$command" 2>&1)
    exit_code=$?
    
    if [[ $exit_code -eq 0 ]]; then
        log_with_context "SUCCESS" "$description completed successfully" "COMMAND_EXEC"
        [[ -n "$output" ]] && echo "$output"
        return 0
    else
        if [[ "$allow_failure" == "true" ]]; then
            log_with_context "WARNING" "$description failed (allowed): exit code $exit_code" "COMMAND_EXEC"
        else
            log_with_context "ERROR" "$description failed: exit code $exit_code" "COMMAND_EXEC"
        fi
        [[ -n "$output" ]] && echo "$output" >&2
        return $exit_code
    fi
}

# Check system requirements
check_system_requirements() {
    local requirements_met=0
    
    log_with_context "INFO" "Checking system requirements" "SYS_CHECK"
    
    # Check macOS version
    if [[ "$OSTYPE" == "darwin"* ]]; then
        log_with_context "SUCCESS" "macOS detected" "SYS_CHECK"
    else
        log_with_context "ERROR" "This utility requires macOS" "SYS_CHECK"
        ((requirements_met++))
    fi
    
    # Check essential commands
    local required_commands=("defaults" "sudo" "pgrep" "pkill")
    for cmd in "${required_commands[@]}"; do
        if command -v "$cmd" >/dev/null 2>&1; then
            log_with_context "DEBUG" "Command available: $cmd" "SYS_CHECK"
        else
            log_with_context "ERROR" "Required command not found: $cmd" "SYS_CHECK"
            ((requirements_met++))
        fi
    done
    
    return $requirements_met
}

# Validate script environment
validate_script_environment() {
    local validation_errors=0
    
    # Check if FORCE_EXIT is properly set - FIXES LINE 132 ERROR
    if [[ -z "${FORCE_EXIT:-}" ]]; then
        log_with_context "WARNING" "FORCE_EXIT variable not set, defaulting to false" "ENV_VALIDATION"
        export FORCE_EXIT="false"
    fi
    
    # Validate FORCE_EXIT value
    if [[ "$FORCE_EXIT" == "true" ]] || [[ "$FORCE_EXIT" == "false" ]]; then
        log_with_context "DEBUG" "FORCE_EXIT properly configured: $FORCE_EXIT" "ENV_VALIDATION"
    else
        log_with_context "ERROR" "FORCE_EXIT has invalid value: $FORCE_EXIT" "ENV_VALIDATION"
        export FORCE_EXIT="false"
        ((validation_errors++))
    fi
    
    return $validation_errors
}

################################################################################
# Module Initialization
################################################################################

# Initialize helpers module
initialize_helpers() {
    log_with_context "INFO" "Initializing helpers module v$HELPERS_VERSION" "INIT"
    
    # Validate environment
    validate_script_environment
    
    # Check system requirements
    if ! check_system_requirements; then
        log_with_context "WARNING" "Some system requirements not met" "INIT"
    fi
    
    log_with_context "SUCCESS" "Helpers module initialized successfully" "INIT"
    return 0
}

# Auto-initialize when sourced
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    initialize_helpers
fi 