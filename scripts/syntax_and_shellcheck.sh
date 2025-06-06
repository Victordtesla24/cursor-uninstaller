#!/usr/bin/env bash

# Comprehensive Code Validation Tool v3.3.0
# Enhanced for complete validation coverage with detailed error reporting

# set -e: disabled to ensure script continues after errors, allowing a full report.
# set -E: ensures ERR traps are inherited by shell functions.
# set -u: treats unset variables as an error.
# set -o pipefail: a pipeline's exit code is the last command's with a non-zero exit.
set -Euo pipefail

# Basic configuration
readonly SCRIPT_VERSION="3.3.0"
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

# Arrays to store detailed error information
declare -a SHELL_ERRORS=()
declare -a JS_ERRORS=()
declare -a TS_ERRORS=()
declare -a JSON_ERRORS=()

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

# Run command with timeout but preserve error output
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

# Add error to specific category with full details
add_shell_error() {
    local file="$1"
    local error_msg="$2"
    SHELL_ERRORS+=("$file" "$error_msg")
}

add_js_error() {
    local file="$1"
    local error_msg="$2"
    JS_ERRORS+=("$file" "$error_msg")
}

add_ts_error() {
    local file="$1"
    local error_msg="$2"
    TS_ERRORS+=("$file" "$error_msg")
}

add_json_error() {
    local file="$1"
    local error_msg="$2"
    JSON_ERRORS+=("$file" "$error_msg")
}

# Simplified file discovery with better exclusion patterns
discover_files() {
    log_header "File Discovery"
    
    # Clear arrays
    SHELL_SCRIPTS=()
    JAVASCRIPT_FILES=()
    TYPESCRIPT_FILES=()
    JSON_FILES_LIST=()
    
    # Find shell scripts (exclude more paths that might cause issues)
    log_info "Scanning for shell scripts..."
    if command -v find >/dev/null 2>&1; then
        while IFS= read -r -d '' file; do
            [[ -f "$file" && -r "$file" ]] && SHELL_SCRIPTS+=("$file")
        done < <(find . -type f \( -name "*.sh" -o -name "*.bash" \) \
            -not -path "./node_modules/*" -not -path "./.git/*" \
            -not -path "./coverage/*" -not -path "./build/*" \
            -not -path "./dist/*" -not -path "./.cache/*" \
            -not -path "./tmp/*" -print0 2>/dev/null || true)
    fi
    
    # Find JavaScript files (exclude test artifacts and build outputs)
    log_info "Scanning for JavaScript files..."
    if command -v find >/dev/null 2>&1; then
        while IFS= read -r -d '' file; do
            [[ -f "$file" && -r "$file" ]] && JAVASCRIPT_FILES+=("$file")
        done < <(find . -type f -name "*.js" \
            -not -path "./node_modules/*" -not -path "./.git/*" \
            -not -path "./coverage/*" -not -path "./build/*" \
            -not -path "./dist/*" -not -path "./.cache/*" \
            -not -path "./tmp/*" -print0 2>/dev/null || true)
    fi
    
    # Find TypeScript files (ONLY in our project, not node_modules)
    log_info "Scanning for TypeScript files..."
    if command -v find >/dev/null 2>&1; then
        while IFS= read -r -d '' file; do
            [[ -f "$file" && -r "$file" ]] && TYPESCRIPT_FILES+=("$file")
        done < <(find . -type f \( -name "*.ts" -o -name "*.tsx" \) \
            -not -path "./node_modules/*" -not -path "./.git/*" \
            -not -path "./coverage/*" -not -path "./build/*" \
            -not -path "./dist/*" -not -path "./.cache/*" \
            -not -path "./tmp/*" -print0 2>/dev/null || true)
    fi
    
    # Find JSON files (exclude node_modules and build artifacts)
    log_info "Scanning for JSON files..."
    if command -v find >/dev/null 2>&1; then
        while IFS= read -r -d '' file; do
            [[ -f "$file" && -r "$file" ]] && JSON_FILES_LIST+=("$file")
        done < <(find . -type f -name "*.json" \
            -not -path "./node_modules/*" -not -path "./.git/*" \
            -not -path "./coverage/*" -not -path "./build/*" \
            -not -path "./dist/*" -not -path "./.cache/*" \
            -not -path "./tmp/*" -print0 2>/dev/null || true)
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

# Validate shell scripts with comprehensive error capture
validate_shell_scripts() {
    [[ $SHELL_FILES -eq 0 ]] && return 0
    
    log_header "Shell Script Validation"
    
    # Check for ShellCheck
    local has_shellcheck=0
    if has_command shellcheck; then
        has_shellcheck=1
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
        
        # Basic syntax check - CAPTURE the error output
        local syntax_error
        if ! syntax_error=$(run_with_timeout 10 bash -n "$script" 2>&1); then
            printf "\r%80s\r" " " >&2  # Clear progress line
            log_error "Syntax error in: $basename_script"
            add_shell_error "$script" "Syntax error: $syntax_error"
            script_issues=1
        fi
        
        # ShellCheck if available - CAPTURE the detailed output
        if [[ $has_shellcheck -eq 1 && $script_issues -eq 0 ]]; then
            local shellcheck_output
            if ! shellcheck_output=$(run_with_timeout 15 shellcheck "$script" 2>&1); then
                printf "\r%80s\r" " " >&2  # Clear progress line
                log_warning "ShellCheck issues in: $basename_script"
                add_shell_error "$script" "ShellCheck issues: $shellcheck_output"
                script_issues=1
            else
                printf "\r%80s\r" " " >&2  # Clear progress line
                log_success "$basename_script - passed"
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

# Validate JavaScript files with enhanced error capture
validate_javascript_files() {
    [[ $JS_FILES -eq 0 ]] && return 0
    
    log_header "JavaScript Validation"
    
    local issues=0
    local has_node=0
    local has_eslint=0
    
    # Check available tools
    if run_with_timeout 5 node --version >/dev/null 2>&1; then
        has_node=1
        local node_version
        node_version="$(run_with_timeout 5 node --version 2>/dev/null || echo "unknown")"
        log_info "Using Node.js $node_version"
    else
        log_warning "Node.js not found - skipping JavaScript validation"
        return 0
    fi
    
    # Test ESLint
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
        
        # Show progress
        printf "\r%80s\r" " " >&2  # Clear line
        printf "\rProcessing JavaScript file %d/%d: %s" "$processed" "$JS_FILES" "$basename_file" >&2
        
        # Node.js syntax validation - CAPTURE the error output
        if [[ $has_node -eq 1 ]]; then
            local js_error
            if ! js_error=$(run_with_timeout 10 node --check "$jsfile" 2>&1); then
                printf "\r%80s\r" " " >&2  # Clear progress line
                log_error "JavaScript syntax error in: $basename_file"
                add_js_error "$jsfile" "Syntax error: $js_error"
                file_issues=1
            else
                printf "\r%80s\r" " " >&2  # Clear progress line
                log_success "$basename_file - syntax OK"
            fi
        fi
        
        # ESLint validation - CAPTURE the detailed output
        if [[ $has_eslint -eq 1 && $file_issues -eq 0 ]]; then
            local eslint_output
            if ! eslint_output=$(run_with_timeout 8 eslint "$jsfile" 2>&1); then
                log_warning "ESLint issues in: $basename_file"
                add_js_error "$jsfile" "ESLint issues: $eslint_output"
                file_issues=1
            fi
        fi
        
        if [[ $file_issues -gt 0 ]]; then
            issues=$((issues + 1))
        fi
    done
    
    # Clear progress line
    printf "\r%80s\r" " " >&2
    
    JS_ISSUES=$issues
    log_info "JavaScript validation complete: $issues issues found"
}

# Validate TypeScript files with proper error handling
validate_typescript_files() {
    [[ $TS_FILES -eq 0 ]] && return 0
    
    log_header "TypeScript Validation"
    
    local issues=0
    
    # Check for TypeScript compiler
    if ! run_with_timeout 5 tsc --version >/dev/null 2>&1; then
        log_warning "TypeScript compiler not found - skipping TypeScript validation"
        return 0
    fi
    
    local tsc_version
    tsc_version="$(run_with_timeout 5 tsc --version 2>/dev/null | cut -d' ' -f2 || echo "unknown")"
    log_info "Using TypeScript v$tsc_version"
    
    # Individual file syntax checking (safer than global compilation)
    local processed=0
    for tsfile in "${TYPESCRIPT_FILES[@]}"; do
        [[ ! -f "$tsfile" ]] && continue
        
        local basename_file
        basename_file="$(basename "$tsfile")"
        
        processed=$((processed + 1))
        printf "\rProcessing TypeScript file %d/%d: %s" "$processed" "$TS_FILES" "$basename_file" >&2
        
        # Basic TypeScript syntax check - CAPTURE error output
        local ts_error
        if ! ts_error=$(run_with_timeout 15 tsc --noEmit --skipLibCheck "$tsfile" 2>&1); then
            printf "\r%80s\r" " " >&2  # Clear progress line
            log_error "TypeScript error in: $basename_file"
            add_ts_error "$tsfile" "Compilation error: $ts_error"
            issues=$((issues + 1))
        else
            printf "\r%80s\r" " " >&2  # Clear progress line
            log_success "$basename_file - syntax OK"
        fi
    done
    
    # Clear progress line
    printf "\r%80s\r" " " >&2
    
    TS_ISSUES=$issues
    log_info "TypeScript validation: $issues issues found"
}

# Validate JSON files with comprehensive error reporting
validate_json_files() {
    [[ $JSON_FILES -eq 0 ]] && return 0
    
    log_header "JSON Validation"
    
    local issues=0
    local validation_method=""
    
    # Determine validation method
    if run_with_timeout 3 jq --version >/dev/null 2>&1; then
        validation_method="jq"
        log_info "Using jq for JSON validation"
    elif run_with_timeout 3 node --version >/dev/null 2>&1; then
        validation_method="node"
        log_info "Using Node.js for JSON validation"
    elif run_with_timeout 3 python3 --version >/dev/null 2>&1; then
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
        local json_error=""
        local exit_code=0
        
        processed=$((processed + 1))
        printf "\rProcessing JSON file %d/%d: %s" "$processed" "$JSON_FILES" "$basename_file" >&2
        
        # Validate based on available tool - CAPTURE error output and exit code
        case "$validation_method" in
            "jq")
                json_error=$(run_with_timeout 10 jq . "$jsonfile" 2>&1 >/dev/null)
                exit_code=$?
                ;;
            "node")
                json_error=$(run_with_timeout 10 node -e "JSON.parse(require('fs').readFileSync('$jsonfile', 'utf8'))" 2>&1)
                exit_code=$?
                ;;
            "python3")
                json_error=$(run_with_timeout 10 python3 -c "import json, sys; json.load(open(sys.argv[1]))" "$jsonfile" 2>&1)
                exit_code=$?
                ;;
        esac
        
        printf "\r%80s\r" " " >&2  # Clear progress line
        
        if [[ $exit_code -eq 0 ]]; then
            log_success "$basename_file - valid JSON"
        else
            log_error "Invalid JSON in: $basename_file"
            add_json_error "$jsonfile" "$json_error"
            issues=$((issues + 1))
        fi
    done
    
    # Clear progress line
    printf "\r%80s\r" " " >&2
    
    JSON_ISSUES=$issues
    log_info "JSON validation: $issues issues found"
}

# Show detailed error summary for debugging
show_detailed_errors() {
    if [[ ${#SHELL_ERRORS[@]} -gt 0 ]]; then
        log_header "Detailed Shell Script Errors"
        for ((i=0; i<${#SHELL_ERRORS[@]}; i+=2)); do
            local file="${SHELL_ERRORS[i]}"
            local msg="${SHELL_ERRORS[i+1]}"
            printf "\n${YELLOW}File: ${BOLD}%s${NC}\n" "$file" >&2
            while IFS= read -r line; do
                printf "  %s%s%s\n" "${RED}" "$line" "${NC}" >&2
            done <<< "${msg}"
        done
    fi
    
    if [[ ${#JS_ERRORS[@]} -gt 0 ]]; then
        log_header "Detailed JavaScript Errors"
        for ((i=0; i<${#JS_ERRORS[@]}; i+=2)); do
            local file="${JS_ERRORS[i]}"
            local msg="${JS_ERRORS[i+1]}"
            printf "\n${YELLOW}File: ${BOLD}%s${NC}\n" "$file" >&2
            while IFS= read -r line; do
                printf "  %s%s%s\n" "${RED}" "$line" "${NC}" >&2
            done <<< "${msg}"
        done
    fi
    
    if [[ ${#TS_ERRORS[@]} -gt 0 ]]; then
        log_header "Detailed TypeScript Errors"
        for ((i=0; i<${#TS_ERRORS[@]}; i+=2)); do
            local file="${TS_ERRORS[i]}"
            local msg="${TS_ERRORS[i+1]}"
            printf "\n${YELLOW}File: ${BOLD}%s${NC}\n" "$file" >&2
            while IFS= read -r line; do
                printf "  %s%s%s\n" "${RED}" "$line" "${NC}" >&2
            done <<< "${msg}"
        done
    fi
    
    if [[ ${#JSON_ERRORS[@]} -gt 0 ]]; then
        log_header "Detailed JSON Errors"
        for ((i=0; i<${#JSON_ERRORS[@]}; i+=2)); do
            local file="${JSON_ERRORS[i]}"
            local msg="${JSON_ERRORS[i+1]}"
            printf "\n${YELLOW}File: ${BOLD}%s${NC}\n" "$file" >&2
            while IFS= read -r line; do
                printf "  %s%s%s\n" "${RED}" "$line" "${NC}" >&2
            done <<< "${msg}"
        done
    fi
}

# Generate comprehensive summary
show_summary() {
    log_header "Validation Summary"
    
    # Calculate total issues
    TOTAL_ISSUES=$((SHELL_ISSUES + JS_ISSUES + TS_ISSUES + JSON_ISSUES))
    
    # File statistics
    printf '%sFile Statistics:%s\n' "${BOLD}" "${NC}" >&2
    printf "  • Shell scripts: %d (issues: %s%d%s)\n" "$SHELL_FILES" "${RED}" "$SHELL_ISSUES" "${NC}" >&2
    printf "  • JavaScript files: %d (issues: %s%d%s)\n" "$JS_FILES" "${RED}" "$JS_ISSUES" "${NC}" >&2
    printf "  • TypeScript files: %d (issues: %s%d%s)\n" "$TS_FILES" "${RED}" "$TS_ISSUES" "${NC}" >&2
    printf "  • JSON files: %d (issues: %s%d%s)\n" "$JSON_FILES" "${RED}" "$JSON_ISSUES" "${NC}" >&2
    printf "  • Total files: %d\n" "$TOTAL_FILES" >&2
    
    echo >&2
    
    # Show detailed errors if any
    if [[ $TOTAL_ISSUES -gt 0 ]]; then
        show_detailed_errors
    fi
    
    # Overall result
    if [[ $TOTAL_ISSUES -eq 0 ]]; then
        printf '%s%s🎉 ALL VALIDATIONS PASSED!%s\n' "${GREEN}" "${BOLD}" "${NC}" >&2
        printf '%sAll %d files are valid and ready for production.%s\n' "${GREEN}" "$TOTAL_FILES" "${NC}" >&2
        return 0
    else
        printf '\n%s%s⚠️  ISSUES FOUND%s\n' "${YELLOW}" "${BOLD}" "${NC}" >&2
        printf '%sFound %d issues across all files that need attention.%s\n' "${YELLOW}" "$TOTAL_ISSUES" "${NC}" >&2
        
        # Recommendations
        echo >&2
        printf '%sRecommendations:%s\n' "${BOLD}" "${NC}" >&2
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

${BOLD}NOTE:${NC}
    The accuracy of validation (including false positives) depends on the
    configuration of the underlying tools (e.g., .eslintrc, tsconfig.json).
    This script accurately reports the output from those tools.

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
    ✅ Detailed, non-suppressed error reporting for easy debugging
    ✅ Continue processing all files even if some fail
    ✅ Complete summary of all issues found
    ✅ Timeout protection for long-running operations

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
    
    # Run validations (each function handles its own errors)
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
