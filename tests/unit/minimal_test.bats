#!/usr/bin/env bats

# Minimal test to debug BATS loading issues
load ../helpers/test_helper

@test "Check script exists" {
  echo "Starting test"
  [ -f "uninstall_cursor.sh" ]
  echo "Test complete"
}
