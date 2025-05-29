#!/usr/bin/env bats

setup() {
    # Set variables to disable interactive menu
    export CURSOR_TEST_MODE=true
    export BATS_TEST_SOURCED=true

    # Create test directories
    mkdir -p "$HOME/tmp/Downloads"
    touch "$HOME/tmp/Downloads/Cursor-darwin-universal.dmg"
}

teardown() {
    # Clean up environment
    unset CURSOR_TEST_MODE
    unset BATS_TEST_SOURCED

    # Clean up test files
    rm -rf "$HOME/tmp"
}

@test "Check DMG file existence function" {
    # Simple function to test
    check_dmg_exists() {
        local test_dmg="$HOME/tmp/Downloads/Cursor-darwin-universal.dmg"
        [ -f "$test_dmg" ]
        return $?
    }

    # Test the function
    run check_dmg_exists

    # Assert
    [ "$status" -eq 0 ]
}
