#!/bin/bash

################################################################################
# UI Module - Option 1: Functional Domain Separation
# Contains user interface, progress tracking, and interactive components
################################################################################

# Prevent multiple loading
if [[ "${UI_LOADED:-}" == "true" ]]; then
    return 0
fi

################################################################################
# Progress Tracking and Status Display
################################################################################

# Update progress display with spinner animation
update_status() {
    if [[ "$QUIET" == "true" ]]; then
        return 0
    fi

    local spinner_chars="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
    local spinner_index=$((CURRENT_PROGRESS % ${#spinner_chars}))
    local spinner_char="${spinner_chars:$spinner_index:1}"

    # Calculate percentage
    local percentage=0
    if [[ "$TOTAL_TASKS" -gt 0 ]]; then
        percentage=$(( (CURRENT_PROGRESS * 100) / TOTAL_TASKS ))
    fi

    # Create progress bar
    local bar_width=30
    local filled=$(( (percentage * bar_width) / 100 ))
    local empty=$((bar_width - filled))

    local progress_bar=""
    for ((i=0; i<filled; i++)); do
        progress_bar+="█"
    done
    for ((i=0; i<empty; i++)); do
        progress_bar+="░"
    done

    # Display status line
    printf "\r${BLUE}%s${NC} [%s] %3d%% %s" "$spinner_char" "$progress_bar" "$percentage" "$CURRENT_TASK"
}

# Initialize progress tracking
init_progress() {
    local total="$1"
    TOTAL_TASKS="$total"
    CURRENT_PROGRESS=0
    CURRENT_TASK="Initializing..."

    if [[ "$QUIET" != "true" ]]; then
        echo -e "\n${BOLD}Starting operation with $total tasks...${NC}"
    fi
}

# Complete progress tracking
complete_progress() {
    CURRENT_PROGRESS="$TOTAL_TASKS"
    update_status

    if [[ "$QUIET" != "true" ]]; then
        echo -e "\n${GREEN}${BOLD}✓ Operation completed successfully${NC}\n"
    fi
}

# Enhanced task runner with progress updates
run_task() {
    CURRENT_TASK="$1"
    shift
    local cmd="$*"

    log_message "DEBUG" "Starting task: $CURRENT_TASK"

    # Execute in background with progress updates
    (eval "$cmd" || true) > /dev/null 2>&1 &
    local pid=$!

    # Show progress while task runs
    while kill -0 "$pid" 2>/dev/null; do
        update_status
        sleep 0.1
    done

    # Wait for completion and get exit code
    wait "$pid"
    local exit_code=$?

    CURRENT_PROGRESS=$((CURRENT_PROGRESS + 1))
    update_status
    sleep 0.2

    log_message "DEBUG" "Completed task: $CURRENT_TASK (exit code: $exit_code)"
    return 0  # Always return success for UI purposes
}

################################################################################
# Menu Systems and User Interaction
################################################################################

# Enhanced main menu with better formatting
enhanced_show_menu() {
    clear
    echo -e "${BOLD}${BLUE}╔═════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${BLUE}║                                            ${WHITE}Cursor AI Editor Manager${BLUE}                                                                      ║${NC}"
    echo -e "${BOLD}${BLUE}║                                        ${CYAN}Enhanced Version ${SCRIPT_VERSION}${BLUE}                                                                 ║${NC}"
    echo -e "${BOLD}${BLUE}╠═════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${BOLD}${BLUE}║                                                                                                                                                         ║${NC}"
    echo -e "${BOLD}${BLUE}║                                                                                                                                                         ║${NC}"
    # System information section
    echo -e "${BOLD}${BLUE}║  ${YELLOW}System Information:${BLUE}                                                                                                                    ║${NC}"
    echo -e "${BOLD}${BLUE}║    macOS: ${WHITE}$MACOS_VERSION${BLUE} | Architecture: ${WHITE}$HARDWARE_ARCH${BLUE}$(printf "%*s" $((17 - ${#MACOS_VERSION} - ${#HARDWARE_ARCH})) "") ║${NC}"
    echo -e "${BOLD}${BLUE}║                                                                                                                                                         ║${NC}"
    # Cursor installation status
    local cursor_status
    if detect_cursor_paths >/dev/null 2>&1; then
        cursor_status="${GREEN}Installed${BLUE}"
    else
        cursor_status="${RED}Not Found${BLUE}"
    fi
    echo -e "${BOLD}${BLUE}║    Cursor Status: $cursor_status$(printf "%*s" $((39 - 10)) "")                                                                                         ║${NC}"
    echo -e "${BOLD}${BLUE}║                                                                                                                                                         ║${NC}"
    echo -e "${BOLD}${BLUE}║                                                                                                                                                         ║${NC}"
    echo -e "${BOLD}${BLUE}╠═════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${BOLD}${BLUE}║  ${WHITE}Main Operations:${BLUE}                                                                                                                        ║${NC}"
    echo -e "${BOLD}${BLUE}║                                                                                                                                                         ║${NC}"
    echo -e "${BOLD}${BLUE}║    ${YELLOW}1.${NC} ${WHITE}Complete Uninstall${BLUE}     - Remove all Cursor files                                                                     ║${NC}"
    echo -e "${BOLD}${BLUE}║    ${YELLOW}2.${NC} ${WHITE}Install from DMG${BLUE}       - Install Cursor from DMG file                                                                ║${NC}"
    echo -e "${BOLD}${BLUE}║    ${YELLOW}3.${NC} ${WHITE}Optimize Performance${BLUE}   - Enhance system performance                                                                  ║${NC}"
    echo -e "${BOLD}${BLUE}║    ${YELLOW}4.${NC} ${WHITE}Reset Performance${BLUE}      - Reset optimization settings                                                                 ║${NC}"
    echo -e "${BOLD}${BLUE}║    ${YELLOW}5.${NC} ${WHITE}Check Installation${BLUE}     - Verify Cursor installation                                                                  ║${NC}"
    echo -e "${BOLD}${BLUE}║                                                                                                                                                         ║${NC}"
    echo -e "${BOLD}${BLUE}╠═════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${BOLD}${BLUE}║  ${WHITE}Management:${BLUE}                                                                                                                             ║${NC}"
    echo -e "${BOLD}${BLUE}║                                                                                                                                                         ║${NC}"
    echo -e "${BOLD}${BLUE}║    ${YELLOW}6.${NC} ${WHITE}Backup Management${BLUE}      - Create and manage backups                                                                   ║${NC}"
    echo -e "${BOLD}${BLUE}║    ${YELLOW}7.${NC} ${WHITE}Configuration${BLUE}          - View and edit settings                                                                      ║${NC}"
    echo -e "${BOLD}${BLUE}║    ${YELLOW}8.${NC} ${WHITE}Logs & Metrics${BLUE}         - View system logs and metrics                                                                ║${NC}"
    echo -e "${BOLD}${BLUE}║    ${YELLOW}9.${NC} ${WHITE}System Health Check${BLUE}    - Comprehensive system analysis                                                               ║${NC}"
    echo -e "${BOLD}${BLUE}║                                                                                                                                                         ║${NC}"
    echo -e "${BOLD}${BLUE}╠═════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${BOLD}${BLUE}║  ${WHITE}Testing & Help:${BLUE}                                                                                                                         ║${NC}"
    echo -e "${BOLD}${BLUE}║                                                                                                                                                         ║${NC}"
    echo -e "${BOLD}${BLUE}║    ${YELLOW}t.${NC} ${WHITE}Run Tests${BLUE}              - Execute comprehensive tests                                                                 ║${NC}"
    echo -e "${BOLD}${BLUE}║    ${YELLOW}h.${NC} ${WHITE}Help${BLUE}                   - Show detailed help information                                                              ║${NC}"
    echo -e "${BOLD}${BLUE}║    ${YELLOW}q.${NC} ${WHITE}Quit${BLUE}                   - Exit the program                                                                            ║${NC}"
    echo -e "${BOLD}${BLUE}║                                                                                                                                                         ║${NC}"
    echo -e "${BOLD}${BLUE}╚═════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    # Get user choice
    echo -e "${BOLD}${WHITE}Enter your choice: ${NC}"
    read -r choice

    case "$choice" in
        1)
            if get_confirmation "This will completely remove Cursor from your system."; then
                enhanced_uninstall_cursor
            fi
            ;;
        2)
            echo -e "\n${BOLD}Enter path to Cursor DMG file:${NC}"
            read -r dmg_path
            if [[ -f "$dmg_path" ]]; then
                install_cursor_from_dmg "$dmg_path"
            else
                error_message "DMG file not found: $dmg_path"
            fi
            ;;
        3)
            enhanced_optimize_cursor_performance
            ;;
        4)
            if get_confirmation "This will reset all performance optimizations."; then
                reset_performance_settings
            fi
            ;;
        5)
            check_cursor_installation
            ;;
        6)
            show_backup_menu
            ;;
        7)
            show_configuration_menu
            ;;
        8)
            show_logs_and_metrics
            ;;
        9)
            perform_health_check
            ;;
        [Tt])
            run_tests
            ;;
        [Hh])
            show_help
            ;;
        [Qq])
            echo -e "\n${GREEN}Thank you for using Cursor Manager!${NC}"
            exit 0
            ;;
        *)
            error_message "Invalid choice: $choice"
            ;;
    esac

    # Return to menu unless exiting
    echo -e "\n${BOLD}Press Enter to return to menu...${NC}"
    read -r
    enhanced_show_menu
}

# Backup management menu
show_backup_menu() {
    clear
    echo -e "${BOLD}${CYAN}╔═══════════════════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${CYAN}║                     ${WHITE}Backup Management${CYAN}                                          ║${NC}"
    echo -e "${BOLD}${CYAN}╠═══════════════════════════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${BOLD}${CYAN}║                                                                                               ║${NC}"
    echo -e "${BOLD}${CYAN}║    ${YELLOW}1.${NC} ${WHITE}Create New Backup${CYAN}      - Create backup of current setup    ║${NC}"
    echo -e "${BOLD}${CYAN}║    ${YELLOW}2.${NC} ${WHITE}Restore from Backup${CYAN}    - Restore from existing backup      ║${NC}"
    echo -e "${BOLD}${CYAN}║    ${YELLOW}3.${NC} ${WHITE}List Backups${CYAN}           - Show all available backups        ║${NC}"
    echo -e "${BOLD}${CYAN}║    ${YELLOW}4.${NC} ${WHITE}Configure Backup${CYAN}       - Backup settings and retention     ║${NC}"
    echo -e "${BOLD}${CYAN}║    ${YELLOW}5.${NC} ${WHITE}Back to Main Menu${CYAN}      - Return to main menu               ║${NC}"
    echo -e "${BOLD}${CYAN}║                                                                                               ║${NC}"
    echo -e "${BOLD}${CYAN}╚═══════════════════════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    echo -e "${BOLD}${WHITE}Enter your choice: ${NC}"
    read -r backup_choice

    case "$backup_choice" in
        1)
            create_backup
            ;;
        2)
            echo -e "\n${BOLD}Enter backup name or path:${NC}"
            read -r backup_path
            restore_from_backup "$backup_path"
            ;;
        3)
            list_backups
            ;;
        4)
            configure_backup_settings
            ;;
        5)
            return
            ;;
        *)
            error_message "Invalid choice: $backup_choice"
            ;;
    esac
}

# Configuration menu
show_configuration_menu() {
    clear
    echo -e "${BOLD}${MAGENTA}╔════════════════════════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${MAGENTA}║                           ${WHITE}Configuration Manager${MAGENTA}                                  ║${NC}"
    echo -e "${BOLD}${MAGENTA}╠════════════════════════════════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${BOLD}${MAGENTA}║                                                                                                    ║${NC}"
    echo -e "${BOLD}${MAGENTA}║    ${YELLOW}1.${NC} ${WHITE}View Configuration${MAGENTA}     - Display current settings            ║${NC}"
    echo -e "${BOLD}${MAGENTA}║    ${YELLOW}2.${NC} ${WHITE}Edit Configuration${MAGENTA}     - Modify configuration file           ║${NC}"
    echo -e "${BOLD}${MAGENTA}║    ${YELLOW}3.${NC} ${WHITE}Reset to Defaults${MAGENTA}      - Restore default settings            ║${NC}"
    echo -e "${BOLD}${MAGENTA}║    ${YELLOW}4.${NC} ${WHITE}Export Configuration${MAGENTA}   - Save configuration to file          ║${NC}"
    echo -e "${BOLD}${MAGENTA}║    ${YELLOW}5.${NC} ${WHITE}Import Configuration${MAGENTA}   - Load configuration from file        ║${NC}"
    echo -e "${BOLD}${MAGENTA}║    ${YELLOW}6.${NC} ${WHITE}Back to Main Menu${MAGENTA}      - Return to main menu                 ║${NC}"
    echo -e "${BOLD}${MAGENTA}║                                                                                                    ║${NC}"
    echo -e "${BOLD}${MAGENTA}╚════════════════════════════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    echo -e "${BOLD}${WHITE}Enter your choice: ${NC}"
    read -r config_choice

    case "$config_choice" in
        1)
            view_configuration
            ;;
        2)
            edit_configuration
            ;;
        3)
            if get_confirmation "This will reset all settings to defaults."; then
                reset_configuration
            fi
            ;;
        4)
            export_configuration
            ;;
        5)
            import_configuration
            ;;
        6)
            return
            ;;
        *)
            error_message "Invalid choice: $config_choice"
            ;;
    esac
}

# Logs and metrics menu
show_logs_and_metrics() {
    clear
    echo -e "${BOLD}${GREEN}╔════════════════════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${GREEN}║                          ${WHITE}Logs & Metrics Viewer${GREEN}                                 ║${NC}"
    echo -e "${BOLD}${GREEN}╠════════════════════════════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${BOLD}${GREEN}║                                                                                                ║${NC}"
    echo -e "${BOLD}${GREEN}║    ${YELLOW}1.${NC} ${WHITE}View Recent Logs${GREEN}       - Show latest log entries           ║${NC}"
    echo -e "${BOLD}${GREEN}║    ${YELLOW}2.${NC} ${WHITE}View System Metrics${GREEN}    - Display performance metrics       ║${NC}"
    echo -e "${BOLD}${GREEN}║    ${YELLOW}3.${NC} ${WHITE}View Error Log${GREEN}         - Show error log entries            ║${NC}"
    echo -e "${BOLD}${GREEN}║    ${YELLOW}4.${NC} ${WHITE}Clear All Logs${GREEN}         - Remove all log files              ║${NC}"
    echo -e "${BOLD}${GREEN}║    ${YELLOW}5.${NC} ${WHITE}Export Logs${GREEN}            - Save logs to archive              ║${NC}"
    echo -e "${BOLD}${GREEN}║    ${YELLOW}6.${NC} ${WHITE}Back to Main Menu${GREEN}      - Return to main menu               ║${NC}"
    echo -e "${BOLD}${GREEN}║                                                                                                ║${NC}"
    echo -e "${BOLD}${GREEN}╚════════════════════════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    echo -e "${BOLD}${WHITE}Enter your choice: ${NC}"
    read -r logs_choice

    case "$logs_choice" in
        1)
            view_recent_logs
            ;;
        2)
            view_system_metrics
            ;;
        3)
            view_error_log
            ;;
        4)
            if get_confirmation "This will delete all log files."; then
                clear_all_logs
            fi
            ;;
        5)
            export_logs
            ;;
        6)
            return
            ;;
        *)
            error_message "Invalid choice: $logs_choice"
            ;;
    esac
}

################################################################################
# Confirmation and Input Functions
################################################################################

# Confirm uninstall action with detailed information
confirm_uninstall_action() {
    echo -e "\n${YELLOW}${BOLD}⚠️  COMPLETE CURSOR UNINSTALL CONFIRMATION${NC}"
    echo -e "${BOLD}═════════════════════════════════════════════════════${NC}\n"

    echo -e "${BOLD}This operation will:${NC}"
    echo -e "  ${RED}•${NC} Remove the Cursor application"
    echo -e "  ${RED}•${NC} Delete all user settings and preferences"
    echo -e "  ${RED}•${NC} Clear application caches and logs"
    echo -e "  ${RED}•${NC} Remove saved application state"
    echo -e "  ${RED}•${NC} Clean system databases and registrations"
    echo ""

    # Show what will be removed
    if detect_cursor_paths >/dev/null 2>&1; then
        echo -e "${BOLD}Files and directories to be removed:${NC}"
        local cursor_paths=(
            "$CURSOR_APP"
            "$CURSOR_SUPPORT"
            "$CURSOR_CACHE"
            "$CURSOR_PREFERENCES"
            "$CURSOR_SAVED_STATE"
            "$CURSOR_LOGS"
            "$CURSOR_WEBSTORAGE"
        )

        for path in "${cursor_paths[@]}"; do
            if [[ -e "$path" ]]; then
                local size
                size=$(get_file_size "$path")
                echo -e "  ${BLUE}•${NC} $path ${CYAN}($size)${NC}"
            fi
        done
        echo ""
    fi

    echo -e "${YELLOW}${BOLD}This action cannot be undone without a backup.${NC}"
    echo -e "${BOLD}Do you want to create a backup before uninstalling? (Y/n):${NC}"
    read -r backup_response

    case "$backup_response" in
        [Nn]|[Nn][Oo])
            ;;
        *)
            echo -e "\n${BLUE}Creating backup before uninstall...${NC}"
            if ! create_backup; then
                echo -e "${YELLOW}Backup failed, but continuing with uninstall...${NC}"
            fi
            ;;
    esac

    echo -e "\n${RED}${BOLD}Are you absolutely sure you want to proceed? (yes/no):${NC}"
    read -r final_confirm

    case "$final_confirm" in
        [Yy][Ee][Ss])
            log_message "INFO" "User confirmed complete uninstall"
            return 0
            ;;
        *)
            log_message "INFO" "User cancelled uninstall"
            echo -e "\n${GREEN}Uninstall cancelled.${NC}"
            return 1
            ;;
    esac
}

# Confirm installation action
confirm_installation_action() {
    echo -e "\n${BLUE}${BOLD}📦 CURSOR INSTALLATION CONFIRMATION${NC}"
    echo -e "${BOLD}════════════════════════════════════════════${NC}\n"

    echo -e "${BOLD}This operation will:${NC}"
    echo -e "  ${GREEN}•${NC} Mount and verify the DMG file"
    echo -e "  ${GREEN}•${NC} Install Cursor application"
    echo -e "  ${GREEN}•${NC} Set up default configurations"
    echo -e "  ${GREEN}•${NC} Configure system optimizations"
    echo -e "  ${GREEN}•${NC} Create project templates"
    echo ""

    # FIXED SC2046: Quote to prevent word splitting
    local confirmation_result
    confirmation_result="$(get_confirmation "Proceed with installation?")"
    return "$confirmation_result"
}

################################################################################
# Help and Information Display
################################################################################

# Show comprehensive help information
show_help() {
    clear
    echo -e "${BOLD}${BLUE}╔══════════════════════════════════════════════════════════════════╗${NC}"  
    echo -e "${BOLD}${BLUE}║        ${WHITE}Cursor Manager Help${BLUE}                        ║${NC}"
    echo -e "${BOLD}${BLUE}║        ${CYAN}Version ${SCRIPT_VERSION}${BLUE}                   ║${NC}"
    echo -e "${BOLD}${BLUE}╚══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    echo -e "${BOLD}${WHITE}DESCRIPTION:${NC}"
    echo -e "  Advanced Cursor AI Editor management utility with comprehensive"
    echo -e "  installation, removal, and optimization capabilities."
    echo ""

    echo -e "${BOLD}${WHITE}COMMAND LINE USAGE:${NC}"
    echo -e "  ${CYAN}./uninstall_cursor.sh${NC} [OPTION] [ARGUMENTS]"
    echo ""

    echo -e "${BOLD}${WHITE}OPTIONS:${NC}"
    echo -e "  ${YELLOW}-u, --uninstall${NC}           Complete removal of Cursor"
    echo -e "  ${YELLOW}-i, --install DMG${NC}         Install from DMG file"
    echo -e "  ${YELLOW}-o, --optimize${NC}            Optimize system performance"
    echo -e "  ${YELLOW}-r, --reset-performance${NC}   Reset optimization settings"
    echo -e "  ${YELLOW}-c, --check${NC}               Check installation status"
    echo -e "  ${YELLOW}-m, --menu${NC}                Show interactive menu"
    echo -e "  ${YELLOW}-b, --backup ACTION${NC}       Backup operations"
    echo -e "  ${YELLOW}--health${NC}                  Perform system health check"
    echo -e "  ${YELLOW}--verbose${NC}                 Enable detailed output"
    echo -e "  ${YELLOW}-h, --help${NC}                Show this help message"
    echo ""

    echo -e "${BOLD}${WHITE}BACKUP ACTIONS:${NC}"
    echo -e "  ${CYAN}create${NC}                     Create new backup"
    echo -e "  ${CYAN}restore${NC}                    Restore from backup"
    echo -e "  ${CYAN}list${NC}                       List available backups"
    echo ""

    echo -e "${BOLD}${WHITE}EXAMPLES:${NC}"
    echo -e "  ${CYAN}./uninstall_cursor.sh --uninstall${NC}"
    echo -e "  ${CYAN}./uninstall_cursor.sh --install /path/to/cursor.dmg${NC}"
    echo -e "  ${CYAN}./uninstall_cursor.sh --backup create${NC}"
    echo -e "  ${CYAN}./uninstall_cursor.sh --verbose --uninstall${NC}"
    echo ""

    echo -e "${BOLD}${WHITE}CONFIGURATION:${NC}"
    echo -e "  Config file: ${CYAN}$CONFIG_FILE${NC}"
    echo -e "  Backup dir:  ${CYAN}$BACKUP_DIR${NC}"
    echo -e "  Log dir:     ${CYAN}$LOG_DIR${NC}"
    echo ""

    echo -e "${BOLD}${WHITE}SUPPORT:${NC}"
    echo -e "  For issues and feature requests, check the script documentation"
    echo -e "  or run with ${CYAN}--verbose${NC} flag for detailed logging."
    echo ""
}

################################################################################
# Module Initialization
################################################################################

# Mark UI module as loaded
UI_LOADED="true"

# Export important functions and variables
export UI_LOADED
