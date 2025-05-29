#!/usr/bin/env bats

@test "simple test" {
    [ "$(echo hello)" = "hello" ]
}

@test "another test" {
    run echo "hello world"
    [ "$status" -eq 0 ]
    [ "$output" = "hello world" ]
}
