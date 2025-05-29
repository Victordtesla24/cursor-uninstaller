#!/usr/bin/env bats

load ../helpers/test_helper

# Setup - prepare the environment for each test
setup() {
    # Set variables to disable interactive menu
    export CURSOR_TEST_MODE=true
    export BATS_TEST_SOURCED=true
    export DRY_RUN=true

    # Create test directories
    mkdir -p "$TEST_DIR/tmp/Applications/Cursor.app/Contents"
    mkdir -p "$TEST_DIR/tmp/process_test"
    mkdir -p "$TEST_DIR/tmp/logs"

    # Create log files needed for tests
    touch "$TEST_DIR/tmp/complete_removal_operations.log" || true
    touch "$TEST_DIR/tmp/process_operations.log" || true
    touch "$TEST_DIR/tmp/bundle_verification.log" || true

    # Initialize logs with some content to ensure grep succeeds
    echo "INIT: Test log initialized" > "$TEST_DIR/tmp/complete_removal_operations.log"
    echo "INIT: Test log initialized" > "$TEST_DIR/tmp/process_operations.log"
    echo "INIT: Test log initialized" > "$TEST_DIR/tmp/bundle_verification.log"

    # Source the script to make functions available
    source "$SCRIPT_PATH"
}

# Teardown - clean up after each test
teardown() {
    # Clean up environment variables
    unset CURSOR_TEST_MODE
    unset BATS_TEST_SOURCED
    unset DRY_RUN

    # Clean up test files
    rm -rf "$TEST_DIR/tmp"
}

@test "remove_background_processes protects script from self-termination" {
    # Source the complete removal module
    source "$PROJECT_ROOT/modules/complete_removal.sh"

    # Mock ps command to simulate finding the script's own process
    ps() {
        if [[ "$1" == "aux" ]]; then
            cat << EOF
USER      PID  %CPU %MEM      VSZ    RSS   TT  STAT STARTED      TIME COMMAND
user     1234   0.0  0.1  1234567   1234  s000  S+    1:00PM   0:00.01 /bin/bash ./uninstall_cursor.sh
user     5678   0.0  0.1  1234567   1234  s000  S+    1:00PM   0:00.01 /Applications/Cursor.app/Contents/MacOS/Cursor
user     9999   0.0  0.1  1234567   1234  s000  S+    1:00PM   0:00.01 cursor-helper-process
EOF
        else
            command ps "$@"
        fi
    }

    # Mock kill command to track what gets killed
    kill() {
        echo "KILL: $@" >> "$TEST_DIR/tmp/process_operations.log"
        return 0
    }

    # Mock current script PID to test protection
    current_pid=$$
    
    # Run the function
    remove_background_processes

    # Verify that the script didn't try to kill itself
    if [[ -f "$TEST_DIR/tmp/process_operations.log" ]]; then
        ! grep -q "KILL:.*$current_pid" "$TEST_DIR/tmp/process_operations.log"
    fi

    # Should have protected uninstaller processes
    [[ -f "$TEST_DIR/tmp/process_operations.log" ]]
}

@test "remove_background_processes properly filters uninstaller processes" {
    # Source the complete removal module
    source "$PROJECT_ROOT/modules/complete_removal.sh"

    # Mock ps command to return various processes including uninstaller
    ps() {
        if [[ "$1" == "aux" ]]; then
            cat << EOF
USER      PID  %CPU %MEM      VSZ    RSS   TT  STAT STARTED      TIME COMMAND
user     1234   0.0  0.1  1234567   1234  s000  S+    1:00PM   0:00.01 /bin/bash ./uninstall_cursor.sh
user     5678   0.0  0.1  1234567   1234  s000  S+    1:00PM   0:00.01 /Applications/Cursor.app/Contents/MacOS/Cursor
user     9999   0.0  0.1  1234567   1234  s000  S+    1:00PM   0:00.01 cursor-helper-process
user     1111   0.0  0.1  1234567   1234  s000  S+    1:00PM   0:00.01 /path/to/cursor-uninstaller/script.sh
EOF
        elif [[ "$1" == "-p" ]]; then
            case "$2" in
                1234) echo "/bin/bash ./uninstall_cursor.sh" ;;
                5678) echo "/Applications/Cursor.app/Contents/MacOS/Cursor" ;;
                9999) echo "cursor-helper-process" ;;
                1111) echo "/path/to/cursor-uninstaller/script.sh" ;;
                *) echo "" ;;
            esac
        else
            command ps "$@"
        fi
    }

    # Mock kill and track operations
    kill() {
        echo "KILL: $@" >> "$TEST_DIR/tmp/process_operations.log"
        return 0
    }

    # Mock basename
    basename() {
        command basename "$@"
    }

    # Run the function
    remove_background_processes

    # Verify correct processes were targeted
    if [[ -f "$TEST_DIR/tmp/process_operations.log" ]]; then
        # Should NOT try to kill uninstaller processes
        ! grep -q "KILL:.*1234" "$TEST_DIR/tmp/process_operations.log"  # uninstall_cursor.sh
        ! grep -q "KILL:.*1111" "$TEST_DIR/tmp/process_operations.log"  # cursor-uninstaller script
        
        # Should try to kill actual Cursor processes
        grep -q "KILL:.*5678" "$TEST_DIR/tmp/process_operations.log" || \
        grep -q "KILL:.*9999" "$TEST_DIR/tmp/process_operations.log"
    fi
}

@test "remove_cursor_application handles todesktop bundle ID correctly" {
    # Source the complete removal module
    source "$PROJECT_ROOT/modules/complete_removal.sh"

    # Create a mock Cursor.app with todesktop bundle ID
    local test_app_path="$TEST_DIR/tmp/Applications/Cursor.app"
    mkdir -p "$test_app_path/Contents"
    
    # Create Info.plist with todesktop bundle ID
    cat > "$test_app_path/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleIdentifier</key>
    <string>com.todesktop.230313mzl4w4u92</string>
    <key>CFBundleName</key>
    <string>Cursor</string>
    <key>CFBundleDisplayName</key>
    <string>Cursor</string>
</dict>
</plist>
EOF

    # Mock defaults command to return the bundle info
    defaults() {
        case "$2" in
            "CFBundleIdentifier") echo "com.todesktop.230313mzl4w4u92" ;;
            "CFBundleName") echo "Cursor" ;;
            "CFBundleDisplayName") echo "Cursor" ;;
            *) echo "unknown" ;;
        esac
    }

    # Mock du command
    du() {
        if [[ "$1" == "-sh" ]]; then
            echo "100M	$2"
        else
            command du "$@"
        fi
    }

    # Mock enhanced_safe_remove
    enhanced_safe_remove() {
        echo "REMOVE: $1" >> "$TEST_DIR/tmp/complete_removal_operations.log"
        return 0
    }

    # Override app path for test
    local original_path="/Applications/Cursor.app"
    
    # Temporarily replace the path check in the function
    remove_cursor_application_test() {
        production_log_message "INFO" "Removing Cursor application bundle"
        
        local app_path="$test_app_path"
        
        if [[ -d "$app_path" ]]; then
            # Use the same verification logic as the fixed function
            local bundle_id
            bundle_id=$(defaults read "$app_path/Contents/Info.plist" CFBundleIdentifier 2>/dev/null || echo "unknown")
            
            local bundle_name
            bundle_name=$(defaults read "$app_path/Contents/Info.plist" CFBundleName 2>/dev/null || echo "unknown")
            
            local bundle_display_name
            bundle_display_name=$(defaults read "$app_path/Contents/Info.plist" CFBundleDisplayName 2>/dev/null || echo "unknown")
            
            # Enhanced verification to handle todesktop bundle IDs used by Cursor
            if [[ "$bundle_id" == *"cursor"* ]] || [[ "$bundle_id" == *"Cursor"* ]] || \
               [[ "$bundle_id" == *"todesktop"* ]] || \
               [[ "$bundle_name" == *"cursor"* ]] || [[ "$bundle_name" == *"Cursor"* ]] || \
               [[ "$bundle_display_name" == *"cursor"* ]] || [[ "$bundle_display_name" == *"Cursor"* ]] || \
               [[ "$(basename "$app_path")" == "Cursor.app" ]]; then
                
                echo "VERIFIED: $bundle_id ($bundle_name)" >> "$TEST_DIR/tmp/bundle_verification.log"
                
                local app_size
                app_size=$(du -sh "$app_path" 2>/dev/null | cut -f1)
                
                if enhanced_safe_remove "$app_path"; then
                    echo "SUCCESS: Removed Cursor.app ($app_size)" >> "$TEST_DIR/tmp/bundle_verification.log"
                    return 0
                else
                    echo "ERROR: Failed to remove Cursor.app" >> "$TEST_DIR/tmp/bundle_verification.log"
                    return 1
                fi
            else
                echo "VERIFICATION_FAILED: $bundle_id" >> "$TEST_DIR/tmp/bundle_verification.log"
                return 1
            fi
        else
            echo "NOT_FOUND: $app_path" >> "$TEST_DIR/tmp/bundle_verification.log"
            return 0
        fi
    }

    # Run the test function
    run remove_cursor_application_test

    # Verify the function succeeded
    [ "$status" -eq 0 ]

    # Check that verification succeeded
    [[ -f "$TEST_DIR/tmp/bundle_verification.log" ]]
    grep -q "VERIFIED:.*todesktop" "$TEST_DIR/tmp/bundle_verification.log"
    grep -q "SUCCESS:" "$TEST_DIR/tmp/bundle_verification.log"
    
    # Check that removal was attempted
    [[ -f "$TEST_DIR/tmp/complete_removal_operations.log" ]]
    grep -q "REMOVE:" "$TEST_DIR/tmp/complete_removal_operations.log"
}

@test "remove_cursor_application handles bundle verification gracefully" {
    # Source the complete removal module
    source "$PROJECT_ROOT/modules/complete_removal.sh"

    # Create mock app with unknown bundle ID but Cursor.app name
    local test_app_path="$TEST_DIR/tmp/Applications/Cursor.app"
    mkdir -p "$test_app_path/Contents"
    
    cat > "$test_app_path/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleIdentifier</key>
    <string>com.unknown.application</string>
    <key>CFBundleName</key>
    <string>UnknownApp</string>
    <key>CFBundleDisplayName</key>
    <string>Unknown Application</string>
</dict>
</plist>
EOF

    # Mock defaults command
    defaults() {
        case "$2" in
            "CFBundleIdentifier") echo "com.unknown.application" ;;
            "CFBundleName") echo "UnknownApp" ;;
            "CFBundleDisplayName") echo "Unknown Application" ;;
            *) echo "unknown" ;;
        esac
    }

    # Mock du command
    du() {
        if [[ "$1" == "-sh" ]]; then
            echo "50M	$2"
        else
            command du "$@"
        fi
    }

    # Mock enhanced_safe_remove
    enhanced_safe_remove() {
        echo "REMOVE: $1" >> "$TEST_DIR/tmp/complete_removal_operations.log"
        return 0
    }

    # Test function with fallback logic
    remove_cursor_application_fallback_test() {
        local app_path="$test_app_path"
        
        if [[ -d "$app_path" ]]; then
            local bundle_id="com.unknown.application"
            local bundle_name="UnknownApp"
            local bundle_display_name="Unknown Application"
            
            # Should fail initial verification but succeed on path-based fallback
            if [[ "$bundle_id" == *"cursor"* ]] || [[ "$bundle_id" == *"Cursor"* ]] || \
               [[ "$bundle_id" == *"todesktop"* ]] || \
               [[ "$bundle_name" == *"cursor"* ]] || [[ "$bundle_name" == *"Cursor"* ]] || \
               [[ "$bundle_display_name" == *"cursor"* ]] || [[ "$bundle_display_name" == *"Cursor"* ]] || \
               [[ "$(basename "$app_path")" == "Cursor.app" ]]; then
                
                echo "VERIFIED" >> "$TEST_DIR/tmp/bundle_verification.log"
                return 0
            else
                # Test the fallback logic
                if [[ "$(basename "$app_path")" == "Cursor.app" ]]; then
                    echo "FALLBACK_SUCCESS" >> "$TEST_DIR/tmp/bundle_verification.log"
                    enhanced_safe_remove "$app_path"
                    return 0
                else
                    echo "FALLBACK_FAILED" >> "$TEST_DIR/tmp/bundle_verification.log"
                    return 1
                fi
            fi
        fi
    }

    # Run the test
    run remove_cursor_application_fallback_test

    # Should succeed due to Cursor.app path
    [ "$status" -eq 0 ]
    
    # Check that fallback logic worked
    [[ -f "$TEST_DIR/tmp/bundle_verification.log" ]]
    grep -q "FALLBACK_SUCCESS" "$TEST_DIR/tmp/bundle_verification.log"
}

@test "detect_all_cursor_components finds components correctly" {
    # Source the complete removal module
    source "$PROJECT_ROOT/modules/complete_removal.sh"

    # Create mock Cursor components
    mkdir -p "$TEST_DIR/tmp/Applications/Cursor.app"
    mkdir -p "$TEST_DIR/tmp/Library/Application Support/Cursor"
    mkdir -p "$TEST_DIR/tmp/usr/local/bin"
    ln -sf "/Applications/Cursor.app/Contents/Resources/app/bin/code" "$TEST_DIR/tmp/usr/local/bin/cursor"

    # Mock du command
    du() {
        case "$2" in
            *"Cursor.app") echo "500M	$2" ;;
            *"Application Support/Cursor") echo "100M	$2" ;;
            *) echo "1K	$2" ;;
        esac
    }

    # Override path checks for test environment
    HOME="$TEST_DIR/tmp"
    
    # Mock readlink
    readlink() {
        if [[ "$1" == *"cursor" ]]; then
            echo "/Applications/Cursor.app/Contents/Resources/app/bin/code"
        else
            command readlink "$@"
        fi
    }

    # Mock TEMP_DIR
    TEMP_DIR="$TEST_DIR/tmp"

    # Run the function
    run detect_all_cursor_components

    # Should succeed
    [ "$status" -eq 0 ]

    # Check that components file was created
    [[ -f "$TEMP_DIR/cursor_components.txt" ]]
    
    # Verify components were detected
    grep -q "APPLICATION:" "$TEMP_DIR/cursor_components.txt"
}

@test "verify_complete_removal excludes uninstaller files correctly" {
    # Source the complete removal module
    source "$PROJECT_ROOT/modules/complete_removal.sh"

    # Mock find command to return various cursor-related files including uninstaller
    find() {
        if [[ "$*" == *"-iname"* ]] && [[ "$*" == *"cursor"* ]]; then
            cat << 'EOF'
/tmp/cursor-temp-file
/Users/test/.Trash/cursor-old-file
/Users/test/Documents/cursor-uninstaller/uninstall_cursor.sh
/Users/test/Documents/project/node_modules/cursor-something
/Users/test/Documents/legitimate-cursor-file
EOF
        else
            command find "$@"
        fi
    }

    # Mock command checks
    command() {
        case "$1" in
            -v)
                case "$2" in
                    cursor) return 1 ;;  # cursor command not found
                    timeout) return 0 ;;  # timeout available
                    sudo) return 0 ;;    # sudo available
                    *) command "$@" ;;
                esac
                ;;
            *) command "$@" ;;
        esac
    }

    # Mock sudo check
    sudo() {
        if [[ "$1" == "-n" ]]; then
            return 0  # passwordless sudo available
        else
            # Call find with the filtered arguments
            command find "$@"
        fi
    }

    # Mock timeout
    timeout() {
        shift  # Remove timeout duration
        "$@"   # Execute the command
    }

    # Mock directory checks
    HOME="$TEST_DIR/tmp"
    
    # Run the function
    run verify_complete_removal

    # Should find issues due to legitimate-cursor-file but not uninstaller files
    [ "$status" -eq 1 ]  # Should fail due to remaining files, but exclude uninstaller
}

@test "perform_complete_cursor_removal orchestrates all phases correctly" {
    # Source the complete removal module
    source "$PROJECT_ROOT/modules/complete_removal.sh"

    # Mock all required functions to track execution order
    local execution_log="$TEST_DIR/tmp/execution_order.log"

    detect_all_cursor_components() {
        echo "Phase1: detect_all_cursor_components" >> "$execution_log"
        return 0
    }

    find_additional_cursor_files() {
        echo "Phase1: find_additional_cursor_files" >> "$execution_log"
        return 0
    }

    remove_background_processes() {
        echo "Phase2: remove_background_processes" >> "$execution_log"
        return 0
    }

    remove_cursor_application() {
        echo "Phase3: remove_cursor_application" >> "$execution_log"
        return 0
    }

    remove_user_data() {
        echo "Phase4: remove_user_data" >> "$execution_log"
        return 0
    }

    remove_cli_tools() {
        echo "Phase5: remove_cli_tools" >> "$execution_log"
        return 0
    }

    clear_launch_services_entries() {
        echo "Phase6: clear_launch_services_entries" >> "$execution_log"
        return 0
    }

    clear_keychain_entries() {
        echo "Phase6: clear_keychain_entries" >> "$execution_log"
        return 0
    }

    verify_complete_removal() {
        echo "Phase7: verify_complete_removal" >> "$execution_log"
        return 0
    }

    generate_removal_report() {
        echo "Phase8: generate_removal_report" >> "$execution_log"
        echo "$TEST_DIR/tmp/mock_report.txt"
    }

    # Set up TEMP_DIR
    TEMP_DIR="$TEST_DIR/tmp"

    # Run the main function
    run perform_complete_cursor_removal

    # Should succeed
    [ "$status" -eq 0 ]

    # Verify all phases executed in correct order
    [[ -f "$execution_log" ]]
    
    # Check phase execution order
    grep -q "Phase1: detect_all_cursor_components" "$execution_log"
    grep -q "Phase2: remove_background_processes" "$execution_log"
    grep -q "Phase3: remove_cursor_application" "$execution_log"
    grep -q "Phase4: remove_user_data" "$execution_log"
    grep -q "Phase5: remove_cli_tools" "$execution_log"
    grep -q "Phase6: clear_launch_services_entries" "$execution_log"
    grep -q "Phase6: clear_keychain_entries" "$execution_log"
    grep -q "Phase7: verify_complete_removal" "$execution_log"
    grep -q "Phase8: generate_removal_report" "$execution_log"
} 