#!/bin/bash

################################################################################
# Uninstall Module - Cursor Editor Removal Functions
# Part of Cursor Uninstaller Modular Architecture
################################################################################

# Enhanced uninstall function with comprehensive removal
enhanced_uninstall_cursor() {
    log_message "INFO" "Starting enhanced Cursor uninstallation..."

    if [[ "${DRY_RUN:-}" == "true" ]]; then
        info_message "DRY RUN: Would perform complete Cursor uninstallation"
        return 0
    fi

    # Detect all Cursor paths and installations
    detect_cursor_paths

    # Stop any running Cursor processes
    stop_cursor_processes

    # Remove main application
    remove_cursor_application

    # Remove user data and preferences
    remove_cursor_user_data

    # Remove system-wide configurations
    remove_cursor_system_configs

    # Clean up launch services and caches
    clean_launch_services

    # Remove symlinks and binaries
    remove_cursor_binaries

    # Clean up lingering files
    enhanced_clean_up_lingering_files

    # Verify complete removal
    if enhanced_verify_complete_removal; then
        log_message "SUCCESS" "✓ Cursor has been completely uninstalled"
        return 0
    else
        warning_message "Some Cursor components may still remain"
        return 1
    fi
}

# Detect all Cursor paths and installations
detect_cursor_paths() {
    log_message "INFO" "Detecting Cursor installation paths..."

    # Initialize arrays for different types of paths
    declare -a APP_PATHS
    declare -a USER_DATA_PATHS
    declare -a SYSTEM_PATHS
    declare -a BINARY_PATHS

    # Common application paths
    APP_PATHS=(
        "/Applications/Cursor.app"
        "/Applications/Cursor Beta.app"
        "/Applications/Cursor Insiders.app"
        "$HOME/Applications/Cursor.app"
    )

    # User data and preference paths
    USER_DATA_PATHS=(
        "$HOME/Library/Application Support/Cursor"
        "$HOME/Library/Application Support/com.todesktop.230313mzl4w4u92"
        "$HOME/Library/Preferences/com.todesktop.230313mzl4w4u92.plist"
        "$HOME/Library/Caches/com.todesktop.230313mzl4w4u92"
        "$HOME/Library/Caches/Cursor"
        "$HOME/Library/HTTPStorages/com.todesktop.230313mzl4w4u92"
        "$HOME/Library/Logs/Cursor"
        "$HOME/Library/Saved Application State/com.todesktop.230313mzl4w4u92.savedState"
        "$HOME/.cursor"
        "$HOME/.vscode-cursor"
    )

    # System-wide paths
    SYSTEM_PATHS=(
        "/usr/local/share/cursor"
        "/opt/cursor"
        "/Library/Application Support/Cursor"
        "/Library/Caches/Cursor"
    )

    # Binary and executable paths
    BINARY_PATHS=(
        "/usr/local/bin/cursor"
        "/usr/local/bin/code"
        "/usr/bin/cursor"
        "/opt/local/bin/cursor"
    )

    # Export arrays for use by other functions
    export APP_PATHS USER_DATA_PATHS SYSTEM_PATHS BINARY_PATHS

    # Log detected paths
    for path in "${APP_PATHS[@]}"; do
        [[ -e "$path" ]] && info_message "Found application: $path"
    done

    for path in "${USER_DATA_PATHS[@]}"; do
        [[ -e "$path" ]] && info_message "Found user data: $path"
    done
}

# Stop all running Cursor processes
stop_cursor_processes() {
    log_message "INFO" "Stopping Cursor processes..."

    local cursor_processes=(
        "Cursor"
        "Cursor Helper"
        "Cursor (GPU Process)"
        "Cursor (Renderer)"
        "com.todesktop.230313mzl4w4u92"
    )

    for process in "${cursor_processes[@]}"; do
        if pgrep -f "$process" >/dev/null 2>&1; then
            info_message "Stopping process: $process"
            execute_safely pkill -f "$process" || true
            sleep 1

            # Force kill if still running
            if pgrep -f "$process" >/dev/null 2>&1; then
                warning_message "Force killing process: $process"
                execute_safely pkill -9 -f "$process" || true
            fi
        fi
    done

    log_message "SUCCESS" "✓ Cursor processes stopped"
}

# Remove main application bundle
remove_cursor_application() {
    log_message "INFO" "Removing Cursor application bundle..."

    for app_path in "${APP_PATHS[@]}"; do
        if [[ -d "$app_path" ]]; then
            info_message "Removing: $app_path"
            enhanced_safe_remove "$app_path"
        fi
    done

    log_message "SUCCESS" "✓ Cursor application removed"
}

# Remove user data and preferences
remove_cursor_user_data() {
    log_message "INFO" "Removing Cursor user data and preferences..."

    for user_path in "${USER_DATA_PATHS[@]}"; do
        if [[ -e "$user_path" ]]; then
            info_message "Removing: $user_path"
            enhanced_safe_remove "$user_path"
        fi
    done

    # Remove additional user-specific files
    local additional_paths=(
        "$HOME/.cursor-server"
        "$HOME/.cursor-workspace"
        "$HOME/Library/Cookies/com.todesktop.230313mzl4w4u92.binarycookies"
        "$HOME/Library/WebKit/com.todesktop.230313mzl4w4u92"
    )

    for path in "${additional_paths[@]}"; do
        if [[ -e "$path" ]]; then
            info_message "Removing additional file: $path"
            enhanced_safe_remove "$path"
        fi
    done

    log_message "SUCCESS" "✓ User data and preferences removed"
}

# Remove system-wide configurations
remove_cursor_system_configs() {
    log_message "INFO" "Removing system-wide Cursor configurations..."

    for system_path in "${SYSTEM_PATHS[@]}"; do
        if [[ -e "$system_path" ]]; then
            info_message "Removing system path: $system_path"
            execute_safely sudo rm -rf "$system_path"
        fi
    done

    log_message "SUCCESS" "✓ System configurations removed"
}

# Clean up launch services and caches
clean_launch_services() {
    log_message "INFO" "Cleaning Launch Services and system caches..."

    # Reset Launch Services database
    execute_safely /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister \
        -kill -r -domain local -domain system -domain user

    # Clear system caches related to Cursor
    local cache_paths=(
        "/Library/Caches/com.apple.iconservices.store"
        "/var/folders/*/*/C/com.apple.LaunchServices*"
    )

    for cache_path in "${cache_paths[@]}"; do
        if ls $cache_path >/dev/null 2>&1; then
            execute_safely sudo rm -rf $cache_path
        fi
    done

    log_message "SUCCESS" "✓ Launch Services and caches cleaned"
}

# Remove Cursor binaries and symlinks
remove_cursor_binaries() {
    log_message "INFO" "Removing Cursor binaries and symlinks..."

    for binary_path in "${BINARY_PATHS[@]}"; do
        if [[ -L "$binary_path" ]]; then
            # Check if symlink points to Cursor
            local link_target
            link_target=$(readlink "$binary_path")
            if [[ "$link_target" == *"Cursor"* ]]; then
                info_message "Removing Cursor symlink: $binary_path"
                execute_safely sudo rm -f "$binary_path"
            fi
        elif [[ -f "$binary_path" ]]; then
            # Check if binary is related to Cursor
            if file "$binary_path" | grep -i cursor >/dev/null 2>&1; then
                info_message "Removing Cursor binary: $binary_path"
                execute_safely sudo rm -f "$binary_path"
            fi
        fi
    done

    log_message "SUCCESS" "✓ Cursor binaries and symlinks removed"
}

# Enhanced cleanup of lingering files
enhanced_clean_up_lingering_files() {
    log_message "INFO" "Cleaning up lingering Cursor files..."

    # Search for any remaining Cursor-related files
    local search_patterns=(
        "cursor"
        "Cursor"
        "com.todesktop.230313mzl4w4u92"
        ".cursor"
        ".vscode-cursor"
    )

    local search_directories=(
        "$HOME/Library"
        "$HOME/.local"
        "$HOME/.config"
        "/tmp"
        "/var/tmp"
    )

    for dir in "${search_directories[@]}"; do
        if [[ -d "$dir" ]]; then
            for pattern in "${search_patterns[@]}"; do
                # Find files and directories matching pattern
                while IFS= read -r -d '' file; do
                    if [[ -e "$file" ]]; then
                        info_message "Removing lingering file: $file"
                        enhanced_safe_remove "$file"
                    fi
                done < <(find "$dir" -name "*$pattern*" -print0 2>/dev/null | head -100)
            done
        fi
    done

    # Clean up specific locations
    local specific_cleanup=(
        "/private/var/db/receipts/*cursor*"
        "/private/var/db/receipts/*Cursor*"
        "$HOME/Desktop/Cursor*"
        "$HOME/Downloads/Cursor*"
    )

    for cleanup_path in "${specific_cleanup[@]}"; do
        if ls $cleanup_path >/dev/null 2>&1; then
            enhanced_safe_remove $cleanup_path
        fi
    done

    log_message "SUCCESS" "✓ Lingering files cleaned up"
}

# Enhanced verification of complete removal
enhanced_verify_complete_removal() {
    log_message "INFO" "Verifying complete Cursor removal..."

    local remaining_items=0

    # Check main application paths
    for app_path in "${APP_PATHS[@]}"; do
        if [[ -e "$app_path" ]]; then
            warning_message "Application still exists: $app_path"
            remaining_items=$((remaining_items + 1))
        fi
    done

    # Check for running processes
    local cursor_processes=("Cursor" "com.todesktop.230313mzl4w4u92")
    for process in "${cursor_processes[@]}"; do
        if pgrep -f "$process" >/dev/null 2>&1; then
            warning_message "Process still running: $process"
            remaining_items=$((remaining_items + 1))
        fi
    done

    # Check user data paths
    for user_path in "${USER_DATA_PATHS[@]}"; do
        if [[ -e "$user_path" ]]; then
            warning_message "User data still exists: $user_path"
            remaining_items=$((remaining_items + 1))
        fi
    done

    # Check binary paths
    for binary_path in "${BINARY_PATHS[@]}"; do
        if [[ -e "$binary_path" ]]; then
            local link_target=""
            if [[ -L "$binary_path" ]]; then
                link_target=$(readlink "$binary_path")
            fi

            if [[ -L "$binary_path" && "$link_target" == *"Cursor"* ]] ||
               [[ -f "$binary_path" && $(file "$binary_path" 2>/dev/null) == *"cursor"* ]]; then
                warning_message "Binary still exists: $binary_path"
                remaining_items=$((remaining_items + 1))
            fi
        fi
    done

    if [[ $remaining_items -eq 0 ]]; then
        log_message "SUCCESS" "✓ Complete removal verified - no Cursor components found"
        return 0
    else
        warning_message "⚠ $remaining_items Cursor components still remain"
        return 1
    fi
}

# Confirm uninstall action with user
confirm_uninstall_action() {
    warning_message "This will completely remove Cursor and all its data from your system."
    warning_message "This action cannot be undone!"
    echo
    warning_message "The following will be removed:"
    echo "  • Cursor application"
    echo "  • All user preferences and settings"
    echo "  • Extensions and workspaces"
    echo "  • Command line tools"
    echo "  • System integration files"
    echo

    if [[ "${DRY_RUN:-}" == "true" ]]; then
        info_message "DRY RUN: Would proceed with uninstallation"
        return 0
    fi

    read -p "Are you sure you want to proceed? (type 'yes' to confirm): " -r
    echo

    if [[ $REPLY == "yes" ]]; then
        return 0
    else
        info_message "Uninstallation cancelled by user"
        return 1
    fi
}
