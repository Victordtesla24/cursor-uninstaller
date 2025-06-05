#!/bin/bash

# Comprehensive Syntax, Linting & Integrity Validation Script
# Validates Shell scripts (.sh), JavaScript files (.js), and project structure
# Follows .clinerules/cline-directory-management-protocols.md for duplicate detection
set -euo pipefail

# Color codes for industry-standard output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly NC='\033[0m' # No Color

# Global counters
TOTAL_FILES=0
PROCESSED_FILES=0
SYNTAX_ERRORS=0
LINTER_ERRORS=0
IMPORT_ERRORS=0
RUNTIME_ERRORS=0
DUPLICATE_ERRORS=0
STRUCTURE_ERRORS=0
JSON_ERRORS=0

# Arrays to store discovered files
SHELL_SCRIPTS=()
JS_FILES=()
JSON_FILES=()
CONFIG_FILES=()
ALL_FILES=()

# Performance tracking
START_TIME=$(date +%s)

# Utility functions
log_info() { echo -e "${BLUE}ℹ ${1}${NC}"; }
log_success() { echo -e "${GREEN}✓ ${1}${NC}"; }
log_warning() { echo -e "${YELLOW}⚠ ${1}${NC}"; }
log_error() { echo -e "${RED}✗ ${1}${NC}"; }
log_critical() { echo -e "${RED}🚨 CRITICAL: ${1}${NC}"; }
log_header() { echo -e "\n${WHITE}=== ${1} ===${NC}"; }

# Create temporary directory for analysis
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

# 1. COMPREHENSIVE FILE DISCOVERY
discover_files() {
    log_header "File Discovery & Inventory"
    
    # Project-focused directories only (excluding dev/build artifacts)
    local scan_dirs=("scripts" "modules" "lib" "bin" "tests" "docs" "src")
    
    # Comprehensive exclusions - focus only on project-relevant files
    local exclude_patterns=(
        "node_modules" ".venv" ".git" ".cursor" ".vscode" ".cline"
        "build" "dist" "coverage" "__pycache__" ".pytest_cache" 
        ".mypy_cache" "*.egg-info" ".tox" "tmp" "temp"
        ".DS_Store" "*.log" "*.tmp" ".cache" ".next"
        "vendor" "bower_components" ".sass-cache"
    )
    
    # Build find exclusion arguments as array
    local find_excludes=()
    for pattern in "${exclude_patterns[@]}"; do
        find_excludes+=("-not" "-path" "*/${pattern}/*" "-not" "-name" "${pattern}")
    done
    
    log_info "Scanning project directories: ${scan_dirs[*]}"
    log_info "Excluding: ${exclude_patterns[*]}"
    
    # Discover shell scripts
    while IFS= read -r -d '' file; do
        SHELL_SCRIPTS+=("$file")
        ALL_FILES+=("$file")
    done < <(find "${scan_dirs[@]}" -type f \( -name "*.sh" -o -name "*.bash" \) "${find_excludes[@]}" -print0 2>/dev/null || true)
    
    # Discover JavaScript files
    while IFS= read -r -d '' file; do
        JS_FILES+=("$file")
        ALL_FILES+=("$file")
    done < <(find "${scan_dirs[@]}" -type f -name "*.js" "${find_excludes[@]}" -print0 2>/dev/null || true)
    
    # Discover JSON files (limit root search to avoid excluded dirs)
    while IFS= read -r -d '' file; do
        JSON_FILES+=("$file")
        ALL_FILES+=("$file")
    done < <(find "${scan_dirs[@]}" -type f -name "*.json" "${find_excludes[@]}" -print0 2>/dev/null || true)
    
    # Add root-level JSON files separately with proper exclusions
    while IFS= read -r -d '' file; do
        [[ ! " ${JSON_FILES[*]} " =~ \ $file\  ]] && JSON_FILES+=("$file") && ALL_FILES+=("$file")
    done < <(find . -maxdepth 1 -type f -name "*.json" -print0 2>/dev/null || true)
    
    # Discover configuration files (separate from JSON for special handling)
    while IFS= read -r -d '' file; do
        CONFIG_FILES+=("$file")
    done < <(find . -maxdepth 2 -type f \( -name ".eslintrc*" -o -name "tsconfig.json" -o -name ".shellcheckrc" -o -name ".gitignore" \) -print0 2>/dev/null || true)
    
    TOTAL_FILES=$((${#SHELL_SCRIPTS[@]} + ${#JS_FILES[@]} + ${#JSON_FILES[@]}))
    
    log_success "Discovered ${#SHELL_SCRIPTS[@]} shell scripts"
    log_success "Discovered ${#JS_FILES[@]} JavaScript files"
    log_success "Discovered ${#JSON_FILES[@]} JSON files"
    log_success "Discovered ${#CONFIG_FILES[@]} configuration files"
    log_info "Total files to validate: $TOTAL_FILES"
    
    # List discovered files
    if [[ ${#SHELL_SCRIPTS[@]} -gt 0 ]]; then
        echo -e "${CYAN}Shell Scripts:${NC}"
        printf "  • %s\n" "${SHELL_SCRIPTS[@]}"
    fi
    
    if [[ ${#JS_FILES[@]} -gt 0 ]]; then
        echo -e "${CYAN}JavaScript Files:${NC}"
        printf "  • %s\n" "${JS_FILES[@]}"
    fi
    
    if [[ ${#JSON_FILES[@]} -gt 0 ]]; then
        echo -e "${CYAN}JSON Files:${NC}"
        printf "  • %s\n" "${JSON_FILES[@]}"
    fi
}

# 2. SHELL SCRIPT VALIDATION
validate_shell_scripts() {
    [[ ${#SHELL_SCRIPTS[@]} -eq 0 ]] && return 0
    
    log_header "Shell Script Syntax & ShellCheck Validation"
    
    local shell_errors=0
    
    for script in "${SHELL_SCRIPTS[@]}"; do
        [[ ! -f "$script" ]] && continue
        
        echo -n "Validating: $script ... "
        
        # Syntax check
        if ! bash -n "$script" 2>/dev/null; then
            log_error "Syntax error in: $script"
            bash -n "$script" 2>&1 | head -5
            ((shell_errors++))
            ((SYNTAX_ERRORS++))
            continue
        fi
        
        # ShellCheck validation
        if command -v shellcheck >/dev/null 2>&1; then
            local shellcheck_output
            shellcheck_output=$(shellcheck --severity=info --source-path=SCRIPTDIR "$script" 2>&1 || true)
            
            if [[ -n "$shellcheck_output" ]]; then
                log_warning "ShellCheck issues in: $script"
                echo "$shellcheck_output" | head -10
                ((shell_errors++))
                ((LINTER_ERRORS++))
            else
                log_success "PASS"
            fi
        else
            log_warning "ShellCheck not available"
            echo "SKIP"
        fi
        
        ((PROCESSED_FILES++))
    done
    
    log_info "Shell script validation: $((${#SHELL_SCRIPTS[@]} - shell_errors))/${#SHELL_SCRIPTS[@]} passed"
}

# 3. JAVASCRIPT VALIDATION
validate_javascript_files() {
    [[ ${#JS_FILES[@]} -eq 0 ]] && return 0
    
    log_header "JavaScript Syntax & ESLint Validation"
    
    local js_errors=0
    
    # Check if Node.js is available
    if ! command -v node >/dev/null 2>&1; then
        log_error "Node.js not available - skipping JavaScript validation"
        return 1
    fi
    
    for jsfile in "${JS_FILES[@]}"; do
        [[ ! -f "$jsfile" ]] && continue
        
        echo -n "Validating: $jsfile ... "
        
        # Node.js syntax check
        if ! node --check "$jsfile" 2>/dev/null; then
            log_error "Syntax error in: $jsfile"
            node --check "$jsfile" 2>&1 | head -5
            ((js_errors++))
            ((SYNTAX_ERRORS++))
            continue
        fi
        
        # ESLint validation
        if command -v npx >/dev/null 2>&1 && [[ -f ".eslintrc.json" || -f "eslint.config.js" ]]; then
            local eslint_output
            eslint_output=$(npx eslint "$jsfile" 2>&1 || true)
            
            if [[ -n "$eslint_output" ]] && [[ "$eslint_output" != *"0 problems"* ]]; then
                log_warning "ESLint issues in: $jsfile"
                echo "$eslint_output" | head -10
                ((js_errors++))
                ((LINTER_ERRORS++))
            else
                log_success "PASS"
            fi
        else
            log_success "PASS (no ESLint config)"
        fi
        
        ((PROCESSED_FILES++))
    done
    
    log_info "JavaScript validation: $((${#JS_FILES[@]} - js_errors))/${#JS_FILES[@]} passed"
}

# 4. JSON VALIDATION
validate_json_files() {
    [[ ${#JSON_FILES[@]} -eq 0 ]] && return 0
    
    log_header "JSON Syntax & Schema Validation"
    
    local json_errors=0
    
    for jsonfile in "${JSON_FILES[@]}"; do
        [[ ! -f "$jsonfile" ]] && continue
        
        echo -n "Validating: $jsonfile ... "
        
        # JSON syntax validation using multiple methods
        local json_valid=true
        local validation_method=""
        
        # Try jq first (most reliable)
        if command -v jq >/dev/null 2>&1; then
            if ! jq empty "$jsonfile" 2>/dev/null; then
                json_valid=false
                validation_method="jq"
            fi
        # Fall back to python
        elif command -v python3 >/dev/null 2>&1; then
            if ! python3 -m json.tool "$jsonfile" >/dev/null 2>&1; then
                json_valid=false
                validation_method="python3"
            fi
        elif command -v python >/dev/null 2>&1; then
            if ! python -m json.tool "$jsonfile" >/dev/null 2>&1; then
                json_valid=false
                validation_method="python"
            fi
        # Fall back to node.js
        elif command -v node >/dev/null 2>&1; then
            if ! node -e "JSON.parse(require('fs').readFileSync('$jsonfile', 'utf8'))" 2>/dev/null; then
                json_valid=false
                validation_method="node"
            fi
        else
            log_warning "No JSON validator available (jq, python, or node)"
            echo "SKIP"
            continue
        fi
        
        if [[ "$json_valid" == "false" ]]; then
            log_error "JSON syntax error in: $jsonfile"
            case "$validation_method" in
                "jq") jq empty "$jsonfile" 2>&1 | head -3 ;;
                "python3") python3 -m json.tool "$jsonfile" 2>&1 | head -3 ;;
                "python") python -m json.tool "$jsonfile" 2>&1 | head -3 ;;
                "node") node -e "JSON.parse(require('fs').readFileSync('$jsonfile', 'utf8'))" 2>&1 | head -3 ;;
            esac
            ((json_errors++))
            ((JSON_ERRORS++))
            ((SYNTAX_ERRORS++))
            continue
        fi
        
        # Special validation for common JSON files
        local filename
        filename=$(basename "$jsonfile")
        case "$filename" in
            "package.json")
                # Validate package.json structure
                if command -v jq >/dev/null 2>&1; then
                    local missing_fields=()
                    [[ "$(jq -r '.name // empty' "$jsonfile")" == "" ]] && missing_fields+=("name")
                    [[ "$(jq -r '.version // empty' "$jsonfile")" == "" ]] && missing_fields+=("version")
                    
                    if [[ ${#missing_fields[@]} -gt 0 ]]; then
                        log_warning "package.json missing required fields: ${missing_fields[*]}"
                        ((json_errors++))
                        ((JSON_ERRORS++))
                    fi
                    
                    # Check for duplicate dependencies
                    local deps_file="$TEMP_DIR/deps_check.txt"
                    jq -r '.dependencies // {} | keys[]' "$jsonfile" > "$deps_file" 2>/dev/null || true
                    jq -r '.devDependencies // {} | keys[]' "$jsonfile" >> "$deps_file" 2>/dev/null || true
                    
                    local duplicates
                    duplicates=$(sort "$deps_file" | uniq -d)
                    if [[ -n "$duplicates" ]]; then
                        log_warning "Duplicate dependencies in package.json: $duplicates"
                        ((json_errors++))
                        ((JSON_ERRORS++))
                    fi
                fi
                ;;
            ".eslintrc.json"|"eslint.config.json")
                # Basic ESLint config validation
                if command -v jq >/dev/null 2>&1; then
                    if ! jq -e '.extends // .rules // .env' "$jsonfile" >/dev/null 2>&1; then
                        log_warning "ESLint config appears incomplete (no extends, rules, or env)"
                        ((json_errors++))
                        ((JSON_ERRORS++))
                    fi
                fi
                ;;
            "tsconfig.json")
                # Basic TypeScript config validation
                if command -v jq >/dev/null 2>&1; then
                    if ! jq -e '.compilerOptions' "$jsonfile" >/dev/null 2>&1; then
                        log_warning "tsconfig.json missing compilerOptions"
                        ((json_errors++))
                        ((JSON_ERRORS++))
                    fi
                fi
                ;;
        esac
        
        # Check for duplicate keys (common JSON issue)
        if command -v jq >/dev/null 2>&1; then
            local key_count
            key_count=$(jq -r 'paths(scalars) as $p | $p | join(".")' "$jsonfile" 2>/dev/null | sort | uniq -d | wc -l)
            if [[ $key_count -gt 0 ]]; then
                log_warning "Potential duplicate keys detected in: $jsonfile"
                ((json_errors++))
                ((JSON_ERRORS++))
            fi
        fi
        
        if [[ $json_errors -eq 0 ]]; then
            log_success "PASS"
        fi
        
        ((PROCESSED_FILES++))
    done
    
    log_info "JSON validation: $((${#JSON_FILES[@]} - json_errors))/${#JSON_FILES[@]} passed"
}

# 5. IMPORT ERROR VALIDATION
validate_imports() {
    log_header "Import & Dependency Validation"
    
    local import_issues=0
    
    # Check shell script sourcing
    for script in "${SHELL_SCRIPTS[@]}"; do
        [[ ! -f "$script" ]] && continue
        
        # Look for source/. commands and validate paths
        while IFS= read -r line; do
            if [[ "$line" =~ ^[[:space:]]*(source|\.|bash)[[:space:]]+([^[:space:]]+) ]]; then
                local sourced_file="${BASH_REMATCH[2]}"
                # Remove quotes and resolve relative paths
                sourced_file=$(echo "$sourced_file" | tr -d '"'"'" | sed "s|\\\$SCRIPT_DIR|scripts|g")
                
                if [[ ! -f "$sourced_file" ]] && [[ ! "$sourced_file" =~ ^/ ]]; then
                    log_warning "Missing sourced file in $script: $sourced_file"
                    ((import_issues++))
                fi
            fi
        done < "$script"
    done
    
    # Check JavaScript imports/requires
    for jsfile in "${JS_FILES[@]}"; do
        [[ ! -f "$jsfile" ]] && continue
        
        # Check for import statements and require calls
        local jsfile_content
        jsfile_content=$(cat "$jsfile")
        while IFS= read -r line; do
            if [[ "$line" =~ (import.*from[[:space:]]+[\'\"]\./|require\([\'\"]\./)[^\'\"]*[\'\"] ]]; then
                local imported_path
                imported_path=$(echo "$line" | grep -o '['\''"][^'\'']*['\''"]' | tr -d '"'"'" | head -1)
                
                if [[ -n "$imported_path" ]] && [[ "$imported_path" =~ ^\. ]]; then
                    # Resolve relative path
                    local dir_path
                    dir_path=$(dirname "$jsfile")
                    local full_path="$dir_path/$imported_path"
                    
                    # Check various extensions
                    if [[ ! -f "$full_path" ]] && [[ ! -f "$full_path.js" ]] && [[ ! -f "$full_path/index.js" ]]; then
                        log_warning "Potential missing import in $jsfile: $imported_path"
                        ((import_issues++))
                    fi
                fi
            fi
        done <<< "$jsfile_content"
    done
    
    IMPORT_ERRORS=$import_issues
    log_info "Import validation: $import_issues issues found"
}

# 5. RUNTIME ERROR VALIDATION
validate_runtime_errors() {
    log_header "Runtime & Type Error Validation"
    
    local runtime_issues=0
    
    # Check package.json dependencies
    if [[ -f "package.json" ]]; then
        log_info "Validating package.json dependencies..."
        
        # Check for node_modules existence
        if [[ ! -d "node_modules" ]]; then
            log_warning "node_modules directory missing - run 'npm install'"
            ((runtime_issues++))
        fi
        
        # Validate main entry point
        local main_file
        main_file=$(jq -r '.main // "index.js"' package.json 2>/dev/null || echo "index.js")
        if [[ -n "$main_file" ]] && [[ ! -f "$main_file" ]]; then
            log_warning "Main entry point missing: $main_file"
            ((runtime_issues++))
        fi
    fi
    
    # Check for TypeScript if files exist
    if find . -name "*.ts" -type f | head -1 | grep -q .; then
        log_info "TypeScript files detected"
        if command -v tsc >/dev/null 2>&1; then
            if ! tsc --noEmit 2>/dev/null; then
                log_warning "TypeScript compilation issues detected"
                ((runtime_issues++))
            fi
        else
            log_warning "TypeScript files found but tsc not available"
        fi
    fi
    
    RUNTIME_ERRORS=$runtime_issues
    log_info "Runtime validation: $runtime_issues issues found"
}

# 6. DUPLICATE DETECTION (following .clinerules protocols)
detect_duplicates() {
    log_header "Duplicate File & Code Detection"
    
    local duplicate_issues=0
    
    # Generate file content hashes
    local hash_file="$TEMP_DIR/file_hashes.txt"
    
    for file in "${ALL_FILES[@]}"; do
        [[ ! -f "$file" ]] && continue
        local hash
        hash=$(md5 -q "$file" 2>/dev/null || md5sum "$file" 2>/dev/null | cut -d' ' -f1)
        echo "$hash $file" >> "$hash_file"
    done
    
    # Find exact content duplicates
    if [[ -f "$hash_file" ]]; then
        while IFS= read -r hash; do
            local files_with_hash
            files_with_hash=$(grep "^$hash " "$hash_file" | cut -d' ' -f2-)
            local file_count
            file_count=$(echo "$files_with_hash" | wc -l)
            
            if [[ $file_count -gt 1 ]]; then
                log_warning "Exact duplicate files found:"
                printf '  • %s\n' "$files_with_hash"
                ((duplicate_issues++))
            fi
        done < <(cut -d' ' -f1 "$hash_file" | sort | uniq -d)
    fi
    
    # Check for similar function signatures
    local functions_file="$TEMP_DIR/functions.txt"
    
    for script in "${SHELL_SCRIPTS[@]}"; do
        [[ ! -f "$script" ]] && continue
        grep -n "^[[:space:]]*function\|^[[:space:]]*[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*(" "$script" 2>/dev/null | \
        sed "s|^|$script:|" >> "$functions_file" || true
    done
    
    for jsfile in "${JS_FILES[@]}"; do
        [[ ! -f "$jsfile" ]] && continue
        grep -n "function\|=>[[:space:]]*{" "$jsfile" 2>/dev/null | \
        sed "s|^|$jsfile:|" >> "$functions_file" || true
    done
    
    # Detect similar function names
    if [[ -f "$functions_file" ]]; then
        local func_names
        func_names=$(cut -d':' -f3- "$functions_file" | sed 's/.*function[[:space:]]*\([a-zA-Z_][a-zA-Z0-9_]*\).*/\1/' | sort | uniq -d)
        
        if [[ -n "$func_names" ]]; then
            while IFS= read -r func_name; do
                [[ -z "$func_name" ]] && continue
                log_warning "Potentially duplicate function: $func_name"
                grep "$func_name" "$functions_file" | head -3 | sed 's/^/  • /'
                ((duplicate_issues++))
            done <<< "$func_names"
        fi
    fi
    
    DUPLICATE_ERRORS=$duplicate_issues
    log_info "Duplicate detection: $duplicate_issues issues found"
}

# 7. DIRECTORY STRUCTURE VALIDATION
validate_directory_structure() {
    log_header "Directory Structure Integrity"
    
    local structure_issues=0
    
    # Check for proper Node.js project structure
    local expected_files=("package.json")
    local expected_dirs=("scripts" "lib" "tests")
    
    for file in "${expected_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            log_warning "Missing expected file: $file"
            ((structure_issues++))
        fi
    done
    
    for dir in "${expected_dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            log_info "Optional directory missing: $dir"
        fi
    done
    
    # Check for misplaced files
    local misplaced_files=()
    
    # Shell scripts should be in scripts/, bin/, or root
    for script in "${SHELL_SCRIPTS[@]}"; do
        if [[ ! "$script" =~ ^(scripts/|bin/|[^/]+\.sh$) ]]; then
            misplaced_files+=("$script (shell script in unexpected location)")
            ((structure_issues++))
        fi
    done
    
    # JavaScript files structure validation
    for jsfile in "${JS_FILES[@]}"; do
        # Check if test files are in appropriate directories
        if [[ "$jsfile" =~ \.(test|spec)\.js$ ]] && [[ ! "$jsfile" =~ ^tests/ ]]; then
            misplaced_files+=("$jsfile (test file outside tests/ directory)")
            ((structure_issues++))
        fi
    done
    
    if [[ ${#misplaced_files[@]} -gt 0 ]]; then
        log_warning "Misplaced files detected:"
        printf "  • %s\n" "${misplaced_files[@]}"
    fi
    
    # Check for orphaned files
    local orphaned_count=0
    for file in "${ALL_FILES[@]}"; do
        # Check if file is referenced anywhere
        local references=0
        if [[ ${#SHELL_SCRIPTS[@]} -gt 0 ]] || [[ ${#JS_FILES[@]} -gt 0 ]]; then
            local search_files=()
            [[ ${#SHELL_SCRIPTS[@]} -gt 0 ]] && search_files+=("${SHELL_SCRIPTS[@]}")
            [[ ${#JS_FILES[@]} -gt 0 ]] && search_files+=("${JS_FILES[@]}")
            
            if [[ ${#search_files[@]} -gt 0 ]]; then
                references=$(grep -r "$(basename "$file")" "${search_files[@]}" 2>/dev/null | wc -l 2>/dev/null || echo 0)
            fi
        fi
        if [[ $references -eq 0 ]] && [[ ! "$file" =~ (test|spec|config) ]]; then
            ((orphaned_count++))
        fi
    done
    
    if [[ $orphaned_count -gt 0 ]]; then
        log_info "Potentially orphaned files: $orphaned_count"
    fi
    
    STRUCTURE_ERRORS=$structure_issues
    log_info "Structure validation: $structure_issues issues found"
}

# 8. PERFORMANCE & SUMMARY REPORTING
generate_summary_report() {
    local end_time
    end_time=$(date +%s)
    local duration=$((end_time - START_TIME))
    
    log_header "Comprehensive Validation Summary"
    
    echo -e "${WHITE}Performance Metrics:${NC}"
    echo "  • Total execution time: ${duration}s"
    echo "  • Files discovered: $TOTAL_FILES"
    echo "  • Files processed: $PROCESSED_FILES"
    echo "  • Processing rate: $((PROCESSED_FILES / (duration + 1))) files/sec"
    
    echo -e "\n${WHITE}Validation Results:${NC}"
    echo "  • Shell scripts: ${#SHELL_SCRIPTS[@]}"
    echo "  • JavaScript files: ${#JS_FILES[@]}"
    echo "  • JSON files: ${#JSON_FILES[@]}"
    echo "  • Configuration files: ${#CONFIG_FILES[@]}"
    
    echo -e "\n${WHITE}Error Summary:${NC}"
    local total_errors=$((SYNTAX_ERRORS + LINTER_ERRORS + IMPORT_ERRORS + RUNTIME_ERRORS + DUPLICATE_ERRORS + STRUCTURE_ERRORS + JSON_ERRORS))
    
    echo "  • Syntax errors: $SYNTAX_ERRORS"
    echo "  • Linter issues: $LINTER_ERRORS"
    echo "  • JSON errors: $JSON_ERRORS"
    echo "  • Import problems: $IMPORT_ERRORS"
    echo "  • Runtime issues: $RUNTIME_ERRORS"
    echo "  • Duplicates found: $DUPLICATE_ERRORS"
    echo "  • Structure issues: $STRUCTURE_ERRORS"
    echo "  • Total issues: $total_errors"
    
    if [[ $total_errors -eq 0 ]]; then
        log_success "All validation checks passed! 🎉"
        log_info "Codebase health: EXCELLENT"
        return 0
    else
        log_error "Validation completed with $total_errors issues"
        log_info "Codebase health: NEEDS ATTENTION"
        
        # Provide debugging recommendations
        echo -e "\n${YELLOW}Debugging Recommendations:${NC}"
        [[ $SYNTAX_ERRORS -gt 0 ]] && echo "  • Fix syntax errors first (critical)"
        [[ $LINTER_ERRORS -gt 0 ]] && echo "  • Review linter output for code quality"
        [[ $IMPORT_ERRORS -gt 0 ]] && echo "  • Verify all import paths and dependencies"
        [[ $RUNTIME_ERRORS -gt 0 ]] && echo "  • Check runtime configuration and dependencies"
        [[ $DUPLICATE_ERRORS -gt 0 ]] && echo "  • Consolidate duplicate code per .clinerules protocols"
        [[ $STRUCTURE_ERRORS -gt 0 ]] && echo "  • Reorganize project structure following conventions"
        
        return 1
    fi
}

# MAIN EXECUTION
main() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════════════════════╗"
    echo "║                  Comprehensive Code Validation & Analysis                    ║"
    echo "║      Shell Scripts • JavaScript • JSON • Linting • Dependencies • Structure  ║"
    echo "╚══════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    # Execute validation phases
    discover_files
    validate_shell_scripts
    validate_javascript_files
    validate_json_files
    validate_imports
    validate_runtime_errors
    detect_duplicates
    validate_directory_structure
    generate_summary_report
}

# Check for required tools
check_prerequisites() {
    local missing_tools=()
    
    command -v bash >/dev/null 2>&1 || missing_tools+=("bash")
    command -v find >/dev/null 2>&1 || missing_tools+=("find")
    command -v grep >/dev/null 2>&1 || missing_tools+=("grep")
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        log_error "Missing required tools: ${missing_tools[*]}"
        exit 1
    fi
    
    # Check optional tools
    if ! command -v shellcheck >/dev/null 2>&1; then
        log_warning "ShellCheck not installed - shell script analysis will be limited"
        log_info "Install with: brew install shellcheck (macOS) or apt install shellcheck (Ubuntu)"
    fi
    
    if ! command -v node >/dev/null 2>&1; then
        log_warning "Node.js not installed - JavaScript analysis will be skipped"
    fi
}

# Script entry point
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    check_prerequisites
    main "$@"
fi
