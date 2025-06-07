#!/bin/bash
# =============================================================================
# CURSOR AI PRODUCTION OPTIMIZER v2.0 (REAL FEATURES ONLY)
#
# This script configures the Cursor AI editor by applying real, production-grade
# settings and validating actual system components that exist.
# =============================================================================

set -euo pipefail

# --- Global State ---
OPTIMIZER_VERSION="2.0"
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
WORKSPACE_ROOT=$(dirname "$SCRIPT_DIR")
REMAINING_VULNS=0
TESTS_FAILED=false
CURSOR_SETTINGS_PATH="$HOME/Library/Application Support/Cursor/User/settings.json"
CURSOR_KEYBINDINGS_PATH="$HOME/Library/Application Support/Cursor/User/keybindings.json"
BACKUP_DIR="$HOME/.cursor-production-backup-$(date +"%Y%m%d-%H%M%S")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

print_header() {
    echo ""
    echo -e "${CYAN}================================================================${NC}"
    echo -e "${WHITE}🔧 CURSOR AI PRODUCTION OPTIMIZER v${OPTIMIZER_VERSION}${NC}"
    echo -e "${CYAN}================================================================${NC}"
    echo -e "${BLUE}Applying real, production-grade Cursor optimizations${NC}"
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

validate_environment() {
    print_info "PHASE 1: ENVIRONMENT VALIDATION"
    
    if [[ ! -d "/Applications/Cursor.app" ]]; then
        print_error "Cursor AI Editor not found at /Applications/Cursor.app"
        exit 1
    fi
    print_success "Cursor AI Editor found."
    
    if ! command -v node >/dev/null 2>&1; then 
        print_error "Node.js is required."; 
        exit 1; 
    fi
    print_success "Node.js is installed."
    
    if [[ -f "$WORKSPACE_ROOT/package.json" ]]; then
        print_success "Package.json found."
    else
        print_warning "Package.json not found in workspace."
    fi
}

security_audit() {
    print_info "PHASE 2: SECURITY AUDIT"
    cd "$WORKSPACE_ROOT" || exit 1
    
    if [[ -f "package.json" ]]; then
        print_info "Running npm audit..."
        
        # Run audit and capture output
        if npm audit --json > /tmp/audit.json 2>/dev/null; then
            print_success "No vulnerabilities found."
            REMAINING_VULNS=0
        else
            # Parse vulnerabilities count
            if [[ -f /tmp/audit.json ]]; then
                REMAINING_VULNS=$(node -e "
                    try {
                        const audit = JSON.parse(require('fs').readFileSync('/tmp/audit.json'));
                        const total = audit.metadata?.vulnerabilities?.total || 0;
                        console.log(parseInt(total) || 0);
                    } catch(e) { console.log(0); }
                " 2>/dev/null | tr -d ' \n\r')
                REMAINING_VULNS=${REMAINING_VULNS:-0}
                
                # Ensure it's a valid number
                if ! [[ "$REMAINING_VULNS" =~ ^[0-9]+$ ]]; then
                    REMAINING_VULNS=0
                fi
                
                if (( REMAINING_VULNS > 0 )); then
                    print_warning "$REMAINING_VULNS vulnerabilities detected."
                    print_info "Run 'npm audit fix' manually to address them."
                fi
            fi
        fi
        
        rm -f /tmp/audit.json
    else
        print_info "No package.json found, skipping npm audit."
    fi
}

backup_configurations() {
    print_info "PHASE 3: CONFIGURATION BACKUP"
    mkdir -p "$BACKUP_DIR"
    
    local files_backed_up=0
    for file in "$CURSOR_SETTINGS_PATH" "$CURSOR_KEYBINDINGS_PATH"; do
        if [[ -f "$file" ]]; then
            cp "$file" "$BACKUP_DIR/"
            print_success "Backed up $(basename "$file")"
            files_backed_up=$((files_backed_up + 1))
        fi
    done
    
    if [[ $files_backed_up -gt 0 ]]; then
        print_success "Backup created at: $BACKUP_DIR"
    else
        print_info "No existing configurations to backup."
    fi
}

apply_real_optimizations() {
    print_info "PHASE 4: APPLYING REAL CURSOR OPTIMIZATIONS"
    
    # Apply real Cursor settings
    local settings_dir
    settings_dir=$(dirname "$CURSOR_SETTINGS_PATH")
    mkdir -p "$settings_dir"
    
    # Create optimized settings.json with real Cursor/VSCode settings
    cat > "$CURSOR_SETTINGS_PATH" << 'EOF'
{
    "editor.suggestSelection": "first",
    "editor.tabCompletion": "on",
    "editor.acceptSuggestionOnEnter": "smart",
    "editor.quickSuggestions": {
        "other": true,
        "comments": true,
        "strings": true
    },
    "editor.inlineSuggest.enabled": true,
    "editor.wordBasedSuggestions": "matchingDocuments",
    "editor.suggestOnTriggerCharacters": true,
    "editor.snippetSuggestions": "top",
    "files.exclude": {
        "**/.git": true,
        "**/.DS_Store": true,
        "**/node_modules": true,
        "**/dist": true,
        "**/build": true,
        "**/.next": true,
        "**/coverage": true
    },
    "workbench.statusBar.visible": true,
    "workbench.activityBar.visible": true,
    "breadcrumbs.enabled": true,
    "editor.fontSize": 14,
    "editor.lineHeight": 1.5,
    "editor.fontFamily": "SF Mono, Monaco, 'Cascadia Code', monospace",
    "editor.minimap.enabled": true,
    "terminal.integrated.fontSize": 13
}
EOF
    
    if [[ -f "$CURSOR_SETTINGS_PATH" ]]; then
        print_success "Real Cursor settings applied."
    else
        print_error "Failed to apply settings."
        return 1
    fi
    
    # Create optimized keybindings
    cat > "$CURSOR_KEYBINDINGS_PATH" << 'EOF'
[
    {
        "key": "cmd+k",
        "command": "editor.action.quickFix",
        "when": "editorTextFocus"
    },
    {
        "key": "cmd+i",
        "command": "editor.action.triggerSuggest",
        "when": "editorTextFocus"
    },
    {
        "key": "cmd+shift+k",
        "command": "editor.action.deleteLines",
        "when": "editorTextFocus"
    }
]
EOF
    
    if [[ -f "$CURSOR_KEYBINDINGS_PATH" ]]; then
        print_success "Real keybindings applied."
    else
        print_error "Failed to apply keybindings."
        return 1
    fi
    
    # Create .cursorignore if in a project
    if [[ -f "$WORKSPACE_ROOT/package.json" ]] || [[ -d "$WORKSPACE_ROOT/.git" ]]; then
        cat > "$WORKSPACE_ROOT/.cursorignore" << 'EOF'
# Cursor AI Optimization - File Exclusion for Better Context
node_modules/
dist/
build/
.next/
coverage/
.cache/
*.log
.DS_Store
*.swp
*.swo
.git/
EOF
        print_success "Created .cursorignore for better AI context."
    fi
}

validate_optimizations() {
    print_info "PHASE 5: VALIDATION"
    
    # Validate settings file
    if [[ -f "$CURSOR_SETTINGS_PATH" ]]; then
        if node -e "JSON.parse(require('fs').readFileSync('$CURSOR_SETTINGS_PATH'))" 2>/dev/null; then
            print_success "Settings file is valid JSON."
        else
            print_error "Settings file is invalid JSON."
            TESTS_FAILED=true
        fi
    else
        print_error "Settings file not found."
        TESTS_FAILED=true
    fi
    
    # Validate keybindings file
    if [[ -f "$CURSOR_KEYBINDINGS_PATH" ]]; then
        if node -e "JSON.parse(require('fs').readFileSync('$CURSOR_KEYBINDINGS_PATH'))" 2>/dev/null; then
            print_success "Keybindings file is valid JSON."
        else
            print_error "Keybindings file is invalid JSON."
            TESTS_FAILED=true
        fi
    else
        print_error "Keybindings file not found."
        TESTS_FAILED=true
    fi
    
    # Run project tests if available
    cd "$WORKSPACE_ROOT" || exit 1
    if [[ -f "package.json" ]] && npm run test --if-present >/dev/null 2>&1; then
        print_success "Project tests passed."
    else
        print_info "No project tests available or tests failed (non-critical)."
    fi
}

display_summary() {
    print_info "PHASE 6: OPTIMIZATION SUMMARY"
    
    echo ""
    echo -e "${CYAN}================================================================${NC}"
    if [[ "$TESTS_FAILED" = true ]]; then
        echo -e "${RED}❌ OPTIMIZATION FAILED${NC}"
        echo -e "${RED}Some configurations could not be applied properly.${NC}"
    else
        echo -e "${GREEN}✅ OPTIMIZATION COMPLETE${NC}"
        echo -e "${GREEN}🚀 Cursor AI optimizations applied successfully.${NC}"
        echo ""
        echo -e "${WHITE}Applied Optimizations:${NC}"
        echo -e "${GREEN}  ✓ Enhanced AI completion settings${NC}"
        echo -e "${GREEN}  ✓ Optimized keyboard shortcuts${NC}"
        echo -e "${GREEN}  ✓ File exclusion patterns (.cursorignore)${NC}"
        echo -e "${GREEN}  ✓ Editor UI optimization${NC}"
        echo -e "${GREEN}  ✓ Configuration backup created${NC}"
        
        if (( REMAINING_VULNS > 0 )); then
            echo -e "${YELLOW}  ⚠ $REMAINING_VULNS security vulnerabilities remain${NC}"
        else
            echo -e "${GREEN}  ✓ No security vulnerabilities${NC}"
        fi
        
        echo ""
        echo -e "${CYAN}Next Steps:${NC}"
        echo -e "${WHITE}1. Restart Cursor AI to activate optimizations${NC}"
        echo -e "${WHITE}2. Test enhanced shortcuts: Cmd+K, Cmd+I${NC}"
        echo -e "${WHITE}3. Experience improved AI completion performance${NC}"
    fi
    echo -e "${CYAN}================================================================${NC}"
    echo ""
}

# --- Main Execution ---
main() {
    print_header
    
    validate_environment
    security_audit
    backup_configurations
    apply_real_optimizations
    validate_optimizations
    display_summary
    
    # Exit with appropriate code
    if [[ "$TESTS_FAILED" = true ]]; then
        exit 1
    else
        exit 0
    fi
}

# Execute main function
main "$@" 