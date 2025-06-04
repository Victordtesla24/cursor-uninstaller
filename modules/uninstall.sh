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
    
    # Step 1: Process termination
    show_progress $((++completed_steps)) $total_steps "Terminating Cursor processes"
    if terminate_cursor_processes 10 5 3; then
        uninstall_log "SUCCESS" "Cursor processes terminated successfully"
        ((success_count++))
    else
        uninstall_log "WARNING" "Some processes may still be running"
        ((warning_count++))
    fi
    
    # Step 2: Remove main application
    show_progress $((++completed_steps)) $total_steps "Removing main application"
    if [[ -d "$CURSOR_APP_PATH" ]]; then
        local app_size
        app_size=$(du -sh "$CURSOR_APP_PATH" 2>/dev/null | cut -f1 || echo "unknown")
        uninstall_log "INFO" "Removing Cursor.app ($app_size)..."
        
        if safe_remove_file "$CURSOR_APP_PATH" true true; then
            uninstall_log "SUCCESS" "Cursor application removed successfully"
            ((success_count++))
        else
            uninstall_log "ERROR" "Failed to remove Cursor application"
            ((error_count++))
        fi
    else
        uninstall_log "INFO" "Cursor application not found"
        ((success_count++))
    fi
    
    # Step 3: Remove user data directories
    show_progress $((++completed_steps)) $total_steps "Removing user data"
    local user_dirs
    user_dirs=$(get_cursor_user_dirs)
    local user_data_errors=0
    local user_data_removed=0
    
    while read -r dir; do
        if [[ -e "$dir" ]]; then
            local dir_size
            dir_size=$(du -sh "$dir" 2>/dev/null | cut -f1 || echo "unknown")
            uninstall_log "INFO" "Removing user data: $dir ($dir_size)"
            
            if safe_remove_file "$dir" true true; then
                uninstall_log "SUCCESS" "Removed: $dir"
                ((user_data_removed++))
            else
                uninstall_log "ERROR" "Failed to remove: $dir"
                ((user_data_errors++))
            fi
        fi
    done <<< "$user_dirs"
    
    if [[ $user_data_errors -eq 0 ]]; then
        if [[ $user_data_removed -gt 0 ]]; then
            uninstall_log "SUCCESS" "All user data removed ($user_data_removed directories)"
        else
            uninstall_log "INFO" "No user data found"
        fi
        ((success_count++))
    else
        uninstall_log "WARNING" "Some user data could not be removed ($user_data_errors errors)"
        ((warning_count++))
    fi
    
    # Step 4: Remove CLI tools
    show_progress $((++completed_steps)) $total_steps "Removing CLI tools"
    local cli_errors=0
    local cli_removed=0
    
    # Define CLI paths locally for Bash 3.2 compatibility
    local cli_paths=(
        "/usr/local/bin/cursor"
        "/opt/homebrew/bin/cursor"
        "$HOME/.local/bin/cursor"
    )
    
    for cli_path in "${cli_paths[@]}"; do
        if [[ -x "$cli_path" ]]; then
            uninstall_log "INFO" "Removing CLI tool: $cli_path"
            
            if safe_remove_file "$cli_path" true true; then
                uninstall_log "SUCCESS" "Removed CLI tool: $cli_path"
                ((cli_removed++))
            else
                uninstall_log "ERROR" "Failed to remove CLI tool: $cli_path"
                ((cli_errors++))
            fi
        fi
    done
    
    if [[ $cli_errors -eq 0 ]]; then
        if [[ $cli_removed -gt 0 ]]; then
            uninstall_log "SUCCESS" "All CLI tools removed ($cli_removed tools)"
        else
            uninstall_log "INFO" "No CLI tools found"
        fi
        ((success_count++))
    else
        uninstall_log "WARNING" "Some CLI tools could not be removed ($cli_errors errors)"
        ((warning_count++))
    fi
    
    # Step 5: Clean system registrations
    show_progress $((++completed_steps)) $total_steps "Cleaning system registrations"
    if cleanup_system_registrations; then
        uninstall_log "SUCCESS" "System registrations cleaned"
        ((success_count++))
    else
        uninstall_log "WARNING" "System registration cleanup had issues"
        ((warning_count++))
    fi
    
    # Step 6: Verify removal
    show_progress $((++completed_steps)) $total_steps "Verifying removal"
    if verify_uninstall_completion; then
        uninstall_log "SUCCESS" "Uninstall verification passed"
        ((success_count++))
    else
        uninstall_log "WARNING" "Some components may still remain"
        ((warning_count++))
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
    elif [[ $error_count -eq 0 ]]; then
        uninstall_log "INFO" "Enhanced uninstall completed with $warning_count warnings"
        return 0
    elif [[ $error_count -le 2 ]]; then
        uninstall_log "WARNING" "Enhanced uninstall completed with $error_count minor errors"
        return 0
    else
        uninstall_log "ERROR" "Enhanced uninstall completed with $error_count significant errors"
        return 1
    fi
}

# Clean system registrations and caches
cleanup_system_registrations() {
    uninstall_log "INFO" "Cleaning system registrations..."
    
    local cleanup_success=true
    
    # Reset Launch Services database
    if [[ -x "$LAUNCH_SERVICES_CMD" ]]; then
        uninstall_log "INFO" "Resetting Launch Services database..."
        if "$LAUNCH_SERVICES_CMD" -kill -r -domain local -domain system -domain user >/dev/null 2>&1; then
            uninstall_log "SUCCESS" "Launch Services database reset"
        else
            uninstall_log "WARNING" "Launch Services reset failed"
            cleanup_success=false
        fi
    else
        uninstall_log "WARNING" "Launch Services command not available"
        cleanup_success=false
    fi
    
    # Clear Spotlight metadata for Cursor
    uninstall_log "INFO" "Clearing Spotlight metadata..."
    if mdimport -r "$CURSOR_APP_PATH" 2>/dev/null || timeout 10 sudo mdutil -E / >/dev/null 2>&1; then
        uninstall_log "SUCCESS" "Spotlight metadata cleared"
    else
        uninstall_log "WARNING" "Spotlight metadata clearing failed"
        cleanup_success=false
    fi
    
    # Clear system font cache if Cursor installed fonts
    if fc-cache -f >/dev/null 2>&1; then
        uninstall_log "SUCCESS" "Font cache cleared"
    else
        uninstall_log "DEBUG" "Font cache clearing skipped (fc-cache not available)"
    fi
    
    if [[ "$cleanup_success" = true ]]; then
        return 0
    else
        return 1
    fi
}

# Verify that uninstall completed successfully
verify_uninstall_completion() {
    uninstall_log "INFO" "Verifying uninstall completion..."
    
    local verification_issues=0
    
    # Check main application
    if [[ -d "$CURSOR_APP_PATH" ]]; then
        uninstall_log "WARNING" "Main application still exists: $CURSOR_APP_PATH"
        ((verification_issues++))
    fi
    
    # Check user directories
    local user_dirs
    user_dirs=$(get_cursor_user_dirs)
    
    while read -r dir; do
        if [[ -e "$dir" ]]; then
            uninstall_log "WARNING" "User data still exists: $dir"
            ((verification_issues++))
        fi
    done <<< "$user_dirs"
    
    # Check CLI tools
    # Define CLI paths locally for Bash 3.2 compatibility
    local cli_paths=(
        "/usr/local/bin/cursor"
        "/opt/homebrew/bin/cursor"
        "$HOME/.local/bin/cursor"
    )
    
    for cli_path in "${cli_paths[@]}"; do
        if [[ -x "$cli_path" ]]; then
            uninstall_log "WARNING" "CLI tool still exists: $cli_path"
            ((verification_issues++))
        fi
    done
    
    # Quick process check
    if check_cursor_processes >/dev/null 2>&1; then
        uninstall_log "WARNING" "Cursor processes are still running"
        ((verification_issues++))
    fi
    
    if [[ $verification_issues -eq 0 ]]; then
        uninstall_log "SUCCESS" "Uninstall verification passed - no remaining components found"
        return 0
    else
        uninstall_log "WARNING" "Uninstall verification found $verification_issues remaining items"
        return 1
    fi
}

# Provide helpful post-uninstall guidance
provide_post_uninstall_guidance() {
    uninstall_log "INFO" "📋 POST-UNINSTALL INFORMATION"
    uninstall_log "INFO" "═══════════════════════════════════════════════"
    
    uninstall_log "INFO" "What was removed:"
    uninstall_log "INFO" "• Cursor application bundle"
    uninstall_log "INFO" "• User preferences and settings"
    uninstall_log "INFO" "• Application caches and temporary files"
    uninstall_log "INFO" "• CLI tools and system integrations"
    uninstall_log "INFO" "• Launch Services registrations"
    
    uninstall_log "INFO" "Additional cleanup (optional):"
    uninstall_log "INFO" "• Check Keychain Access for any saved Cursor passwords"
    uninstall_log "INFO" "• Review browser bookmarks for Cursor-related sites"
    uninstall_log "INFO" "• Clear any custom aliases or PATH modifications"
    
    uninstall_log "INFO" "Reinstallation:"
    uninstall_log "INFO" "• Download fresh copy from: https://cursor.sh"
    uninstall_log "INFO" "• Previous settings will not be restored automatically"
    uninstall_log "INFO" "• Extensions and customizations will need to be reconfigured"
    
    if command -v curl >/dev/null 2>&1 || command -v wget >/dev/null 2>&1; then
        uninstall_log "INFO" "💡 Consider upgrading to the latest version when reinstalling"
    fi
}

# Module initialization
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    # Being sourced, export functions
    export -f enhanced_uninstall_cursor
    export -f cleanup_system_registrations
    export -f verify_uninstall_completion
    export UNINSTALL_LOADED=true
    uninstall_log "DEBUG" "Enhanced uninstall module loaded successfully"
else
    # Being executed directly
    echo "Enhanced Uninstall Module v$UNINSTALL_MODULE_VERSION"
    echo "This module must be sourced, not executed directly"
    exit 1
fi 