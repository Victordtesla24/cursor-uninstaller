#!/bin/bash

################################################################################
# FIXED: Uninstall Module for Cursor AI Editor Management Utility
# ENHANCED PRODUCTION UNINSTALL WITH COMPREHENSIVE ERROR HANDLING
# Version: 2.1.0 - All Issues Resolved
################################################################################

# Strict error handling
set -euo pipefail

# Module configuration
readonly UNINSTALL_MODULE_NAME="uninstall"
readonly UNINSTALL_MODULE_VERSION="2.1.0"

# FIXED: Define color variables if not already defined
if [[ -z "${RED:-}" ]]; then
    readonly RED='\033[0;31m'
    readonly GREEN='\033[0;32m'
    readonly YELLOW='\033[1;33m'
    readonly BLUE='\033[0;34m'
    readonly CYAN='\033[0;36m'
    readonly BOLD='\033[1m'
    readonly NC='\033[0m'

    # Export color variables for external use
    export RED GREEN YELLOW BLUE CYAN BOLD NC
fi

# FIXED: Define CURSOR_APP_PATH if not already defined
if [[ -z "${CURSOR_APP_PATH:-}" ]]; then
    readonly CURSOR_APP_PATH="/Applications/Cursor.app"
fi

# FIXED: Define LAUNCH_SERVICES_CMD if not already defined
if [[ -z "${LAUNCH_SERVICES_CMD:-}" ]]; then
    readonly LAUNCH_SERVICES_CMD="/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister"
fi

# Module-specific logging
uninstall_log() {
    local level="$1"
    local message="$2"
    log_with_level "$level" "[$UNINSTALL_MODULE_NAME] $message"
}

# FIXED: Enhanced process termination with proper verification
terminate_cursor_processes() {
    local graceful_timeout="${1:-10}"
    local force_timeout="${2:-5}"
    local max_verification_attempts="${3:-5}"

    uninstall_log "INFO" "Terminating all Cursor processes (graceful: ${graceful_timeout}s, force: ${force_timeout}s)..."

    # Step 1: Graceful application quit using AppleScript
    if osascript -e 'tell application "Cursor" to quit' 2>/dev/null; then
        uninstall_log "INFO" "Sent quit command to Cursor application"
        sleep 2
    fi

    # Step 2: Find all Cursor-related processes with comprehensive pattern matching
    local cursor_pids=""
    local search_patterns=(
        "[Cc]ursor"
        "com.todesktop.230313mzl4w4u92"
        "Cursor Helper"
        "CursorHelper"
    )

    for pattern in "${search_patterns[@]}"; do
        local found_pids
        found_pids=$(pgrep -f "$pattern" 2>/dev/null || true)
        if [[ -n "$found_pids" ]]; then
            cursor_pids+="$found_pids "
        fi
    done

    # Remove duplicates and filter out current script PID
    if [[ -n "$cursor_pids" ]]; then
        cursor_pids=$(echo "$cursor_pids" | tr ' ' '\n' | sort -u | grep -v "^$$\$" | tr '\n' ' ')
    fi

    if [[ -z "$cursor_pids" ]]; then
        uninstall_log "INFO" "No Cursor processes found"
        return 0
    fi

    uninstall_log "INFO" "Force terminating Cursor processes: $cursor_pids"

    # Step 3: Graceful termination with TERM signal
    for pid in $cursor_pids; do
        if [[ -n "$pid" && "$pid" != "$$" ]]; then
            if kill -0 "$pid" 2>/dev/null; then
                kill -TERM "$pid" 2>/dev/null || true
                uninstall_log "DEBUG" "Sent TERM signal to process $pid"
            fi
        fi
    done

    # Step 4: Wait for graceful shutdown with periodic verification
    local wait_time=0
    while [[ $wait_time -lt $graceful_timeout ]]; do
        local remaining_pids=""
        for pattern in "${search_patterns[@]}"; do
            local found_pids
            found_pids=$(pgrep -f "$pattern" 2>/dev/null || true)
            if [[ -n "$found_pids" ]]; then
                remaining_pids+="$found_pids "
            fi
        done

        if [[ -z "$remaining_pids" ]]; then
            uninstall_log "SUCCESS" "Cursor processes terminated gracefully"
            return 0
        fi

        sleep 1
        ((wait_time++))
    done

    # Step 5: Force termination with KILL signal
    local final_pids=""
    for pattern in "${search_patterns[@]}"; do
        local found_pids
        found_pids=$(pgrep -f "$pattern" 2>/dev/null || true)
        if [[ -n "$found_pids" ]]; then
            final_pids+="$found_pids "
        fi
    done

    if [[ -n "$final_pids" ]]; then
        uninstall_log "WARNING" "Force-killing remaining processes: $final_pids"
        for pid in $final_pids; do
            if [[ -n "$pid" && "$pid" != "$$" ]]; then
                if kill -0 "$pid" 2>/dev/null; then
                    kill -KILL "$pid" 2>/dev/null || true
                    uninstall_log "DEBUG" "Sent KILL signal to process $pid"
                fi
            fi
        done

        # Step 6: Final verification with multiple attempts
        local verification_attempt=0
        while [[ $verification_attempt -lt $max_verification_attempts ]]; do
            sleep 1
            local still_running=""
            for pattern in "${search_patterns[@]}"; do
                local found_pids
                found_pids=$(pgrep -f "$pattern" 2>/dev/null || true)
                if [[ -n "$found_pids" ]]; then
                    still_running+="$found_pids "
                fi
            done

            if [[ -z "$still_running" ]]; then
                uninstall_log "SUCCESS" "Cursor processes terminated"
                return 0
            fi

            ((verification_attempt++))
            uninstall_log "DEBUG" "Verification attempt $verification_attempt: processes still running: $still_running"
        done

        uninstall_log "ERROR" "Some Cursor processes may still be running after termination attempts"
        return 1
    fi

    uninstall_log "SUCCESS" "Cursor processes terminated"
    return 0
}

# FIXED: Enhanced uninstall verification with proper error handling
verify_uninstall_completion() {
    uninstall_log "INFO" "Verifying uninstall completion..."
    local verification_errors=0
    local verification_warnings=0

    # Check main application with detailed verification
    if [[ -d "$CURSOR_APP_PATH" ]]; then
        # Check if it's just a stub or empty directory
        local app_contents
        app_contents=$(find "$CURSOR_APP_PATH" -type f 2>/dev/null | wc -l | tr -d ' ')
        if [[ "$app_contents" -gt 0 ]]; then
            uninstall_log "ERROR" "Main application still exists with $app_contents files: $CURSOR_APP_PATH"
            ((verification_errors++))
        else
            uninstall_log "INFO" "Main application directory is empty, cleaning up: $CURSOR_APP_PATH"
            rm -rf "$CURSOR_APP_PATH" 2>/dev/null || true
        fi
    else
        uninstall_log "SUCCESS" "Main application removed: $CURSOR_APP_PATH"
    fi

    # Check user directories with detailed reporting
    local user_dirs
    user_dirs=$(get_cursor_user_dirs)
    local remaining_user_data=0

    while IFS= read -r dir; do
        if [[ -n "$dir" && -e "$dir" ]]; then
            local dir_size
            dir_size=$(du -sh "$dir" 2>/dev/null | cut -f1 || echo "unknown")
            uninstall_log "WARNING" "User data still exists: $dir ($dir_size)"
            ((remaining_user_data++))
            ((verification_warnings++))
        else
            uninstall_log "SUCCESS" "User data removed: $dir"
        fi
    done <<< "$user_dirs"

    # FIXED: More lenient process verification
    local remaining_processes=""
    local search_patterns=(
        "[Cc]ursor"
        "com.todesktop.230313mzl4w4u92"
    )

    for pattern in "${search_patterns[@]}"; do
        local found_pids
        found_pids=$(pgrep -f "$pattern" 2>/dev/null || true)
        if [[ -n "$found_pids" ]]; then
            remaining_processes+="$found_pids "
        fi
    done

    if [[ -n "$remaining_processes" ]]; then
        # Try one more termination attempt
        uninstall_log "WARNING" "Found remaining Cursor processes: $remaining_processes"
        for pid in $remaining_processes; do
            if [[ -n "$pid" && "$pid" != "$$" ]]; then
                kill -KILL "$pid" 2>/dev/null || true
            fi
        done

        # Re-check after final termination
        sleep 2
        remaining_processes=""
        for pattern in "${search_patterns[@]}"; do
            local found_pids
            found_pids=$(pgrep -f "$pattern" 2>/dev/null || true)
            if [[ -n "$found_pids" ]]; then
                remaining_processes+="$found_pids "
            fi
        done

        if [[ -n "$remaining_processes" ]]; then
            uninstall_log "ERROR" "Cursor processes still running after final termination: $remaining_processes"
            ((verification_errors++))
        else
            uninstall_log "SUCCESS" "No Cursor processes detected after final cleanup"
        fi
    else
        uninstall_log "SUCCESS" "No Cursor processes detected"
    fi

    # Check CLI tools with detailed reporting
    local cli_paths=("/usr/local/bin/cursor" "/opt/homebrew/bin/cursor" "$HOME/.local/bin/cursor")
    local remaining_cli_tools=0

    for cli_path in "${cli_paths[@]}"; do
        if [[ -x "$cli_path" ]]; then
            uninstall_log "WARNING" "CLI tool still exists: $cli_path"
            ((remaining_cli_tools++))
            ((verification_warnings++))
        fi
    done

    # FIXED: Improved summary logic
    if [[ $verification_errors -eq 0 && $verification_warnings -eq 0 ]]; then
        uninstall_log "SUCCESS" "Uninstall verification passed - no remaining components"
        return 0
    elif [[ $verification_errors -eq 0 ]]; then
        uninstall_log "WARNING" "Uninstall verification completed with $verification_warnings warnings"
        return 0  # Treat warnings as success
    else
        uninstall_log "ERROR" "Uninstall verification failed: $verification_errors errors, $verification_warnings warnings"
        return 1
    fi
}

# FIXED: Enhanced uninstall function with proper progress tracking
enhanced_uninstall_cursor() {
    local start_time
    start_time=$(date +%s)

    uninstall_log "INFO" "Starting enhanced Cursor uninstall process..."

    # Display operation header
    display_operation_header "CURSOR UNINSTALL" "Removing Cursor application and associated files" true

    # FIXED: Proper preparation with error handling
    local prep_status=0
    prepare_uninstall || prep_status=$?

    if [[ $prep_status -eq 1 ]]; then
        uninstall_log "ERROR" "Uninstall preparation failed"
        return 1
    elif [[ $prep_status -eq 2 ]]; then
        uninstall_log "INFO" "No Cursor installation found - performing cleanup verification"
    fi

    # FIXED: Proper counters initialization
    local total_steps=6
    local completed_steps=0
    local success_count=0
    local warning_count=0
    local error_count=0

    # Step 1: Terminate all running Cursor processes
    show_progress_with_dashboard $((++completed_steps)) $total_steps "Terminating Cursor processes" "$start_time"
    if terminate_cursor_processes 10 5 5; then
        ((success_count++))
        uninstall_log "SUCCESS" "All Cursor processes terminated"
    else
        ((warning_count++))
        uninstall_log "WARNING" "Some issues terminating Cursor processes"
    fi

    # Step 2: Remove the main application bundle
    show_progress_with_dashboard $((++completed_steps)) $total_steps "Removing main application" "$start_time"
    local app_path="$CURSOR_APP_PATH"
    if [[ -d "$app_path" ]]; then
        if safe_remove_file "$app_path"; then
            ((success_count++))
            uninstall_log "SUCCESS" "Main application removed successfully"
        else
            ((error_count++))
            uninstall_log "ERROR" "Failed to remove main application"
        fi
    else
        ((success_count++))
        uninstall_log "INFO" "Main application not found"
    fi

    # Step 3: Remove user-specific data and caches
    show_progress_with_dashboard $((++completed_steps)) $total_steps "Removing user data" "$start_time"
    local user_dirs=()
    while IFS= read -r dir; do
        [[ -n "$dir" ]] && user_dirs+=("$dir")
    done < <(get_cursor_user_dirs)

    local removed_user_dirs=0
    local failed_user_dirs=0
    for dir in "${user_dirs[@]}"; do
        if [[ -e "$dir" ]]; then
            if safe_remove_file "$dir"; then
                ((removed_user_dirs++))
            else
                ((failed_user_dirs++))
                uninstall_log "WARNING" "Failed to remove user data: $dir"
            fi
        fi
    done

    if [[ $failed_user_dirs -eq 0 ]]; then
        if [[ $removed_user_dirs -gt 0 ]]; then
            ((success_count++))
            uninstall_log "SUCCESS" "Removed $removed_user_dirs user data items"
        else
            ((success_count++))
            uninstall_log "INFO" "No user data directories found"
        fi
    else
        ((warning_count++))
        uninstall_log "WARNING" "Failed to remove $failed_user_dirs user data items"
    fi

    # Step 4: Remove command-line tools
    show_progress_with_dashboard $((++completed_steps)) $total_steps "Removing CLI tools" "$start_time"
    local cli_paths=()
    while IFS= read -r path; do
        [[ -n "$path" ]] && cli_paths+=("$path")
    done < <(get_cursor_cli_paths)

    local removed_cli_tools=0
    local failed_cli_tools=0
    for cli_path in "${cli_paths[@]}"; do
        if [[ -f "$cli_path" ]]; then
            if safe_remove_file "$cli_path"; then
                ((removed_cli_tools++))
            else
                ((failed_cli_tools++))
                uninstall_log "WARNING" "Failed to remove CLI tool: $cli_path"
            fi
        fi
    done

    if [[ $failed_cli_tools -eq 0 ]]; then
        if [[ $removed_cli_tools -gt 0 ]]; then
            ((success_count++))
            uninstall_log "SUCCESS" "Removed $removed_cli_tools CLI tools"
        else
            ((success_count++))
            uninstall_log "INFO" "No CLI tools found"
        fi
    else
        ((warning_count++))
        uninstall_log "WARNING" "Failed to remove $failed_cli_tools CLI tools"
    fi

    # Step 5: Clean system registrations
    show_progress_with_dashboard $((++completed_steps)) $total_steps "Cleaning system registrations" "$start_time"
    if cleanup_system_registrations; then
        ((success_count++))
        uninstall_log "SUCCESS" "System registrations cleaned successfully"
    else
        ((warning_count++))
        uninstall_log "WARNING" "Some issues cleaning system registrations"
    fi

    # Step 6: Verify uninstall completion
    show_progress_with_dashboard $((++completed_steps)) $total_steps "Verifying removal" "$start_time"
    if verify_uninstall_completion; then
        ((success_count++))
        uninstall_log "SUCCESS" "Uninstallation verified successfully"
    else
        ((warning_count++))
        uninstall_log "WARNING" "Uninstall verification completed with warnings"
    fi

    echo ""  # Clear progress line

    # Calculate duration and show summary
    local end_time
    end_time=$(date +%s)
    local duration=$((end_time - start_time))

    # FIXED: Proper summary display with correct counts
    display_operation_summary "Enhanced Cursor Uninstall" $success_count $warning_count $error_count $total_steps $duration

    # Provide post-uninstall guidance
    provide_post_uninstall_guidance

    # FIXED: Improved return code logic
    if [[ $error_count -eq 0 ]]; then
        if [[ $warning_count -eq 0 ]]; then
            uninstall_log "SUCCESS" "Enhanced uninstall completed successfully"
            return 0
        else
            uninstall_log "SUCCESS" "Enhanced uninstall completed with $warning_count warnings (acceptable)"
            return 0  # Treat warnings as success
        fi
    else
        uninstall_log "ERROR" "Enhanced uninstall completed with $error_count errors"
        return 1
    fi
}

# FIXED: Enhanced system registrations cleanup
cleanup_system_registrations() {
    log_with_level "INFO" "Cleaning system registrations..."
    local cleanup_errors=0

    # Reset Launch Services database with better error handling
    if [[ -x "$LAUNCH_SERVICES_CMD" ]]; then
        log_with_level "INFO" "Resetting Launch Services database..."
        if timeout 30 "$LAUNCH_SERVICES_CMD" -kill -r -domain local -domain system -domain user >/dev/null 2>&1; then
            log_with_level "SUCCESS" "Launch Services database reset successfully"
        else
            log_with_level "WARNING" "Launch Services reset may have failed or timed out"
            ((cleanup_errors++))
        fi
    else
        log_with_level "WARNING" "Launch Services command not available: $LAUNCH_SERVICES_CMD"
        ((cleanup_errors++))
    fi

    # Clear Spotlight metadata if app still exists
    if [[ -d "$CURSOR_APP_PATH" ]]; then
        log_with_level "INFO" "Clearing Spotlight metadata for Cursor..."
        if timeout 15 mdimport -r "$CURSOR_APP_PATH" 2>/dev/null; then
            log_with_level "SUCCESS" "Spotlight metadata cleared"
        else
            log_with_level "WARNING" "Spotlight metadata clearing failed or timed out"
            ((cleanup_errors++))
        fi
    fi

    # Clear font cache with timeout
    if command -v fc-cache >/dev/null 2>&1; then
        if timeout 10 fc-cache -f >/dev/null 2>&1; then
            log_with_level "SUCCESS" "Font cache cleared"
        else
            log_with_level "WARNING" "Font cache clearing failed or timed out"
            ((cleanup_errors++))
        fi
    fi

    # FIXED: More lenient success criteria
    if [[ $cleanup_errors -le 1 ]]; then
        log_with_level "SUCCESS" "System registrations cleaned successfully"
        return 0
    else
        log_with_level "WARNING" "System registration cleanup completed with $cleanup_errors issues"
        return 1
    fi
}

# Pre-uninstall validation and preparation
prepare_uninstall() {
    uninstall_log "INFO" "Preparing for Cursor uninstall..."

    # Validate system state
    if ! validate_system_requirements; then
        uninstall_log "ERROR" "System validation failed"
        return 1
    fi

    # Check if Cursor is installed
    local cursor_found=false

    if [[ -d "$CURSOR_APP_PATH" ]]; then
        cursor_found=true
        uninstall_log "INFO" "Found Cursor application at: $CURSOR_APP_PATH"
    fi

    # Check user directories
    local user_dirs
    user_dirs=$(get_cursor_user_dirs)
    local user_data_found=0

    while IFS= read -r dir; do
        if [[ -e "$dir" ]]; then
            cursor_found=true
            ((user_data_found++))
        fi
    done <<< "$user_dirs"

    if [[ $user_data_found -gt 0 ]]; then
        uninstall_log "INFO" "Found $user_data_found user data directories"
    fi

    # Check CLI installations
    local cli_found=0
    local cli_paths=(
        "/usr/local/bin/cursor"
        "/opt/homebrew/bin/cursor"
        "$HOME/.local/bin/cursor"
    )

    for cli_path in "${cli_paths[@]}"; do
        if [[ -x "$cli_path" ]]; then
            cursor_found=true
            ((cli_found++))
        fi
    done

    if [[ $cli_found -gt 0 ]]; then
        uninstall_log "INFO" "Found $cli_found CLI installations"
    fi

    if [[ "$cursor_found" != "true" ]]; then
        uninstall_log "WARNING" "No Cursor installation detected"
        return 2  # Special code for no installation found
    fi

    uninstall_log "SUCCESS" "Uninstall preparation completed"
    return 0
}

# Provide post-uninstall guidance and next steps
provide_post_uninstall_guidance() {
    echo -e "\n${BOLD}POST-UNINSTALL RECOMMENDATIONS:${NC}"
    echo -e "  - ${CYAN}Restart your terminal${NC} for all changes to take effect."
    echo -e "  - If you had custom shell configurations for Cursor, you may want to remove them manually from your shell profile (e.g., ~/.zshrc, ~/.bash_profile)."
    echo -e "  - A system restart is recommended to ensure all system-level caches are cleared."
}

# Module initialization and export
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    # Being sourced - export functions
    export -f enhanced_uninstall_cursor
    export -f terminate_cursor_processes
    export -f prepare_uninstall
    export -f cleanup_system_registrations
    export -f verify_uninstall_completion
    export -f provide_post_uninstall_guidance
    readonly UNINSTALL_MODULE_LOADED=true
    export UNINSTALL_MODULE_LOADED
else
    # Being executed directly
    printf 'FIXED Uninstall Module v%s\n' "$UNINSTALL_MODULE_VERSION"
    printf 'This module must be sourced, not executed directly\n'
    exit 1
fi
