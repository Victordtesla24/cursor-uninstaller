#!/bin/bash

################################################################################
# Complete Removal Module - PRODUCTION GRADE Comprehensive Cursor Elimination
# Systematic removal of all Cursor AI Editor components from macOS
################################################################################

# Prevent multiple loading
if [[ "${COMPLETE_REMOVAL_LOADED:-}" == "true" ]]; then
    return 0
fi

################################################################################
# Cursor Component Detection and Inventory
################################################################################

# Comprehensive Cursor file path detection
detect_all_cursor_components() {
    production_log_message "INFO" "Performing comprehensive Cursor component detection"
    
    local components_found=()
    local total_size=0
    
    # Main application bundle
    if [[ -d "/Applications/Cursor.app" ]]; then
        local app_size
        app_size=$(du -sh "/Applications/Cursor.app" 2>/dev/null | cut -f1)
        components_found+=("APPLICATION:/Applications/Cursor.app:$app_size")
        production_info_message "Found: Cursor.app ($app_size)"
    fi
    
    # User configuration and support files
    local user_paths=(
        "$HOME/Library/Application Support/Cursor"
        "$HOME/Library/Preferences/com.cursor.Cursor.plist"
        "$HOME/Library/Caches/Cursor"
        "$HOME/Library/Saved Application State/com.cursor.Cursor.savedState"
        "$HOME/Library/WebKit/com.cursor.Cursor"
        "$HOME/Library/Logs/Cursor"
        "$HOME/Library/HTTPStorages/com.cursor.Cursor"
        "$HOME/Library/Containers/com.cursor.Cursor"
        "$HOME/Library/Group Containers/group.com.cursor.Cursor"
    )
    
    for path in "${user_paths[@]}"; do
        if [[ -e "$path" ]]; then
            local path_size
            path_size=$(du -sh "$path" 2>/dev/null | cut -f1)
            components_found+=("USER_DATA:$path:$path_size")
            production_info_message "Found: $path ($path_size)"
        fi
    done
    
    # CLI tools and symlinks
    local cli_paths=(
        "/usr/local/bin/cursor"
        "/opt/homebrew/bin/cursor"
        "/usr/bin/cursor"
    )
    
    for path in "${cli_paths[@]}"; do
        if [[ -e "$path" ]]; then
            local link_info=""
            if [[ -L "$path" ]]; then
                link_info=" -> $(readlink "$path")"
            fi
            components_found+=("CLI_TOOL:$path:$link_info")
            production_info_message "Found: $path$link_info"
        fi
    done
    
    # Additional system locations
    local system_paths=(
        "/Library/Application Support/Cursor"
        "/Library/Caches/com.cursor.Cursor"
        "/System/Library/LaunchAgents/com.cursor.Cursor.plist"
        "/Library/LaunchAgents/com.cursor.Cursor.plist"
        "/Library/LaunchDaemons/com.cursor.Cursor.plist"
    )
    
    for path in "${system_paths[@]}"; do
        if [[ -e "$path" ]]; then
            local path_size
            path_size=$(du -sh "$path" 2>/dev/null | cut -f1)
            components_found+=("SYSTEM:$path:$path_size")
            production_info_message "Found: $path ($path_size)"
        fi
    done
    
    # Store findings for later use
    if [[ ${#components_found[@]} -gt 0 ]]; then
        printf '%s\n' "${components_found[@]}" > "${TEMP_DIR}/cursor_components.txt"
        production_success_message "Detected ${#components_found[@]} Cursor components"
        return 0
    else
        production_info_message "No Cursor components detected"
        return 1
    fi
}

# Find additional Cursor files using system search
find_additional_cursor_files() {
    production_log_message "INFO" "Searching for additional Cursor files across the system"
    
    local additional_files=()
    
    # Search for cursor-related files (case-insensitive)
    production_info_message "Performing system-wide search for Cursor files..."
    
    # Search in user directories
    local user_search_dirs=(
        "$HOME/Library"
        "$HOME/.cursor"
        "$HOME/.config/cursor"
        "$HOME/Documents"
        "$HOME/Downloads"
    )
    
    for search_dir in "${user_search_dirs[@]}"; do
        if [[ -d "$search_dir" ]]; then
            production_log_message "DEBUG" "Searching user directory: $search_dir"
            while IFS= read -r -d '' file; do
                if [[ -e "$file" ]]; then
                    additional_files+=("$file")
                fi
            done < <(find "$search_dir" \( -iname "*cursor*" -o -iname "*.cursor" \) -print0 2>/dev/null)
        fi
    done
    
    # Search in system directories (with sudo if available and user has permission)
    if command -v sudo >/dev/null 2>&1 && sudo -n true 2>/dev/null; then
        local system_search_dirs=(
            "/Library"
            "/usr/local"
            "/opt"
        )
        
        for search_dir in "${system_search_dirs[@]}"; do
            if [[ -d "$search_dir" ]]; then
                production_log_message "DEBUG" "Searching system directory: $search_dir"
                # Use timeout and better error handling for system directories
                local search_timeout=30
                if command -v timeout >/dev/null 2>&1; then
                    while IFS= read -r -d '' file; do
                        if [[ -e "$file" ]]; then
                            additional_files+=("$file")
                        fi
                    done < <(timeout "$search_timeout" sudo find "$search_dir" \( -iname "*cursor*" -o -iname "*.cursor" \) -print0 2>/dev/null || true)
                else
                    # Fallback without timeout
                    while IFS= read -r -d '' file; do
                        if [[ -e "$file" ]]; then
                            additional_files+=("$file")
                        fi
                    done < <(sudo find "$search_dir" \( -iname "*cursor*" -o -iname "*.cursor" \) -print0 2>/dev/null || true)
                fi
            fi
        done
    else
        production_warning_message "Skipping system directory search: insufficient permissions"
    fi
    
    # Filter out already known components
    local new_files=()
    for file in "${additional_files[@]}"; do
        if ! grep -q "$file" "${TEMP_DIR}/cursor_components.txt" 2>/dev/null; then
            new_files+=("$file")
        fi
    done
    
    if [[ ${#new_files[@]} -gt 0 ]]; then
        printf '%s\n' "${new_files[@]}" > "${TEMP_DIR}/additional_cursor_files.txt"
        production_success_message "Found ${#new_files[@]} additional Cursor files"
        return 0
    else
        production_info_message "No additional Cursor files found"
        return 1
    fi
}

################################################################################
# System Registration and Database Cleanup
################################################################################

# Clear Launch Services database entries
clear_launch_services_entries() {
    production_log_message "INFO" "Clearing Launch Services database entries"
    
    # Reset Launch Services database
    if command -v /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister >/dev/null 2>&1; then
        production_info_message "Resetting Launch Services database..."
        
        if /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user; then
            production_success_message "Launch Services database reset successfully"
        else
            production_warning_message "Failed to reset Launch Services database"
        fi
    else
        production_warning_message "lsregister command not found"
    fi
    
    # Remove specific Cursor entries if possible
    if command -v lsregister >/dev/null 2>&1; then
        production_info_message "Removing specific Cursor entries..."
        lsregister -u "/Applications/Cursor.app" 2>/dev/null || true
    fi
}

# Clear system keychain entries
clear_keychain_entries() {
    production_log_message "INFO" "Clearing Cursor-related keychain entries"
    
    # Search for Cursor-related keychain entries
    local keychain_items=()
    
    # Check login keychain
    if command -v security >/dev/null 2>&1; then
        production_info_message "Searching for Cursor keychain entries..."
        
        # Find entries containing 'cursor' in the service name
        while IFS= read -r line; do
            if [[ -n "$line" ]]; then
                keychain_items+=("$line")
            fi
        done < <(security dump-keychain | grep -i "cursor" | head -20 2>/dev/null || true)
        
        if [[ ${#keychain_items[@]} -gt 0 ]]; then
            production_warning_message "Found ${#keychain_items[@]} potential Cursor keychain entries"
            production_info_message "Manual keychain cleanup may be required"
        else
            production_info_message "No Cursor keychain entries found"
        fi
    else
        production_warning_message "Security command not available for keychain cleanup"
    fi
}

# Remove background processes and daemons
remove_background_processes() {
    production_log_message "INFO" "Checking for and removing Cursor background processes"
    
    # Check for running Cursor processes
    local cursor_processes
    cursor_processes=$(ps aux | grep -i cursor | grep -v grep | awk '{print $2}' || true)
    
    if [[ -n "$cursor_processes" ]]; then
        production_warning_message "Found running Cursor processes:"
        ps aux | grep -i cursor | grep -v grep || true
        
        production_info_message "Terminating Cursor processes..."
        while IFS= read -r pid; do
            if [[ -n "$pid" ]]; then
                if kill "$pid" 2>/dev/null; then
                    production_success_message "Terminated process: $pid"
                else
                    production_warning_message "Failed to terminate process: $pid"
                fi
            fi
        done <<< "$cursor_processes"
        
        # Wait for processes to terminate
        sleep 2
        
        # Force kill if still running
        cursor_processes=$(ps aux | grep -i cursor | grep -v grep | awk '{print $2}' || true)
        if [[ -n "$cursor_processes" ]]; then
            production_warning_message "Force killing remaining processes..."
            while IFS= read -r pid; do
                if [[ -n "$pid" ]]; then
                    kill -9 "$pid" 2>/dev/null || true
                fi
            done <<< "$cursor_processes"
        fi
    else
        production_info_message "No running Cursor processes found"
    fi
    
    # Check for and remove LaunchAgents/LaunchDaemons
    local launch_items=(
        "$HOME/Library/LaunchAgents/com.cursor.Cursor.plist"
        "/Library/LaunchAgents/com.cursor.Cursor.plist"
        "/Library/LaunchDaemons/com.cursor.Cursor.plist"
        "/System/Library/LaunchAgents/com.cursor.Cursor.plist"
        "/System/Library/LaunchDaemons/com.cursor.Cursor.plist"
    )
    
    for item in "${launch_items[@]}"; do
        if [[ -f "$item" ]]; then
            production_warning_message "Found LaunchAgent/Daemon: $item"
            
            # Unload the service first
            local service_name
            service_name=$(basename "$item" .plist)
            if launchctl list | grep -q "$service_name"; then
                production_info_message "Unloading service: $service_name"
                launchctl unload "$item" 2>/dev/null || true
            fi
            
            # Remove the plist file
            if enhanced_safe_remove "$item"; then
                production_success_message "Removed: $item"
            fi
        fi
    done
}

################################################################################
# File Removal Operations
################################################################################

# Remove main application bundle
remove_cursor_application() {
    production_log_message "INFO" "Removing Cursor application bundle"
    
    local app_path="/Applications/Cursor.app"
    
    if [[ -d "$app_path" ]]; then
        # Verify it's actually Cursor
        local bundle_id
        bundle_id=$(defaults read "$app_path/Contents/Info.plist" CFBundleIdentifier 2>/dev/null || echo "unknown")
        
        if [[ "$bundle_id" == *"cursor"* ]] || [[ "$bundle_id" == *"Cursor"* ]]; then
            production_info_message "Verified Cursor application bundle: $bundle_id"
            
            # Get size before removal
            local app_size
            app_size=$(du -sh "$app_path" 2>/dev/null | cut -f1)
            
            if enhanced_safe_remove "$app_path"; then
                production_success_message "Removed Cursor.app ($app_size)"
                return 0
            else
                production_error_message "Failed to remove Cursor.app"
                return 1
            fi
        else
            production_error_message "Application bundle verification failed: $bundle_id"
            return 1
        fi
    else
        production_info_message "Cursor.app not found at $app_path"
        return 0
    fi
}

# Remove user configuration and data
remove_user_data() {
    production_log_message "INFO" "Removing Cursor user configuration and data"
    
    local removed_count=0
    local failed_count=0
    
    # Read components from file if available
    if [[ -f "${TEMP_DIR}/cursor_components.txt" ]]; then
        while IFS=':' read -r type path size; do
            if [[ "$type" == "USER_DATA" ]] && [[ -e "$path" ]]; then
                production_info_message "Removing: $path ($size)"
                if enhanced_safe_remove "$path"; then
                    production_success_message "Removed: $path"
                    ((removed_count++))
                else
                    production_error_message "Failed to remove: $path"
                    ((failed_count++))
                fi
            fi
        done < "${TEMP_DIR}/cursor_components.txt"
    fi
    
    # Additional cleanup for standard locations
    local user_paths=(
        "$HOME/Library/Application Support/Cursor"
        "$HOME/Library/Preferences/com.cursor.Cursor.plist"
        "$HOME/Library/Caches/Cursor"
        "$HOME/Library/Saved Application State/com.cursor.Cursor.savedState"
        "$HOME/Library/WebKit/com.cursor.Cursor"
        "$HOME/Library/Logs/Cursor"
        "$HOME/.cursor"
        "$HOME/.config/cursor"
    )
    
    for path in "${user_paths[@]}"; do
        if [[ -e "$path" ]]; then
            if enhanced_safe_remove "$path"; then
                production_success_message "Removed: $path"
                ((removed_count++))
            else
                production_error_message "Failed to remove: $path"
                ((failed_count++))
            fi
        fi
    done
    
    production_info_message "User data removal: $removed_count removed, $failed_count failed"
    return $failed_count
}

# Remove CLI tools and symlinks
remove_cli_tools() {
    production_log_message "INFO" "Removing Cursor CLI tools and symlinks"
    
    local cli_paths=(
        "/usr/local/bin/cursor"
        "/opt/homebrew/bin/cursor"
        "/usr/bin/cursor"
    )
    
    local removed_count=0
    
    for path in "${cli_paths[@]}"; do
        if [[ -e "$path" ]]; then
            # Check if it's actually related to Cursor
            if [[ -L "$path" ]]; then
                local link_target
                link_target=$(readlink "$path")
                if [[ "$link_target" == *"Cursor"* ]] || [[ "$link_target" == *"cursor"* ]]; then
                    production_info_message "Removing symlink: $path -> $link_target"
                    if enhanced_safe_remove "$path"; then
                        production_success_message "Removed symlink: $path"
                        ((removed_count++))
                    fi
                fi
            elif [[ -f "$path" ]]; then
                # Check file content or metadata
                local file_info
                file_info=$(file "$path" 2>/dev/null || echo "unknown")
                if [[ "$file_info" == *"cursor"* ]] || [[ "$file_info" == *"Cursor"* ]]; then
                    production_info_message "Removing CLI tool: $path"
                    if enhanced_safe_remove "$path"; then
                        production_success_message "Removed CLI tool: $path"
                        ((removed_count++))
                    fi
                fi
            fi
        fi
    done
    
    production_info_message "CLI tools removal: $removed_count items removed"
    return 0
}

################################################################################
# Verification Functions
################################################################################

# Verify complete removal
verify_complete_removal() {
    production_log_message "INFO" "Verifying complete Cursor removal"
    
    local verification_failed=false
    local remaining_items=()
    
    # Check for Cursor command
    if command -v cursor >/dev/null 2>&1; then
        local cursor_path
        cursor_path=$(which cursor)
        remaining_items+=("CLI_COMMAND:$cursor_path")
        verification_failed=true
    fi
    
    # Check main application
    if [[ -d "/Applications/Cursor.app" ]]; then
        remaining_items+=("APPLICATION:/Applications/Cursor.app")
        verification_failed=true
    fi
    
    # System-wide search for remaining files with proper error handling
    production_info_message "Performing final system search for remaining Cursor files..."
    
    local search_results=()
    
    # Search user directories with timeout
    production_log_message "DEBUG" "Searching user directories for remaining files"
    local user_search_timeout=30
    if command -v timeout >/dev/null 2>&1; then
        while IFS= read -r -d '' file; do
            if [[ -e "$file" ]]; then
                search_results+=("$file")
            fi
        done < <(timeout "$user_search_timeout" find "$HOME" \( -iname "*cursor*" -o -iname "*.cursor" \) -not -path "*/.*" -print0 2>/dev/null || true)
    else
        while IFS= read -r -d '' file; do
            if [[ -e "$file" ]]; then
                search_results+=("$file")
            fi
        done < <(find "$HOME" \( -iname "*cursor*" -o -iname "*.cursor" \) -not -path "*/.*" -print0 2>/dev/null || true)
    fi
    
    # Search system directories with proper permissions check
    if command -v sudo >/dev/null 2>&1 && sudo -n true 2>/dev/null; then
        production_log_message "DEBUG" "Searching system directories for remaining files"
        local system_search_timeout=30
        local system_search_dirs=("/Applications" "/Library" "/usr/local" "/opt")
        
        for search_dir in "${system_search_dirs[@]}"; do
            if [[ -d "$search_dir" ]]; then
                if command -v timeout >/dev/null 2>&1; then
                    while IFS= read -r -d '' file; do
                        if [[ -e "$file" ]]; then
                            search_results+=("$file")
                        fi
                    done < <(timeout "$system_search_timeout" sudo find "$search_dir" \( -iname "*cursor*" -o -iname "*.cursor" \) -print0 2>/dev/null || true)
                else
                    while IFS= read -r -d '' file; do
                        if [[ -e "$file" ]]; then
                            search_results+=("$file")
                        fi
                    done < <(sudo find "$search_dir" \( -iname "*cursor*" -o -iname "*.cursor" \) -print0 2>/dev/null || true)
                fi
            fi
        done
    else
        production_warning_message "Skipping system directory verification: insufficient permissions"
    fi
    
    # Filter results to exclude false positives
    for file in "${search_results[@]}"; do
        # Skip temporary files, build artifacts, and unrelated items
        if [[ "$file" != *"/tmp/"* ]] && \
           [[ "$file" != *"/.Trash/"* ]] && \
           [[ "$file" != *"/node_modules/"* ]] && \
           [[ "$file" != *"/build/"* ]] && \
           [[ "$file" != *"/dist/"* ]] && \
           [[ "$file" != *"/coverage/"* ]] && \
           [[ "$file" != *"cursor-uninstaller"* ]]; then
            remaining_items+=("REMAINING_FILE:$file")
            verification_failed=true
        fi
    done
    
    # Display results
    if [[ "$verification_failed" == "true" ]]; then
        production_warning_message "⚠ ${#remaining_items[@]} Cursor components still remain"
        
        # Show first few remaining items
        local show_count=$((${#remaining_items[@]} < 10 ? ${#remaining_items[@]} : 10))
        for (( i=0; i<show_count; i++ )); do
            local item_type="${remaining_items[i]%%:*}"
            local item_path="${remaining_items[i]#*:}"
            production_warning_message "  $item_type: $item_path"
        done
        
        if [[ ${#remaining_items[@]} -gt 10 ]]; then
            production_warning_message "  ... and $((${#remaining_items[@]} - 10)) more items"
        fi
        
        production_warning_message "Some Cursor components may still remain"
        return 1
    else
        production_success_message "✓ Complete Cursor removal verified - no remaining components found"
        return 0
    fi
}

# Generate removal report
generate_removal_report() {
    local report_file="${TEMP_DIR}/cursor_removal_report_$(date +%Y%m%d_%H%M%S).txt"
    
    production_log_message "INFO" "Generating removal report: $report_file"
    
    cat > "$report_file" << EOF
# Cursor AI Editor Complete Removal Report
# Generated: $(date)
# System: $(uname -s) $(uname -r)
# User: $(whoami)

## Components Detected and Removed:
EOF
    
    if [[ -f "${TEMP_DIR}/cursor_components.txt" ]]; then
        echo "" >> "$report_file"
        cat "${TEMP_DIR}/cursor_components.txt" >> "$report_file"
    fi
    
    if [[ -f "${TEMP_DIR}/additional_cursor_files.txt" ]]; then
        echo -e "\n## Additional Files Found:" >> "$report_file"
        cat "${TEMP_DIR}/additional_cursor_files.txt" >> "$report_file"
    fi
    
    if [[ -f "${TEMP_DIR}/remaining_cursor_items.txt" ]]; then
        echo -e "\n## Items Requiring Manual Cleanup:" >> "$report_file"
        cat "${TEMP_DIR}/remaining_cursor_items.txt" >> "$report_file"
    fi
    
    echo -e "\n## Verification Status:" >> "$report_file"
    if verify_complete_removal >/dev/null 2>&1; then
        echo "PASSED - System is clean" >> "$report_file"
    else
        echo "FAILED - Manual cleanup required" >> "$report_file"
    fi
    
    production_success_message "Removal report saved: $report_file"
    echo "$report_file"
}

################################################################################
# Complete Removal Orchestration
################################################################################

# Perform complete Cursor removal
perform_complete_cursor_removal() {
    production_log_message "INFO" "Starting complete Cursor AI Editor removal"
    
    local removal_errors=0
    
    # Step 1: Detect all components
    production_info_message "Phase 1: Component Detection"
    detect_all_cursor_components || true
    find_additional_cursor_files || true
    
    # Step 2: Remove background processes
    production_info_message "Phase 2: Background Process Cleanup"
    remove_background_processes || ((removal_errors++))
    
    # Step 3: Remove main application
    production_info_message "Phase 3: Application Removal"
    remove_cursor_application || ((removal_errors++))
    
    # Step 4: Remove user data
    production_info_message "Phase 4: User Data Cleanup"
    remove_user_data
    removal_errors=$((removal_errors + $?))
    
    # Step 5: Remove CLI tools
    production_info_message "Phase 5: CLI Tools Removal"
    remove_cli_tools || ((removal_errors++))
    
    # Step 6: Clear system registrations
    production_info_message "Phase 6: System Database Cleanup"
    clear_launch_services_entries || ((removal_errors++))
    clear_keychain_entries || ((removal_errors++))
    
    # Step 7: Verification
    production_info_message "Phase 7: Removal Verification"
    if verify_complete_removal; then
        production_success_message "✓ Complete Cursor removal successful"
    else
        production_error_message "✗ Complete removal verification failed"
        ((removal_errors++))
    fi
    
    # Step 8: Generate report
    local report_file
    report_file=$(generate_removal_report)
    
    if [[ $removal_errors -eq 0 ]]; then
        production_success_message "Complete Cursor removal finished successfully"
        production_info_message "Report: $report_file"
        return 0
    else
        production_error_message "Complete removal finished with $removal_errors errors"
        production_error_message "Manual cleanup may be required - see report: $report_file"
        return 1
    fi
}

################################################################################
# Module Initialization
################################################################################

# Mark module as loaded
COMPLETE_REMOVAL_LOADED="true"

# Export functions for use in other modules
export -f detect_all_cursor_components perform_complete_cursor_removal
export -f verify_complete_removal generate_removal_report 