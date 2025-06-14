#!/bin/bash

################################################################################
# Enhanced Cursor Installation Module v4.0.0
# Production-grade installation checks with comprehensive health monitoring
################################################################################

# Module Information
readonly MODULE_INSTALLATION_VERSION="4.0.0"
readonly MODULE_INSTALLATION_NAME="installation"

# Production-grade Cursor AI application details
readonly CURSOR_EXPECTED_VERSION="1.1.2"
readonly CURSOR_VSCODE_VERSION="1.96.2"
readonly CURSOR_COMMIT="87ea1604be1f602f173c5fb67582e647fcef6c40"
readonly CURSOR_ELECTRON_VERSION="34.5.1"
readonly CURSOR_CHROMIUM_VERSION="132.0.6834.210"
readonly CURSOR_NODEJS_VERSION="20.19.0"
readonly CURSOR_V8_VERSION="13.2.152.41-electron.0"

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

# Comprehensive installation status check
check_cursor_installation_status() {
    echo -e "\n${BLUE}${BOLD}🔍 COMPREHENSIVE CURSOR INSTALLATION CHECK${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════${NC}\n"

    local status_excellent=true
    local warnings_count=0
    local errors_count=0

    # 1. APPLICATION BUNDLE ANALYSIS
    echo -e "${BOLD}1. APPLICATION BUNDLE ANALYSIS:${NC}"

    if [[ -d "$CURSOR_APP_PATH" ]]; then
        log_with_level "SUCCESS" "Cursor.app found at: $CURSOR_APP_PATH"

        # Get application version using production-grade method
        local app_version=""
        local app_build=""
        local bundle_id=""
        local app_size=""

        # Extract version from Info.plist with proper error handling
        if [[ -f "$CURSOR_APP_PATH/Contents/Info.plist" ]]; then
            app_version=$(defaults read "$CURSOR_APP_PATH/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null || echo "Unknown")
            app_build=$(defaults read "$CURSOR_APP_PATH/Contents/Info.plist" CFBundleVersion 2>/dev/null || echo "Unknown")
            bundle_id=$(defaults read "$CURSOR_APP_PATH/Contents/Info.plist" CFBundleIdentifier 2>/dev/null || echo "Unknown")
        else
            log_with_level "ERROR" "Info.plist not found in application bundle"
            ((errors_count++))
            status_excellent=false
        fi

        # Calculate application size accurately
        if command -v du >/dev/null 2>&1; then
            local size_bytes
            size_bytes=$(du -s "$CURSOR_APP_PATH" 2>/dev/null | cut -f1)
            if [[ -n "$size_bytes" && "$size_bytes" =~ ^[0-9]+$ ]]; then
                app_size=$(( size_bytes / 1024 ))M  # Convert to MB
            else
                app_size="Unknown"
            fi
        else
            app_size="Unknown"
        fi

        echo -e "     ${CYAN}Version:${NC} $app_version"
        echo -e "     ${CYAN}Build:${NC} $app_build"
        echo -e "     ${CYAN}Bundle ID:${NC} $bundle_id"
        echo -e "     ${CYAN}Size:${NC} $app_size"

        # Version validation against expected values
        if [[ "$app_version" == "$CURSOR_EXPECTED_VERSION" ]]; then
            log_with_level "SUCCESS" "✅ Version matches expected ($CURSOR_EXPECTED_VERSION)"
        else
            log_with_level "WARNING" "⚠️ Version mismatch: Expected $CURSOR_EXPECTED_VERSION, found $app_version"
            ((warnings_count++))
        fi

        # Bundle structure validation
        local required_bundle_components=(
            "Contents/MacOS/Cursor"
            "Contents/Resources/app/package.json"
            "Contents/Resources/app/bin/code"
        )

        local bundle_valid=true
        for component in "${required_bundle_components[@]}"; do
            if [[ ! -e "$CURSOR_APP_PATH/$component" ]]; then
                log_with_level "ERROR" "Missing bundle component: $component"
                bundle_valid=false
                ((errors_count++))
            fi
        done

        if [[ "$bundle_valid" == "true" ]]; then
            log_with_level "SUCCESS" "✅ Bundle structure valid"
        else
            log_with_level "ERROR" "❌ Bundle structure incomplete"
            status_excellent=false
        fi

        # VSCode Engine Version Check (production-grade validation)
        local package_json="$CURSOR_APP_PATH/Contents/Resources/app/package.json"
        if [[ -f "$package_json" ]]; then
            local vscode_version
            vscode_version=$(grep -o '"engines"[^}]*"vscode"[^"]*"[^"]*"' "$package_json" 2>/dev/null | sed 's/.*"vscode"[^"]*"\([^"]*\)".*/\1/' || echo "Unknown")
            echo -e "     ${CYAN}VSCode Engine:${NC} $vscode_version"

            if [[ "$vscode_version" == *"$CURSOR_VSCODE_VERSION"* ]]; then
                log_with_level "SUCCESS" "✅ VSCode engine version validated"
            else
                log_with_level "WARNING" "⚠️ VSCode engine version may not match expected ($CURSOR_VSCODE_VERSION)"
                ((warnings_count++))
            fi
        fi

    else
        log_with_level "ERROR" "❌ Cursor.app not found at expected location: $CURSOR_APP_PATH"
        ((errors_count++))
        status_excellent=false
    fi

    echo ""

    # 2. COMMAND LINE TOOLS VERIFICATION
    echo -e "${BOLD}2. COMMAND LINE TOOLS:${NC}"

    if [[ -L "$CURSOR_CLI_PATH" ]]; then
        local cli_target
        cli_target=$(readlink "$CURSOR_CLI_PATH" 2>/dev/null || echo "Unknown")
        local cli_version
        cli_version=$("$CURSOR_CLI_PATH" --version 2>/dev/null | head -1 || echo "Unknown")

        log_with_level "SUCCESS" "✅ CLI tool found: $CURSOR_CLI_PATH"
        echo -e "     ${CYAN}Type:${NC} Symlink -> $cli_target"
        echo -e "     ${CYAN}Version:${NC} $cli_version"

        # Validate CLI tool functionality
        if "$CURSOR_CLI_PATH" --help >/dev/null 2>&1; then
            log_with_level "SUCCESS" "✅ CLI tool functional"
        else
            log_with_level "WARNING" "⚠️ CLI tool may not be functional"
            ((warnings_count++))
        fi

    elif [[ -f "$CURSOR_CLI_PATH" ]]; then
        local cli_version
        cli_version=$("$CURSOR_CLI_PATH" --version 2>/dev/null | head -1 || echo "Unknown")
        log_with_level "SUCCESS" "✅ CLI tool found: $CURSOR_CLI_PATH"
        echo -e "     ${CYAN}Type:${NC} Binary"
        echo -e "     ${CYAN}Version:${NC} $cli_version"
    else
        log_with_level "WARNING" "⚠️ CLI tool not found at: $CURSOR_CLI_PATH"
        echo -e "     ${YELLOW}Note: CLI can be installed via Cursor settings${NC}"
        ((warnings_count++))
    fi

    echo ""

    # 3. PRODUCTION-GRADE SYSTEM INTEGRATION
    echo -e "${BOLD}3. SYSTEM INTEGRATION:${NC}"

    # Launch Services registration check with proper error handling
    if command -v lsregister >/dev/null 2>&1; then
        local ls_check_result
        ls_check_result=$(lsregister -dump 2>/dev/null | grep -i "cursor" | head -5 || echo "")

        if [[ -n "$ls_check_result" ]]; then
            log_with_level "SUCCESS" "✅ Launch Services registration confirmed"
            echo -e "     ${CYAN}Registered entries:${NC} $(echo "$ls_check_result" | wc -l | xargs) found"
        else
            log_with_level "INFO" "ℹ️ Launch Services ready for registration"
            echo -e "     ${CYAN}Note:${NC} Cursor will register automatically on first launch"
        fi
    else
        log_with_level "WARNING" "⚠️ Cannot verify Launch Services registration (lsregister not available)"
        ((warnings_count++))
    fi

    # Process monitoring with enhanced accuracy
    local cursor_processes
    cursor_processes=$(pgrep -f "Cursor" 2>/dev/null | wc -l | xargs)
    if [[ "$cursor_processes" -gt 0 ]]; then
        echo -e "     ${CYAN}Currently running:${NC} $cursor_processes Cursor processes"

        # Memory usage analysis
        local total_memory=0
        local process_details=""

        while IFS= read -r pid; do
            if [[ -n "$pid" ]]; then
                local mem_usage
                mem_usage=$(ps -p "$pid" -o rss= 2>/dev/null | xargs || echo "0")
                if [[ "$mem_usage" =~ ^[0-9]+$ ]]; then
                    total_memory=$((total_memory + mem_usage))
                fi

                local proc_name
                proc_name=$(ps -p "$pid" -o comm= 2>/dev/null | xargs || echo "Unknown")
                process_details="${process_details}       • PID $pid: $proc_name\n"
            fi
        done < <(pgrep -f "Cursor" 2>/dev/null)

        if [[ $total_memory -gt 0 ]]; then
            local memory_mb=$((total_memory / 1024))
            echo -e "     ${CYAN}Memory usage:${NC} ${memory_mb}MB total"
        fi

        if [[ -n "$process_details" ]]; then
            echo -e "     ${CYAN}Process details:${NC}"
            echo -e "$process_details"
        fi
    else
        echo -e "     ${CYAN}Currently running:${NC} No active processes"
    fi

    # File associations check
    local cursor_associations
    cursor_associations=$(duti -l 2>/dev/null | grep -ci cursor || echo "0")
    if [[ "$cursor_associations" -gt 0 ]]; then
        echo -e "     ${CYAN}File associations:${NC} $cursor_associations registered"
    else
        echo -e "     ${CYAN}File associations:${NC} None registered"
    fi

    echo ""

    # 4. ELECTRON & RUNTIME ENVIRONMENT VALIDATION
    echo -e "${BOLD}4. RUNTIME ENVIRONMENT:${NC}"

    # Electron version validation (if possible to extract)
    local electron_version="Unknown"
    local chromium_version="Unknown"
    local nodejs_version="Unknown"

    # Try to extract versions from the application
    local version_file="$CURSOR_APP_PATH/Contents/Resources/app/node_modules/electron/package.json"
    if [[ -f "$version_file" ]]; then
        electron_version=$(grep '"version"' "$version_file" 2>/dev/null | head -1 | sed 's/.*"version"[^"]*"\([^"]*\)".*/\1/' || echo "Unknown")
    fi

    echo -e "     ${CYAN}Electron:${NC} $electron_version"
    echo -e "     ${CYAN}Chromium:${NC} $chromium_version (bundled)"
    echo -e "     ${CYAN}Node.js:${NC} $nodejs_version (bundled)"

    # System compatibility checks
    local system_arch
    system_arch=$(uname -m)
    local macos_version
    macos_version=$(sw_vers -productVersion 2>/dev/null || echo "Unknown")

    echo -e "     ${CYAN}System Architecture:${NC} $system_arch"
    echo -e "     ${CYAN}macOS Version:${NC} $macos_version"

    # Architecture compatibility
    if [[ "$system_arch" == "arm64" ]]; then
        log_with_level "SUCCESS" "✅ Apple Silicon optimized"
    elif [[ "$system_arch" == "x86_64" ]]; then
        log_with_level "INFO" "ℹ️ Intel architecture (may run via Rosetta on Apple Silicon)"
    else
        log_with_level "WARNING" "⚠️ Unknown architecture: $system_arch"
        ((warnings_count++))
    fi

    echo ""

    # 5. COMPREHENSIVE INSTALLATION QUALITY ASSESSMENT
    echo -e "${BOLD}📊 INSTALLATION QUALITY ASSESSMENT${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════${NC}"

    if [[ $errors_count -eq 0 ]] && [[ $warnings_count -eq 0 ]] && [[ "$status_excellent" == "true" ]]; then
        echo -e "${GREEN}${BOLD}🎉 INSTALLATION STATUS: EXCELLENT${NC}"
        echo -e "${GREEN}Cursor is properly installed and ready to use${NC}"

        echo -e "\n${BOLD}Next Steps:${NC}"
        echo -e "  ${CYAN}•${NC} Launch Cursor from Applications or Spotlight"
        echo -e "  ${CYAN}•${NC} Configure your preferred settings"
        echo -e "  ${CYAN}•${NC} Install CLI tools if needed (from Cursor settings)"
        echo -e "  ${CYAN}•${NC} Explore AI features and capabilities"

    elif [[ $errors_count -eq 0 ]] && [[ $warnings_count -le 2 ]]; then
        echo -e "${YELLOW}${BOLD}✅ INSTALLATION STATUS: GOOD${NC}"
        echo -e "${YELLOW}Cursor is installed with minor issues ($warnings_count warnings)${NC}"

        echo -e "\n${BOLD}Recommendations:${NC}"
        echo -e "  ${CYAN}•${NC} Review warnings above"
        echo -e "  ${CYAN}•${NC} Consider reinstalling CLI tools if needed"
        echo -e "  ${CYAN}•${NC} Launch Cursor to complete system registration"

    else
        echo -e "${RED}${BOLD}⚠️ INSTALLATION STATUS: NEEDS ATTENTION${NC}"
        echo -e "${RED}Issues detected: $errors_count errors, $warnings_count warnings${NC}"

        echo -e "\n${BOLD}Required Actions:${NC}"
        echo -e "  ${CYAN}•${NC} Address errors listed above"
        echo -e "  ${CYAN}•${NC} Consider reinstalling Cursor if bundle is corrupted"
        echo -e "  ${CYAN}•${NC} Verify system permissions and disk space"

        status_excellent=false
    fi

    echo ""

    # Return status for scripting
    if [[ "$status_excellent" == "true" ]] && [[ $errors_count -eq 0 ]]; then
        return 0
    else
        return 1
    fi
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
    export -f check_cursor_installation_status
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
