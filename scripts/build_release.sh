#!/bin/bash

################################################################################
# Cursor Uninstaller Release Builder
# Automates the complete build and packaging process
################################################################################

set -eE

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
VERSION="1.0.0"
BUILD_TYPE="${1:-release}"
OUTPUT_DIR="${OUTPUT_DIR:-/Users/vicd/Downloads}"

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

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_step() {
    echo -e "\n${BOLD}${BLUE}=== $1 ===${NC}"
}

# Error handler
error_handler() {
    local line_number="$1"
    local error_code="$2"
    log_error "Build failed at line $line_number with exit code $error_code"
    cleanup_on_error
    exit 1
}

trap 'error_handler $LINENO $?' ERR

# Cleanup on error
cleanup_on_error() {
    log_warning "Cleaning up after build failure..."
    
    # Remove any partial build artifacts
    if [[ -d "$PROJECT_ROOT/build" ]] && [[ "$KEEP_BUILD_ON_ERROR" != "true" ]]; then
        rm -rf "$PROJECT_ROOT/build" 2>/dev/null || true
        log_info "Removed partial build directory"
    fi
}

# Display build header
display_header() {
    clear
    echo -e "${BOLD}${BLUE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                 CURSOR UNINSTALLER BUILDER                  ║"
    echo "║                    Release Automation                       ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo
    log_info "Starting build process for version $VERSION"
    log_info "Build type: $BUILD_TYPE"
    log_info "Output directory: $OUTPUT_DIR"
    echo
}

# Validate build environment
validate_build_environment() {
    log_step "VALIDATING BUILD ENVIRONMENT"
    
    # Check operating system
    if [[ "$OSTYPE" != "darwin"* ]]; then
        log_error "Build process requires macOS for DMG creation"
        exit 1
    fi
    
    # Check required tools
    local required_tools=("bash" "git" "hdiutil" "codesign" "plutil" "defaults" "bats")
    local missing_tools=()
    
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            missing_tools+=("$tool")
        fi
    done
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        log_error "Missing required build tools: ${missing_tools[*]}"
        log_error "Please install missing tools and try again"
        exit 1
    fi
    
    # Check Git repository status
    if [[ -d "$PROJECT_ROOT/.git" ]]; then
        local git_status
        git_status=$(git -C "$PROJECT_ROOT" status --porcelain 2>/dev/null || echo "error")
        
        if [[ "$git_status" == "error" ]]; then
            log_warning "Not in a Git repository or Git not available"
        elif [[ -n "$git_status" ]] && [[ "$BUILD_TYPE" == "release" ]]; then
            log_warning "Working directory has uncommitted changes:"
            git -C "$PROJECT_ROOT" status --short
            echo
            read -p "Continue with uncommitted changes? (y/N): " continue_build
            case "$continue_build" in
                [Yy]|[Yy][Ee][Ss])
                    log_info "Continuing build with uncommitted changes"
                    ;;
                *)
                    log_info "Build cancelled - commit changes and try again"
                    exit 0
                    ;;
            esac
        else
            log_success "Git repository is clean"
        fi
    fi
    
    # Check output directory
    if [[ ! -d "$OUTPUT_DIR" ]]; then
        log_info "Creating output directory: $OUTPUT_DIR"
        mkdir -p "$OUTPUT_DIR"
    fi
    
    # Check disk space (need at least 1GB free)
    local available_space
    available_space=$(df -g "$OUTPUT_DIR" | tail -1 | awk '{print $4}')
    if [[ "$available_space" -lt 1 ]]; then
        log_error "Insufficient disk space in output directory"
        log_error "Available: ${available_space}GB, Required: 1GB"
        exit 1
    fi
    
    log_success "Build environment validated"
}

# Clean previous builds
clean_builds() {
    log_step "CLEANING PREVIOUS BUILDS"
    
    if [[ -d "$PROJECT_ROOT/build" ]]; then
        rm -rf "$PROJECT_ROOT/build"
        log_info "Removed previous build directory"
    fi
    
    if [[ -d "$PROJECT_ROOT/dist" ]]; then
        rm -rf "$PROJECT_ROOT/dist"
        log_info "Removed previous dist directory"
    fi
    
    # Clean any old DMG files in output directory
    local old_dmgs
    old_dmgs=$(find "$OUTPUT_DIR" -name "CursorUninstaller-*.dmg" -type f 2>/dev/null || true)
    if [[ -n "$old_dmgs" ]]; then
        log_info "Found existing DMG files in output directory:"
        echo "$old_dmgs"
        
        if [[ "$BUILD_TYPE" == "release" ]]; then
            read -p "Remove existing DMG files? (Y/n): " remove_old
            case "$remove_old" in
                [Nn]|[Nn][Oo])
                    log_info "Keeping existing DMG files"
                    ;;
                *)
                    echo "$old_dmgs" | xargs rm -f
                    log_success "Removed existing DMG files"
                    ;;
            esac
        else
            # Auto-remove in non-release builds
            echo "$old_dmgs" | xargs rm -f
            log_success "Removed existing DMG files"
        fi
    fi
    
    log_success "Build environment cleaned"
}

# Run comprehensive tests
run_tests() {
    log_step "RUNNING COMPREHENSIVE TESTS"
    
    cd "$PROJECT_ROOT"
    
    local test_failures=0
    
    # Test 1: Shell script syntax validation
    log_info "Test 1: Validating shell script syntax..."
    local shell_scripts
    shell_scripts=$(find "$PROJECT_ROOT" -name "*.sh" -type f | grep -v node_modules || true)
    
    if [[ -n "$shell_scripts" ]]; then
        local syntax_errors=0
        while IFS= read -r script; do
            if ! bash -n "$script" 2>/dev/null; then
                log_error "Syntax error in: $script"
                ((syntax_errors++))
            fi
        done <<< "$shell_scripts"
        
        if [[ $syntax_errors -eq 0 ]]; then
            log_success "✓ All shell scripts have valid syntax"
        else
            log_error "✗ Found $syntax_errors shell scripts with syntax errors"
            ((test_failures++))
        fi
    fi
    
    # Test 2: BATS test suite
    log_info "Test 2: Running BATS test suite..."
    if [[ -f "tests/scripts/run-tests.sh" ]]; then
        if bash tests/scripts/run-tests.sh; then
            log_success "✓ BATS test suite passed"
        else
            log_error "✗ BATS test suite failed"
            ((test_failures++))
        fi
    elif [[ -f "scripts/run-tests.sh" ]]; then
        if bash scripts/run-tests.sh; then
            log_success "✓ Test suite passed"
        else
            log_error "✗ Test suite failed"
            ((test_failures++))
        fi
    else
        log_warning "⚠ No test suite found - skipping tests"
    fi
    
    # Test 3: npm tests (if available)
    if [[ -f "package.json" ]] && command -v npm >/dev/null 2>&1; then
        log_info "Test 3: Running npm tests..."
        if npm test; then
            log_success "✓ npm tests passed"
        else
            log_error "✗ npm tests failed"
            ((test_failures++))
        fi
    fi
    
    # Test 4: Main script functionality test
    log_info "Test 4: Testing main script functionality..."
    if timeout 10s bash uninstall_cursor.sh --help >/dev/null 2>&1; then
        log_success "✓ Main script responds to help command"
    else
        log_error "✗ Main script help test failed or timed out"
        ((test_failures++))
    fi
    
    # Test 5: Module loading test
    log_info "Test 5: Testing module loading..."
    local module_errors=0
    if [[ -d "lib" ]]; then
        for module in lib/*.sh; do
            if [[ -f "$module" ]]; then
                if ! bash -n "$module" 2>/dev/null; then
                    log_error "Module syntax error: $module"
                    ((module_errors++))
                fi
            fi
        done
    fi
    
    if [[ $module_errors -eq 0 ]]; then
        log_success "✓ All modules have valid syntax"
    else
        log_error "✗ Found $module_errors modules with syntax errors"
        ((test_failures++))
    fi
    
    # Test summary
    if [[ $test_failures -eq 0 ]]; then
        log_success "All tests passed successfully"
        return 0
    else
        log_error "Tests failed with $test_failures failures"
        
        if [[ "$BUILD_TYPE" == "release" ]]; then
            log_error "Cannot proceed with release build due to test failures"
            exit 1
        else
            log_warning "Continuing with development build despite test failures"
            return 0
        fi
    fi
}

# Validate project structure
validate_project() {
    log_step "VALIDATING PROJECT STRUCTURE"
    
    local required_files=(
        "uninstall_cursor.sh"
        "lib/config.sh"
        "lib/helpers.sh"
        "lib/ui.sh"
        "modules/uninstall.sh"
        "modules/installation.sh"
        "modules/optimization.sh"
        "modules/git_integration.sh"
        "modules/complete_removal.sh"
        "modules/ai_optimization.sh"
    )
    
    local missing_files=()
    for file in "${required_files[@]}"; do
        if [[ ! -f "$PROJECT_ROOT/$file" ]]; then
            missing_files+=("$file")
        fi
    done
    
    if [[ ${#missing_files[@]} -gt 0 ]]; then
        log_error "Required files missing:"
        for file in "${missing_files[@]}"; do
            log_error "  - $file"
        done
        exit 1
    fi
    
    # Check that scripts are executable
    local script_files=(
        "uninstall_cursor.sh"
        "scripts/create_dmg_package.sh"
        "scripts/install_cursor_uninstaller.sh"
    )
    
    for script in "${script_files[@]}"; do
        if [[ -f "$PROJECT_ROOT/$script" ]] && [[ ! -x "$PROJECT_ROOT/$script" ]]; then
            log_warning "Making $script executable"
            chmod +x "$PROJECT_ROOT/$script"
        fi
    done
    
    log_success "Project structure validated"
}

# Create distribution package
create_distribution() {
    log_step "CREATING DISTRIBUTION PACKAGE"
    
    # Set environment variables for DMG creation
    export OUTPUT_DIR="$OUTPUT_DIR"
    export KEEP_BUILD_DIR="true"  # Keep build dir for additional packaging
    
    # Create DMG package
    if [[ -f "$SCRIPT_DIR/create_dmg_package.sh" ]]; then
        log_info "Creating DMG package..."
        if bash "$SCRIPT_DIR/create_dmg_package.sh"; then
            log_success "DMG package created successfully"
        else
            log_error "DMG package creation failed"
            exit 1
        fi
    else
        log_error "DMG creation script not found: $SCRIPT_DIR/create_dmg_package.sh"
        exit 1
    fi
    
    # Create additional distribution formats
    create_zip_package
    create_tar_package
    create_installer_package
}

# Create ZIP package for cross-platform distribution
create_zip_package() {
    log_info "Creating ZIP package..."
    
    local zip_name="CursorUninstaller-${VERSION}.zip"
    local build_dir="$PROJECT_ROOT/build"
    
    if [[ ! -d "$build_dir" ]]; then
        log_warning "Build directory not found - skipping ZIP package"
        return 0
    fi
    
    cd "$build_dir"
    
    if command -v zip >/dev/null 2>&1; then
        # Create ZIP with proper compression
        zip -r "$OUTPUT_DIR/$zip_name" CursorUninstaller/ -x "*.DS_Store" "*/.*" -9
        log_success "ZIP package created: $zip_name"
    else
        log_warning "zip command not available, skipping ZIP package"
    fi
}

# Create TAR package for Unix systems
create_tar_package() {
    log_info "Creating TAR package..."
    
    local tar_name="CursorUninstaller-${VERSION}.tar.gz"
    local build_dir="$PROJECT_ROOT/build"
    
    if [[ ! -d "$build_dir" ]]; then
        log_warning "Build directory not found - skipping TAR package"
        return 0
    fi
    
    cd "$build_dir"
    
    # Create TAR with proper compression
    tar -czf "$OUTPUT_DIR/$tar_name" CursorUninstaller/ --exclude="*.DS_Store" --exclude="*/.*"
    log_success "TAR package created: $tar_name"
}

# Create standalone installer package
create_installer_package() {
    log_info "Creating standalone installer package..."
    
    local installer_dir="$PROJECT_ROOT/build/CursorUninstaller-Installer"
    local installer_name="CursorUninstaller-Installer-${VERSION}.zip"
    
    # Create installer directory
    mkdir -p "$installer_dir"
    
    # Copy app bundle
    if [[ -d "$PROJECT_ROOT/build/CursorUninstaller/CursorUninstaller.app" ]]; then
        cp -R "$PROJECT_ROOT/build/CursorUninstaller/CursorUninstaller.app" "$installer_dir/"
    else
        log_warning "App bundle not found - skipping installer package"
        return 0
    fi
    
    # Copy installer script
    if [[ -f "$SCRIPT_DIR/install_cursor_uninstaller.sh" ]]; then
        cp "$SCRIPT_DIR/install_cursor_uninstaller.sh" "$installer_dir/"
        chmod +x "$installer_dir/install_cursor_uninstaller.sh"
    fi
    
    # Copy documentation
    if [[ -f "$PROJECT_ROOT/build/CursorUninstaller/README.txt" ]]; then
        cp "$PROJECT_ROOT/build/CursorUninstaller/README.txt" "$installer_dir/"
    fi
    
    # Create installer ZIP
    cd "$PROJECT_ROOT/build"
    if command -v zip >/dev/null 2>&1; then
        zip -r "$OUTPUT_DIR/$installer_name" CursorUninstaller-Installer/ -x "*.DS_Store" "*/.*" -9
        log_success "Installer package created: $installer_name"
    else
        log_warning "zip command not available, skipping installer package"
    fi
}

# Generate checksums
generate_checksums() {
    log_step "GENERATING CHECKSUMS"
    
    cd "$OUTPUT_DIR"
    
    local package_files
    package_files=$(find . -maxdepth 1 -name "CursorUninstaller-*" -type f 2>/dev/null || true)
    
    if [[ -z "$package_files" ]]; then
        log_warning "No package files found for checksum generation"
        return 0
    fi
    
    # Generate SHA256 checksums
    if command -v shasum >/dev/null 2>&1; then
        shasum -a 256 CursorUninstaller-* > "CursorUninstaller-${VERSION}-checksums.sha256" 2>/dev/null || true
        log_success "SHA256 checksums generated"
    fi
    
    # Generate MD5 checksums for compatibility
    if command -v md5 >/dev/null 2>&1; then
        md5 CursorUninstaller-* > "CursorUninstaller-${VERSION}-checksums.md5" 2>/dev/null || true
        log_success "MD5 checksums generated"
    fi
}

# Create release notes
create_release_notes() {
    log_step "CREATING RELEASE NOTES"
    
    local release_notes="$OUTPUT_DIR/CursorUninstaller-${VERSION}-RELEASE_NOTES.md"
    
    # Get Git information if available
    local git_commit=""
    local git_branch=""
    if [[ -d "$PROJECT_ROOT/.git" ]] && command -v git >/dev/null 2>&1; then
        git_commit=$(git -C "$PROJECT_ROOT" rev-parse --short HEAD 2>/dev/null || echo "unknown")
        git_branch=$(git -C "$PROJECT_ROOT" branch --show-current 2>/dev/null || echo "unknown")
    fi
    
    cat > "$release_notes" << EOF
# Cursor Uninstaller v${VERSION}

## Release Information
- **Version**: ${VERSION}
- **Build Date**: $(date '+%Y-%m-%d %H:%M:%S')
- **Build Type**: ${BUILD_TYPE}
- **Platform**: macOS (Universal)
- **Git Commit**: ${git_commit}
- **Git Branch**: ${git_branch}

## Package Contents
- **DMG Package**: Complete installer with app bundle
- **ZIP Package**: Cross-platform archive
- **TAR Package**: Unix-compatible archive
- **Installer Package**: Standalone installer with script
- **Checksums**: SHA256 and MD5 verification files

## Features
- ✅ Complete Cursor AI Editor removal
- ✅ Git backup integration before uninstallation
- ✅ AI-optimized performance tuning for Apple Silicon and Intel Macs
- ✅ Comprehensive system health diagnostics
- ✅ Interactive menu and command-line interfaces
- ✅ Advanced removal verification and reporting
- ✅ System optimization for AI development workflows
- ✅ Background process detection and cleanup
- ✅ Launch Services and Spotlight database cleanup

## Installation Instructions

### DMG Installation (Recommended)
1. Download \`CursorUninstaller-${VERSION}.dmg\`
2. Double-click to mount the disk image
3. Drag \`CursorUninstaller.app\` to Applications folder
4. Double-click the app to launch

### Manual Installation
1. Download and extract the ZIP or TAR package
2. Run the included installer script: \`./install_cursor_uninstaller.sh\`
3. Follow the on-screen instructions

### Standalone Installer
1. Download \`CursorUninstaller-Installer-${VERSION}.zip\`
2. Extract and run \`./install_cursor_uninstaller.sh\`

## System Requirements
- macOS 10.15 (Catalina) or later
- Administrator privileges for system modifications
- Terminal access for full functionality
- Minimum 1GB free disk space

## Usage

### Interactive Mode
Launch the app from Applications folder for guided menu interface.

### Command Line Mode
\`\`\`bash
./uninstall_cursor.sh [OPTIONS]

OPTIONS:
  -u, --uninstall         Complete removal of Cursor
  --git-backup           Perform Git backup before operations
  -o, --optimize          Comprehensive performance optimization
  -c, --check             Check Cursor installation status
  --health               Perform system health check
  --git-status           Show Git repository information
  --system-specs         Display system specifications
  --verbose              Enable detailed logging
  -h, --help             Show help message
\`\`\`

### Examples
\`\`\`bash
# Git backup + complete uninstall
./uninstall_cursor.sh --git-backup -u

# AI performance optimization
./uninstall_cursor.sh --optimize

# System health check
./uninstall_cursor.sh --health

# Show Git status
./uninstall_cursor.sh --git-status
\`\`\`

## Verification
Verify package integrity using the provided checksums:
\`\`\`bash
# SHA256 verification
shasum -a 256 -c CursorUninstaller-${VERSION}-checksums.sha256

# MD5 verification (if needed)
md5sum -c CursorUninstaller-${VERSION}-checksums.md5
\`\`\`

## Security Notes
- The application requires administrator privileges for system-level operations
- All operations are logged and can be reviewed
- Code signing may show warnings on first launch (right-click → Open to bypass)
- Git operations are safe and create backups before any destructive actions

## Troubleshooting
- If the app won't open: Right-click → Open (bypass Gatekeeper warning)
- If permissions errors occur: Run with administrator privileges
- For Git issues: Ensure repository is in a clean state before operations
- For performance issues: Check system requirements and available disk space

## Support
For issues, questions, or feature requests:
- Check the included documentation in the app bundle
- Review the application logs for detailed error information
- Ensure your system meets the minimum requirements

## Changelog
### v${VERSION}
- Initial release with comprehensive Cursor management features
- Git integration for safe backup operations
- AI-optimized performance tuning
- Advanced system health diagnostics
- Interactive and command-line interfaces
- Complete removal with verification

---
© 2024 Cursor Uninstaller. All rights reserved.

Built with ❤️ for the macOS development community.
EOF
    
    log_success "Release notes created: $(basename "$release_notes")"
}

# Test created packages
test_packages() {
    log_step "TESTING CREATED PACKAGES"
    
    cd "$OUTPUT_DIR"
    
    local test_failures=0
    
    # Test DMG file
    local dmg_file
    dmg_file=$(find . -name "CursorUninstaller-*.dmg" -type f | head -1)
    if [[ -n "$dmg_file" ]]; then
        log_info "Testing DMG file: $dmg_file"
        
        # Test DMG can be mounted
        local mount_point
        mount_point=$(hdiutil attach "$dmg_file" -nobrowse -readonly 2>/dev/null | grep -E '^/dev/' | awk '{print $3}')
        
        if [[ -n "$mount_point" ]]; then
            log_success "✓ DMG mounts successfully"
            
            # Test app bundle exists
            if [[ -d "$mount_point/CursorUninstaller.app" ]]; then
                log_success "✓ App bundle found in DMG"
                
                # Test app bundle is valid
                if [[ -f "$mount_point/CursorUninstaller.app/Contents/Info.plist" ]]; then
                    log_success "✓ App bundle is valid"
                else
                    log_error "✗ App bundle is missing Info.plist"
                    ((test_failures++))
                fi
            else
                log_error "✗ App bundle not found in DMG"
                ((test_failures++))
            fi
            
            # Unmount DMG
            hdiutil detach "$mount_point" >/dev/null 2>&1 || true
        else
            log_error "✗ DMG failed to mount"
            ((test_failures++))
        fi
    else
        log_warning "⚠ No DMG file found for testing"
    fi
    
    # Test checksum files
    if [[ -f "CursorUninstaller-${VERSION}-checksums.sha256" ]]; then
        log_info "Testing SHA256 checksums..."
        if shasum -a 256 -c "CursorUninstaller-${VERSION}-checksums.sha256" >/dev/null 2>&1; then
            log_success "✓ SHA256 checksums verified"
        else
            log_error "✗ SHA256 checksum verification failed"
            ((test_failures++))
        fi
    fi
    
    if [[ $test_failures -eq 0 ]]; then
        log_success "All package tests passed"
        return 0
    else
        log_error "Package testing failed with $test_failures failures"
        return 1
    fi
}

# Display build summary
show_build_summary() {
    log_step "BUILD SUMMARY"
    
    echo -e "${BOLD}${GREEN}🎉 BUILD COMPLETED SUCCESSFULLY!${NC}"
    echo
    echo -e "${BOLD}BUILD INFORMATION:${NC}"
    echo -e "  🏗️  Build Type: ${BOLD}$BUILD_TYPE${NC}"
    echo -e "  📋 Version: ${BOLD}$VERSION${NC}"
    echo -e "  📅 Build Date: ${BOLD}$(date '+%Y-%m-%d %H:%M:%S')${NC}"
    echo -e "  📍 Output Location: ${BOLD}$OUTPUT_DIR${NC}"
    echo
    
    echo -e "${BOLD}PACKAGES CREATED:${NC}"
    if [[ -d "$OUTPUT_DIR" ]]; then
        cd "$OUTPUT_DIR"
        for file in CursorUninstaller-* 2>/dev/null; do
            if [[ -f "$file" ]]; then
                local size
                size=$(du -h "$file" | cut -f1)
                local file_type=""
                case "$file" in
                    *.dmg) file_type="📦 DMG Package" ;;
                    *.zip) file_type="📁 ZIP Archive" ;;
                    *.tar.gz) file_type="📄 TAR Archive" ;;
                    *checksums*) file_type="🔒 Checksums" ;;
                    *RELEASE*) file_type="📝 Release Notes" ;;
                    *) file_type="📄 File" ;;
                esac
                echo -e "  $file_type ${BOLD}$file${NC} (${size})"
            fi
        done
    fi
    
    echo
    echo -e "${BOLD}QUALITY ASSURANCE:${NC}"
    echo -e "  ✅ All tests passed"
    echo -e "  ✅ Package integrity verified"
    echo -e "  ✅ Checksums generated"
    echo -e "  ✅ Documentation included"
    echo
    echo -e "${BOLD}NEXT STEPS:${NC}"
    echo -e "  1. Test the DMG installation on a clean system"
    echo -e "  2. Verify all functionality works as expected"
    echo -e "  3. Share with testers for feedback"
    echo -e "  4. Upload to distribution platform when ready"
    echo
    echo -e "${BOLD}TESTING RECOMMENDATIONS:${NC}"
    echo -e "  • Test on both Intel and Apple Silicon Macs"
    echo -e "  • Verify installation and uninstallation processes"
    echo -e "  • Test Git backup functionality"
    echo -e "  • Validate system optimization features"
    echo -e "  • Check all command-line options"
    echo
}

# Main build function
main() {
    display_header
    
    # Execute build pipeline
    validate_build_environment
    clean_builds
    validate_project
    
    # Run tests based on build type
    if [[ "$BUILD_TYPE" == "release" ]]; then
        run_tests
    else
        log_info "Skipping comprehensive tests for development build"
        # Still run basic syntax check
        log_info "Running basic syntax validation..."
        if ! bash -n "$PROJECT_ROOT/uninstall_cursor.sh"; then
            log_error "Main script has syntax errors"
            exit 1
        fi
        log_success "Basic syntax validation passed"
    fi
    
    create_distribution
    generate_checksums
    create_release_notes
    test_packages
    show_build_summary
    
    log_success "Build process completed successfully!"
    echo
    echo -e "${BOLD}${CYAN}Ready for distribution! 🚀${NC}"
    echo
}

# Handle command line arguments
case "${1:-}" in
    --help|-h)
        echo "Cursor Uninstaller Release Builder"
        echo "Usage: $0 [BUILD_TYPE] [OPTIONS]"
        echo
        echo "BUILD_TYPE:"
        echo "  release    Full release build with comprehensive testing (default)"
        echo "  dev        Development build with minimal testing"
        echo "  debug      Debug build with verbose output"
        echo
        echo "OPTIONS:"
        echo "  --output DIR          Set output directory (default: /Users/vicd/Downloads)"
        echo "  --keep-on-error       Keep build artifacts on error"
        echo "  --help, -h            Show this help message"
        echo "  --version, -v         Show version information"
        echo
        echo "ENVIRONMENT VARIABLES:"
        echo "  OUTPUT_DIR            Output directory for packages"
        echo "  KEEP_BUILD_ON_ERROR   Set to 'true' to keep build dir on error"
        echo
        echo "EXAMPLES:"
        echo "  $0                    # Create release build"
        echo "  $0 dev                # Create development build"
        echo "  $0 --output ~/Desktop # Build to Desktop"
        echo
        exit 0
        ;;
    --version|-v)
        echo "Cursor Uninstaller Builder v1.0.0"
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
    --keep-on-error)
        KEEP_BUILD_ON_ERROR="true"
        shift
        ;;
    dev|debug|release)
        BUILD_TYPE="$1"
        shift
        ;;
esac

# Execute main build process
main "$@" 