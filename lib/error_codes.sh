#!/bin/bash

################################################################################
# Standardized Error Codes for Cursor AI Editor Management Utility
# CENTRALIZED ERROR CODE DEFINITIONS AND HANDLING
################################################################################

# Strict error handling
set -euo pipefail

# Error code module configuration
readonly ERROR_CODES_VERSION="1.0.0"

# SUCCESS CODES (0-9)
readonly ERR_SUCCESS=0
readonly ERR_SUCCESS_WITH_WARNINGS=1

# GENERAL ERRORS (10-19)
readonly ERR_GENERAL_ERROR=10
readonly ERR_INVALID_ARGUMENTS=11
readonly ERR_PERMISSION_DENIED=12
readonly ERR_NOT_FOUND=13
readonly ERR_ALREADY_EXISTS=14
readonly ERR_OPERATION_CANCELLED=15

# SYSTEM ERRORS (20-29)
readonly ERR_SYSTEM_ERROR=20
readonly ERR_INSUFFICIENT_MEMORY=21
readonly ERR_INSUFFICIENT_DISK=22
readonly ERR_UNSUPPORTED_OS=23
readonly ERR_MISSING_DEPENDENCY=24
readonly ERR_SYSTEM_INCOMPATIBLE=25

# NETWORK ERRORS (30-39)
readonly ERR_NETWORK_ERROR=30
readonly ERR_NETWORK_TIMEOUT=31
readonly ERR_NETWORK_UNAVAILABLE=32
readonly ERR_DOWNLOAD_FAILED=33
readonly ERR_CONNECTION_REFUSED=34

# FILE OPERATION ERRORS (40-49)
readonly ERR_FILE_ERROR=40
readonly ERR_FILE_NOT_FOUND=41
readonly ERR_FILE_PERMISSION=42
readonly ERR_FILE_CORRUPTED=43
readonly ERR_FILE_TOO_LARGE=44
readonly ERR_FILE_IN_USE=45
readonly ERR_DISK_FULL=46

# PROCESS ERRORS (50-59)
readonly ERR_PROCESS_ERROR=50
readonly ERR_PROCESS_NOT_FOUND=51
readonly ERR_PROCESS_TERMINATION_FAILED=52
readonly ERR_PROCESS_TIMEOUT=53
readonly ERR_PROCESS_PERMISSION=54

# APPLICATION ERRORS (60-69)
readonly ERR_APP_ERROR=60
readonly ERR_APP_NOT_INSTALLED=61
readonly ERR_APP_INSTALLATION_FAILED=62
readonly ERR_APP_REMOVAL_FAILED=63
readonly ERR_APP_CORRUPTED=64
readonly ERR_APP_INCOMPATIBLE=65

# SECURITY ERRORS (70-79)
readonly ERR_SECURITY_ERROR=70
readonly ERR_SECURITY_VALIDATION_FAILED=71
readonly ERR_SECURITY_PATH_TRAVERSAL=72
readonly ERR_SECURITY_COMMAND_INJECTION=73
readonly ERR_SECURITY_PRIVILEGE_ESCALATION=74

# VALIDATION ERRORS (80-89)
readonly ERR_VALIDATION_ERROR=80
readonly ERR_VALIDATION_INPUT=81
readonly ERR_VALIDATION_CONFIG=82
readonly ERR_VALIDATION_DEPENDENCY=83
readonly ERR_VALIDATION_INTEGRITY=84

# MODULE ERRORS (90-99)
readonly ERR_MODULE_ERROR=90
readonly ERR_MODULE_LOAD_FAILED=91
readonly ERR_MODULE_INIT_FAILED=92
readonly ERR_MODULE_DEPENDENCY=93
readonly ERR_MODULE_COMPATIBILITY=94

# CRITICAL ERRORS (100+)
readonly ERR_CRITICAL_ERROR=100
readonly ERR_CRITICAL_SYSTEM_FAILURE=101
readonly ERR_CRITICAL_DATA_LOSS=102
readonly ERR_CRITICAL_SECURITY_BREACH=103

# Function to get error description (Bash 3.2 compatible)
get_error_description() {
    local error_code="$1"
    
    case "$error_code" in
        "$ERR_SUCCESS") echo "Operation completed successfully" ;;
        "$ERR_SUCCESS_WITH_WARNINGS") echo "Operation completed with warnings" ;;
        "$ERR_GENERAL_ERROR") echo "General error occurred" ;;
        "$ERR_INVALID_ARGUMENTS") echo "Invalid arguments provided" ;;
        "$ERR_PERMISSION_DENIED") echo "Permission denied" ;;
        "$ERR_NOT_FOUND") echo "Resource not found" ;;
        "$ERR_ALREADY_EXISTS") echo "Resource already exists" ;;
        "$ERR_OPERATION_CANCELLED") echo "Operation cancelled by user" ;;
        "$ERR_SYSTEM_ERROR") echo "System error occurred" ;;
        "$ERR_INSUFFICIENT_MEMORY") echo "Insufficient memory available" ;;
        "$ERR_INSUFFICIENT_DISK") echo "Insufficient disk space" ;;
        "$ERR_UNSUPPORTED_OS") echo "Unsupported operating system" ;;
        "$ERR_MISSING_DEPENDENCY") echo "Missing required dependency" ;;
        "$ERR_SYSTEM_INCOMPATIBLE") echo "System incompatible" ;;
        "$ERR_NETWORK_ERROR") echo "Network error occurred" ;;
        "$ERR_NETWORK_TIMEOUT") echo "Network operation timed out" ;;
        "$ERR_NETWORK_UNAVAILABLE") echo "Network unavailable" ;;
        "$ERR_DOWNLOAD_FAILED") echo "Download failed" ;;
        "$ERR_CONNECTION_REFUSED") echo "Connection refused" ;;
        "$ERR_FILE_ERROR") echo "File operation error" ;;
        "$ERR_FILE_NOT_FOUND") echo "File not found" ;;
        "$ERR_FILE_PERMISSION") echo "File permission error" ;;
        "$ERR_FILE_CORRUPTED") echo "File corrupted" ;;
        "$ERR_FILE_TOO_LARGE") echo "File too large" ;;
        "$ERR_FILE_IN_USE") echo "File in use" ;;
        "$ERR_DISK_FULL") echo "Disk full" ;;
        "$ERR_PROCESS_ERROR") echo "Process error occurred" ;;
        "$ERR_PROCESS_NOT_FOUND") echo "Process not found" ;;
        "$ERR_PROCESS_TERMINATION_FAILED") echo "Process termination failed" ;;
        "$ERR_PROCESS_TIMEOUT") echo "Process operation timed out" ;;
        "$ERR_PROCESS_PERMISSION") echo "Process permission error" ;;
        "$ERR_APP_ERROR") echo "Application error occurred" ;;
        "$ERR_APP_NOT_INSTALLED") echo "Application not installed" ;;
        "$ERR_APP_INSTALLATION_FAILED") echo "Application installation failed" ;;
        "$ERR_APP_REMOVAL_FAILED") echo "Application removal failed" ;;
        "$ERR_APP_CORRUPTED") echo "Application corrupted" ;;
        "$ERR_APP_INCOMPATIBLE") echo "Application incompatible" ;;
        "$ERR_SECURITY_ERROR") echo "Security error occurred" ;;
        "$ERR_SECURITY_VALIDATION_FAILED") echo "Security validation failed" ;;
        "$ERR_SECURITY_PATH_TRAVERSAL") echo "Path traversal attempt detected" ;;
        "$ERR_SECURITY_COMMAND_INJECTION") echo "Command injection attempt detected" ;;
        "$ERR_SECURITY_PRIVILEGE_ESCALATION") echo "Privilege escalation attempt detected" ;;
        "$ERR_VALIDATION_ERROR") echo "Validation error occurred" ;;
        "$ERR_VALIDATION_INPUT") echo "Input validation failed" ;;
        "$ERR_VALIDATION_CONFIG") echo "Configuration validation failed" ;;
        "$ERR_VALIDATION_DEPENDENCY") echo "Dependency validation failed" ;;
        "$ERR_VALIDATION_INTEGRITY") echo "Integrity validation failed" ;;
        "$ERR_MODULE_ERROR") echo "Module error occurred" ;;
        "$ERR_MODULE_LOAD_FAILED") echo "Module load failed" ;;
        "$ERR_MODULE_INIT_FAILED") echo "Module initialization failed" ;;
        "$ERR_MODULE_DEPENDENCY") echo "Module dependency error" ;;
        "$ERR_MODULE_COMPATIBILITY") echo "Module compatibility error" ;;
        "$ERR_CRITICAL_ERROR") echo "Critical error occurred" ;;
        "$ERR_CRITICAL_SYSTEM_FAILURE") echo "Critical system failure" ;;
        "$ERR_CRITICAL_DATA_LOSS") echo "Critical data loss" ;;
        "$ERR_CRITICAL_SECURITY_BREACH") echo "Critical security breach" ;;
        *) echo "Unknown error code: $error_code" ;;
    esac
}

# Function to log error with standardized format
log_error_with_code() {
    local error_code="$1"
    local context="${2:-}"
    local module="${3:-MAIN}"
    
    local description
    description=$(get_error_description "$error_code")
    
    local message="[ERROR $error_code] $description"
    if [[ -n "$context" ]]; then
        message="$message - $context"
    fi
    
    if declare -f log_with_level >/dev/null 2>&1; then
        log_with_level "ERROR" "$message" "$module"
    else
        printf '[ERROR] %s\n' "$message" >&2
    fi
}

# Function to exit with standardized error code
exit_with_error() {
    local error_code="$1"
    local context="${2:-}"
    local module="${3:-MAIN}"
    
    log_error_with_code "$error_code" "$context" "$module"
    exit "$error_code"
}

# Export all error codes and functions
export ERR_SUCCESS ERR_SUCCESS_WITH_WARNINGS
export ERR_GENERAL_ERROR ERR_INVALID_ARGUMENTS ERR_PERMISSION_DENIED ERR_NOT_FOUND ERR_ALREADY_EXISTS ERR_OPERATION_CANCELLED
export ERR_SYSTEM_ERROR ERR_INSUFFICIENT_MEMORY ERR_INSUFFICIENT_DISK ERR_UNSUPPORTED_OS ERR_MISSING_DEPENDENCY ERR_SYSTEM_INCOMPATIBLE
export ERR_NETWORK_ERROR ERR_NETWORK_TIMEOUT ERR_NETWORK_UNAVAILABLE ERR_DOWNLOAD_FAILED ERR_CONNECTION_REFUSED
export ERR_FILE_ERROR ERR_FILE_NOT_FOUND ERR_FILE_PERMISSION ERR_FILE_CORRUPTED ERR_FILE_TOO_LARGE ERR_FILE_IN_USE ERR_DISK_FULL
export ERR_PROCESS_ERROR ERR_PROCESS_NOT_FOUND ERR_PROCESS_TERMINATION_FAILED ERR_PROCESS_TIMEOUT ERR_PROCESS_PERMISSION
export ERR_APP_ERROR ERR_APP_NOT_INSTALLED ERR_APP_INSTALLATION_FAILED ERR_APP_REMOVAL_FAILED ERR_APP_CORRUPTED ERR_APP_INCOMPATIBLE
export ERR_SECURITY_ERROR ERR_SECURITY_VALIDATION_FAILED ERR_SECURITY_PATH_TRAVERSAL ERR_SECURITY_COMMAND_INJECTION ERR_SECURITY_PRIVILEGE_ESCALATION
export ERR_VALIDATION_ERROR ERR_VALIDATION_INPUT ERR_VALIDATION_CONFIG ERR_VALIDATION_DEPENDENCY ERR_VALIDATION_INTEGRITY
export ERR_MODULE_ERROR ERR_MODULE_LOAD_FAILED ERR_MODULE_INIT_FAILED ERR_MODULE_DEPENDENCY ERR_MODULE_COMPATIBILITY
export ERR_CRITICAL_ERROR ERR_CRITICAL_SYSTEM_FAILURE ERR_CRITICAL_DATA_LOSS ERR_CRITICAL_SECURITY_BREACH

export -f get_error_description log_error_with_code exit_with_error

# Module loaded successfully
readonly ERROR_CODES_LOADED=true
export ERROR_CODES_LOADED

if declare -f log_with_level >/dev/null 2>&1; then
    log_with_level "DEBUG" "Error codes module v$ERROR_CODES_VERSION loaded successfully"
fi 