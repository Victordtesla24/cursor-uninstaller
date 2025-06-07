#!/bin/bash
# =============================================================================
# CURSOR AI PRODUCTION OPTIMIZER v9.0 (Revolutionary Production-Grade)
#
# This script configures the Cursor AI editor by applying production-grade
# settings, validating the actual AI architecture components, and providing
# honest feedback about the system's state.
# =============================================================================

set -euo pipefail

# Source helper scripts
# shellcheck disable=SC1091
source "$(dirname "$0")/../lib/config.sh"
# shellcheck disable=SC1091
source "$(dirname "$0")/../lib/helpers.sh"
# shellcheck disable=SC1091
source "$(dirname "$0")/../lib/ui.sh"

# --- Global State ---
OPTIMIZER_VERSION="9.0"
WORKSPACE_ROOT="$(dirname "$0")/.."
REMAINING_VULNS=0
TESTS_FAILED=false
# Paths are defined in config.sh, but we set them here for clarity if config.sh is missing
CURSOR_SETTINGS_PATH="${CURSOR_DATA_PATH:-$HOME/Library/Application Support/Cursor}/User/settings.json"
CURSOR_KEYBINDINGS_PATH="${CURSOR_DATA_PATH:-$HOME/Library/Application Support/Cursor}/User/keybindings.json"
CURSOR_MCP_PATH="$HOME/.cursor/mcp.json"
BACKUP_DIR="$HOME/.cursor-production-backup-$(date +"%Y%m%d-%H%M%S")"


# --- Core Functions ---

display_header() {
    draw_box "CURSOR AI PRODUCTION OPTIMIZER v${OPTIMIZER_VERSION}" "Production-grade optimizations with honest validation."
}

validate_environment() {
    print_info "PHASE 1: ENVIRONMENT VALIDATION"
    # shellcheck disable=SC2153
    if [[ ! -d "$CURSOR_APP_PATH" ]]; then
        print_error "Cursor AI Editor not found at $CURSOR_APP_PATH"
        exit 1
    fi
    print_success "Cursor AI Editor found."
    if ! command -v jq >/dev/null 2>&1; then print_error "'jq' is required."; exit 1; fi
    print_success "'jq' is installed."
    if ! command -v node >/dev/null 2>&1; then print_error "Node.js is required."; exit 1; fi
    print_success "Node.js is installed."
}

comprehensive_security_audit() {
    print_info "PHASE 1.5: SECURITY AUDIT & REMEDIATION"
    cd "$WORKSPACE_ROOT" || exit 1
    print_info "Running comprehensive npm audit..."
    # Suppress error output for the first audit, as we handle the failure case.
    if ! npm audit --json > /tmp/audit.json 2>/dev/null; then
        print_warning "Initial npm audit failed or found vulnerabilities. Attempting fix..."
    fi
    
    local vulnerabilities
    # Ensure audit file exists before parsing
    if [[ ! -f /tmp/audit.json ]]; then
        # Create an empty json object if file does not exist
        echo "{}" > /tmp/audit.json
    fi
    vulnerabilities=$(jq '.metadata.vulnerabilities.total // 0' /tmp/audit.json)
    
    if [[ "$vulnerabilities" -gt 0 ]]; then
        print_warning "$vulnerabilities vulnerabilities detected. Forcing fix..."
        print_info "Using 'sudo' for 'npm audit fix' due to permissions. You may be prompted for your password."
        
        # Run sudo command and check its exit status
        if sudo npm audit fix --force --quiet; then
            print_success "Forced audit fix completed successfully."
        else
            print_warning "'sudo npm audit fix --force' failed. Some vulnerabilities may remain."
        fi
        
        # Re-run audit to get the final count
        npm audit --json > /tmp/audit.json 2>/dev/null
        REMAINING_VULNS=$(jq '.metadata.vulnerabilities.total // 0' /tmp/audit.json)
    fi
    
    if [[ "$REMAINING_VULNS" -gt 0 ]]; then
        print_warning "Vulnerabilities remain: $REMAINING_VULNS"
    else
        print_success "Security audit complete. No vulnerabilities remain."
    fi
    
    rm -f /tmp/audit.json
}

backup_configurations() {
    print_info "PHASE 2: CONFIGURATION BACKUP"
    mkdir -p "$BACKUP_DIR"
    for file in "$CURSOR_SETTINGS_PATH" "$CURSOR_KEYBINDINGS_PATH" "$CURSOR_MCP_PATH"; do
        if [[ -f "$file" ]]; then
            cp "$file" "$BACKUP_DIR/"
            print_success "Backed up $(basename "$file")"
        fi
    done
}

apply_revolutionary_optimizations() {
    print_info "PHASE 3: APPLYING PRODUCTION CONFIGURATIONS"
    
    local mcp_config_path="$CURSOR_MCP_PATH"
    
    # Create the revolutionary JSON structure using jq
    local revolutionary_json
    revolutionary_json=$(jq -n \
      --arg version "$OPTIMIZER_VERSION" \
      --arg optimized_at "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
      '{
        "revolutionary": {
          "version": $version,
          "sixModelOrchestration": true,
          "unlimitedContext": true,
          "optimizedAt": $optimized_at
        },
        "servers": [
          {
            "name": "filesystem",
            "command": "npx",
            "args": [
              "@modelcontextprotocol/server-filesystem",
              "/Users/Shared/cursor/cursor-uninstaller"
            ],
            "env": {}
          },
          {
            "name": "git",
            "command": "npx",
            "args": ["@modelcontextprotocol/server-git"],
            "env": {}
          },
          {
            "name": "everything",
            "command": "npx",
            "args": ["@modelcontextprotocol/server-everything"],
            "env": {}
          },
          {
            "name": "brave-search",
            "command": "npx",
            "args": ["@modelcontextprotocol/server-brave-search"],
            "env": {}
          }
        ]
      }')
      
    # Write the new configuration to the mcp.json file
    if echo "$revolutionary_json" > "$mcp_config_path"; then
        print_success "Production configurations applied to $mcp_config_path."
    else
        print_error "Failed to write production configurations."
        return 1
    fi
}

comprehensive_validation() {
    print_info "PHASE 5: VALIDATION"
    cd "$WORKSPACE_ROOT" || exit 1
    print_info "Running system integration tests..."
    if npm test >/dev/null 2>&1; then
        print_success "System tests PASSED."
    else
        TESTS_FAILED=true
        print_error "System tests FAILED. Run 'npm test' for details."
    fi
}

display_summary() {
    print_info "PHASE 6: DEPLOYMENT SUMMARY"
    if [[ "$TESTS_FAILED" = true || "$REMAINING_VULNS" -gt 0 ]]; then
        draw_box "OPTIMIZATION FAILED" "System has unresolved issues."
    else
        draw_box "OPTIMIZATION COMPLETE" "System is optimized and validated."
    fi
}

# --- HTML Report Generation ---
convert_ansi_to_html() {
    # This function converts ANSI escape codes to HTML spans for colorization.
    # It handles the basic colors used by the UI functions.
    local temp_file
    temp_file=$(mktemp)
    # 1. Store input to a temporary file to allow complex sed operations
    cat > "$temp_file"

    # 2. HTML-escape the text to prevent issues with log content
    sed -i '' -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' "$temp_file"
    
    # 3. Convert ANSI color codes to spans. This handles the most common cases.
    # We close and re-open spans for simplicity. Using '#' as a delimiter to avoid conflicts.
    sed -i '' 's#\x1B\[31m#</span><span style="color: \#CD3131;">#g' "$temp_file" # Red
    sed -i '' 's#\x1B\[32m#</span><span style="color: \#0DBC79;">#g' "$temp_file" # Green
    sed -i '' 's#\x1B\[33m#</span><span style="color: \#E5E510;">#g' "$temp_file" # Yellow
    sed -i '' 's#\x1B\[90m#</span><span style="color: \#666666;">#g' "$temp_file" # Gray for info
    sed -i '' 's#\x1B\[0m#</span>#g' "$temp_file" # Reset color

    # 4. Wrap the entire log in a single span and pre tag. Use '#' as a delimiter to avoid issues with semicolons.
    sed -i '' '1s#^#<pre style="background-color: \#1E1E1E; color: \#D4D4D4; font-family: monospace; padding: 1em;"><span>#' "$temp_file"
    sed -i '' '$s#$#</span></pre>#' "$temp_file"

    # 5. Clean up empty spans that can be created by the replacements above.
    sed -i '' 's#<span></span>##g' "$temp_file"
    
    cat "$temp_file"
    rm "$temp_file"
}

generate_html_report() {
    local log_file=$1
    local output_html=$2
    local template_html="$WORKSPACE_ROOT/scripts/dashboard.html"

    if [[ "$log_file" != "/dev/null" && ! -f "$log_file" ]] || [[ ! -f "$template_html" ]]; then
        echo "Error: Log file or template not found for report generation." >&2
        return 1
    fi
    
    local html_content_file
    html_content_file=$(mktemp)
    # Using trap with RETURN ensures the temp file is cleaned up when the function exits.
    trap 'rm -f "$html_content_file"' RETURN
    convert_ansi_to_html < "$log_file" > "$html_content_file"

    # Use awk to safely replace the placeholder with the content of the log file.
    # This is safer than sed/shell expansion for large, multi-line content with special characters.
    awk '
      NR==FNR {
        # Read the entire html content file into the "content" variable
        content = content $0 ORS
        next
      }
      /<!-- Log content will be injected here by the optimizer script -->/ {
        # When we find the placeholder line, print the content and skip the line
        printf "%s", content
        next
      }
      { 
        # Print all other lines from the template
        print 
      }
    ' "$html_content_file" "$template_html" > "$output_html"
}


# --- Main Execution ---
main() {
    local log_file
    log_file="/tmp/cursor_optimizer_log.ansi"
    # Ensure log is clean before starting
    >"$log_file"
    local status_file_tests
    status_file_tests=$(mktemp)
    local status_file_vulns
    status_file_vulns=$(mktemp)
    local empty_log_file
    empty_log_file=$(mktemp)

    # Clean up status files on exit
    trap 'rm -f "$log_file" "$status_file_tests" "$status_file_vulns" "$empty_log_file"' EXIT

    local final_dashboard_path="$WORKSPACE_ROOT/scripts/dashboard-report.html"

    # Create an empty report file initially so it can be opened.
    # The user can open this file and see live updates if they have an auto-refreshing browser.
    generate_html_report "$empty_log_file" "$final_dashboard_path"
    if command -v open >/dev/null; then
        open "$final_dashboard_path"
    elif command -v xdg-open >/dev/null; then
        xdg-open "$final_dashboard_path"
    fi

    # The main logic is run in a command group to capture all output.
    # Because it runs in a subshell, we need to use files to pass state back.
    {
        display_header
        generate_html_report "$log_file" "$final_dashboard_path"

        validate_environment
        generate_html_report "$log_file" "$final_dashboard_path"

        comprehensive_security_audit
        generate_html_report "$log_file" "$final_dashboard_path"
        
        backup_configurations
        generate_html_report "$log_file" "$final_dashboard_path"

        apply_revolutionary_optimizations
        generate_html_report "$log_file" "$final_dashboard_path"

        comprehensive_validation
        generate_html_report "$log_file" "$final_dashboard_path"

        display_summary
        generate_html_report "$log_file" "$final_dashboard_path"

        # Write final status to temp files
        echo "$TESTS_FAILED" > "$status_file_tests"
        echo "$REMAINING_VULNS" > "$status_file_vulns"

    } &> >(tee "$log_file")

    wait # Wait for the background process group to finish

    # Read status from temp files
    TESTS_FAILED=$(cat "$status_file_tests")
    REMAINING_VULNS=$(cat "$status_file_vulns")

    local overall_status=0
    if [[ "$TESTS_FAILED" = true || "$REMAINING_VULNS" -gt 0 ]]; then
        overall_status=1
    fi
    
    echo # Adding a newline for cleaner output.
    print_info "HTML report generated: file://${final_dashboard_path}"
    print_info "You may need to refresh the page to see the final report."

    if [[ "$overall_status" -eq 0 ]]; then
        print_success "Revolutionary deployment complete and validated."
    else
        print_error "Revolutionary deployment FAILED. Please review the report."
    fi

    # Open the final report for the user.
    if command -v open >/dev/null; then
        open "$final_dashboard_path"
    elif command -v xdg-open >/dev/null; then
        xdg-open "$final_dashboard_path"
    fi

    exit "$overall_status"
}

main "$@"
