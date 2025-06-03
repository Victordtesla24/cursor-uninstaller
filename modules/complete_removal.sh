#!/bin/bash

################################################################################
# Production Complete Removal Module for Cursor AI Editor
# ENHANCED FORENSIC REMOVAL WITH PRECISION TARGETING AND ZERO FALSE POSITIVES
################################################################################

# Strict error handling
set -euo pipefail

# Module configuration and constants
readonly MODULE_NAME="complete_removal"
readonly MODULE_VERSION="2.0.0"
readonly SPOTLIGHT_TIMEOUT=30
readonly MAX_REMOVAL_ATTEMPTS=3
readonly PROCESS_TERMINATION_TIMEOUT=15

# Enhanced logging for this module
module_log() {
    local level="$1"
    local message="$2"
    log_with_level "$level" "[$MODULE_NAME] $message"
}

# Validate Cursor installation existence
validate_cursor_installation() {
    local found_components=0
    
    module_log "INFO" "Validating Cursor installation presence..."
    
    # Check main application bundle
    if [[ -d "$CURSOR_APP_PATH" ]]; then
        module_log "INFO" "Found Cursor application: $CURSOR_APP_PATH"
        ((found_components++))
    fi
    
    # Check for user data directories
    local user_dirs
    user_dirs=$(get_cursor_user_dirs)
    
    while IFS= read -r dir; do
        if [[ -e "$dir" ]]; then
            module_log "INFO" "Found user data: $dir"
            ((found_components++))
        fi
    done <<< "$user_dirs"
    
    # Check CLI installations
    for cli_path in "${CURSOR_CLI_PATHS[@]}"; do
        if [[ -x "$cli_path" ]]; then
            module_log "INFO" "Found CLI installation: $cli_path"
            ((found_components++))
        fi
    done
    
    if [[ $found_components -eq 0 ]]; then
        module_log "WARNING" "No Cursor components found on system"
        return 1
    else
        module_log "INFO" "Found $found_components Cursor components for removal"
        return 0
    fi
}

# Enhanced process termination with comprehensive detection
terminate_all_cursor_processes() {
    local max_attempts="$1"
    local graceful_timeout="$2"
    
    module_log "INFO" "Starting comprehensive process termination..."
    
    # Application-specific quit attempts
    local app_quit_attempts=0
    while [[ $app_quit_attempts -lt 3 ]]; do
        if osascript -e 'tell application "Cursor" to quit' 2>/dev/null; then
            module_log "INFO" "Sent application quit signal (attempt $((app_quit_attempts + 1)))"
        fi
        ((app_quit_attempts++))
        sleep 2
    done
    
    # Use enhanced process termination from helpers
    if terminate_cursor_processes "$graceful_timeout" 5 "$max_attempts"; then
        module_log "SUCCESS" "All Cursor processes terminated successfully"
        return 0
    else
        module_log "ERROR" "Failed to terminate all Cursor processes"
        return 1
    fi
}

# Enhanced Core Data cache cleanup with multiple strategies
cleanup_coredata_caches() {
    module_log "INFO" "Starting comprehensive Core Data cache cleanup..."
    
    local cleanup_success=true
    local cache_patterns=(
        "*Cursor*"
        "*cursor*"
        "*com.todesktop.230313mzl4w4u92*"
        "*todesktop*"
    )
    
    local cache_locations=(
        "$HOME/Library/Caches"
        "$HOME/Library/Application Support"
        "/var/folders"
        "/private/var/folders"
        "/tmp"
        "$TMPDIR"
    )
    
    # Remove duplicates and invalid paths from cache_locations
    local validated_locations=()
    for location in "${cache_locations[@]}"; do
        if [[ -d "$location" ]] && [[ ! " ${validated_locations[*]} " =~ \ $location\  ]]; then
            validated_locations+=("$location")
        fi
    done
    
    local total_operations=0
    local successful_operations=0
    local failed_operations=0
    
    # Calculate total operations for progress tracking
    for location in "${validated_locations[@]}"; do
        for pattern in "${cache_patterns[@]}"; do
            if find "$location" -maxdepth 3 -name "$pattern" 2>/dev/null | grep -q .; then
                ((total_operations++))
            fi
        done
    done
    
    local current_operation=0
    
    for location in "${validated_locations[@]}"; do
        module_log "INFO" "Scanning cache location: $location"
        
        for pattern in "${cache_patterns[@]}"; do
            local cache_paths
            cache_paths=$(find "$location" -maxdepth 3 -name "$pattern" 2>/dev/null | head -50)
            
            while IFS= read -r cache_path; do
                if [[ -n "$cache_path" && -e "$cache_path" ]]; then
                    ((current_operation++))
                    
                    # Show progress
                    if [[ $total_operations -gt 0 ]]; then
                        show_progress "$current_operation" "$total_operations" "Cleaning caches" true true
                    fi
                    
                    # Validate this is actually a Cursor-related cache
                    if validate_cursor_cache_path "$cache_path"; then
                        local cache_size
                        cache_size=$(du -sh "$cache_path" 2>/dev/null | cut -f1 || echo "unknown")
                        
                        module_log "INFO" "Removing cache: $cache_path ($cache_size)"
                        
                        # Multiple removal strategies
                        if attempt_cache_removal "$cache_path"; then
                            ((successful_operations++))
                        else
                            ((failed_operations++))
                            cleanup_success=false
                        fi
                    else
                        module_log "DEBUG" "Skipped non-Cursor cache: $cache_path"
                    fi
                fi
            done <<< "$cache_paths"
        done
    done
    
    # Clear progress line
    if [[ $total_operations -gt 0 ]]; then
        echo ""
    fi
    
    module_log "INFO" "Cache cleanup summary: $successful_operations successful, $failed_operations failed"
    
    if [[ "$cleanup_success" == "true" ]]; then
        module_log "SUCCESS" "Core Data cache cleanup completed successfully"
        return 0
    else
        module_log "WARNING" "Core Data cache cleanup completed with some failures"
        return 1
    fi
}

# Validate that a cache path is actually Cursor-related
validate_cursor_cache_path() {
    local cache_path="$1"
    
    # Detailed validation to prevent false positives
    
    # Check if path contains Cursor identifiers
    if [[ "$cache_path" =~ Cursor ]] || [[ "$cache_path" =~ cursor ]] || [[ "$cache_path" =~ com\.todesktop\.230313mzl4w4u92 ]]; then
        
        # Exclude known false positives
        local false_positive_patterns=(
            "firefox"
            "Firefox" 
            "chrome"
            "Chrome"
            "safari"
            "Safari"
            "webkit"
            "WebKit"
            "mongosh"
            "Developer/SDKs"
            "CommandLineTools"
            "System/Library"
        )
        
        for pattern in "${false_positive_patterns[@]}"; do
            if [[ "$cache_path" =~ $pattern ]]; then
                module_log "DEBUG" "Excluded false positive: $cache_path (contains $pattern)"
                return 1
            fi
        done
        
        # Additional validation for actual Cursor content
        if [[ -d "$cache_path" ]]; then
            # Check for Cursor-specific files or bundle identifiers
            if find "$cache_path" -name "*.plist" -exec grep -l "todesktop\|Cursor" {} \; 2>/dev/null | grep -q .; then
                return 0
            fi
            
            # Check for Cursor executable or app structure
            if find "$cache_path" -name "*Cursor*" -o -name "*.app" 2>/dev/null | grep -q .; then
                return 0
            fi
        fi
        
        # For files, check if they contain Cursor-specific content
        if [[ -f "$cache_path" ]] && [[ -r "$cache_path" ]]; then
            if head -100 "$cache_path" 2>/dev/null | grep -qi "cursor\|todesktop"; then
                return 0
            fi
        fi
        
        # If no specific Cursor content found, treat as false positive
        module_log "DEBUG" "No Cursor-specific content found in: $cache_path"
        return 1
    fi
    
    return 1
}

# Attempt cache removal with multiple strategies
attempt_cache_removal() {
    local cache_path="$1"
    local attempt=1
    
    while [[ $attempt -le $MAX_REMOVAL_ATTEMPTS ]]; do
        module_log "DEBUG" "Removal attempt $attempt for: $cache_path"
        
        # Strategy 1: Standard removal
        if [[ $attempt -eq 1 ]]; then
            if rm -rf "$cache_path" 2>/dev/null; then
                module_log "SUCCESS" "Removed with standard permissions: $cache_path"
                return 0
            fi
        fi
        
        # Strategy 2: Change permissions first
        if [[ $attempt -eq 2 ]]; then
            if chmod -R 755 "$cache_path" 2>/dev/null && rm -rf "$cache_path" 2>/dev/null; then
                module_log "SUCCESS" "Removed after permission change: $cache_path"
                return 0
            fi
        fi
        
        # Strategy 3: Use sudo
        if [[ $attempt -eq 3 ]]; then
            if sudo rm -rf "$cache_path" 2>/dev/null; then
                module_log "SUCCESS" "Removed with elevated permissions: $cache_path"
                return 0
            fi
        fi
        
        ((attempt++))
        sleep 1
    done
    
    module_log "ERROR" "Failed to remove after $MAX_REMOVAL_ATTEMPTS attempts: $cache_path"
    return 1
}

# Enhanced system maintenance with specific, reliable operations
perform_system_maintenance() {
    module_log "INFO" "Starting enhanced system maintenance..."
    
    local maintenance_success=true
    local operations=("DNS Cache" "Font Cache" "Launch Services" "Spotlight Index")
    local current_op=1
    local total_ops=${#operations[@]}
    
    # DNS Cache Clearing
    show_progress "$current_op" "$total_ops" "Clearing DNS cache" true true
    if dscacheutil -flushcache 2>/dev/null && sudo dscacheutil -flushcache 2>/dev/null; then
        module_log "SUCCESS" "DNS cache cleared successfully"
    else
        module_log "WARNING" "DNS cache clearing encountered issues (non-critical)"
    fi
    ((current_op++))
    
    # Font Cache Clearing  
    show_progress "$current_op" "$total_ops" "Clearing font cache" true true
    if sudo atsutil databases -remove 2>/dev/null; then
        module_log "SUCCESS" "Font cache cleared successfully"
    else
        module_log "WARNING" "Font cache clearing failed (non-critical)"
    fi
    ((current_op++))
    
    # Launch Services Registration Update
    show_progress "$current_op" "$total_ops" "Updating Launch Services" true true
    if [[ -x "$LAUNCH_SERVICES_CMD" ]]; then
        if "$LAUNCH_SERVICES_CMD" -kill -r -domain local -domain system -domain user 2>/dev/null; then
            module_log "SUCCESS" "Launch Services database updated"
        else
            module_log "WARNING" "Launch Services update encountered issues"
            maintenance_success=false
        fi
    else
        module_log "WARNING" "Launch Services command not available"
        maintenance_success=false
    fi
    ((current_op++))
    
    # Spotlight Reindexing (selective)
    show_progress "$current_op" "$total_ops" "Rebuilding Spotlight index" true true
    if timeout "$SPOTLIGHT_TIMEOUT" sudo mdutil -i on / 2>/dev/null; then
        module_log "SUCCESS" "Spotlight reindexing initiated"
    else
        module_log "WARNING" "Spotlight reindexing failed or timed out (non-critical)"
    fi
    
    # Clear progress
    echo ""
    
    if [[ "$maintenance_success" == "true" ]]; then
        module_log "SUCCESS" "System maintenance completed successfully"
        return 0
    else
        module_log "WARNING" "System maintenance completed with some issues"
        return 1
    fi
}

# Enhanced deep scan with precision targeting and false positive prevention
perform_deep_system_scan() {
    module_log "INFO" "Starting precision deep system scan..."
    
    # Enhanced search with strict validation
    local search_results=()
    local false_positives=0
    local validated_results=0
    
    # Spotlight search with exact bundle identifier
    module_log "INFO" "Performing Spotlight search with bundle identifier..."
    local spotlight_results
    if spotlight_results=$(mdfind "kMDItemCFBundleIdentifier == 'com.todesktop.230313mzl4w4u92'" 2>/dev/null); then
        while IFS= read -r result; do
            if [[ -n "$result" && -e "$result" ]]; then
                if validate_spotlight_result "$result"; then
                    search_results+=("$result")
                    ((validated_results++))
                else
                    ((false_positives++))
                fi
            fi
        done <<< "$spotlight_results"
    fi
    
    # Targeted directory searches in known Cursor locations only
    local target_directories=(
        "/Applications"
        "$HOME/Applications"
        "$HOME/Library"
        "/usr/local/bin"
        "/opt/homebrew/bin"
        "$HOME/.local/bin"
    )
    
    module_log "INFO" "Scanning targeted directories for remaining Cursor components..."
    
    for target_dir in "${target_directories[@]}"; do
        if [[ -d "$target_dir" ]]; then
            module_log "DEBUG" "Scanning: $target_dir"
            
            # Search for Cursor-specific patterns with depth limits
            local found_items
            found_items=$(find "$target_dir" -maxdepth 3 \( -name "*Cursor*" -o -name "*cursor*" -o -name "*todesktop*" \) 2>/dev/null | head -20)
            
            while IFS= read -r item; do
                if [[ -n "$item" && -e "$item" ]]; then
                    if validate_found_item "$item"; then
                        # Check if already in results
                        if [[ ! " ${search_results[*]} " =~ \ $item\  ]]; then
                            search_results+=("$item")
                            ((validated_results++))
                        fi
                    else
                        ((false_positives++))
                    fi
                fi
            done <<< "$found_items"
        fi
    done
    
    module_log "INFO" "Deep scan completed: $validated_results validated items, $false_positives false positives filtered"
    
    # Categorize and report results
    if [[ ${#search_results[@]} -gt 0 ]]; then
        categorize_remaining_items "${search_results[@]}"
    else
        module_log "SUCCESS" "No remaining Cursor components found"
    fi
    
    return 0
}

# Validate Spotlight search results
validate_spotlight_result() {
    local result="$1"
    
    # Must contain Cursor bundle identifier or be in Cursor app path
    if [[ "$result" =~ com\.todesktop\.230313mzl4w4u92 ]] || [[ "$result" == *"/Cursor.app"* ]]; then
        
        # Exclude system directories and known false positives
        local exclusion_patterns=(
            "/System/Library"
            "/Library/Developer/SDKs"
            "/Applications/Firefox"
            "/opt/homebrew.*mongosh"
            "/.Trash"
        )
        
        for pattern in "${exclusion_patterns[@]}"; do
            if [[ "$result" =~ $pattern ]]; then
                module_log "DEBUG" "Excluded Spotlight result: $result (matches $pattern)"
                return 1
            fi
        done
        
        return 0
    fi
    
    return 1
}

# Validate found items to prevent false positives
validate_found_item() {
    local item="$1"
    
    # Check for Cursor-specific indicators
    local cursor_indicators=false
    
    # Check bundle ID in plist files
    if [[ -f "$item/Contents/Info.plist" ]]; then
        if grep -q "com.todesktop.230313mzl4w4u92" "$item/Contents/Info.plist" 2>/dev/null; then
            cursor_indicators=true
        fi
    fi
    
    # Check for Cursor executable
    if [[ -x "$item/Contents/MacOS/Cursor" ]] || [[ -x "$item" && "$(basename "$item")" == "cursor" ]]; then
        cursor_indicators=true
    fi
    
    # Check file content for known false positives
    local false_positive_indicators=(
        "firefox"
        "Firefox"
        "chrome" 
        "Chrome"
        "mongosh"
        "Developer/SDKs"
    )
    
    for indicator in "${false_positive_indicators[@]}"; do
        if [[ "$item" =~ $indicator ]]; then
            module_log "DEBUG" "Excluded item as false positive: $item (contains $indicator)"
            return 1
        fi
    done
    
    # If Cursor indicators found, validate it's actually Cursor
    if [[ "$cursor_indicators" == "true" ]]; then
        return 0
    fi
    
    # For items without clear indicators, do deeper validation
    if [[ -d "$item" ]]; then
        # Check for Cursor-specific files within directory
        if find "$item" -name "*.plist" -exec grep -l "todesktop\|Cursor" {} \; 2>/dev/null | grep -q .; then
            return 0
        fi
    fi
    
    module_log "DEBUG" "No Cursor indicators found in: $item"
    return 1
}

# Enhanced categorization of remaining items
categorize_remaining_items() {
    local items=("$@")
    
    module_log "INFO" "Categorizing ${#items[@]} remaining items..."
    
    local manual_removal=()
    local automatic_removal=()
    local safe_to_ignore=()
    
    for item in "${items[@]}"; do
        if [[ -e "$item" ]]; then
            local item_type
            item_type=$(classify_remaining_item "$item")
            
            case "$item_type" in
                "manual")
                    manual_removal+=("$item")
                    ;;
                "automatic")
                    automatic_removal+=("$item")
                    ;;
                "ignore")
                    safe_to_ignore+=("$item")
                    ;;
            esac
        fi
    done
    
    # Report categorized results
    echo -e "\n${BOLD}${BLUE}📋 REMAINING CURSOR COMPONENTS ANALYSIS${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════${NC}\n"
    
    if [[ ${#automatic_removal[@]} -gt 0 ]]; then
        echo -e "${YELLOW}${BOLD}⚠️  ITEMS FOR AUTOMATIC REMOVAL (${#automatic_removal[@]}):${NC}"
        for item in "${automatic_removal[@]}"; do
            local size
            size=$(du -sh "$item" 2>/dev/null | cut -f1 || echo "unknown")
            echo -e "  📁 $item ${CYAN}($size)${NC}"
        done
        echo ""
        
        if confirm_operation "Remove these items automatically?" 30 "y"; then
            remove_categorized_items "automatic" "${automatic_removal[@]}"
        fi
    fi
    
    if [[ ${#manual_removal[@]} -gt 0 ]]; then
        echo -e "${RED}${BOLD}🔧 ITEMS REQUIRING MANUAL REMOVAL (${#manual_removal[@]}):${NC}"
        echo -e "${RED}These items may require special handling or admin privileges:${NC}"
        for item in "${manual_removal[@]}"; do
            local size
            size=$(du -sh "$item" 2>/dev/null | cut -f1 || echo "unknown")
            echo -e "  🔒 $item ${CYAN}($size)${NC}"
        done
        echo -e "\n${BOLD}Manual removal commands:${NC}"
        for item in "${manual_removal[@]}"; do
            echo -e "  ${CYAN}sudo rm -rf \"$item\"${NC}"
        done
        echo ""
    fi
    
    if [[ ${#safe_to_ignore[@]} -gt 0 ]]; then
        echo -e "${GREEN}${BOLD}✅ ITEMS SAFE TO IGNORE (${#safe_to_ignore[@]}):${NC}"
        echo -e "${GREEN}These items do not affect Cursor functionality:${NC}"
        for item in "${safe_to_ignore[@]}"; do
            echo -e "  ℹ️  $item"
        done
        echo ""
    fi
    
    # Final assessment
    local critical_items=$((${#automatic_removal[@]} + ${#manual_removal[@]}))
    if [[ $critical_items -eq 0 ]]; then
        module_log "SUCCESS" "✅ Complete removal successful - no critical remnants found"
    else
        module_log "INFO" "⚠️  $critical_items items require attention for complete removal"
    fi
}

# Classify remaining items by required action
classify_remaining_item() {
    local item="$1"
    
    # Check if item is in system location requiring special handling
    if [[ "$item" =~ /System/ ]] || [[ "$item" =~ /usr/libexec/ ]]; then
        echo "ignore"
        return
    fi
    
    # Check if item requires elevated privileges
    if [[ ! -w "$(dirname "$item")" ]] || [[ ! -w "$item" ]]; then
        echo "manual"
        return
    fi
    
    # Check if item is a critical system component (false positive prevention)
    if [[ "$item" =~ /(Developer|SDK|mongosh|firefox)/ ]]; then
        echo "ignore"
        return
    fi
    
    # Default to automatic removal for standard user files
    echo "automatic"
}

# Remove categorized items with appropriate handling
remove_categorized_items() {
    local category="$1"
    shift
    local items=("$@")
    
    module_log "INFO" "Removing ${#items[@]} items in category: $category"
    
    local success_count=0
    local failure_count=0
    
    for item in "${items[@]}"; do
        if safe_remove_file "$item" true true; then
            ((success_count++))
        else
            ((failure_count++))
        fi
    done
    
    module_log "INFO" "Removal completed: $success_count successful, $failure_count failed"
    return 0
}

# Enhanced keychain cleanup guidance
provide_keychain_cleanup_guidance() {
    echo -e "\n${BOLD}${YELLOW}🔐 KEYCHAIN CLEANUP GUIDANCE${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════${NC}\n"
    
    echo -e "${BOLD}To remove Cursor keychain entries:${NC}"
    echo -e "1. Open ${BOLD}Keychain Access.app${NC} (found in /Applications/Utilities/)"
    echo -e "2. Select ${BOLD}All Items${NC} in the Category section"
    echo -e "3. Search for: ${CYAN}todesktop${NC} or ${CYAN}cursor${NC}"
    echo -e "4. Select any found entries and press ${BOLD}Delete${NC}"
    echo -e "5. Confirm deletion when prompted"
    echo ""
    echo -e "${BOLD}Alternative terminal method:${NC}"
    echo -e "${CYAN}security find-generic-password -s \"todesktop\" 2>/dev/null && security delete-generic-password -s \"todesktop\"${NC}"
    echo -e "${CYAN}security find-generic-password -s \"cursor\" 2>/dev/null && security delete-generic-password -s \"cursor\"${NC}"
    echo ""
}

# Main complete removal function
perform_complete_cursor_removal() {
    local start_time
    start_time=$(date +%s)
    
    module_log "INFO" "Initiating complete Cursor removal process..."
    
    # Initialize counters
    local total_steps=7
    local completed_steps=0
    local warnings=0
    local errors=0
    
    # Step 1: Validate installation
    show_progress $((++completed_steps)) $total_steps "Validating Cursor installation"
    if ! validate_cursor_installation; then
        module_log "WARNING" "No Cursor installation found, proceeding with cleanup verification"
        ((warnings++))
    fi
    
    # Step 2: Terminate processes  
    show_progress $((++completed_steps)) $total_steps "Terminating Cursor processes"
    if ! terminate_all_cursor_processes 3 "$PROCESS_TERMINATION_TIMEOUT"; then
        module_log "ERROR" "Process termination failed"
        ((errors++))
    fi
    
    # Step 3: Remove main application
    show_progress $((++completed_steps)) $total_steps "Removing main application"
    if [[ -d "$CURSOR_APP_PATH" ]]; then
        if safe_remove_file "$CURSOR_APP_PATH" true true; then
            module_log "SUCCESS" "Main application removed"
        else
            module_log "ERROR" "Failed to remove main application"
            ((errors++))
        fi
    else
        module_log "INFO" "Main application not found"
    fi
    
    # Step 4: Remove user data directories
    show_progress $((++completed_steps)) $total_steps "Removing user data"
    local user_dirs
    user_dirs=$(get_cursor_user_dirs)
    local user_data_errors=0
    
    while IFS= read -r dir; do
        if [[ -e "$dir" ]]; then
            if safe_remove_file "$dir" true true; then
                module_log "SUCCESS" "Removed user data: $dir"
            else
                module_log "ERROR" "Failed to remove user data: $dir"
                ((user_data_errors++))
            fi
        fi
    done <<< "$user_dirs"
    
    if [[ $user_data_errors -gt 0 ]]; then
        ((errors++))
    fi
    
    # Step 5: Remove CLI tools
    show_progress $((++completed_steps)) $total_steps "Removing CLI tools"
    for cli_path in "${CURSOR_CLI_PATHS[@]}"; do
        if [[ -x "$cli_path" ]]; then
            if safe_remove_file "$cli_path" true true; then
                module_log "SUCCESS" "Removed CLI tool: $cli_path"
            else
                module_log "ERROR" "Failed to remove CLI tool: $cli_path"
                ((errors++))
            fi
        fi
    done
    
    # Step 6: Clean Core Data caches
    show_progress $((++completed_steps)) $total_steps "Cleaning Core Data caches"
    if ! cleanup_coredata_caches; then
        module_log "WARNING" "Core Data cleanup had issues"
        ((warnings++))
    fi
    
    # Step 7: System maintenance
    show_progress $((++completed_steps)) $total_steps "Performing system maintenance"
    if ! perform_system_maintenance; then
        module_log "WARNING" "System maintenance had issues"
        ((warnings++))
    fi
    
    echo ""  # Clear progress line
    
    # Deep scan for remaining items
    module_log "INFO" "Performing final verification scan..."
    perform_deep_system_scan
    
    # Provide keychain guidance
    provide_keychain_cleanup_guidance
    
    # Calculate duration and display summary
    local end_time
    end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    display_operation_summary "Complete Cursor Removal" $((completed_steps - errors - warnings)) $warnings $errors $total_steps $duration
    
    if [[ $errors -eq 0 ]]; then
        module_log "SUCCESS" "Complete removal process finished successfully"
        return 0
    else
        module_log "ERROR" "Complete removal process finished with $errors errors"
        return 1
    fi
}

# Module initialization and export
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    # Being sourced, export functions
    export -f perform_complete_cursor_removal
    export -f perform_deep_system_scan
    export -f cleanup_coredata_caches
    export -f terminate_all_cursor_processes
    export COMPLETE_REMOVAL_LOADED=true
    module_log "DEBUG" "Complete removal module loaded successfully"
else
    # Being executed directly
    echo "Complete Removal Module v$MODULE_VERSION"
    echo "This module must be sourced, not executed directly"
    exit 1
fi 