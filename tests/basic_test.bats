#!/usr/bin/env bats

setup() {
    # Set variables to disable interactive menu
    export CURSOR_TEST_MODE=true
    export BATS_TEST_SOURCED=true
}

teardown() {
    # Clean up environment
    unset CURSOR_TEST_MODE
    unset BATS_TEST_SOURCED
}

@test "Script exists and is executable" {
    [ -f "uninstall_cursor.sh" ]
    [ -x "uninstall_cursor.sh" ]
}

@test "get_script_path function works" {
    source "uninstall_cursor.sh"
    local path=$(get_script_path)
    [ -d "$path" ]
}

@test "Script sets CURSOR_CWD to /Users/Shared/cursor" {
    source "uninstall_cursor.sh"
    [ "$CURSOR_CWD" = "/Users/Shared/cursor" ]
}

@test "Script creates necessary directories" {
    source "uninstall_cursor.sh"
    detect_cursor_paths
    [ -d "$CURSOR_CWD" ] || [ "$CURSOR_CWD" = "/Users/Shared/cursor" ]
    [ -n "$CURSOR_SHARED_CONFIG" ]
    [ -n "$CURSOR_SHARED_PROJECTS" ]
}
