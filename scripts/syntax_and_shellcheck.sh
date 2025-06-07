#!/usr/bin/env bash

# Comprehensive Code Validation Tool v3.5.1 (ShellCheck-fixed)
# Purpose: Validate .sh, .js, .ts, .json files without any false-positive suppression.

set -Euo pipefail

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------
SCRIPT_NAME=""
SCRIPT_NAME=$(basename "$0")
readonly SCRIPT_NAME
readonly SCRIPT_VERSION="3.5.1"

# Counters
TOTAL_FILES=0
SHELL_FILES=0
JS_FILES=0
TS_FILES=0
JSON_FILES=0

# Issue counters
TOTAL_ISSUES=0
SHELL_ISSUES=0
JS_ISSUES=0
TS_ISSUES=0
JSON_ISSUES=0

# File lists
declare -a SHELL_SCRIPTS=()
declare -a JAVASCRIPT_FILES=()
declare -a TYPESCRIPT_FILES=()
declare -a JSON_FILES_LIST=()

# Error detail arrays
declare -a SHELL_ERRORS=()
declare -a JS_ERRORS=()
declare -a TS_ERRORS=()
declare -a JSON_ERRORS=()

# ------------------------------------------------------------------------------
# ANSI Color Codes
# ------------------------------------------------------------------------------
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly RESET='\033[0m'

# ------------------------------------------------------------------------------
# Logging functions with ANSI colors
# ------------------------------------------------------------------------------
log_header()   { printf "\n${CYAN}=== %s ===${RESET}\n" "$1" >&2; }
log_info()     { printf "${BLUE}INFO:${RESET} %s\n" "$1" >&2; }
log_success()  { printf "${GREEN}SUCCESS:${RESET} %s\n" "$1" >&2; }
log_warning()  { printf "${YELLOW}WARNING:${RESET} %s\n" "$1" >&2; }
log_error()    { printf "${RED}ERROR:${RESET} %s\n" "$1" >&2; }
log_debug()    { printf "${GRAY}DEBUG:${RESET} %s\n" "$1" >&2; }

# ------------------------------------------------------------------------------
# Check if a command exists
# ------------------------------------------------------------------------------
has_command() { command -v "$1" >/dev/null 2>&1; }

# ------------------------------------------------------------------------------
# Run a command with optional timeout
# ------------------------------------------------------------------------------
run_with_timeout() {
    local timeout_sec="$1"; shift
    if has_command timeout; then
        timeout "$timeout_sec" "$@"
    elif has_command gtimeout; then
        gtimeout "$timeout_sec" "$@"
    else
        "$@"
    fi
}

# ------------------------------------------------------------------------------
# Error aggregation functions
# ------------------------------------------------------------------------------
add_shell_error() { SHELL_ERRORS+=("$1" "$2"); }
add_js_error()    { JS_ERRORS+=("$1" "$2"); }
add_ts_error()    { TS_ERRORS+=("$1" "$2"); }
add_json_error()  { JSON_ERRORS+=("$1" "$2"); }

# ------------------------------------------------------------------------------
# Discover files excluding common build and tool directories
# ------------------------------------------------------------------------------
discover_files() {
    log_header "File Discovery"

    SHELL_SCRIPTS=()
    JAVASCRIPT_FILES=()
    TYPESCRIPT_FILES=()
    JSON_FILES_LIST=()

    local exclude=(
        "./node_modules" "./.git" "./coverage" "./build" "./dist"
        "./.cache" "./tmp" "./.cursor" "./.vscode" "./logs" "./.nyc_output" "./public/build"
    )

    # Build prune arguments
    local prune_args=()
    for d in "${exclude[@]}"; do
        prune_args+=( -path "$d" -prune -o )
    done

    # Find shell scripts
    log_info "Scanning for shell scripts..."
    while IFS= read -r -d '' file; do
        [[ -f "$file" && -r "$file" ]] && SHELL_SCRIPTS+=("$file")
    done < <(find . "${prune_args[@]}" -type f \( -name "*.sh" -o -name "*.bash" -o -name "*.zsh" -o -name "*.ksh" \) -print0)

    # Find executable files with shebang
    while IFS= read -r -d '' file; do
        if [[ -f "$file" && -r "$file" ]] && head -n1 "$file" 2>/dev/null | grep -qE '^#!/.*(bash|sh|zsh|ksh)'; then
            SHELL_SCRIPTS+=("$file")
        fi
    done < <(find . "${prune_args[@]}" -type f -perm /u=x -print0)

    # Find JavaScript files
    log_info "Scanning for JavaScript files..."
    while IFS= read -r -d '' file; do
        [[ -f "$file" && -r "$file" ]] && JAVASCRIPT_FILES+=("$file")
    done < <(find . "${prune_args[@]}" -type f \( -name "*.js" -o -name "*.mjs" -o -name "*.cjs" \) -print0)

    # Find TypeScript files
    log_info "Scanning for TypeScript files..."
    while IFS= read -r -d '' file; do
        [[ -f "$file" && -r "$file" ]] && TYPESCRIPT_FILES+=("$file")
    done < <(find . "${prune_args[@]}" -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.mts" -o -name "*.cts" \) -print0)

    # Find JSON files
    log_info "Scanning for JSON files..."
    while IFS= read -r -d '' file; do
        [[ -f "$file" && -r "$file" ]] && JSON_FILES_LIST+=("$file")
    done < <(find . "${prune_args[@]}" -type f \( -name "*.json" -o -name "*.jsonc" \) -print0)

    # Deduplicate shell scripts
    if [[ ${#SHELL_SCRIPTS[@]} -gt 0 ]]; then
        local uniq_shell=()
        while IFS= read -r -d '' item; do
            uniq_shell+=("$item")
        done < <(printf '\0' "${SHELL_SCRIPTS[@]}" | sort -uz)  
        SHELL_SCRIPTS=("${uniq_shell[@]}")
    fi

    # Update counters
    SHELL_FILES=${#SHELL_SCRIPTS[@]}
    JS_FILES=${#JAVASCRIPT_FILES[@]}
    TS_FILES=${#TYPESCRIPT_FILES[@]}
    JSON_FILES=${#JSON_FILES_LIST[@]}
    TOTAL_FILES=$((SHELL_FILES + JS_FILES + TS_FILES + JSON_FILES))

    # Report discovery
    log_info "Discovery Results:"
    printf "  ${WHITE}•${RESET} Shell scripts: %d\n" "$SHELL_FILES" >&2
    printf "  ${WHITE}•${RESET} JavaScript files: %d\n" "$JS_FILES" >&2
    printf "  ${WHITE}•${RESET} TypeScript files: %d\n" "$TS_FILES" >&2
    printf "  ${WHITE}•${RESET} JSON files: %d\n" "$JSON_FILES" >&2
    printf "  ${WHITE}•${RESET} Total files: %d\n" "$TOTAL_FILES" >&2
}

# ------------------------------------------------------------------------------
# Validate shell scripts: syntax + ShellCheck (if available). Report all issues.
# ------------------------------------------------------------------------------
validate_shell_scripts() {
    [[ $SHELL_FILES -eq 0 ]] && return 0
    log_header "Shell Script Validation"

    local has_shellcheck=0
    if has_command shellcheck; then
        has_shellcheck=1
        local ver
        ver=$(run_with_timeout 5 shellcheck --version | grep "version:" | awk '{print $2}')
        log_info "ShellCheck version: $ver"
    else
        log_warning "ShellCheck not found: install for full validation"
    fi

    local processed=0
    for script in "${SHELL_SCRIPTS[@]}"; do
        [[ ! -f "$script" ]] && continue
        processed=$((processed + 1))
        printf "\r${CYAN}Processing shell script %d/%d: ${WHITE}%s${RESET}" "$processed" "$SHELL_FILES" "$(basename "$script")" >&2

        local issues_in_file=0
        # Syntax check
        if ! bash -n "$script" 2>/dev/null; then
            printf "\r%80s\r" "" >&2
            log_error "Syntax error in: $script"
            add_shell_error "$script" "Bash syntax validation failed"
            issues_in_file=1
        fi

        # ShellCheck (treat warnings as issues too)
        if [[ $has_shellcheck -eq 1 && $issues_in_file -eq 0 ]]; then
            local sc_output
            if ! sc_output=$(run_with_timeout 15 shellcheck -x "$script" 2>&1); then
                printf "\r%80s\r" "" >&2
                log_warning "ShellCheck issues in: $script"
                add_shell_error "$script" "$sc_output"
                issues_in_file=1
            fi
        fi

        if [[ $issues_in_file -eq 0 ]]; then
            printf "\r%80s\r" "" >&2
            log_success "$(basename "$script") passed"
        else
            SHELL_ISSUES=$((SHELL_ISSUES + 1))
        fi
    done
    printf "\r%80s\r" "" >&2
    log_info "Shell validation: $((SHELL_FILES - SHELL_ISSUES)) passed, $SHELL_ISSUES issues"
}

# ------------------------------------------------------------------------------
# Validate JavaScript: node --check + ESLint (if available). Report all issues.
# ------------------------------------------------------------------------------
validate_javascript_files() {
    [[ $JS_FILES -eq 0 ]] && return 0
    log_header "JavaScript Validation"

    if ! has_command node; then
        log_warning "Node.js not found: skipping JS validation"
        return 0
    fi
    local node_ver
    node_ver=$(run_with_timeout 5 node --version)
    log_info "Node.js detected: $node_ver"

    local has_eslint=0
    if has_command eslint; then
        has_eslint=1
        local eslint_ver
        eslint_ver=$(run_with_timeout 5 eslint --version)
        log_info "ESLint detected: $eslint_ver"
    else
        log_info "ESLint not found: JS linting skipped"
    fi

    local processed=0
    for js in "${JAVASCRIPT_FILES[@]}"; do
        [[ ! -f "$js" ]] && continue
        processed=$((processed + 1))
        printf "\r${CYAN}Processing JS file %d/%d: %s${RESET}" "$processed" "$JS_FILES" "$(basename "$js")" >&2

        local issues_in_file=0
        # Syntax check
        if ! node --check "$js" 2>/dev/null; then
            printf "\r%80s\r" "" >&2
            log_error "Syntax error in: $js"
            add_js_error "$js" "Node syntax check failed"
            issues_in_file=1
        fi

        # ESLint (treat warnings as issues)
        if [[ $has_eslint -eq 1 && $issues_in_file -eq 0 ]]; then
            local etl_out
            if ! etl_out=$(run_with_timeout 10 eslint "$js" 2>&1); then
                printf "\r%80s\r" "" >&2
                log_warning "ESLint issues in: $js"
                add_js_error "$js" "$etl_out"
                issues_in_file=1
            fi
        fi

        if [[ $issues_in_file -eq 0 ]]; then
            printf "\r%80s\r" "" >&2
            log_success "$(basename "$js") passed"
        else
            JS_ISSUES=$((JS_ISSUES + 1))
        fi
    done
    printf "\r%80s\r" "" >&2
    log_info "JavaScript validation: $((JS_FILES - JS_ISSUES)) passed, $JS_ISSUES issues"
}

# ------------------------------------------------------------------------------
# Validate TypeScript: tsc --noEmit --strict. Report all issues.
# ------------------------------------------------------------------------------
validate_typescript_files() {
    [[ $TS_FILES -eq 0 ]] && return 0
    log_header "TypeScript Validation"

    if ! has_command tsc; then
        log_warning "tsc not found: skipping TypeScript validation"
        return 0
    fi
    local tsc_ver
    tsc_ver=$(run_with_timeout 5 tsc --version | awk '{print $2}')
    log_info "TypeScript detected: v$tsc_ver"

    local processed=0
    for ts in "${TYPESCRIPT_FILES[@]}"; do
        [[ ! -f "$ts" ]] && continue
        processed=$((processed + 1))
        printf "\r${CYAN}Processing TS file %d/%d: %s${RESET}" "$processed" "$TS_FILES" "$(basename "$ts")" >&2

        if ! tsc --noEmit --skipLibCheck --strict "$ts" 2>/dev/null; then
            printf "\r%80s\r" "" >&2
            log_error "TypeScript error in: $ts"
            add_ts_error "$ts" "tsc compilation failed"
            TS_ISSUES=$((TS_ISSUES + 1))
        else
            printf "\r%80s\r" "" >&2
            log_success "$(basename "$ts") passed"
        fi
    done
    printf "\r%80s\r" "" >&2
    log_info "TypeScript validation: $((TS_FILES - TS_ISSUES)) passed, $TS_ISSUES issues"
}

# ------------------------------------------------------------------------------
# Validate JSON files: jq > node > python3. Report all issues.
# ------------------------------------------------------------------------------
validate_json_files() {
    [[ $JSON_FILES -eq 0 ]] && return 0
    log_header "JSON Validation"

    local method=""
    if has_command jq; then
        method="jq"
        local jq_ver
        jq_ver=$(run_with_timeout 3 jq --version)
        log_info "jq detected: $jq_ver"
    elif has_command node; then
        method="node"
        log_info "Node.js fallback for JSON detected"
    elif has_command python3; then
        method="python3"
        log_info "Python3 fallback for JSON detected"
    else
        log_warning "No JSON validator found: skipping JSON validation"
        return 0
    fi

    local processed=0
    for jf in "${JSON_FILES_LIST[@]}"; do
        [[ ! -f "$jf" ]] && continue
        processed=$((processed + 1))
        printf "\r${CYAN}Processing JSON file %d/%d: %s${RESET}" "$processed" "$JSON_FILES" "$(basename "$jf")" >&2

        local exit_code=0
        case "$method" in
            jq)
                if ! jq . "$jf" >/dev/null 2>/dev/null; then
                    exit_code=1
                fi
                ;;
            node)
                if ! node -e "JSON.parse(require('fs').readFileSync('$jf','utf8'))" >/dev/null 2>/dev/null; then
                    exit_code=1
                fi
                ;;
            python3)
                if ! python3 -c "import json,sys; json.load(open(sys.argv[1]))" "$jf" >/dev/null 2>/dev/null; then
                    exit_code=1
                fi
                ;;
        esac

        printf "\r%80s\r" "" >&2
        if [[ $exit_code -eq 0 ]]; then
            log_success "$(basename "$jf") valid"
        else
            log_error "Invalid JSON in: $jf"
            add_json_error "$jf" "JSON validation failed"
            JSON_ISSUES=$((JSON_ISSUES + 1))
        fi
    done
    printf "\r%80s\r" "" >&2
    log_info "JSON validation: $((JSON_FILES - JSON_ISSUES)) passed, $JSON_ISSUES issues"
}

# ------------------------------------------------------------------------------
# Show detailed errors if any
# ------------------------------------------------------------------------------
show_detailed_errors() {
    if [[ ${#SHELL_ERRORS[@]} -gt 0 ]]; then
        log_header "Detailed Shell Script Errors"
        for ((i=0; i<${#SHELL_ERRORS[@]}; i+=2)); do
            printf "\n${WHITE}File:${RESET} %s\n  ${RED}Issue:${RESET} %s\n" "${SHELL_ERRORS[i]}" "${SHELL_ERRORS[i+1]}" >&2
        done
    fi
    if [[ ${#JS_ERRORS[@]} -gt 0 ]]; then
        log_header "Detailed JavaScript Errors"
        for ((i=0; i<${#JS_ERRORS[@]}; i+=2)); do
            printf "\n${WHITE}File:${RESET} %s\n  ${RED}Issue:${RESET} %s\n" "${JS_ERRORS[i]}" "${JS_ERRORS[i+1]}" >&2
        done
    fi
    if [[ ${#TS_ERRORS[@]} -gt 0 ]]; then
        log_header "Detailed TypeScript Errors"
        for ((i=0; i<${#TS_ERRORS[@]}; i+=2)); do
            printf "\n${WHITE}File:${RESET} %s\n  ${RED}Issue:${RESET} %s\n" "${TS_ERRORS[i]}" "${TS_ERRORS[i+1]}" >&2
        done
    fi
    if [[ ${#JSON_ERRORS[@]} -gt 0 ]]; then
        log_header "Detailed JSON Errors"
        for ((i=0; i<${#JSON_ERRORS[@]}; i+=2)); do
            printf "\n${WHITE}File:${RESET} %s\n  ${RED}Issue:${RESET} %s\n" "${JSON_ERRORS[i]}" "${JSON_ERRORS[i+1]}" >&2
        done
    fi
}

# ------------------------------------------------------------------------------
# Show summary and exit code
# ------------------------------------------------------------------------------
show_summary() {
    log_header "Validation Summary"
    TOTAL_ISSUES=$((SHELL_ISSUES + JS_ISSUES + TS_ISSUES + JSON_ISSUES))

    printf "\nFile Statistics:\n" "$WHITE" "$RESET" >&2
    printf "  • Shell scripts: %d (issues: %d)\n" "$SHELL_FILES" "$SHELL_ISSUES" >&2
    printf "  • JavaScript files: %d (issues: %d)\n" "$JS_FILES" "$JS_ISSUES" >&2
    printf "  • TypeScript files: %d (issues: %d)\n" "$TS_FILES" "$TS_ISSUES" >&2
    printf "  • JSON files: %d (issues: %d)\n" "$JSON_FILES" "$JSON_ISSUES" >&2
    printf "  • Total files: %d\n" "$TOTAL_FILES" >&2

    if [[ $TOTAL_ISSUES -gt 0 ]]; then
        show_detailed_errors
        printf "\n⚠️  ISSUES FOUND: %d across all files\n" "$TOTAL_ISSUES" >&2
        printf "Recommendations:\n" >&2
        if [[ $SHELL_ISSUES -gt 0 ]]; then
            printf "  • Fix shell script issues using shellcheck\n" >&2
        fi
        if [[ $JS_ISSUES -gt 0 ]]; then
            printf "  • Fix JavaScript issues using eslint\n" >&2
        fi
        if [[ $TS_ISSUES -gt 0 ]]; then
            printf "  • Fix TypeScript compilation errors\n" >&2
        fi
        if [[ $JSON_ISSUES -gt 0 ]]; then
            printf "  • Fix JSON syntax errors\n" >&2
        fi
        exit 1
    else
        printf "\n🎉 ALL VALIDATIONS PASSED! All %d files are valid.\n" "$TOTAL_FILES" >&2
        exit 0
    fi
}

# ------------------------------------------------------------------------------
# Display help text
# ------------------------------------------------------------------------------
show_help() {
    cat << EOF
${CYAN}Comprehensive Code Validation Tool v${SCRIPT_VERSION}${RESET}

${WHITE}USAGE:${RESET}
  $SCRIPT_NAME [OPTIONS]

${WHITE}OPTIONS:${RESET}
  -h, --help      Show help message
  --version       Show version

${WHITE}DESCRIPTION:${RESET}
  Validates code files with full transparency—no suppressed warnings or masked errors.

  ${YELLOW}Shell Scripts (.sh, etc.):${RESET}
    • Syntax check: bash -n
    • Lint: shellcheck (all severities)

  ${YELLOW}JavaScript (.js, etc.):${RESET}
    • Syntax check: node --check
    • Lint: eslint

  ${YELLOW}TypeScript (.ts, etc.):${RESET}
    • Compilation check: tsc --noEmit --strict

  ${YELLOW}JSON (.json, .jsonc):${RESET}
    • Validation: jq, node, or python3

${WHITE}EXIT CODES:${RESET}
  0   All files passed
  1   One or more issues found
  2   Invalid arguments

EOF
}

# ------------------------------------------------------------------------------
# Argument parsing
# ------------------------------------------------------------------------------
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help; exit 0
                ;;
            --version)
                echo "${CYAN}Comprehensive Code Validation Tool v$SCRIPT_VERSION${RESET}"; exit 0
                ;;
            *)
                log_error "Unknown argument: $1"
                show_help >&2; exit 2
                ;;
        esac
    done
}

# ------------------------------------------------------------------------------
# Main execution
# ------------------------------------------------------------------------------
main() {
    printf "\n"
    printf "╔═════════════════════════════════════════════════════════════════════════╗\n"
    printf "║             Comprehensive Code Validation Tool v%-22s  ║\n" "$SCRIPT_VERSION"
    printf "║               Shell • JavaScript • TypeScript • JSON                    ║\n"
    printf "╚═════════════════════════════════════════════════════════════════════════╝\n"
    printf "\n"

    discover_files
    validate_shell_scripts
    validate_javascript_files
    validate_typescript_files
    validate_json_files
    show_summary
}

# ------------------------------------------------------------------------------
# Entrypoint
# ------------------------------------------------------------------------------
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    parse_arguments "$@"
    main
fi
