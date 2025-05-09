#!/usr/bin/env bats

# Super minimal test without loading test_helper
@test "True check" {
  echo "This test should run"
  [ true ]
}
