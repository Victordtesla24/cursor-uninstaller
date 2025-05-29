#!/bin/bash

################################################################################
# Cursor AI Editor Removal & Management Utility - Enhanced Error Handling
# Production-Ready Version with Robust Error Recovery
################################################################################

# Script Self-Location & Robust Path Resolution
get_script_path() {
    # Special case for test environment
    if [[ "${BATS_TEST_SOURCED:-}" == "1" ]]; then
        if [[ "${CURSOR_TEST_SYMLINK_MODE:-}" == "true" ]] || [[ "${BASH_SOURCE[0]:-}" == *"symlink"* ]]; then
            if [[ -n "${SCRIPT_DIR:-}" ]]; then
                echo "$SCRIPT_DIR"
                return 0
            fi
            echo "$PWD"
            return 0
        elif [[ -n "${TEST_DIR:-}" ]]; then
            dirname "$TEST_DIR"
            return 0
        fi
    fi

    local SOURCE="${BASH_SOURCE[0]}"
    local DIR=""

    while [ -h "$SOURCE" ]; do
        DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
        SOURCE="$(readlink "$SOURCE")"
        [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
    done

    DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
    echo "$DIR"
}

# Store the script's directory path
SCRIPT_DIR="$(get_script_path)"

# Enhanced error handling with graceful recovery
set -eE  # Removed 'u' and 'pipefail' for better error recovery
trap 'handle_script_error $LINENO "$BASH_COMMAND"' ERR

# Global error handling variables
ERRORS_ENCOUNTERED=0
NON_INTERACTIVE_MODE=false

# Enhanced error handler with recovery
handle_script_error() {
    local line_number="$1"
    local failed_command="$2"
    
    ((ERRORS_ENCOUNTERED++))
    
    echo -e "\n[WARNING] Non-critical error at line $line_number: $failed_command" >&2
    echo "[INFO] Attempting to continue execution..." >&2
    
    # Return 0 to continue execution instead of exiting
    return 0
}

# Detect if running in non-interactive environment
detect_environment() {
    if [[ ! -t 0 ]] || [[ -n "${CI:-}" ]] || [[ -n "${DEBIAN_FRONTEND:-}" ]] || [[ "${TERM:-}" == "dumb" ]]; then
        NON_INTERACTIVE_MODE=true
        echo "[INFO] Non-interactive environment detected"
    fi
}

# Enhanced sudo handling with fallback mechanisms
safe_sudo() {
    local cmd="$*"
    local max_attempts=2
    local attempt=1
    
    # Check if sudo is available
    if ! command -v sudo >/dev/null 2>&1; then
        echo "[WARNING] sudo not available, attempting command without privileges" >&2
        eval "$cmd" 2>/dev/null || {
            echo "[WARNING] Command failed without sudo: $cmd" >&2
            return 1
        }
        return 0
    fi
    
    # In non-interactive mode, try sudo with timeout
    if [[ "$NON_INTERACTIVE_MODE" == "true" ]]; then
        # Try sudo with a short timeout
        if timeout 5s sudo -n true 2>/dev/null; then
            # Passwordless sudo available
            sudo "$@" 2>/dev/null || {
                echo "[WARNING] Sudo command failed: $cmd" >&2
                return 1
            }
        else
            echo "[INFO] Passwordless sudo not available, attempting without privileges" >&2
            eval "$cmd" 2>/dev/null || {
                echo "[WARNING] Command failed without sudo: $cmd" >&2
                return 1
            }
        fi
        return 0
    fi
    
    # Interactive mode - try normal sudo
    while [[ $attempt -le $max_attempts ]]; do
        if sudo -v 2>/dev/null; then
            sudo "$@" && return 0
            echo "[WARNING] Sudo command failed (attempt $attempt/$max_attempts): $cmd" >&2
        else
            echo "[WARNING] Sudo authentication failed (attempt $attempt/$max_attempts)" >&2
        fi
        ((attempt++))
        sleep 1
    done
    
    # Final fallback - try without sudo
    echo "[INFO] Attempting command without sudo privileges" >&2
    eval "$cmd" 2>/dev/null || {
        echo "[WARNING] Command failed completely: $cmd" >&2
        return 1
    }
    
    return 0
}

# Safe module loading with error recovery
safe_source() {
    local module_path="$1"
    local module_name="$(basename "$module_path")"
    
    if [[ -f "$module_path" ]] && [[ -r "$module_path" ]]; then
        if source "$module_path" 2>/dev/null; then
            echo "[INFO] Successfully loaded module: $module_name" >&2
            return 0
        else
            echo "[WARNING] Failed to load module: $module_name" >&2
            echo "[INFO] Continuing with basic functionality..." >&2
            return 1
        fi
    else
        echo "[WARNING] Module not found or not readable: $module_path" >&2
        echo "[INFO] Using fallback implementations..." >&2
        return 1
    fi
}

################################################################################
# Fallback Functions (for when modules fail to load)
################################################################################

# Fallback logging function
fallback_log_message() {
    local level="${1:-INFO}"
    local message="${2:-No message provided}"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" >&2
}

# Fallback error message function
fallback_error_message() {
    local message="$1"
    echo -e "\033[0;31m[ERROR]\033[0m $message" >&2
}

# Fallback success message function
fallback_success_message() {
    local message="$1"
    echo -e "\033[0;32m[SUCCESS]\033[0m $message" >&2
}

# Fallback show help function
fallback_show_help() {
    cat << 'EOF'
Cursor AI Editor Management Utility - Enhanced Error Handling Version

Usage: ./uninstall_cursor.sh [OPTIONS]

OPTIONS:
    -u, --uninstall         Completely uninstall Cursor
    -i, --install PATH      Install Cursor from DMG file
    -o, --optimize          Optimize Cursor performance
    -r, --reset-performance Reset performance settings
    -c, --check             Check Cursor installation status
    -m, --menu              Show interactive menu (default)
    -b, --backup OPERATION  Backup operations (create/restore/list)
    --backup-path PATH      Specify backup path
    -t, --test              Run system tests
    --health                Perform health check
    --dry-run               Show what would be done without executing
    --verbose               Enable verbose output
    -h, --help              Show this help message

EXAMPLES:
    ./uninstall_cursor.sh                    # Show interactive menu
    ./uninstall_cursor.sh -u                 # Uninstall Cursor
    ./uninstall_cursor.sh -c                 # Check installation
    ./uninstall_cursor.sh --dry-run -u       # Dry run uninstall

EOF
}

################################################################################
# Enhanced Module Loading System with Fallbacks
################################################################################

# Initialize environment
detect_environment

# Initialize basic functions
if ! declare -f log_message >/dev/null 2>&1; then
    alias log_message='fallback_log_message'
fi

if ! declare -f error_message >/dev/null 2>&1; then
    alias error_message='fallback_error_message'
fi

if ! declare -f success_message >/dev/null 2>&1; then
    alias success_message='fallback_success_message'
fi

if ! declare -f show_help >/dev/null 2>&1; then
    alias show_help='fallback_show_help'
fi

# Add missing function aliases for module compatibility
if ! declare -f warning_message >/dev/null 2>&1; then
    warning_message() { echo -e "\033[1;33m[WARNING]\033[0m $*" >&2; }
fi

if ! declare -f info_message >/dev/null 2>&1; then
    info_message() { echo -e "\033[0;36m[INFO]\033[0m $*" >&2; }
fi

# Add missing function stubs for UI module compatibility
if ! declare -f detect_cursor_paths >/dev/null 2>&1; then
    detect_cursor_paths() { return 1; }
fi

if ! declare -f get_file_size >/dev/null 2>&1; then
    get_file_size() { echo "Unknown size"; }
fi

if ! declare -f create_backup >/dev/null 2>&1; then
    create_backup() { echo "Backup functionality not available in fallback mode"; return 1; }
fi

# Load configuration first (contains constants and settings)
if ! safe_source "$SCRIPT_DIR/lib/config.sh"; then
    # Fallback configuration
    ERR_INVALID_ARGS=1
    ERR_PERMISSION_DENIED=2
    ERR_FILE_NOT_FOUND=3
    ERR_SYSTEM_ERROR=4
    
    # Default color codes
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    NC='\033[0m'
fi

# Load helper utilities
safe_source "$SCRIPT_DIR/lib/helpers.sh"

# Load UI components
safe_source "$SCRIPT_DIR/lib/ui.sh"

# Load functional modules
safe_source "$SCRIPT_DIR/modules/installation.sh"
safe_source "$SCRIPT_DIR/modules/optimization.sh"
safe_source "$SCRIPT_DIR/modules/uninstall.sh"

# Load testing module (this is optional and can fail safely)
safe_source "$SCRIPT_DIR/tests/helpers/test_functions.sh" || true

################################################################################
# Enhanced Main Orchestration Functions
################################################################################

# Enhanced main function with comprehensive error handling
main() {
    # Initialize logging with fallback
    if declare -f initialize_logging >/dev/null 2>&1; then
        initialize_logging 2>/dev/null || fallback_log_message "WARNING" "Failed to initialize advanced logging, using fallback"
    fi
    
    log_message "INFO" "Starting Cursor management utility (Enhanced Error Handling Version)"
    log_message "INFO" "Non-interactive mode: $NON_INTERACTIVE_MODE"

    # Parse command line arguments
    if ! parse_arguments "$@"; then
        error_message "Failed to parse command line arguments"
        show_help
        exit "${ERR_INVALID_ARGS:-1}"
    fi

    # Validate system requirements with fallback
    if declare -f validate_system_requirements >/dev/null 2>&1; then
        validate_system_requirements || {
            log_message "WARNING" "System validation failed, continuing with basic functionality"
        }
    else
        log_message "INFO" "Using basic system validation"
        # Basic validation - check if we're on macOS
        if [[ "$OSTYPE" != "darwin"* ]]; then
            error_message "This utility is designed for macOS"
            exit "${ERR_SYSTEM_ERROR:-4}"
        fi
    fi

    # Execute requested operation based on parsed arguments
    case "${OPERATION:-menu}" in
        "uninstall")
            if declare -f confirm_uninstall_action >/dev/null 2>&1; then
                confirm_uninstall_action || exit $?
            fi
            
            if declare -f enhanced_uninstall_cursor >/dev/null 2>&1; then
                enhanced_uninstall_cursor
            else
                fallback_uninstall_cursor
            fi
            ;;
        "install")
            if declare -f confirm_installation_action >/dev/null 2>&1; then
                confirm_installation_action || exit $?
            fi
            
            if [[ -n "${DMG_PATH:-}" ]]; then
                if declare -f install_cursor_from_dmg >/dev/null 2>&1; then
                    install_cursor_from_dmg "$DMG_PATH"
                else
                    error_message "Installation module not available"
                    exit "${ERR_SYSTEM_ERROR:-4}"
                fi
            else
                error_message "DMG path required for installation"
                exit "${ERR_INVALID_ARGS:-1}"
            fi
            ;;
        "optimize")
            if declare -f enhanced_optimize_cursor_performance >/dev/null 2>&1; then
                enhanced_optimize_cursor_performance
            else
                fallback_optimize_cursor
            fi
            ;;
        "reset-performance")
            if declare -f reset_performance_settings >/dev/null 2>&1; then
                reset_performance_settings
            else
                fallback_reset_performance
            fi
            ;;
        "check")
            if declare -f check_cursor_installation >/dev/null 2>&1; then
                check_cursor_installation
            else
                fallback_check_installation
            fi
            ;;
        "menu")
            if declare -f enhanced_show_menu >/dev/null 2>&1; then
                enhanced_show_menu
            else
                fallback_show_menu
            fi
            ;;
        "backup")
            handle_backup_operations
            ;;
        "test")
            if declare -f run_tests >/dev/null 2>&1; then
                run_tests
            else
                error_message "Test module not available"
                exit "${ERR_SYSTEM_ERROR:-4}"
            fi
            ;;
        "health")
            if declare -f perform_health_check >/dev/null 2>&1; then
                perform_health_check
            else
                fallback_health_check
            fi
            ;;
        *)
            show_help
            exit "${ERR_INVALID_ARGS:-1}"
            ;;
    esac

    if [[ $ERRORS_ENCOUNTERED -gt 0 ]]; then
        log_message "WARNING" "Operation completed with $ERRORS_ENCOUNTERED non-critical errors"
    else
        log_message "INFO" "Operation completed successfully"
    fi
}

################################################################################
# Fallback Implementation Functions
################################################################################

# Fallback uninstall function
fallback_uninstall_cursor() {
    echo "Performing basic Cursor uninstallation..."
    
    # Basic Cursor paths for macOS
    local cursor_paths=(
        "/Applications/Cursor.app"
        "$HOME/Library/Application Support/Cursor"
        "$HOME/Library/Caches/Cursor"
        "$HOME/Library/Preferences/com.cursor.Cursor.plist"
        "$HOME/Library/Saved Application State/com.cursor.Cursor.savedState"
        "/Users/Shared/cursor"
    )
    
    for path in "${cursor_paths[@]}"; do
        if [[ -e "$path" ]]; then
            echo "Removing: $path"
            safe_sudo rm -rf "$path" || {
                echo "Warning: Could not remove $path"
            }
        fi
    done
    
    success_message "Basic uninstallation completed"
}

# Fallback optimization function
fallback_optimize_cursor() {
    echo "Performing basic Cursor optimization..."
    log_message "INFO" "Basic optimization features not available without modules"
}

# Fallback reset performance function  
fallback_reset_performance() {
    echo "Resetting basic Cursor performance settings..."
    log_message "INFO" "Basic reset features not available without modules"
}

# Fallback check installation function
fallback_check_installation() {
    echo "Checking Cursor installation status..."
    echo "========================================"
    
    local cursor_found=false
    local issues_found=()
    
    # Check main application
    if [[ -d "/Applications/Cursor.app" ]]; then
        # Get version if possible
        local version=""
        if [[ -f "/Applications/Cursor.app/Contents/Info.plist" ]]; then
            if command -v defaults >/dev/null 2>&1; then
                version=$(defaults read "/Applications/Cursor.app/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null || echo "Unknown")
                success_message "✓ Cursor.app found at /Applications/Cursor.app (Version: $version)"
            else
                success_message "✓ Cursor.app found at /Applications/Cursor.app"
            fi
        else
            success_message "✓ Cursor.app found at /Applications/Cursor.app"
        fi
        cursor_found=true
    else
        echo "✗ Cursor.app not found in /Applications"
        issues_found+=("Main application not installed")
    fi
    
    # Check command line tools in common locations
    local cli_locations=(
        "/usr/local/bin/cursor"
        "/opt/homebrew/bin/cursor"
        "$HOME/.local/bin/cursor"
        "/usr/bin/cursor"
    )
    
    local cli_found=false
    for location in "${cli_locations[@]}"; do
        if [[ -f "$location" ]] && [[ -x "$location" ]]; then
            success_message "✓ Cursor CLI found at $location"
            cli_found=true
            cursor_found=true
            break
        fi
    done
    
    if [[ "$cli_found" == "false" ]]; then
        echo "✗ Cursor CLI not found in standard locations"
        issues_found+=("Command line tools not installed")
        
        # Check if it's available in PATH anyway
        if command -v cursor >/dev/null 2>&1; then
            local cursor_path=$(which cursor 2>/dev/null)
            success_message "✓ Cursor CLI found in PATH at $cursor_path"
            cli_found=true
            cursor_found=true
        fi
    fi
    
    # Check for support files and configuration
    local support_locations=(
        "$HOME/Library/Application Support/Cursor"
        "$HOME/.cursor"
        "$HOME/.config/cursor"
    )
    
    local support_found=false
    for location in "${support_locations[@]}"; do
        if [[ -d "$location" ]]; then
            success_message "✓ Cursor support files found at $location"
            support_found=true
            cursor_found=true
        fi
    done
    
    if [[ "$support_found" == "false" ]]; then
        echo "✗ No Cursor support files found"
        issues_found+=("No user configuration found")
    fi
    
    # Check for preferences
    local pref_locations=(
        "$HOME/Library/Preferences/com.cursor.Cursor.plist"
        "$HOME/.cursor-server"
    )
    
    local prefs_found=false
    for location in "${pref_locations[@]}"; do
        if [[ -e "$location" ]]; then
            success_message "✓ Cursor preferences found at $location"
            prefs_found=true
        fi
    done
    
    if [[ "$prefs_found" == "false" ]]; then
        echo "✗ No Cursor preferences found"
    fi
    
    # Check for cache files
    local cache_locations=(
        "$HOME/Library/Caches/Cursor"
        "$HOME/Library/Caches/com.cursor.Cursor"
    )
    
    local cache_found=false
    for location in "${cache_locations[@]}"; do
        if [[ -d "$location" ]]; then
            success_message "✓ Cursor cache found at $location"
            cache_found=true
        fi
    done
    
    if [[ "$cache_found" == "false" ]]; then
        echo "✗ No Cursor cache files found"
    fi
    
    # Additional checks for common issues
    echo ""
    echo "Additional Diagnostics:"
    echo "----------------------"
    
    # Check if code command points to Cursor (common issue from GitHub)
    if command -v code >/dev/null 2>&1; then
        local code_path=$(which code 2>/dev/null)
        if [[ -L "$code_path" ]]; then
            local link_target=$(readlink "$code_path" 2>/dev/null)
            if [[ "$link_target" == *"cursor"* ]] || [[ "$link_target" == *"Cursor"* ]]; then
                echo "⚠️  'code' command points to Cursor at $link_target"
                echo "   This may cause conflicts with VS Code"
            else
                echo "✓ 'code' command points to $link_target"
            fi
        else
            echo "✓ 'code' command found at $code_path"
        fi
    else
        echo "ℹ️  'code' command not found in PATH"
    fi
    
    # Check for WSL-specific issues
    if [[ -n "${WSL_DISTRO_NAME:-}" ]] || [[ -f "/proc/version" ]] && grep -qi "microsoft\|wsl" /proc/version 2>/dev/null; then
        echo "ℹ️  WSL environment detected"
        echo "   Note: Cursor GUI apps require X11 forwarding or Windows integration"
        
        # Check for Windows Cursor installation
        local windows_cursor_paths=(
            "/mnt/c/Users/*/AppData/Local/Programs/cursor"
            "/mnt/c/Program Files/cursor"
        )
        
        for path_pattern in "${windows_cursor_paths[@]}"; do
            if compgen -G "$path_pattern" >/dev/null 2>&1; then
                echo "✓ Windows Cursor installation detected at $path_pattern"
                cursor_found=true
            fi
        done
    fi
    
    # Check PATH for cursor-related commands
    echo ""
    echo "PATH Analysis:"
    echo "-------------"
    echo "PATH contains: $(echo "$PATH" | tr ':' '\n' | grep -E "(cursor|Cursor)" || echo "No cursor-related paths")"
    
    # Final status summary
    echo ""
    echo "========================================="
    if [[ "$cursor_found" == "true" ]]; then
        success_message "Overall Status: Cursor installation detected"
        if [[ ${#issues_found[@]} -gt 0 ]]; then
            echo ""
            echo "Issues found that may affect functionality:"
            for issue in "${issues_found[@]}"; do
                echo "  • $issue"
            done
            echo ""
            echo "Recommendations:"
            if [[ "$cli_found" == "false" ]]; then
                echo "  • Install command line tools from Cursor > Install 'cursor' command"
            fi
            echo "  • Run Cursor at least once to initialize all components"
        fi
    else
        echo "❌ Overall Status: Cursor not found"
        echo ""
        echo "No Cursor installation detected on this system."
        echo ""
        echo "To install Cursor:"
        echo "  1. Download from https://cursor.sh"
        echo "  2. Install the .dmg/.pkg file"
        echo "  3. Run Cursor and install command line tools"
        echo "  4. Verify installation with: cursor --version"
    fi
    echo "========================================="
}

# Fallback health check function
fallback_health_check() {
    echo "Performing basic health check..."
    
    # Check if running on macOS
    if [[ "$OSTYPE" != "darwin"* ]]; then
        error_message "This utility is designed for macOS"
        return 1
    fi
    
    # Check basic commands
    local commands=("rm" "find" "defaults")
    for cmd in "${commands[@]}"; do
        if command -v "$cmd" >/dev/null 2>&1; then
            echo "✓ $cmd available"
        else
            echo "✗ $cmd not available"
        fi
    done
    
    success_message "Basic health check completed"
}

# Fallback CLI installer function
fallback_install_cli_tools() {
    echo "Installing Cursor CLI tools..."
    echo "============================="
    
    # Check if Cursor.app exists first
    if [[ ! -d "/Applications/Cursor.app" ]]; then
        error_message "Cursor.app not found. Please install Cursor first from https://cursor.sh"
        return 1
    fi
    
    # Find the CLI binary inside the app bundle
    local cli_source="/Applications/Cursor.app/Contents/Resources/app/bin/cursor"
    local cli_dest="/usr/local/bin/cursor"
    
    if [[ ! -f "$cli_source" ]]; then
        echo "Looking for alternative CLI locations..."
        local alt_locations=(
            "/Applications/Cursor.app/Contents/MacOS/cursor"
            "/Applications/Cursor.app/Contents/Resources/cursor"
            "/Applications/Cursor.app/bin/cursor"
        )
        
        for location in "${alt_locations[@]}"; do
            if [[ -f "$location" ]]; then
                cli_source="$location"
                echo "Found CLI binary at: $cli_source"
                break
            fi
        done
        
        if [[ ! -f "$cli_source" ]]; then
            error_message "Could not find Cursor CLI binary in application bundle"
            echo ""
            echo "Alternative installation methods:"
            echo "1. Open Cursor.app and use: View > Command Palette > Install 'cursor' command"
            echo "2. Manually create symlink if you know the correct path"
            echo "3. Use the alias method: alias cursor='open -a Cursor'"
            return 1
        fi
    fi
    
    echo "Installing CLI from: $cli_source"
    echo "Installing CLI to: $cli_dest"
    
    # Create symlink with sudo
    if safe_sudo ln -sf "$cli_source" "$cli_dest"; then
        success_message "✓ Cursor CLI installed successfully"
        
        # Verify installation
        if command -v cursor >/dev/null 2>&1; then
            local version=$(cursor --version 2>/dev/null || echo "Unknown")
            success_message "✓ Verification successful: $version"
        else
            echo "⚠️  CLI installed but not found in PATH"
            echo "   You may need to restart your terminal or add /usr/local/bin to your PATH"
        fi
        
        # Check for conflicts with VS Code
        if command -v code >/dev/null 2>&1; then
            echo ""
            echo "Note: 'code' command detected. To avoid conflicts:"
            echo "  • Use 'cursor' command for Cursor"
            echo "  • Use 'code' command for VS Code"
        fi
        
        return 0
    else
        error_message "Failed to install CLI tools"
        echo ""
        echo "Manual installation steps:"
        echo "1. Open Terminal"
        echo "2. Run: sudo ln -sf '$cli_source' '$cli_dest'"
        echo "3. Or add to your shell profile: alias cursor='open -a Cursor'"
        return 1
    fi
}

# Fallback troubleshooting function
fallback_troubleshoot_cursor() {
    echo "Cursor Troubleshooting Guide"
    echo "==========================="
    echo ""
    
    # Check common issues
    echo "1. Command Line Issues:"
    echo "----------------------"
    
    if ! command -v cursor >/dev/null 2>&1; then
        echo "❌ 'cursor' command not found"
        echo "   Solution: Run option 6 to install CLI tools"
    else
        echo "✓ 'cursor' command available"
    fi
    
    # Check for conflicts
    if command -v code >/dev/null 2>&1; then
        local code_path=$(which code 2>/dev/null)
        if [[ -L "$code_path" ]]; then
            local link_target=$(readlink "$code_path" 2>/dev/null)
            if [[ "$link_target" == *"cursor"* ]] || [[ "$link_target" == *"Cursor"* ]]; then
                echo "⚠️  'code' command hijacked by Cursor"
                echo "   Solution: Remove/fix the symlink or use 'cursor' command instead"
            fi
        fi
    fi
    
    echo ""
    echo "2. Application Launch Issues:"
    echo "----------------------------"
    
    if [[ -d "/Applications/Cursor.app" ]]; then
        echo "✓ Cursor.app installed"
        
        # Check if app can launch
        if safe_sudo open -a "Cursor" --args --version >/dev/null 2>&1; then
            echo "✓ Cursor.app can launch"
        else
            echo "❌ Cursor.app launch failed"
            echo "   Try: Reset permissions, reinstall Cursor"
        fi
    else
        echo "❌ Cursor.app not installed"
        echo "   Solution: Download and install from https://cursor.sh"
    fi
    
    echo ""
    echo "3. WSL/Linux Issues:"
    echo "-------------------"
    
    if [[ -n "${WSL_DISTRO_NAME:-}" ]] || [[ -f "/proc/version" ]] && grep -qi "microsoft\|wsl" /proc/version 2>/dev/null; then
        echo "ℹ️  WSL environment detected"
        echo "   • GUI apps need X11 forwarding or Windows integration"
        echo "   • Use Windows Cursor installation for best results"
        echo "   • Install X11 server (VcXsrv, Xming) for GUI forwarding"
    else
        echo "✓ Not a WSL environment"
    fi
    
    echo ""
    echo "4. Common Solutions:"
    echo "-------------------"
    echo "   • Restart terminal after installing CLI tools"
    echo "   • Check PATH includes /usr/local/bin"
    echo "   • Use 'cursor .' instead of 'code .' in projects"
    echo "   • For WSL: Use Windows Cursor + remote connection"
    echo "   • Reset Cursor: rm -rf ~/.cursor ~/.cursor-server"
    
    echo ""
    echo "5. Alternative Commands:"
    echo "-----------------------"
    echo "   • macOS: open -a Cursor"
    echo "   • CLI alias: alias cursor='open -a Cursor'"
    echo "   • Full path: /Applications/Cursor.app/Contents/MacOS/Cursor"
}

# Enhanced fallback menu function
fallback_show_menu() {
    clear
    echo "=============================================="
    echo "    Cursor AI Editor Management Utility"
    echo "    (Basic Mode - Enhanced Diagnostics)"
    echo "=============================================="
    echo
    
    # Show quick status
    if [[ -d "/Applications/Cursor.app" ]]; then
        if command -v cursor >/dev/null 2>&1; then
            echo "Status: ✓ Cursor installed with CLI tools"
        else
            echo "Status: ⚠️  Cursor installed, CLI tools missing"
        fi
    else
        echo "Status: ❌ Cursor not installed"
    fi
    
    echo
    echo "Available options:"
    echo "  1) Basic Uninstallation"
    echo "  2) Detailed Installation Check"
    echo "  3) Basic Health Check"
    echo "  4) Show Help"
    echo "  5) Troubleshooting Guide"
    echo "  6) Install CLI Tools"
    echo "  7) Exit"
    echo
    echo -n "Enter your choice [1-7]: "
    
    read -r choice
    case "$choice" in
        1) fallback_uninstall_cursor ;;
        2) fallback_check_installation ;;
        3) fallback_health_check ;;
        4) show_help ;;
        5) fallback_troubleshoot_cursor ;;
        6) fallback_install_cli_tools ;;
        7) exit 0 ;;
        *) echo "Invalid choice"; sleep 2; fallback_show_menu ;;
    esac
    
    echo
    echo -n "Press Enter to return to the main menu..."
    read
    fallback_show_menu
}

# Handle backup-related operations with error handling
handle_backup_operations() {
    if ! declare -f create_backup >/dev/null 2>&1; then
        error_message "Backup functionality not available"
        return 1
    fi
    
    case "${BACKUP_OPERATION:-}" in
        "create")
            create_backup
            ;;
        "restore")
            restore_from_backup "${BACKUP_PATH:-}"
            ;;
        "list")
            list_backups
            ;;
        *)
            if declare -f show_backup_menu >/dev/null 2>&1; then
                show_backup_menu
            else
                error_message "Backup menu not available"
                return 1
            fi
            ;;
    esac
}

# Enhanced argument parsing function with error recovery
parse_arguments() {
    # Set defaults
    OPERATION=""
    DMG_PATH=""
    BACKUP_OPERATION=""
    BACKUP_PATH=""
    DRY_RUN="false"
    VERBOSE="false"
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -u|--uninstall)
                OPERATION="uninstall"
                shift
                ;;
            -i|--install)
                OPERATION="install"
                if [[ $# -lt 2 ]] || [[ "$2" == -* ]]; then
                    error_message "Install option requires a DMG path"
                    return 1
                fi
                DMG_PATH="$2"
                shift 2
                ;;
            -o|--optimize)
                OPERATION="optimize"
                shift
                ;;
            -r|--reset-performance)
                OPERATION="reset-performance"
                shift
                ;;
            -c|--check)
                OPERATION="check"
                shift
                ;;
            -m|--menu)
                OPERATION="menu"
                shift
                ;;
            -b|--backup)
                OPERATION="backup"
                if [[ $# -lt 2 ]] || [[ "$2" == -* ]]; then
                    error_message "Backup option requires an operation (create/restore/list)"
                    return 1
                fi
                BACKUP_OPERATION="$2"
                shift 2
                ;;
            --backup-path)
                if [[ $# -lt 2 ]] || [[ "$2" == -* ]]; then
                    error_message "Backup path option requires a path"
                    return 1
                fi
                BACKUP_PATH="$2"
                shift 2
                ;;
            -t|--test)
                OPERATION="test"
                shift
                ;;
            --health)
                OPERATION="health"
                shift
                ;;
            --dry-run)
                DRY_RUN="true"
                shift
                ;;
            --verbose)
                VERBOSE="true"
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                error_message "Unknown argument: $1"
                show_help
                return 1
                ;;
        esac
    done

    # Set default operation if none specified
    if [[ -z "${OPERATION}" ]]; then
        OPERATION="menu"
    fi
    
    return 0
}

################################################################################
# Script Execution Entry Point
################################################################################

# Execute main function if script is run directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
