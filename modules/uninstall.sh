#!/bin/bash

################################################################################
# Uninstall Module for Cursor AI Editor Management Utility
# ENHANCED PRODUCTION UNINSTALL WITH COMPREHENSIVE ERROR HANDLING
################################################################################

# Strict error handling
set -euo pipefail

# Module configuration
readonly UNINSTALL_MODULE_NAME="uninstall"
readonly UNINSTALL_MODULE_VERSION="2.0.0"

# Module-specific logging
uninstall_log() {
    local level="$1"
    local message="$2"
    log_with_level "$level" "[$UNINSTALL_MODULE_NAME] $message"
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

    while read -r dir; do
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
    # Define CLI paths locally for Bash 3.2 compatibility
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

# Enhanced uninstall function with comprehensive tracking
enhanced_uninstall_cursor() {
    local start_time
    start_time=$(date +%s)

    uninstall_log "INFO" "Starting enhanced Cursor uninstall process..."

    # Display operation header
    display_operation_header "CURSOR UNINSTALL" "Removing Cursor application and associated files" true

    # Prepare for uninstall
    local prep_status=0
    prepare_uninstall || prep_status=$?

    if [[ $prep_status -eq 1 ]]; then
        uninstall_log "ERROR" "Uninstall preparation failed"
        return 1
    elif [[ $prep_status -eq 2 ]]; then
        uninstall_log "INFO" "No Cursor installation found - performing cleanup verification"
    fi

    # Initialize counters for tracking
    local total_steps=6
    local completed_steps=0
    local success_count=0
    local warning_count=0
    local error_count=0

    # Step 1: Terminate all running Cursor processes
    show_progress_with_dashboard $((++completed_steps)) $total_steps "Terminating Cursor processes" "$start_time"
    if ! smart_retry_with_backoff terminate_cursor_processes; then
        ((warning_count++))
        uninstall_log "WARNING" "Failed to terminate all Cursor processes after multiple attempts. Manual intervention may be required."
    else
        uninstall_log "SUCCESS" "All Cursor processes terminated"
    fi

    # Step 2: Remove the main application bundle
    show_progress_with_dashboard $((++completed_steps)) $total_steps "Removing main application" "$start_time"
    local app_path="/Applications/Cursor.app"
    if [[ -d "$app_path" ]]; then
        if rm -rf "$app_path"; then
            uninstall_log "SUCCESS" "Main application removed successfully"
        else
            ((error_count++))
            uninstall_log "ERROR" "Failed to remove main application"
        fi
    else
        uninstall_log "INFO" "Main application not found"
    fi

    # Step 3: Remove user-specific data and caches
    show_progress_with_dashboard $((++completed_steps)) $total_steps "Removing user data" "$start_time"
    local user_dirs=()
    while IFS= read -r dir; do
        [[ -n "$dir" ]] && user_dirs+=("$dir")
    done < <(get_cursor_user_dirs)

    local -i removed_user_dirs=0
    for dir in "${user_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            if rm -rf "$dir"; then
                ((removed_user_dirs++))
            else
                ((warning_count++))
                uninstall_log "WARNING" "Failed to remove user data directory: $dir"
            fi
        elif [[ -f "$dir" ]]; then
            if rm -f "$dir"; then
                ((removed_user_dirs++))
            else
                ((warning_count++))
                uninstall_log "WARNING" "Failed to remove user data file: $dir"
            fi
        fi
    done
    if [[ $removed_user_dirs -gt 0 ]]; then
        uninstall_log "SUCCESS" "Removed $removed_user_dirs user data items"
    else
        uninstall_log "INFO" "No user data directories found"
    fi

    # Step 4: Remove command-line tools
    show_progress_with_dashboard $((++completed_steps)) $total_steps "Removing CLI tools" "$start_time"
    local cli_paths=()
    while IFS= read -r path; do
        [[ -n "$path" ]] && cli_paths+=("$path")
    done < <(get_cursor_cli_paths)

    local -i removed_cli_tools=0
    for cli_path in "${cli_paths[@]}"; do
        if [[ -f "$cli_path" ]]; then
            if rm -f "$cli_path"; then
                ((removed_cli_tools++))
            else
                ((warning_count++))
                uninstall_log "WARNING" "Failed to remove CLI tool: $cli_path"
            fi
        fi
    done
    if [[ $removed_cli_tools -gt 0 ]]; then
        uninstall_log "SUCCESS" "Removed $removed_cli_tools CLI tools"
    else
        uninstall_log "INFO" "No CLI tools found"
    fi

    # Step 5: Clean system registrations
    show_progress_with_dashboard $((++completed_steps)) $total_steps "Cleaning system registrations" "$start_time"
    if cleanup_system_registrations; then
        uninstall_log "SUCCESS" "System registrations cleaned successfully"
    else
        ((warning_count++))
        uninstall_log "WARNING" "Failed to clean all system registrations"
    fi

    # Step 6: Verify uninstall completion
    show_progress_with_dashboard $((++completed_steps)) $total_steps "Verifying removal" "$start_time"
    if verify_uninstall_completion; then
        uninstall_log "SUCCESS" "Uninstallation verified successfully"
    else
        ((warning_count++))
        uninstall_log "WARNING" "Uninstall verification failed"
    fi

    echo ""  # Clear progress line

    # Calculate duration and show summary
    local end_time
    end_time=$(date +%s)
    local duration=$((end_time - start_time))

    display_operation_summary "Enhanced Cursor Uninstall" $success_count $warning_count $error_count $total_steps $duration

    # Provide post-uninstall guidance
    provide_post_uninstall_guidance

    # Determine return code based on results
    if [[ $error_count -eq 0 && $warning_count -eq 0 ]]; then
        uninstall_log "SUCCESS" "Enhanced uninstall completed successfully"
        return 0
    elif [[ $error_count -gt 0 ]]; then
        uninstall_log "ERROR" "Enhanced uninstall completed with $error_count errors"
        return 1
    else
        uninstall_log "WARNING" "Enhanced uninstall completed with $warning_count warnings"
        return 2
    fi
}

# Function to clean system registrations (e.g., Launch Services)
cleanup_system_registrations() {
    log_with_level "INFO" "Cleaning system registrations..."
    local cleanup_errors=0

    # Reset Launch Services database
    if [[ -x "$LAUNCH_SERVICES_CMD" ]]; then
        log_with_level "INFO" "Resetting Launch Services database..."
        if "$LAUNCH_SERVICES_CMD" -kill -r -domain local -domain system -domain user >/dev/null 2>&1; then
            log_with_level "SUCCESS" "Launch Services database reset successfully"
        else
            log_with_level "ERROR" "Failed to reset Launch Services database"
            ((cleanup_errors++))
        fi
    else
        log_with_level "WARNING" "Launch Services command not available: $LAUNCH_SERVICES_CMD"
        ((cleanup_errors++))
    fi

    # Clear Spotlight metadata
    if [[ -d "$CURSOR_APP_PATH" ]]; then
        log_with_level "INFO" "Clearing Spotlight metadata for Cursor..."
        if mdimport -r "$CURSOR_APP_PATH" 2>/dev/null; then
            log_with_level "SUCCESS" "Spotlight metadata cleared"
        else
            log_with_level "WARNING" "Failed to clear Spotlight metadata"
            ((cleanup_errors++))
        fi
    fi

    # Clear font cache if needed
    if command -v fc-cache >/dev/null 2>&1; then
        if fc-cache -f >/dev/null 2>&1; then
            log_with_level "SUCCESS" "Font cache cleared"
        else
            log_with_level "WARNING" "Failed to clear font cache"
            ((cleanup_errors++))
        fi
    fi

    if [[ $cleanup_errors -eq 0 ]]; then
        log_with_level "SUCCESS" "System registrations cleaned successfully"
        return 0
    else
        log_with_level "WARNING" "System registration cleanup completed with $cleanup_errors errors"
        return 1
    fi
}

# Verify uninstall completion
verify_uninstall_completion() {
    uninstall_log "INFO" "Verifying uninstall completion..."
    local verification_errors=0

    # Check main application
    if [[ -d "$CURSOR_APP_PATH" ]]; then
        uninstall_log "ERROR" "Main application still exists: $CURSOR_APP_PATH"
        ((verification_errors++))
    else
        uninstall_log "SUCCESS" "Main application removed: $CURSOR_APP_PATH"
    fi

    # Check user directories
    local user_dirs
    user_dirs=$(get_cursor_user_dirs)
    while IFS= read -r dir; do
        if [[ -e "$dir" ]]; then
            uninstall_log "WARNING" "User data still exists: $dir"
            ((verification_errors++))
        else
            uninstall_log "SUCCESS" "User data removed: $dir"
        fi
    done <<< "$user_dirs"

    # Check processes
    if pgrep -f "[Cc]ursor" >/dev/null 2>&1; then
        uninstall_log "ERROR" "Cursor processes still running"
        ((verification_errors++))
    else
        uninstall_log "SUCCESS" "No Cursor processes detected"
    fi

    # Check CLI tools
    local cli_paths=("/usr/local/bin/cursor" "/opt/homebrew/bin/cursor" "$HOME/.local/bin/cursor")
    for cli_path in "${cli_paths[@]}"; do
        if [[ -x "$cli_path" ]]; then
            uninstall_log "WARNING" "CLI tool still exists: $cli_path"
            ((verification_errors++))
        fi
    done

    if [[ $verification_errors -eq 0 ]]; then
        uninstall_log "SUCCESS" "Uninstall verification passed - no remaining components"
        return 0
    else
        uninstall_log "WARNING" "Uninstall verification found $verification_errors remaining items"
        return 1
    fi
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
    export -f prepare_uninstall
    export -f cleanup_system_registrations
    export -f verify_uninstall_completion
    export -f provide_post_uninstall_guidance
    readonly UNINSTALL_MODULE_LOADED=true
    export UNINSTALL_MODULE_LOADED
else
    # Being executed directly
    printf 'Uninstall Module v%s\n' "$UNINSTALL_MODULE_VERSION"
    printf 'This module must be sourced, not executed directly\n'
    exit 1
fi