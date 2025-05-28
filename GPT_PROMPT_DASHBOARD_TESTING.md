# GPT Prompt for Cursor AI: Dashboard Production Testing & Error Resolution

## Objective
Execute comprehensive production testing of the **Cline AI Dashboard** within the VSCode IDE environment, systematically identify and resolve all runtime, linting, and build errors using strict adherence to established error-fixing and directory management protocols.

## Primary Tasks & Execution Sequence

### Phase 1: Production Environment Setup & Build Verification

**Task 1.1: Environment Preparation**
```bash
# Navigate to dashboard directory
cd ui/dashboard

# Verify and install dependencies
npm install --production=false

# Execute production build with error capture
npm run build 2>&1 | tee build-log.txt

# Start production preview server
npm run preview
```

**Task 1.2: Build Integrity Verification**
- Confirm production build generates optimized assets in `dist/` directory
- Verify preview server serves correctly on designated port
- Document any build warnings or performance optimization suggestions
- Capture bundle size metrics and initial load performance data

### Phase 2: Comprehensive Error Detection & Analysis Protocol

**Task 2.1: Systematic Linting Analysis**
```bash
# Execute comprehensive ESLint analysis
npx eslint . --ext .js,.jsx --format=json > lint-report.json
npx eslint . --ext .js,.jsx --fix

# Generate detailed linting report
npx eslint . --ext .js,.jsx --format=html > lint-report.html
```

**Task 2.2: Test Suite Execution**
```bash
# Execute complete test suite with coverage
npm test -- --coverage --verbose --watchAll=false

# Run tests with detailed error reporting
npm test -- --passWithNoTests=false --testPathPattern=".*\.test\.(js|jsx)$"

# Generate test coverage report
npm test -- --coverage --coverageReporters=html,text,lcov
```

**Task 2.3: Runtime Error Detection & Browser Console Analysis**
```bash
# Start development server for runtime testing
npm run dev

# Access dashboard at http://localhost:3000
# Monitor browser console for JavaScript errors, warnings, and performance issues
# Execute comprehensive functionality testing across all dashboard features
```

### Phase 3: Systematic Error Resolution Protocol Implementation

**CRITICAL: Follow `@my-error-fixing-protocols.mdc` & `@my-directory-management-protocols.mdc` EXACTLY**

**Step 3.1: Error Categorization & Prioritization**
For each identified error, perform the following sequence:

1. **Error Isolation & Context Capture**
   - Document complete error messages, stack traces, and reproduction steps
   - Identify error categories: runtime, linting, build, import, or configuration errors
   - Capture environment context (Node.js version, npm version, browser details)

2. **Root Cause Analysis (RCA)**
   - Investigate code history using `git blame` for recent changes
   - Analyze dependency versions and compatibility issues
   - Examine configuration files: `vite.config.js`, `jest.config.js`, `.eslintrc.js`, `babel.config.js`
   - Check import/export statements and module resolution paths

**Step 3.2: Apply Recursive Error Resolution Algorithm**

```
FOR EACH ERROR:
  1. Checkpoint current state using git
  2. Attempt 1 (Internal): Apply minimal, atomic fix targeting specific root cause
  3. Verify fix: Run tests, linting, and build verification
  4. IF verification fails:
     - Revert changes
     - Refine analysis and hypothesis
     - Attempt 2 (Internal): Apply revised minimal fix
     - Verify fix again
  5. IF both internal attempts fail:
     - Revert changes
     - Research vetted external solutions
     - Evaluate solutions based on: effectiveness, minimalism, maintainability, performance, security
     - Attempt 3 (External): Implement optimal external solution
     - Verify fix
  6. IF all attempts fail:
     - Document failure and escalate
     - Move to next error
```

**Step 3.3: Specific Error Resolution Targets**

1. **Import/Module Resolution Errors**
   - Verify all component imports use correct relative paths
   - Ensure UI component barrel exports are properly configured
   - Validate that all imported modules exist and are accessible

2. **Runtime JavaScript Errors**
   - Fix undefined variable references
   - Resolve function call errors and missing method implementations
   - Address React component lifecycle and hook dependency issues

3. **Linting Violations**
   - Fix ESLint rule violations following project conventions
   - Resolve code style inconsistencies
   - Address accessibility (a11y) warnings and errors

4. **Build Configuration Issues**
   - Resolve Vite configuration problems
   - Fix asset resolution and bundling issues
   - Address any dependency conflict warnings

### Phase 4: Directory Management & Code Organization Compliance

**Task 4.1: Structure Validation**
- Verify adherence to established React/Vite project conventions
- Confirm component organization in `components/`, `components/ui/`, `components/features/`
- Validate API layer structure in `lib/` directory
- Ensure test files are properly organized in `tests/` directory

**Task 4.2: Duplicate Detection & Consolidation**
- Scan entire codebase for duplicate components, utilities, or configuration files
- **STRICTLY PROHIBITED**: Creating new files when existing ones serve the same purpose
- Consolidate overlapping functionality into canonical versions
- Remove redundant code and update all references

**Task 4.3: Import Path Standardization**
- Ensure all imports use consistent relative path patterns
- Verify barrel file exports are properly maintained
- Update any absolute path imports to relative paths where appropriate

### Phase 5: Comprehensive Dashboard Functionality Validation

**Task 5.1: Feature-by-Feature Testing**
Execute systematic testing of each dashboard feature:

1. **Navigation & UI Components**
   - Test all tab navigation (Overview, Analytics, Usage Insights, etc.)
   - Verify dark mode toggle functionality
   - Confirm responsive design on multiple viewport sizes

2. **Data Visualization Components**
   - Test MetricsPanel rendering and data display
   - Verify UsageChart functionality and chart interactions
   - Confirm TokenUtilization progress bars and calculations
   - Test CostTracker budget displays and formatting

3. **Interactive Features**
   - Test model selection and switching
   - Verify settings panel functionality
   - Test budget recommendation applications
   - Confirm real-time data refresh mechanisms

4. **Error Handling & Edge Cases**
   - Test dashboard behavior with missing or invalid data
   - Verify graceful degradation when APIs are unavailable
   - Test loading states and error boundaries

**Task 5.2: Performance Validation**
- Measure initial page load time and identify optimization opportunities
- Test component re-render efficiency and memory usage
- Verify smooth animations and transitions
- Document performance metrics and suggest improvements

### Phase 6: Quality Assurance & Documentation

**Task 6.1: Accessibility Compliance**
- Verify ARIA attributes are properly implemented
- Test keyboard navigation functionality
- Confirm screen reader compatibility
- Check color contrast ratios meet WCAG guidelines

**Task 6.2: Browser Compatibility Testing**
- Test dashboard functionality in Chrome, Firefox, Safari, and Edge
- Verify responsive design across desktop, tablet, and mobile devices
- Document any browser-specific issues and implement fixes

**Task 6.3: Documentation & Reporting**
- Generate comprehensive test report documenting all identified and resolved issues
- Update component JSDoc comments with any discovered edge cases
- Document performance improvements and optimization recommendations
- Create summary of changes made and their impact

## Success Criteria

The dashboard testing is considered complete when ALL of the following conditions are met:

1. **Zero Build Errors**: Production build completes without errors
2. **Zero Runtime Errors**: Dashboard runs without JavaScript console errors
3. **Zero Linting Violations**: All ESLint rules pass without warnings
4. **All Tests Pass**: Complete test suite executes successfully with >80% coverage
5. **Full Functionality**: All dashboard features work as intended
6. **Performance Standards**: Load time <2 seconds, smooth 60fps animations
7. **Accessibility Compliance**: WCAG 2.1 AA standards met
8. **Cross-Browser Compatibility**: Consistent behavior across major browsers

## Critical Implementation Requirements

### Error Resolution Standards
- **Maximum 2 internal fix attempts** per error before seeking external solutions
- **Atomic changes only**: Each fix must target one specific issue
- **Verification after each attempt**: Run full test suite and build process
- **No functionality loss**: Fixes must not break existing features
- **No placeholder code**: All implementations must be complete and functional

### Directory Management Compliance
- **No duplicate files**: Consolidate overlapping functionality
- **Consistent import patterns**: Use established project conventions
- **Proper component organization**: Follow React best practices
- **Clean file structure**: Remove obsolete files and update references

### Code Quality Standards
- **Production-ready code only**: No mockups, simulations, or temporary solutions
- **Complete implementations**: No partial fixes or TODO comments
- **Proper error handling**: Graceful degradation and user feedback
- **Performance optimization**: Efficient rendering and minimal re-renders

## Execution Protocol

1. **Begin with Phase 1** and proceed sequentially through all phases
2. **Document all errors** found during each phase before attempting fixes
3. **Apply error-fixing protocols strictly** - no deviations from the established algorithm
4. **Verify each fix completely** before proceeding to the next error
5. **Maintain detailed logs** of all changes made and their impact
6. **Test comprehensively** after each phase completion
7. **Report final status** with metrics and recommendations

This prompt ensures systematic, thorough testing and error resolution of the Cline AI Dashboard while maintaining the highest code quality standards and adhering to established protocols. 