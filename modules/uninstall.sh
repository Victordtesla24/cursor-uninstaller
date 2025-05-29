#!/bin/bash

################################################################################
# Basic Uninstall Module - PRODUCTION GRADE Cursor Removal
# Standard uninstallation functions for Cursor AI Editor
################################################################################

# Prevent multiple loading
if [[ "${UNINSTALL_LOADED:-}" == "true" ]]; then
    return 0
fi

################################################################################
# Core Uninstall Functions
################################################################################

# Enhanced Cursor uninstallation with comprehensive cleanup
enhanced_uninstall_cursor() {
    production_log_message "INFO" "Starting enhanced Cursor uninstallation process"
    
    echo -e "\n${BOLD}${BLUE}🗑️  ENHANCED CURSOR UNINSTALLATION${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════════${NC}\n"
    
    local uninstall_errors=0
    local items_removed=0
    
    # Step 1: Stop Cursor processes
    production_info_message "Step 1: Stopping Cursor processes..."
    if stop_cursor_processes; then
        production_success_message "✓ Cursor processes stopped"
    else
        production_warning_message "⚠ Some processes may still be running"
        ((uninstall_errors++))
    fi
    
    # Step 2: Remove main application
    production_info_message "Step 2: Removing main application..."
    if remove_cursor_application; then
        production_success_message "✓ Cursor.app removed"
        ((items_removed++))
    else
        production_error_message "✗ Failed to remove Cursor.app"
        ((uninstall_errors++))
    fi
    
    # Step 3: Remove user data
    production_info_message "Step 3: Removing user data and preferences..."
    local user_items_removed
    if user_items_removed=$(remove_cursor_user_data); then
        production_success_message "✓ User data removed ($user_items_removed items)"
        items_removed=$((items_removed + user_items_removed))
    else
        production_error_message "✗ Failed to remove some user data"
        ((uninstall_errors++))
    fi
    
    # Step 4: Remove CLI tools
    production_info_message "Step 4: Removing CLI tools..."
    if remove_cursor_cli_tools; then
        production_success_message "✓ CLI tools removed"
        ((items_removed++))
    else
        production_warning_message "⚠ Some CLI tools may remain"
        ((uninstall_errors++))
    fi
    
    # Step 5: Clean system caches
    production_info_message "Step 5: Cleaning system caches..."
    if clean_cursor_caches; then
        production_success_message "✓ System caches cleaned"
        ((items_removed++))
    else
        production_warning_message "⚠ Some caches may remain"
        ((uninstall_errors++))
    fi
    
    # Step 6: Reset system registrations
    production_info_message "Step 6: Resetting system registrations..."
    if reset_cursor_system_registrations; then
        production_success_message "✓ System registrations reset"
    else
        production_warning_message "⚠ Some registrations may remain"
        ((uninstall_errors++))
    fi
    
    # Summary
    echo ""
    production_info_message "UNINSTALLATION SUMMARY:"
    production_info_message "  Items removed: $items_removed"
    production_info_message "  Errors encountered: $uninstall_errors"
    
    if [[ $uninstall_errors -eq 0 ]]; then
        production_success_message "🎉 Enhanced uninstallation completed successfully"
        return 0
    else
        production_error_message "Uninstallation completed with $uninstall_errors errors"
        return 1
    fi
}

# Stop all Cursor processes safely
stop_cursor_processes() {
    production_log_message "INFO" "Stopping Cursor processes"
    
    local current_script_pid="$$"
    local processes_stopped=0
    
    # Find Cursor processes (excluding our script)
    local cursor_pids
    cursor_pids=$(pgrep -f -i cursor 2>/dev/null | grep -v "$current_script_pid" || true)
    
    if [[ -n "$cursor_pids" ]]; then
        production_info_message "Found running Cursor processes:"
        
        # Show process information
        for pid in $cursor_pids; do
            if [[ "$pid" != "$current_script_pid" ]]; then
                local process_info
                process_info=$(ps -p "$pid" -o comm= 2>/dev/null || echo "Unknown")
                production_info_message "  PID $pid: $process_info"
            fi
        done
        
        # Graceful termination first
        production_info_message "Attempting graceful termination..."
        for pid in $cursor_pids; do
            if [[ "$pid" != "$current_script_pid" ]]; then
                if kill "$pid" 2>/dev/null; then
                    production_success_message "  Sent TERM signal to PID $pid"
                    ((processes_stopped++))
                fi
            fi
        done
        
        # Wait for graceful shutdown
        sleep 3
        
        # Force kill if still running
        cursor_pids=$(pgrep -f -i cursor 2>/dev/null | grep -v "$current_script_pid" || true)
        if [[ -n "$cursor_pids" ]]; then
            production_warning_message "Force killing remaining processes..."
            for pid in $cursor_pids; do
                if [[ "$pid" != "$current_script_pid" ]]; then
                    if kill -9 "$pid" 2>/dev/null; then
                        production_warning_message "  Force killed PID $pid"
                        ((processes_stopped++))
                    fi
                fi
            done
        fi
        
        production_info_message "Stopped $processes_stopped processes"
    else
        production_info_message "No Cursor processes found running"
    fi
    
    return 0
}

# Remove Cursor application bundle
remove_cursor_application() {
    production_log_message "INFO" "Removing Cursor application bundle"
    
    local app_path="/Applications/Cursor.app"
    
    if [[ -d "$app_path" ]]; then
        # Verify it's Cursor by checking bundle identifier
        local bundle_id
        bundle_id=$(defaults read "$app_path/Contents/Info.plist" CFBundleIdentifier 2>/dev/null || echo "unknown")
        
        local bundle_name
        bundle_name=$(defaults read "$app_path/Contents/Info.plist" CFBundleName 2>/dev/null || echo "unknown")
        
        # Enhanced verification for Cursor
        if [[ "$bundle_id" == *"cursor"* ]] || [[ "$bundle_id" == *"Cursor"* ]] || \
           [[ "$bundle_id" == *"todesktop"* ]] || \
           [[ "$bundle_name" == *"cursor"* ]] || [[ "$bundle_name" == *"Cursor"* ]] || \
           [[ "$(basename "$app_path")" == "Cursor.app" ]]; then
            
            # Get size for reporting
            local app_size
            app_size=$(du -sh "$app_path" 2>/dev/null | cut -f1 || echo "Unknown")
            
            production_info_message "Removing Cursor.app ($app_size)..."
            production_info_message "  Bundle ID: $bundle_id"
            production_info_message "  Bundle Name: $bundle_name"
            
            if enhanced_safe_remove "$app_path"; then
                production_success_message "Successfully removed Cursor.app"
                return 0
            else
                production_error_message "Failed to remove Cursor.app"
                return 1
            fi
        else
            production_error_message "Bundle verification failed - not confirmed as Cursor"
            production_error_message "  Bundle ID: $bundle_id"
            production_error_message "  Bundle Name: $bundle_name"
            return 1
        fi
    else
        production_info_message "Cursor.app not found at $app_path"
        return 0
    fi
}

# Remove Cursor user data and preferences
remove_cursor_user_data() {
    production_log_message "INFO" "Removing Cursor user data and preferences"
    
    local removed_count=0
    
    # Define user data locations
    local user_data_paths=(
        "$HOME/Library/Application Support/Cursor"
        "$HOME/Library/Preferences/com.cursor.Cursor.plist"
        "$HOME/Library/Preferences/com.todesktop.230313mzl4w4u92.plist"
        "$HOME/Library/Caches/Cursor"
        "$HOME/Library/Caches/com.cursor.Cursor"
        "$HOME/Library/Saved Application State/com.cursor.Cursor.savedState"
        "$HOME/Library/WebKit/com.cursor.Cursor"
        "$HOME/Library/Logs/Cursor"
        "$HOME/Library/HTTPStorages/com.cursor.Cursor"
        "$HOME/Library/Containers/com.cursor.Cursor"
        "$HOME/Library/Group Containers/group.com.cursor.Cursor"
        "$HOME/.cursor"
        "$HOME/.config/cursor"
        "$HOME/.vscode-cursor"
    )
    
    for path in "${user_data_paths[@]}"; do
        if [[ -e "$path" ]]; then
            local path_size
            path_size=$(du -sh "$path" 2>/dev/null | cut -f1 || echo "Unknown")
            
            production_info_message "Removing: $path ($path_size)"
            
            if enhanced_safe_remove "$path"; then
                production_success_message "  ✓ Removed: $path"
                ((removed_count++))
            else
                production_error_message "  ✗ Failed to remove: $path"
            fi
        fi
    done
    
    # Clean up any remaining cursor-related files in preferences
    if [[ -d "$HOME/Library/Preferences" ]]; then
        local cursor_prefs
        cursor_prefs=$(find "$HOME/Library/Preferences" -name "*cursor*" -o -name "*Cursor*" 2>/dev/null || true)
        
        if [[ -n "$cursor_prefs" ]]; then
            while IFS= read -r pref_file; do
                if [[ -e "$pref_file" ]]; then
                    production_info_message "Removing preference: $(basename "$pref_file")"
                    if enhanced_safe_remove "$pref_file"; then
                        production_success_message "  ✓ Removed: $(basename "$pref_file")"
                        ((removed_count++))
                    fi
                fi
            done <<< "$cursor_prefs"
        fi
    fi
    
    echo "$removed_count"
    return 0
}

# Remove Cursor CLI tools
remove_cursor_cli_tools() {
    production_log_message "INFO" "Removing Cursor CLI tools"
    
    local cli_locations=(
        "/usr/local/bin/cursor"
        "/opt/homebrew/bin/cursor"
        "/usr/bin/cursor"
    )
    
    local tools_removed=0
    
    for location in "${cli_locations[@]}"; do
        if [[ -e "$location" ]]; then
            # Check if it's actually Cursor-related
            local is_cursor_tool=false
            
            if [[ -L "$location" ]]; then
                # It's a symlink - check target
                local link_target
                link_target=$(readlink "$location")
                if [[ "$link_target" == *"Cursor"* ]] || [[ "$link_target" == *"cursor"* ]]; then
                    is_cursor_tool=true
                    production_info_message "Removing Cursor symlink: $location -> $link_target"
                fi
            elif [[ -f "$location" ]]; then
                # It's a file - check if it's Cursor CLI
                if command -v file >/dev/null 2>&1; then
                    local file_info
                    file_info=$(file "$location" 2>/dev/null || echo "")
                    if [[ "$file_info" == *"cursor"* ]] || [[ "$file_info" == *"Cursor"* ]]; then
                        is_cursor_tool=true
                        production_info_message "Removing Cursor CLI tool: $location"
                    fi
                else
                    # Can't determine, assume it's Cursor if found in standard locations
                    is_cursor_tool=true
                    production_info_message "Removing CLI tool: $location (unable to verify type)"
                fi
            fi
            
            if [[ "$is_cursor_tool" == "true" ]]; then
                if enhanced_safe_remove "$location"; then
                    production_success_message "  ✓ Removed: $location"
                    ((tools_removed++))
                else
                    production_error_message "  ✗ Failed to remove: $location"
                fi
            else
                production_info_message "Skipping non-Cursor tool: $location"
            fi
        fi
    done
    
    # Also check if cursor command is still available after removal
    if command -v cursor >/dev/null 2>&1; then
        local cursor_path
        cursor_path=$(which cursor 2>/dev/null)
        production_warning_message "Cursor command still available at: $cursor_path"
        production_info_message "Manual removal may be required for: $cursor_path"
    fi
    
    production_info_message "Removed $tools_removed CLI tools"
    return 0
}

# Clean Cursor-related caches
clean_cursor_caches() {
    production_log_message "INFO" "Cleaning Cursor-related caches"
    
    local caches_cleaned=0
    
    # System-wide cache locations
    local cache_locations=(
        "/Library/Caches/com.cursor.Cursor"
        "/var/folders/*/*/C/com.cursor.Cursor"
    )
    
    for cache_path in "${cache_locations[@]}"; do
        # Use glob expansion for /var/folders pattern
        if [[ "$cache_path" == *"/var/folders"* ]]; then
            # Find matching cache directories
            local cache_dirs
            cache_dirs=$(find /var/folders -path "*/C/com.cursor.Cursor" 2>/dev/null || true)
            
            if [[ -n "$cache_dirs" ]]; then
                while IFS= read -r cache_dir; do
                    if [[ -d "$cache_dir" ]]; then
                        production_info_message "Cleaning system cache: $cache_dir"
                        if enhanced_safe_remove "$cache_dir"; then
                            production_success_message "  ✓ Cleaned: $cache_dir"
                            ((caches_cleaned++))
                        fi
                    fi
                done <<< "$cache_dirs"
            fi
        else
            if [[ -d "$cache_path" ]]; then
                production_info_message "Cleaning cache: $cache_path"
                if enhanced_safe_remove "$cache_path"; then
                    production_success_message "  ✓ Cleaned: $cache_path"
                    ((caches_cleaned++))
                fi
            fi
        fi
    done
    
    # Clean temporary files
    local temp_patterns=(
        "/tmp/*cursor*"
        "/tmp/*Cursor*"
        "/var/tmp/*cursor*"
        "/var/tmp/*Cursor*"
    )
    
    for pattern in "${temp_patterns[@]}"; do
        # Use find to safely handle patterns
        local temp_files
        temp_files=$(find "$(dirname "$pattern")" -maxdepth 1 -name "$(basename "$pattern")" 2>/dev/null || true)
        
        if [[ -n "$temp_files" ]]; then
            while IFS= read -r temp_file; do
                if [[ -e "$temp_file" ]]; then
                    production_info_message "Removing temp file: $temp_file"
                    if enhanced_safe_remove "$temp_file"; then
                        production_success_message "  ✓ Removed: $temp_file"
                        ((caches_cleaned++))
                    fi
                fi
            done <<< "$temp_files"
        fi
    done
    
    production_info_message "Cleaned $caches_cleaned cache items"
    return 0
}

# Reset Cursor system registrations
reset_cursor_system_registrations() {
    production_log_message "INFO" "Resetting Cursor system registrations"
    
    local registrations_reset=0
    
    # Reset Launch Services database
    production_info_message "Resetting Launch Services database..."
    if command -v lsregister >/dev/null 2>&1; then
        if lsregister -kill -r -domain local -domain system -domain user >/dev/null 2>&1; then
            production_success_message "✓ Launch Services database reset"
            ((registrations_reset++))
        else
            production_warning_message "Failed to reset Launch Services database"
        fi
    else
        production_warning_message "lsregister command not available"
    fi
    
    # Clear any LaunchAgent/LaunchDaemon entries
    local launch_locations=(
        "$HOME/Library/LaunchAgents"
        "/Library/LaunchAgents"
        "/Library/LaunchDaemons"
        "/System/Library/LaunchAgents"
        "/System/Library/LaunchDaemons"
    )
    
    for location in "${launch_locations[@]}"; do
        if [[ -d "$location" ]]; then
            local cursor_plists
            cursor_plists=$(find "$location" -name "*cursor*" -o -name "*Cursor*" 2>/dev/null || true)
            
            if [[ -n "$cursor_plists" ]]; then
                while IFS= read -r plist_file; do
                    if [[ -f "$plist_file" ]]; then
                        production_info_message "Found LaunchAgent/Daemon: $plist_file"
                        
                        # Unload the service first
                        local service_name
                        service_name=$(basename "$plist_file" .plist)
                        if launchctl list | grep -q "$service_name" 2>/dev/null; then
                            production_info_message "Unloading service: $service_name"
                            launchctl unload "$plist_file" 2>/dev/null || true
                        fi
                        
                        # Remove the plist file
                        if enhanced_safe_remove "$plist_file"; then
                            production_success_message "  ✓ Removed: $plist_file"
                            ((registrations_reset++))
                        fi
                    fi
                done <<< "$cursor_plists"
            fi
        fi
    done
    
    # Clear Spotlight index for Cursor
    production_info_message "Clearing Spotlight index..."
    if command -v mdutil >/dev/null 2>&1; then
        if sudo mdutil -E / >/dev/null 2>&1; then
            production_success_message "✓ Spotlight index cleared"
            ((registrations_reset++))
        else
            production_warning_message "Failed to clear Spotlight index"
        fi
    fi
    
    production_info_message "Reset $registrations_reset system registrations"
    return 0
}

################################################################################
# User Interaction Functions
################################################################################

# Confirm uninstallation action
confirm_uninstallation_action() {
    if [[ "$NON_INTERACTIVE_MODE" == "true" ]]; then
        production_info_message "Non-interactive mode: Automatically proceeding with uninstallation"
        return 0
    fi
    
    echo -e "\n${YELLOW}${BOLD}⚠️  CURSOR UNINSTALLATION CONFIRMATION${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════${NC}\n"
    
    echo -e "${BOLD}This will remove:${NC}"
    echo -e "  ${RED}•${NC} Cursor.app from /Applications/"
    echo -e "  ${RED}•${NC} All user preferences and configuration"
    echo -e "  ${RED}•${NC} Cache files and temporary data"
    echo -e "  ${RED}•${NC} CLI tools and system integrations"
    echo -e "  ${RED}•${NC} System database registrations"
    echo ""
    echo -e "${BOLD}${YELLOW}This action cannot be easily undone.${NC}"
    echo ""
    
    while true; do
        echo -n "Do you want to proceed with Cursor uninstallation? (y/n): "
        read -r response
        
        case "$response" in
            [Yy]|[Yy][Ee][Ss])
                production_info_message "User confirmed uninstallation"
                return 0
                ;;
            [Nn]|[Nn][Oo])
                production_info_message "User cancelled uninstallation"
                return 1
                ;;
            *)
                production_warning_message "Please answer 'y' or 'n'"
                ;;
        esac
    done
}

################################################################################
# Module Initialization
################################################################################

# Mark module as loaded
UNINSTALL_LOADED="true"

# Export functions for use in other modules
export -f enhanced_uninstall_cursor stop_cursor_processes remove_cursor_application
export -f remove_cursor_user_data remove_cursor_cli_tools clean_cursor_caches
export -f reset_cursor_system_registrations confirm_uninstallation_action
