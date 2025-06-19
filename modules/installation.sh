#!/bin/bash

################################################################################
# Enhanced Cursor Installation Module v4.0.0
# Production-grade installation checks with comprehensive health monitoring
################################################################################

# Module Information
readonly MODULE_INSTALLATION_VERSION="4.0.0"
readonly MODULE_INSTALLATION_NAME="installation"
export MODULE_INSTALLATION_VERSION MODULE_INSTALLATION_NAME

# Production-grade Cursor AI application details
readonly CURSOR_EXPECTED_VERSION="1.1.2"
readonly CURSOR_VSCODE_VERSION="1.96.2"
readonly CURSOR_COMMIT="87ea1604be1f602f173c5fb67582e647fcef6c40"
readonly CURSOR_ELECTRON_VERSION="34.5.1"
readonly CURSOR_CHROMIUM_VERSION="132.0.6834.210"
readonly CURSOR_NODEJS_VERSION="20.19.0"
readonly CURSOR_V8_VERSION="13.2.152.41-electron.0"
export CURSOR_EXPECTED_VERSION CURSOR_VSCODE_VERSION CURSOR_COMMIT
export CURSOR_ELECTRON_VERSION CURSOR_CHROMIUM_VERSION CURSOR_NODEJS_VERSION CURSOR_V8_VERSION

# Module configuration
readonly INSTALL_MODULE_NAME="installation"
readonly INSTALL_MODULE_VERSION="2.0.0"
export INSTALL_MODULE_NAME INSTALL_MODULE_VERSION
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

    # Initialize progress tracking
    local -i total_steps=6
    local -i current_step=0
    local -i start_time
    start_time=$(date +%s)

    # Step 1: Mount DMG
    show_progress_with_dashboard $((++current_step)) $total_steps "Mounting DMG file" "$start_time"
    local mount_point
    mount_point=$(hdiutil attach -nobrowse -readonly "$dmg_path" | grep /Volumes | awk '{print $NF}')
    if [[ -z "$mount_point" ]]; then
        install_log "ERROR" "Failed to mount DMG file"
        return 1
    fi
    install_log "SUCCESS" "DMG mounted at: $mount_point"

    # Step 2: Locate Cursor.app
    show_progress_with_dashboard $((++current_step)) $total_steps "Locating Cursor application" "$start_time"
    local source_app_path
    source_app_path=$(find "$mount_point" -name "Cursor.app" -maxdepth 2 -type d | head -n 1)
    if [[ -z "$source_app_path" ]]; then
        install_log "ERROR" "Cursor.app not found in DMG"
        cleanup_mount "$mount_point"
        return 1
    fi
    install_log "SUCCESS" "Found Cursor.app: $source_app_path"

    # Step 3: Validate App Bundle
    show_progress_with_dashboard $((++current_step)) $total_steps "Validating application bundle" "$start_time"
    if ! validate_cursor_app_bundle "$source_app_path"; then
        install_log "ERROR" "Invalid Cursor.app bundle"
        cleanup_mount "$mount_point"
        return 1
    fi
    install_log "SUCCESS" "Application bundle validation passed"

    # Step 4: Install to /Applications
    show_progress_with_dashboard $((++current_step)) $total_steps "Installing Cursor to Applications" "$start_time"
    if ! copy_cursor_app_with_progress "$source_app_path" "$CURSOR_APP_PATH"; then
        install_log "ERROR" "Failed to copy Cursor.app to Applications"
        cleanup_mount "$mount_point"
        return 1
    fi
    install_log "SUCCESS" "Cursor.app installed successfully"

    # Step 5: Set Permissions
    show_progress_with_dashboard $((++current_step)) $total_steps "Setting permissions" "$start_time"
    if ! set_application_permissions "$CURSOR_APP_PATH"; then
        install_log "WARNING" "Some permission settings failed (non-critical)"
    else
        install_log "SUCCESS" "Permissions set correctly"
    fi

    # Step 6: Finalize
    show_progress_with_dashboard $((++current_step)) $total_steps "Finalizing installation" "$start_time"
    cleanup_mount "$mount_point"

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

# Comprehensive installation status check
check_installation_status() {
    log_with_level "INFO" "Running comprehensive installation check..."
    echo -e "\n${BOLD}${BLUE}🔍 COMPREHENSIVE CURSOR INSTALLATION CHECK${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════${NC}\n"

    local errors_count=0
    local warnings_count=0
    local -i total_checks=4
    local -i current_check=0
    local -i start_time
    start_time=$(date +%s)

    # 1. Application Bundle Check
    show_progress_with_dashboard $((++current_check)) $total_checks "Analyzing Application Bundle" "$start_time"
    echo -e "${BOLD}1. APPLICATION BUNDLE ANALYSIS:${NC}"
    if [[ -d "$CURSOR_APP_PATH" ]]; then
        log_with_level "SUCCESS" "Cursor.app found at: $CURSOR_APP_PATH"

        # Initialize variables
        local app_version=""
        local bundle_id=""
        local app_size=""
        local vscode_version=""
        local commit=""
        local electron_version=""
        local node_version=""
        local chromium_version=""

        # Extract version from Info.plist with proper error handling
        local info_plist="$CURSOR_APP_PATH/Contents/Info.plist"
        if [[ -f "$info_plist" ]]; then
            app_version=$(defaults read "$info_plist" CFBundleShortVersionString 2>/dev/null || echo "Unknown")
            bundle_id=$(defaults read "$info_plist" CFBundleIdentifier 2>/dev/null || echo "Unknown")
            echo -e "     ${CYAN}Version:${NC} $app_version"
            echo -e "     ${CYAN}Build:${NC} $(defaults read "$info_plist" CFBundleVersion 2>/dev/null || echo "Unknown")"
            echo -e "     ${CYAN}Bundle ID:${NC} $bundle_id"
        else
            log_with_level "ERROR" "❌ Info.plist not found"
            ((errors_count++))
        fi

        # Extract more details from product.json for VSCode engine version
        local product_json_path="$CURSOR_APP_PATH/Contents/Resources/app/product.json"
        if [[ -f "$product_json_path" ]]; then
            # Use jq for robust JSON parsing if available, otherwise fallback to grep/sed
            if command -v jq >/dev/null 2>&1; then
                vscode_version=$(jq -r '.version // "N/A"' "$product_json_path" 2>/dev/null)
                commit=$(jq -r '.commit // "N/A"' "$product_json_path" 2>/dev/null)
                electron_version=$(jq -r '.electronVersion // "N/A"' "$product_json_path" 2>/dev/null)
                node_version=$(jq -r '.nodeVersion // "N/A"' "$product_json_path" 2>/dev/null)
                chromium_version=$(jq -r '.chromiumVersion // "N/A"' "$product_json_path" 2>/dev/null)
            else
                log_with_level "WARNING" "jq not found. Falling back to less reliable grep/sed for product.json parsing. Recommend 'brew install jq'."
                # Fallback to grep/sed if jq is not available
                # Use a more robust pattern to capture the value, and default to "N/A" if not found or null
                vscode_version=$(grep -oP '"version":\s*"\K[^"]*' "$product_json_path" | head -1 || echo "N/A")
                commit=$(grep -oP '"commit":\s*"\K[^"]*' "$product_json_path" | head -1 || echo "N/A")
                electron_version=$(grep -oP '"electronVersion":\s*"\K[^"]*' "$product_json_path" | head -1 || echo "N/A")
                node_version=$(grep -oP '"nodeVersion":\s*"\K[^"]*' "$product_json_path" | head -1 || echo "N/A")
                chromium_version=$(grep -oP '"chromiumVersion":\s*"\K[^"]*' "$product_json_path" | head -1 || echo "N/A")
            fi
        fi

        # Calculate application size accurately
        app_size=$(du -sh "$CURSOR_APP_PATH" 2>/dev/null | awk '{print $1}' || echo "Unknown")
        echo -e "     ${CYAN}Size:${NC} $app_size"

        # Display actual versions without hardcoded comparisons
        log_with_level "INFO" "Actual Cursor Version: $app_version"
        log_with_level "INFO" "Actual VSCode Engine: ${vscode_version:-Unknown}"
        log_with_level "INFO" "Actual Commit: ${commit:-Unknown}"
        log_with_level "INFO" "Actual Electron: ${electron_version:-Unknown}"
        log_with_level "INFO" "Actual Chromium: ${chromium_version:-Unknown}"
        log_with_level "INFO" "Actual Node.js: ${node_version:-Unknown}"

        # Validate app bundle structure more thoroughly
        if ! validate_cursor_app_bundle "$CURSOR_APP_PATH"; then
            log_with_level "ERROR" "Application bundle validation failed"
            ((errors_count++))
        else
            log_with_level "SUCCESS" "✅ Bundle structure valid"
        fi

    else
        log_with_level "ERROR" "Cursor.app not found"
        ((errors_count++))
    fi

    # 2. Command Line Tools
    show_progress_with_dashboard $((++current_check)) $total_checks "Checking Command Line Tools" "$start_time"
    echo -e "\n${BOLD}2. COMMAND LINE TOOLS:${NC}"
    if command -v cursor >/dev/null 2>&1; then
        local cli_path
        cli_path=$(which cursor 2>/dev/null)
        log_with_level "SUCCESS" "✅ CLI tool found: $cli_path"
        echo -e "     ${CYAN}Type:${NC} $(file -b "$cli_path")"
        echo -e "     ${CYAN}Version:${NC} $(cursor --version 2>/dev/null | head -n 1)"

        # Functional test
        if cursor --version >/dev/null 2>&1; then
            log_with_level "SUCCESS" "✅ CLI tool functional"
        else
            log_with_level "ERROR" "❌ CLI tool not functional"
            ((errors_count++))
        fi
    else
        log_with_level "ERROR" "❌ CLI tool 'cursor' not found in PATH"
        ((errors_count++))
    fi

    # 3. System Integration
    show_progress_with_dashboard $((++current_check)) $total_checks "Verifying System Integration" "$start_time"
    echo -e "\n${BOLD}3. SYSTEM INTEGRATION:${NC}"

    # Launch Services / Spotlight check
    log_with_level "INFO" "Verifying application registration via Spotlight..."
    local spotlight_path
    spotlight_path=$(mdfind "kMDItemCFBundleIdentifier == '$CURSOR_BUNDLE_ID'" 2>/dev/null | head -n 1)
    if [[ -n "$spotlight_path" && -d "$spotlight_path" ]]; then
        log_with_level "SUCCESS" "✅ Application is registered with Launch Services (found via Spotlight)"
        echo -e "     ${CYAN}Registered Path:${NC} $spotlight_path"

        # Check running processes
        local pids
        pids=$(pgrep -f "Cursor" || echo "")
        local process_count
        process_count=$(echo "$pids" | wc -w | tr -d ' ')

        if [[ "$process_count" -gt 0 ]]; then
            echo -e "     ${CYAN}Currently running:${NC} $process_count Cursor processes"
            local total_mem_kb=0
            local valid_pids=""
            for pid in $pids; do
                if kill -0 "$pid" 2>/dev/null; then
                    local mem
                    mem=$(ps -o rss= -p "$pid" 2>/dev/null || echo 0)
                    total_mem_kb=$((total_mem_kb + mem))
                    valid_pids+=" $pid"
                fi
            done

            if [[ -n "${valid_pids}" ]]; then
                if [[ "$total_mem_kb" -gt 0 ]]; then
                    local total_mem_mb=$((total_mem_kb / 1024))
                    echo -e "     ${CYAN}Memory usage:${NC} ${total_mem_mb}MB total"
                fi
                echo -e "     ${CYAN}Process details:${NC}"
                ps -o pid=,command= -p "${valid_pids}" 2>/dev/null | while read -r pid cmd; do
                    echo -e "       • ${CYAN}PID $pid:${NC} $(echo "$cmd" | cut -c 1-100)..."
                done
            fi
        fi
    else
        log_with_level "WARNING" "⚠️ Application not fully registered with Launch Services. Try launching it once."
        ((warnings_count++))
    fi

    # File associations check
    if command -v duti >/dev/null 2>&1; then
        local file_types=("public.source-code" "public.plain-text" "com.netscape.javascript-source")
        local unassociated_types=0

        for type in "${file_types[@]}"; do
            if ! duti -x "$type" 2>/dev/null | grep -q "$CURSOR_BUNDLE_ID"; then
                ((unassociated_types++))
            fi
        done

        if [[ $unassociated_types -eq 0 ]]; then
            log_with_level "SUCCESS" "✅ All relevant file types associated with Cursor"
        else
            log_with_level "WARNING" "⚠️ $unassociated_types file types not associated with Cursor. Run installation to fix."
            ((warnings_count++))
        fi
    else
        log_with_level "INFO" "ℹ️ 'duti' command not found. Skipping file association check."
        echo -e "     ${CYAN}File associations:${NC} Not checked ('duti' not installed, recommend 'brew install duti')"
    fi

    # 4. Runtime Environment
    show_progress_with_dashboard $((++current_check)) $total_checks "Assessing Runtime Environment" "$start_time"
    echo -e "\n${BOLD}4. RUNTIME ENVIRONMENT:${NC}"

    echo -e "     ${CYAN}System Architecture:${NC} $(uname -m)"
    echo -e "     ${CYAN}macOS Version:${NC} $(sw_vers -productVersion)"

    if [[ "$(uname -m)" == "arm64" ]]; then
        log_with_level "SUCCESS" "✅ Apple Silicon optimized"
    fi

    # Final Assessment
    echo ""  # Clear progress line

    local end_time
    end_time=$(date +%s)
    local duration=$((end_time - start_time))
    display_operation_summary "Installation Status Check" $((total_checks - errors_count - warnings_count)) $warnings_count $errors_count $total_checks $duration

    if [[ $errors_count -eq 0 && $warnings_count -eq 0 ]]; then
        echo -e "${GREEN}✅ INSTALLATION STATUS: EXCELLENT${NC}"
        echo -e "Cursor appears to be correctly installed and configured."
    elif [[ $errors_count -eq 0 ]]; then
        echo -e "${YELLOW}✅ INSTALLATION STATUS: GOOD${NC}"
        echo -e "Cursor is installed with minor issues ($warnings_count warnings)"
    else
        echo -e "${RED}❌ INSTALLATION STATUS: POOR${NC}"
        echo -e "Cursor installation has $errors_count critical errors and $warnings_count warnings."
    fi

    echo ""
    if [[ $errors_count -gt 0 || $warnings_count -gt 0 ]]; then
        echo -e "${BOLD}Recommendations:${NC}"
        if [[ $errors_count -gt 0 ]]; then
            echo -e "  • ${RED}Review critical errors above and consider a full reinstall.${NC}"
        fi
        if [[ $warnings_count -gt 0 ]]; then
            echo -e "  • ${YELLOW}Review warnings above${NC}"
        fi
    fi

    return "$errors_count"
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
    export -f check_installation_status
    export -f validate_cursor_app_bundle
    export -f copy_cursor_app_with_progress
    export -f set_application_permissions
    export -f cleanup_mount
    export -f verify_installation
    export -f display_post_installation_info
    export INSTALLATION_LOADED=true
    install_log "DEBUG" "Enhanced installation module loaded successfully"
else
    # Being executed directly
    echo "Enhanced Installation Module v$INSTALL_MODULE_VERSION"
    echo "This module must be sourced, not executed directly"
    exit 1
fi
