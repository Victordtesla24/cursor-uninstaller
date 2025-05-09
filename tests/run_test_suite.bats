#!/usr/bin/env bats

# This is the main test suite that runs all other test files

# Define color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# The list of all test files to run
TEST_FILES=(
    "very_simple_test.bats"
    "basic_test.bats"
    "test_path_functions.bats"
    "test_performance_functions.bats"
    "test_project_environments.bats"
    "test_dmg_installation.bats"
    "test_uninstallation.bats"
    "test_documentation.bats"
)

# Create a setup function to display information
setup() {
    local test_name=${BATS_TEST_DESCRIPTION}
    echo -e "\n${BLUE}${BOLD}Running test suite: ${test_name}${NC}"
}

# Define a helper function to run a test file
run_test_file() {
    local test_file="$1"
    local file_name=$(basename "$test_file")

    echo -e "\n${YELLOW}${BOLD}Running tests from: ${file_name}${NC}"

    if [ -f "$test_file" ]; then
        bats "$test_file"
        return $?
    else
        echo -e "${RED}Error: Test file $test_file not found${NC}"
        return 1
    fi
}

# Create a test to check basic environment
@test "Checking test environment setup" {
    [ -f "uninstall_cursor.sh" ]
    [ -x "uninstall_cursor.sh" ]
    [ -d "." ]
}

# Create a test that runs all the test files
@test "Running all test files" {
    local failed_files=()
    local passed_files=()
    local total_tests=0
    local passed_tests=0

    for test_file in "${TEST_FILES[@]}"; do
        # Verify the file exists
        if [ ! -f "$test_file" ]; then
            echo -e "${RED}Warning: Test file $test_file not found, skipping${NC}"
            continue
        fi

        # Count tests in the file
        local tests_in_file=$(grep -c "@test" "$test_file")
        total_tests=$((total_tests + tests_in_file))

        # Run the test file and capture the result
        echo -e "\n${YELLOW}${BOLD}Running: ${test_file} (${tests_in_file} tests)${NC}"
        if run_test_file "$test_file"; then
            passed_files+=("$test_file")
            passed_tests=$((passed_tests + tests_in_file))
            echo -e "${GREEN}✓ All tests in ${test_file} passed${NC}"
        else
            failed_files+=("$test_file")
            echo -e "${RED}✗ Some tests in ${test_file} failed${NC}"
        fi
    done

    # Display a summary
    echo -e "\n${BOLD}${BLUE}TEST SUITE SUMMARY:${NC}"
    echo -e "${BOLD}Total test files:${NC} ${#TEST_FILES[@]}"
    echo -e "${BOLD}Passed test files:${NC} ${#passed_files[@]}"
    echo -e "${BOLD}Failed test files:${NC} ${#failed_files[@]}"
    echo -e "${BOLD}Total tests:${NC} ${total_tests}"
    echo -e "${BOLD}Passed tests:${NC} ${passed_tests}"
    echo -e "${BOLD}Failed tests:${NC} $((total_tests - passed_tests))"

    # If any test files failed, list them
    if [ ${#failed_files[@]} -gt 0 ]; then
        echo -e "\n${RED}${BOLD}FAILED TEST FILES:${NC}"
        for failed_file in "${failed_files[@]}"; do
            echo -e "${RED}✗ ${failed_file}${NC}"
        done
        return 1
    fi

    # All tests passed
    echo -e "\n${GREEN}${BOLD}ALL TESTS PASSED SUCCESSFULLY!${NC}"
    return 0
}

# Create a test to verify test coverage
@test "Verify test coverage" {
    # Test categories that should be covered
    local categories=(
        "path resolution"
        "error handling"
        "uninstallation"
        "performance optimization"
        "project environment"
        "DMG installation"
        "documentation"
    )

    local missing_categories=()

    for category in "${categories[@]}"; do
        # Check if any test file covers this category
        local found=false
        for test_file in "${TEST_FILES[@]}"; do
            if grep -q -i "$category" "$test_file"; then
                found=true
                break
            fi
        done

        if [ "$found" = false ]; then
            missing_categories+=("$category")
        fi
    done

    # If any categories are missing, fail the test
    if [ ${#missing_categories[@]} -gt 0 ]; then
        echo -e "\n${RED}${BOLD}MISSING TEST COVERAGE:${NC}"
        for missing_category in "${missing_categories[@]}"; do
            echo -e "${RED}✗ No tests found for: ${missing_category}${NC}"
        done
        return 1
    fi

    # All categories covered
    echo -e "\n${GREEN}${BOLD}TEST COVERAGE COMPLETE:${NC}"
    for category in "${categories[@]}"; do
        echo -e "${GREEN}✓ ${category}${NC}"
    done
    return 0
}

# Instructions for running the test suite
@test "Display test suite usage instructions" {
    echo
    echo -e "${BLUE}${BOLD}USING THE TEST SUITE:${NC}"
    echo -e "Run all tests:${BOLD} bats tests/run_test_suite.bats${NC}"
    echo -e "Run a specific test file:${BOLD} bats tests/test_specific_file.bats${NC}"
    echo -e "Run with detailed output:${BOLD} bats --verbose tests/run_test_suite.bats${NC}"
    echo
    echo -e "${YELLOW}${BOLD}NOTE:${NC} Individual test files can be run directly using:"
    echo -e "${BOLD}bats tests/test_dmg_installation.bats${NC}"
    echo
}
