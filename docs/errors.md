vicd@Vics-MacBook-Air cursor-uninstaller % ./scripts/syntax_and_shellcheck.sh         

╔══════════════════════════════════════════════════════════════════════════════╗
║                  Comprehensive Code Validation & Analysis                    ║
║      Shell Scripts • JavaScript • JSON • Linting • Dependencies • Structure  ║
╚══════════════════════════════════════════════════════════════════════════════╝


=== File Discovery & Inventory ===
ℹ Scanning project directories: scripts modules lib bin tests docs src
ℹ Excluding: node_modules .venv .git .cursor .vscode .cline build dist coverage __pycache__ .pytest_cache .mypy_cache *.egg-info .tox tmp temp .DS_Store *.log *.tmp .cache .next vendor bower_components .sass-cache
✓ Discovered 1 shell scripts
✓ Discovered 30 JavaScript files
✓ Discovered 5 JSON files
✓ Discovered 3 configuration files
ℹ Total files to validate: 36
Shell Scripts:
  • scripts/syntax_and_shellcheck.sh
JavaScript Files:
  • modules/performance/index.js
  • modules/performance/latency-tracker.js
  • lib/ui/index.js
  • lib/cache/result-cache.js
  • lib/shadow/ipc.js
  • lib/shadow/index.js
  • lib/shadow/workspace.js
  • lib/shadow/manager.js
  • lib/lang/index.js
  • lib/lang/adapters/shell.js
  • lib/lang/adapters/javascript.js
  • lib/lang/adapters/base.js
  • lib/lang/adapters/python.js
  • lib/ai/model-selector.js
  • lib/ai/index.js
  • lib/ai/context-manager.js
  • lib/ai/controller.js
  • tests/bench/completion-latency.js
  • tests/bench/memory-usage.js
  • tests/integration/mocks/ui/index.js
  • tests/integration/mocks/mockComponents.js
  • tests/integration/mocks/componentMocks.js
  • tests/integration/ai-system-integration.test.js
  • tests/integration/basic.test.js
  • tests/integration/setupJest.js
  • tests/integration/ai-system-v2-integration.test.js
  • tests/integration/optimization.test.js
  • tests/integration/structure.test.js
  • tests/jest-setup.js
  • tests/setup.js
JSON Files:
  • tests/bench/memory-usage-report.json
  • tests/bench/completion-latency-report.json
  • ./package-lock.json
  • ./package.json
  • ./.eslintrc.json

=== Shell Script Syntax & ShellCheck Validation ===
Validating: scripts/syntax_and_shellcheck.sh ... ✓ PASS
ℹ Shell script validation: 1/1 passed

=== JavaScript Syntax & ESLint Validation ===
Validating: modules/performance/index.js ... ⚠ ESLint issues in: modules/performance/index.js

/Users/Shared/cursor/cursor-uninstaller/modules/performance/index.js
  33:19  warning  'data' is defined but never used  no-unused-vars

✖ 1 problem (0 errors, 1 warning)

Validating: modules/performance/latency-tracker.js ... ⚠ ESLint issues in: modules/performance/latency-tracker.js

/Users/Shared/cursor/cursor-uninstaller/modules/performance/latency-tracker.js
  598:29  warning  'operation' is assigned a value but never used  no-unused-vars

✖ 1 problem (0 errors, 1 warning)

Validating: lib/ui/index.js ... ✓ PASS
Validating: lib/cache/result-cache.js ... ✓ PASS
Validating: lib/shadow/ipc.js ... ⚠ ESLint issues in: lib/shadow/ipc.js

/Users/Shared/cursor/cursor-uninstaller/lib/shadow/ipc.js
  398:44  warning  'payload' is defined but never used             no-unused-vars
  407:49  warning  'payload' is defined but never used             no-unused-vars
  415:43  warning  'payload' is defined but never used             no-unused-vars
  549:25  warning  'messageId' is assigned a value but never used  no-unused-vars

✖ 4 problems (0 errors, 4 warnings)

Validating: lib/shadow/index.js ... ✓ PASS
Validating: lib/shadow/workspace.js ... ⚠ ESLint issues in: lib/shadow/workspace.js

/Users/Shared/cursor/cursor-uninstaller/lib/shadow/workspace.js
   10:9   warning  'spawn' is assigned a value but never used  no-unused-vars
  615:26  warning  'fileUri' is defined but never used         no-unused-vars
  638:27  warning  'fileUri' is defined but never used         no-unused-vars

✖ 3 problems (0 errors, 3 warnings)

Validating: lib/shadow/manager.js ... ✓ PASS
Validating: lib/lang/index.js ... ✓ PASS
Validating: lib/lang/adapters/shell.js ... ⚠ ESLint issues in: lib/lang/adapters/shell.js

/Users/Shared/cursor/cursor-uninstaller/lib/lang/adapters/shell.js
    9:7   warning  'path' is assigned a value but never used         no-unused-vars
  130:56  warning  'options' is assigned a value but never used      no-unused-vars
  195:38  warning  'options' is assigned a value but never used      no-unused-vars
  269:53  warning  'position' is defined but never used              no-unused-vars
  494:34  warning  'filePath' is defined but never used              no-unused-vars
  503:17  warning  'errorOutput' is assigned a value but never used  no-unused-vars
  528:30  warning  'error' is defined but never used                 no-unused-vars
  653:26  warning  'indentLevel' is defined but never used           no-unused-vars
Validating: lib/lang/adapters/javascript.js ... ⚠ ESLint issues in: lib/lang/adapters/javascript.js

/Users/Shared/cursor/cursor-uninstaller/lib/lang/adapters/javascript.js
  136:56  warning  'options' is assigned a value but never used      no-unused-vars
  158:18  warning  'error' is defined but never used                 no-unused-vars
  246:35  warning  'position' is defined but never used              no-unused-vars
  327:18  warning  'error' is defined but never used                 no-unused-vars
  362:18  warning  'error' is defined but never used                 no-unused-vars
  454:18  warning  'error' is defined but never used                 no-unused-vars
  462:38  warning  'options' is assigned a value but never used      no-unused-vars
  471:53  warning  Strings must use singlequote                      quotes
Validating: lib/lang/adapters/base.js ... ⚠ ESLint issues in: lib/lang/adapters/base.js

/Users/Shared/cursor/cursor-uninstaller/lib/lang/adapters/base.js
  110:15  warning  'startTime' is assigned a value but never used  no-unused-vars
  303:36  warning  'filePath' is defined but never used            no-unused-vars
  303:46  warning  'position' is defined but never used            no-unused-vars
  303:56  warning  'options' is defined but never used             no-unused-vars
  311:35  warning  'filePath' is defined but never used            no-unused-vars
  311:45  warning  'symbol' is defined but never used              no-unused-vars
  311:53  warning  'position' is defined but never used            no-unused-vars
  319:26  warning  'filePath' is defined but never used            no-unused-vars
Validating: lib/lang/adapters/python.js ... ⚠ ESLint issues in: lib/lang/adapters/python.js

/Users/Shared/cursor/cursor-uninstaller/lib/lang/adapters/python.js
    10:9   warning  'spawn' is assigned a value but never used           no-unused-vars
   213:56  warning  'options' is assigned a value but never used         no-unused-vars
   238:18  warning  'error' is defined but never used                    no-unused-vars
   334:35  warning  'position' is defined but never used                 no-unused-vars
   558:18  warning  'error' is defined but never used                    no-unused-vars
   616:56  warning  Strings must use singlequote                         quotes
   696:19  warning  'variableRegex' is assigned a value but never used   no-unused-vars
   698:19  warning  'usedVars' is assigned a value but never used        no-unused-vars
Validating: lib/ai/model-selector.js ... ⚠ ESLint issues in: lib/ai/model-selector.js

/Users/Shared/cursor/cursor-uninstaller/lib/ai/model-selector.js
   93:9  warning  'code' is assigned a value but never used         no-unused-vars
   94:9  warning  'language' is assigned a value but never used     no-unused-vars
   95:9  warning  'context' is assigned a value but never used      no-unused-vars
   96:9  warning  'tokenCount' is assigned a value but never used   no-unused-vars
   97:9  warning  'priority' is assigned a value but never used     no-unused-vars
   98:9  warning  'requestType' is assigned a value but never used  no-unused-vars
  100:9  warning  'complexity' is assigned a value but never used   no-unused-vars

Validating: lib/ai/index.js ... ✓ PASS
Validating: lib/ai/context-manager.js ... ⚠ ESLint issues in: lib/ai/context-manager.js

/Users/Shared/cursor/cursor-uninstaller/lib/ai/context-manager.js
  139:51  warning  'options' is defined but never used   no-unused-vars
  252:16  warning  'error' is defined but never used     no-unused-vars
  274:26  warning  'position' is defined but never used  no-unused-vars
  274:36  warning  'language' is defined but never used  no-unused-vars
  274:46  warning  'options' is defined but never used   no-unused-vars
  291:27  warning  'language' is defined but never used  no-unused-vars
  291:37  warning  'options' is defined but never used   no-unused-vars

Validating: lib/ai/controller.js ... ⚠ ESLint issues in: lib/ai/controller.js

/Users/Shared/cursor/cursor-uninstaller/lib/ai/controller.js
  250:41  warning  'position' is assigned a value but never used  no-unused-vars
  340:33  warning  'language' is defined but never used           no-unused-vars

✖ 2 problems (0 errors, 2 warnings)

Validating: tests/bench/completion-latency.js ... ✓ PASS
Validating: tests/bench/memory-usage.js ... ✓ PASS
Validating: tests/integration/mocks/ui/index.js ... ✓ PASS
Validating: tests/integration/mocks/mockComponents.js ... ✓ PASS
Validating: tests/integration/mocks/componentMocks.js ... ✓ PASS
Validating: tests/integration/ai-system-integration.test.js ... ✓ PASS
Validating: tests/integration/basic.test.js ... ✓ PASS
Validating: tests/integration/setupJest.js ... ⚠ ESLint issues in: tests/integration/setupJest.js

/Users/Shared/cursor/cursor-uninstaller/tests/integration/setupJest.js
  1:1  warning  Unused eslint-disable directive (no problems were reported from 'no-unused-vars')

✖ 1 problem (0 errors, 1 warning)
  0 errors and 1 warning potentially fixable with the `--fix` option.

Validating: tests/integration/ai-system-v2-integration.test.js ... ✓ PASS
Validating: tests/integration/optimization.test.js ... ✓ PASS
Validating: tests/integration/structure.test.js ... ✓ PASS
Validating: tests/jest-setup.js ... ✓ PASS
Validating: tests/setup.js ... ✓ PASS
ℹ JavaScript validation: 18/30 passed

=== JSON Syntax & Schema Validation ===
Validating: tests/bench/memory-usage-report.json ... ✓ PASS
Validating: tests/bench/completion-latency-report.json ... ✓ PASS
Validating: ./package-lock.json ... ✓ PASS
Validating: ./package.json ... ✓ PASS
Validating: ./.eslintrc.json ... ✓ PASS
ℹ JSON validation: 5/5 passed

=== Import & Dependency Validation ===
⚠ Missing sourced file in scripts/syntax_and_shellcheck.sh: 
ℹ Import validation: 1 issues found

=== Runtime & Type Error Validation ===
ℹ Validating package.json dependencies...
⚠ Main entry point missing: bin/uninstall_cursor.sh
ℹ Runtime validation: 1 issues found

=== Duplicate File & Code Detection ===
⚠ Potentially duplicate function:                     kind: 'function',
  • lib/lang/adapters/shell.js:279:                    kind: 'function',
  • lib/lang/adapters/javascript.js:549:                    kind: 'function',
  • lib/lang/adapters/python.js:840:                    kind: 'function',
⚠ Potentially duplicate function:                 kind: 'function',
  • lib/lang/adapters/shell.js:279:                    kind: 'function',
  • lib/lang/adapters/javascript.js:259:                kind: 'function',
  • lib/lang/adapters/javascript.js:549:                    kind: 'function',
⚠ Potentially duplicate function:             const timeout = setTimeout(() => {
  • lib/shadow/ipc.js:176:            const timeout = setTimeout(() => {
  • lib/shadow/workspace.js:314:            const timeout = setTimeout(() => {
⚠ Potentially duplicate function:             shellcheck.stdout.on('data', (data) => {
  • lib/lang/adapters/shell.js:505:            shellcheck.stdout.on('data', (data) => {
  • lib/lang/adapters/shell.js:558:            shellcheck.stdout.on('data', (data) => {
⚠ Potentially duplicate function:         expect(() => {
  • tests/integration/optimization.test.js:31:        expect(() => {
  • tests/integration/optimization.test.js:41:        expect(() => {
⚠ Potentially duplicate function:         return new Promise((resolve) => {
  • lib/shadow/workspace.js:313:        return new Promise((resolve) => {
  • lib/lang/adapters/shell.js:495:        return new Promise((resolve) => {
  • lib/lang/adapters/shell.js:546:        return new Promise((resolve) => {
⚠ Potentially duplicate function:       setTimeout(() => {
  • lib/ai/controller.js:256:      setTimeout(() => {
  • lib/ai/controller.js:279:      setTimeout(() => {
  • lib/ai/controller.js:400:      setTimeout(() => {
⚠ Potentially duplicate function:       this.monitoringInterval = setInterval(() => {
  • lib/ai/index.js:398:      this.monitoringInterval = setInterval(() => {
  • lib/ai/index.js:477:      this.monitoringInterval = setInterval(() => {
⚠ Potentially duplicate function:     return new Promise((resolve) => {
  • lib/shadow/workspace.js:313:        return new Promise((resolve) => {
  • lib/lang/adapters/shell.js:495:        return new Promise((resolve) => {
  • lib/lang/adapters/shell.js:546:        return new Promise((resolve) => {
⚠ Potentially duplicate function:     this.results.forEach(result => {
  • tests/bench/completion-latency.js:291:    this.results.forEach(result => {
  • tests/bench/memory-usage.js:327:    this.results.forEach(result => {
⚠ Potentially duplicate function:   afterAll(async () => {
  • tests/integration/ai-system-integration.test.js:27:  afterAll(async () => {
  • tests/integration/ai-system-integration.test.js:324:  afterAll(async () => {
  • tests/integration/ai-system-v2-integration.test.js:100:    afterAll(async () => {
⚠ Potentially duplicate function:   beforeAll(async () => {
  • tests/integration/ai-system-integration.test.js:12:  beforeAll(async () => {
  • tests/integration/ai-system-integration.test.js:317:  beforeAll(async () => {
  • tests/integration/ai-system-v2-integration.test.js:29:    beforeAll(async () => {
⚠ Potentially duplicate function: al
  • scripts/syntax_and_shellcheck.sh:43:log_critical() { echo -e "${RED}🚨 CRITICAL: ${1}${NC}"; }
  • scripts/syntax_and_shellcheck.sh:129:validate_shell_scripts() {
  • scripts/syntax_and_shellcheck.sh:175:validate_javascript_files() {
⚠ Potentially duplicate function: ality
  • lib/shadow/workspace.js:107:            // 6. Verify workspace functionality
  • lib/lang/adapters/base.js:2: * Base Language Adapter - Abstract interface for all language-specific functionality
  • tests/integration/basic.test.js:3: * Tests core functionality
⚠ Potentially duplicate function: calculateSum
  • lib/ai/controller.js:318:        'function ': 'calculateSum(a, b) { return a + b; }',
  • tests/bench/completion-latency.js:24:        code: 'function calculateSum(a, b) {\n  return ',
  • tests/integration/ai-system-v2-integration.test.js:396:                function calculateSum(a, b) {
⚠ Potentially duplicate function: definition
  • lib/lang/adapters/shell.js:280:                    definition: functionMatch.definition,
  • lib/lang/adapters/javascript.js:540:            // Look for function definition
  • lib/lang/adapters/python.js:337:        // Extract all function definitions
⚠ Potentially duplicate function: definitions
  • lib/lang/adapters/python.js:337:        // Extract all function definitions
  • lib/lang/adapters/python.js:407:     * Extract function definitions
  • lib/lang/adapters/python.js:735:            // Add trailing commas in function definitions
⚠ Potentially duplicate function: main
  • scripts/syntax_and_shellcheck.sh:653:main() {
  • tests/bench/completion-latency.js:311:async function main() {
  • tests/bench/memory-usage.js:361:async function main() {
⚠ Potentially duplicate function: Match
  • lib/lang/adapters/shell.js:275:            const functionMatch = functions.find(f => f.name === symbol);
  • lib/lang/adapters/shell.js:276:            if (functionMatch) {
  • lib/lang/adapters/shell.js:280:                    definition: functionMatch.definition,
⚠ Potentially duplicate function: Matches
  • lib/lang/adapters/javascript.js:697:        const functionMatches = beforeContent.match(/function\s+\w+/g);
  • lib/lang/adapters/javascript.js:700:        if (functionMatches && functionMatches.length > 0) {
⚠ Potentially duplicate function: Pattern
  • lib/lang/adapters/shell.js:369:        const functionPattern = /^(\w+)\s*\(\s*\)\s*\{/gm;
  • lib/lang/adapters/shell.js:372:        while ((match = functionPattern.exec(content)) !== null) {
⚠ Potentially duplicate function: Regex
  • lib/lang/adapters/javascript.js:204:        const namedExportRegex = /export\s+(?:const|let|var|function|class)\s+(\w+)/g;
  • lib/lang/adapters/javascript.js:217:        const defaultExportRegex = /export\s+default\s+(?:(?:function|class)\s+(\w+)|(\w+))/g;
  • lib/lang/adapters/javascript.js:250:        const functionRegex = /(?:function\s+(\w+)|(?:const|let|var)\s+(\w+)\s*=\s*(?:function|async\s+function|\([^)]*\)\s*=>))/g;
⚠ Potentially duplicate function: s
  • scripts/syntax_and_shellcheck.sh:39:log_info() { echo -e "${BLUE}ℹ ${1}${NC}"; }
  • scripts/syntax_and_shellcheck.sh:40:log_success() { echo -e "${GREEN}✓ ${1}${NC}"; }
  • scripts/syntax_and_shellcheck.sh:41:log_warning() { echo -e "${YELLOW}⚠ ${1}${NC}"; }
⚠ Potentially duplicate function: signature
  • lib/lang/adapters/javascript.js:653:     * Extract function signature
  • lib/lang/adapters/javascript.js:659:        // Look for function signature
  • lib/lang/adapters/javascript.js:660:        const signatureMatch = afterStart.match(/function\s+\w+\s*\([^)]*\)|(?:const|let|var)\s+\w+\s*=\s*(?:function\s*\([^)]*\)|async\s+function\s*\([^)]*\)|\([^)]*\)\s*=>)/);
⚠ Potentially duplicate function: to
  • scripts/syntax_and_shellcheck.sh:525:validate_directory_structure() {
  • modules/performance/index.js:298:     * @param {Function} operation - Operation function to track
  • modules/performance/index.js:725:// Factory functions and utilities
ℹ Duplicate detection: 25 issues found

=== Directory Structure Integrity ===
./scripts/syntax_and_shellcheck.sh: line 586: [[: 0
0: syntax error in expression (error token is "0")
./scripts/syntax_and_shellcheck.sh: line 586: [[: 0
0: syntax error in expression (error token is "0")
./scripts/syntax_and_shellcheck.sh: line 586: [[: 0
0: syntax error in expression (error token is "0")
./scripts/syntax_and_shellcheck.sh: line 586: [[: 0
0: syntax error in expression (error token is "0")
./scripts/syntax_and_shellcheck.sh: line 586: [[: 0
0: syntax error in expression (error token is "0")
./scripts/syntax_and_shellcheck.sh: line 586: [[: 0
0: syntax error in expression (error token is "0")
./scripts/syntax_and_shellcheck.sh: line 586: [[: 0
0: syntax error in expression (error token is "0")
./scripts/syntax_and_shellcheck.sh: line 586: [[: 0
0: syntax error in expression (error token is "0")
./scripts/syntax_and_shellcheck.sh: line 586: [[: 0
0: syntax error in expression (error token is "0")
./scripts/syntax_and_shellcheck.sh: line 586: [[: 0
0: syntax error in expression (error token is "0")
./scripts/syntax_and_shellcheck.sh: line 586: [[: 0
0: syntax error in expression (error token is "0")
./scripts/syntax_and_shellcheck.sh: line 586: [[: 0
0: syntax error in expression (error token is "0")
./scripts/syntax_and_shellcheck.sh: line 586: [[: 0
0: syntax error in expression (error token is "0")
./scripts/syntax_and_shellcheck.sh: line 586: [[: 0
0: syntax error in expression (error token is "0")
./scripts/syntax_and_shellcheck.sh: line 586: [[: 0
0: syntax error in expression (error token is "0")
./scripts/syntax_and_shellcheck.sh: line 586: [[: 0
0: syntax error in expression (error token is "0")
./scripts/syntax_and_shellcheck.sh: line 586: [[: 0
0: syntax error in expression (error token is "0")
./scripts/syntax_and_shellcheck.sh: line 586: [[: 0
0: syntax error in expression (error token is "0")
./scripts/syntax_and_shellcheck.sh: line 586: [[: 0
0: syntax error in expression (error token is "0")
./scripts/syntax_and_shellcheck.sh: line 586: [[: 0
0: syntax error in expression (error token is "0")
./scripts/syntax_and_shellcheck.sh: line 586: [[: 0
0: syntax error in expression (error token is "0")
./scripts/syntax_and_shellcheck.sh: line 586: [[: 0
0: syntax error in expression (error token is "0")
./scripts/syntax_and_shellcheck.sh: line 586: [[: 0
0: syntax error in expression (error token is "0")
./scripts/syntax_and_shellcheck.sh: line 586: [[: 0
0: syntax error in expression (error token is "0")
ℹ Structure validation: 0 issues found

=== Comprehensive Validation Summary ===
Performance Metrics:
  • Total execution time: 10s
  • Files discovered: 36
  • Files processed: 36
  • Processing rate: 3 files/sec

Validation Results:
  • Shell scripts: 1
  • JavaScript files: 30
  • JSON files: 5
  • Configuration files: 3

Error Summary:
  • Syntax errors: 0
  • Linter issues: 12
  • JSON errors: 0
  • Import problems: 1
  • Runtime issues: 1
  • Duplicates found: 25
  • Structure issues: 0
  • Total issues: 39
✗ Validation completed with 39 issues
ℹ Codebase health: NEEDS ATTENTION

Debugging Recommendations:
  • Review linter output for code quality
  • Verify all import paths and dependencies
  • Check runtime configuration and dependencies
  • Consolidate duplicate code per .clinerules protocols
vicd@Vics-MacBook-Air cursor-uninstaller % 