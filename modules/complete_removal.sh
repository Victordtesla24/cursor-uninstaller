#!/bin/bash

################################################################################
# Complete Cursor AI Editor Removal Script for macOS
# Refactored and Debugged Version
################################################################################

set -euo pipefail

# Configuration Constants
readonly CURSOR_APP_PATH="/Applications/Cursor.app"
readonly CURSOR_BUNDLE_ID="com.todesktop.230313mzl4w4u92"
readonly MAX_REMOVAL_ATTEMPTS=3
readonly SPOTLIGHT_TIMEOUT=30

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m' # No Color

# Logging function
log_message() {
    local level="$1"
    local message="$2"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    case "$level" in
        "ERROR")
            echo -e "${RED}[ERROR]${NC} ${timestamp}: $message" >&2
            ;;
        "WARN")
            echo -e "${YELLOW}[WARN]${NC} ${timestamp}: $message"
            ;;
        "INFO")
            echo -e "${BLUE}[INFO]${NC} ${timestamp}: $message"
            ;;
        "SUCCESS")
            echo -e "${GREEN}[SUCCESS]${NC} ${timestamp}: $message"
            ;;
    esac
}

# Function to terminate Cursor processes
terminate_cursor_processes() {
    log_message "INFO" "Terminating all Cursor processes..."

    # Graceful application quit attempt
    osascript -e 'tell application "Cursor" to quit' 2>/dev/null || true
    sleep 2

    # Force terminate any remaining processes
    local cursor_pids
    cursor_pids=$(pgrep -i cursor 2>/dev/null || true)

    if [[ -n "$cursor_pids" ]]; then
        log_message "INFO" "Force terminating Cursor processes: $cursor_pids"
        echo "$cursor_pids" | xargs -r kill -TERM 2>/dev/null || true
        sleep 2

        # Final force kill if still running
        cursor_pids=$(pgrep -i cursor 2>/dev/null || true)
        if [[ -n "$cursor_pids" ]]; then
            echo "$cursor_pids" | xargs -r kill -KILL 2>/dev/null || true
        fi
    fi

    log_message "SUCCESS" "Cursor processes terminated"
}

# Function to validate Cursor installation
validate_cursor_installation() {
    log_message "INFO" "Validating Cursor installation..."
    local found_components=0

    # Check main application
    if [[ -d "$CURSOR_APP_PATH" ]]; then
        log_message "INFO" "Found main application: $CURSOR_APP_PATH"
        ((found_components++))
    fi

    # Check user directories
    local user_dirs=(
        "$HOME/Library/Application Support/Cursor"
        "$HOME/Library/Caches/$CURSOR_BUNDLE_ID"
        "$HOME/Library/Preferences/$CURSOR_BUNDLE_ID.plist"
        "$HOME/Library/Saved Application State/$CURSOR_BUNDLE_ID.savedState"
    )

    for dir in "${user_dirs[@]}"; do
        if [[ -e "$dir" ]]; then
            log_message "INFO" "Found user data: $dir"
            ((found_components++))
        fi
    done

    # Check CLI installations
    local cli_paths=(
        "/usr/local/bin/cursor"
        "/opt/homebrew/bin/cursor"
        "$HOME/.local/bin/cursor"
    )

    for cli_path in "${cli_paths[@]}"; do
        if [[ -x "$cli_path" ]]; then
            log_message "INFO" "Found CLI installation: $cli_path"
            ((found_components++))
        fi
    done

    if [[ $found_components -eq 0 ]]; then
        log_message "WARN" "No Cursor components found"
        return 1
    else
        log_message "INFO" "Found $found_components Cursor components"
        return 0
    fi
}

# Function to remove file/directory with multiple strategies
remove_with_retry() {
    local target="$1"
    local attempt=1

    if [[ ! -e "$target" ]]; then
        log_message "INFO" "Target already removed: $target"
        return 0
    fi

    local target_size
    target_size=$(du -sh "$target" 2>/dev/null | cut -f1 || echo "unknown")
    log_message "INFO" "Removing: $target ($target_size)"

    while [[ $attempt -le $MAX_REMOVAL_ATTEMPTS ]]; do
        log_message "INFO" "Removal attempt $attempt for: $target"

        # Strategy 1: Standard removal
        if [[ $attempt -eq 1 ]]; then
            if sudo rm -rf "$target" 2>/dev/null; then
                log_message "SUCCESS" "Removed successfully: $target"
                return 0
            fi
        fi

        # Strategy 2: Change permissions first
        if [[ $attempt -eq 2 ]]; then
            if sudo chmod -R 755 "$target" 2>/dev/null && sudo rm -rf "$target" 2>/dev/null; then
                log_message "SUCCESS" "Removed after permission change: $target"
                return 0
            fi
        fi

        # Strategy 3: Force removal with different flags
        if [[ $attempt -eq 3 ]]; then
            if sudo rm -rf "$target" 2>/dev/null; then
                log_message "SUCCESS" "Force removed: $target"
                return 0
            fi
        fi

        ((attempt++))
        sleep 1
    done

    log_message "ERROR" "Failed to remove after $MAX_REMOVAL_ATTEMPTS attempts: $target"
    return 1
}

# Function to clean Core Data caches
cleanup_cursor_caches() {
    log_message "INFO" "Cleaning Cursor caches..."

    local cache_locations=(
        "$HOME/Library/Caches"
        "/var/folders"
        "/tmp"
    )

    local cache_patterns=(
        "*Cursor*"
        "*cursor*"
        "*$CURSOR_BUNDLE_ID*"
        "*todesktop*"
    )

    local cleaned_count=0

    for location in "${cache_locations[@]}"; do
        if [[ ! -d "$location" ]]; then
            continue
        fi

        log_message "INFO" "Scanning cache location: $location"

        for pattern in "${cache_patterns[@]}"; do
            while IFS= read -r -d '' cache_path; do
                if [[ -e "$cache_path" ]]; then
                    # Validate this is actually Cursor-related
                    if validate_cursor_path "$cache_path"; then
                        if remove_with_retry "$cache_path"; then
                            ((cleaned_count++))
                        fi
                    fi
                fi
            done < <(find "$location" -maxdepth 3 -name "$pattern" -print0 2>/dev/null || true)
        done
    done

    log_message "SUCCESS" "Cache cleanup completed. Cleaned $cleaned_count items"
}

# Function to validate Cursor-related paths
validate_cursor_path() {
    local path="$1"

    # Check if path contains Cursor identifiers
    if [[ "$path" =~ Cursor ]] || [[ "$path" =~ cursor ]] || [[ "$path" =~ $CURSOR_BUNDLE_ID ]]; then
        # Exclude known false positives
        local false_positive_patterns=(
            "firefox" "Firefox" "chrome" "Chrome" "safari" "Safari"
            "webkit" "WebKit" "mongosh" "CommandLineTools" "System/Library"
        )

        for pattern in "${false_positive_patterns[@]}"; do
            if [[ "$path" =~ $pattern ]]; then
                log_message "INFO" "Excluded false positive: $path"
                return 1
            fi
        done

        return 0
    fi

    return 1
}

# Function to perform system maintenance
perform_system_maintenance() {
    log_message "INFO" "Performing system maintenance..."

    # Clear DNS cache
    if sudo dscacheutil -flushcache >/dev/null 2>&1; then
        log_message "SUCCESS" "DNS cache cleared"
    else
        log_message "WARN" "DNS cache clearing failed"
    fi

    # Clear font cache
    if sudo atsutil databases -remove >/dev/null 2>&1; then
        log_message "SUCCESS" "Font cache cleared"
    else
        log_message "WARN" "Font cache clearing failed"
    fi

    # Update Launch Services database
    if sudo /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user >/dev/null 2>&1; then
        log_message "SUCCESS" "Launch Services database updated"
    else
        log_message "WARN" "Launch Services update failed"
    fi

    # Rebuild Spotlight index
    log_message "INFO" "Rebuilding Spotlight index (this may take time)..."
    if timeout "$SPOTLIGHT_TIMEOUT" sudo mdutil -i on / >/dev/null 2>&1; then
        log_message "SUCCESS" "Spotlight index rebuild completed"
    else
        log_message "WARN" "Spotlight reindexing failed or timed out"
    fi
}

# Function to perform deep system scan for remaining components
perform_deep_scan() {
    log_message "INFO" "Performing deep system scan for remaining components..."

    # Use Spotlight to find any remaining Cursor components
    local remaining_items=()

    # Search by bundle identifier
    while IFS= read -r item; do
        if [[ -n "$item" && -e "$item" ]] && validate_cursor_path "$item"; then
            remaining_items+=("$item")
        fi
    done < <(mdfind "kMDItemCFBundleIdentifier == '$CURSOR_BUNDLE_ID'" 2>/dev/null || true)

    # Search by name patterns
    local search_patterns=("Cursor" "cursor" "todesktop")
    for pattern in "${search_patterns[@]}"; do
        while IFS= read -r item; do
            if [[ -n "$item" && -e "$item" ]] && validate_cursor_path "$item"; then
                if [[ ! " ${remaining_items[*]} " =~ \ $item\  ]]; then
                    remaining_items+=("$item")
                fi
            fi
        done < <(mdfind -name "$pattern" 2>/dev/null || true)
    done

    if [[ ${#remaining_items[@]} -gt 0 ]]; then
        log_message "WARN" "Found ${#remaining_items[@]} remaining Cursor components"
        for item in "${remaining_items[@]}"; do
            log_message "INFO" "Remaining: $item"
            remove_with_retry "$item"
        done
    else
        log_message "SUCCESS" "No remaining Cursor components found"
    fi
}

# Function to display keychain cleanup guidance
display_keychain_guidance() {
    echo ""
    echo -e "${BOLD}${YELLOW}🔐 KEYCHAIN CLEANUP GUIDANCE${NC}"
    echo -e "${BOLD}════════════════════════════════${NC}"
    echo ""
    echo -e "${BOLD}To remove Cursor keychain entries:${NC}"
    echo -e "1. Open ${BOLD}Keychain Access.app${NC}"
    echo -e "2. Search for: ${CYAN}cursor${NC} or ${CYAN}todesktop${NC}"
    echo -e "3. Delete any found entries"
    echo ""
    echo -e "${BOLD}Terminal method:${NC}"
    echo -e "${CYAN}security find-generic-password -s \"cursor\" 2>/dev/null && security delete-generic-password -s \"cursor\"${NC}"
    echo ""
}

# Main removal function
perform_complete_removal() {
    local start_time
    start_time=$(date +%s)

    echo -e "${BOLD}${BLUE}🚀 CURSOR AI EDITOR COMPLETE REMOVAL${NC}"
    echo -e "${BOLD}═══════════════════════════════════════${NC}"
    echo ""

    log_message "INFO" "Starting complete Cursor removal process..."

    # Step 1: Validate installation
    log_message "INFO" "Step 1/7: Validating Cursor installation"
    validate_cursor_installation || log_message "WARN" "No installation found, proceeding with cleanup"

    # Step 2: Terminate processes
    log_message "INFO" "Step 2/7: Terminating Cursor processes"
    terminate_cursor_processes

    # Step 3: Remove main application
    log_message "INFO" "Step 3/7: Removing main application"
    if [[ -d "$CURSOR_APP_PATH" ]]; then
        remove_with_retry "$CURSOR_APP_PATH"
    else
        log_message "INFO" "Main application not found"
    fi

    # Step 4: Remove user data directories
    log_message "INFO" "Step 4/7: Removing user data"
    local user_dirs=(
        "$HOME/Library/Application Support/Cursor"
        "$HOME/Library/Application Support/cursor"
        "$HOME/Library/Caches/$CURSOR_BUNDLE_ID"
        "$HOME/Library/Caches/Cursor"
        "$HOME/Library/Preferences/$CURSOR_BUNDLE_ID.plist"
        "$HOME/Library/Saved Application State/$CURSOR_BUNDLE_ID.savedState"
        "$HOME/.cursor"
        "$HOME/.config/cursor"
    )

    for dir in "${user_dirs[@]}"; do
        if [[ -e "$dir" ]]; then
            remove_with_retry "$dir"
        fi
    done

    # Step 5: Remove CLI tools
    log_message "INFO" "Step 5/7: Removing CLI tools"
    local cli_paths=(
        "/usr/local/bin/cursor"
        "/opt/homebrew/bin/cursor"
        "$HOME/.local/bin/cursor"
    )

    for cli_path in "${cli_paths[@]}"; do
        if [[ -e "$cli_path" ]]; then
            remove_with_retry "$cli_path"
        fi
    done

    # Step 6: Clean caches
    log_message "INFO" "Step 6/7: Cleaning system caches"
    cleanup_cursor_caches

    # Step 7: System maintenance
    log_message "INFO" "Step 7/7: Performing system maintenance"
    perform_system_maintenance

    # Final deep scan
    log_message "INFO" "Performing final verification scan"
    perform_deep_scan

    # Display keychain guidance
    display_keychain_guidance

    # Calculate duration
    local end_time
    end_time=$(date +%s)
    local duration=$((end_time - start_time))

    echo ""
    echo -e "${BOLD}${GREEN}✅ REMOVAL COMPLETED${NC}"
    echo -e "${BOLD}Duration: ${duration}s${NC}"
    echo ""
    log_message "SUCCESS" "Cursor AI Editor removal completed successfully"
}

# Main execution
main() {
    # Check if running on macOS
    if [[ "$(uname)" != "Darwin" ]]; then
        log_message "ERROR" "This script is designed for macOS only"
        exit 1
    fi

    # Check for required commands
    local required_commands=("mdfind" "mdutil" "sudo" "osascript" "pgrep")
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            log_message "ERROR" "Required command not found: $cmd"
            exit 1
        fi
    done

    # Confirm removal
    echo -e "${YELLOW}This will completely remove Cursor AI Editor from your Mac.${NC}"
    echo -e "${YELLOW}This action cannot be undone.${NC}"
    echo ""
    read -p "Continue? (y/N): " -n 1 -r
    echo

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_message "INFO" "Operation cancelled by user"
        exit 0
    fi

    # Request sudo access upfront
    if ! sudo -v; then
        log_message "ERROR" "Sudo access required for complete removal"
        exit 1
    fi

    # Keep sudo alive
    while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

    # Perform removal
    perform_complete_removal
}

# Execute main function if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
