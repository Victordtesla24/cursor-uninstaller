#!/bin/bash

################################################################################
# Cursor Uninstaller Installer Script
# Handles installation of the Cursor Uninstaller utility
################################################################################

set -eE

# Configuration
INSTALLER_NAME="Cursor Uninstaller Installer"
APP_NAME="CursorUninstaller.app"
BUNDLE_ID="com.cursoruninstaller.app"
MIN_MACOS_VERSION="10.15"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Logging functions
log_info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

log_step() {
    echo -e "\n${BOLD}${BLUE}=== $1 ===${NC}"
}

# Error handler
error_handler() {
    local line_number="$1"
    local error_code="$2"
    log_error "Installation failed at line $line_number with exit code $error_code"
    cleanup_on_error
    exit 1
}

trap 'error_handler $LINENO $?' ERR

# Cleanup on error
cleanup_on_error() {
    log_warning "Cleaning up partial installation..."
    
    # Remove partially installed app if it exists
    if [[ -d "/Applications/$APP_NAME.partial" ]]; then
        sudo rm -rf "/Applications/$APP_NAME.partial" 2>/dev/null || true
        log_info "Removed partial installation"
    fi
}

# Display installation header
display_header() {
    clear
    echo -e "${BOLD}${BLUE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                CURSOR UNINSTALLER INSTALLER                  ║"
    echo "║                    Professional Setup                        ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo
    log_info "Welcome to the $INSTALLER_NAME"
    echo
}

# Check system requirements
check_system_requirements() {
    log_step "CHECKING SYSTEM REQUIREMENTS"
    
    # Check macOS version
    if [[ "$OSTYPE" != "darwin"* ]]; then
        log_error "This installer requires macOS"
        exit 1
    fi
    
    local macos_version
    macos_version=$(sw_vers -productVersion)
    log_info "macOS version: $macos_version"
    
    # Check if version meets minimum requirement
    if [[ "$(printf '%s\n' "$MIN_MACOS_VERSION" "$macos_version" | sort -V | head -n1)" != "$MIN_MACOS_VERSION" ]]; then
        log_error "macOS $MIN_MACOS_VERSION or later is required"
        log_error "Current version: $macos_version"
        exit 1
    fi
    
    # Check architecture
    local arch=$(uname -m)
    log_info "System architecture: $arch"
    
    # Check available disk space
    local available_space
    available_space=$(df -h /Applications | awk 'NR==2 {print $4}')
    log_info "Available space in /Applications: $available_space"
    
    # Check if we have write permissions to /Applications
    if [[ ! -w "/Applications" ]]; then
        log_warning "/Applications directory is not writable - will require administrator privileges"
    fi
    
    # Check for required system tools
    local required_tools=("cp" "chmod" "chown" "plutil")
    local missing_tools=()
    
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            missing_tools+=("$tool")
        fi
    done
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        log_error "Missing required system tools: ${missing_tools[*]}"
        exit 1
    fi
    
    log_success "System requirements met"
}

# Check for existing installation
check_existing_installation() {
    log_step "CHECKING FOR EXISTING INSTALLATION"
    
    if [[ -d "/Applications/$APP_NAME" ]]; then
        log_warning "Existing installation found at /Applications/$APP_NAME"
        
        # Get version of existing installation
        local existing_version=""
        if [[ -f "/Applications/$APP_NAME/Contents/Info.plist" ]]; then
            existing_version=$(defaults read "/Applications/$APP_NAME/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null || echo "unknown")
            log_info "Currently installed version: $existing_version"
        fi
        
        echo
        echo -e "${YELLOW}An existing installation was found.${NC}"
        echo -e "Existing version: ${BOLD}$existing_version${NC}"
        echo
        echo "Choose an option:"
        echo "  1) Replace existing installation (recommended)"
        echo "  2) Cancel installation"
        echo
        read -p "Enter your choice [1-2]: " choice
        
        case "$choice" in
            1)
                log_info "User chose to replace existing installation"
                remove_existing_installation
                ;;
            2|"")
                log_info "Installation cancelled by user"
                exit 0
                ;;
            *)
                log_error "Invalid choice: $choice"
                exit 1
                ;;
        esac
    else
        log_info "No existing installation found"
    fi
}

# Remove existing installation
remove_existing_installation() {
    log_info "Removing existing installation..."
    
    # Create backup name with timestamp
    local backup_name="${APP_NAME}.backup.$(date +%Y%m%d_%H%M%S)"
    
    # First try to move to backup location
    if mv "/Applications/$APP_NAME" "/Applications/$backup_name" 2>/dev/null; then
        log_success "Existing installation backed up as: $backup_name"
        
        # Ask user if they want to keep the backup
        echo
        read -p "Keep backup of previous installation? (Y/n): " keep_backup
        case "$keep_backup" in
            [Nn]|[Nn][Oo])
                log_info "Removing backup..."
                rm -rf "/Applications/$backup_name" 2>/dev/null || true
                log_success "Backup removed"
                ;;
            *)
                log_info "Backup kept at: /Applications/$backup_name"
                ;;
        esac
    else
        # If move failed, try with sudo
        log_warning "Standard removal failed, trying with administrator privileges..."
        if sudo rm -rf "/Applications/$APP_NAME"; then
            log_success "Existing installation removed"
        else
            log_error "Failed to remove existing installation"
            exit 1
        fi
    fi
}

# Locate source application
locate_source_app() {
    log_step "LOCATING SOURCE APPLICATION"
    
    # Try multiple possible locations
    local possible_locations=(
        "$(dirname "$SCRIPT_DIR")/$APP_NAME"
        "$SCRIPT_DIR/$APP_NAME"
        "./$APP_NAME"
        "../$APP_NAME"
    )
    
    for location in "${possible_locations[@]}"; do
        if [[ -d "$location" ]]; then
            SOURCE_APP="$location"
            log_success "Found source application at: $SOURCE_APP"
            return 0
        fi
    done
    
    # If not found in standard locations, ask user
    echo
    log_warning "Source application not found in standard locations"
    echo
    read -p "Please enter the path to $APP_NAME: " user_path
    
    if [[ -d "$user_path" ]]; then
        SOURCE_APP="$user_path"
        log_success "Using user-specified path: $SOURCE_APP"
        return 0
    else
        log_error "Source application not found: $user_path"
        exit 1
    fi
}

# Validate source application
validate_source_app() {
    log_step "VALIDATING SOURCE APPLICATION"
    
    if [[ ! -d "$SOURCE_APP" ]]; then
        log_error "Source application directory not found: $SOURCE_APP"
        exit 1
    fi
    
    # Check for required components
    local required_components=(
        "Contents/Info.plist"
        "Contents/MacOS/CursorUninstaller"
        "Contents/Resources/uninstall_cursor.sh"
    )
    
    local missing_components=()
    for component in "${required_components[@]}"; do
        if [[ ! -e "$SOURCE_APP/$component" ]]; then
            missing_components+=("$component")
        fi
    done
    
    if [[ ${#missing_components[@]} -gt 0 ]]; then
        log_error "Source application is missing required components:"
        for component in "${missing_components[@]}"; do
            log_error "  - $component"
        done
        exit 1
    fi
    
    # Validate Info.plist
    if ! plutil -lint "$SOURCE_APP/Contents/Info.plist" >/dev/null 2>&1; then
        log_error "Invalid Info.plist in source application"
        exit 1
    fi
    
    # Check bundle identifier
    local bundle_id
    bundle_id=$(defaults read "$SOURCE_APP/Contents/Info.plist" CFBundleIdentifier 2>/dev/null || echo "")
    if [[ "$bundle_id" != "$BUNDLE_ID" ]]; then
        log_warning "Bundle identifier mismatch. Expected: $BUNDLE_ID, Found: $bundle_id"
    fi
    
    # Get and display version
    local app_version
    app_version=$(defaults read "$SOURCE_APP/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null || echo "unknown")
    log_info "Application version: $app_version"
    
    log_success "Source application validation passed"
}

# Install application
install_application() {
    log_step "INSTALLING CURSOR UNINSTALLER"
    
    local dest_app="/Applications/$APP_NAME"
    local temp_dest="/Applications/$APP_NAME.partial"
    
    log_info "Installing to: $dest_app"
    
    # Copy to temporary location first
    log_info "Copying application files..."
    if cp -R "$SOURCE_APP" "$temp_dest"; then
        log_success "Application files copied successfully"
    else
        log_error "Failed to copy application files"
        exit 1
    fi
    
    # Set proper permissions
    log_info "Setting permissions..."
    
    # Set ownership if needed
    if [[ "$(stat -f %u "$temp_dest")" != "$(id -u)" ]]; then
        if sudo chown -R "$(id -u):$(id -g)" "$temp_dest"; then
            log_info "Ownership corrected"
        else
            log_warning "Could not set ownership - continuing anyway"
        fi
    fi
    
    # Set permissions
    chmod -R 755 "$temp_dest" 2>/dev/null || true
    chmod +x "$temp_dest/Contents/MacOS/CursorUninstaller" 2>/dev/null || true
    chmod +x "$temp_dest/Contents/Resources/uninstall_cursor.sh" 2>/dev/null || true
    
    # Move to final location
    if mv "$temp_dest" "$dest_app"; then
        log_success "Application installed successfully"
    else
        log_error "Failed to move application to final location"
        exit 1
    fi
    
    # Verify installation
    if [[ -d "$dest_app" ]] && [[ -x "$dest_app/Contents/MacOS/CursorUninstaller" ]]; then
        log_success "Installation verification passed"
    else
        log_error "Installation verification failed"
        exit 1
    fi
}

# Create desktop shortcut (optional)
create_desktop_shortcut() {
    log_step "CREATING DESKTOP SHORTCUT (OPTIONAL)"
    
    echo
    read -p "Create desktop shortcut? (Y/n): " create_shortcut
    
    case "$create_shortcut" in
        [Nn]|[Nn][Oo])
            log_info "Desktop shortcut creation skipped"
            return 0
            ;;
    esac
    
    local desktop_path="$HOME/Desktop"
    local shortcut_path="$desktop_path/Cursor Uninstaller.app"
    
    if [[ -d "$desktop_path" ]]; then
        # Create symbolic link to the app
        if ln -sf "/Applications/$APP_NAME" "$shortcut_path" 2>/dev/null; then
            log_success "Desktop shortcut created"
        else
            log_warning "Could not create desktop shortcut"
        fi
    else
        log_warning "Desktop directory not found"
    fi
}

# Register with system
register_application() {
    log_step "REGISTERING APPLICATION WITH SYSTEM"
    
    # Refresh Launch Services database
    log_info "Refreshing Launch Services database..."
    if /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "/Applications/$APP_NAME" >/dev/null 2>&1; then
        log_success "Application registered with Launch Services"
    else
        log_warning "Could not register with Launch Services"
    fi
    
    # Update Spotlight index
    log_info "Updating Spotlight index..."
    if mdimport "/Applications/$APP_NAME" >/dev/null 2>&1; then
        log_success "Spotlight index updated"
    else
        log_warning "Could not update Spotlight index"
    fi
}

# Post-installation verification
post_installation_verification() {
    log_step "POST-INSTALLATION VERIFICATION"
    
    local app_path="/Applications/$APP_NAME"
    local verification_errors=0
    
    # Test 1: Application bundle exists and is valid
    if [[ -d "$app_path" ]]; then
        log_success "✓ Application bundle exists"
    else
        log_error "✗ Application bundle not found"
        ((verification_errors++))
    fi
    
    # Test 2: Executable is present and executable
    if [[ -x "$app_path/Contents/MacOS/CursorUninstaller" ]]; then
        log_success "✓ Main executable is present and executable"
    else
        log_error "✗ Main executable missing or not executable"
        ((verification_errors++))
    fi
    
    # Test 3: Resources are present
    if [[ -f "$app_path/Contents/Resources/uninstall_cursor.sh" ]]; then
        log_success "✓ Core resources are present"
    else
        log_error "✗ Core resources missing"
        ((verification_errors++))
    fi
    
    # Test 4: Info.plist is valid
    if plutil -lint "$app_path/Contents/Info.plist" >/dev/null 2>&1; then
        log_success "✓ Info.plist is valid"
    else
        log_error "✗ Info.plist is invalid"
        ((verification_errors++))
    fi
    
    # Test 5: Script syntax check
    if bash -n "$app_path/Contents/Resources/uninstall_cursor.sh" 2>/dev/null; then
        log_success "✓ Script syntax is valid"
    else
        log_error "✗ Script contains syntax errors"
        ((verification_errors++))
    fi
    
    # Test 6: Quick functional test
    log_info "Running functional test..."
    if cd "$app_path/Contents/Resources" && timeout 5s bash uninstall_cursor.sh --help >/dev/null 2>&1; then
        log_success "✓ Application responds to help command"
    else
        log_warning "⚠ Application help test failed or timed out"
    fi
    
    if [[ $verification_errors -eq 0 ]]; then
        log_success "All verification tests passed"
        return 0
    else
        log_error "Verification failed with $verification_errors errors"
        return 1
    fi
}

# Display installation summary
display_installation_summary() {
    log_step "INSTALLATION COMPLETE"
    
    local app_path="/Applications/$APP_NAME"
    local app_version=""
    
    if [[ -f "$app_path/Contents/Info.plist" ]]; then
        app_version=$(defaults read "$app_path/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null || echo "unknown")
    fi
    
    echo
    echo -e "${BOLD}${GREEN}🎉 INSTALLATION COMPLETED SUCCESSFULLY!${NC}"
    echo
    echo -e "${BOLD}INSTALLATION DETAILS:${NC}"
    echo -e "  📦 Application: ${BOLD}Cursor Uninstaller${NC}"
    echo -e "  📋 Version: ${BOLD}$app_version${NC}"
    echo -e "  📍 Location: ${BOLD}$app_path${NC}"
    echo -e "  🎯 Bundle ID: ${BOLD}$BUNDLE_ID${NC}"
    echo
    echo -e "${BOLD}${CYAN}HOW TO USE:${NC}"
    echo -e "  🖱️  GUI Mode: Double-click the app in Applications folder"
    echo -e "  ⌨️  Terminal Mode: Launch Terminal and run the script directly"
    echo -e "  📖 Help: Run with --help flag for detailed usage instructions"
    echo
    echo -e "${BOLD}${YELLOW}NEXT STEPS:${NC}"
    echo -e "  1. Launch the application from Applications folder"
    echo -e "  2. Choose your preferred operation mode (menu or command-line)"
    echo -e "  3. Review the help documentation for available options"
    echo -e "  4. Consider running a system health check first"
    echo
    echo -e "${BOLD}${GREEN}APPLICATION FEATURES:${NC}"
    echo -e "  ✅ Complete Cursor AI Editor removal"
    echo -e "  ✅ Git backup integration before uninstallation"
    echo -e "  ✅ AI-optimized performance tuning"
    echo -e "  ✅ Comprehensive system health diagnostics"
    echo -e "  ✅ Interactive menu and command-line interfaces"
    echo -e "  ✅ Advanced removal verification and reporting"
    echo
}

# Main installation function
main() {
    display_header
    
    # Execute installation steps
    check_system_requirements
    check_existing_installation
    locate_source_app
    validate_source_app
    install_application
    create_desktop_shortcut
    register_application
    
    # Verify installation
    if post_installation_verification; then
        display_installation_summary
        
        # Ask if user wants to launch the application
        echo
        read -p "Launch Cursor Uninstaller now? (Y/n): " launch_now
        case "$launch_now" in
            [Nn]|[Nn][Oo])
                log_info "You can launch the application later from Applications folder"
                ;;
            *)
                log_info "Launching Cursor Uninstaller..."
                open "/Applications/$APP_NAME" 2>/dev/null || {
                    log_warning "Could not launch application automatically"
                    log_info "Please launch it manually from Applications folder"
                }
                ;;
        esac
    else
        log_error "Installation verification failed"
        log_error "The application may not function correctly"
        exit 1
    fi
    
    echo
    log_success "Thank you for installing Cursor Uninstaller!"
    echo
}

# Handle command line arguments
case "${1:-}" in
    --help|-h)
        echo "Cursor Uninstaller Installer"
        echo "Usage: $0 [OPTIONS]"
        echo
        echo "This script installs the Cursor Uninstaller application to your Applications folder."
        echo
        echo "OPTIONS:"
        echo "  --help, -h        Show this help message"
        echo "  --version, -v     Show version information"
        echo
        echo "The installer will:"
        echo "  • Check system requirements"
        echo "  • Handle existing installations"
        echo "  • Copy application files to /Applications"
        echo "  • Set proper permissions"
        echo "  • Register with system databases"
        echo "  • Verify installation integrity"
        echo
        exit 0
        ;;
    --version|-v)
        echo "Cursor Uninstaller Installer v1.0.0"
        exit 0
        ;;
esac

# Initialize variables
SOURCE_APP=""

# Execute main installation
main "$@" 