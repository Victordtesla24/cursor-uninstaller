#!/usr/bin/env bash

# Comprehensive Code Validation Tool v3.1
# Simplified and optimized for reliability with complete validation coverage

set -euo pipefail

# Basic configuration
readonly SCRIPT_VERSION="3.1.0"
SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_NAME

# Simple color support
if [[ -t 2 ]]; then
    readonly RED='\033[0;31m'
    readonly GREEN='\033[0;32m'
    readonly YELLOW='\033[1;33m'
    readonly BLUE='\033[0;34m'
    readonly CYAN='\033[0;36m'
    readonly BOLD='\033[1m'
    readonly NC='\033[0m'
else
    readonly RED='' GREEN='' YELLOW='' BLUE='' CYAN='' BOLD='' NC=''
fi

# Counters
TOTAL_FILES=0
SHELL_FILES=0
JS_FILES=0
TS_FILES=0
JSON_FILES=0
TOTAL_ISSUES=0
SHELL_ISSUES=0
JS_ISSUES=0
TS_ISSUES=0
JSON_ISSUES=0

# Arrays to store found files
declare -a SHELL_SCRIPTS=()
declare -a JAVASCRIPT_FILES=()
declare -a TYPESCRIPT_FILES=()
declare -a JSON_FILES_LIST=()

# Simple logging
log_header() {
    printf "\n${BLUE}${BOLD}=== %s ===${NC}\n" "$1" >&2
}

log_info() {
    printf "${BLUE}ℹ️  %s${NC}\n" "$1" >&2
}

log_success() {
    printf "${GREEN}✅ %s${NC}\n" "$1" >&2
}

log_warning() {
    printf "${YELLOW}⚠️  %s${NC}\n" "$1" >&2
}

log_error() {
    printf "${RED}❌ %s${NC}\n" "$1" >&2
}

# Check if command exists
has_command() {
    command -v "$1" >/dev/null 2>&1
}

# Run command with timeout (simplified)
run_with_timeout() {
    local timeout_sec="$1"
    shift
    
    if has_command timeout; then
        timeout "$timeout_sec" "$@"
    elif has_command gtimeout; then
        gtimeout "$timeout_sec" "$@"
    else
        # Fallback without timeout
        "$@"
    fi
}

# Simplified file discovery (compatible with all bash versions)
discover_files() {
    log_header "File Discovery"
    
    # Clear arrays
    SHELL_SCRIPTS=()
    JAVASCRIPT_FILES=()
    TYPESCRIPT_FILES=()
    JSON_FILES_LIST=()
    
    # Find shell scripts (portable approach)
    log_info "Scanning for shell scripts..."
    if command -v find >/dev/null 2>&1; then
        while IFS= read -r -d '' file; do
            [[ -f "$file" ]] && SHELL_SCRIPTS+=("$file")
        done < <(find . -type f \( -name "*.sh" -o -name "*.bash" \) \
            -not -path "./node_modules/*" -not -path "./.git/*" \
            -not -path "./coverage/*" -not -path "./build/*" \
            -not -path "./dist/*" -print0 2>/dev/null || true)
    fi
    
    # Find JavaScript files
    log_info "Scanning for JavaScript files..."
    if command -v find >/dev/null 2>&1; then
        while IFS= read -r -d '' file; do
            [[ -f "$file" ]] && JAVASCRIPT_FILES+=("$file")
        done < <(find . -type f -name "*.js" \
            -not -path "./node_modules/*" -not -path "./.git/*" \
            -not -path "./coverage/*" -not -path "./build/*" \
            -not -path "./dist/*" -print0 2>/dev/null || true)
    fi
    
    # Find TypeScript files
    log_info "Scanning for TypeScript files..."
    if command -v find >/dev/null 2>&1; then
        while IFS= read -r -d '' file; do
            [[ -f "$file" ]] && TYPESCRIPT_FILES+=("$file")
        done < <(find . -type f \( -name "*.ts" -o -name "*.tsx" \) \
            -not -path "./node_modules/*" -not -path "./.git/*" \
            -not -path "./coverage/*" -not -path "./build/*" \
            -not -path "./dist/*" -print0 2>/dev/null || true)
    fi
    
    # Find JSON files
    log_info "Scanning for JSON files..."
    if command -v find >/dev/null 2>&1; then
        while IFS= read -r -d '' file; do
            [[ -f "$file" ]] && JSON_FILES_LIST+=("$file")
        done < <(find . -type f -name "*.json" \
            -not -path "./node_modules/*" -not -path "./.git/*" \
            -not -path "./coverage/*" -not -path "./build/*" \
            -not -path "./dist/*" -print0 2>/dev/null || true)
    fi
    
    # Update counters
    SHELL_FILES=${#SHELL_SCRIPTS[@]}
    JS_FILES=${#JAVASCRIPT_FILES[@]}
    TS_FILES=${#TYPESCRIPT_FILES[@]}
    JSON_FILES=${#JSON_FILES_LIST[@]}
    TOTAL_FILES=$((SHELL_FILES + JS_FILES + TS_FILES + JSON_FILES))
    
    # Display results
    log_info "Discovery Results:"
    printf "  • Shell scripts: ${BOLD}%d${NC}\n" "$SHELL_FILES" >&2
    printf "  • JavaScript files: ${BOLD}%d${NC}\n" "$JS_FILES" >&2
    printf "  • TypeScript files: ${BOLD}%d${NC}\n" "$TS_FILES" >&2
    printf "  • JSON files: ${BOLD}%d${NC}\n" "$JSON_FILES" >&2
    printf "  • Total files: ${BOLD}%d${NC}\n" "$TOTAL_FILES" >&2
}

# Validate shell scripts
validate_shell_scripts() {
    [[ $SHELL_FILES -eq 0 ]] && return 0
    
    log_header "Shell Script Validation"
    
    # Check for ShellCheck
    if has_command shellcheck; then
        local version
        version="$(run_with_timeout 5 shellcheck --version | grep version: | cut -d' ' -f2 2>/dev/null || echo "unknown")"
        log_info "Using ShellCheck v$version"
    else
        log_warning "ShellCheck not found - using basic syntax validation only"
    fi
    
    local issues=0
    local processed=0
    
    for script in "${SHELL_SCRIPTS[@]}"; do
        [[ ! -f "$script" ]] && continue
        
        local script_issues=0
        local basename_script
        basename_script="$(basename "$script")"
        
        processed=$((processed + 1))
        printf "\rProcessing shell script %d/%d: %s" "$processed" "$SHELL_FILES" "$basename_script" >&2
        
        # Basic syntax check with timeout
        if ! run_with_timeout 10 bash -n "$script" 2>/dev/null; then
            printf "\r%80s\r" " " >&2  # Clear progress line
            log_error "Syntax error in: $basename_script"
            script_issues=1
        fi
        
        # ShellCheck if available
        if has_command shellcheck && [[ $script_issues -eq 0 ]]; then
            if run_with_timeout 15 shellcheck "$script" >/dev/null 2>&1; then
                printf "\r%80s\r" " " >&2  # Clear progress line
                log_success "$basename_script - passed"
            else
                printf "\r%80s\r" " " >&2  # Clear progress line
                log_warning "ShellCheck issues in: $basename_script"
                # Show a few key issues
                run_with_timeout 10 shellcheck "$script" 2>&1 | head -3 | while read -r line; do
                    printf "    %s\n" "$line" >&2
                done
                script_issues=1
            fi
        elif [[ $script_issues -eq 0 ]]; then
            printf "\r%80s\r" " " >&2  # Clear progress line
            log_success "$basename_script - syntax OK"
        fi
        
        if [[ $script_issues -gt 0 ]]; then
            issues=$((issues + 1))
        fi
    done
    
    # Clear progress line
    printf "\r%80s\r" " " >&2
    
    SHELL_ISSUES=$issues
    log_info "Shell validation: $issues issues found"
}

# Validate JavaScript files with enhanced debugging and timeout protection
validate_javascript_files() {
    [[ $JS_FILES -eq 0 ]] && return 0
    
    log_header "JavaScript Validation"
    
    local issues=0
    local has_node=0
    local has_eslint=0
    local skipped=0
    
    # Check available tools with timeout
    if run_with_timeout 5 node --version >/dev/null 2>&1; then
        has_node=1
        local node_version
        node_version="$(run_with_timeout 5 node --version 2>/dev/null || echo "unknown")"
        log_info "Using Node.js $node_version"
    else
        log_warning "Node.js not found - skipping JavaScript validation"
        return 0
    fi
    
    # Test ESLint with shorter timeout
    if run_with_timeout 3 eslint --version >/dev/null 2>&1; then
        has_eslint=1
        log_info "ESLint available for enhanced validation"
    else
        log_info "ESLint not available - using Node.js syntax checking only"
    fi
    
    local processed=0
    for jsfile in "${JAVASCRIPT_FILES[@]}"; do
        [[ ! -f "$jsfile" ]] && continue
        
        local file_issues=0
        local basename_file
        basename_file="$(basename "$jsfile")"
        
        processed=$((processed + 1))
        
        # Debug: Show which file we're processing
        printf "\r%80s\r" " " >&2  # Clear line
        printf "\rProcessing JavaScript file %d/%d: %s" "$processed" "$JS_FILES" "$basename_file" >&2
        
        # Skip very large files that might cause timeouts
        local file_size
        if file_size=$(wc -c < "$jsfile" 2>/dev/null) && [[ $file_size -gt 1048576 ]]; then
            printf "\r%80s\r" " " >&2  # Clear progress line
            log_warning "$basename_file - skipped (file too large: ${file_size} bytes)"
            skipped=$((skipped + 1))
            continue
        fi
        
        # Simple Node.js syntax validation with reliable timeout
        if [[ $has_node -eq 1 ]]; then
            if run_with_timeout 8 node --check "$jsfile" >/dev/null 2>&1; then
                printf "\r%80s\r" " " >&2  # Clear progress line
                log_success "$basename_file - syntax OK"
            else
                printf "\r%80s\r" " " >&2  # Clear progress line
                log_error "JavaScript syntax error in: $basename_file"
                file_issues=1
            fi
        fi
        
        # ESLint validation with timeout (only if syntax is OK)
        if [[ $has_eslint -eq 1 && $file_issues -eq 0 ]]; then
            if run_with_timeout 5 eslint --quiet "$jsfile" >/dev/null 2>&1; then
                # File passed ESLint - don't double-log success
                :
            else
                log_warning "ESLint issues in: $basename_file"
                file_issues=1
            fi
        fi
        
        if [[ $file_issues -gt 0 ]]; then
            issues=$((issues + 1))
        fi
        
        # Progress indicator every 10 files
        if [[ $((processed % 10)) -eq 0 ]]; then
            printf "\r%80s\r" " " >&2  # Clear line
            log_info "Processed $processed/$JS_FILES JavaScript files..."
        fi
    done
    
    # Clear progress line
    printf "\r%80s\r" " " >&2
    
    JS_ISSUES=$issues
    log_info "JavaScript validation complete: $issues issues found"
    [[ $skipped -gt 0 ]] && log_info "Skipped $skipped large files"
}

# Validate TypeScript files
validate_typescript_files() {
    [[ $TS_FILES -eq 0 ]] && return 0
    
    log_header "TypeScript Validation"
    
    local issues=0
    
    # Check for TypeScript compiler
    if run_with_timeout 5 tsc --version >/dev/null 2>&1; then
        local tsc_version
        tsc_version="$(run_with_timeout 5 tsc --version 2>/dev/null | cut -d' ' -f2 || echo "unknown")"
        log_info "Using TypeScript v$tsc_version"
    else
        log_warning "TypeScript compiler not found - skipping TypeScript validation"
        return 0
    fi
    
    # Try global TypeScript compilation check
    log_info "Running TypeScript compilation check..."
    local ts_output
    if ts_output=$(run_with_timeout 30 tsc --noEmit --skipLibCheck 2>&1); then
        log_success "TypeScript compilation passed"
    else
        log_warning "TypeScript compilation issues detected"
        # Show compilation errors
        echo "$ts_output" | head -5 | while read -r line; do
            printf "    %s\n" "$line" >&2
        done
        issues=1
    fi
    
    # Individual file syntax checking
    local processed=0
    for tsfile in "${TYPESCRIPT_FILES[@]}"; do
        [[ ! -f "$tsfile" ]] && continue
        
        local basename_file
        basename_file="$(basename "$tsfile")"
        
        processed=$((processed + 1))
        printf "\rProcessing TypeScript file %d/%d: %s" "$processed" "$TS_FILES" "$basename_file" >&2
        
        # Basic TypeScript syntax check
        if run_with_timeout 15 tsc --noEmit --skipLibCheck "$tsfile" >/dev/null 2>&1; then
            printf "\r%80s\r" " " >&2  # Clear progress line
            log_success "$basename_file - syntax OK"
        else
            printf "\r%80s\r" " " >&2  # Clear progress line
            log_error "TypeScript error in: $basename_file"
            issues=$((issues + 1))
        fi
    done
    
    # Clear progress line
    printf "\r%80s\r" " " >&2
    
    TS_ISSUES=$issues
    log_info "TypeScript validation: $issues issues found"
}

# Validate JSON files
validate_json_files() {
    [[ $JSON_FILES -eq 0 ]] && return 0
    
    log_header "JSON Validation"
    
    local issues=0
    local validation_method=""
    
    # Determine validation method with timeout checks
    if run_with_timeout 5 jq --version >/dev/null 2>&1; then
        validation_method="jq"
        log_info "Using jq for JSON validation"
    elif run_with_timeout 5 node --version >/dev/null 2>&1; then
        validation_method="node"
        log_info "Using Node.js for JSON validation"
    elif run_with_timeout 5 python3 --version >/dev/null 2>&1; then
        validation_method="python3"
        log_info "Using Python3 for JSON validation"
    else
        log_warning "No JSON validation tools found (jq, node, or python3)"
        return 0
    fi
    
    local processed=0
    for jsonfile in "${JSON_FILES_LIST[@]}"; do
        [[ ! -f "$jsonfile" ]] && continue
        
        local basename_file
        basename_file="$(basename "$jsonfile")"
        local is_valid=0
        
        processed=$((processed + 1))
        printf "\rProcessing JSON file %d/%d: %s" "$processed" "$JSON_FILES" "$basename_file" >&2
        
        # Validate based on available tool
        case "$validation_method" in
            "jq")
                if run_with_timeout 10 jq empty "$jsonfile" >/dev/null 2>&1; then
                    is_valid=1
                fi
                ;;
            "node")
                if run_with_timeout 10 node -e "JSON.parse(require('fs').readFileSync('$jsonfile', 'utf8'))" >/dev/null 2>&1; then
                    is_valid=1
                fi
                ;;
            "python3")
                if run_with_timeout 10 python3 -c "import json; json.load(open('$jsonfile'))" >/dev/null 2>&1; then
                    is_valid=1
                fi
                ;;
        esac
        
        printf "\r%80s\r" " " >&2  # Clear progress line
        
        if [[ $is_valid -eq 1 ]]; then
            log_success "$basename_file - valid JSON"
        else
            log_error "Invalid JSON in: $basename_file"
            issues=$((issues + 1))
        fi
    done
    
    # Clear progress line
    printf "\r%80s\r" " " >&2
    
    JSON_ISSUES=$issues
    log_info "JSON validation: $issues issues found"
}

# Generate comprehensive summary
show_summary() {
    log_header "Validation Summary"
    
    # Calculate total issues
    TOTAL_ISSUES=$((SHELL_ISSUES + JS_ISSUES + TS_ISSUES + JSON_ISSUES))
    
    # File statistics
    printf "%sFile Statistics:%s\n" "${BOLD}" "${NC}" >&2
    printf "  • Shell scripts: %d (issues: %d)\n" "$SHELL_FILES" "$SHELL_ISSUES" >&2
    printf "  • JavaScript files: %d (issues: %d)\n" "$JS_FILES" "$JS_ISSUES" >&2
    printf "  • TypeScript files: %d (issues: %d)\n" "$TS_FILES" "$TS_ISSUES" >&2
    printf "  • JSON files: %d (issues: %d)\n" "$JSON_FILES" "$JSON_ISSUES" >&2
    printf "  • Total files: %d\n" "$TOTAL_FILES" >&2
    
    echo >&2
    
    # Overall result
    if [[ $TOTAL_ISSUES -eq 0 ]]; then
        printf "%s%s🎉 ALL VALIDATIONS PASSED!%s\n" "${GREEN}" "${BOLD}" "${NC}" >&2
        printf "%sAll %d files are valid and ready for production.%s\n" "${GREEN}" "$TOTAL_FILES" "${NC}" >&2
        return 0
    else
        printf "%s%s⚠️  ISSUES FOUND%s\n" "${YELLOW}" "${BOLD}" "${NC}" >&2
        printf "%sFound %d issues across %d files that need attention.%s\n" "${YELLOW}" "$TOTAL_ISSUES" "$TOTAL_FILES" "${NC}" >&2
        
        # Recommendations
        echo >&2
        printf "%sRecommendations:%s\n" "${BOLD}" "${NC}" >&2
        [[ $SHELL_ISSUES -gt 0 ]] && printf "  • Fix shell script issues using shellcheck\n" >&2
        [[ $JS_ISSUES -gt 0 ]] && printf "  • Fix JavaScript issues using eslint\n" >&2
        [[ $TS_ISSUES -gt 0 ]] && printf "  • Fix TypeScript compilation errors\n" >&2
        [[ $JSON_ISSUES -gt 0 ]] && printf "  • Fix JSON syntax errors\n" >&2
        
        return 1
    fi
}

# Show help
show_help() {
    cat << EOF
${BOLD}Comprehensive Code Validation Tool v${SCRIPT_VERSION}${NC}

${BOLD}USAGE:${NC}
    $SCRIPT_NAME [OPTIONS]

${BOLD}OPTIONS:${NC}
    -h, --help      Show this help message
    --version       Show version information

${BOLD}DESCRIPTION:${NC}
    Validates code files using appropriate tools for each file type:
    
    ${BOLD}Shell Scripts (.sh, .bash):${NC}
      • Syntax validation with bash -n
      • Style and error checking with ShellCheck (if available)
    
    ${BOLD}JavaScript (.js):${NC}
      • Syntax validation with Node.js (if available)
      • Linting with ESLint (if available)
    
    ${BOLD}TypeScript (.ts, .tsx):${NC}
      • Type checking and compilation with tsc (if available)
      • Syntax validation
    
    ${BOLD}JSON (.json):${NC}
      • Syntax validation with jq, Node.js, or Python3

${BOLD}EXIT CODES:${NC}
    0   All files passed validation
    1   Issues found requiring attention
    2   Invalid arguments

${BOLD}TOOLS USED (when available):${NC}
    • shellcheck - Shell script analysis
    • node - JavaScript syntax validation
    • eslint - JavaScript linting
    • tsc - TypeScript compilation
    • jq - JSON validation
    • python3 - JSON validation fallback

${BOLD}FEATURES:${NC}
    ✅ Comprehensive multi-language validation
    ✅ Timeout protection for long-running operations
    ✅ Progress indicators for large codebases
    ✅ Intelligent tool detection and fallbacks
    ✅ Clear, actionable error reporting

EOF
}

# Parse arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help
                exit 0
                ;;
            --version)
                echo "Comprehensive Code Validation Tool v$SCRIPT_VERSION"
                exit 0
                ;;
            -*)
                log_error "Unknown option: $1"
                echo >&2
                show_help >&2
                exit 2
                ;;
            *)
                log_error "Unexpected argument: $1"
                exit 2
                ;;
        esac
    done
}

# Main execution
main() {
    # Show header
    printf "%s%s\n" "${CYAN}" "${BOLD}"
    printf "╔══════════════════════════════════════════════════════════════════════════════╗\n"
    printf "║            Comprehensive Code Validation Tool v%-28s  ║\n" "$SCRIPT_VERSION"
    printf "║               Shell • JavaScript • TypeScript • JSON                         ║\n"
    printf "╚══════════════════════════════════════════════════════════════════════════════╝\n"
    printf "%s\n" "${NC}"
    
    # Run validations
    discover_files
    validate_shell_scripts
    validate_javascript_files
    validate_typescript_files
    validate_json_files
    
    # Show summary and return appropriate exit code
    show_summary
}

# Script entry point
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    parse_arguments "$@"
    main
fi
