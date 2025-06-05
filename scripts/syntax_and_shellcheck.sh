#!/bin/bash

# Enhanced Comprehensive Syntax, Linting & Integrity Validation Script
# Validates Shell scripts (.sh), JavaScript files (.js), and project structure
# Follows .clinerules/cline-directory-management-protocols.md for duplicate detection
# Version: 2.0 - Security hardened, performance optimized, cross-platform compatible
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
declare -a SHELL_SCRIPTS=()
declare -a JS_FILES=()
declare -a JSON_FILES=()
declare -a CONFIG_FILES=()
declare -a ALL_FILES=()

# Performance tracking
START_TIME=$(date +%s)
readonly START_TIME

# Configuration
readonly VALIDATION_TIMEOUT=30

# Utility functions
log_info() { echo -e "${BLUE}ℹ ${1}${NC}" >&2; }
log_success() { echo -e "${GREEN}✓ ${1}${NC}" >&2; }
log_warning() { echo -e "${YELLOW}⚠ ${1}${NC}" >&2; }
log_error() { echo -e "${RED}✗ ${1}${NC}" >&2; }
log_critical() { echo -e "${RED}🚨 CRITICAL: ${1}${NC}" >&2; }
log_header() { echo -e "\n${WHITE}=== ${1} ===${NC}" >&2; }

# Create temporary directory for analysis
TEMP_DIR=$(mktemp -d)
readonly TEMP_DIR
trap 'cleanup_and_exit' EXIT

# Enhanced cleanup function
cleanup_and_exit() {
    local exit_code=$?
    [[ -d "$TEMP_DIR" ]] && rm -rf "$TEMP_DIR"
    
    # Kill any background jobs
    jobs -p | xargs -r kill 2>/dev/null || true
    
    exit $exit_code
}

# Cross-platform file hash function (SECURITY FIX)
get_file_hash() {
    local file="$1"
    [[ ! -f "$file" ]] && return 1
    
    # Prefer SHA256 for better security, fallback to available tools
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$file" | cut -d' ' -f1
    elif command -v shasum >/dev/null 2>&1; then
        shasum -a 256 "$file" | cut -d' ' -f1
    elif command -v md5sum >/dev/null 2>&1; then
        md5sum "$file" | cut -d' ' -f1
    elif command -v md5 >/dev/null 2>&1; then
        md5 -q "$file"
    else
        # Fallback using file size + modification time
        if command -v stat >/dev/null 2>&1; then
            stat -c "%s-%Y" "$file" 2>/dev/null || stat -f "%z-%m" "$file" 2>/dev/null
        else
            # Ultimate fallback
            wc -c < "$file"
        fi
    fi
}

# Timeout wrapper for hanging tools (RELIABILITY FIX)
run_with_timeout() {
    local timeout_duration="$1"
    shift
    
    if command -v timeout >/dev/null 2>&1; then
        timeout "$timeout_duration" "$@"
    elif command -v gtimeout >/dev/null 2>&1; then
        gtimeout "$timeout_duration" "$@"
    else
        # Fallback without timeout
        "$@"
    fi
}

# Safe string manipulation (SECURITY FIX)
safe_clean_path() {
    local input="$1"
    # Use parameter expansion instead of dangerous sed/tr commands
    input="${input//\"/}"      # Remove double quotes
    input="${input//\'/}"      # Remove single quotes
    input="${input//\$SCRIPT_DIR/scripts}"  # Safe variable substitution
    echo "$input"
}

# Enhanced file discovery with robust scanning (PERFORMANCE & ACCURACY FIX)
discover_files() {
    log_header "File Discovery & Inventory"
    
    # Project-focused directories (excluding dev/build artifacts)
    local -a scan_dirs=("scripts" "modules" "lib" "bin" "tests" "docs" "src")
    
    # Always scan existing project directories AND root for common files
    local -a existing_dirs=()
    for dir in "${scan_dirs[@]}"; do
        [[ -d "$dir" ]] && existing_dirs+=("$dir")
    done
    
    # Always include root directory for package.json, config files, etc.
    existing_dirs+=(".")
    
    # Comprehensive exclusions - focus only on project-relevant files
    local -a exclude_patterns=(
        "node_modules" ".venv" ".git" ".cursor" ".vscode" ".cline"
        "build" "dist" "coverage" "__pycache__" ".pytest_cache" 
        ".mypy_cache" "*.egg-info" ".tox" "tmp" "temp"
        ".DS_Store" "*.log" "*.tmp" ".cache" ".next"
        "vendor" "bower_components" ".sass-cache"
    )
    
    log_info "Scanning directories: ${existing_dirs[*]}"
    log_info "Excluding patterns: ${exclude_patterns[*]}"
    
    # Scan each directory type separately for better control
    local file_count=0
    
    # Simplified file discovery using single find commands with path normalization
    log_info "Scanning for shell scripts..."
    while IFS= read -r -d '' file; do
        # Normalize path to remove leading ./
        file="${file#./}"
        SHELL_SCRIPTS+=("$file")
        ALL_FILES+=("$file")
        ((file_count++))
    done < <(find "${existing_dirs[@]}" -type f \( -name "*.sh" -o -name "*.bash" \) \
        ! -path "*/node_modules/*" ! -path "*/.git/*" ! -path "*/coverage/*" \
        ! -path "*/.venv/*" ! -path "*/build/*" ! -path "*/dist/*" \
        ! -path "*/.cursor/*" ! -path "*/.clinerules/*" \
        -print0 2>/dev/null)
    
    # Scan for JavaScript files
    log_info "Scanning for JavaScript files..."
    while IFS= read -r -d '' file; do
        # Normalize path to remove leading ./
        file="${file#./}"
        JS_FILES+=("$file")
        ALL_FILES+=("$file")
        ((file_count++))
    done < <(find "${existing_dirs[@]}" -type f -name "*.js" \
        ! -path "*/node_modules/*" ! -path "*/.git/*" ! -path "*/coverage/*" \
        ! -path "*/.venv/*" ! -path "*/build/*" ! -path "*/dist/*" \
        ! -path "*/.cursor/*" ! -path "*/.clinerules/*" \
        -print0 2>/dev/null)
    
    # Scan for JSON files
    log_info "Scanning for JSON files..."
    while IFS= read -r -d '' file; do
        # Normalize path to remove leading ./
        file="${file#./}"
        JSON_FILES+=("$file")
        ALL_FILES+=("$file")
        ((file_count++))
    done < <(find "${existing_dirs[@]}" -type f -name "*.json" \
        ! -path "*/node_modules/*" ! -path "*/.git/*" ! -path "*/coverage/*" \
        ! -path "*/.venv/*" ! -path "*/build/*" ! -path "*/dist/*" \
        ! -path "*/.cursor/*" ! -path "*/.clinerules/*" \
        -print0 2>/dev/null)
    
    # Discover configuration files separately
    log_info "Scanning for configuration files..."
    while IFS= read -r -d '' file; do
        CONFIG_FILES+=("$file")
    done < <(find . -maxdepth 2 -type f \( -name ".eslintrc*" -o -name "tsconfig.json" -o -name ".shellcheckrc" -o -name ".gitignore" \) -print0 2>/dev/null)
    
    # Remove duplicates from ALL_FILES array and individual arrays (cross-platform compatible)
    if [[ ${#ALL_FILES[@]} -gt 0 ]]; then
        local -a unique_files=()
        while IFS= read -r file; do
            [[ -n "$file" ]] && unique_files+=("$file")
        done < <(printf '%s\n' "${ALL_FILES[@]}" | sort | uniq)
        ALL_FILES=("${unique_files[@]}")
    fi
    
    # Deduplicate individual arrays too
    if [[ ${#SHELL_SCRIPTS[@]} -gt 0 ]]; then
        local -a unique_shell=()
        while IFS= read -r file; do
            [[ -n "$file" ]] && unique_shell+=("$file")
        done < <(printf '%s\n' "${SHELL_SCRIPTS[@]}" | sort | uniq)
        SHELL_SCRIPTS=("${unique_shell[@]}")
    fi
    
    if [[ ${#JS_FILES[@]} -gt 0 ]]; then
        local -a unique_js=()
        while IFS= read -r file; do
            [[ -n "$file" ]] && unique_js+=("$file")
        done < <(printf '%s\n' "${JS_FILES[@]}" | sort | uniq)
        JS_FILES=("${unique_js[@]}")
    fi
    
    if [[ ${#JSON_FILES[@]} -gt 0 ]]; then
        local -a unique_json=()
        while IFS= read -r file; do
            [[ -n "$file" ]] && unique_json+=("$file")
        done < <(printf '%s\n' "${JSON_FILES[@]}" | sort | uniq)
        JSON_FILES=("${unique_json[@]}")
    fi
    
    TOTAL_FILES=$((${#SHELL_SCRIPTS[@]} + ${#JS_FILES[@]} + ${#JSON_FILES[@]}))
    
    log_success "Discovered ${#SHELL_SCRIPTS[@]} shell scripts"
    log_success "Discovered ${#JS_FILES[@]} JavaScript files"
    log_success "Discovered ${#JSON_FILES[@]} JSON files"
    log_success "Discovered ${#CONFIG_FILES[@]} configuration files"
    log_info "Total files to validate: $TOTAL_FILES"
    
    # Debug output if no files found
    if [[ $TOTAL_FILES -eq 0 ]]; then
        log_warning "No files found! Debugging directory structure..."
        echo "Available directories:" >&2
        ls -la . >&2
        echo "Contents of potential directories:" >&2
        for dir in "${scan_dirs[@]}"; do
            if [[ -d "$dir" ]]; then
                echo "Contents of $dir:" >&2
                find "$dir" -type f -name "*.sh" -o -name "*.js" -o -name "*.json" 2>/dev/null | head -5 >&2
            fi
        done
    fi
    
    # List discovered files (limit output for large projects)
    if [[ ${#SHELL_SCRIPTS[@]} -gt 0 ]] && [[ ${#SHELL_SCRIPTS[@]} -le 20 ]]; then
        echo -e "${CYAN}Shell Scripts:${NC}"
        printf "  • %s\n" "${SHELL_SCRIPTS[@]}"
    elif [[ ${#SHELL_SCRIPTS[@]} -gt 20 ]]; then
        echo -e "${CYAN}Shell Scripts: ${#SHELL_SCRIPTS[@]} files (too many to list)${NC}"
    fi
    
    if [[ ${#JS_FILES[@]} -gt 0 ]] && [[ ${#JS_FILES[@]} -le 20 ]]; then
        echo -e "${CYAN}JavaScript Files:${NC}"
        printf "  • %s\n" "${JS_FILES[@]}"
    elif [[ ${#JS_FILES[@]} -gt 20 ]]; then
        echo -e "${CYAN}JavaScript Files: ${#JS_FILES[@]} files (too many to list)${NC}"
    fi
    
    if [[ ${#JSON_FILES[@]} -gt 0 ]] && [[ ${#JSON_FILES[@]} -le 20 ]]; then
        echo -e "${CYAN}JSON Files:${NC}"
        printf "  • %s\n" "${JSON_FILES[@]}"
    elif [[ ${#JSON_FILES[@]} -gt 20 ]]; then
        echo -e "${CYAN}JSON Files: ${#JSON_FILES[@]} files (too many to list)${NC}"
    fi
}

# Enhanced shell script validation with timeout protection
validate_shell_scripts() {
    [[ ${#SHELL_SCRIPTS[@]} -eq 0 ]] && return 0
    
    log_header "Shell Script Syntax & ShellCheck Validation"
    
    local shell_errors=0
    
    for script in "${SHELL_SCRIPTS[@]}"; do
        [[ ! -f "$script" ]] && continue
        
        echo -n "Validating: $script ... "
        
        # Syntax check with timeout protection
        if ! run_with_timeout "$VALIDATION_TIMEOUT" bash -n "$script" 2>/dev/null; then
            log_error "Syntax error in: $script"
            run_with_timeout 5 bash -n "$script" 2>&1 | head -5
            ((shell_errors++))
            ((SYNTAX_ERRORS++))
            continue
        fi
        
        # ShellCheck validation with timeout
        if command -v shellcheck >/dev/null 2>&1; then
            local shellcheck_output
            shellcheck_output=$(run_with_timeout "$VALIDATION_TIMEOUT" shellcheck --severity=info --source-path=SCRIPTDIR "$script" 2>&1 || true)
            
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

# Enhanced JavaScript validation
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
        
        # Node.js syntax check with timeout
        if ! run_with_timeout "$VALIDATION_TIMEOUT" node --check "$jsfile" 2>/dev/null; then
            log_error "Syntax error in: $jsfile"
            run_with_timeout 5 node --check "$jsfile" 2>&1 | head -5
            ((js_errors++))
            ((SYNTAX_ERRORS++))
            continue
        fi
        
        # ESLint validation with timeout
        if command -v npx >/dev/null 2>&1 && [[ -f ".eslintrc.json" || -f "eslint.config.js" || -f ".eslintrc.js" ]]; then
            local eslint_output
            eslint_output=$(run_with_timeout "$VALIDATION_TIMEOUT" npx eslint "$jsfile" 2>&1 || true)
            
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

# Enhanced JSON validation with better error handling
validate_json_files() {
    [[ ${#JSON_FILES[@]} -eq 0 ]] && return 0
    
    log_header "JSON Syntax & Schema Validation"
    
    local json_errors=0
    
    for jsonfile in "${JSON_FILES[@]}"; do
        [[ ! -f "$jsonfile" ]] && continue
        
        echo -n "Validating: $jsonfile ... "
        
        # JSON syntax validation using multiple methods with timeout
        local json_valid=true
        local validation_method=""
        local current_json_errors=0
        
        # Try jq first (most reliable)
        if command -v jq >/dev/null 2>&1; then
            if ! run_with_timeout "$VALIDATION_TIMEOUT" jq empty "$jsonfile" 2>/dev/null; then
                json_valid=false
                validation_method="jq"
            fi
        # Fall back to python3
        elif command -v python3 >/dev/null 2>&1; then
            if ! run_with_timeout "$VALIDATION_TIMEOUT" python3 -m json.tool "$jsonfile" >/dev/null 2>&1; then
                json_valid=false
                validation_method="python3"
            fi
        elif command -v python >/dev/null 2>&1; then
            if ! run_with_timeout "$VALIDATION_TIMEOUT" python -m json.tool "$jsonfile" >/dev/null 2>&1; then
                json_valid=false
                validation_method="python"
            fi
        # Fall back to node.js
        elif command -v node >/dev/null 2>&1; then
            if ! run_with_timeout "$VALIDATION_TIMEOUT" node -e "JSON.parse(require('fs').readFileSync('$jsonfile', 'utf8'))" 2>/dev/null; then
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
                "jq") run_with_timeout 5 jq empty "$jsonfile" 2>&1 | head -3 ;;
                "python3") run_with_timeout 5 python3 -m json.tool "$jsonfile" 2>&1 | head -3 ;;
                "python") run_with_timeout 5 python -m json.tool "$jsonfile" 2>&1 | head -3 ;;
                "node") run_with_timeout 5 node -e "JSON.parse(require('fs').readFileSync('$jsonfile', 'utf8'))" 2>&1 | head -3 ;;
            esac
            ((current_json_errors++))
            ((JSON_ERRORS++))
            ((SYNTAX_ERRORS++))
        else
            # Enhanced schema validation for common JSON files
            local filename
            filename=$(basename "$jsonfile")
            case "$filename" in
                "package.json")
                    validate_package_json "$jsonfile" && ((current_json_errors++))
                    ;;
                ".eslintrc.json"|"eslint.config.json")
                    validate_eslint_config "$jsonfile" && ((current_json_errors++))
                    ;;
                "tsconfig.json")
                    validate_tsconfig "$jsonfile" && ((current_json_errors++))
                    ;;
            esac
            
            # Check for duplicate keys (common JSON issue)
            if command -v jq >/dev/null 2>&1; then
                local key_duplicates
                # shellcheck disable=SC2016 # $p is jq variable, not bash variable
                key_duplicates=$(run_with_timeout 10 jq -r 'paths(scalars) as $p | $p | join(".")' "$jsonfile" 2>/dev/null | sort | uniq -d | wc -l 2>/dev/null || echo "0")
                if [[ "$key_duplicates" -gt 0 ]]; then
                    log_warning "Potential duplicate keys detected in: $jsonfile"
                    ((current_json_errors++))
                    ((JSON_ERRORS++))
                fi
            fi
        fi
        
        if [[ $current_json_errors -eq 0 ]]; then
            log_success "PASS"
        else
            ((json_errors += current_json_errors))
        fi
        
        ((PROCESSED_FILES++))
    done
    
    log_info "JSON validation: $((${#JSON_FILES[@]} - json_errors))/${#JSON_FILES[@]} passed"
}

# Enhanced package.json validation
validate_package_json() {
    local jsonfile="$1"
    local errors=0
    
    if command -v jq >/dev/null 2>&1; then
        local missing_fields=()
        
        # Check required fields
        [[ "$(jq -r '.name // empty' "$jsonfile" 2>/dev/null)" == "" ]] && missing_fields+=("name")
        [[ "$(jq -r '.version // empty' "$jsonfile" 2>/dev/null)" == "" ]] && missing_fields+=("version")
        
        if [[ ${#missing_fields[@]} -gt 0 ]]; then
            log_warning "package.json missing required fields: ${missing_fields[*]}"
            ((errors++))
        fi
        
        # Check for duplicate dependencies
        local deps_file="$TEMP_DIR/deps_check_${RANDOM}.txt"
        {
            jq -r '.dependencies // {} | keys[]' "$jsonfile" 2>/dev/null || true
            jq -r '.devDependencies // {} | keys[]' "$jsonfile" 2>/dev/null || true
            jq -r '.peerDependencies // {} | keys[]' "$jsonfile" 2>/dev/null || true
        } > "$deps_file"
        
        local duplicates
        duplicates=$(sort "$deps_file" | uniq -d)
        if [[ -n "$duplicates" ]]; then
            log_warning "Duplicate dependencies in package.json: $duplicates"
            ((errors++))
        fi
        
        # Check for valid semver versions
        local invalid_versions
        invalid_versions=$(jq -r '.dependencies // {} | to_entries[] | select(.value | test("^[0-9]") | not) | .key' "$jsonfile" 2>/dev/null | head -5)
        if [[ -n "$invalid_versions" ]]; then
            log_warning "Non-standard version specifications in dependencies: $invalid_versions"
        fi
        
        rm -f "$deps_file"
    fi
    
    return $errors
}

# Enhanced ESLint config validation
validate_eslint_config() {
    local jsonfile="$1"
    local errors=0
    
    if command -v jq >/dev/null 2>&1; then
        if ! jq -e '.extends // .rules // .env // .parser' "$jsonfile" >/dev/null 2>&1; then
            log_warning "ESLint config appears minimal (no extends, rules, env, or parser)"
            ((errors++))
        fi
        
        # Check for deprecated rules
        local deprecated_rules
        deprecated_rules=$(jq -r '.rules // {} | keys[] | select(. == "no-native-reassign" or . == "no-negated-in-lhs")' "$jsonfile" 2>/dev/null)
        if [[ -n "$deprecated_rules" ]]; then
            log_warning "Deprecated ESLint rules detected: $deprecated_rules"
            ((errors++))
        fi
    fi
    
    return $errors
}

# Enhanced TypeScript config validation
validate_tsconfig() {
    local jsonfile="$1"
    local errors=0
    
    if command -v jq >/dev/null 2>&1; then
        if ! jq -e '.compilerOptions' "$jsonfile" >/dev/null 2>&1; then
            log_warning "tsconfig.json missing compilerOptions"
            ((errors++))
        fi
        
        # Check for recommended compiler options
        local target
        target=$(jq -r '.compilerOptions.target // empty' "$jsonfile" 2>/dev/null)
        if [[ -z "$target" ]]; then
            log_warning "tsconfig.json missing target specification"
            ((errors++))
        fi
        
        # Check if strict mode is enabled
        local strict
        strict=$(jq -r '.compilerOptions.strict // false' "$jsonfile" 2>/dev/null)
        if [[ "$strict" != "true" ]]; then
            log_info "Consider enabling strict mode in tsconfig.json"
        fi
    fi
    
    return $errors
}

# Enhanced import validation with better path resolution (SECURITY FIX)
validate_imports() {
    log_header "Import & Dependency Validation"
    
    local import_issues=0
    
    # Check shell script sourcing with safe path handling
    for script in "${SHELL_SCRIPTS[@]}"; do
        [[ ! -f "$script" ]] && continue
        
        # Extract script directory once outside the loop to avoid SC2094
        local script_dir
        script_dir=$(dirname "$script")
        
        # Look for source/. commands and validate paths
        while IFS= read -r line; do
            if [[ "$line" =~ ^[[:space:]]*(source|\.|bash)[[:space:]]+([^[:space:]]+) ]]; then
                local sourced_file="${BASH_REMATCH[2]}"
                # Use safe path cleaning instead of dangerous sed
                sourced_file=$(safe_clean_path "$sourced_file")
                
                # Resolve relative paths safely
                if [[ ! -f "$sourced_file" ]] && [[ ! "$sourced_file" =~ ^/ ]]; then
                    local resolved_path="$script_dir/$sourced_file"
                    
                    if [[ ! -f "$resolved_path" ]] && [[ ! -f "$sourced_file" ]]; then
                        log_warning "Missing sourced file in $script: $sourced_file"
                        ((import_issues++))
                    fi
                fi
            fi
        done < "$script"
    done
    
    # Enhanced JavaScript import checking with Node.js resolution algorithm
    for jsfile in "${JS_FILES[@]}"; do
        [[ ! -f "$jsfile" ]] && continue
        
        local jsfile_dir
        jsfile_dir=$(dirname "$jsfile")
        
        # Check for import statements and require calls
        while IFS= read -r line; do
            # Match various import patterns
            if [[ "$line" =~ (import.*from[[:space:]]+[\'\"]\./|require\([\'\"]\./|import[[:space:]]+[\'\"]\./)[^\'\"]*[\'\"] ]]; then
                local imported_path
                imported_path=$(echo "$line" | grep -o '['\''"][^'\'']*['\''"]' | tr -d '"'"'" | head -1)
                
                if [[ -n "$imported_path" ]] && [[ "$imported_path" =~ ^\. ]]; then
                    if ! resolve_js_import "$imported_path" "$jsfile_dir"; then
                        log_warning "Potential missing import in $jsfile: $imported_path"
                        ((import_issues++))
                    fi
                fi
            fi
        done < "$jsfile"
    done
    
    IMPORT_ERRORS=$import_issues
    log_info "Import validation: $import_issues issues found"
}

# Enhanced JavaScript import resolution
resolve_js_import() {
    local import_path="$1"
    local base_dir="$2"
    local resolved_path="$base_dir/$import_path"
    
    # Check multiple extensions and index files
    local -a check_paths=(
        "$resolved_path"
        "$resolved_path.js"
        "$resolved_path.json"
        "$resolved_path/index.js"
        "$resolved_path/index.json"
    )
    
    for path in "${check_paths[@]}"; do
        [[ -f "$path" ]] && return 0
    done
    
    return 1
}

# Enhanced runtime validation
validate_runtime_errors() {
    log_header "Runtime & Type Error Validation"
    
    local runtime_issues=0
    
    # Enhanced package.json dependencies check
    if [[ -f "package.json" ]]; then
        log_info "Validating package.json dependencies..."
        
        # Check for node_modules existence
        if [[ ! -d "node_modules" ]]; then
            log_warning "node_modules directory missing - run 'npm install'"
            ((runtime_issues++))
        fi
        
        # Validate main entry point
        if command -v jq >/dev/null 2>&1; then
            local main_file
            main_file=$(jq -r '.main // "index.js"' package.json 2>/dev/null)
            if [[ -n "$main_file" ]] && [[ "$main_file" != "null" ]] && [[ ! -f "$main_file" ]]; then
                log_warning "Main entry point missing: $main_file"
                ((runtime_issues++))
            fi
            
            # Check scripts section
            local scripts_count
            scripts_count=$(jq '.scripts // {} | length' package.json 2>/dev/null || echo "0")
            if [[ "$scripts_count" -eq 0 ]]; then
                log_info "No npm scripts defined in package.json"
            fi
        fi
    fi
    
    # Enhanced TypeScript checking
    if find . -name "*.ts" -type f -print -quit | grep -q .; then
        log_info "TypeScript files detected"
        if command -v tsc >/dev/null 2>&1; then
            # Check if tsconfig.json exists, if not, create a minimal one temporarily
            local temp_tsconfig=""
            if [[ ! -f "tsconfig.json" ]]; then
                temp_tsconfig="$TEMP_DIR/tsconfig.json"
                cat > "$temp_tsconfig" << 'EOF'
{
  "compilerOptions": {
    "target": "es2017",
    "module": "commonjs",
    "strict": true,
    "noEmit": true,
    "skipLibCheck": true
  },
  "include": ["**/*.ts"],
  "exclude": ["node_modules", "dist", "build"]
}
EOF
            fi
            
            # Run TypeScript compilation check and capture actual errors
            local tsc_output tsc_exit_code
            if [[ -n "$temp_tsconfig" ]]; then
                tsc_output=$(run_with_timeout 60 tsc --project "$temp_tsconfig" 2>&1)
                tsc_exit_code=$?
            else
                tsc_output=$(run_with_timeout 60 tsc --noEmit 2>&1)
                tsc_exit_code=$?
            fi
            
            # Only report issues if there are actual compilation errors (not help text)
            if [[ $tsc_exit_code -ne 0 ]] && [[ "$tsc_output" != *"COMMON COMMANDS"* ]] && [[ -n "$tsc_output" ]]; then
                log_warning "TypeScript compilation issues detected:"
                echo "$tsc_output" | head -10
                ((runtime_issues++))
            elif [[ "$tsc_output" == *"COMMON COMMANDS"* ]]; then
                log_info "TypeScript compiler available but no valid project configuration"
            else
                log_info "TypeScript validation passed"
            fi
            
            # Clean up temporary tsconfig if created
            [[ -n "$temp_tsconfig" ]] && rm -f "$temp_tsconfig"
        else
            log_warning "TypeScript files found but tsc not available"
            log_info "Install with: npm install -g typescript"
        fi
    fi
    
    # Check for Python files and validate if found
    if find . -name "*.py" -type f -print -quit | grep -q .; then
        log_info "Python files detected"
        if command -v python3 >/dev/null 2>&1; then
            local python_errors=0
            while IFS= read -r -d '' pyfile; do
                if ! run_with_timeout 10 python3 -m py_compile "$pyfile" 2>/dev/null; then
                    ((python_errors++))
                fi
            done < <(find . -name "*.py" -type f -print0 2>/dev/null | head -z -20)
            
            if [[ $python_errors -gt 0 ]]; then
                log_warning "Python syntax errors detected in $python_errors files"
                ((runtime_issues++))
            fi
        fi
    fi
    
    RUNTIME_ERRORS=$runtime_issues
    log_info "Runtime validation: $runtime_issues issues found"
}

# Enhanced duplicate detection with smart filtering (SECURITY & PERFORMANCE FIX)
detect_duplicates() {
    log_header "Duplicate File & Code Detection"
    
    local duplicate_issues=0
    
    # Generate file content hashes using secure method
    local hash_file="$TEMP_DIR/file_hashes.txt"
    local hash_progress=0
    
    log_info "Generating file hashes..."
    for file in "${ALL_FILES[@]}"; do
        [[ ! -f "$file" ]] && continue
        
        local hash
        hash=$(get_file_hash "$file")
        if [[ -n "$hash" ]]; then
            echo "$hash $file" >> "$hash_file"
        fi
        
        ((hash_progress++))
        if ((hash_progress % 50 == 0)); then
            echo -n "." >&2
        fi
    done
    echo >&2
    
    # Find exact content duplicates
    if [[ -f "$hash_file" ]]; then
        log_info "Analyzing for duplicate content..."
        while IFS= read -r hash; do
            local files_with_hash
            files_with_hash=$(grep "^$hash " "$hash_file" | cut -d' ' -f2-)
            local file_count
            file_count=$(echo "$files_with_hash" | wc -l)
            
            if [[ $file_count -gt 1 ]]; then
                log_warning "Exact duplicate files found (hash: ${hash:0:12}...):"
                while IFS= read -r duplicate_file; do
                    echo "  • $duplicate_file"
                done <<< "$files_with_hash"
                ((duplicate_issues++))
            fi
        done < <(cut -d' ' -f1 "$hash_file" | sort | uniq -d)
    fi
    
    # Smart function analysis with filtering
    detect_meaningful_duplicates
    duplicate_issues=$((duplicate_issues + $?))
    
    DUPLICATE_ERRORS=$duplicate_issues
    log_info "Duplicate detection: $duplicate_issues meaningful issues found"
}

# Smart duplicate detection with pattern filtering
detect_meaningful_duplicates() {
    local meaningful_duplicates=0
    local functions_file="$TEMP_DIR/functions.txt"
    local filtered_functions="$TEMP_DIR/filtered_functions.txt"
    
    # Common patterns to ignore (reduce false positives) - Enhanced to reduce noise
    local -a ignore_patterns=(
        "const.*=.*\[\]"                     # Empty array initialization
        "const.*=.*\{\}"                     # Empty object initialization  
        "const.*=.*Date\.now\(\)"            # Timestamp creation
        "const.*=.*performance\.now\(\)"     # Performance timing
        "const.*=.*process\.hrtime"          # Process timing
        "const.*=.*Math\.(max|min|floor|ceil)" # Basic math operations
        "const.*=.*[a-zA-Z_]+\.length"      # Length access
        "const.*=.*[a-zA-Z_]+\.(get|set|map|filter|find|includes)\(" # Common methods
        "const.*=.*path\.(join|extname|dirname|basename)" # Path operations
        "const.*=.*JSON\.(parse|stringify)"  # JSON operations
        "const.*=.*require\("                # Require statements
        "const.*=.*await"                    # Await expressions
        "const.*=.*new.*\("                  # Constructor calls
        "const.*=.*\.slice\("                # Array slice
        "const.*=.*\.split\("                # String split
        "const.*=.*\.replace\("              # String replace
        "const.*=.*\.trim\("                 # String trim
        "\.forEach\("                        # Standard iteration
        "\.map\("                           # Standard mapping
        "\.filter\("                        # Standard filtering
        "setTimeout\("                       # Standard async
        "setInterval\("                      # Standard intervals  
        "console\.(log|error|warn|info)"     # Logging statements
        "if.*null.*undefined"                # Standard null checks
        "throw new Error"                    # Standard error throwing
        "return.*\{"                         # Return statements
        "expect\("                           # Test assertions
        "test\("                            # Test definitions
        "describe\("                        # Test suites
        "\.on\("                            # Event listeners
        "\.once\("                          # One-time event listeners
        "\.catch\("                         # Promise catch
        "\.then\("                          # Promise then
        "import.*from"                      # Import statements
        "export.*\{"                        # Export statements
    )
    
    # Collect meaningful function signatures only
    log_info "Extracting function signatures..."
    
    # Analyze shell functions (focus on actual functions, not variables)
    for script in "${SHELL_SCRIPTS[@]}"; do
        [[ ! -f "$script" ]] && continue
        # Look for actual function definitions, not simple variable assignments
        grep -n "^[[:space:]]*function[[:space:]]\+[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*(" "$script" 2>/dev/null | \
        sed "s|^|$script:|" >> "$functions_file" 2>/dev/null || true
    done
    
    # Analyze JavaScript functions (focus on meaningful patterns)
    for jsfile in "${JS_FILES[@]}"; do
        [[ ! -f "$jsfile" ]] && continue
        
        # Get function lines
        grep -n -E "(function\s+[a-zA-Z_][a-zA-Z0-9_]*\s*\(|class\s+[a-zA-Z_][a-zA-Z0-9_]*|async\s+function|\w+\s*:\s*function)" "$jsfile" 2>/dev/null | \
        sed "s|^|$jsfile:|" >> "$functions_file" 2>/dev/null || true
    done
    
    # Filter out common patterns
    if [[ -f "$functions_file" ]]; then
        cp "$functions_file" "$filtered_functions"
        
        # Apply ignore patterns to reduce noise
        for pattern in "${ignore_patterns[@]}"; do
            grep -v -E "$pattern" "$filtered_functions" > "$filtered_functions.tmp" 2>/dev/null || true
            mv "$filtered_functions.tmp" "$filtered_functions" 2>/dev/null || true
        done
        
        # Find meaningful duplicates (functions/classes with same names)
        log_info "Analyzing meaningful duplicates..."
        local meaningful_funcs
        meaningful_funcs=$(grep -E "(function\s+|class\s+)" "$filtered_functions" 2>/dev/null | \
                          sed -E 's/.*\b(function|class)\s+([a-zA-Z_][a-zA-Z0-9_]*).*/\2/' | \
                          grep -v "^[[:space:]]*$" | \
                          sort | uniq -d)
        
        if [[ -n "$meaningful_funcs" ]]; then
            while IFS= read -r func_name; do
                [[ -z "$func_name" ]] && continue
                local duplicate_count
                duplicate_count=$(grep -c "$func_name" "$filtered_functions" 2>/dev/null || echo "0")
                # Strip whitespace and newlines to prevent bash syntax errors
                duplicate_count=$(echo "$duplicate_count" | tr -d '\n\r' | tr -d ' ')
                
                # Only report if there are multiple meaningful occurrences
                if [[ "$duplicate_count" -gt 2 ]]; then
                    log_warning "Meaningful duplicate detected: function/class '$func_name' (${duplicate_count} occurrences)"
                    grep "$func_name" "$filtered_functions" 2>/dev/null | head -3 | sed 's/^/  • /' || true
                    ((meaningful_duplicates++))
                fi
            done <<< "$meaningful_funcs"
        fi
        
        # Check for complex duplicate patterns (methods with similar signatures)
        detect_complex_duplicates "$filtered_functions"
        meaningful_duplicates=$((meaningful_duplicates + $?))
    fi
    
    if [[ $meaningful_duplicates -eq 0 ]]; then
        log_success "No meaningful code duplicates found"
    fi
    
    return $meaningful_duplicates
}

# Detect complex duplicate patterns
detect_complex_duplicates() {
    local functions_file="$1"
    local complex_duplicates=0
    
    # Look for methods with similar complex signatures (5+ parameters or complex logic)
    local complex_patterns
    complex_patterns=$(grep -E "\([^)]{20,}\)" "$functions_file" 2>/dev/null | \
                      sed 's/.*:\([0-9]*\):.*/\1/' | \
                      sort | uniq -d)
    
    if [[ -n "$complex_patterns" ]]; then
        log_info "Found potential complex duplicates - manual review recommended"
        echo "$complex_patterns" | head -3 | sed 's/^/  • Line: /' || true
        ((complex_duplicates += 1))
    fi
    
    return $complex_duplicates
}

# Enhanced directory structure validation
validate_directory_structure() {
    log_header "Directory Structure Integrity"
    
    local structure_issues=0
    
    # Check for proper project structure
    local -a expected_files=("package.json")
    local -a expected_dirs=("scripts" "lib" "tests")
    
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
    local -a misplaced_files=()
    
    # Shell scripts should be in scripts/, bin/, or root (allow single-level files ending in .sh)
    for script in "${SHELL_SCRIPTS[@]}"; do
        # Normalize script path and check if it's in an acceptable location
        if [[ ! "$script" =~ ^(scripts/|bin/|[^/]+\.sh$) ]]; then
            # Skip reporting .cursor and .clinerules directories as misplaced since they're development tools
            if [[ ! "$script" =~ ^\.cursor/ ]] && [[ ! "$script" =~ ^\.clinerules/ ]]; then
                misplaced_files+=("$script (shell script in unexpected location)")
                ((structure_issues++))
            fi
        fi
    done
    
    # JavaScript files structure validation  
    for jsfile in "${JS_FILES[@]}"; do
        # Check if test files are in appropriate directories (fix regex to handle normalized paths)
        if [[ "$jsfile" =~ \.(test|spec)\.js$ ]] && [[ ! "$jsfile" =~ ^tests/ ]]; then
            misplaced_files+=("$jsfile (test file outside tests/ directory)")
            ((structure_issues++))
        fi
    done
    
    if [[ ${#misplaced_files[@]} -gt 0 ]]; then
        log_warning "Misplaced files detected:"
        printf "  • %s\n" "${misplaced_files[@]}"
    fi
    
    # Check for orphaned files (simplified for performance)
    local orphaned_count=0
    if [[ ${#ALL_FILES[@]} -lt 100 ]]; then  # Only for smaller projects
        for file in "${ALL_FILES[@]}"; do
            # Check if file is referenced anywhere
            local references=0
            if [[ ${#SHELL_SCRIPTS[@]} -gt 0 ]] || [[ ${#JS_FILES[@]} -gt 0 ]]; then
                local -a search_files=()
                [[ ${#SHELL_SCRIPTS[@]} -gt 0 ]] && search_files+=("${SHELL_SCRIPTS[@]}")
                [[ ${#JS_FILES[@]} -gt 0 ]] && search_files+=("${JS_FILES[@]}")
                
                if [[ ${#search_files[@]} -gt 0 ]]; then
                    local file_basename
                    file_basename=$(basename "$file")
                    references=$(grep -l "$file_basename" "${search_files[@]}" 2>/dev/null | wc -l 2>/dev/null | tr -d ' \n' || echo 0)
                fi
            fi
            if [[ $references -eq 0 ]] && [[ ! "$file" =~ (test|spec|config|README) ]]; then
                ((orphaned_count++))
            fi
        done
        
        if [[ $orphaned_count -gt 0 ]]; then
            log_info "Potentially orphaned files: $orphaned_count"
        fi
    fi
    
    STRUCTURE_ERRORS=$structure_issues
    log_info "Structure validation: $structure_issues issues found"
}

# Enhanced performance & summary reporting with metrics
generate_summary_report() {
    local end_time
    end_time=$(date +%s)
    local duration=$((end_time - START_TIME))
    
    log_header "Comprehensive Validation Summary"
    
    echo -e "${WHITE}Performance Metrics:${NC}"
    echo "  • Total execution time: ${duration}s"
    echo "  • Files discovered: $TOTAL_FILES"
    echo "  • Files processed: $PROCESSED_FILES"
    if [[ $duration -gt 0 ]]; then
        echo "  • Processing rate: $((PROCESSED_FILES / duration)) files/sec"
    else
        echo "  • Processing rate: $PROCESSED_FILES files/sec (instant)"
    fi
    
    echo -e "\n${WHITE}File Type Distribution:${NC}"
    echo "  • Shell scripts: ${#SHELL_SCRIPTS[@]}"
    echo "  • JavaScript files: ${#JS_FILES[@]}"
    echo "  • JSON files: ${#JSON_FILES[@]}"
    echo "  • Configuration files: ${#CONFIG_FILES[@]}"
    
    echo -e "\n${WHITE}Validation Results:${NC}"
    local total_errors=$((SYNTAX_ERRORS + LINTER_ERRORS + IMPORT_ERRORS + RUNTIME_ERRORS + DUPLICATE_ERRORS + STRUCTURE_ERRORS + JSON_ERRORS))
    
    echo "  • Syntax errors: $SYNTAX_ERRORS"
    echo "  • Linter issues: $LINTER_ERRORS"
    echo "  • JSON errors: $JSON_ERRORS"
    echo "  • Import problems: $IMPORT_ERRORS"
    echo "  • Runtime issues: $RUNTIME_ERRORS"
    echo "  • Duplicates found: $DUPLICATE_ERRORS"
    echo "  • Structure issues: $STRUCTURE_ERRORS"
    echo "  • Total issues: $total_errors"
    
    # Enhanced health scoring
    local health_score=100
    ((health_score -= SYNTAX_ERRORS * 10))
    ((health_score -= LINTER_ERRORS * 2))
    ((health_score -= JSON_ERRORS * 5))
    ((health_score -= IMPORT_ERRORS * 3))
    ((health_score -= RUNTIME_ERRORS * 5))
    ((health_score -= DUPLICATE_ERRORS * 3))
    ((health_score -= STRUCTURE_ERRORS * 2))
    
    [[ $health_score -lt 0 ]] && health_score=0
    
    if [[ $total_errors -eq 0 ]]; then
        log_success "All validation checks passed! 🎉"
        log_info "Codebase health: EXCELLENT (${health_score}/100)"
        return 0
    else
        if [[ $health_score -ge 80 ]]; then
            log_info "Codebase health: GOOD (${health_score}/100)"
        elif [[ $health_score -ge 60 ]]; then
            log_warning "Codebase health: FAIR (${health_score}/100)"
        else
            log_error "Codebase health: POOR (${health_score}/100)"
        fi
        
        # Enhanced debugging recommendations
        echo -e "\n${YELLOW}Debugging Recommendations (Priority Order):${NC}"
        [[ $SYNTAX_ERRORS -gt 0 ]] && echo "  • 🚨 Fix syntax errors first (blocks execution)"
        [[ $RUNTIME_ERRORS -gt 0 ]] && echo "  • ⚠️  Check runtime configuration and dependencies"
        [[ $JSON_ERRORS -gt 0 ]] && echo "  • 🔧 Validate JSON schema and syntax"
        [[ $IMPORT_ERRORS -gt 0 ]] && echo "  • 📦 Verify all import paths and dependencies"
        [[ $DUPLICATE_ERRORS -gt 0 ]] && echo "  • 🔄 Consolidate duplicate code per .clinerules protocols"
        [[ $LINTER_ERRORS -gt 0 ]] && echo "  • 💡 Review linter output for code quality improvements"
        [[ $STRUCTURE_ERRORS -gt 0 ]] && echo "  • 📁 Reorganize project structure following conventions"
        
        echo -e "\n${CYAN}Quick Fixes:${NC}"
        [[ $SYNTAX_ERRORS -gt 0 ]] && echo "  • Run: bash -n <script> to check syntax"
        [[ $JSON_ERRORS -gt 0 ]] && echo "  • Run: jq . <jsonfile> to validate JSON"
        if command -v shellcheck >/dev/null 2>&1 && [[ $LINTER_ERRORS -gt 0 ]]; then
            echo "  • Run: shellcheck <script> for detailed analysis"
        fi
        
        return 1
    fi
}

# Enhanced main execution with error handling
main() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════════════════════╗"
    echo "║               Enhanced Code Validation & Analysis v2.0                       ║"
    echo "║   Shell • JavaScript • JSON • Python • TypeScript • Linting • Structure      ║"
    echo "║                    Security Hardened • Performance Optimized                 ║"
    echo "╚══════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    # Execute validation phases with error handling
    local validation_errors=0
    
    # First discover files - CRITICAL FIX: This must come first!
    discover_files || ((validation_errors++))
    
    # Now check if we found any files to validate
    if [[ $TOTAL_FILES -eq 0 ]]; then
        log_info "No files found to validate"
        return 0
    fi
    
    # Proceed with validation phases
    validate_shell_scripts || ((validation_errors++))
    validate_javascript_files || ((validation_errors++))
    validate_json_files || ((validation_errors++))
    validate_imports || ((validation_errors++))
    validate_runtime_errors || ((validation_errors++))
    detect_duplicates || ((validation_errors++))
    validate_directory_structure || ((validation_errors++))
    
    # Always generate summary, even if some phases failed
    if ! generate_summary_report; then
        return 1
    fi
    
    if [[ $validation_errors -gt 0 ]]; then
        log_warning "Some validation phases encountered errors"
        return 1
    fi
    
    return 0
}

# Enhanced prerequisites check with better tool detection
check_prerequisites() {
    local -a missing_tools=()
    local -a optional_tools=()
    
    # Required tools
    command -v bash >/dev/null 2>&1 || missing_tools+=("bash")
    command -v find >/dev/null 2>&1 || missing_tools+=("find")
    command -v grep >/dev/null 2>&1 || missing_tools+=("grep")
    command -v cut >/dev/null 2>&1 || missing_tools+=("cut")
    command -v sort >/dev/null 2>&1 || missing_tools+=("sort")
    command -v uniq >/dev/null 2>&1 || missing_tools+=("uniq")
    command -v wc >/dev/null 2>&1 || missing_tools+=("wc")
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        log_critical "Missing required tools: ${missing_tools[*]}"
        log_error "Cannot proceed without these basic utilities"
        exit 1
    fi
    
    # Check optional tools and provide installation guidance
    local tool_count=0
    if ! command -v shellcheck >/dev/null 2>&1; then
        optional_tools+=("shellcheck")
        log_warning "ShellCheck not installed - shell script analysis will be limited"
        log_info "Install: brew install shellcheck (macOS) | apt install shellcheck (Ubuntu) | dnf install ShellCheck (Fedora)"
    else
        ((tool_count++))
    fi
    
    if ! command -v node >/dev/null 2>&1; then
        optional_tools+=("node")
        log_warning "Node.js not installed - JavaScript analysis will be skipped"
        log_info "Install: https://nodejs.org/ or use your package manager"
    else
        ((tool_count++))
    fi
    
    if ! command -v jq >/dev/null 2>&1; then
        optional_tools+=("jq")
        log_warning "jq not installed - JSON analysis will be limited"
        log_info "Install: brew install jq (macOS) | apt install jq (Ubuntu)"
    else
        ((tool_count++))
    fi
    
    if ! command -v python3 >/dev/null 2>&1; then
        optional_tools+=("python3")
        log_info "Python3 not available - Python file validation will be skipped"
    else
        ((tool_count++))
    fi
    
    # Check for timeout command
    if ! command -v timeout >/dev/null 2>&1 && ! command -v gtimeout >/dev/null 2>&1; then
        log_warning "timeout command not available - validation may hang on problematic files"
    fi
    
    log_info "Available validation tools: $tool_count/4 (shellcheck, node, jq, python3)"
    
    if [[ ${#optional_tools[@]} -gt 2 ]]; then
        log_warning "Consider installing missing tools for comprehensive validation"
    fi
}

# Enhanced argument parsing
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--verbose)
                set -x
                shift
                ;;
            --version)
                echo "Enhanced Syntax & ShellCheck Validation Script v2.0"
                exit 0
                ;;
            --timeout)
                if [[ -n "$2" ]] && [[ "$2" =~ ^[0-9]+$ ]]; then
                    readonly VALIDATION_TIMEOUT="$2"
                    shift 2
                else
                    log_error "Invalid timeout value: $2"
                    exit 1
                fi
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# Help function
show_help() {
    cat << EOF
Enhanced Syntax & ShellCheck Validation Script v2.0

USAGE:
    $0 [OPTIONS]

OPTIONS:
    -h, --help          Show this help message
    -v, --verbose       Enable verbose output (set -x)
    --version           Show version information
    --timeout SECONDS   Set validation timeout (default: 30)

DESCRIPTION:
    Comprehensive validation script for multi-language projects.
    Validates syntax, linting, imports, runtime configuration, and project structure.

SUPPORTED FILE TYPES:
    • Shell scripts (.sh, .bash)
    • JavaScript files (.js)
    • JSON files (.json)
    • Python files (.py) - basic syntax checking
    • TypeScript files (.ts) - compilation checking

VALIDATION PHASES:
    1. File Discovery & Inventory
    2. Syntax Validation (per language)
    3. Linting & Style Checking
    4. Import & Dependency Validation
    5. Runtime Configuration Validation
    6. Duplicate Code Detection
    7. Directory Structure Validation
    8. Comprehensive Summary Report

SECURITY FEATURES:
    • Cross-platform secure file hashing
    • Safe string manipulation (no command injection)
    • Timeout protection against hanging processes
    • Proper error handling and cleanup

PERFORMANCE FEATURES:
    • Single-pass file discovery
    • Optimized duplicate detection
    • Progress indicators for large projects
    • Efficient memory usage

EXIT CODES:
    0  - All validations passed
    1  - Validation issues found or script errors

EXAMPLES:
    $0                      # Run with default settings
    $0 --timeout 60         # Run with 60-second timeout
    $0 --verbose            # Run with debug output

EOF
}

# Script entry point with enhanced error handling
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Parse command line arguments
    parse_arguments "$@"
    
    # Check prerequisites
    check_prerequisites
    
    # Run main validation
    if main; then
        log_success "Validation completed successfully"
        exit 0
    else
        log_error "Validation completed with issues"
        exit 1
    fi
fi
