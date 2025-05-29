#!/bin/bash

################################################################################
# Installation Module - Cursor Editor Installation & Verification Functions
# Part of Cursor Uninstaller Modular Architecture
################################################################################

# Check if Cursor is currently installed
check_cursor_installation() {
    log_message "INFO" "Checking Cursor installation status..."

    local cursor_app="/Applications/Cursor.app"
    local cursor_binary="/usr/local/bin/cursor"
    local cursor_symlink="/usr/local/bin/code"

    if [[ -d "$cursor_app" ]]; then
        local version
        version=$(defaults read "$cursor_app/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null)
        log_message "SUCCESS" "✓ Cursor.app found at $cursor_app (Version: ${version:-Unknown})"

        # Check for binary symlinks
        if [[ -L "$cursor_binary" ]] || [[ -f "$cursor_binary" ]]; then
            log_message "SUCCESS" "✓ Cursor binary found at $cursor_binary"
        fi

        if [[ -L "$cursor_symlink" ]] && [[ "$(readlink "$cursor_symlink")" == *"Cursor"* ]]; then
            log_message "SUCCESS" "✓ Cursor 'code' symlink found at $cursor_symlink"
        fi

        return 0
    else
        warning_message "✗ Cursor.app not found at $cursor_app"
        return 1
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
    if execute_safely cp -R "$app_bundle" "/Applications/"; then
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
        if execute_safely sudo mkdir -p "$target_dir"; then
            log_message "SUCCESS" "Created directory: $target_dir"
        else
            error_message "Failed to create directory: $target_dir"
            return 1
        fi
    fi

    # Create symlink to cursor binary
    if execute_safely sudo ln -sf "$cursor_binary" "$target_binary"; then
        log_message "SUCCESS" "✓ Cursor command line tool installed at $target_binary"
    else
        error_message "Failed to install cursor command line tool"
        return 1
    fi

    # Optionally create 'code' symlink for VS Code compatibility
    local code_symlink="$target_dir/code"
    if [[ ! -e "$code_symlink" ]]; then
        if execute_safely sudo ln -sf "$target_binary" "$code_symlink"; then
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
        if execute_safely mkdir -p "$project_path"; then
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

    if [[ "${DRY_RUN:-}" == "true" ]]; then
        info_message "DRY RUN: Would proceed with installation"
        return 0
    fi

    read -p "Do you want to proceed with the installation? (y/N): " -n 1 -r
    echo

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        return 0
    else
        info_message "Installation cancelled by user"
        return 1
    fi
}
