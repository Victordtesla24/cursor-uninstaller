#!/bin/bash
# Simple script to run the cursor uninstaller test suite

# Define color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
TEST_DIR="$PROJECT_ROOT/tests"

echo -e "${BLUE}${BOLD}CURSOR UNINSTALLER TEST RUNNER${NC}"
echo -e "Running fixed test suite with improved reliability\n"

# Set test mode flags globally to prevent hanging
export CURSOR_TEST_MODE=true
export BATS_TEST_SOURCED=1
export TEST_MODE=true

# Create tmp directory for test artifacts if needed
mkdir -p "$PROJECT_ROOT/tmp" 2>/dev/null

# Change to tests directory
cd "$TEST_DIR" || {
    echo -e "${RED}${BOLD}❌ Could not change to tests directory${NC}"
    exit 1
}

# Check if BATS is available
if ! command -v bats >/dev/null 2>&1; then
    echo -e "${YELLOW}${BOLD}⚠️  BATS not found - running basic script tests instead${NC}"
    
    # Run basic script syntax checks
    echo -e "${BLUE}Running basic script validation...${NC}"
    
    test_failures=0
    
    # Test main script syntax
    if bash -n "$PROJECT_ROOT/uninstall_cursor.sh" 2>/dev/null; then
        echo -e "${GREEN}✓ Main script syntax valid${NC}"
    else
        echo -e "${RED}✗ Main script syntax errors${NC}"
        ((test_failures++))
    fi
    
    # Test module syntax
    if [[ -d "$PROJECT_ROOT/lib" ]]; then
        for module in "$PROJECT_ROOT/lib/"*.sh; do
            if [[ -f "$module" ]]; then
                if bash -n "$module" 2>/dev/null; then
                    echo -e "${GREEN}✓ Module $(basename "$module") syntax valid${NC}"
                else
                    echo -e "${RED}✗ Module $(basename "$module") syntax errors${NC}"
                    ((test_failures++))
                fi
            fi
        done
    fi
    
    # Test help functionality
    echo -e "${BLUE}Testing help functionality...${NC}"
    if timeout 5s bash "$PROJECT_ROOT/uninstall_cursor.sh" --help >/dev/null 2>&1; then
        echo -e "${GREEN}✓ Help function works${NC}"
    else
        echo -e "${RED}✗ Help function failed or timed out${NC}"
        ((test_failures++))
    fi
    
    if [[ $test_failures -eq 0 ]]; then
        echo -e "\n${GREEN}${BOLD}✅ Basic tests passed successfully!${NC}"
        exit 0
    else
        echo -e "\n${RED}${BOLD}❌ Basic tests failed with $test_failures errors.${NC}"
        exit 1
    fi
fi

# Run the comprehensive BATS test suite
test_file="unit/run_test_suite.bats"

if [[ ! -f "$test_file" ]]; then
    echo -e "${RED}${BOLD}❌ Test file not found: $test_file${NC}"
    echo -e "${YELLOW}Available test files:${NC}"
    find . -name "*.bats" -type f | head -5
    exit 1
fi

echo -e "${BLUE}Running BATS test suite: $test_file${NC}"

# Run the test suite with timeout
if timeout 60s bats "$test_file"; then
    echo -e "\n${GREEN}${BOLD}✅ All tests passed successfully!${NC}"
    echo -e "${YELLOW}See tests/FIX_ANALYSIS.md for details on the test suite fixes.${NC}"
    exit 0
else
    echo -e "\n${RED}${BOLD}❌ Some tests failed.${NC}"
    echo -e "${YELLOW}Review the output above for details.${NC}"
    exit 1
fi
