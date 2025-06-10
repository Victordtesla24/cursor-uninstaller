#!/bin/bash
# =============================================================================
# Helper Functions Library for Cursor Development Tools
# =============================================================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# =============================================================================
# Print Functions
# =============================================================================

print_header() {
    echo ""
    echo -e "${CYAN}================================================================${NC}"
    echo -e "${WHITE}$1${NC}"
    echo -e "${CYAN}================================================================${NC}"
    echo ""
}

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

# =============================================================================
# Environment Validation
# =============================================================================

validate_macos() {
    if [[ "$(uname)" != "Darwin" ]]; then
        print_error "This script is designed for macOS. Detected: $(uname)"
        return 1
    fi
    
    local version=$(sw_vers -productVersion)
    print_info "macOS version: $version"
    return 0
}

validate_cursor_installation() {
    local cursor_paths=(
        "/Applications/Cursor.app"
        "$HOME/Applications/Cursor.app"
        "/usr/local/bin/cursor"
        "$HOME/.local/bin/cursor"
    )
    
    for path in "${cursor_paths[@]}"; do
        if [[ -e "$path" ]]; then
            print_success "Cursor found at: $path"
            return 0
        fi
    done
    
    print_error "Cursor not found. Please install Cursor from https://cursor.com"
    return 1
}

validate_nodejs() {
    if ! command -v node &> /dev/null; then
        print_error "Node.js not found. Please install Node.js 18 or later"
        return 1
    fi
    
    local node_version=$(node --version)
    print_info "Node.js version: $node_version"
    
    # Extract major version
    local major_version=$(echo "$node_version" | cut -d. -f1 | sed 's/v//')
    
    if [[ "$major_version" -lt 18 ]]; then
        print_warning "Node.js 18+ recommended. Current: $node_version"
    fi
    
    return 0
}

validate_npm() {
    if ! command -v npm &> /dev/null; then
        print_error "npm not found. Please install npm"
        return 1
    fi
    
    local npm_version=$(npm --version)
    print_info "npm version: $npm_version"
    return 0
}

# =============================================================================
# File System Helpers
# =============================================================================

ensure_directory() {
    local dir="$1"
    
    if [[ ! -d "$dir" ]]; then
        print_info "Creating directory: $dir"
        mkdir -p "$dir"
    fi
}

backup_file() {
    local file="$1"
    local backup_dir="${2:-$HOME/.cursor-backup}"
    
    if [[ -f "$file" ]]; then
        ensure_directory "$backup_dir"
        
        local filename=$(basename "$file")
        local timestamp=$(date +"%Y%m%d-%H%M%S")
        local backup_path="$backup_dir/${filename}.${timestamp}"
        
        cp "$file" "$backup_path"
        print_info "Backed up: $file -> $backup_path"
    fi
}

# =============================================================================
# Process Management
# =============================================================================

is_cursor_running() {
    if pgrep -x "Cursor" > /dev/null; then
        return 0
    else
        return 1
    fi
}

stop_cursor() {
    if is_cursor_running; then
        print_info "Stopping Cursor..."
        pkill -x "Cursor"
        sleep 2
    fi
}

# =============================================================================
# Error Handling
# =============================================================================

handle_error() {
    local error_code=$?
    local error_message="$1"
    
    print_error "$error_message (Exit code: $error_code)"
    exit $error_code
}

# =============================================================================
# Utility Functions
# =============================================================================

confirm_action() {
    local prompt="$1"
    local default="${2:-n}"
    
    local response
    if [[ "$default" == "y" ]]; then
        read -p "$prompt [Y/n]: " response
        response=${response:-y}
    else
        read -p "$prompt [y/N]: " response
        response=${response:-n}
    fi
    
    [[ "$response" =~ ^[Yy]$ ]]
}

get_script_dir() {
    cd "$(dirname "${BASH_SOURCE[0]}")" && pwd
}

get_project_root() {
    local script_dir=$(get_script_dir)
    dirname "$script_dir"
}

# =============================================================================
# Additional Validation Functions (for test compatibility)
# =============================================================================

validate_system() {
    print_info "Running comprehensive system validation"
    
    local validation_result=0
    
    if ! validate_macos; then
        validation_result=1
    fi
    
    if ! validate_nodejs; then
        validation_result=1
    fi
    
    if ! validate_npm; then
        validation_result=1
    fi
    
    if ! validate_cursor_installation; then
        validation_result=1
    fi
    
    return $validation_result
}

terminate_cursor() {
    print_info "Terminating Cursor processes"
    stop_cursor
    
    # Additional termination logic
    if is_cursor_running; then
        print_warning "Force terminating remaining Cursor processes"
        pkill -9 "Cursor" 2>/dev/null || true
        sleep 1
    fi
    
    return 0
}

system_spec() {
    print_info "Gathering system specifications"
    
    local os_version=$(sw_vers -productVersion)
    local hardware=$(system_profiler SPHardwareDataType | grep "Model Name" | cut -d: -f2 | xargs)
    local memory=$(system_profiler SPHardwareDataType | grep "Memory" | cut -d: -f2 | xargs)
    
    echo "System Specifications:"
    echo "- OS: macOS $os_version"
    echo "- Hardware: $hardware"
    echo "- Memory: $memory"
    
    if command -v node &> /dev/null; then
        echo "- Node.js: $(node --version)"
    fi
    
    if command -v npm &> /dev/null; then
        echo "- npm: $(npm --version)"
    fi
    
    return 0
}

# =============================================================================
# Export Functions
# =============================================================================

# Export all functions for use in other scripts
export -f print_header print_step print_success print_error print_warning print_info
export -f validate_macos validate_cursor_installation validate_nodejs validate_npm validate_system
export -f ensure_directory backup_file
export -f is_cursor_running stop_cursor terminate_cursor
export -f handle_error confirm_action get_script_dir get_project_root system_spec
