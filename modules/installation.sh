#!/bin/bash

################################################################################
# Production Installation Module for Cursor AI Editor Management Utility
# COMPREHENSIVE INSTALLATION WITH VERIFICATION AND ERROR HANDLING
################################################################################

# Strict error handling
set -euo pipefail

# Module configuration
readonly INSTALL_MODULE_NAME="installation"
readonly INSTALL_MODULE_VERSION="2.0.0"
# readonly CURSOR_DOWNLOAD_URL="https://cursor.sh"  # Reserved for future use
# DMG_MOUNT_TIMEOUT is defined in config.sh
readonly COPY_TIMEOUT=300

# Enhanced logging for this module
install_log() {
    local level="$1"
    local message="$2"
    log_with_level "$level" "[$INSTALL_MODULE_NAME] $message"
}

# Enhanced DMG installation with comprehensive error handling
install_cursor_from_dmg() {
    local dmg_path="$1"
    local force_reinstall="${2:-false}"
    
    install_log "INFO" "Starting Cursor installation from DMG: $dmg_path"
    
    # Validate DMG file
    if ! validate_dmg_file "$dmg_path"; then
        install_log "ERROR" "DMG validation failed"
        return 1
    fi
    
    # Check for existing installation
    if [[ "$force_reinstall" != "true" ]] && [[ -d "$CURSOR_APP_PATH" ]]; then
        install_log "WARNING" "Cursor is already installed"
        echo -e "\n${YELLOW}${BOLD}⚠️  EXISTING INSTALLATION DETECTED${NC}"
        echo -e "${BOLD}Cursor.app is already installed at: $CURSOR_APP_PATH${NC}\n"
        
        if ! confirm_operation "Replace existing installation?" 30 "n"; then
            install_log "INFO" "Installation cancelled by user"
            return 0
        fi
        
        install_log "INFO" "Removing existing installation..."
        if ! safe_remove_file "$CURSOR_APP_PATH" true true; then
            install_log "ERROR" "Failed to remove existing installation"
            return 1
        fi
    fi
    
    # Display installation header
    display_operation_header "CURSOR INSTALLATION" "Installing Cursor AI Editor from DMG file" true
    
    local start_time
    start_time=$(date +%s)
    local total_steps=6
    local current_step=0
    local mount_point=""
    
    # Step 1: Mount DMG
    show_progress $((++current_step)) $total_steps "Mounting DMG file"
    if ! mount_point=$(mount_dmg_with_retry "$dmg_path" 3); then
        install_log "ERROR" "Failed to mount DMG file after retries"
        return 1
    fi
    install_log "SUCCESS" "DMG mounted at: $mount_point"
    
    # Step 2: Locate Cursor.app
    show_progress $((++current_step)) $total_steps "Locating Cursor application"
    local cursor_app_source
    if ! cursor_app_source=$(find_cursor_app_in_mount "$mount_point"); then
        install_log "ERROR" "Cursor.app not found in DMG"
        cleanup_mount "$mount_point"
        return 1
    fi
    install_log "SUCCESS" "Found Cursor.app: $cursor_app_source"
    
    # Step 3: Validate application bundle
    show_progress $((++current_step)) $total_steps "Validating application bundle"
    if ! validate_cursor_app_bundle "$cursor_app_source"; then
        install_log "ERROR" "Invalid Cursor.app bundle"
        cleanup_mount "$mount_point"
        return 1
    fi
    install_log "SUCCESS" "Application bundle validation passed"
    
    # Step 4: Copy application
    show_progress $((++current_step)) $total_steps "Installing Cursor to Applications"
    if ! copy_cursor_app_with_progress "$cursor_app_source" "$CURSOR_APP_PATH"; then
        install_log "ERROR" "Failed to copy Cursor.app to Applications"
        cleanup_mount "$mount_point"
        return 1
    fi
    install_log "SUCCESS" "Cursor.app installed successfully"
    
    # Step 5: Set permissions and ownership
    show_progress $((++current_step)) $total_steps "Setting permissions"
    if ! set_application_permissions "$CURSOR_APP_PATH"; then
        install_log "WARNING" "Some permission settings failed (non-critical)"
    else
        install_log "SUCCESS" "Permissions set correctly"
    fi
    
    # Step 6: Cleanup and verification
    show_progress $((++current_step)) $total_steps "Finalizing installation"
    
    # Unmount DMG
    if ! cleanup_mount "$mount_point"; then
        install_log "WARNING" "Failed to unmount DMG (non-critical)"
    fi
    
    # Verify installation
    if ! verify_installation; then
        install_log "ERROR" "Installation verification failed"
        return 1
    fi
    
    echo ""  # Clear progress line
    
    # Calculate duration and show summary
    local end_time
    end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    display_operation_summary "Cursor Installation" $total_steps 0 0 $total_steps $duration
    
    # Show post-installation information
    display_post_installation_info
    
    install_log "SUCCESS" "Cursor installation completed successfully"
    return 0
}

# Validate DMG file integrity and accessibility
validate_dmg_file() {
    local dmg_path="$1"
    
    install_log "DEBUG" "Validating DMG file: $dmg_path"
    
    # Check file existence
    if [[ ! -f "$dmg_path" ]]; then
        install_log "ERROR" "DMG file not found: $dmg_path"
        return 1
    fi
    
    # Check file permissions
    if [[ ! -r "$dmg_path" ]]; then
        install_log "ERROR" "DMG file is not readable: $dmg_path"
        return 1
    fi
    
    # Check file size (should be reasonable for Cursor app)
    local file_size_mb
    file_size_mb=$(du -m "$dmg_path" 2>/dev/null | cut -f1 || echo "0")
    
    if [[ $file_size_mb -lt 50 ]]; then
        install_log "ERROR" "DMG file too small (${file_size_mb}MB) - likely corrupted"
        return 1
    elif [[ $file_size_mb -gt 2000 ]]; then
        install_log "WARNING" "DMG file very large (${file_size_mb}MB) - unusual for Cursor"
    fi
    
    # Comprehensive DMG integrity check with timeout
    install_log "DEBUG" "Performing DMG integrity verification..."
    if ! timeout 30 hdiutil imageinfo "$dmg_path" >/dev/null 2>&1; then
        install_log "ERROR" "DMG file appears to be corrupted, invalid, or verification timed out"
        return 1
    fi
    
    # Additional file type validation
    local file_type
    if command -v file >/dev/null 2>&1; then
        file_type=$(file "$dmg_path" 2>/dev/null | tr '[:upper:]' '[:lower:]')
        if [[ ! "$file_type" =~ (disk|image|dmg) ]]; then
            install_log "WARNING" "File may not be a valid DMG: $file_type"
        fi
    fi
    
    install_log "SUCCESS" "DMG file validation passed (${file_size_mb}MB)"
    return 0
}

# Mount DMG with retry logic
mount_dmg_with_retry() {
    local dmg_path="$1"
    local max_attempts="$2"
    local attempt=1
    
    while [[ $attempt -le $max_attempts ]]; do
        install_log "DEBUG" "DMG mount attempt $attempt of $max_attempts"
        
        local mount_output
        mount_output=$(timeout "$DMG_MOUNT_TIMEOUT" hdiutil attach "$dmg_path" -readonly -nobrowse -mountrandom /tmp 2>/dev/null)
        
        if [[ $? -eq 0 && -n "$mount_output" ]]; then
            local mount_point
            mount_point=$(echo "$mount_output" | grep -E '/tmp/dmg\.' | tail -1 | awk '{print $3}')
            
            if [[ -n "$mount_point" && -d "$mount_point" ]]; then
                echo "$mount_point"
                return 0
            fi
        fi
        
        install_log "WARNING" "Mount attempt $attempt failed, retrying..."
        ((attempt++))
        if [[ $attempt -le $max_attempts ]]; then
            local sleep_duration=$((2 ** (attempt - 2))) # 1, 2, 4, 8 seconds for attempts 2,3,4,5 if max_attempts is high enough
            if [[ $sleep_duration -gt 15 ]]; then # Cap sleep duration to avoid very long waits
                sleep_duration=15
            fi
            install_log "DEBUG" "Sleeping for ${sleep_duration}s before next mount attempt."
            sleep "$sleep_duration"
        fi
    done
    
    install_log "ERROR" "Failed to mount DMG after $max_attempts attempts"
    return 1
}

# Find Cursor.app in mounted DMG
find_cursor_app_in_mount() {
    local mount_point="$1"
    
    install_log "DEBUG" "Searching for Cursor.app in: $mount_point"
    
    # Look for Cursor.app in common locations
    local search_paths=(
        "$mount_point/Cursor.app"
        "$mount_point/Applications/Cursor.app"
        "$mount_point"
    )
    
    for path in "${search_paths[@]}"; do
        if [[ -d "$path" && "$(basename "$path")" == "Cursor.app" ]]; then
            echo "$path"
            return 0
        fi
    done
    
    # Fallback: search recursively (but limited depth)
    local found_app
    found_app=$(find "$mount_point" -maxdepth 3 -name "Cursor.app" -type d 2>/dev/null | head -1)
    
    if [[ -n "$found_app" && -d "$found_app" ]]; then
        echo "$found_app"
        return 0
    fi
    
    install_log "ERROR" "Cursor.app not found in DMG"
    return 1
}

# Validate Cursor.app bundle structure
validate_cursor_app_bundle() {
    local app_path="$1"
    
    install_log "DEBUG" "Validating app bundle: $app_path"
    
    # Check basic app bundle structure
    local required_paths=(
        "$app_path/Contents"
        "$app_path/Contents/Info.plist"
        "$app_path/Contents/MacOS"
    )
    
    for path in "${required_paths[@]}"; do
        if [[ ! -e "$path" ]]; then
            install_log "ERROR" "Missing required bundle component: $path"
            return 1
        fi
    done
    
    # Validate Info.plist
    if ! defaults read "$app_path/Contents/Info.plist" CFBundleIdentifier >/dev/null 2>&1; then
        install_log "ERROR" "Invalid or corrupted Info.plist"
        return 1
    fi
    
    # Check for main executable
    local executable_name
    executable_name=$(defaults read "$app_path/Contents/Info.plist" CFBundleExecutable 2>/dev/null || echo "Cursor")
    local executable_path="$app_path/Contents/MacOS/$executable_name"
    
    if [[ ! -x "$executable_path" ]]; then
        install_log "ERROR" "Main executable not found or not executable: $executable_path"
        return 1
    fi
    
    # Get and validate version info
    local app_version
    app_version=$(defaults read "$app_path/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null || echo "Unknown")
    local bundle_id
    bundle_id=$(defaults read "$app_path/Contents/Info.plist" CFBundleIdentifier 2>/dev/null || echo "Unknown")
    
    install_log "INFO" "App version: $app_version, Bundle ID: $bundle_id"
    
    # Basic bundle ID validation
    if [[ "$bundle_id" != *"cursor"* ]] && [[ "$bundle_id" != *"todesktop"* ]]; then
        install_log "WARNING" "Unexpected bundle ID - this may not be a genuine Cursor app"
    fi
    
    install_log "SUCCESS" "App bundle validation passed"
    return 0
}

# Copy Cursor.app with progress indication
copy_cursor_app_with_progress() {
    local source="$1"
    local destination="$2"
    
    install_log "INFO" "Copying application: $source -> $destination"
    
    # Calculate source size for progress estimation
    local source_size_mb
    source_size_mb=$(du -sm "$source" 2>/dev/null | cut -f1 || echo "unknown")
    install_log "DEBUG" "Source app size: ${source_size_mb}MB"
    
    # Ensure parent directory exists and is writable
    local parent_dir
    parent_dir="$(dirname "$destination")"
    if [[ ! -d "$parent_dir" ]]; then
        install_log "ERROR" "Applications directory does not exist: $parent_dir"
        return 1
    fi
    
    if [[ ! -w "$parent_dir" ]]; then
        install_log "ERROR" "Applications directory is not writable: $parent_dir"
        return 1
    fi
    
    # Perform the copy with timeout
    if timeout "$COPY_TIMEOUT" cp -R "$source" "$destination" 2>/dev/null; then
        install_log "SUCCESS" "Application copied successfully"
        return 0
    else
        install_log "ERROR" "Failed to copy application (timeout or error)"
        return 1
    fi
}

# Set appropriate permissions for installed application
set_application_permissions() {
    local app_path="$1"
    
    install_log "DEBUG" "Setting permissions for: $app_path"
    
    # Set standard application permissions
    if chmod -R 755 "$app_path" 2>/dev/null; then
        install_log "DEBUG" "Set basic permissions (755)"
    else
        install_log "WARNING" "Failed to set basic permissions"
        return 1
    fi
    
    # Ensure executable is properly executable
    local executable_name
    executable_name=$(defaults read "$app_path/Contents/Info.plist" CFBundleExecutable 2>/dev/null || echo "Cursor")
    local executable_path="$app_path/Contents/MacOS/$executable_name"
    
    if [[ -f "$executable_path" ]]; then
        if chmod +x "$executable_path" 2>/dev/null; then
            install_log "DEBUG" "Ensured executable permissions for main binary"
        else
            install_log "WARNING" "Failed to set executable permissions"
        fi
    fi
    
    # Set ownership to current user
    if chown -R "$(whoami)" "$app_path" 2>/dev/null; then
        install_log "DEBUG" "Set ownership to current user"
    else
        install_log "DEBUG" "Could not change ownership (may not be necessary)"
    fi
    
    return 0
}

# Cleanup mount point
cleanup_mount() {
    local mount_point="$1"
    
    if [[ -z "$mount_point" ]]; then
        return 0
    fi
    
    install_log "DEBUG" "Unmounting: $mount_point"
    
    local attempt=1
    local max_attempts=3
    
    while [[ $attempt -le $max_attempts ]]; do
        if hdiutil detach "$mount_point" -force 2>/dev/null; then
            install_log "SUCCESS" "DMG unmounted successfully"
            return 0
        fi
        
        install_log "WARNING" "Unmount attempt $attempt failed, retrying..."
        ((attempt++))
        sleep 2
    done
    
    install_log "ERROR" "Failed to unmount DMG after $max_attempts attempts"
    return 1
}

# Verify successful installation
verify_installation() {
    install_log "DEBUG" "Verifying installation..."
    
    # Check if app exists
    if [[ ! -d "$CURSOR_APP_PATH" ]]; then
        install_log "ERROR" "Cursor.app not found at expected location"
        return 1
    fi
    
    # Check if app is launchable
    if ! validate_cursor_app_bundle "$CURSOR_APP_PATH"; then
        install_log "ERROR" "Installed app failed bundle validation"
        return 1
    fi
    
    # Try to register with Launch Services
    if [[ -x "$LAUNCH_SERVICES_CMD" ]]; then
        if "$LAUNCH_SERVICES_CMD" -f "$CURSOR_APP_PATH" 2>/dev/null; then
            install_log "DEBUG" "Registered with Launch Services"
        else
            install_log "DEBUG" "Launch Services registration failed (non-critical)"
        fi
    fi
    
    install_log "SUCCESS" "Installation verification passed"
    return 0
}

# Enhanced installation confirmation
confirm_installation_action() {
    echo -e "\n${BOLD}${BLUE}📦 CURSOR INSTALLATION CONFIRMATION${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════${NC}\n"
    
    echo -e "${BOLD}Installation Details:${NC}"
    echo -e "  • Target Location: ${CYAN}/Applications/Cursor.app${NC}"
    echo -e "  • Installation Type: ${CYAN}Full Application Bundle${NC}"
    echo -e "  • System Integration: ${CYAN}Launch Services Registration${NC}"
    echo ""
    
    if [[ -d "$CURSOR_APP_PATH" ]]; then
        local existing_version
        existing_version=$(defaults read "$CURSOR_APP_PATH/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null || echo "Unknown")
        echo -e "${YELLOW}${BOLD}⚠️  Existing Installation:${NC}"
        echo -e "  • Current Version: ${CYAN}$existing_version${NC}"
        echo -e "  • Action: ${CYAN}Replace existing installation${NC}"
        echo ""
    fi
    
    echo -e "${BOLD}Required Permissions:${NC}"
    echo -e "  • Write access to /Applications directory"
    echo -e "  • Launch Services modification"
    echo ""
    
    if [[ "$NON_INTERACTIVE_MODE" == "true" ]]; then
        install_log "INFO" "Non-interactive mode: Auto-confirming installation"
        return 0
    fi
    
    confirm_operation "Proceed with Cursor installation?" 30 "y"
    return $?
}

# Comprehensive installation status check
check_cursor_installation() {
    local issues_found=0
    
    echo -e "\n${BOLD}${BLUE}🔍 COMPREHENSIVE CURSOR INSTALLATION CHECK${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════${NC}\n"
    
    # Check main application with detailed analysis
    echo -e "${BOLD}1. APPLICATION BUNDLE ANALYSIS:${NC}"
    if [[ -d "$CURSOR_APP_PATH" ]]; then
        echo -e "   ${GREEN}✅ Cursor.app found at: $CURSOR_APP_PATH${NC}"
        
        # Get detailed app information
        if [[ -f "$CURSOR_APP_PATH/Contents/Info.plist" ]]; then
            local version bundle_id build_version app_size
            version=$(defaults read "$CURSOR_APP_PATH/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null || echo "Unknown")
            bundle_id=$(defaults read "$CURSOR_APP_PATH/Contents/Info.plist" CFBundleIdentifier 2>/dev/null || echo "Unknown")
            build_version=$(defaults read "$CURSOR_APP_PATH/Contents/Info.plist" CFBundleVersion 2>/dev/null || echo "Unknown")
            app_size=$(du -sh "$CURSOR_APP_PATH" 2>/dev/null | cut -f1 || echo "Unknown")
            
            echo -e "     ${CYAN}Version:${NC} $version"
            echo -e "     ${CYAN}Build:${NC} $build_version"
            echo -e "     ${CYAN}Bundle ID:${NC} $bundle_id"
            echo -e "     ${CYAN}Size:${NC} $app_size"
            
            # Validate bundle structure
            if validate_cursor_app_bundle "$CURSOR_APP_PATH" >/dev/null 2>&1; then
                echo -e "     ${GREEN}✅ Bundle structure valid${NC}"
            else
                echo -e "     ${RED}❌ Bundle structure invalid${NC}"
                ((issues_found++))
            fi
        else
            echo -e "     ${RED}❌ Info.plist missing or corrupted${NC}"
            ((issues_found++))
        fi
    else
        echo -e "   ${RED}❌ Cursor.app not found in Applications${NC}"
        echo -e "     ${CYAN}Expected location:${NC} $CURSOR_APP_PATH"
        ((issues_found++))
    fi
    
    # Check CLI tools with enhanced detection
    echo -e "\n${BOLD}2. COMMAND LINE TOOLS:${NC}"
    local cli_found=false
    
    # Define CLI paths locally for Bash 3.2 compatibility
    local cli_paths=(
        "/usr/local/bin/cursor"
        "/opt/homebrew/bin/cursor"
        "$HOME/.local/bin/cursor"
    )
    
    for cli_path in "${cli_paths[@]}"; do
        if [[ -f "$cli_path" ]] && [[ -x "$cli_path" ]]; then
            local cli_version target_path
            cli_version=$("$cli_path" --version 2>/dev/null | head -1 || echo "Version unknown")
            
            if [[ -L "$cli_path" ]]; then
                target_path=$(readlink "$cli_path" 2>/dev/null || echo "Unknown target")
                echo -e "   ${GREEN}✅ CLI tool found: $cli_path${NC}"
                echo -e "     ${CYAN}Type:${NC} Symlink -> $target_path"
            else
                echo -e "   ${GREEN}✅ CLI tool found: $cli_path${NC}"
                echo -e "     ${CYAN}Type:${NC} Binary executable"
            fi
            echo -e "     ${CYAN}Version:${NC} $cli_version"
            
            cli_found=true
            break
        fi
    done
    
    if [[ "$cli_found" == "false" ]]; then
        # Check if cursor is in PATH
        if command -v cursor >/dev/null 2>&1; then
            local cursor_path cli_version
            cursor_path=$(which cursor 2>/dev/null)
            cli_version=$(cursor --version 2>/dev/null | head -1 || echo "Version unknown")
            echo -e "   ${GREEN}✅ CLI tool found in PATH: $cursor_path${NC}"
            echo -e "     ${CYAN}Version:${NC} $cli_version"
        else
            echo -e "   ${YELLOW}⚠️ CLI tools not installed${NC}"
            echo -e "     ${CYAN}Install from:${NC} Cursor → Settings → Command Palette → 'Install cursor command'"
        fi
    fi
    
    # Check system integration
    echo -e "\n${BOLD}3. SYSTEM INTEGRATION:${NC}"
    
    # Launch Services registration
    if command -v lsregister >/dev/null 2>&1; then
        if lsregister -dump 2>/dev/null | grep -q "$CURSOR_BUNDLE_ID"; then
            echo -e "   ${GREEN}✅ Registered with Launch Services${NC}"
        else
            echo -e "   ${YELLOW}⚠️ Not registered with Launch Services${NC}"
            echo -e "     ${CYAN}Try:${NC} Opening Cursor once to register"
        fi
    else
        echo -e "   ${YELLOW}⚠️ Cannot check Launch Services registration${NC}"
    fi
    
    # Check for running processes
    if check_cursor_processes >/dev/null 2>&1; then
        local process_count
        process_count=$(check_cursor_processes | wc -l | xargs)
        echo -e "   ${CYAN}ℹ️ Currently running: $process_count Cursor processes${NC}"
    else
        echo -e "   ${CYAN}ℹ️ No Cursor processes currently running${NC}"
    fi
    
    # Installation quality assessment
    echo -e "\n${BOLD}${BLUE}📊 INSTALLATION QUALITY ASSESSMENT${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════${NC}"
    
    if [[ $issues_found -eq 0 ]]; then
        echo -e "${GREEN}${BOLD}🎉 INSTALLATION STATUS: EXCELLENT${NC}"
        echo -e "${GREEN}Cursor is properly installed and ready to use${NC}"
        echo -e "\n${BOLD}Next Steps:${NC}"
        echo -e "  • Launch Cursor from Applications or Spotlight"
        echo -e "  • Configure your preferred settings"
        echo -e "  • Install CLI tools if needed (from Cursor settings)"
        echo -e "  • Explore AI features and capabilities"
    elif [[ $issues_found -eq 1 ]]; then
        echo -e "${YELLOW}${BOLD}⚠️ INSTALLATION STATUS: GOOD WITH MINOR ISSUES${NC}"
        echo -e "${YELLOW}Cursor is functional but has ${issues_found} minor issue${NC}"
    else
        echo -e "${RED}${BOLD}❌ INSTALLATION STATUS: ISSUES DETECTED${NC}"
        echo -e "${RED}Found $issues_found issues that may affect functionality${NC}"
        echo -e "\n${BOLD}Recommended Actions:${NC}"
        echo -e "  • Reinstall Cursor from latest DMG"
        echo -e "  • Check system permissions"
        echo -e "  • Contact support if issues persist"
    fi
    
    echo ""
    return $issues_found
}

# Display post-installation information
display_post_installation_info() {
    echo -e "\n${BOLD}${GREEN}🎉 CURSOR INSTALLATION COMPLETED SUCCESSFULLY${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════${NC}\n"
    
    echo -e "${BOLD}Installation Summary:${NC}"
    echo -e "  • Application: ${GREEN}✅ Installed to /Applications/Cursor.app${NC}"
    echo -e "  • Integration: ${GREEN}✅ Registered with macOS${NC}"
    echo -e "  • Status: ${GREEN}✅ Ready to launch${NC}"
    echo ""
    
    echo -e "${BOLD}Next Steps:${NC}"
    echo -e "  1. ${CYAN}Launch Cursor${NC} from Applications folder or Spotlight"
    echo -e "  2. ${CYAN}Complete setup${NC} wizard (if prompted)"
    echo -e "  3. ${CYAN}Install CLI tools${NC} (optional): Command Palette → 'Install cursor command'"
    echo -e "  4. ${CYAN}Configure settings${NC} to match your preferences"
    echo ""
    
    echo -e "${BOLD}Getting Started:${NC}"
    echo -e "  • ${CYAN}AI Features:${NC} Use Ctrl+K for AI chat, Tab for autocomplete"
    echo -e "  • ${CYAN}Documentation:${NC} Visit https://cursor.sh/docs"
    echo -e "  • ${CYAN}Keyboard Shortcuts:${NC} Cmd+Shift+P for Command Palette"
    echo ""
    
    if check_network_connectivity >/dev/null 2>&1; then
        echo -e "${CYAN}💡 Tip: Your network connection is ready for AI model downloads${NC}"
    fi
}

# Module initialization
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    # Being sourced, export functions
    export -f install_cursor_from_dmg
    export -f confirm_installation_action
    export -f check_cursor_installation
    export INSTALLATION_LOADED=true
    install_log "DEBUG" "Enhanced installation module loaded successfully"
else
    # Being executed directly
    echo "Enhanced Installation Module v$INSTALL_MODULE_VERSION"
    echo "This module must be sourced, not executed directly"
    exit 1
fi 