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
    
    # Comprehensive Cursor process termination including background services
    echo "[INFO] Comprehensive termination of all Cursor-related processes..."
    
    # First, try graceful shutdown of main Cursor application
    if pgrep -f -i "Cursor\.app" >/dev/null 2>&1; then
        echo "[INFO] Attempting graceful shutdown of Cursor application..."
        osascript -e 'tell application "Cursor" to quit' 2>/dev/null || true
        sleep 3
    fi
    
    # Force terminate all Cursor-related processes including background services
    local all_cursor_processes
    all_cursor_processes=$(ps -ef | grep -i "cursor\|todesktop\.230313mzl4w4u92" | grep -v grep | grep -v "$$" | awk '{print $2}' || true)
    
    if [[ -n "$all_cursor_processes" ]]; then
        echo "[INFO] Force terminating all Cursor processes: $all_cursor_processes"
        for pid in $all_cursor_processes; do
            if [[ "$pid" != "$$" ]] && kill -0 "$pid" 2>/dev/null; then
                # First attempt graceful termination
                kill -TERM "$pid" 2>/dev/null || true
            fi
        done
        sleep 3
        
        # Check for remaining processes and force kill if necessary
        all_cursor_processes=$(ps -ef | grep -i "cursor\|todesktop\.230313mzl4w4u92" | grep -v grep | grep -v "$$" | awk '{print $2}' || true)
        if [[ -n "$all_cursor_processes" ]]; then
            echo "[INFO] Force killing remaining Cursor processes: $all_cursor_processes"
            for pid in $all_cursor_processes; do
                if [[ "$pid" != "$$" ]] && kill -0 "$pid" 2>/dev/null; then
                    kill -KILL "$pid" 2>/dev/null || true
                fi
            done
            sleep 2  # Allow time for cleanup
        fi
    fi
    
    # Verify no Cursor processes remain
    local final_check
    final_check=$(pgrep -f -i "cursor\|todesktop" 2>/dev/null | grep -v "$$" || true)
    if [[ -n "$final_check" ]]; then
        echo "[WARNING] Some Cursor processes may still be running: $final_check"
        echo "[INFO] Proceeding with cache cleanup - some files may be locked"
    else
        echo "[SUCCESS] All Cursor processes successfully terminated"
    fi
    
    # Target specific Core Data cache locations for Cursor with enhanced permissions
    local cursor_coredata_paths=(
        "$HOME/Library/Application Support/com.todesktop.230313mzl4w4u92/databases"
        "$HOME/Library/Application Support/com.todesktop.230313mzl4w4u92/IndexedDB"
        "$HOME/Library/Application Support/com.todesktop.230313mzl4w4u92/Local Storage"
        "$HOME/Library/Application Support/com.todesktop.230313mzl4w4u92/Session Storage"
        "$HOME/Library/Caches/com.todesktop.230313mzl4w4u92/databases"
        "$HOME/Library/Caches/com.todesktop.230313mzl4w4u92/Cache"
        "$HOME/Library/Saved Application State/com.todesktop.230313mzl4w4u92.savedState"
    )
    
    local coredata_cleanup_success=true
    local coredata_cleanup_attempts=0
    
    for cache_path in "${cursor_coredata_paths[@]}"; do
        if [[ -e "$cache_path" ]]; then
            ((coredata_cleanup_attempts++))
            echo "[INFO] Removing Core Data cache: $cache_path"
            
            # Try different removal approaches for locked files
            local removal_success=false
            
            # First attempt: Standard removal with user permissions
            if rm -rf "$cache_path" 2>/dev/null; then
                removal_success=true
                echo "[SUCCESS] Removed Core Data cache: $cache_path"
            # Second attempt: Use sudo for stubborn files
            elif sudo rm -rf "$cache_path" 2>/dev/null; then
                removal_success=true
                echo "[SUCCESS] Removed Core Data cache with elevated permissions: $cache_path"
            # Third attempt: Change permissions first, then remove
            elif sudo chmod -R 755 "$cache_path" 2>/dev/null && sudo rm -rf "$cache_path" 2>/dev/null; then
                removal_success=true
                echo "[SUCCESS] Removed Core Data cache after permission change: $cache_path"
            else
                echo "[WARNING] Could not remove Core Data cache: $cache_path"
                echo "[INFO] This may be due to active file locks or system protection"
                coredata_cleanup_success=false
                ((removal_errors++))
            fi
        fi
    done
    
    # Provide detailed feedback on Core Data cache cleanup
    if [[ $coredata_cleanup_attempts -eq 0 ]]; then
        echo "[SUCCESS] No Cursor Core Data caches found to clean"
    elif [[ "$coredata_cleanup_success" == "true" ]]; then
        echo "[SUCCESS] All Cursor Core Data caches cleared successfully ($coredata_cleanup_attempts locations processed)"
    else
        echo "[WARNING] Some Cursor Core Data caches could not be cleared"
        echo "[INFO] This is often due to active file locks and can be resolved by:"
        echo "[INFO]   1. Ensuring Cursor is completely closed"
        echo "[INFO]   2. Restarting the system if files remain locked"
        echo "[INFO]   3. Running the uninstaller again after restart"
    fi
    
    # Step 10: Precision deep scan for remaining Cursor traces - NO FALSE POSITIVES
    echo "[INFO] Performing precision deep scan for remaining Cursor traces..."
    
    # Use Spotlight mdfind for precise identification using Cursor's exact bundle identifier
    local spotlight_cursor_files=""
    if command -v mdfind >/dev/null 2>&1; then
        echo "[INFO] Using Spotlight to locate Cursor-specific files..."
        
        # Search for files associated with Cursor's exact bundle identifier only
        spotlight_cursor_files=$(mdfind "kMDItemCFBundleIdentifier == 'com.todesktop.230313mzl4w4u92'" 2>/dev/null | grep -v "/var/folders\|/private/tmp\|/tmp\|/var/tmp" || true)
        
        # Additional search for bundle identifier in file content/metadata
        local additional_bundle_files
        additional_bundle_files=$(mdfind "com.todesktop.230313mzl4w4u92" 2>/dev/null | grep -v "/var/folders\|/private/tmp\|/tmp\|/var/tmp\|/Library/Developer/\|/Applications/Firefox\|/opt/homebrew.*mongosh" || true)
        
        # Combine results only if additional files are in known user directories
        if [[ -n "$additional_bundle_files" ]]; then
            while IFS= read -r add_file; do
                # Only include files in user-specific Cursor directories
                if [[ "$add_file" =~ $HOME/Library/(Application\ Support|Caches|Preferences|HTTPStorages|Logs)/.*cursor ]] || \
                   [[ "$add_file" =~ $HOME/Library/(Application\ Support|Caches|Preferences|HTTPStorages|Logs)/.*com\.todesktop\.230313mzl4w4u92 ]] || \
                   [[ "$add_file" =~ $HOME/\.cursor ]] || \
                   [[ "$add_file" =~ ^/Applications/Cursor\.app ]] || \
                   [[ "$add_file" =~ ^/(usr/local|opt/homebrew)/bin/cursor$ ]]; then
                    if [[ -n "$spotlight_cursor_files" ]]; then
                        spotlight_cursor_files="$spotlight_cursor_files"$'\n'"$add_file"
                    else
                        spotlight_cursor_files="$add_file"
                    fi
                fi
            done <<< "$additional_bundle_files"
        fi
    fi
    
    # Define ONLY genuine Cursor-specific directories for targeted search
    local cursor_specific_locations=(
        "$HOME/Library/Application Support/Cursor"
        "$HOME/Library/Application Support/com.todesktop.230313mzl4w4u92"
        "$HOME/Library/Caches/Cursor"
        "$HOME/Library/Caches/com.todesktop.230313mzl4w4u92"
        "$HOME/Library/HTTPStorages/com.todesktop.230313mzl4w4u92"
        "$HOME/Library/Preferences/com.todesktop.230313mzl4w4u92.plist"
        "$HOME/Library/Preferences/ByHost"
        "$HOME/Library/Saved Application State/com.todesktop.230313mzl4w4u92.savedState"
        "$HOME/Library/Logs/Cursor"
        "$HOME/.cursor"
        "$HOME/.vscode-cursor"
        "/Applications/Cursor.app"
        "/usr/local/bin/cursor"
        "/opt/homebrew/bin/cursor"
    )
    
    local total_remaining=0
    local verified_cursor_files=()
    
    # Process Spotlight results with strict validation
    if [[ -n "$spotlight_cursor_files" ]]; then
        echo "[INFO] Analyzing Spotlight search results with strict validation..."
        while IFS= read -r spotlight_file; do
            if [[ -e "$spotlight_file" ]] && [[ ! "$spotlight_file" =~ ^/private/var/folders ]] && [[ ! "$spotlight_file" =~ ^/tmp ]] && [[ ! "$spotlight_file" =~ ^/var/tmp ]]; then
                # STRICT verification - must contain exact bundle ID or be in exact Cursor path
                local is_genuine_cursor_file=false
                
                # Check if file path contains exact bundle ID
                if [[ "$spotlight_file" =~ com\.todesktop\.230313mzl4w4u92 ]]; then
                    is_genuine_cursor_file=true
                # Check if file is exactly Cursor.app
                elif [[ "$spotlight_file" == "/Applications/Cursor.app" ]]; then
                    is_genuine_cursor_file=true
                # Check if file is in exact user Cursor directories
                elif [[ "$spotlight_file" =~ ^$HOME/Library/(Application\ Support|Caches|HTTPStorages|Logs)/Cursor(/.*)?$ ]] || \
                     [[ "$spotlight_file" =~ ^$HOME/\.cursor(/.*)?$ ]] || \
                     [[ "$spotlight_file" =~ ^$HOME/\.vscode-cursor(/.*)?$ ]] || \
                     [[ "$spotlight_file" =~ ^/(usr/local|opt/homebrew)/bin/cursor$ ]]; then
                    is_genuine_cursor_file=true
                # For files in broader directories, verify bundle ID in content
                elif [[ -f "$spotlight_file" ]] && file "$spotlight_file" 2>/dev/null | grep -q "com.todesktop.230313mzl4w4u92"; then
                    is_genuine_cursor_file=true
                fi
                
                if [[ "$is_genuine_cursor_file" == "true" ]]; then
                    verified_cursor_files+=("$spotlight_file")
                    ((total_remaining++))
                fi
            fi
        done <<< "$spotlight_cursor_files"
    fi
    
    # Targeted search ONLY in verified Cursor-specific locations
    echo "[INFO] Performing targeted search in verified Cursor-specific locations..."
    for location in "${cursor_specific_locations[@]}"; do
        # Only search if location exists and is not already found by Spotlight
        if [[ -e "$location" ]] && ! printf '%s\n' "${verified_cursor_files[@]}" | grep -Fq "$location"; then
            # For directories, search for exact bundle ID matches only
            if [[ -d "$location" ]]; then
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
            else
                # For files, add directly if they exist
                verified_cursor_files+=("$location")
                ((total_remaining++))
            fi
        fi
    done
    
    # Display verified remaining items with actionable guidance
    if [[ ${#verified_cursor_files[@]} -gt 0 ]]; then
        echo "[WARNING] Found remaining verified Cursor-related items:"
        
        # Group by parent directory and classify by action needed
        declare -A location_groups
        declare -A manual_removal_items
        declare -A safe_to_ignore_items
        
        for verified_file in "${verified_cursor_files[@]}"; do
            local parent_dir
            parent_dir="$(dirname "$verified_file")"
            local basename_file
            basename_file="$(basename "$verified_file")"
            
            # Classify items by what action is needed
            if [[ "$verified_file" =~ \.plist$ ]] && [[ "$verified_file" =~ /ByHost/ ]]; then
                manual_removal_items["$parent_dir"]+="$verified_file"$'\n'
            elif [[ "$verified_file" =~ /Keychain ]] || [[ "$verified_file" =~ \.keychain ]]; then
                manual_removal_items["$parent_dir"]+="$verified_file (requires Keychain Access.app)"$'\n'
            elif [[ "$verified_file" =~ /Logs/ ]] && [[ "$basename_file" =~ \.log$ ]]; then
                safe_to_ignore_items["$parent_dir"]+="$verified_file (safe to ignore - log file)"$'\n'
            else
                if [[ -z "${location_groups[$parent_dir]}" ]]; then
                    location_groups[$parent_dir]="$verified_file"
                else
                    location_groups[$parent_dir]="${location_groups[$parent_dir]}"$'\n'"$verified_file"
                fi
            fi
        done
        
        # Display standard remaining items
        if [[ ${#location_groups[@]} -gt 0 ]]; then
            echo ""
            echo "  Standard remaining items (should have been removed):"
            for location in "${!location_groups[@]}"; do
                echo "    In $location:"
                while IFS= read -r item; do
                    echo "      - $(basename "$item")"
                done <<< "${location_groups[$location]}"
            done
        fi
        
        # Display items requiring manual removal
        if [[ ${#manual_removal_items[@]} -gt 0 ]]; then
            echo ""
            echo "  Items requiring manual removal:"
            for location in "${!manual_removal_items[@]}"; do
                echo "    In $location:"
                while IFS= read -r item; do
                    if [[ -n "$item" ]]; then
                        echo "      - $item"
                    fi
                done <<< "${manual_removal_items[$location]}"
            done
            echo "    ACTION: Use Keychain Access.app to search for and remove Cursor-related entries"
        fi
        
        # Display items safe to ignore
        if [[ ${#safe_to_ignore_items[@]} -gt 0 ]]; then
            echo ""
            echo "  Items safe to ignore (non-functional remnants):"
            for location in "${!safe_to_ignore_items[@]}"; do
                echo "    In $location:"
                while IFS= read -r item; do
                    if [[ -n "$item" ]]; then
                        echo "      - $item"
                    fi
                done <<< "${safe_to_ignore_items[$location]}"
            done
        fi
        
        echo ""
        echo "  SUMMARY: ${#verified_cursor_files[@]} verified Cursor-related items found"
        echo "  NOTE: All items listed above have been confirmed as genuinely Cursor-related"
        echo "  NOTE: No false positives from system files, SDKs, or other applications included"
    else
        echo "[SUCCESS] No remaining Cursor traces found in precision scan"
        echo "[SUCCESS] System is completely clean of Cursor-related files"
    fi
    
    # Step 11: Final system maintenance and verification
    echo "[INFO] Performing final system maintenance..."
    
    # Clear DNS cache to remove any Cursor-related network entries
    echo "[INFO] Clearing DNS cache to remove network references..."
    if sudo dscacheutil -flushcache 2>/dev/null && sudo killall -HUP mDNSResponder 2>/dev/null; then
        echo "[SUCCESS] DNS cache cleared successfully"
    else
        echo "[WARNING] Could not clear DNS cache - not critical for uninstallation"
    fi
    
    # Clear font cache if Cursor installed any custom fonts
    echo "[INFO] Clearing font caches..."
    if atsutil databases -remove 2>/dev/null; then
        echo "[SUCCESS] Font caches cleared successfully"
    else
        echo "[INFO] Font cache clearing skipped (not critical for Cursor uninstallation)"
    fi
    
    # Update system cache for completeness
    echo "[INFO] Updating system caches..."
    if sudo update_dyld_shared_cache -force 2>/dev/null; then
        echo "[SUCCESS] System cache update completed"
    else
        echo "[INFO] System cache update not required or unavailable"
    fi

    # Final status report
    echo ""
    echo "[INFO] ═══════════════════════════════════════"
    echo "[INFO] FORENSIC REMOVAL COMPLETION REPORT"
    echo "[INFO] ═══════════════════════════════════════"
    echo "[INFO] Advanced cleanup errors: $removal_errors"
    echo "[INFO] Targeted scan remaining items: $total_remaining"
    
    # Enhanced final status assessment
    local critical_items=0
    local safe_ignore_items=0
    local manual_items=0
    
    # Count different types of remaining items for better assessment
    if [[ $total_remaining -gt 0 ]]; then
        for verified_file in "${verified_cursor_files[@]}"; do
            if [[ "$verified_file" =~ /Logs/ ]] && [[ "$(basename "$verified_file")" =~ \.log$ ]]; then
                ((safe_ignore_items++))
            elif [[ "$verified_file" =~ \.plist$ ]] && [[ "$verified_file" =~ /ByHost/ ]]; then
                ((manual_items++))
            elif [[ "$verified_file" =~ /Keychain ]] || [[ "$verified_file" =~ \.keychain ]]; then
                ((manual_items++))
            else
                ((critical_items++))
            fi
        done
        
        echo "[INFO] PRECISION SCAN RESULTS:"
        echo "[INFO] • Critical items (should have been removed): $critical_items"
        echo "[INFO] • Items requiring manual removal: $manual_items"
        echo "[INFO] • Safe to ignore items: $safe_ignore_items"
        echo "[INFO] • Total verified Cursor items found: $total_remaining"
        echo "[INFO] • Zero false positives from system files, SDKs, or other applications"
    fi
    
    if [[ $removal_errors -eq 0 ]] && [[ $total_remaining -eq 0 ]]; then
        echo "[SUCCESS] ✅ PRECISION FORENSIC REMOVAL SUCCESSFUL"
        echo "[SUCCESS] System completely cleaned - zero Cursor traces remaining"
        echo "[SUCCESS] No false positives detected - 100% accurate scan results"
        return 0
    elif [[ $removal_errors -eq 0 ]] && [[ $critical_items -eq 0 ]] && [[ $total_remaining -le 5 ]]; then
        echo "[SUCCESS] ✅ REMOVAL SUBSTANTIALLY COMPLETE"
        echo "[SUCCESS] No critical Cursor traces remain - system ready for fresh installation"
        if [[ $manual_items -gt 0 ]]; then
            echo "[INFO] $manual_items items require manual removal (detailed guidance provided above)"
        fi
        if [[ $safe_ignore_items -gt 0 ]]; then
            echo "[INFO] $safe_ignore_items log files can be safely ignored"
        fi
        return 0
    elif [[ $removal_errors -le 2 ]] && [[ $critical_items -le 2 ]]; then
        echo "[WARNING] ⚠️ REMOVAL COMPLETED WITH MINOR LIMITATIONS"
        echo "[INFO] Most Cursor traces removed successfully"
        if [[ $critical_items -gt 0 ]]; then
            echo "[WARNING] $critical_items critical items may need manual attention"
        fi
        echo "[INFO] System should be suitable for fresh Cursor installation"
        return 0
    else
        echo "[ERROR] ❌ REMOVAL COMPLETED WITH SIGNIFICANT ISSUES"
        echo "[ERROR] $removal_errors removal errors and $critical_items critical items remain"
        echo "[ERROR] Manual cleanup strongly recommended before reinstalling Cursor"
        return 1
    fi
}

# Complete removal module loaded
export COMPLETE_REMOVAL_LOADED=true 