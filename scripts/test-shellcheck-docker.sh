#!/usr/bin/env bash
# 🐳 Comprehensive ShellCheck Docker Testing Script
# Tests all .sh files continuously with Docker-based ShellCheck
# Shows all extension features and functionality

set -euo pipefail

# Configuration
readonly DOCKER_IMAGE="koalaman/shellcheck:latest"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly PROJECT_ROOT

LOGFILE="${PROJECT_ROOT}/shellcheck-test.log"
readonly LOGFILE

# Source professional console output library
# shellcheck source=../lib/console.sh disable=SC1091
source "${PROJECT_ROOT}/lib/console.sh" || {
    printf '[ERROR] Failed to source console.sh library\n' >&2
    exit 1
}

# Global variables
declare -a SHELL_FILES=()
# Note: Docker availability is checked dynamically; no need for a separate flag
CONTINUOUS_MODE=false

# Signal handling for clean exit
cleanup() {
    printf "\n"
    print_warning "Cleaning up Docker containers..."
    docker ps -q --filter "ancestor=${DOCKER_IMAGE}" | xargs -r docker stop >/dev/null 2>&1 || true
    docker ps -aq --filter "ancestor=${DOCKER_IMAGE}" | xargs -r docker rm >/dev/null 2>&1 || true
    print_success "Cleanup complete"
    exit 0
}

trap cleanup SIGINT SIGTERM

# Print header
print_header_docker() {
    clear
    print_header "${I_DOCKER} SHELLCHECK DOCKER TESTING SUITE" "Continuous Monitoring"
    print_key_value "Project Root" "${PROJECT_ROOT}"
    print_key_value "Docker Image" "${DOCKER_IMAGE}"
    print_key_value "Log File" "${LOGFILE}"
}

# Check Docker availability
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker not found. Please install Docker first."
        exit 1
    fi

    if ! docker info &> /dev/null; then
        print_error "Docker daemon not running. Please start Docker."
        exit 1
    fi

    print_success "Docker is available and running"
}

# Pull latest ShellCheck image
pull_shellcheck_image() {
    print_info "Pulling latest ShellCheck Docker image..."
    if docker pull "${DOCKER_IMAGE}" &> /dev/null; then
        print_success "ShellCheck image updated"
    else
        print_warning "Using existing ShellCheck image"
    fi
}

# Find all shell scripts in the project
discover_shell_files() {
    print_info "Discovering shell scripts..."

    # Find all .sh files recursively, excluding hidden directories
    while IFS= read -r -d '' file; do
        SHELL_FILES+=("$file")
    done < <(find "${PROJECT_ROOT}" -name "*.sh" -type f ! -path "*/.*" -print0)

    if [[ ${#SHELL_FILES[@]} -eq 0 ]]; then
        print_error "No shell scripts found in project"
        exit 1
    fi

    print_success "Found ${#SHELL_FILES[@]} shell scripts:"
    for file in "${SHELL_FILES[@]}"; do
        local relative_path="${file#"${PROJECT_ROOT}/"}"
        print_list_item "${relative_path}" 1 "${I_FILE}"
    done
    printf "\n"
}

# Run ShellCheck on a single file using Docker
shellcheck_file() {
    local file="$1"
    local relative_path="${file#"${PROJECT_ROOT}/"}"

    printf "%s%s %s\n" "$C_INFO" "$I_SEARCH" "Checking: ${relative_path}$C_RESET"

    # Run ShellCheck with comprehensive options
    local output
    local exit_code

    if output=$(docker run --rm -i \
        -v "${PROJECT_ROOT}:/mnt:ro" \
        "${DOCKER_IMAGE}" \
        --format=gcc \
        --shell=bash \
        --severity=style \
        --enable=all \
        "/mnt/${relative_path}" 2>&1); then
        exit_code=0
    else
        exit_code=$?
    fi

    if [[ $exit_code -eq 0 && -z "$output" ]]; then
        printf "   %s%s %s%s\n" "$C_SUCCESS" "$I_SUCCESS" "No issues found" "$C_RESET"
        echo "$(date): ${relative_path} - PASSED" >> "${LOGFILE}"
    else
        printf "   %s%s %s%s\n" "$C_ERROR" "$I_ERROR" "Issues found:" "$C_RESET"
        echo "$output" | while IFS= read -r line; do
            printf "   %s   %s%s\n" "$C_ERROR" "$line" "$C_RESET"
        done
        echo "$(date): ${relative_path} - FAILED" >> "${LOGFILE}"
        echo "$output" >> "${LOGFILE}"
    fi
    printf "\n"
}

# Run ShellCheck on all discovered files
run_shellcheck_batch() {
    print_section "${I_ROCKET} Running ShellCheck on all files"

    local total_files=${#SHELL_FILES[@]}
    local current=0

    for file in "${SHELL_FILES[@]}"; do
        ((current++))
        print_progress "$current" "$total_files" "Processing files..."
        clear_line
        shellcheck_file "$file"
    done

    print_success "Batch analysis complete!"
    printf "\n"
}

# Show ShellCheck extension features
show_extension_features() {
    print_section "${I_GEAR} ShellCheck VS Code Extension Features"

    print_list_item "Real-time Linting: Issues highlighted as you type" 0 "${I_CHECK}"
    print_list_item "Quick Fixes: Click lightbulb icon for automated fixes" 0 "${I_CHECK}"
    print_list_item "Code Actions: Save files to trigger auto-fix actions" 0 "${I_CHECK}"
    print_list_item "Docker Integration: Consistent analysis via containerized ShellCheck" 0 "${I_CHECK}"
    print_list_item "Workspace Awareness: Respects project root for relative paths" 0 "${I_CHECK}"
    print_list_item "Ignore Patterns: Excludes non-bash shells (fish, zsh, etc.)" 0 "${I_CHECK}"

    printf "\n"
    print_section "${I_ROCKET} To test features"
    print_list_item "Open any .sh file in VS Code" 0 "1."
    print_list_item "Introduce syntax errors to see real-time highlighting" 0 "2."
    print_list_item "Use lightbulb icon (💡) for quick fixes" 0 "3."
    print_list_item "Save files to trigger automatic fixes" 0 "4."
    printf "\n"
}

# Continuous monitoring mode
continuous_monitoring() {
    if ! command -v fswatch &> /dev/null; then
        print_warning "fswatch not available. Install with: brew install fswatch"
        print_info "Running in polling mode instead..."
        polling_mode
        return
    fi

    print_success "Starting continuous monitoring..."
    print_key_value "Watching" "${PROJECT_ROOT}"
    print_info "Press Ctrl+C to stop"
    printf "\n"

    # Initial run
    run_shellcheck_batch

    # Monitor file changes
    fswatch -0 -r --event Created --event Updated --event MovedTo \
        --include='\.sh$' "${PROJECT_ROOT}" | \
    while IFS= read -r -d '' file; do
        if [[ "$file" == *.sh ]]; then
            print_info "File changed: ${file#"${PROJECT_ROOT}/"}"
            shellcheck_file "$file"
        fi
    done
}

# Polling mode fallback
polling_mode() {
    print_success "Starting polling mode..."
    print_info "Press Ctrl+C to stop"
    printf "\n"

    local last_check=0

    while true; do
        local current_time
        current_time=$(date +%s)
        local need_check=false

        for file in "${SHELL_FILES[@]}"; do
            if [[ "$file" -nt "$last_check" ]]; then
                need_check=true
                break
            fi
        done

        if [[ $need_check == true ]]; then
            print_info "Changes detected, re-running analysis..."
            run_shellcheck_batch
            last_check=$current_time
        fi

        sleep 5
    done
}

# Main execution
main() {
    print_header_docker

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -c|--continuous)
                CONTINUOUS_MODE=true
                shift
                ;;
            -h|--help)
                echo "Usage: $0 [OPTIONS]"
                echo "Options:"
                echo "  -c, --continuous    Enable continuous monitoring"
                echo "  -h, --help         Show this help message"
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                exit 1
                ;;
        esac
    done

    # Initialize log file
    echo "$(date): ShellCheck testing session started" > "${LOGFILE}"

    # Run checks
    check_docker
    pull_shellcheck_image
    discover_shell_files
    show_extension_features

    if [[ $CONTINUOUS_MODE == true ]]; then
        continuous_monitoring
    else
        run_shellcheck_batch
        print_info "Tip: Use -c or --continuous for continuous monitoring"
    fi
}

# Run main function with all arguments
main "$@"
