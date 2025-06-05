#!/bin/bash

# =============================================================================
# Simple Cursor AI Optimization Installation Test Script
# Tests and verifies optimizations applied based on errors.md successful output
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# Configuration paths (based on successful installation from errors.md)
# Using the correct Cursor paths that match the optimization script
CURSOR_USER_CONFIG="$HOME/Library/Application Support/Cursor/User"
CURSOR_SETTINGS_DIR="$CURSOR_USER_CONFIG/settings"
CURSOR_CONFIG_DIR="$HOME/.cursor"

print_header() {
    echo ""
    echo -e "${CYAN}================================================================${NC}"
    echo -e "${WHITE}🔍 CURSOR AI OPTIMIZATION INSTALLATION TEST${NC}"
    echo -e "${CYAN}================================================================${NC}"
    echo -e "${BLUE}Testing optimizations applied based on successful installation${NC}"
    echo -e "${CYAN}================================================================${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# Test function for file existence and basic content validation
test_config_file() {
    local file_path="$1"
    local file_name="$2"
    local expected_content="$3"
    
    if [[ -f "$file_path" ]]; then
        print_success "Configuration found: $file_name"
        
        # Check if file has expected content
        if [[ -n "$expected_content" ]] && grep -q "$expected_content" "$file_path" 2>/dev/null; then
            print_info "✓ Content validation passed for $file_name"
        elif [[ -n "$expected_content" ]]; then
            print_warning "Content validation failed for $file_name (missing: $expected_content)"
        fi
        
        # Show file size for verification
        local file_size
        file_size=$(wc -c < "$file_path" 2>/dev/null || echo "unknown")
        print_info "File size: $file_size bytes"
        return 0
    else
        print_error "Configuration missing: $file_name"
        print_info "Expected location: $file_path"
        return 1
    fi
}

# Test Cursor directories
test_cursor_directories() {
    echo -e "${YELLOW}🔍 TESTING CURSOR DIRECTORIES${NC}"
    echo ""
    
    local dirs_ok=0
    local total_dirs=3
    
    if [[ -d "$CURSOR_USER_CONFIG" ]]; then
        print_success "Cursor user config directory exists"
        dirs_ok=$((dirs_ok + 1))
    else
        print_error "Cursor user config directory missing: $CURSOR_USER_CONFIG"
    fi
    
    if [[ -d "$CURSOR_SETTINGS_DIR" ]]; then
        print_success "Cursor settings directory exists"
        dirs_ok=$((dirs_ok + 1))
    else
        print_error "Cursor settings directory missing: $CURSOR_SETTINGS_DIR"
    fi
    
    if [[ -d "/Applications/Cursor.app" ]]; then
        print_success "Cursor AI Editor application found"
        dirs_ok=$((dirs_ok + 1))
    else
        print_warning "Cursor AI Editor application not found at /Applications/Cursor.app"
    fi
    
    echo ""
    return $((total_dirs - dirs_ok))
}

# Test required configuration files (from successful errors.md output)
test_configuration_files() {
    echo -e "${YELLOW}🔍 TESTING CONFIGURATION FILES${NC}"
    echo ""
    
    local files_ok=0
    local total_files=5
    
    # Test mcp.json (check multiple possible locations)
    local mcp_found=false
    for mcp_path in "$CURSOR_CONFIG_DIR/mcp.json" "$CURSOR_CONFIG_DIR/ultimate-mcp.json" "$CURSOR_SETTINGS_DIR/mcp.json"; do
        if [[ -f "$mcp_path" ]]; then
            if test_config_file "$mcp_path" "mcp.json" "mcp"; then
                mcp_found=true
                break
            fi
        fi
    done
    
    if [[ "$mcp_found" == "true" ]]; then
        files_ok=$((files_ok + 1))
    else
        print_error "Configuration missing: mcp.json"
        print_info "Checked locations: $CURSOR_CONFIG_DIR/mcp.json, $CURSOR_CONFIG_DIR/ultimate-mcp.json, $CURSOR_SETTINGS_DIR/mcp.json"
    fi
    echo ""
    
    # Test yolo-enhanced.json
    if test_config_file "$CURSOR_SETTINGS_DIR/yolo-enhanced.json" "yolo-enhanced.json" "yolo\|revolutionaryMode"; then
        files_ok=$((files_ok + 1))
    fi
    echo ""
    
    # Test context-optimization.json
    if test_config_file "$CURSOR_SETTINGS_DIR/context-optimization.json" "context-optimization.json" "contextOptimization\|unlimited"; then
        files_ok=$((files_ok + 1))
    fi
    echo ""
    
    # Test .cursorignore (check multiple possible locations)
    local cursorignore_found=false
    for cursorignore_path in "$CURSOR_USER_CONFIG/.cursorignore" "$HOME/.cursorignore" ".cursorignore"; do
        if [[ -f "$cursorignore_path" ]]; then
            if test_config_file "$cursorignore_path" ".cursorignore" "node_modules\|\.git"; then
                cursorignore_found=true
                break
            fi
        fi
    done
    
    if [[ "$cursorignore_found" == "true" ]]; then
        files_ok=$((files_ok + 1))
    else
        print_error "Configuration missing: .cursorignore"
        print_info "Checked locations: $CURSOR_USER_CONFIG/.cursorignore, $HOME/.cursorignore, .cursorignore"
    fi
    echo ""
    
    # Test performance-monitor.js (check multiple possible locations)
    local perf_monitor_found=false
    for perf_path in "$CURSOR_USER_CONFIG/performance-monitor.js" "$CURSOR_USER_CONFIG/revolutionary-performance-monitor.js" "$CURSOR_SETTINGS_DIR/performance-monitor.js"; do
        if [[ -f "$perf_path" ]]; then
            if test_config_file "$perf_path" "performance-monitor.js" "performance\|monitor"; then
                perf_monitor_found=true
                break
            fi
        fi
    done
    
    if [[ "$perf_monitor_found" == "true" ]]; then
        files_ok=$((files_ok + 1))
    else
        print_error "Configuration missing: performance-monitor.js"
        print_info "Checked locations: $CURSOR_USER_CONFIG/performance-monitor.js, $CURSOR_USER_CONFIG/revolutionary-performance-monitor.js, $CURSOR_SETTINGS_DIR/performance-monitor.js"
    fi
    echo ""
    
    return $((total_files - files_ok))
}

# Test backup creation (from successful errors.md output)
test_backup_creation() {
    echo -e "${YELLOW}🔍 TESTING BACKUP CREATION${NC}"
    echo ""
    
    # Look for recent backup directories
    local backup_pattern="$HOME/.cursor-optimization-backup-*"
    local backups_found=0
    
    for backup_dir in $backup_pattern; do
        if [[ -d "$backup_dir" ]]; then
            print_success "Backup found: $(basename "$backup_dir")"
            
            # Check backup contents
            if [[ -f "$backup_dir/config_backup.json" ]] || [[ -d "$backup_dir/.cursor" ]]; then
                print_info "✓ Backup contains configuration data"
            fi
            
            # Show backup date/size
            local backup_date
            backup_date=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$backup_dir" 2>/dev/null || echo "unknown")
            print_info "Backup date: $backup_date"
            
            backups_found=$((backups_found + 1))
        fi
    done
    
    if [[ $backups_found -eq 0 ]]; then
        print_error "No backup directories found"
        print_info "Expected pattern: $backup_pattern"
        return 1
    fi
    
    echo ""
    return 0
}

# Test VS Code extension configuration (from errors.md fix)
test_vscode_integration() {
    echo -e "${YELLOW}🔍 TESTING VS CODE INTEGRATION${NC}"
    echo ""
    
    local integration_ok=0
    local total_tests=2
    
    # Test .vscode/extensions.json fix
    if test_config_file ".vscode/extensions.json" "extensions.json" "nyxb.cursorrules"; then
        print_info "✓ Extension recommendations properly formatted"
        integration_ok=$((integration_ok + 1))
    fi
    echo ""
    
    # Test workspace configuration
    if [[ -f ".vscode/settings.json" ]]; then
        print_success "VS Code workspace settings found"
        integration_ok=$((integration_ok + 1))
    else
        print_warning "No VS Code workspace settings found (.vscode/settings.json)"
    fi
    
    echo ""
    return $((total_tests - integration_ok))
}

# Test performance characteristics
test_performance_indicators() {
    echo -e "${YELLOW}🔍 TESTING PERFORMANCE INDICATORS${NC}"
    echo ""
    
    # Check if Node.js is available (required for performance monitoring)
    if command -v node >/dev/null 2>&1; then
        local node_version
        node_version=$(node --version)
        print_success "Node.js available: $node_version"
        
        # Check if npm is available
        if command -v npm >/dev/null 2>&1; then
            local npm_version
            npm_version=$(npm --version)
            print_success "npm available: $npm_version"
        fi
    else
        print_warning "Node.js not found (required for MCP integration)"
    fi
    
    # Check configuration file sizes (larger files suggest more comprehensive config)
    local total_config_size=0
    for config_file in "$CURSOR_SETTINGS_DIR"/*.json; do
        if [[ -f "$config_file" ]]; then
            local size
            size=$(wc -c < "$config_file" 2>/dev/null || echo "0")
            total_config_size=$((total_config_size + size))
        fi
    done
    
    if [[ $total_config_size -gt 1000 ]]; then
        print_success "Configuration files contain substantial optimizations ($total_config_size bytes total)"
    else
        print_warning "Configuration files seem minimal ($total_config_size bytes total)"
    fi
    
    echo ""
}

# Main test function
main() {
    print_header
    
    local total_errors=0
    
    # Run all tests
    test_cursor_directories
    total_errors=$((total_errors + $?))
    
    test_configuration_files  
    total_errors=$((total_errors + $?))
    
    test_backup_creation
    total_errors=$((total_errors + $?))
    
    test_vscode_integration
    total_errors=$((total_errors + $?))
    
    test_performance_indicators
    
    # Print summary
    echo -e "${CYAN}================================================================${NC}"
    echo -e "${WHITE}📊 OPTIMIZATION INSTALLATION TEST SUMMARY${NC}"
    echo -e "${CYAN}================================================================${NC}"
    echo ""
    
    if [[ $total_errors -eq 0 ]]; then
        echo -e "${GREEN}✅ ALL OPTIMIZATION TESTS PASSED${NC}"
        echo -e "${GREEN}🚀 Cursor AI optimizations are properly installed and configured${NC}"
        echo ""
        echo -e "${WHITE}✓ Configuration files: All required files found${NC}"
        echo -e "${WHITE}✓ Backup system: Working properly${NC}"
        echo -e "${WHITE}✓ VS Code integration: Extension recommendations fixed${NC}"
        echo -e "${WHITE}✓ Performance setup: Ready for enhanced AI features${NC}"
        
        echo ""
        echo -e "${CYAN}🎯 NEXT STEPS:${NC}"
        echo -e "${WHITE}1. Restart Cursor AI Editor to activate optimizations${NC}"
        echo -e "${WHITE}2. Try the enhanced shortcuts: Cmd+K, Cmd+I${NC}"
        echo -e "${WHITE}3. Test code completion performance${NC}"
        echo -e "${WHITE}4. Experience improved accuracy and speed${NC}"
        
    elif [[ $total_errors -le 2 ]]; then
        echo -e "${YELLOW}⚠️  OPTIMIZATION TESTS MOSTLY PASSED${NC}"
        echo -e "${YELLOW}🔧 Minor issues detected ($total_errors issues)${NC}"
        echo ""
        echo -e "${WHITE}Most optimizations are working, but some components may need attention.${NC}"
        echo -e "${WHITE}Review the warnings above for specific issues.${NC}"
        
    else
        echo -e "${RED}❌ OPTIMIZATION TESTS FAILED${NC}"
        echo -e "${RED}🔧 Significant issues detected ($total_errors issues)${NC}"
        echo ""
        echo -e "${WHITE}The optimization installation may not have completed successfully.${NC}"
        echo -e "${WHITE}Consider re-running the optimization script or checking the errors above.${NC}"
    fi
    
    echo ""
    echo -e "${CYAN}================================================================${NC}"
    echo -e "${BLUE}Test completed. Check output above for detailed results.${NC}"
    echo -e "${CYAN}================================================================${NC}"
    echo ""
    
    # Return exit code based on results
    if [[ $total_errors -eq 0 ]]; then
        exit 0
    else
        exit 1
    fi
}

# Execute tests
main "$@" 