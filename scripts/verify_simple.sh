#!/bin/bash

################################################################################
# Simplified Phase 1 Verification Script
################################################################################

set -euo pipefail

readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly NC='\033[0m'

declare -i errors=0

echo -e "${GREEN}Phase 1 Verification: Requirements Discovery${NC}"
echo "=================================================="

# Check deliverable exists
if [[ -f "docs/analysis.md" ]]; then
    echo -e "${GREEN}✓${NC} Analysis document exists"
else
    echo -e "${RED}✗${NC} Analysis document missing"
    ((errors++))
fi

# Check required sections
analysis_file="docs/analysis.md"
if [[ -f "$analysis_file" ]]; then
    # Essential content checks
    if grep -q "Bottleneck Analysis" "$analysis_file"; then
        echo -e "${GREEN}✓${NC} Bottleneck Analysis section found"
    else
        echo -e "${RED}✗${NC} Bottleneck Analysis missing"
        ((errors++))
    fi
    
    if grep -q "Impact.*Effort.*Matrix" "$analysis_file"; then
        echo -e "${GREEN}✓${NC} Impact-vs-Effort Matrix found"
    else
        echo -e "${RED}✗${NC} Impact-vs-Effort Matrix missing"
        ((errors++))
    fi
    
    if grep -q "P1.*Critical" "$analysis_file"; then
        echo -e "${GREEN}✓${NC} Priority levels found"
    else
        echo -e "${RED}✗${NC} Priority levels missing"
        ((errors++))
    fi
    
    if grep -q "2-8s.*<0.5s" "$analysis_file"; then
        echo -e "${GREEN}✓${NC} Quantified latency targets found"
    else
        echo -e "${RED}✗${NC} Quantified latency targets missing"
        ((errors++))
    fi
    
    if grep -q "70%.*95%" "$analysis_file"; then
        echo -e "${GREEN}✓${NC} Accuracy improvement targets found"
    else
        echo -e "${RED}✗${NC} Accuracy targets missing"
        ((errors++))
    fi
    
    if grep -q "User Reports\|Forum Analysis" "$analysis_file"; then
        echo -e "${GREEN}✓${NC} Real-world user data integration found"
    else
        echo -e "${RED}✗${NC} User data integration missing"
        ((errors++))
    fi
    
    if grep -q "Next Phase" "$analysis_file"; then
        echo -e "${GREEN}✓${NC} Next phase recommendations found"
    else
        echo -e "${RED}✗${NC} Next phase recommendations missing"
        ((errors++))
    fi
    
    # Word count check
    word_count=$(wc -w < "$analysis_file" 2>/dev/null || echo 0)
    
    if (( word_count > 1000 )); then
        echo -e "${GREEN}✓${NC} Document is comprehensive ($word_count words)"
    else
        echo -e "${RED}✗${NC} Document too brief ($word_count words, expected >1000)"
        ((errors++))
    fi
fi

echo "=================================================="

# Final summary
if (( errors == 0 )); then
    echo -e "${GREEN}SUCCESS: Phase 1 verification PASSED${NC}"
    echo -e "${GREEN}Ready for Phase 2: Architecture Design${NC}"
    exit 0
else
    echo -e "${RED}FAILED: $errors error(s) must be resolved${NC}"
    exit 1
fi
