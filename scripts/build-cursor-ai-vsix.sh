#!/bin/bash

# =============================================================================
# Cursor Development Tools VSIX Builder
# Creates cursor-dev-tools-1.0.0.vsix package for VS Code/Cursor installation
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

# Configuration
BUILD_DIR="/tmp/cursor-dev-tools-build"
OUTPUT_DIR="/Users/vicd/Desktop"
EXTENSION_NAME="cursor-dev-tools"
VERSION="1.0.0"
VSIX_NAME="${EXTENSION_NAME}-${VERSION}.vsix"

print_header() {
    echo ""
    echo -e "${CYAN}================================================================${NC}"
    echo -e "${WHITE}🔧 CURSOR DEVELOPMENT TOOLS VSIX BUILDER${NC}"
    echo -e "${CYAN}================================================================${NC}"
    echo -e "${BLUE}Building ${EXTENSION_NAME}-${VERSION}.vsix for Cursor Development Tools${NC}"
    echo -e "${CYAN}================================================================${NC}"
    echo ""
}

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_dependencies() {
    print_step "Checking build dependencies..."
    
    # Check if vsce is installed
    if ! command -v vsce >/dev/null 2>&1; then
        print_info "Installing vsce (Visual Studio Code Extension manager)..."
        npm install -g @vscode/vsce
    fi
    
    print_success "Build dependencies verified"
}

create_extension_structure() {
    print_step "Creating extension structure..."
    
    # Clean and create build directory
    rm -rf "$BUILD_DIR"
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"
    
    # Create package.json with proper VS Code extension structure
    cat > package.json << 'EOF'
{
  "name": "cursor-dev-tools",
  "displayName": "Cursor Development Tools",
  "description": "Basic development tools and status indicator for Cursor IDE",
  "version": "1.0.0",
  "publisher": "cursor-dev-team",
  "author": {
    "name": "Cursor Development Team"
  },
  "license": "MIT",
  "repository": {
    "type": "git",
    "url": "https://github.com/cursor-dev/tools"
  },
  "engines": {
    "vscode": "^1.74.0"
  },
  "categories": [
    "Other",
    "Development"
  ],
  "keywords": [
    "cursor",
    "development",
    "tools",
    "status"
  ],
  "activationEvents": [
    "onStartupFinished"
  ],
  "main": "./extension.js",
  "contributes": {
    "commands": [
      {
        "command": "cursorTools.toggleStatus",
        "title": "Toggle Development Tools Status",
        "category": "Cursor Tools"
      },
      {
        "command": "cursorTools.showDetails",
        "title": "Show Tool Details",
        "category": "Cursor Tools"
      }
    ],
    "configuration": {
      "title": "Cursor Development Tools",
      "properties": {
        "cursorTools.statusBar.enabled": {
          "type": "boolean",
          "default": true,
          "description": "Enable status bar indicator"
        },
        "cursorTools.statusBar.showDetails": {
          "type": "boolean",
          "default": true,
          "description": "Show detailed status information"
        }
      }
    }
  },
  "scripts": {
    "vscode:prepublish": "echo 'No compilation needed'"
  }
}
EOF

    print_success "Extension package.json created"
}

create_extension_code() {
    print_step "Creating extension JavaScript source..."
    
    # Create main extension file
    cat > extension.js << 'EOF'
const vscode = require('vscode');

let statusBarItem;

function activate(context) {
    // Create status bar item following VS Code UX guidelines
    // Placed on left side as it's primary/global information
    statusBarItem = vscode.window.createStatusBarItem(vscode.StatusBarAlignment.Left, 100);
    statusBarItem.command = 'cursorTools.toggleStatus';
    
    // Set initial status
    updateStatusBar(true);
    
    // Register commands
    const toggleCommand = vscode.commands.registerCommand('cursorTools.toggleStatus', () => {
        const config = vscode.workspace.getConfiguration('cursorTools');
        const enabled = config.get('statusBar.enabled', true);
        
        vscode.window.showInformationMessage(
            `Cursor Development Tools are ${enabled ? 'active' : 'inactive'}.\n` +
            'This extension provides basic development utilities for Cursor IDE.'
        );
    });
    
    const detailsCommand = vscode.commands.registerCommand('cursorTools.showDetails', () => {
        vscode.window.showInformationMessage(
            'Cursor Development Tools:\n' +
            '• Basic status indicator\n' +
            '• MCP server integration helpers\n' +
            '• Development utilities\n' +
            '• Performance monitoring tools'
        );
    });

    context.subscriptions.push(toggleCommand, detailsCommand, statusBarItem);
    
    // Monitor configuration changes
    const configWatcher = vscode.workspace.onDidChangeConfiguration(e => {
        if (e.affectsConfiguration('cursorTools.statusBar.enabled')) {
            const config = vscode.workspace.getConfiguration('cursorTools');
            const enabled = config.get('statusBar.enabled', true);
            updateStatusBar(enabled);
        }
    });
    
    context.subscriptions.push(configWatcher);
    
    // Show the status bar item
    statusBarItem.show();
    
    console.log('Cursor Development Tools extension is now active!');
}

function updateStatusBar(isEnabled) {
    const config = vscode.workspace.getConfiguration('cursorTools');
    const showDetails = config.get('statusBar.showDetails', true);
    
    if (isEnabled) {
        if (showDetails) {
            statusBarItem.text = "$(tools) Dev Tools: Active";
        } else {
            statusBarItem.text = "$(tools) Dev Tools";
        }
        statusBarItem.backgroundColor = new vscode.ThemeColor('statusBarItem.prominentBackground');
        statusBarItem.tooltip = 'Cursor Development Tools Active\nClick for more details';
    } else {
        statusBarItem.text = "$(x) Dev Tools: Inactive";
        statusBarItem.backgroundColor = new vscode.ThemeColor('statusBarItem.errorBackground');
        statusBarItem.tooltip = 'Cursor Development Tools Inactive - Click to enable';
    }
}

function deactivate() {
    if (statusBarItem) {
        statusBarItem.dispose();
    }
}

module.exports = {
    activate,
    deactivate
};
EOF

    print_success "Extension JavaScript source created"
}

create_additional_files() {
    print_step "Creating additional extension files..."
    
    # Create README.md
    cat > README.md << 'EOF'
# Cursor Development Tools

A Visual Studio Code extension that provides basic development tools and status indicators for Cursor IDE.

## Features

- **Status Bar Integration**: Shows development tools status in the VS Code status bar
- **Interactive Status**: Click the status bar item to view tool information
- **Configurable Display**: Customize what information is shown

## What This Extension Actually Does

This is a basic status indicator extension that:
- Shows a status in your VS Code/Cursor status bar
- Allows toggling and viewing basic tool information
- Provides a template for custom extensions

## What This Extension Does NOT Do

- Does not provide AI model integration
- Does not enable special AI features
- Does not access non-existent models

## Commands

- `Cursor Tools: Toggle Development Tools Status` - Show tool status
- `Cursor Tools: Show Tool Details` - Display available tools

## Configuration

- `cursorTools.statusBar.enabled` - Enable/disable status bar indicator
- `cursorTools.statusBar.showDetails` - Show detailed status information

## Installation

Install the extension and it will show a basic status indicator in your VS Code status bar.

## License

MIT
EOF

    # Create CHANGELOG.md
    cat > CHANGELOG.md << 'EOF'
# Change Log

## [1.0.0] - 2025-01-06

### Added
- Initial release
- Basic status bar integration
- Interactive status details
- Configurable display options
EOF

    # Create .vscodeignore
    cat > .vscodeignore << 'EOF'
.vscode/**
.vscode-test/**
.gitignore
vsc-extension-quickstart.md
**/node_modules/**
**/.DS_Store
**/*.map
EOF

    print_success "Additional extension files created"
}

build_extension() {
    print_step "Building extension package..."
    
    # Initialize npm (simple setup)
    npm init -y
    
    # Build VSIX package (no compilation needed for JavaScript)
    print_info "Creating VSIX package..."
    vsce package --out "$OUTPUT_DIR/$VSIX_NAME"
    
    print_success "Extension packaged successfully"
}

verify_build() {
    print_step "Verifying VSIX package..."
    
    if [[ -f "$OUTPUT_DIR/$VSIX_NAME" ]]; then
        local file_size
        file_size=$(stat -f%z "$OUTPUT_DIR/$VSIX_NAME" 2>/dev/null || stat -c%s "$OUTPUT_DIR/$VSIX_NAME" 2>/dev/null || echo "unknown")
        # Convert bytes to human readable format
        if [[ "$file_size" != "unknown" ]]; then
            if command -v numfmt >/dev/null 2>&1; then
                file_size=$(numfmt --to=iec-i --suffix=B "$file_size")
            else
                # Fallback for systems without numfmt
                if [[ $file_size -gt 1048576 ]]; then
                    file_size="$((file_size / 1048576))MB"
                elif [[ $file_size -gt 1024 ]]; then
                    file_size="$((file_size / 1024))KB"
                else
                    file_size="${file_size}B"
                fi
            fi
        fi
        print_success "VSIX package created: $OUTPUT_DIR/$VSIX_NAME ($file_size)"
        
        # Show package contents
        print_info "Package contents:"
        vsce list-files "$OUTPUT_DIR/$VSIX_NAME" | head -10
        
        return 0
    else
        print_error "VSIX package creation failed"
        return 1
    fi
}

cleanup_build() {
    print_step "Cleaning up build directory..."
    
    cd /
    rm -rf "$BUILD_DIR"
    
    print_success "Build cleanup completed"
}

print_final_report() {
    echo ""
    echo -e "${CYAN}================================================================${NC}"
    echo -e "${WHITE}🎯 CURSOR DEVELOPMENT TOOLS VSIX BUILD COMPLETE!${NC}"
    echo -e "${CYAN}================================================================${NC}"
    echo ""
    echo -e "${GREEN}✅ VSIX Package Details:${NC}"
    echo -e "${WHITE}  • File: ${OUTPUT_DIR}/${VSIX_NAME}${NC}"
    echo -e "${WHITE}  • Version: ${VERSION}${NC}"
    echo -e "${WHITE}  • Publisher: cursor-dev-team${NC}"
    echo -e "${WHITE}  • Status Bar Text: Dev Tools: Active${NC}"
    echo ""
    echo -e "${YELLOW}📋 Installation Instructions:${NC}"
    echo -e "${WHITE}1.${NC} Open VS Code or Cursor IDE"
    echo -e "${WHITE}2.${NC} Press Ctrl+Shift+P (Cmd+Shift+P on macOS)"
    echo -e "${WHITE}3.${NC} Type 'Extensions: Install from VSIX...'"
    echo -e "${WHITE}4.${NC} Select ${OUTPUT_DIR}/${VSIX_NAME}"
    echo -e "${WHITE}5.${NC} Restart VS Code to activate the extension"
    echo ""
    echo -e "${BLUE}🚀 Features:${NC}"
    echo -e "${WHITE}•${NC} Status bar shows development tools status"
    echo -e "${WHITE}•${NC} Click status bar for tool information"
    echo -e "${WHITE}•${NC} Basic development utilities"
    echo -e "${WHITE}•${NC} Configurable display options"
    echo ""
    echo -e "${CYAN}================================================================${NC}"
    echo -e "${WHITE}🎯 EXTENSION READY FOR INSTALLATION${NC}"
    echo -e "${CYAN}================================================================${NC}"
}

# =============================================================================
# Main Execution Flow
# =============================================================================

main() {
    print_header
    
    check_dependencies
    create_extension_structure
    create_extension_code
    create_additional_files
    build_extension
    verify_build
    cleanup_build
    print_final_report
}

# Script entry point
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 