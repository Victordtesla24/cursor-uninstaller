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
# Core Removal Functions - FIXES MISSING FUNCTION ERRORS
################################################################################

# Execute commands safely with proper error handling
execute_safely() {
    local command="$1"
    local description="${2:-command execution}"
    local critical="${3:-false}"
    
    if [[ -z "$command" ]]; then
        log_with_context "ERROR" "No command provided for execution" "EXECUTE_SAFELY"
        return 1
    fi
    
    log_with_context "DEBUG" "Executing: $description" "EXECUTE_SAFELY"
    
    # Execute the command and capture result
    if eval "$command" >/dev/null 2>&1; then
        log_with_context "SUCCESS" "Successfully executed: $description" "EXECUTE_SAFELY"
        return 0
    else
        local exit_code=$?
        log_with_context "ERROR" "Failed to execute: $description" "EXECUTE_SAFELY"
        
        # For critical commands, return the error code
        if [[ "$critical" == "true" ]]; then
            return $exit_code
        else
            # For non-critical commands, return success to continue execution
            return 0
        fi
    fi
}

# Production removal function with comprehensive error handling
production_remove() {
    local path="$1"
    
    if [[ -z "$path" ]]; then
        log_with_context "ERROR" "No path provided for removal" "PROD_REMOVE"
        return 1
    fi
    
    # Safety check - never remove critical system directories
    case "$path" in
        "/" | "/System" | "/Library/System" | "/usr/bin" | "/usr/sbin" | "/bin" | "/sbin")
            log_with_context "ERROR" "Refusing to remove critical system directory: $path" "PROD_REMOVE"
            return 1
            ;;
    esac
    
    # Check if path exists
    if [[ ! -e "$path" ]]; then
        log_with_context "DEBUG" "Path does not exist, nothing to remove: $path" "PROD_REMOVE"
        return 0
    fi
    
    log_with_context "INFO" "Attempting to remove: $path" "PROD_REMOVE"
    
    # Try standard removal first
    if rm -rf "$path" 2>/dev/null; then
        log_with_context "SUCCESS" "Successfully removed: $path" "PROD_REMOVE"
        return 0
    fi
    
    # If standard removal fails, try with elevated permissions
    log_with_context "DEBUG" "Standard removal failed, attempting with sudo" "PROD_REMOVE"
    
    # First try to fix permissions
    if sudo chmod -R 755 "$path" 2>/dev/null; then
        log_with_context "DEBUG" "Fixed permissions for: $path" "PROD_REMOVE"
    fi
    
    # Now try removal with sudo
    if sudo rm -rf "$path" 2>/dev/null; then
        log_with_context "SUCCESS" "Successfully removed with sudo: $path" "PROD_REMOVE"
        return 0
    fi
    
    # If all removal attempts fail, return error
    log_with_context "ERROR" "Failed to remove: $path" "PROD_REMOVE"
    return 1
}

################################################################################
# Logging and Message Functions
################################################################################

# Production-grade logging function
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

# Production message functions with color coding
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

# Comprehensive system requirements validation for Cursor Management Utility
validate_system_requirements() {
    local validation_errors=0
    local validation_warnings=0
    
    log_with_context "INFO" "Starting comprehensive system requirements validation" "SYS_VALIDATION"
    
    # 1. Operating System Validation
    log_with_context "DEBUG" "Validating operating system compatibility" "SYS_VALIDATION"
    if [[ "$OSTYPE" != "darwin"* ]]; then
        log_with_context "ERROR" "This utility requires macOS - Current OS: $OSTYPE" "SYS_VALIDATION"
        ((validation_errors++))
    else
        # Check macOS version
        local macos_version
        macos_version=$(sw_vers -productVersion 2>/dev/null)
        if [[ -n "$macos_version" ]]; then
            local major_version
            major_version=$(echo "$macos_version" | cut -d. -f1)
            if [[ $major_version -lt 10 ]]; then
                log_with_context "ERROR" "macOS version too old: $macos_version (minimum: 10.0)" "SYS_VALIDATION"
                ((validation_errors++))
            elif [[ $major_version -eq 10 ]]; then
                local minor_version
                minor_version=$(echo "$macos_version" | cut -d. -f2)
                if [[ $minor_version -lt 12 ]]; then
                    log_with_context "WARNING" "macOS version may have compatibility issues: $macos_version (recommended: 10.12+)" "SYS_VALIDATION"
                    ((validation_warnings++))
                fi
            fi
            log_with_context "SUCCESS" "macOS version validated: $macos_version" "SYS_VALIDATION"
        else
            log_with_context "WARNING" "Could not determine macOS version" "SYS_VALIDATION"
            ((validation_warnings++))
        fi
    fi
    
    # 2. Architecture Validation
    local arch
    arch=$(uname -m)
    log_with_context "INFO" "System architecture: $arch" "SYS_VALIDATION"
    case "$arch" in
        "arm64")
            log_with_context "SUCCESS" "Apple Silicon architecture detected (optimal)" "SYS_VALIDATION"
            ;;
        "x86_64")
            log_with_context "SUCCESS" "Intel x86_64 architecture detected (compatible)" "SYS_VALIDATION"
            ;;
        *)
            log_with_context "WARNING" "Unsupported architecture detected: $arch" "SYS_VALIDATION"
            ((validation_warnings++))
            ;;
    esac
    
    # 3. Memory Requirements
    local memory_gb
    memory_gb=$(sysctl -n hw.memsize 2>/dev/null | awk '{print int($1/1024/1024/1024)}' 2>/dev/null || echo "0")
    if [[ $memory_gb -lt 4 ]]; then
        log_with_context "ERROR" "Insufficient memory: ${memory_gb}GB (minimum: 4GB)" "SYS_VALIDATION"
        ((validation_errors++))
    elif [[ $memory_gb -lt 8 ]]; then
        log_with_context "WARNING" "Limited memory for optimal performance: ${memory_gb}GB (recommended: 8GB+)" "SYS_VALIDATION"
        ((validation_warnings++))
    else
        log_with_context "SUCCESS" "Memory requirements satisfied: ${memory_gb}GB" "SYS_VALIDATION"
    fi
    
    # 4. Disk Space Requirements
    local available_space_gb
    available_space_gb=$(df -g / 2>/dev/null | tail -1 | awk '{print $4}' 2>/dev/null || echo "0")
    if [[ $available_space_gb -lt 1 ]]; then
        log_with_context "ERROR" "Insufficient disk space: ${available_space_gb}GB (minimum: 1GB)" "SYS_VALIDATION"
        ((validation_errors++))
    elif [[ $available_space_gb -lt 5 ]]; then
        log_with_context "WARNING" "Limited disk space: ${available_space_gb}GB (recommended: 5GB+)" "SYS_VALIDATION"
        ((validation_warnings++))
    else
        log_with_context "SUCCESS" "Disk space requirements satisfied: ${available_space_gb}GB available" "SYS_VALIDATION"
    fi
    
    # 5. Essential Commands Validation
    local required_commands=("defaults" "sudo" "pgrep" "pkill" "ps" "grep" "awk" "sed" "find" "xargs")
    local missing_commands=()
    
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing_commands+=("$cmd")
            log_with_context "ERROR" "Required command not found: $cmd" "SYS_VALIDATION"
            ((validation_errors++))
        else
            log_with_context "DEBUG" "Command available: $cmd" "SYS_VALIDATION"
        fi
    done
    
    # 6. Optional but Recommended Commands
    local recommended_commands=("brew" "git" "curl" "wget" "jq" "plutil")
    local missing_recommended=()
    
    for cmd in "${recommended_commands[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing_recommended+=("$cmd")
            log_with_context "WARNING" "Recommended command not found: $cmd" "SYS_VALIDATION"
            ((validation_warnings++))
        else
            log_with_context "DEBUG" "Recommended command available: $cmd" "SYS_VALIDATION"
        fi
    done
    
    # 7. System Integrity Protection (SIP) Check
    if command -v csrutil >/dev/null 2>&1; then
        local sip_status
        sip_status=$(csrutil status 2>/dev/null)
        if echo "$sip_status" | grep -q "enabled"; then
            log_with_context "SUCCESS" "System Integrity Protection is enabled (secure)" "SYS_VALIDATION"
        else
            log_with_context "WARNING" "System Integrity Protection is disabled" "SYS_VALIDATION"
            ((validation_warnings++))
        fi
    else
        log_with_context "WARNING" "Cannot check System Integrity Protection status" "SYS_VALIDATION"
        ((validation_warnings++))
    fi
    
    # 8. Admin/Sudo Privileges Check
    log_with_context "DEBUG" "Checking administrative privileges" "SYS_VALIDATION"
    if sudo -n true 2>/dev/null; then
        log_with_context "SUCCESS" "Administrative privileges available (passwordless sudo)" "SYS_VALIDATION"
    elif command -v sudo >/dev/null 2>&1; then
        log_with_context "INFO" "Administrative privileges available (sudo with password)" "SYS_VALIDATION"
    else
        log_with_context "ERROR" "No administrative privileges available (sudo not found)" "SYS_VALIDATION"
        ((validation_errors++))
    fi
    
    # 9. File System Permissions Check
    local temp_test_file="/tmp/.cursor_uninstaller_permission_test_$$"
    if touch "$temp_test_file" 2>/dev/null; then
        if [[ -w "$temp_test_file" ]]; then
            log_with_context "SUCCESS" "File system write permissions validated" "SYS_VALIDATION"
            rm -f "$temp_test_file" 2>/dev/null
        else
            log_with_context "ERROR" "File system write permissions denied" "SYS_VALIDATION"
            ((validation_errors++))
        fi
    else
        log_with_context "ERROR" "Cannot create temporary files in /tmp" "SYS_VALIDATION"
        ((validation_errors++))
    fi
    
    # 10. Network Connectivity Check (optional)
    log_with_context "DEBUG" "Checking network connectivity" "SYS_VALIDATION"
    if ping -c 1 -W 3000 8.8.8.8 >/dev/null 2>&1; then
        log_with_context "SUCCESS" "Network connectivity available" "SYS_VALIDATION"
    else
        log_with_context "WARNING" "Network connectivity issues detected" "SYS_VALIDATION"
        ((validation_warnings++))
    fi
    
    # 11. CPU Core Count Check
    local cpu_cores
    cpu_cores=$(sysctl -n hw.ncpu 2>/dev/null || echo "1")
    if [[ $cpu_cores -ge 2 ]]; then
        log_with_context "SUCCESS" "CPU requirements satisfied: $cpu_cores cores" "SYS_VALIDATION"
    else
        log_with_context "WARNING" "Limited CPU cores: $cpu_cores (recommended: 2+)" "SYS_VALIDATION"
        ((validation_warnings++))
    fi
    
    # 12. Shell Environment Validation
    if [[ -n "${BASH_VERSION:-}" ]]; then
        log_with_context "SUCCESS" "Bash shell environment validated: $BASH_VERSION" "SYS_VALIDATION"
    elif [[ -n "${ZSH_VERSION:-}" ]]; then
        log_with_context "SUCCESS" "Zsh shell environment validated: $ZSH_VERSION" "SYS_VALIDATION"
    else
        log_with_context "WARNING" "Unknown shell environment: $SHELL" "SYS_VALIDATION"
        ((validation_warnings++))
    fi
    
    # Generate Validation Summary
    local total_checks=12
    local passed_checks=$((total_checks - validation_errors))
    
    log_with_context "INFO" "=== SYSTEM VALIDATION SUMMARY ===" "SYS_VALIDATION"
    log_with_context "INFO" "Total Checks: $total_checks" "SYS_VALIDATION"
    log_with_context "INFO" "Passed: $passed_checks" "SYS_VALIDATION"
    log_with_context "INFO" "Errors: $validation_errors" "SYS_VALIDATION"
    log_with_context "INFO" "Warnings: $validation_warnings" "SYS_VALIDATION"
    
    # Provide specific remediation advice if there are issues
    if [[ $validation_errors -gt 0 ]]; then
        log_with_context "ERROR" "SYSTEM VALIDATION FAILED: $validation_errors critical issues found" "SYS_VALIDATION"
        log_with_context "ERROR" "Please resolve the above errors before proceeding" "SYS_VALIDATION"
        
        if [[ ${#missing_commands[@]} -gt 0 ]]; then
            log_with_context "ERROR" "Missing required commands: ${missing_commands[*]}" "SYS_VALIDATION"
            log_with_context "ERROR" "Install missing commands using: brew install <command> or xcode-select --install" "SYS_VALIDATION"
        fi
        
        return 1
    elif [[ $validation_warnings -gt 0 ]]; then
        log_with_context "WARNING" "SYSTEM VALIDATION PASSED WITH WARNINGS: $validation_warnings non-critical issues" "SYS_VALIDATION"
        
        if [[ ${#missing_recommended[@]} -gt 0 ]]; then
            log_with_context "WARNING" "Missing recommended commands: ${missing_recommended[*]}" "SYS_VALIDATION"
            log_with_context "INFO" "Consider installing: brew install ${missing_recommended[*]}" "SYS_VALIDATION"
        fi
        
        log_with_context "SUCCESS" "System is suitable for operation with minor limitations" "SYS_VALIDATION"
        return 0
    else
        log_with_context "SUCCESS" "SYSTEM VALIDATION PASSED: All requirements satisfied" "SYS_VALIDATION"
        return 0
    fi
}

# Export functions for use by other modules
export -f validate_file_exists validate_directory_exists validate_application_exists
export -f apply_sysctl_parameter handle_plist_file terminate_process_safely
export -f check_system_requirements validate_script_environment
export -f validate_system_requirements production_remove 