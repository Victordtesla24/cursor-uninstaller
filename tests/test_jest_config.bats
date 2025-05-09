#!/usr/bin/env bats

# Test to verify Jest configuration
@test "Jest configuration should be only in jest.config.js and not in package.json" {
    # Check that jest.config.js exists
    [ -f "$BATS_TEST_DIRNAME/../ui/dashboard/jest.config.js" ]

    # Check that package.json doesn't have a jest configuration section
    ! grep -q '"jest": {' "$BATS_TEST_DIRNAME/../ui/dashboard/package.json"
}
