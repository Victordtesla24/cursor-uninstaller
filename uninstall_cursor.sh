#!/bin/bash

################################################################################
# Cursor AI Editor Removal & Management Utility - Modular Version
# Consolidated Functional Domain Separation Architecture
################################################################################

# Script Self-Location & Robust Path Resolution
get_script_path() {
    # Special case for test environment
    if [[ "${BATS_TEST_SOURCED:-}" == "1" ]]; then
        if [[ "${CURSOR_TEST_SYMLINK_MODE:-}" == "true" ]] || [[ "${BASH_SOURCE[0]:-}" == *"symlink"* ]]; then
            if [[ -n "${SCRIPT_DIR:-}" ]]; then
                echo "$SCRIPT_DIR"
                return 0
            fi
            echo "$PWD"
            return 0
        elif [[ -n "${TEST_DIR:-}" ]]; then
            dirname "$TEST_DIR"
            return 0
        fi
    fi

    local SOURCE="${BASH_SOURCE[0]}"
    local DIR=""

    while [ -h "$SOURCE" ]; do
        DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
        SOURCE="$(readlink "$SOURCE")"
        [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
    done

    DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
    echo "$DIR"
}

# Store the script's directory path
SCRIPT_DIR="$(get_script_path)"

# Improved error handling with strict mode
set -Eeou pipefail
trap 'echo -e "\n[ERROR] An error occurred at line $LINENO, command: $BASH_COMMAND. Exiting." >&2; exit 1' ERR

################################################################################
# Module Loading System
################################################################################

# Load configuration first (contains constants and settings)
source "$SCRIPT_DIR/lib/config.sh"

# Load helper utilities
source "$SCRIPT_DIR/lib/helpers.sh"

# Load UI components
source "$SCRIPT_DIR/lib/ui.sh"

# Load functional modules
source "$SCRIPT_DIR/modules/installation.sh"
source "$SCRIPT_DIR/modules/optimization.sh"
source "$SCRIPT_DIR/modules/uninstall.sh"

# Load testing module
source "$SCRIPT_DIR/tests/helpers/test_functions.sh"

################################################################################
# Main Orchestration Functions
################################################################################

# Main function - orchestrates all operations
main() {
    # Initialize logging
    initialize_logging
    log_message "INFO" "Starting Cursor management utility (Consolidated Modular Version)"

    # Parse command line arguments
    parse_arguments "$@"

    # Validate system requirements
    validate_system_requirements || exit $?

    # Execute requested operation based on parsed arguments
    case "${OPERATION:-}" in
        "uninstall")
            confirm_uninstall_action || exit $?
            enhanced_uninstall_cursor
            ;;
        "install")
            confirm_installation_action || exit $?
            if [[ -n "${DMG_PATH:-}" ]]; then
                install_cursor_from_dmg "$DMG_PATH"
            else
                error_message "DMG path required for installation"
                exit "$ERR_INVALID_ARGS"
            fi
            ;;
        "optimize")
            enhanced_optimize_cursor_performance
            ;;
        "reset-performance")
            reset_performance_settings
            ;;
        "check")
            check_cursor_installation
            ;;
        "menu")
            enhanced_show_menu
            ;;
        "backup")
            handle_backup_operations
            ;;
        "test")
            run_tests
            ;;
        "health")
            perform_health_check
            ;;
        *)
            show_help
            exit "$ERR_INVALID_ARGS"
            ;;
    esac

    log_message "INFO" "Operation completed successfully"
}

# Handle backup-related operations
handle_backup_operations() {
    case "${BACKUP_OPERATION:-}" in
        "create")
            create_backup
            ;;
        "restore")
            restore_from_backup "${BACKUP_PATH:-}"
            ;;
        "list")
            list_backups
            ;;
        *)
            show_backup_menu
            ;;
    esac
}

# Argument parsing function
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -u|--uninstall)
                OPERATION="uninstall"
                shift
                ;;
            -i|--install)
                OPERATION="install"
                DMG_PATH="$2"
                shift 2
                ;;
            -o|--optimize)
                OPERATION="optimize"
                shift
                ;;
            -r|--reset-performance)
                OPERATION="reset-performance"
                shift
                ;;
            -c|--check)
                OPERATION="check"
                shift
                ;;
            -m|--menu)
                OPERATION="menu"
                shift
                ;;
            -b|--backup)
                OPERATION="backup"
                BACKUP_OPERATION="$2"
                shift 2
                ;;
            --backup-path)
                BACKUP_PATH="$2"
                shift 2
                ;;
            -t|--test)
                OPERATION="test"
                shift
                ;;
            --health)
                OPERATION="health"
                shift
                ;;
            --dry-run)
                DRY_RUN="true"
                shift
                ;;
            --verbose)
                VERBOSE="true"
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                error_message "Unknown argument: $1"
                show_help
                exit "$ERR_INVALID_ARGS"
                ;;
        esac
    done

    # Set default operation if none specified
    if [[ -z "${OPERATION:-}" ]]; then
        OPERATION="menu"
    fi
}

################################################################################
# Script Execution Entry Point
################################################################################

# Execute main function if script is run directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
