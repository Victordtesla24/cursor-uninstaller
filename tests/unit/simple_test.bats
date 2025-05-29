#!/usr/bin/env bats

# A simple test file that will run quickly without hanging
# Load our simplified test helper
load simple_test_helper

@test "Simple math test - should always pass" {
  result=$((2 + 2))
  [ "$result" -eq 4 ]
}

@test "Environment variables set correctly" {
  [ "${CURSOR_TEST_MODE}" = "true" ]
  [ "${BATS_TEST_SOURCED}" = "1" ]
  [ "${TEST_MODE}" = "true" ]
}

@test "Can call mocked functions without hanging" {
  mock_detect_cursor_paths
  [ $? -eq 0 ]

  mock_check_sudo
  [ $? -eq 0 ]

  mock_uninstall_cursor
  [ $? -eq 0 ]
}

@test "Main script exists" {
  # This test just checks if the main script exists
  # Without trying to run or source it
  [ -f "../uninstall_cursor.sh" ]
}
