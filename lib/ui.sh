#!/bin/bash

################################################################################
# Production UI Functions for Cursor AI Editor Management Utility
# REFACTORED: Enhanced security, accessibility, and responsive design
################################################################################

# Secure error handling
set -euo pipefail
readonly IFS=$' \t\n'

# UI module configuration
readonly UI_MODULE_VERSION="3.0.0"

# UI Constants and Configuration with security considerations
readonly UI_BAR_WIDTH=50
readonly UI_ANIMATION_DELAY=0.05
readonly UI_SPINNER_CHARS="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
readonly UI_MAX_MESSAGE_LENGTH=200

# Terminal capability detection with comprehensive validation
detect_terminal_capabilities() {
    local -a capabilities=()
    
    # Secure color support detection
    if [[ -t 1 ]] && [[ "${TERM:-}" != "dumb" ]] && [[ -z "${NO_COLOR:-}" ]]; then
        if command -v tput >/dev/null 2>&1; then
            local colors
            colors=$(tput colors 2>/dev/null || echo "0")
            if (( colors >= 8 )); then
                capabilities+=("color")
            fi
            if (( colors >= 256 )); then
                capabilities+=("256color")
            fi
        fi
    fi
    
    # Unicode support detection
    if [[ "${LANG:-}" =~ UTF-8 ]] || [[ "${LC_ALL:-}" =~ UTF-8 ]] || [[ "${LC_CTYPE:-}" =~ UTF-8 ]]; then
        capabilities+=("unicode")
    fi
    
    # Terminal width detection with fallback
    local -i term_width
    if term_width=$(tput cols 2>/dev/null) && (( term_width > 0 )); then
        readonly TERM_WIDTH="$term_width"
    else
        readonly TERM_WIDTH=80
    fi
    export TERM_WIDTH
    
    # Terminal height detection
    local -i term_height
    if term_height=$(tput lines 2>/dev/null) && (( term_height > 0 )); then
        readonly TERM_HEIGHT="$term_height"
    else
        readonly TERM_HEIGHT=24
    fi
    export TERM_HEIGHT
    
    # Export capabilities securely
    readonly TERMINAL_CAPABILITIES="${capabilities[*]:-}"
    export TERMINAL_CAPABILITIES
    
    # Log capabilities detection
    if declare -f log_with_level >/dev/null 2>&1; then
        log_with_level "DEBUG" "Terminal capabilities: ${TERMINAL_CAPABILITIES:-none} (${TERM_WIDTH}x${TERM_HEIGHT})"
    fi
}

# SECURITY ENHANCED: Comprehensive message sanitization with injection prevention
sanitize_message() {
    local message="$1"
    local max_length="${2:-$UI_MAX_MESSAGE_LENGTH}"
    local strict_mode="${3:-false}"
    
    # Input validation
    if [[ -z "$message" ]]; then
        return 0
    fi
    
    # SECURITY: Remove all control characters and dangerous sequences
    # First pass: remove null bytes, escape sequences, and control chars
    message=$(printf '%s' "$message" | \
        # Remove null bytes and control characters
        tr -d '\000-\010\013\014\016-\037\177' | \
        # Remove ANSI escape sequences
        sed 's/\x1b\[[0-9;]*[mGKHF]//g' | \
        # Remove other dangerous escape sequences
        sed 's/\x1b[()][AB0-9]//g')
    
    # SECURITY: Remove shell command injection patterns with comprehensive filtering
    message=$(printf '%s' "$message" | \
        # Remove null bytes and dangerous control characters
        tr -d '\000-\010\013\014\016-\037\177' | \
        # Remove ALL forms of command substitution and evaluation
        sed 's/`[^`]*`//g' | \
        sed 's/\$([^)]*)//g' | \
        sed 's/\${[^}]*}//g' | \
        sed 's/\$[a-zA-Z_][a-zA-Z0-9_]*//g' | \
        # Remove eval and exec patterns
        sed 's/eval[[:space:]]*[^[:space:]]*/EVAL_REMOVED/g' | \
        sed 's/exec[[:space:]]*[^[:space:]]*/EXEC_REMOVED/g' | \
        # Remove dangerous shell operators and metacharacters
        sed 's/[;&|><]/ /g' | \
        # Remove function definition patterns
        sed 's/()[[:space:]]*{/FUNCTION_REMOVED/g' | \
        # Clean up multiple spaces
        sed 's/[[:space:]]\+/ /g' | \
        # Trim leading/trailing whitespace
        sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
    
    # SECURITY: Additional strict filtering for log injection prevention
    if [[ "$strict_mode" == "true" ]]; then
        message=$(printf '%s' "$message" | \
            # Allow only alphanumeric, basic punctuation, and safe symbols
            tr -cd 'a-zA-Z0-9 .,!?:;()\[\]_-' | \
            # Replace dangerous patterns with safe equivalents
            sed 's/\.\.\././g')
    else
        # Standard mode: allow printable characters but escape dangerous ones
        message=$(printf '%s' "$message" | \
            # Keep only printable characters plus newline and tab
            tr -cd '[:print:]\n\t' | \
            # Escape shell metacharacters for safe display
            sed 's/[\[\](){}.*+?^$|\\]/\\&/g' | \
            # Escape quotes for shell safety
            sed "s/'/'\\\\''/g" | \
            sed 's/"/\\"/g')
    fi
    
    # SECURITY: Apply length limitation with safe truncation
    if [[ -n "$max_length" && "$max_length" -gt 0 ]]; then
        # Truncate safely without breaking multi-byte characters
        if (( ${#message} > max_length )); then
            message="${message:0:$((max_length - 3))}..."
        fi
    fi
    
    # SECURITY: Final validation - ensure no dangerous content remains
    if [[ "$message" =~ (\$\(|\$\{|`|;|&|\|) ]]; then
        # If dangerous patterns still exist, apply strict sanitization
        message=$(printf '%s' "$message" | tr -cd 'a-zA-Z0-9 .,!?:;()\[\]_-')
        log_with_level "WARNING" "Applied strict sanitization due to dangerous patterns"
    fi
    
    printf '%s' "$message"
}

# Enhanced progress display with comprehensive validation
show_progress() {
    local -i current="${1:-0}"
    local -i total="${2:-100}"
    local message="${3:-Processing}"
    local show_bar="${4:-true}"
    local show_percentage="${5:-true}"
    local show_eta="${6:-false}"
    local -i start_time="${7:-$(date +%s)}"

    # Input validation with security considerations
    if (( total <= 0 )); then
        printf '[INFO] %s...\n' "$(sanitize_message "$message")"
        return 0
    fi
    
    if (( current < 0 )); then
        current=0
    elif (( current > total )); then
        current=total
    fi

    local -i percentage=$(( (current * 100) / total ))
    
    # Build output securely
    local output=""
    
    # Progress bar with adaptive width
    if [[ "$show_bar" == "true" ]]; then
        local -i bar_width="$UI_BAR_WIDTH"
        
        # Adapt to terminal width with minimum constraints
        if (( TERM_WIDTH < 100 )); then
            bar_width=$(( TERM_WIDTH / 3 ))
            # Ensure minimum width
            if (( bar_width < 10 )); then
                bar_width=10
            fi
        fi
        
        local -i filled=$(( (percentage * bar_width) / 100 ))
        local -i empty=$(( bar_width - filled ))

        local fill_char="█" empty_char="░"
        
        # Use ASCII fallback if Unicode not supported
        if [[ ! "$TERMINAL_CAPABILITIES" =~ unicode ]]; then
            fill_char="=" empty_char="-"
        fi
        
        local progress_bar=""
        local -i i
        for ((i=0; i<filled; i++)); do
            progress_bar+="$fill_char"
        done
        for ((i=0; i<empty; i++)); do
            progress_bar+="$empty_char"
        done

        output+="[${progress_bar}]"
    fi
    
    # Percentage display
    if [[ "$show_percentage" == "true" ]]; then
        output+=$(printf ' %3d%%' "$percentage")
    fi
    
    # ETA calculation with overflow protection
    if [[ "$show_eta" == "true" && current -gt 0 ]]; then
        local -i elapsed=$(( $(date +%s) - start_time ))
        if (( elapsed > 0 )); then
            local -i rate=$(( current / elapsed ))
            if (( rate > 0 )); then
                local -i remaining=$(( (total - current) / rate ))
                
                if (( remaining > 3600 )); then
                    local -i hours=$(( remaining / 3600 ))
                    output+=$(printf ' ETA: %dh' "$hours")
                elif (( remaining > 60 )); then
                    local -i minutes=$(( remaining / 60 ))
                    output+=$(printf ' ETA: %dm' "$minutes")
                elif (( remaining > 0 )); then
                    output+=$(printf ' ETA: %ds' "$remaining")
                fi
            fi
        fi
    fi
    
    # Add sanitized message
    local sanitized_msg
    sanitized_msg=$(sanitize_message "$message" 50)
    output+=" $sanitized_msg"
    
    # Apply color if available and appropriate
    if [[ "$TERMINAL_CAPABILITIES" =~ color ]]; then
        if (( percentage >= 100 )); then
            printf '\r%s%s%s' "${GREEN:-}" "$output" "${NC:-}"
        elif (( percentage >= 75 )); then
            printf '\r%s%s%s' "${CYAN:-}" "$output" "${NC:-}"
        elif (( percentage >= 50 )); then
            printf '\r%s%s%s' "${YELLOW:-}" "$output" "${NC:-}"
        else
            printf '\r%s' "$output"
        fi
    else
        printf '\r%s' "$output"
    fi

    # Complete with newline
    if (( current >= total )); then
        printf '\n'
    fi
}

# Enhanced spinner with process monitoring and cleanup
show_spinner() {
    local message="$1"
    local duration="${2:-5}"
    local monitor_pid="${3:-}"
    local cleanup_on_exit="${4:-true}"
    
    # Sanitize message
    message=$(sanitize_message "$message" 50)
    
    # Select appropriate spinner characters
    local spinner_chars
    if [[ "$TERMINAL_CAPABILITIES" =~ unicode ]]; then
        spinner_chars="$UI_SPINNER_CHARS"
    else
        spinner_chars="|/-\\"
    fi
    
    printf '%s ' "$message"
    
    local -i char_index=0
    local -i iterations
    
    if [[ -n "$monitor_pid" && "$monitor_pid" =~ ^[0-9]+$ ]]; then
        # Monitor existing process with timeout protection
        local -i timeout_counter=0
        local -i max_timeout=$((duration * 10))
        
        while kill -0 "$monitor_pid" 2>/dev/null && (( timeout_counter < max_timeout )); do
            local char="${spinner_chars:$char_index:1}"
            printf '\b%s' "$char"
            char_index=$(( (char_index + 1) % ${#spinner_chars} ))
            sleep "$UI_ANIMATION_DELAY"
            ((timeout_counter++))
        done
    else
        # Fixed duration spinner with safe arithmetic
        iterations=$(( duration * 20 ))  # 20 iterations per second
        
        for ((i=0; i<iterations; i++)); do
            local char="${spinner_chars:$char_index:1}"
            printf '\b%s' "$char"
            char_index=$(( (char_index + 1) % ${#spinner_chars} ))
            sleep "$UI_ANIMATION_DELAY"
        done
    fi
    
    # Complete with checkmark or appropriate symbol
    if [[ "$TERMINAL_CAPABILITIES" =~ unicode ]]; then
        printf '\b✅\n'
    else
        printf '\b[OK]\n'
    fi
    
    # Cleanup: Reset any background processes if needed
    if [[ "$cleanup_on_exit" == "true" && -n "$monitor_pid" && "$monitor_pid" =~ ^[0-9]+$ ]]; then
        # Ensure monitored process is properly handled
        if kill -0 "$monitor_pid" 2>/dev/null; then
            # Process is still running - this is expected
            debug_message "Monitored process $monitor_pid still running" "SPINNER"
        fi
    fi
}

# Enhanced system information display with security and formatting
display_system_specifications() {
    local format="${2:-table}"
    
    # Security: Validate format parameter
    if [[ ! "$format" =~ ^(table|json|compact)$ ]]; then
        format="table"
    fi
    
    # Header with adaptive width
    local -i header_width=$((TERM_WIDTH > 60 ? 50 : TERM_WIDTH - 10))
    local header_line
    header_line=$(printf '═%.0s' $(seq 1 "$header_width"))
    
    if [[ "$format" == "table" ]]; then
        printf '\n%s%s🖥️  SYSTEM SPECIFICATIONS%s\n' "${BOLD:-}" "${BLUE:-}" "${NC:-}"
        printf '%s%s%s\n\n' "${BOLD:-}" "$header_line" "${NC:-}"
    fi
    
    # Get system information safely
    local system_info=""
    if declare -f get_system_specs >/dev/null 2>&1; then
        system_info=$(get_system_specs 2>/dev/null || echo "System information unavailable")
    else
        system_info="System information function not available"
    fi
    
    case "$format" in
        "json")
            # JSON output with proper escaping
            printf '{\n'
            local first=true
            while IFS=': ' read -r key value; do
                if [[ -n "$key" && -n "$value" ]]; then
                    [[ "$first" == "false" ]] && printf ',\n'
                    # Escape JSON strings properly
                    key=$(printf '%s' "$key" | sed 's/"/\\"/g')
                    value=$(printf '%s' "$value" | sed 's/"/\\"/g')
                    printf '  "%s": "%s"' "$key" "$value"
                    first=false
                fi
            done <<< "$system_info"
            printf '\n}\n'
            ;;
        "compact")
            # Single line format for scripts
            printf '%s' "$system_info" | tr '\n' ' | ' | sed 's/ | $/\n/'
            ;;
        "table"|*)
            # Enhanced table format with alignment
            while IFS=': ' read -r key value; do
                if [[ -n "$key" && -n "$value" ]]; then
                    if [[ "$TERMINAL_CAPABILITIES" =~ color ]]; then
                        printf '  %s%-20s%s: %s\n' "${CYAN:-}" "$key" "${NC:-}" "$value"
                    else
                        printf '  %-20s: %s\n' "$key" "$value"
                    fi
                fi
            done <<< "$system_info"
            ;;
    esac
    
    if [[ "$format" == "table" ]]; then
        printf '\n'
    fi
}

# Enhanced status indicators with comprehensive validation
show_status_indicator() {
    local status="$1"
    local message="${2:-}"
    local show_timestamp="${3:-false}"
    
    # Sanitize inputs
    status=$(printf '%s' "$status" | tr '[:lower:]' '[:upper:]' | tr -cd '[:alpha:]')
    message=$(sanitize_message "$message" 100)
    
    local symbol color
    
    # Define status indicators with fallbacks
    case "$status" in
        "SUCCESS"|"OK"|"PASS"|"COMPLETE")
            if [[ "$TERMINAL_CAPABILITIES" =~ unicode ]]; then
                symbol="✅"
            else
                symbol="[OK]"
            fi
            color="${GREEN:-}"
            ;;
        "ERROR"|"FAIL"|"FAILED")
            if [[ "$TERMINAL_CAPABILITIES" =~ unicode ]]; then
                symbol="❌"
            else
                symbol="[ERR]"
            fi
            color="${RED:-}"
            ;;
        "WARNING"|"WARN")
            if [[ "$TERMINAL_CAPABILITIES" =~ unicode ]]; then
                symbol="⚠️"
            else
                symbol="[WARN]"
            fi
            color="${YELLOW:-}"
            ;;
        "INFO"|"INFORMATION")
            if [[ "$TERMINAL_CAPABILITIES" =~ unicode ]]; then
                symbol="ℹ️"
            else
                symbol="[INFO]"
            fi
            color="${CYAN:-}"
            ;;
        "PROCESSING"|"WORKING"|"RUNNING")
            if [[ "$TERMINAL_CAPABILITIES" =~ unicode ]]; then
                symbol="🔄"
            else
                symbol="[...]"
            fi
            color="${BLUE:-}"
            ;;
        *)
            symbol="[${status}]"
            color=""
            ;;
    esac
    
    # Build output with timestamp if requested
    local output="$symbol"
    if [[ -n "$message" ]]; then
        output+=" $message"
    fi
    
    if [[ "$show_timestamp" == "true" ]]; then
        local timestamp
        timestamp=$(date '+%H:%M:%S' 2>/dev/null || date '+%T')
        output="[$timestamp] $output"
    fi
    
    # Apply color and output
    if [[ -n "$color" && "$TERMINAL_CAPABILITIES" =~ color ]]; then
        printf '%s%s%s\n' "$color" "$output" "${NC:-}"
    else
        printf '%s\n' "$output"
    fi
}

# Enhanced confirmation dialog with security considerations
confirm_action() {
    local prompt="$1"
    local default_response="${2:-n}"
    local timeout_seconds="${3:-0}"
    local danger_level="${4:-normal}"
    
    # Sanitize inputs
    prompt=$(sanitize_message "$prompt" 150)
    if [[ ! "$default_response" =~ ^[yn]$ ]]; then
        default_response="n"
    fi
    
    # Apply appropriate styling based on danger level
    local prompt_color=""
    local warning_text=""
    
    case "$danger_level" in
        "critical"|"danger")
            prompt_color="${RED:-}"
            warning_text="⚠️  CRITICAL ACTION - "
            ;;
        "warning")
            prompt_color="${YELLOW:-}"
            warning_text="⚠️  WARNING - "
            ;;
        "normal"|*)
            prompt_color="${CYAN:-}"
            warning_text=""
            ;;
    esac
    
    # Build prompt with appropriate indicators
    local full_prompt
    if [[ "$default_response" == "y" ]]; then
        full_prompt="${warning_text}${prompt} [Y/n]: "
    else
        full_prompt="${warning_text}${prompt} [y/N]: "
    fi
    
    # Handle timeout scenario
    if (( timeout_seconds > 0 )); then
        full_prompt+="(timeout in ${timeout_seconds}s) "
    fi
    
    # Display prompt with color
    if [[ -n "$prompt_color" && "$TERMINAL_CAPABILITIES" =~ color ]]; then
        printf '%s%s%s' "$prompt_color" "$full_prompt" "${NC:-}"
    else
        printf '%s' "$full_prompt"
    fi
    
    # Read response with timeout if specified
    local response=""
    if (( timeout_seconds > 0 )); then
        if ! read -r -t "$timeout_seconds" response 2>/dev/null; then
            printf '\n[TIMEOUT] Using default response: %s\n' "$default_response"
            response="$default_response"
        fi
    else
        read -r response 2>/dev/null || response="$default_response"
    fi
    
    # Process response securely
    response=$(printf '%s' "$response" | tr '[:upper:]' '[:lower:]' | tr -cd '[:alpha:]')
    
    # Determine result
    case "$response" in
        "y"|"yes")
            return 0
            ;;
        "n"|"no")
            return 1
            ;;
        "")
            # Use default
            if [[ "$default_response" == "y" ]]; then
                return 0
            else
                return 1
            fi
            ;;
        *)
            # Invalid response - use safe default
            printf 'Invalid response. Using default: %s\n' "$default_response"
            if [[ "$default_response" == "y" ]]; then
                return 0
            else
                return 1
            fi
            ;;
    esac
}

# Enhanced menu display with keyboard navigation
show_menu() {
    local title="$1"
    shift
    local -a options=("$@")
    
    # Sanitize title
    title=$(sanitize_message "$title" 50)
    
    # Validate options
    if (( ${#options[@]} == 0 )); then
        printf '[ERROR] No menu options provided\n' >&2
        return 1
    fi
    
    # Calculate display dimensions
    local -i menu_width=$((TERM_WIDTH > 60 ? 60 : TERM_WIDTH - 4))
    local title_line
    title_line=$(printf '═%.0s' $(seq 1 "$menu_width"))
    
    # Display menu header
    printf '\n%s%s%s\n' "${BOLD:-}" "$title" "${NC:-}"
    printf '%s%s%s\n\n' "${BOLD:-}" "$title_line" "${NC:-}"
    
    # Display options with numbering
    local -i index=1
    for option in "${options[@]}"; do
        local sanitized_option
        sanitized_option=$(sanitize_message "$option" 50)
        
        if [[ "$TERMINAL_CAPABILITIES" =~ color ]]; then
            printf '  %s%2d)%s %s\n' "${CYAN:-}" "$index" "${NC:-}" "$sanitized_option"
        else
            printf '  %2d) %s\n' "$index" "$sanitized_option"
        fi
        ((index++))
    done
    
    printf '\n'
}

# Clear screen with fallback
clear_screen() {
    if command -v clear >/dev/null 2>&1; then
        clear
    elif command -v tput >/dev/null 2>&1; then
        tput clear 2>/dev/null || printf '\033[2J\033[H'
    else
        printf '\033[2J\033[H'
    fi
}

# Enhanced error display with context
display_error() {
    local error_message="$1"
    local error_code="${2:-1}"
    local show_help="${3:-false}"
    
    # Sanitize error message
    error_message=$(sanitize_message "$error_message" 200)
    
    # Validate error code
    if [[ ! "$error_code" =~ ^[0-9]+$ ]]; then
        error_code=1
    fi
    
    # Display error with appropriate formatting
    printf '\n'
    if [[ "$TERMINAL_CAPABILITIES" =~ color ]]; then
        printf '%s━━━ ERROR ━━━%s\n' "${RED:-}" "${NC:-}"
        printf '%s%s%s\n' "${RED:-}" "$error_message" "${NC:-}"
    else
        printf '=== ERROR ===\n'
        printf '%s\n' "$error_message"
    fi
    
    if (( error_code != 1 )); then
        printf 'Error Code: %d\n' "$error_code"
    fi
    
    if [[ "$show_help" == "true" ]]; then
        printf '\nFor help, run with --help option\n'
    fi
    
    printf '\n'
}

# Module initialization and capability detection
init_ui() {
    # Detect terminal capabilities
    detect_terminal_capabilities
    
    # Set up UI defaults based on capabilities
    if [[ ! "$TERMINAL_CAPABILITIES" =~ color ]]; then
        # Disable color variables
        export RED="" GREEN="" YELLOW="" BLUE="" CYAN="" BOLD="" NC=""
    fi
    
    readonly UI_INITIALIZED=true
    export UI_INITIALIZED
    
    if declare -f log_with_level >/dev/null 2>&1; then
        log_with_level "DEBUG" "UI module v$UI_MODULE_VERSION initialized successfully"
    fi
}

# Module loading validation
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    # Being sourced - initialize UI
    init_ui
else
    # Being executed directly
    printf 'UI Module v%s\n' "$UI_MODULE_VERSION"
    printf 'This module must be sourced, not executed directly\n'
    exit 1
fi 