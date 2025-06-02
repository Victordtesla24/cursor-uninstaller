#!/bin/bash

################################################################################
# Cursor Uninstaller DMG Package Creator
# Creates a distributable .dmg file with all components
################################################################################

set -eE

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_ROOT/build"
PACKAGE_DIR="$BUILD_DIR/CursorUninstaller"
DMG_NAME="CursorUninstaller"
VERSION="1.0.0"
BUNDLE_ID="com.cursoruninstaller.app"
OUTPUT_DIR="${OUTPUT_DIR:-/Users/vicd/Downloads}"

# Colors for output
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
    log_error "Script failed at line $line_number with exit code $error_code"
    cleanup
    exit 1
}

trap 'error_handler $LINENO $?' ERR

# Cleanup function
cleanup() {
    if [[ -d "$BUILD_DIR" ]] && [[ "$KEEP_BUILD_DIR" != "true" ]]; then
        log_info "Cleaning up build directory..."
        rm -rf "$BUILD_DIR"
    fi
}

# Trap cleanup on exit only if not keeping build dir
if [[ "$KEEP_BUILD_DIR" != "true" ]]; then
    trap cleanup EXIT
fi

# Validate prerequisites
validate_prerequisites() {
    log_step "VALIDATING PREREQUISITES"
    
    # Check if we're on macOS
    if [[ "$OSTYPE" != "darwin"* ]]; then
        log_error "This script must be run on macOS to create .dmg files"
        exit 1
    fi
    
    # Check for required tools
    local required_tools=("hdiutil" "codesign" "plutil" "defaults")
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            log_error "Required tool not found: $tool"
            exit 1
        fi
    done
    
    # Check if main script exists
    if [[ ! -f "$PROJECT_ROOT/bin/uninstall_cursor.sh" ]]; then
        log_error "Main script not found: $PROJECT_ROOT/bin/uninstall_cursor.sh"
        exit 1
    fi
    
    # Create output directory if it doesn't exist
    if [[ ! -d "$OUTPUT_DIR" ]]; then
        log_info "Creating output directory: $OUTPUT_DIR"
        mkdir -p "$OUTPUT_DIR"
    fi
    
    log_success "All prerequisites validated"
}

# Create package structure
create_package_structure() {
    log_step "CREATING PACKAGE STRUCTURE"
    
    # Create build directories
    mkdir -p "$PACKAGE_DIR"
    mkdir -p "$PACKAGE_DIR/CursorUninstaller.app/Contents/MacOS"
    mkdir -p "$PACKAGE_DIR/CursorUninstaller.app/Contents/Resources"
    mkdir -p "$PACKAGE_DIR/CursorUninstaller.app/Contents/Resources/lib"
    mkdir -p "$PACKAGE_DIR/CursorUninstaller.app/Contents/Resources/modules"
    mkdir -p "$PACKAGE_DIR/CursorUninstaller.app/Contents/Resources/docs"
    mkdir -p "$PACKAGE_DIR/CursorUninstaller.app/Contents/Resources/scripts"
    mkdir -p "$PACKAGE_DIR/CursorUninstaller.app/Contents/Resources/tests"
    
    log_success "Package structure created"
}

# Copy application files
copy_application_files() {
    log_step "COPYING APPLICATION FILES"
    
    local app_resources="$PACKAGE_DIR/CursorUninstaller.app/Contents/Resources"
    
    # Copy main script
    cp "$PROJECT_ROOT/bin/uninstall_cursor.sh" "$app_resources/"
    chmod +x "$app_resources/uninstall_cursor.sh"
    log_info "Copied main script"
    
    # Copy library files
    if [[ -d "$PROJECT_ROOT/lib" ]]; then
        cp -r "$PROJECT_ROOT/lib/"* "$app_resources/lib/"
        log_info "Copied library files"
    fi
    
    # Copy modules
    if [[ -d "$PROJECT_ROOT/modules" ]]; then
        cp -r "$PROJECT_ROOT/modules/"* "$app_resources/modules/"
        log_info "Copied module files"
    fi
    
    # Copy documentation
    if [[ -d "$PROJECT_ROOT/docs" ]]; then
        cp -r "$PROJECT_ROOT/docs/"* "$app_resources/docs/"
        log_info "Copied documentation"
    fi
    
    # Copy scripts (excluding the build scripts to avoid recursion)
    if [[ -d "$PROJECT_ROOT/scripts" ]]; then
        # Copy scripts but exclude packaging scripts
        for script in "$PROJECT_ROOT/scripts/"*; do
            local script_name
            script_name=$(basename "$script")
            if [[ "$script_name" != "create_dmg_package.sh" ]] && \
               [[ "$script_name" != "build_release.sh" ]] && \
               [[ "$script_name" != "install_cursor_uninstaller.sh" ]]; then
                cp "$script" "$app_resources/scripts/"
            fi
        done
        log_info "Copied utility scripts"
    fi
    
    # Copy tests (for verification purposes)
    if [[ -d "$PROJECT_ROOT/tests" ]]; then
        cp -r "$PROJECT_ROOT/tests/"* "$app_resources/tests/"
        log_info "Copied test suite"
    fi
    
    # Copy important root files
    for file in README.md LICENSE .env; do
        if [[ -f "$PROJECT_ROOT/$file" ]]; then
            cp "$PROJECT_ROOT/$file" "$app_resources/"
            log_info "Copied $file"
        fi
    done
    
    log_success "Application files copied"
}

# Create launcher script
create_launcher_script() {
    log_step "CREATING LAUNCHER SCRIPT"
    
    local launcher="$PACKAGE_DIR/CursorUninstaller.app/Contents/MacOS/CursorUninstaller"
    
    cat > "$launcher" << 'EOF'
#!/bin/bash

# Cursor Uninstaller Launcher
# This script launches the Cursor Uninstaller with proper environment setup

# Get the directory where this app bundle is located
APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../Resources" && pwd)"

# Set up environment
export CURSOR_UNINSTALLER_APP_MODE=true
export CURSOR_UNINSTALLER_RESOURCES="$APP_DIR"

# Change to the resources directory
cd "$APP_DIR"

# Check if we're running in a GUI environment
if [[ -n "$DISPLAY" ]] || [[ "$TERM_PROGRAM" == "Apple_Terminal" ]] || [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then
    # Launch in Terminal with proper title and working directory
    if command -v osascript >/dev/null 2>&1; then
        osascript << APPLESCRIPT
tell application "Terminal"
    activate
    set newTab to do script "cd '$APP_DIR' && ./bin/uninstall_cursor.sh --menu"
    set custom title of newTab to "Cursor Uninstaller v1.0.0"
    set background color of newTab to {0, 0, 0}
    set normal text color of newTab to {65535, 65535, 65535}
end tell
APPLESCRIPT
    else
        # Fallback: run directly
        exec ./bin/uninstall_cursor.sh --menu
    fi
else
    # Running in non-GUI environment (SSH, etc.)
    exec ./bin/uninstall_cursor.sh --menu
fi
EOF
    
    chmod +x "$launcher"
    log_success "Launcher script created"
}

# Create Info.plist
create_info_plist() {
    log_step "CREATING INFO.PLIST"
    
    local info_plist="$PACKAGE_DIR/CursorUninstaller.app/Contents/Info.plist"
    
    cat > "$info_plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>CursorUninstaller</string>
    <key>CFBundleIdentifier</key>
    <string>$BUNDLE_ID</string>
    <key>CFBundleName</key>
    <string>Cursor Uninstaller</string>
    <key>CFBundleDisplayName</key>
    <string>Cursor Uninstaller</string>
    <key>CFBundleVersion</key>
    <string>$VERSION</string>
    <key>CFBundleShortVersionString</key>
    <string>$VERSION</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleSignature</key>
    <string>CURS</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.15</string>
    <key>LSApplicationCategoryType</key>
    <string>public.app-category.utilities</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSRequiresAquaSystemAppearance</key>
    <false/>
    <key>NSSupportsAutomaticGraphicsSwitching</key>
    <true/>
    <key>LSUIElement</key>
    <false/>
    <key>CFBundleDocumentTypes</key>
    <array/>
    <key>NSHumanReadableCopyright</key>
    <string>© 2024 Cursor Uninstaller. All rights reserved.</string>
    <key>CFBundleGetInfoString</key>
    <string>Cursor Uninstaller $VERSION - Complete Cursor AI Editor Management Utility</string>
    <key>LSArchitecturePriority</key>
    <array>
        <string>arm64</string>
        <string>x86_64</string>
    </array>
</dict>
</plist>
EOF
    
    log_success "Info.plist created"
}

# Create application icon using system tools
create_app_icon() {
    log_step "CREATING APPLICATION ICON"
    
    local icon_dir="$PACKAGE_DIR/CursorUninstaller.app/Contents/Resources"
    local iconset_dir="$BUILD_DIR/AppIcon.iconset"
    
    # Create iconset directory
    mkdir -p "$iconset_dir"
    
    # Create a simple icon using system fonts and tools
    if command -v sips >/dev/null 2>&1 && command -v textutil >/dev/null 2>&1; then
        # Create base image using built-in icon
        local base_icon="/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/ToolbarUtilitiesFolderIcon.icns"
        
        if [[ -f "$base_icon" ]]; then
            # Extract the largest size and create our icon sizes
            local sizes=("16" "32" "64" "128" "256" "512" "1024")
            
            for size in "${sizes[@]}"; do
                local output_file="$iconset_dir/icon_${size}x${size}.png"
                sips -s format png -Z "$size" "$base_icon" --out "$output_file" >/dev/null 2>&1 || true
                
                # Create @2x versions for retina
                if [[ "$size" != "1024" ]]; then
                    local retina_size=$((size * 2))
                    local retina_output="$iconset_dir/icon_${size}x${size}@2x.png"
                    sips -s format png -Z "$retina_size" "$base_icon" --out "$retina_output" >/dev/null 2>&1 || true
                fi
            done
            
            # Convert to icns
            if command -v iconutil >/dev/null 2>&1; then
                iconutil -c icns "$iconset_dir" -o "$icon_dir/AppIcon.icns" >/dev/null 2>&1 || true
                log_info "Custom application icon created"
            fi
        fi
    fi
    
    # Clean up iconset directory
    rm -rf "$iconset_dir" 2>/dev/null || true
    
    log_success "Icon setup completed"
}

# Create installer documentation
create_installer_docs() {
    log_step "CREATING INSTALLER DOCUMENTATION"
    
    # Create README for the DMG
    cat > "$PACKAGE_DIR/README.txt" << 'EOF'
CURSOR UNINSTALLER - INSTALLATION INSTRUCTIONS
==============================================

WHAT IS THIS?
This package contains the Cursor Uninstaller utility, a comprehensive tool for
managing your Cursor AI Editor installation on macOS.

INSTALLATION:
1. Drag "CursorUninstaller.app" to your Applications folder
2. Double-click the app to launch the Cursor Uninstaller
3. The utility will open in Terminal with an interactive menu

FEATURES:
• Complete Cursor removal with system cleanup
• Git backup integration before uninstallation  
• AI-optimized performance tuning
• System health checks and diagnostics
• Advanced removal with verification
• Command-line interface support

SYSTEM REQUIREMENTS:
• macOS 10.15 (Catalina) or later
• Administrator privileges for system modifications
• Terminal access for full functionality

USAGE:
The application provides both interactive menu and command-line interfaces:
- Interactive: Double-click the app for guided menu
- Command-line: Use Terminal for advanced options

COMMAND LINE USAGE:
./bin/uninstall_cursor.sh [OPTIONS]

OPTIONS:
  -u, --uninstall         Complete removal of Cursor
  --git-backup           Perform Git backup before operations
  -o, --optimize          Comprehensive performance optimization
  -c, --check             Check Cursor installation status
  --health               Perform system health check
  --verbose              Enable detailed logging
  -h, --help             Show help message

EXAMPLES:
./bin/uninstall_cursor.sh --git-backup -u   # Git backup + complete uninstall
./bin/uninstall_cursor.sh --optimize        # AI performance optimization
./bin/uninstall_cursor.sh --health          # System health check

SECURITY:
This utility requires administrator privileges to perform system-level operations.
All operations are logged and can be reviewed in the application logs.

For detailed documentation, see the docs folder in the app bundle.

SUPPORT:
For issues or questions, check the included documentation or visit the project repository.

© 2024 Cursor Uninstaller. All rights reserved.
EOF
    
    # Create uninstaller for the uninstaller (meta!)
    cat > "$PACKAGE_DIR/Uninstall CursorUninstaller.command" << 'EOF'
#!/bin/bash

echo "Cursor Uninstaller Removal"
echo "=========================="
echo
echo "This will remove the Cursor Uninstaller application from your system."
echo
read -p "Are you sure you want to continue? (y/N): " response

case "$response" in
    [Yy]|[Yy][Ee][Ss])
        echo "Removing Cursor Uninstaller..."
        
        # Remove from Applications
        if [[ -d "/Applications/CursorUninstaller.app" ]]; then
            sudo rm -rf "/Applications/CursorUninstaller.app"
            echo "✓ Removed from Applications"
        fi
        
        # Remove any preferences
        if [[ -f "$HOME/Library/Preferences/com.cursoruninstaller.app.plist" ]]; then
            rm -f "$HOME/Library/Preferences/com.cursoruninstaller.app.plist"
            echo "✓ Removed preferences"
        fi
        
        # Remove any application support files
        if [[ -d "$HOME/Library/Application Support/CursorUninstaller" ]]; then
            rm -rf "$HOME/Library/Application Support/CursorUninstaller"
            echo "✓ Removed application support files"
        fi
        
        # Remove any logs
        if [[ -d "$HOME/Library/Logs/CursorUninstaller" ]]; then
            rm -rf "$HOME/Library/Logs/CursorUninstaller"
            echo "✓ Removed log files"
        fi
        
        echo "Cursor Uninstaller has been completely removed from your system."
        ;;
    *)
        echo "Removal cancelled."
        ;;
esac

echo
echo "Press any key to close this window..."
read -n 1
EOF
    
    chmod +x "$PACKAGE_DIR/Uninstall CursorUninstaller.command"
    
    log_success "Installer documentation created"
}

# Create DMG file with advanced options
create_dmg() {
    log_step "CREATING DMG FILE"
    
    local dmg_path="$OUTPUT_DIR/${DMG_NAME}-${VERSION}.dmg"
    local temp_dmg="$BUILD_DIR/temp.dmg"
    
    # Remove existing DMG if it exists
    if [[ -f "$dmg_path" ]]; then
        log_info "Removing existing DMG file..."
        rm -f "$dmg_path"
    fi
    
    # Calculate size needed (add 100MB buffer)
    local size_needed
    size_needed=$(du -sm "$PACKAGE_DIR" | cut -f1)
    size_needed=$((size_needed + 100))
    
    log_info "Creating DMG with ${size_needed}MB capacity..."
    
    # Create temporary DMG
    if ! hdiutil create -size "${size_needed}m" -fs HFS+ -volname "$DMG_NAME" "$temp_dmg"; then
        log_error "Failed to create temporary DMG"
        exit 1
    fi
    
    # Mount the DMG with better error handling
    log_info "Mounting temporary DMG..."
    local mount_output
    mount_output=$(hdiutil attach "$temp_dmg" -nobrowse -mountpoint "$BUILD_DIR/dmg_mount" 2>&1) || {
        log_error "Failed to mount temporary DMG"
        log_error "Mount output: $mount_output"
        exit 1
    }
    
    local mount_point="$BUILD_DIR/dmg_mount"
    
    if [[ ! -d "$mount_point" ]]; then
        log_error "Mount point directory not found: $mount_point"
        exit 1
    fi
    
    log_info "Mounted DMG at: $mount_point"
    
    # Copy files to DMG
    log_info "Copying files to DMG..."
    if ! cp -R "$PACKAGE_DIR/"* "$mount_point/"; then
        log_error "Failed to copy files to DMG"
        hdiutil detach "$mount_point" 2>/dev/null || true
        exit 1
    fi
    
    # Create symbolic link to Applications folder for easy installation
    if ! ln -s /Applications "$mount_point/Applications"; then
        log_warning "Could not create Applications symlink"
    fi
    
    # Set DMG background and layout using AppleScript
    if command -v osascript >/dev/null 2>&1; then
        log_info "Setting DMG layout and appearance..."
        
        # Wait a moment for the Finder to recognize the new mount
        sleep 2
        
        osascript << APPLESCRIPT 2>/dev/null || log_warning "Could not set DMG appearance"
tell application "Finder"
    try
        tell disk "$DMG_NAME"
            open
            set current view of container window to icon view
            set toolbar visible of container window to false
            set statusbar visible of container window to false
            set the bounds of container window to {100, 100, 600, 400}
            
            set viewOptions to the icon view options of container window
            set arrangement of viewOptions to not arranged
            set icon size of viewOptions to 72
            
            -- Position items
            set position of item "CursorUninstaller.app" of container window to {150, 200}
            set position of item "Applications" of container window to {350, 200}
            set position of item "README.txt" of container window to {250, 300}
            
            close
            open
            update without registering applications
            delay 2
        end tell
    end try
end tell
APPLESCRIPT
    fi
    
    # Sync filesystem
    sync
    sleep 2
    
    # Unmount the DMG
    log_info "Unmounting DMG..."
    if ! hdiutil detach "$mount_point"; then
        log_error "Failed to unmount DMG"
        exit 1
    fi
    
    # Convert to compressed, read-only DMG
    log_info "Converting to compressed DMG format..."
    if ! hdiutil convert "$temp_dmg" -format UDZO -o "$dmg_path"; then
        log_error "Failed to convert DMG to compressed format"
        exit 1
    fi
    
    # Clean up temporary files
    rm -f "$temp_dmg"
    
    # Make DMG internet-enabled (optional)
    hdiutil internet-enable -yes "$dmg_path" 2>/dev/null || true
    
    log_success "DMG created: $dmg_path"
    
    # Display file info
    local dmg_size
    dmg_size=$(du -h "$dmg_path" | cut -f1)
    log_info "DMG size: $dmg_size"
    log_info "DMG location: $dmg_path"
    
    return 0
}

# Code signing (optional but recommended)
sign_application() {
    log_step "CODE SIGNING (OPTIONAL)"
    
    # Check if developer certificate is available
    local cert_name=""
    cert_name=$(security find-identity -v -p codesigning | grep "Developer ID Application" | head -1 | sed 's/.*"\(.*\)".*/\1/' 2>/dev/null || echo "")
    
    if [[ -n "$cert_name" ]]; then
        log_info "Developer certificate found: $cert_name"
        log_info "Signing application..."
        
        # Sign the app bundle with hardened runtime
        if codesign --force --deep --timestamp \
                   --options runtime \
                   --sign "$cert_name" \
                   "$PACKAGE_DIR/CursorUninstaller.app" 2>/dev/null; then
            
            # Verify signature
            if codesign --verify --deep --strict "$PACKAGE_DIR/CursorUninstaller.app" 2>/dev/null; then
                log_success "Application signed and verified successfully"
            else
                log_warning "Signature verification failed"
            fi
        else
            log_warning "Code signing failed - continuing without signature"
        fi
    else
        log_info "No developer certificate found - skipping code signing"
        log_info "The app will still work but may show security warnings on first launch"
        log_info "Users can bypass this by right-clicking and selecting 'Open'"
    fi
}

# Verify package integrity
verify_package() {
    log_step "VERIFYING PACKAGE INTEGRITY"
    
    local app_path="$PACKAGE_DIR/CursorUninstaller.app"
    local verification_errors=0
    
    # Check app bundle structure
    if [[ ! -d "$app_path" ]]; then
        log_error "App bundle not found"
        ((verification_errors++))
    fi
    
    if [[ ! -f "$app_path/Contents/Info.plist" ]]; then
        log_error "Info.plist not found"
        ((verification_errors++))
    fi
    
    if [[ ! -x "$app_path/Contents/MacOS/CursorUninstaller" ]]; then
        log_error "Executable not found or not executable"
        ((verification_errors++))
    fi
    
    if [[ ! -f "$app_path/Contents/Resource./bin/uninstall_cursor.sh" ]]; then
        log_error "Main script not found in resources"
        ((verification_errors++))
    fi
    
    # Validate Info.plist
    if ! plutil -lint "$app_path/Contents/Info.plist" >/dev/null 2>&1; then
        log_error "Invalid Info.plist format"
        ((verification_errors++))
    fi
    
    # Check required modules
    local required_modules=("lib" "modules")
    for module in "${required_modules[@]}"; do
        if [[ ! -d "$app_path/Contents/Resources/$module" ]]; then
            log_warning "Module directory not found: $module"
        fi
    done
    
    # Test script execution
    log_info "Testing script execution..."
    if cd "$app_path/Contents/Resources" && bash bin/uninstall_cursor.sh --help >/dev/null 2>&1; then
        log_success "Script execution test passed"
    else
        log_warning "Script execution test failed - check dependencies"
    fi
    
    if [[ $verification_errors -eq 0 ]]; then
        log_success "Package integrity verified successfully"
        return 0
    else
        log_error "Package verification failed with $verification_errors errors"
        return 1
    fi
}

# Run package tests
run_package_tests() {
    log_step "RUNNING PACKAGE TESTS"
    
    local app_resources="$PACKAGE_DIR/CursorUninstaller.app/Contents/Resources"
    
    # Test 1: Check if all required files are present
    log_info "Test 1: Checking required files..."
    local required_files=(
        "bin/uninstall_cursor.sh"
        "lib/config.sh"
        "lib/helpers.sh"
        "lib/ui.sh"
        "modules/uninstall.sh"
        "modules/installation.sh"
        "modules/optimization.sh"
    )
    
    local missing_files=()
    for file in "${required_files[@]}"; do
        if [[ ! -f "$app_resources/$file" ]]; then
            missing_files+=("$file")
        fi
    done
    
    if [[ ${#missing_files[@]} -eq 0 ]]; then
        log_success "✓ All required files present"
    else
        log_error "✗ Missing files: ${missing_files[*]}"
        return 1
    fi
    
    # Test 2: Check script permissions
    log_info "Test 2: Checking script permissions..."
    if [[ -x "$app_resources/bin/uninstall_cursor.sh" ]]; then
        log_success "✓ Main script is executable"
    else
        log_error "✗ Main script is not executable"
        return 1
    fi
    
    # Test 3: Test script syntax
    log_info "Test 3: Testing script syntax..."
    if bash -n "$app_resources/bin/uninstall_cursor.sh"; then
        log_success "✓ Script syntax is valid"
    else
        log_error "✗ Script syntax errors detected"
        return 1
    fi
    
    # Test 4: Test help function
    log_info "Test 4: Testing help function..."
    if cd "$app_resources" && timeout 10s bash bin/uninstall_cursor.sh --help >/dev/null 2>&1; then
        log_success "✓ Help function works correctly"
    else
        log_warning "⚠ Help function test timeout or failed"
    fi
    
    log_success "Package tests completed successfully"
    return 0
}

# Main execution
main() {
    echo -e "${BOLD}${BLUE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                 CURSOR UNINSTALLER DMG CREATOR               ║"
    echo "║                     Professional Packaging                   ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    log_info "Starting DMG package creation process..."
    log_info "Project root: $PROJECT_ROOT"
    log_info "Build directory: $BUILD_DIR"
    log_info "Output directory: $OUTPUT_DIR"
    log_info "Package version: $VERSION"
    
    # Execute build steps
    validate_prerequisites
    create_package_structure
    copy_application_files
    create_launcher_script
    create_info_plist
    create_app_icon
    create_installer_docs
    sign_application
    verify_package
    run_package_tests
    create_dmg
    
    echo
    log_success "🎉 DMG PACKAGE CREATION COMPLETED SUCCESSFULLY!"
    echo
    echo -e "${BOLD}${GREEN}PACKAGE DETAILS:${NC}"
    echo -e "  📦 Package: ${BOLD}${DMG_NAME}-${VERSION}.dmg${NC}"
    echo -e "  📍 Location: ${BOLD}$OUTPUT_DIR/${NC}"
    echo -e "  🎯 Bundle ID: ${BOLD}$BUNDLE_ID${NC}"
    echo -e "  📋 Version: ${BOLD}$VERSION${NC}"
    echo
    echo -e "${BOLD}${CYAN}TESTING INSTRUCTIONS:${NC}"
    echo -e "  1. Navigate to: ${BOLD}$OUTPUT_DIR${NC}"
    echo -e "  2. Double-click ${BOLD}${DMG_NAME}-${VERSION}.dmg${NC} to mount"
    echo -e "  3. Drag ${BOLD}CursorUninstaller.app${NC} to Applications folder"
    echo -e "  4. Double-click the app in Applications to launch"
    echo -e "  5. Test all menu options and functionality"
    echo
    echo -e "${BOLD}${YELLOW}DISTRIBUTION READY:${NC}"
    echo -e "  • DMG file is ready for distribution"
    echo -e "  • Contains complete uninstaller with all modules"
    echo -e "  • Includes documentation and uninstaller removal tool"
    echo -e "  • Optimized for both GUI and command-line usage"
    echo
}

# Handle command line arguments
case "${1:-}" in
    --help|-h)
        echo "Cursor Uninstaller DMG Package Creator"
        echo "Usage: $0 [OPTIONS]"
        echo
        echo "OPTIONS:"
        echo "  --output DIR      Set output directory (default: /Users/vicd/Downloads)"
        echo "  --keep-build      Keep build directory after completion"
        echo "  --help, -h        Show this help message"
        echo
        echo "ENVIRONMENT VARIABLES:"
        echo "  OUTPUT_DIR        Output directory for DMG file"
        echo "  KEEP_BUILD_DIR    Set to 'true' to keep build directory"
        echo
        exit 0
        ;;
    --output)
        if [[ -n "$2" ]]; then
            OUTPUT_DIR="$2"
            shift 2
        else
            log_error "Output directory not specified"
            exit 1
        fi
        ;;
    --keep-build)
        KEEP_BUILD_DIR="true"
        shift
        ;;
esac

# Execute main function
main "$@" 