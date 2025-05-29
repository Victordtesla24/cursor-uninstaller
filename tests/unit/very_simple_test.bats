#!/usr/bin/env bats

@test "simple addition using bc" {
  result="$(echo 2+2 | bc)"
  [ "$result" -eq 4 ]
}

@test "simple arithmetic" {
  [ $(( 2 + 2 )) -eq 4 ]
}

@test "file existence" {
  [ -f "uninstall_cursor.sh" ]
}
