#!/bin/bash
# Simple script to run the cursor uninstaller test suite

# Define color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
BOLD='\033[1m'

echo -e "${BLUE}${BOLD}CURSOR UNINSTALLER TEST RUNNER${NC}"
echo -e "Running fixed test suite with improved reliability\n"

# Set test mode flags globally to prevent hanging
export CURSOR_TEST_MODE=true
export BATS_TEST_SOURCED=1
export TEST_MODE=true

# Create tmp directory for test artifacts if needed
mkdir -p ./tmp 2>/dev/null

# Run the test suite
if bats ./run_test_suite.bats; then
  echo -e "\n${GREEN}${BOLD}✅ All tests passed successfully!${NC}"
  echo -e "${YELLOW}See tests/FIX_ANALYSIS.md for details on the test suite fixes.${NC}"
  exit 0
else
  echo -e "\n${RED}${BOLD}❌ Some tests failed.${NC}"
  echo -e "${YELLOW}Review the output above for details.${NC}"
  exit 1
fi
