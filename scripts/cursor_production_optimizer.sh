#!/bin/bash
# =============================================================================
# Cursor AI Development Tools Setup Script
# =============================================================================
# 
# This script sets up basic development tools and MCP servers for Cursor AI.
# 
# What this actually does:
# - Validates environment (Cursor, Node.js, etc.)
# - Backs up existing configurations
# - Sets up MCP server configurations
# - Installs basic helper scripts
# 
# IMPORTANT: This does NOT provide:
# - Enhanced AI models or capabilities
# - Unlimited context processing
# - Special "thinking modes"
# - Performance improvements beyond basic caching
# 
# All AI functionality requires proper API keys and configuration.
# =============================================================================

set -euo pipefail

# Get script directory and project root
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
WORKSPACE_ROOT=$(dirname "$SCRIPT_DIR")

# Basic configuration
OPTIMIZER_VERSION="1.0"
CURSOR_MCP_PATH="$HOME/.cursor/mcp.json"
BACKUP_DIR="$HOME/.cursor-backup-$(date +"%Y%m%d-%H%M%S")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper functions
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Main functions
display_header() {
    echo "============================================="
    echo "CURSOR AI BASIC SETUP v${OPTIMIZER_VERSION}"
    echo "Basic configuration utility"
    echo "============================================="
}

validate_environment() {
    print_info "Checking environment..."
    
    # Check Node.js
    if command -v node &> /dev/null; then
        print_info "✓ Node.js: $(node --version)"
    else
        print_error "✗ Node.js not found. Please install Node.js."
        exit 1
    fi
    
    # Check npm
    if command -v npm &> /dev/null; then
        print_info "✓ npm: $(npm --version)"
    else
        print_error "✗ npm not found. Please install npm."
        exit 1
    fi
    
    # Check jq
    if command -v jq &> /dev/null; then
        print_info "✓ jq installed"
    else
        print_error "✗ jq not found. Please install jq."
        exit 1
    fi
}

install_dependencies() {
    print_info "Installing dependencies..."
    cd "$WORKSPACE_ROOT"
    
    if npm install --quiet; then
        print_info "✓ Dependencies installed"
    else
        print_error "Failed to install dependencies"
        exit 1
    fi
}

backup_configuration() {
    print_info "Backing up existing configuration..."
    mkdir -p "$BACKUP_DIR"
    
    if [[ -f "$CURSOR_MCP_PATH" ]]; then
        cp "$CURSOR_MCP_PATH" "$BACKUP_DIR/"
        print_info "✓ Backed up MCP configuration"
    fi
}

configure_mcp() {
    print_info "Configuring MCP servers..."
    
    # Create basic MCP configuration
    cat > "$CURSOR_MCP_PATH" << EOF
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": [
        "@modelcontextprotocol/server-filesystem",
        "$WORKSPACE_ROOT"
      ]
    }
  }
}
EOF
    
    print_info "✓ MCP configuration created"
}

test_setup() {
    print_info "Testing setup..."
    
    # Test MCP servers if test script exists
    if [[ -f "$WORKSPACE_ROOT/scripts/test-mcp-servers.js" ]]; then
        if node "$WORKSPACE_ROOT/scripts/test-mcp-servers.js" &> /dev/null; then
            print_info "✓ MCP server tests passed"
        else
            print_warning "MCP server tests failed or incomplete"
        fi
    fi
    
    # Validate MCP config
    if jq -e '.mcpServers' "$CURSOR_MCP_PATH" &> /dev/null; then
        print_info "✓ MCP configuration is valid"
    else
        print_error "MCP configuration is invalid"
    fi
}

display_summary() {
    echo ""
    echo "============================================="
    echo "SETUP COMPLETE"
    echo "============================================="
    echo ""
    print_info "✓ Environment validated"
    print_info "✓ Dependencies installed"
    print_info "✓ Configuration created"
    echo ""
    print_warning "IMPORTANT:"
    print_warning "• This is a TEMPLATE project"
    print_warning "• NO special AI features included"
    print_warning "• Requires API keys for real functionality"
    echo ""
    print_info "To implement real functionality:"
    print_info "1. Get API keys from AI providers"
    print_info "2. Implement actual API calls"
    print_info "3. Replace placeholder code"
    echo ""
    print_info "Configuration: $CURSOR_MCP_PATH"
    print_info "Backup: $BACKUP_DIR"
}

# Main execution
main() {
    display_header
    echo ""
    
    validate_environment
    echo ""
    
    install_dependencies
    echo ""
    
    backup_configuration
    echo ""
    
    configure_mcp
    echo ""
    
    test_setup
    echo ""
    
    display_summary
}

# Run main function
main "$@" 