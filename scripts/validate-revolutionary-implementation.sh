#!/bin/bash

# =============================================================================
# Project Implementation Validation Script
# Validates real project components and legitimate AI capabilities
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

print_header() {
    echo ""
    echo -e "${CYAN}================================================================${NC}"
    echo -e "${WHITE}🔍 PROJECT IMPLEMENTATION VALIDATION${NC}"
    echo -e "${CYAN}================================================================${NC}"
    echo -e "${BLUE}Validating Real Project Components and Existing AI Features${NC}"
    echo -e "${CYAN}================================================================${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

validate_real_features_in_file() {
    local file="$1"
    local description="$2"
    
    if [[ ! -f "$file" ]]; then
        print_error "File not found: $file"
        return 1
    fi
    
    echo -e "${BLUE}Validating $description: $file${NC}"
    
    # Check for legitimate project indicators
    local real_features=(
        "test|testing|spec"
        "implementation|develop|code"
        "javascript|typescript|js|node"
        "performance|optimization|feature"
        "project|application|system"
        "documentation|requirements|design"
    )
    
    local feature_names=(
        "Testing References"
        "Implementation Content"  
        "Technology Stack"
        "Performance/Features"
        "Project Structure"
        "Documentation Standards"
    )
    
    local found_count=0
    
    for i in "${!real_features[@]}"; do
        local pattern="${real_features[$i]}"
        local name="${feature_names[$i]}"
        
        if grep -qiE "$pattern" "$file"; then
            print_success "Found feature: $name"
            found_count=$((found_count + 1))
        else
            print_info "Not found: $name (pattern: $pattern)"
        fi
    done
    
    if [[ $found_count -ge 3 ]]; then
        print_success "Real project features validated in $description ($found_count/6)"
        return 0
    else
        print_warning "Limited real features found in $description ($found_count/6)"
        return 1
    fi
}

validate_project_structure() {
    echo -e "${BLUE}Validating project structure${NC}"
    
    local required_dirs=(
        "lib"
        "tests"
        "scripts"
        "docs"
    )
    
    local found_dirs=0
    
    for dir in "${required_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            print_success "Directory exists: $dir"
            found_dirs=$((found_dirs + 1))
        else
            print_warning "Directory missing: $dir"
        fi
    done
    
    return $((${#required_dirs[@]} - found_dirs))
}

validate_package_configuration() {
    echo -e "${BLUE}Validating package configuration${NC}"
    
    if [[ -f "package.json" ]]; then
        print_success "Package configuration found"
        
        # Check for real dependencies
        if grep -q "jest\|test" package.json; then
            print_success "Testing framework configured"
        fi
        
        if grep -q "eslint" package.json; then
            print_success "Linting configured"
        fi
        
        if grep -q "scripts" package.json; then
            print_success "NPM scripts configured"
        fi
        
        return 0
    else
        print_error "package.json not found"
        return 1
    fi
}

main() {
    print_header
    
    local validation_count=0
    local total_validations=0
    
    echo -e "${YELLOW}🔍 PHASE 1: PROJECT STRUCTURE VALIDATION${NC}"
    echo ""
    
    if validate_project_structure; then
        validation_count=$((validation_count + 1))
    fi
    total_validations=$((total_validations + 1))
    echo ""
    
    echo -e "${YELLOW}🔍 PHASE 2: CONFIGURATION VALIDATION${NC}"
    echo ""
    
    if validate_package_configuration; then
        validation_count=$((validation_count + 1))
    fi
    total_validations=$((total_validations + 1))
    echo ""
    
    echo -e "${YELLOW}🔍 PHASE 3: DOCUMENTATION VALIDATION${NC}"
    echo ""
    
    # Validate documentation files
    local docs=(
        "docs/analysis.md:Analysis Document"
        "docs/architecture_spec.md:Architecture Specification"
        "docs/requirements.md:Requirements Document"
        "docs/roadmap.md:Implementation Roadmap"
    )
    
    for doc_info in "${docs[@]}"; do
        IFS=':' read -r doc_path doc_desc <<< "$doc_info"
        total_validations=$((total_validations + 1))
        
        if validate_real_features_in_file "$doc_path" "$doc_desc"; then
            validation_count=$((validation_count + 1))
        fi
        echo ""
    done
    
    echo -e "${YELLOW}🔍 PHASE 4: IMPLEMENTATION VALIDATION${NC}"
    echo ""
    
    # Check for real implementation files
    local lib_files=(
        "lib/ai"
        "lib/cache"
        "lib/system"
        "lib/tools"
    )
    
    local impl_found=0
    for lib_dir in "${lib_files[@]}"; do
        if [[ -d "$lib_dir" ]]; then
            print_success "Implementation directory exists: $lib_dir"
            impl_found=$((impl_found + 1))
        else
            print_warning "Implementation directory missing: $lib_dir"
        fi
    done
    
    if [[ $impl_found -ge 2 ]]; then
        validation_count=$((validation_count + 1))
    fi
    total_validations=$((total_validations + 1))
    echo ""
    
    echo -e "${YELLOW}🔍 PHASE 5: TEST SUITE VALIDATION${NC}"
    echo ""
    
    # Check for real test files
    if [[ -d "tests" ]]; then
        local test_count
        test_count=$(find tests -name "*.js" -o -name "*.test.js" -o -name "*.spec.js" | wc -l)
        if [[ $test_count -gt 0 ]]; then
            print_success "Test files found: $test_count test files"
            validation_count=$((validation_count + 1))
        else
            print_warning "No test files found in tests directory"
        fi
    else
        print_error "Tests directory not found"
    fi
    total_validations=$((total_validations + 1))
    echo ""
    
    echo -e "${CYAN}================================================================${NC}"
    echo -e "${WHITE}📊 VALIDATION SUMMARY${NC}"
    echo -e "${CYAN}================================================================${NC}"
    echo ""
    
    local success_rate=$(( (validation_count * 100) / total_validations ))
    
    echo -e "${WHITE}Total Validations:${NC} $total_validations"
    echo -e "${WHITE}Successful Validations:${NC} $validation_count"
    echo -e "${WHITE}Success Rate:${NC} $success_rate%"
    echo ""
    
    if [[ $success_rate -ge 80 ]]; then
        echo -e "${GREEN}✅ PROJECT IMPLEMENTATION VALIDATED SUCCESSFULLY${NC}"
        echo -e "${GREEN}🚀 Real project components and structure confirmed${NC}"
        exit 0
    elif [[ $success_rate -ge 60 ]]; then
        echo -e "${YELLOW}⚠️  IMPLEMENTATION MOSTLY VALIDATED${NC}"
        echo -e "${YELLOW}🔧 Minor improvements may be needed${NC}"
        exit 1
    else
        echo -e "${RED}❌ IMPLEMENTATION NEEDS SIGNIFICANT IMPROVEMENTS${NC}"
        echo -e "${RED}🔧 Please review and fix validation issues${NC}"
        exit 2
    fi
}

# Execute validation
main "$@"
