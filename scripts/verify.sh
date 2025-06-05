#!/bin/bash
# Implementation Verification Script
# Ensures all components meet quality standards

set -euo pipefail

echo "🔍 Verifying Cursor AI Editor Implementation..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counters
TESTS_PASSED=0
TESTS_FAILED=0

# Helper function for test results
check_result() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ $2${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}❌ $2${NC}"
        ((TESTS_FAILED++))
    fi
}

echo "🏗️  Verifying project structure..."

# Check required directories exist
check_result "$([ -d "lib/ai" ] && echo 0 || echo 1)" "AI core components directory exists"
check_result "$([ -d "lib/lang/adapters" ] && echo 0 || echo 1)" "Language adapters directory exists"
check_result "$([ -d "lib/shadow" ] && echo 0 || echo 1)" "Shadow workspace directory exists"
check_result "$([ -d "lib/cache" ] && echo 0 || echo 1)" "Cache layer directory exists"
check_result "$([ -d "lib/ui" ] && echo 0 || echo 1)" "UI components directory exists"
check_result "$([ -d "modules/performance" ] && echo 0 || echo 1)" "Performance modules directory exists"
check_result "$([ -d "modules/integration" ] && echo 0 || echo 1)" "Integration modules directory exists"
check_result "$([ -d "tests/bench" ] && echo 0 || echo 1)" "Benchmark tests directory exists"
check_result "$([ -d "tests/unit" ] && echo 0 || echo 1)" "Unit tests directory exists"
check_result "$([ -d "tests/e2e" ] && echo 0 || echo 1)" "End-to-end tests directory exists"

echo ""
echo "🔧 Verifying configuration files..."

# Check configuration files
check_result "$([ -f ".eslintrc.json" ] && echo 0 || echo 1)" "ESLint configuration exists"
check_result "$([ -f "jest.config.js" ] || [ -f "jest.config.enhanced.js" ] && echo 0 || echo 1)" "Jest configuration exists"
check_result "$([ -f ".vscode/settings.json" ] && echo 0 || echo 1)" "VS Code settings exist"
check_result "$([ -f ".github/workflows/ci.yml" ] && echo 0 || echo 1)" "CI/CD workflow exists"

echo ""
echo "📦 Verifying dependencies..."

# Check Node.js and npm
if command -v node >/dev/null 2>&1; then
    NODE_VERSION=$(node --version)
    echo -e "${GREEN}✅ Node.js installed: $NODE_VERSION${NC}"
    ((TESTS_PASSED++))
else
    echo -e "${RED}❌ Node.js not found${NC}"
    ((TESTS_FAILED++))
fi

if command -v npm >/dev/null 2>&1; then
    NPM_VERSION=$(npm --version)
    echo -e "${GREEN}✅ npm installed: $NPM_VERSION${NC}"
    ((TESTS_PASSED++))
else
    echo -e "${RED}❌ npm not found${NC}"
    ((TESTS_FAILED++))
fi

# Check package.json has required scripts
if [ -f "package.json" ]; then
    echo "📄 Checking package.json scripts..."
    REQUIRED_SCRIPTS=("test" "lint")
    
    for script in "${REQUIRED_SCRIPTS[@]}"; do
        if npm run -- "$script" --dry-run >/dev/null 2>&1; then
            check_result 0 "Script '$script' configured"
        else
            check_result 1 "Script '$script' missing"
        fi
    done
fi

echo ""
echo "🧪 Running available tests..."

# Run linting if available
if npm run lint --dry-run >/dev/null 2>&1; then
    echo "🔍 Running ESLint..."
    if npm run lint >/dev/null 2>&1; then
        check_result 0 "ESLint passes"
    else
        check_result 1 "ESLint failed"
        echo -e "${YELLOW}⚠️  Run 'npm run lint' for details${NC}"
    fi
fi

# Run unit tests if available
if npm run test --dry-run >/dev/null 2>&1; then
    echo "🧪 Running unit tests..."
    if npm test >/dev/null 2>&1; then
        check_result 0 "Unit tests pass"
    else
        check_result 1 "Unit tests failed"
        echo -e "${YELLOW}⚠️  Run 'npm test' for details${NC}"
    fi
fi

# Final summary
echo ""
echo "📊 Verification Summary"
echo "================================"
echo -e "✅ Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "❌ Tests Failed: ${RED}$TESTS_FAILED${NC}"
echo "================================"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 All verifications passed! Setup ready for implementation.${NC}"
    exit 0
else
    echo -e "${YELLOW}⚠️  $TESTS_FAILED verification(s) failed. This is expected before implementation.${NC}"
    echo ""
    echo "📝 Next steps:"
    echo "  1. Run setup: ./scripts/setup.sh"
    echo "  2. Begin implementation following docs/roadmap.md"
    echo "  3. Re-run verification after each milestone"
    exit 1
fi
