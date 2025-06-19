#!/usr/bin/env bash
# 🔍 VS Code Settings Validation Script
# Uses jq to verify ShellCheck Docker configuration

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly PROJECT_ROOT
readonly SETTINGS_FILE="${PROJECT_ROOT}/.vscode/settings.json"

# Source professional console output library
# shellcheck source=../lib/console.sh disable=SC1091
source "${PROJECT_ROOT}/lib/console.sh" || {
    printf '[ERROR] Failed to source console.sh library\n' >&2
    exit 1
}

# Print header
print_header_validation() {
    print_header "${I_SEARCH} VS CODE SETTINGS VALIDATION SUITE" "ShellCheck Configuration"
    print_key_value "Settings File" "${SETTINGS_FILE}"
}

# Check if jq is available
check_jq() {
    if ! command -v jq &> /dev/null; then
        print_error "jq not found. Please install jq first."
        print_info "Install with: brew install jq"
        exit 1
    fi
    print_success "jq is available"
}

# Check if settings file exists
check_settings_file() {
    if [[ ! -f "$SETTINGS_FILE" ]]; then
        print_error "VS Code settings file not found: ${SETTINGS_FILE}"
        exit 1
    fi
    print_success "VS Code settings file found"
}

# Validate JSON syntax
validate_json_syntax() {
    print_info "Validating JSON syntax..."
    if jq empty "$SETTINGS_FILE" 2>/dev/null; then
        print_success "JSON syntax is valid"
    else
        print_error "Invalid JSON syntax in settings file"
        exit 1
    fi
}

# Extract and validate ShellCheck settings
validate_shellcheck_settings() {
    print_section "${I_GEAR} ShellCheck Configuration Validation"

    # Check if ShellCheck settings exist
    local shellcheck_keys
    shellcheck_keys=$(jq -r 'keys[] | select(startswith("shellcheck"))' "$SETTINGS_FILE" 2>/dev/null | wc -l)

    if [[ $shellcheck_keys -eq 0 ]]; then
        print_error "No ShellCheck settings found"
        exit 1
    fi

    print_success "Found ${shellcheck_keys} ShellCheck settings"
    printf "\n"

    # Validate critical settings
    validate_setting "shellcheck.enable" "boolean" "true"
    # shellcheck disable=SC2154
    validate_setting "shellcheck.executablePath" "string" "${PROJECT_ROOT}/shellcheck.sh"
    validate_setting "shellcheck.run" "string" "onType"
    validate_setting "shellcheck.enableQuickFix" "boolean" "true"
    validate_setting "shellcheck.useWorkspaceRootAsCwd" "boolean" "true"

    # Show all ShellCheck settings
    print_section "${I_FOLDER} All ShellCheck Settings"
    jq -r '
    to_entries
    | map(select(.key | startswith("shellcheck")))
    | map("   \(.key): \(.value)")
    | .[]
    ' "$SETTINGS_FILE"
}

# Validate individual setting
validate_setting() {
    local key="$1"
    local expected_type="$2"
    local expected_value="$3"

    local value
    value=$(jq -r ".\"$key\"" "$SETTINGS_FILE" 2>/dev/null)

    if [[ "$value" == "null" ]]; then
        print_error "Missing setting: ${key}"
        return 1
    fi

    local actual_type
    actual_type=$(jq -r ".\"$key\" | type" "$SETTINGS_FILE" 2>/dev/null)

    if [[ "$actual_type" != "$expected_type" ]]; then
        print_error "Wrong type for ${key}: expected ${expected_type}, got ${actual_type}"
        return 1
    fi

    if [[ "$value" == "$expected_value" ]]; then
        print_success "${key}: ${value}"
    else
        print_warning "${key}: ${value} (expected: ${expected_value})"
    fi
}

# Check Docker and ShellCheck shim
validate_docker_setup() {
    print_section "${I_DOCKER} Docker ShellCheck Setup Validation"

    # Check if shellcheck.sh exists
    local shellcheck_shim="${PROJECT_ROOT}/shellcheck.sh"
    if [[ -f "$shellcheck_shim" ]]; then
        print_success "ShellCheck Docker shim found: shellcheck.sh"

        # Check if executable
        if [[ -x "$shellcheck_shim" ]]; then
            print_success "ShellCheck shim is executable"
        else
            print_error "ShellCheck shim is not executable"
            print_info "Fix with: chmod +x shellcheck.sh"
        fi

        # Show shim content
        print_section "${I_FILE} ShellCheck Docker Shim Content"
        sed 's/^/   /' "$shellcheck_shim"
    else
        print_error "ShellCheck Docker shim not found: ${shellcheck_shim}"
    fi

    printf "\n"

    # Check Docker availability
    if command -v docker &> /dev/null; then
        print_success "Docker command available"

        if docker info &> /dev/null 2>&1; then
            print_success "Docker daemon running"
        else
            print_error "Docker daemon not running"
        fi
    else
        print_error "Docker not installed"
    fi
}

# Show step-by-step instructions
show_instructions() {
    print_section "${I_ROCKET} Step-by-Step Usage Instructions"

    print_list_item "Validate Configuration:" 0 "1."
    print_list_item "./scripts/validate-vscode-settings.sh" 1
    printf "\n"

    print_list_item "Test ShellCheck with Single Run:" 0 "2."
    print_list_item "./scripts/test-shellcheck-docker.sh" 1
    printf "\n"

    print_list_item "Enable Continuous Monitoring:" 0 "3."
    print_list_item "./scripts/test-shellcheck-docker.sh --continuous" 1
    printf "\n"

    print_list_item "Test VS Code Extension Features:" 0 "4."
    print_list_item "a) Open any .sh file in VS Code" 1
    print_list_item "b) Introduce syntax errors (missing quotes, etc.)" 1
    print_list_item "c) Observe real-time error highlighting" 1
    print_list_item "d) Click lightbulb icon (💡) for quick fixes" 1
    print_list_item "e) Save file to trigger auto-fix actions" 1
    printf "\n"

    print_list_item "Monitor Log Output:" 0 "5."
    print_list_item "tail -f shellcheck-test.log" 1
    printf "\n"

    print_section "${I_GEAR} Extension Features Demonstrated"
    print_list_item "Real-time linting (onType)" 0 "${I_CHECK}"
    print_list_item "Quick fixes (enableQuickFix)" 0 "${I_CHECK}"
    print_list_item "Code actions on save" 0 "${I_CHECK}"
    print_list_item "Docker integration" 0 "${I_CHECK}"
    print_list_item "Workspace awareness" 0 "${I_CHECK}"
    print_list_item "Ignore patterns for non-bash shells" 0 "${I_CHECK}"
}

# Generate jq validation commands
show_jq_commands() {
    print_section "${I_SEARCH} JQ Validation Commands"

    print_info "List all ShellCheck settings:"
    print_list_item "jq 'to_entries | map(select(.key | startswith(\"shellcheck\")))' .vscode/settings.json" 1
    printf "\n"

    print_info "Check specific setting:"
    print_list_item "jq '.\"shellcheck.executablePath\"' .vscode/settings.json" 1
    printf "\n"

    print_info "Validate settings format:"
    print_list_item "jq -r 'keys[] | select(startswith(\"shellcheck\"))' .vscode/settings.json" 1
    printf "\n"

    print_info "Check ignore patterns:"
    print_list_item "jq '.\"shellcheck.ignorePatterns\"' .vscode/settings.json" 1
}

# Main execution
main() {
    print_header_validation

    # Parse arguments
    case "${1:-}" in
        --jq-commands)
            show_jq_commands
            exit 0
            ;;
        --instructions)
            show_instructions
            exit 0
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  --jq-commands     Show JQ validation commands"
            echo "  --instructions    Show step-by-step instructions"
            echo "  --help           Show this help message"
            exit 0
            ;;
    esac

    # Run validations
    check_jq
    check_settings_file
    validate_json_syntax
    printf "\n"
    validate_shellcheck_settings
    printf "\n"
    validate_docker_setup
    printf "\n"
    show_instructions
    printf "\n"

    print_success "Validation Complete!"
    print_info "Use --jq-commands to see JQ validation examples"
    print_info "Use --instructions to see step-by-step usage guide"
}

# Run main function with all arguments
main "$@"
