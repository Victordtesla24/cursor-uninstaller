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
            echo "[INFO] Manual keychain cleanup may be required"
            echo "[INFO] Use Keychain Access app to remove Cursor-related entries"
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
            # Using -exec to handle files safely
            # Find files and then attempt to remove them
            find "$log_dir" \( -name "*cursor*" -o -name "*todesktop*" \) -type f -print0 2>/dev/null | while IFS= read -r -d $'\0' log_file; do
                echo "[INFO] Removing log file: $log_file"
                if sudo rm -f "$log_file" 2>/dev/null; then
                    echo "[SUCCESS] Removed: $log_file"
                else
                    echo "[WARNING] Could not remove: $log_file"
                    ((removal_errors++))
                fi
            done
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
    
    # Clear Core Data caches by running system maintenance scripts
    # These scripts handle more than just Core Data but are generally safe.
    echo "[INFO] Attempting to clear system data caches..."
    if sudo periodic daily weekly >/dev/null 2>&1; then # Removed 'monthly' as it can be very long
        echo "[SUCCESS] System data caches cleared"
    else
        echo "[WARNING] Could not clear system data caches (non-critical)"
        # ((removal_errors++)) # Not critical enough to be a removal error
    fi
    
    # Step 10: Final deep scan for any remaining traces
    echo "[INFO] Performing final deep scan for remaining traces..."
    local deep_scan_locations=(
        "/Applications"
        "$HOME/Library"
        "/Library"
        "/usr/local"
        "/opt"
        # "/tmp" # tmp and var/tmp are too volatile and noisy for this scan
        # "/var/tmp"
    )
    
    local total_remaining=0
    for location in "${deep_scan_locations[@]}"; do
        if [[ -d "$location" ]]; then
            local remaining_items
            # Enhanced filtering to prevent false positives from unrelated system files
            remaining_items=$(find "$location" \
                \( -path "*/CommandLineTools/*" -o \
                   -path "*/SDKs/*" -o \
                   -path "*/mongosh/*" -o \
                   -path "*/usr/share/man/*" -o \
                   -path "*/System/Library/Frameworks/*" -o \
                   -path "*/Xcode.app/*" -o \
                   -path "*/DeveloperTools/*" -o \
                   -path "*/Documentation/*" -o \
                   -path "*/Headers/*" -o \
                   -path "*/PrivateFrameworks/*" \) -prune -o \
                \( -iname "*cursor*" -o -iname "*com.todesktop.230313mzl4w4u92*" \) \
                -type f -print 2>/dev/null | \
                while IFS= read -r item; do
                    # Additional verification to ensure the item is genuinely related to Cursor
                    if [[ -f "$item" ]]; then
                        # Check file metadata or content for Cursor-specific identifiers
                        if file "$item" 2>/dev/null | grep -q -i "cursor\|todesktop" || \
                           head -n 5 "$item" 2>/dev/null | grep -q -i "cursor\|todesktop" || \
                           basename "$item" | grep -q -E "^(cursor|com\.todesktop\.230313mzl4w4u92)" 2>/dev/null; then
                            echo "$item"
                        fi
                    elif [[ -d "$item" ]]; then
                        # For directories, check if they contain Cursor-specific files
                        if [[ -n "$(find "$item" -maxdepth 2 -name "*cursor*" -o -name "*todesktop*" 2>/dev/null | head -1)" ]]; then
                            echo "$item"
                        fi
                    else
                        # For other file types, use basename matching only
                        if basename "$item" | grep -q -E "^(cursor|com\.todesktop\.230313mzl4w4u92)" 2>/dev/null; then
                            echo "$item"
                        fi
                    fi
                done | head -20) # head -20 to limit output
            
            if [[ -n "$remaining_items" ]]; then
                echo "[WARNING] Found remaining items in $location:"
                while IFS= read -r item; do
                    echo "  - $item"
                    ((total_remaining++))
                done <<< "$remaining_items"
            fi
        fi
    done
    
    # Step 11: System maintenance and cache refresh
    echo "[INFO] Performing final system maintenance..."
    
    # Refresh dynamic linker cache
    # update_dyld_shared_cache is very powerful and usually not needed for app uninstall
    # Disabling for safety unless specifically requested for a deeper system interaction
    # if sudo update_dyld_shared_cache -force >/dev/null 2>&1; then
    #     echo "[SUCCESS] Dynamic linker cache refreshed"
    # else
    #     echo "[WARNING] Could not refresh dynamic linker cache"
    #     ((removal_errors++))
    # fi
    echo "[INFO] Skipping dynamic linker cache update (rarely needed for uninstall)."

    # Final status report
    echo ""
    echo "[INFO] ═══════════════════════════════════════"
    echo "[INFO] FORENSIC REMOVAL COMPLETION REPORT"
    echo "[INFO] ═══════════════════════════════════════"
    echo "[INFO] Advanced cleanup errors: $removal_errors"
    echo "[INFO] Deep scan remaining items: $total_remaining"
    
    if [[ $removal_errors -eq 0 ]] && [[ $total_remaining -eq 0 ]]; then
        echo "[SUCCESS] ✅ FORENSIC-LEVEL REMOVAL SUCCESSFUL"
        echo "[SUCCESS] System completely cleaned - no traces remaining"
        return 0
    elif [[ $removal_errors -le 3 ]] && [[ $total_remaining -le 10 ]]; then # Adjusted thresholds
        echo "[SUCCESS] ✅ REMOVAL SUBSTANTIALLY COMPLETE"
        echo "[INFO] Minimal traces may remain but system is clean for reinstallation"
        return 0 # Still considered a success for the script's purpose
    else
        echo "[WARNING] ⚠️ REMOVAL COMPLETED WITH SOME LIMITATIONS"
        echo "[INFO] Most traces removed, but $removal_errors errors and $total_remaining items found."
        echo "[INFO] Some manual cleanup may be needed for a pristine state."
        return 0  # Return success to prevent script exit, user is informed.
    fi
}

# Complete removal module loaded
export COMPLETE_REMOVAL_LOADED=true 