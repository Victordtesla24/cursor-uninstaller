#!/bin/bash

################################################################################
# Installation Module - Cursor Editor Installation & Verification Functions
# Part of Cursor Uninstaller Modular Architecture
################################################################################

# Check if Cursor is currently installed
check_cursor_installation() {
    echo -e "\n${BOLD}${BLUE}🔍 CURSOR INSTALLATION STATUS CHECK   ${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════${NC}\n"

    local found_issues=0
    local total_checks=0

    # Check main application
    ((total_checks++))
    echo -e "${BOLD}1. CHECKING CURSOR APPLICATION:${NC}"
    
    local cursor_app="/Applications/Cursor.app"
    if [[ -d "$cursor_app" ]]; then
        if [[ -f "$cursor_app/Contents/Info.plist" ]]; then
            local version
            version=$(defaults read "$cursor_app/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null)
            if [[ -n "$version" ]]; then
                local bundle_id
                bundle_id=$(defaults read "$cursor_app/Contents/Info.plist" CFBundleIdentifier 2>/dev/null || echo "Unknown")
                
                # Get app size
                local app_size
                app_size=$(du -sh "$cursor_app" 2>/dev/null | cut -f1 || echo "Unknown")
                
                # Get build info
                local build_version
                build_version=$(defaults read "$cursor_app/Contents/Info.plist" CFBundleVersion 2>/dev/null || echo "Unknown")
                
                log_message "SUCCESS" "✓ Cursor.app found at $cursor_app"
                echo -e "    ${CYAN}Version:${NC} $version (Build: $build_version)"
                echo -e "    ${CYAN}Bundle ID:${NC} $bundle_id"
                echo -e "    ${CYAN}Size:${NC} $app_size"
                echo -e "    ${CYAN}Location:${NC} $cursor_app"
            else
                log_message "WARNING" "⚠ Cursor.app found but version unreadable"
                echo -e "    ${YELLOW}Issue:${NC} Version information not accessible"
                ((found_issues++))
            fi
        else
            log_message "WARNING" "⚠ Cursor.app found but Info.plist missing"
            echo -e "    ${YELLOW}Issue:${NC} Application bundle may be corrupted"
            ((found_issues++))
        fi
    else
        log_message "ERROR" "✗ Cursor.app not found"
        echo -e "    ${RED}Status:${NC} Cursor application is not installed at $cursor_app"
        ((found_issues++))
    fi
    echo ""

    # Check CLI tools and symlinks
    ((total_checks++))
    echo -e "${BOLD}2. CHECKING CURSOR CLI TOOLS:${NC}"
    
    local cursor_binary="/usr/local/bin/cursor"
    local cursor_symlink="/usr/local/bin/code"
    local cli_tools_found=0
    
    # Check main cursor binary
    if [[ -L "$cursor_binary" ]] || [[ -f "$cursor_binary" ]]; then
        log_message "SUCCESS" "✓ Cursor binary found at $cursor_binary"
        
        # Get CLI version if possible
        local cli_version
        cli_version=$("$cursor_binary" --version 2>/dev/null | head -1 || echo "Version unknown")
        echo -e "    ${CYAN}Version:${NC} $cli_version"
        
        # Check if it's a symlink
        if [[ -L "$cursor_binary" ]]; then
            local link_target
            link_target=$(readlink "$cursor_binary")
            echo -e "    ${CYAN}Type:${NC} Symlink -> $link_target"
        else
            echo -e "    ${CYAN}Type:${NC} Binary executable"
        fi
        ((cli_tools_found++))
    fi

    # Check 'code' symlink for VS Code compatibility
    if [[ -L "$cursor_symlink" ]]; then
        local link_target
        link_target=$(readlink "$cursor_symlink")
        if [[ "$link_target" == *"Cursor"* ]] || [[ "$link_target" == *"cursor"* ]]; then
            log_message "SUCCESS" "✓ Cursor 'code' symlink found at $cursor_symlink"
            echo -e "    ${CYAN}Target:${NC} $link_target"
            echo -e "    ${CYAN}Purpose:${NC} VS Code compatibility mode"
            ((cli_tools_found++))
        fi
    fi
    
    # Check other possible locations
    local other_locations=("/opt/homebrew/bin/cursor" "/usr/bin/cursor")
    for location in "${other_locations[@]}"; do
        if [[ -f "$location" ]] && [[ -x "$location" ]]; then
            log_message "INFO" "Additional CLI tool found: $location"
            ((cli_tools_found++))
        fi
    done
    
    # Check PATH
    if command -v cursor >/dev/null 2>&1; then
        local cursor_path
        cursor_path=$(which cursor 2>/dev/null)
        if [[ "$cursor_path" != "$cursor_binary" ]] && [[ "$cursor_path" != "/opt/homebrew/bin/cursor" ]]; then
            log_message "INFO" "Cursor found in PATH: $cursor_path"
            ((cli_tools_found++))
        fi
    fi
    
    if [[ $cli_tools_found -eq 0 ]]; then
        log_message "WARNING" "⚠ No Cursor CLI tools found"
        echo -e "    ${YELLOW}Suggestion:${NC} Install CLI tools from Cursor app or run setup"
        ((found_issues++))
    else
        log_message "SUCCESS" "✓ Found $cli_tools_found CLI tool(s)"
    fi
    echo ""

    # Check user configuration and data
    ((total_checks++))
    echo -e "${BOLD}3. CHECKING USER CONFIGURATION:${NC}"
    
    local config_paths=(
        "$HOME/Library/Application Support/Cursor"
        "$HOME/Library/Preferences/com.todesktop.230313mzl4w4u92.plist"
        "$HOME/Library/Caches/Cursor"
        "$HOME/Library/Saved Application State/com.todesktop.230313mzl4w4u92.savedState"
        "$HOME/.cursor"
        "$HOME/.vscode-cursor"
    )
    
    local configs_found=0
    local total_config_size=0
    
    for config_path in "${config_paths[@]}"; do
        if [[ -e "$config_path" ]]; then
            ((configs_found++))
            local config_size
            config_size=$(du -sh "$config_path" 2>/dev/null | cut -f1 || echo "Unknown")
            echo -e "    ${GREEN}✓${NC} Found: $(basename "$config_path") ($config_size)"
            
            # Count total size (approximate)
            if [[ "$config_size" =~ ^([0-9.]+)([KMGT]?)B?$ ]]; then
                local size_num="${BASH_REMATCH[1]}"
                local size_unit="${BASH_REMATCH[2]}"
                case "$size_unit" in
                    "K") total_config_size=$((total_config_size + ${size_num%.*})) ;;
                    "M") total_config_size=$((total_config_size + ${size_num%.*} * 1024)) ;;
                    "G") total_config_size=$((total_config_size + ${size_num%.*} * 1024 * 1024)) ;;
                    *) total_config_size=$((total_config_size + 1)) ;;
                esac
            fi
        fi
    done
    
    if [[ $configs_found -gt 0 ]]; then
        log_message "SUCCESS" "✓ User configuration detected ($configs_found items)"
        if [[ $total_config_size -gt 0 ]]; then
            local total_size_display
            if [[ $total_config_size -gt 1024 ]]; then
                total_size_display="~$((total_config_size / 1024))MB"
            else
                total_size_display="~${total_config_size}KB"
            fi
            echo -e "    ${CYAN}Total Size:${NC} $total_size_display"
        fi
    else
        log_message "INFO" "ℹ No user configuration found"
        echo -e "    ${YELLOW}Note:${NC} This is normal for fresh installations"
    fi
    echo ""

    # Check system integration
    ((total_checks++))
    echo -e "${BOLD}4. CHECKING SYSTEM INTEGRATION:${NC}"
    
    # Check Launch Services registration
    if command -v lsregister >/dev/null 2>&1; then
        if lsregister -dump 2>/dev/null | grep -qi "cursor"; then
            log_message "SUCCESS" "✓ Launch Services registration found"
            echo -e "    ${CYAN}Status:${NC} Cursor is registered with macOS Launch Services"
        else
            log_message "WARNING" "⚠ No Launch Services registration"
            echo -e "    ${YELLOW}Note:${NC} May need to open Cursor once to register"
        fi
    else
        echo -e "    ${YELLOW}Note:${NC} Launch Services check unavailable"
    fi
    
    # Check running processes
    local cursor_processes=0
    if pgrep -f -i "cursor" >/dev/null 2>&1; then
        cursor_processes=$(pgrep -f -i "cursor" 2>/dev/null | wc -l | xargs)
        log_message "INFO" "🔄 Cursor processes running: $cursor_processes"
        echo -e "    ${CYAN}Status:${NC} Cursor is currently active"
    else
        echo -e "    ${CYAN}Status:${NC} No Cursor processes currently running"
    fi
    
    # Check file associations
    if command -v duti >/dev/null 2>&1; then
        local cursor_associations
        cursor_associations=$(duti -l | grep -c -i cursor)
        if [[ $cursor_associations -gt 0 ]]; then
            echo -e "    ${CYAN}File Associations:${NC} $cursor_associations file types"
        fi
    fi
    echo ""

    # Enhanced verification check
    if [[ $found_issues -eq 0 ]] && [[ -d "$cursor_app" ]]; then
        echo -e "${BOLD}5. RUNNING ENHANCED VERIFICATION:${NC}"
        
        # Check executable permissions
        local cursor_executable="$cursor_app/Contents/MacOS/Cursor"
        if [[ -x "$cursor_executable" ]]; then
            echo -e "    ${GREEN}✓${NC} Main executable is properly configured"
        else
            echo -e "    ${RED}✗${NC} Main executable has permission issues"
            ((found_issues++))
        fi
        
        # Check framework integrity
        local frameworks_dir="$cursor_app/Contents/Frameworks"
        if [[ -d "$frameworks_dir" ]]; then
            local framework_count
            framework_count=$(find "$frameworks_dir" -name "*.framework" | wc -l | xargs)
            echo -e "    ${GREEN}✓${NC} Application frameworks present ($framework_count frameworks)"
        fi
        
        # Check resources
        local resources_dir="$cursor_app/Contents/Resources"
        if [[ -d "$resources_dir" ]]; then
            local resource_count
            resource_count=$(find "$resources_dir" -type f | wc -l | xargs)
            echo -e "    ${GREEN}✓${NC} Application resources present ($resource_count files)"
        fi
        echo ""
    fi

    # Final summary
    echo -e "${BOLD}${BLUE}📊 INSTALLATION CHECK SUMMARY${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════${NC}"
    
    local passed_checks=$((total_checks - found_issues))
    echo -e "${BOLD}Total Checks:${NC} $total_checks"
    echo -e "${BOLD}Passed:${NC} ${GREEN}$passed_checks${NC}"
    echo -e "${BOLD}Issues:${NC} ${RED}$found_issues${NC}"
    
    echo ""
    if [[ $found_issues -eq 0 ]]; then
        log_message "SUCCESS" "🎉 ALL CHECKS PASSED - CURSOR IS PROPERLY INSTALLED"
        echo -e "\n${GREEN}${BOLD}NEXT STEPS:${NC}"
        echo -e "  • Cursor is ready to use with AI assistance"
        echo -e "  • Open Cursor to start coding with intelligent features"
        echo -e "  • Configure your preferred settings and extensions"
        echo -e "  • Try AI-powered code completion and chat features"
        return 0
    elif [[ $found_issues -eq $total_checks ]]; then
        log_message "ERROR" "❌ ALL CHECKS FAILED - CURSOR IS NOT INSTALLED"
        echo -e "\n${RED}${BOLD}INSTALLATION REQUIRED:${NC}"
        echo -e "  • Download Cursor from https://cursor.sh"
        echo -e "  • Install the application to /Applications/"
        echo -e "  • Set up CLI tools if needed"
        echo -e "  • Launch Cursor to complete setup"
        log_message "INFO" "Installation check completed: Cursor not installed ($found_issues of $total_checks checks failed)"
        return 0
    else
        log_message "WARNING" "⚠ PARTIAL INSTALLATION DETECTED - $found_issues ISSUES FOUND"
        echo -e "\n${YELLOW}${BOLD}RECOMMENDED ACTIONS:${NC}"
        echo -e "  • Reinstall Cursor to fix missing components"
        echo -e "  • Set up CLI tools from within the Cursor app"
        echo -e "  • Check system permissions if needed"
        echo -e "  • Try launching Cursor to complete registration"
        log_message "INFO" "Installation check completed: Partial installation detected ($found_issues of $total_checks checks failed)"
        return 0
    fi
}

# Install Cursor from DMG file
install_cursor_from_dmg() {
    local dmg_path="$1"

    if [[ -z "$dmg_path" ]]; then
        error_message "DMG path not specified"
        return "$ERR_INVALID_ARGS"
    fi

    if [[ ! -f "$dmg_path" ]]; then
        error_message "DMG file not found: $dmg_path"
        return "$ERR_FILE_NOT_FOUND"
    fi

    log_message "INFO" "Installing Cursor from DMG: $dmg_path"

    # Mount the DMG
    info_message "Mounting DMG file..."
    local mount_point
    mount_point=$(hdiutil mount "$dmg_path" | grep -E '^/dev/disk' | awk '{print $3}')

    if [[ -z "$mount_point" ]]; then
        error_message "Failed to mount DMG file"
        return "$ERR_MOUNT_FAILED"
    fi

    log_message "SUCCESS" "DMG mounted at: $mount_point"

    # Find the .app bundle in the mounted DMG
    local app_bundle
    app_bundle=$(find "$mount_point" -name "*.app" -type d | head -1)

    if [[ -z "$app_bundle" ]]; then
        error_message "No .app bundle found in DMG"
        hdiutil unmount "$mount_point" >/dev/null 2>&1
        return "$ERR_APP_NOT_FOUND"
    fi

    # Copy the app to Applications
    info_message "Installing Cursor.app to /Applications..."
    if cp -R "$app_bundle" "/Applications/" 2>/dev/null; then
        log_message "SUCCESS" "✓ Cursor.app installed successfully"
    else
        error_message "Failed to copy Cursor.app to /Applications"
        hdiutil unmount "$mount_point" >/dev/null 2>&1
        return "$ERR_COPY_FAILED"
    fi

    # Unmount the DMG
    info_message "Unmounting DMG..."
    if hdiutil unmount "$mount_point" >/dev/null 2>&1; then
        log_message "SUCCESS" "✓ DMG unmounted successfully"
    else
        warning_message "Warning: Failed to unmount DMG automatically"
    fi

    # Install shell integration if available
    install_shell_integration

    # Verify installation
    if verify_cursor_installation; then
        log_message "SUCCESS" "✓ Cursor installation completed and verified"
        return 0
    else
        error_message "Installation verification failed"
        return "$ERR_VERIFICATION_FAILED"
    fi
}

# Verify Cursor installation integrity
verify_cursor_installation() {
    log_message "INFO" "Verifying Cursor installation..."

    local cursor_app="/Applications/Cursor.app"
    local cursor_executable="$cursor_app/Contents/MacOS/Cursor"

    # Check if app bundle exists
    if [[ ! -d "$cursor_app" ]]; then
        error_message "Cursor.app not found at $cursor_app"
        return 1
    fi

    # Check if executable exists and is executable
    if [[ ! -x "$cursor_executable" ]]; then
        error_message "Cursor executable not found or not executable: $cursor_executable"
        return 1
    fi

    # Check Info.plist for basic app information
    local info_plist="$cursor_app/Contents/Info.plist"
    if [[ ! -f "$info_plist" ]]; then
        error_message "Info.plist not found: $info_plist"
        return 1
    fi

    # Try to read version information
    local version bundle_id
    version=$(defaults read "$info_plist" CFBundleShortVersionString 2>/dev/null)
    bundle_id=$(defaults read "$info_plist" CFBundleIdentifier 2>/dev/null)

    if [[ -n "$version" ]]; then
        log_message "SUCCESS" "✓ Cursor version: $version"
    fi

    if [[ -n "$bundle_id" ]]; then
        log_message "SUCCESS" "✓ Bundle ID: $bundle_id"
    fi

    log_message "SUCCESS" "✓ Cursor installation verified successfully"
    return 0
}

# Install shell integration (command line tools)
install_shell_integration() {
    log_message "INFO" "Installing Cursor shell integration..."

    local cursor_app="/Applications/Cursor.app"
    local cursor_binary="$cursor_app/Contents/Resources/app/bin/cursor"
    local target_dir="/usr/local/bin"
    local target_binary="$target_dir/cursor"

    # Check if the cursor binary exists in the app bundle
    if [[ ! -f "$cursor_binary" ]]; then
        warning_message "Cursor command line tool not found in app bundle"
        return 1
    fi

    # Create target directory if it doesn't exist
    if [[ ! -d "$target_dir" ]]; then
        if sudo mkdir -p "$target_dir" 2>/dev/null; then
            log_message "SUCCESS" "Created directory: $target_dir"
        else
            error_message "Failed to create directory: $target_dir"
            return 1
        fi
    fi

    # Create symlink to cursor binary
    if sudo ln -sf "$cursor_binary" "$target_binary" 2>/dev/null; then
        log_message "SUCCESS" "✓ Cursor command line tool installed at $target_binary"
    else
        error_message "Failed to install cursor command line tool"
        return 1
    fi

    # Optionally create 'code' symlink for VS Code compatibility
    local code_symlink="$target_dir/code"
    if [[ ! -e "$code_symlink" ]]; then
        if sudo ln -sf "$target_binary" "$code_symlink" 2>/dev/null; then
            log_message "SUCCESS" "✓ Created 'code' symlink for VS Code compatibility"
        else
            warning_message "Failed to create 'code' symlink (may already exist)"
        fi
    fi

    return 0
}

# Setup default project environment
setup_default_project() {
    local project_path="$1"
    local project_type="${2:-general}"

    if [[ -z "$project_path" ]]; then
        error_message "Project path not specified"
        return "$ERR_INVALID_ARGS"
    fi

    log_message "INFO" "Setting up default project at $project_path (type: $project_type)"

    # Create project directory
    if [[ ! -d "$project_path" ]]; then
        if mkdir -p "$project_path"; then
            log_message "SUCCESS" "Created project directory: $project_path"
        else
            error_message "Failed to create project directory: $project_path"
            return "$ERR_CREATE_FAILED"
        fi
    fi

    # Change to project directory
    cd "$project_path" || {
        error_message "Failed to change to project directory"
        return "$ERR_CD_FAILED"
    }

    # Initialize based on project type
    case "$project_type" in
        "node"|"nodejs"|"javascript")
            setup_nodejs_environment
            ;;
        "python")
            setup_venv_environments
            ;;
        "general"|*)
            create_project_structure
            ;;
    esac

    # Initialize git repository if not already initialized
    if [[ ! -d ".git" ]]; then
        initialize_git_repository
    fi

    log_message "SUCCESS" "✓ Default project setup completed"
    return 0
}

# Confirm installation action with user
confirm_installation_action() {
    warning_message "This will install Cursor editor on your system."
    warning_message "Please ensure you have the DMG file ready."
    echo

    read -p "Do you want to proceed with the installation? (y/N): " -n 1 -r
    echo

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        return 0
    else
        info_message "Installation cancelled by user"
        return 1
    fi
}
