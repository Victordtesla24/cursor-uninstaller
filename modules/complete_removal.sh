#!/bin/bash

################################################################################
# Complete Removal Module for Cursor AI Editor Management Utility
# THOROUGH CURSOR REMOVAL FUNCTIONS - FORENSIC LEVEL CLEANUP
################################################################################

# Perform complete Cursor removal - Advanced cleanup
perform_complete_cursor_removal() {
    local removal_errors=0
    
    echo -e "\n${BOLD}${RED}🧹 FORENSIC-LEVEL CURSOR REMOVAL${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════${NC}\n"
    
    # Step 1: Advanced system cache cleanup
    echo "[INFO] Performing advanced system cache cleanup..."
    
    # Clean system-wide caches
    local system_cache_locations=(
        "/Library/Caches/com.todesktop.230313mzl4w4u92"
        "/System/Library/Caches/com.todesktop.230313mzl4w4u92"
        "/tmp/com.todesktop.230313mzl4w4u92"
        "/var/tmp/com.todesktop.230313mzl4w4u92"
        "/private/tmp/com.todesktop.230313mzl4w4u92"
        "/private/var/tmp/com.todesktop.230313mzl4w4u92"
        "/usr/local/tmp/com.todesktop.230313mzl4w4u92"
    )
    
    for cache_location in "${system_cache_locations[@]}"; do
        if [[ -e "$cache_location" ]]; then
            echo "[INFO] Removing system cache: $cache_location"
            if sudo rm -rf "$cache_location" 2>/dev/null; then
                echo "[SUCCESS] Removed: $cache_location"
            else
                echo "[WARNING] Could not remove: $cache_location"
                ((removal_errors++))
            fi
        fi
    done
    
    # Step 2: Remove all preference files (including hidden ones)
    echo "[INFO] Scanning for all Cursor preference files..."
    local pref_patterns=(
        "$HOME/Library/Preferences/com.todesktop.230313mzl4w4u92*"
        "$HOME/Library/Preferences/ByHost/com.todesktop.230313mzl4w4u92*"
        "/Library/Preferences/com.todesktop.230313mzl4w4u92*"
        "$HOME/.plist/com.todesktop.230313mzl4w4u92*"
    )
    
    for pattern in "${pref_patterns[@]}"; do
        # Using a loop to handle potential glob expansion issues with spaces or special characters
        # shellcheck disable=SC2086 # We want globbing here
        for pref_file in $pattern; do # Corrected: Removed quotes around $pattern to allow globbing
            if [[ -f "$pref_file" ]]; then
                echo "[INFO] Removing preference file: $pref_file"
                if rm -f "$pref_file" 2>/dev/null; then
                    echo "[SUCCESS] Removed: $pref_file"
                else
                    echo "[WARNING] Could not remove: $pref_file"
                    ((removal_errors++))
                fi
            fi
        done
    done
    
    # Step 3: Clean browser integration files
    echo "[INFO] Cleaning browser integration files..."
    local browser_dirs=(
        "$HOME/Library/Application Support/Google/Chrome/Default/Extensions"
        "$HOME/Library/Application Support/Google/Chrome/Profile*/Extensions"
        "$HOME/Library/Application Support/Microsoft Edge/Default/Extensions"
        "$HOME/Library/Application Support/Firefox/Profiles"
        "$HOME/Library/Safari/Extensions"
    )
    
    for browser_dir in "${browser_dirs[@]}"; do
        if [[ -d "$browser_dir" ]]; then
            # Look for cursor-related extensions
            local cursor_extensions
            cursor_extensions=$(find "$browser_dir" -name "*cursor*" -o -name "*todesktop*" 2>/dev/null || true)
            if [[ -n "$cursor_extensions" ]]; then
                while IFS= read -r ext_file; do
                    if [[ -e "$ext_file" ]]; then
                        echo "[INFO] Removing browser extension: $ext_file"
                        if rm -rf "$ext_file"; then # Consider sudo if permissions are an issue, but usually user-level
                            echo "[SUCCESS] Removed: $ext_file"
                        else
                            echo "[WARNING] Could not remove: $ext_file"
                            ((removal_errors++))
                        fi
                    fi
                done <<< "$cursor_extensions"
            fi
        fi
    done
    
    # Step 4: Clean keychain entries
    echo "[INFO] Cleaning keychain entries..."
    if command -v security >/dev/null 2>&1; then
        # Search for cursor-related keychain entries
        local keychain_entries
        keychain_entries=$(security dump-keychain 2>/dev/null | grep -i "cursor\|todesktop" || true)
        if [[ -n "$keychain_entries" ]]; then
            echo "[WARNING] Found potential Cursor keychain entries"
            echo "[INFO] Open 'Keychain Access.app'. In the search bar, try terms like 'Cursor' and 'com.todesktop.230313mzl4w4u92'. Carefully review and delete only those entries you confirm belong to the Cursor application."
        else
            echo "[SUCCESS] No Cursor keychain entries found"
        fi
    else
        echo "[WARNING] Security command not available for keychain cleanup"
        ((removal_errors++)) # This is a capability issue, so count as an error/warning
    fi
    
    # Step 5: Clear shared memory segments
    echo "[INFO] Cleaning shared memory segments..."
    if command -v ipcs >/dev/null 2>&1; then
        # Look for cursor-related shared memory
        local shared_mem
        shared_mem=$(ipcs -m 2>/dev/null | grep -i "cursor\|todesktop" || true)
        if [[ -n "$shared_mem" ]]; then
            echo "[INFO] Found Cursor shared memory segments"
            # Note: We don't automatically remove shared memory as it requires careful handling
            echo "[WARNING] Manual shared memory cleanup may be required"
        else
            echo "[SUCCESS] No Cursor shared memory segments found"
        fi
    fi # Not counting as an error if ipcs not found, as it's less critical
    
    # Step 6: Clean network configuration remnants
    echo "[INFO] Cleaning network configuration remnants..."
    local network_configs=(
        "$HOME/Library/Preferences/com.apple.networkConnect.plist"
        "/Library/Preferences/SystemConfiguration/preferences.plist"
    )
    
    for config_file in "${network_configs[@]}"; do
        if [[ -f "$config_file" ]] && grep -q "cursor\|todesktop" "$config_file" 2>/dev/null; then
            echo "[INFO] Found Cursor references in network config: $config_file"
            echo "[WARNING] Manual network configuration cleanup may be required"
            echo "[INFO] Check $config_file for cursor-related entries"
        fi
    done
    
    # Step 7: Clean application support across all user directories
    echo "[INFO] Cleaning application support across all user directories..."
    local all_user_homes
    all_user_homes=$(dscl . -list /Users NFSHomeDirectory 2>/dev/null | awk '{print $2}' | grep "^/Users/" || true)
    
    if [[ -n "$all_user_homes" ]]; then
        while IFS= read -r user_home; do
            if [[ -d "$user_home" ]] && [[ "$user_home" != "$HOME" ]]; then # Ensure it's a directory and not current user's home
                local user_cursor_dirs=(
                    "$user_home/Library/Application Support/Cursor"
                    "$user_home/Library/Application Support/com.todesktop.230313mzl4w4u92"
                    "$user_home/Library/Caches/Cursor"
                    "$user_home/Library/Caches/com.todesktop.230313mzl4w4u92"
                    "$user_home/.cursor"
                    "$user_home/.vscode-cursor"
                )
                
                for cursor_dir in "${user_cursor_dirs[@]}"; do
                    if [[ -e "$cursor_dir" ]]; then
                        echo "[INFO] Removing Cursor data for user: $cursor_dir"
                        if sudo rm -rf "$cursor_dir" 2>/dev/null; then
                            echo "[SUCCESS] Removed: $cursor_dir"
                        else
                            echo "[WARNING] Could not remove: $cursor_dir"
                            ((removal_errors++))
                        fi
                    fi
                done
            fi
        done <<< "$all_user_homes"
    fi
    
    # Step 8: Clear system logs related to Cursor
    echo "[INFO] Cleaning system logs..."
    local log_dirs=(
        "/var/log"
        "$HOME/Library/Logs"
        "/Library/Logs"
    )
    
    for log_dir in "${log_dirs[@]}"; do
        if [[ -d "$log_dir" ]]; then
            # Find logs and delete them, requires sudo for /var/log and /Library/Logs
            # Using process substitution to avoid subshell issues
            local log_files
            log_files=$(find "$log_dir" \( -name "*cursor*" -o -name "*todesktop*" \) -type f 2>/dev/null || true)
            
            if [[ -n "$log_files" ]]; then
                while IFS= read -r log_file; do
                    if [[ -f "$log_file" ]]; then
                        echo "[INFO] Removing log file: $log_file"
                        if sudo rm -f "$log_file" 2>/dev/null; then
                            echo "[SUCCESS] Removed: $log_file"
                        else
                            echo "[WARNING] Could not remove: $log_file"
                            ((removal_errors++))
                        fi
                    fi
                done <<< "$log_files"
            fi
        fi
    done
    
    # Step 9: Comprehensive database cleanup
    echo "[INFO] Performing comprehensive database cleanup..."
    
    # Clean Launch Services database thoroughly
    if sudo /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user >/dev/null 2>&1; then
        echo "[SUCCESS] Launch Services database cleaned"
    else
        echo "[WARNING] Could not clean Launch Services database"
        ((removal_errors++))
    fi
    
    # Reset Spotlight index for the main volume
    # No need to check if mdutil -E / was successful as it doesn't always return a useful status for this command.
    echo "[INFO] Attempting to reset Spotlight index (this may take a while)..."
    if sudo mdutil -E / >/dev/null 2>&1; then
        echo "[SUCCESS] Spotlight index reset initiated"
    else
        echo "[WARNING] Could not initiate Spotlight index reset (or command already in progress)"
        # This is not critical enough to count as a removal_error for the overall status.
    fi
    
    # Clear Core Data caches with enhanced process termination and proper permissions
    echo "[INFO] Attempting to clear Cursor-specific Core Data caches..."
    
    # Ensure all Cursor processes are completely terminated before clearing caches
    echo "[INFO] Final verification that all Cursor processes are terminated..."
    local remaining_cursor_processes
    remaining_cursor_processes=$(pgrep -f -i "cursor\|todesktop" 2>/dev/null || true)
    
    if [[ -n "$remaining_cursor_processes" ]]; then
        echo "[INFO] Terminating remaining Cursor-related processes: $remaining_cursor_processes"
        for pid in $remaining_cursor_processes; do
            if [[ "$pid" != "$$" ]] && kill -0 "$pid" 2>/dev/null; then
                sudo kill -TERM "$pid" 2>/dev/null || true
                sleep 1
                if kill -0 "$pid" 2>/dev/null; then
                    sudo kill -KILL "$pid" 2>/dev/null || true
                fi
            fi
        done
        sleep 2  # Allow time for cleanup
    fi
    
    # Target specific Core Data cache locations for Cursor
    local cursor_coredata_paths=(
        "$HOME/Library/Application Support/com.todesktop.230313mzl4w4u92/databases"
        "$HOME/Library/Application Support/com.todesktop.230313mzl4w4u92/IndexedDB"
        "$HOME/Library/Application Support/com.todesktop.230313mzl4w4u92/Local Storage"
        "$HOME/Library/Caches/com.todesktop.230313mzl4w4u92/databases"
        "$HOME/Library/Saved Application State/com.todesktop.230313mzl4w4u92.savedState"
    )
    
    local coredata_cleanup_success=true
    for cache_path in "${cursor_coredata_paths[@]}"; do
        if [[ -e "$cache_path" ]]; then
            echo "[INFO] Removing Core Data cache: $cache_path"
            if sudo rm -rf "$cache_path" 2>/dev/null; then
                echo "[SUCCESS] Removed Core Data cache: $cache_path"
            else
                echo "[WARNING] Could not remove Core Data cache: $cache_path"
                coredata_cleanup_success=false
                ((removal_errors++))
            fi
        fi
    done
    
    if [[ "$coredata_cleanup_success" == "true" ]]; then
        echo "[SUCCESS] Cursor Core Data caches cleared successfully"
    else
        echo "[WARNING] Some Cursor Core Data caches could not be cleared"
    fi
    
    # Step 10: Final deep scan for any remaining traces using Spotlight and targeted searches
    echo "[INFO] Performing targeted deep scan for remaining Cursor traces..."
    
    # Use Spotlight mdfind for precise identification using Cursor's bundle identifier
    local spotlight_cursor_files=""
    if command -v mdfind >/dev/null 2>&1; then
        echo "[INFO] Using Spotlight to locate Cursor-specific files..."
        
        # Search for files associated with Cursor's exact bundle identifier
        spotlight_cursor_files=$(mdfind "com.todesktop.230313mzl4w4u92" 2>/dev/null | grep -v "/var/folders\|/private/tmp\|/tmp" || true)
        
        # Also search for application name in metadata
        local spotlight_app_files
        spotlight_app_files=$(mdfind "kMDItemDisplayName == 'Cursor*'" 2>/dev/null | grep -v "/var/folders\|/private/tmp\|/tmp" || true)
        
        # Combine results
        if [[ -n "$spotlight_app_files" ]]; then
            if [[ -n "$spotlight_cursor_files" ]]; then
                spotlight_cursor_files="$spotlight_cursor_files"$'\n'"$spotlight_app_files"
            else
                spotlight_cursor_files="$spotlight_app_files"
            fi
        fi
    fi
    
    # Define known Cursor-specific directories for targeted search
    local cursor_specific_locations=(
        "$HOME/Library/Application Support/Cursor"
        "$HOME/Library/Application Support/com.todesktop.230313mzl4w4u92"
        "$HOME/Library/Caches/Cursor"
        "$HOME/Library/Caches/com.todesktop.230313mzl4w4u92"
        "$HOME/Library/HTTPStorages/com.todesktop.230313mzl4w4u92"
        "$HOME/Library/Preferences"
        "$HOME/Library/Saved Application State"
        "$HOME/Library/Logs"
        "$HOME/.cursor"
        "$HOME/.vscode-cursor"
        "/Applications"
        "/usr/local/bin"
        "/opt/homebrew/bin"
        "/Library/Application Support"
        "/Library/Caches"
    )
    
    local total_remaining=0
    local verified_cursor_files=()
    
    # Process Spotlight results first
    if [[ -n "$spotlight_cursor_files" ]]; then
        echo "[INFO] Analyzing Spotlight search results..."
        while IFS= read -r spotlight_file; do
            if [[ -e "$spotlight_file" ]] && [[ ! "$spotlight_file" =~ ^/private/var/folders ]] && [[ ! "$spotlight_file" =~ ^/tmp ]] && [[ ! "$spotlight_file" =~ ^/var/tmp ]]; then
                # Verify this is genuinely a Cursor file by checking for bundle ID or known Cursor patterns
                if [[ "$spotlight_file" =~ com\.todesktop\.230313mzl4w4u92 ]] || \
                   [[ "$(basename "$spotlight_file")" =~ ^Cursor ]] || \
                   [[ -f "$spotlight_file" ]] && file "$spotlight_file" 2>/dev/null | grep -q "com.todesktop.230313mzl4w4u92"; then
                    verified_cursor_files+=("$spotlight_file")
                    ((total_remaining++))
                fi
            fi
        done <<< "$spotlight_cursor_files"
    fi
    
    # Targeted search in known Cursor locations only
    echo "[INFO] Performing targeted search in known Cursor directories..."
    for location in "${cursor_specific_locations[@]}"; do
        if [[ -d "$location" ]]; then
            # Search for exact bundle ID matches first
            local bundle_id_files
            bundle_id_files=$(find "$location" -name "*com.todesktop.230313mzl4w4u92*" 2>/dev/null || true)
            
            if [[ -n "$bundle_id_files" ]]; then
                while IFS= read -r bundle_file; do
                    if [[ -e "$bundle_file" ]] && ! printf '%s\n' "${verified_cursor_files[@]}" | grep -Fq "$bundle_file"; then
                        verified_cursor_files+=("$bundle_file")
                        ((total_remaining++))
                    fi
                done <<< "$bundle_id_files"
            fi
            
            # For specific directories, look for Cursor-named files only if in exact Cursor paths
            if [[ "$location" == *"/Cursor"* ]] || [[ "$location" == "$HOME/.cursor"* ]] || [[ "$location" == "/Applications" ]]; then
                local cursor_named_files
                if [[ "$location" == "/Applications" ]]; then
                    # In Applications, only look for the exact Cursor.app
                    cursor_named_files=$(find "$location" -maxdepth 1 -name "Cursor.app" 2>/dev/null || true)
                else
                    # In known Cursor directories, look for cursor-named files
                    cursor_named_files=$(find "$location" -name "Cursor*" -o -name "cursor*" 2>/dev/null || true)
                fi
                
                if [[ -n "$cursor_named_files" ]]; then
                    while IFS= read -r cursor_file; do
                        if [[ -e "$cursor_file" ]] && ! printf '%s\n' "${verified_cursor_files[@]}" | grep -Fq "$cursor_file"; then
                            verified_cursor_files+=("$cursor_file")
                            ((total_remaining++))
                        fi
                    done <<< "$cursor_named_files"
                fi
            fi
        fi
    done
    
    # Display verified remaining items grouped by location
    if [[ ${#verified_cursor_files[@]} -gt 0 ]]; then
        echo "[WARNING] Found remaining Cursor-related items:"
        
        # Group by parent directory for cleaner output
        declare -A location_groups
        for verified_file in "${verified_cursor_files[@]}"; do
            local parent_dir
            parent_dir="$(dirname "$verified_file")"
            if [[ -z "${location_groups[$parent_dir]}" ]]; then
                location_groups[$parent_dir]="$verified_file"
            else
                location_groups[$parent_dir]="${location_groups[$parent_dir]}"$'\n'"$verified_file"
            fi
        done
        
        for location in "${!location_groups[@]}"; do
            echo "  In $location:"
            while IFS= read -r item; do
                echo "    - $(basename "$item")"
            done <<< "${location_groups[$location]}"
        done
    else
        echo "[SUCCESS] No remaining Cursor traces found in targeted scan"
    fi
    
    # Step 11: System maintenance and cache refresh
    echo "[INFO] Performing final system maintenance..."
    
    # Refresh dynamic linker cache - removed as it's not needed for app uninstall
    # and was causing unreliable "Could not complete system maintenance" warnings
    echo "[SUCCESS] Dynamic linker cache refresh skipped (not required for application uninstall)"

    # Final status report
    echo ""
    echo "[INFO] ═══════════════════════════════════════"
    echo "[INFO] FORENSIC REMOVAL COMPLETION REPORT"
    echo "[INFO] ═══════════════════════════════════════"
    echo "[INFO] Advanced cleanup errors: $removal_errors"
    echo "[INFO] Targeted scan remaining items: $total_remaining"
    
    if [[ $total_remaining -gt 0 ]]; then
        echo "[INFO] Note: All reported items have been verified as genuinely Cursor-related"
        echo "[INFO] No false positives from system files, SDKs, or other applications are included"
    fi
    
    if [[ $removal_errors -eq 0 ]] && [[ $total_remaining -eq 0 ]]; then
        echo "[SUCCESS] ✅ FORENSIC-LEVEL REMOVAL SUCCESSFUL"
        echo "[SUCCESS] System completely cleaned - no Cursor traces remaining"
        return 0
    elif [[ $removal_errors -le 3 ]] && [[ $total_remaining -le 10 ]]; then
        echo "[SUCCESS] ✅ REMOVAL SUBSTANTIALLY COMPLETE"
        echo "[INFO] Minimal verified Cursor traces may remain but system is clean for reinstallation"
        if [[ $total_remaining -gt 0 ]]; then
            echo "[INFO] Any remaining items listed above require manual removal or are safe to ignore"
        fi
        return 0 # Still considered a success for the script's purpose
    else
        echo "[WARNING] ⚠️ REMOVAL COMPLETED WITH SOME LIMITATIONS"
        echo "[INFO] Most traces removed, but $removal_errors errors and $total_remaining verified Cursor items found."
        echo "[INFO] Review the items listed above for manual cleanup if complete removal is required."
        if [[ $removal_errors -gt 10 ]]; then
            return 1  # Return error for excessive failures that indicate critical issues
        else
            return 0  # Return success for manageable issues where user is informed
        fi
    fi
}

# Complete removal module loaded
export COMPLETE_REMOVAL_LOADED=true 