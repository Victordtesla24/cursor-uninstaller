vicd@Vics-MacBook-Air cursor-uninstaller % ./scripts/syntax_and_shellcheck.sh
ℹ Available validation tools: 4/4 (shellcheck, node, jq, python3)

╔══════════════════════════════════════════════════════════════════════════════╗
║               Enhanced Code Validation & Analysis v2.0                       ║
║   Shell • JavaScript • JSON • Python • TypeScript • Linting • Structure      ║
║                    Security Hardened • Performance Optimized                 ║
╚══════════════════════════════════════════════════════════════════════════════╝


=== File Discovery & Inventory ===
ℹ Scanning directories: scripts modules lib bin tests docs .
ℹ Excluding patterns: node_modules .venv .git .cursor .vscode .cline build dist coverage __pycache__ .pytest_cache .mypy_cache *.egg-info .tox tmp temp .DS_Store *.log *.tmp .cache .next vendor bower_components .sass-cache
ℹ Scanning for shell scripts...
ℹ Scanning for JavaScript files...
ℹ Scanning for JSON files...
ℹ Scanning for configuration files...
✓ Discovered 2 shell scripts
✓ Discovered 33 JavaScript files
✓ Discovered 7 JSON files
✓ Discovered 3 configuration files
ℹ Total files to validate: 42
Shell Scripts:
  • scripts/syntax_and_shellcheck.sh
  • scripts/test-script.sh
JavaScript Files: 33 files (too many to list)
JSON Files:
  • .eslintrc.json
  • .vscode/extensions.json
  • .vscode/settings.json
  • package-lock.json
  • package.json
  • tests/bench/completion-latency-report.json
  • tests/bench/memory-usage-report.json

=== Shell Script Syntax & ShellCheck Validation ===
Validating: scripts/syntax_and_shellcheck.sh ... ✓ PASS
Validating: scripts/test-script.sh ... ⚠ ShellCheck issues in: scripts/test-script.sh

In scripts/test-script.sh line 5:
source ./nonexistent-file.sh
       ^-------------------^ SC1091 (info): Not following: ./nonexistent-file.sh was not specified as input (see shellcheck -x).


In scripts/test-script.sh line 11:
cd $HOME
^------^ SC2164 (warning): Use 'cd ... || exit' or 'cd ... || return' in case cd fails.
   ^---^ SC2086 (info): Double quote to prevent globbing and word splitting.
ℹ Shell script validation: 1/2 passed

=== JavaScript Syntax & ESLint Validation ===
Validating: eslint.config.js ... ✓ PASS
Validating: jest.config.enhanced.js ... ✓ PASS
Validating: jest.config.js ... ✓ PASS
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

Validating: lib/ai/index.js ... ✓ PASS
Validating: lib/ai/model-selector.js ... ⚠ ESLint issues in: lib/ai/model-selector.js

/Users/Shared/cursor/cursor-uninstaller/lib/ai/model-selector.js
   93:9  warning  'code' is assigned a value but never used         no-unused-vars
   94:9  warning  'language' is assigned a value but never used     no-unused-vars
   95:9  warning  'context' is assigned a value but never used      no-unused-vars
   96:9  warning  'tokenCount' is assigned a value but never used   no-unused-vars
   97:9  warning  'priority' is assigned a value but never used     no-unused-vars
   98:9  warning  'requestType' is assigned a value but never used  no-unused-vars
  100:9  warning  'complexity' is assigned a value but never used   no-unused-vars

Validating: lib/cache/result-cache.js ... ✓ PASS
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
Validating: lib/lang/index.js ... ✓ PASS
Validating: lib/shadow/index.js ... ✓ PASS
Validating: lib/shadow/ipc.js ... ⚠ ESLint issues in: lib/shadow/ipc.js

/Users/Shared/cursor/cursor-uninstaller/lib/shadow/ipc.js
  398:44  warning  'payload' is defined but never used             no-unused-vars
  407:49  warning  'payload' is defined but never used             no-unused-vars
  415:43  warning  'payload' is defined but never used             no-unused-vars
  549:25  warning  'messageId' is assigned a value but never used  no-unused-vars

✖ 4 problems (0 errors, 4 warnings)

Validating: lib/shadow/manager.js ... ✓ PASS
Validating: lib/shadow/workspace.js ... ⚠ ESLint issues in: lib/shadow/workspace.js

/Users/Shared/cursor/cursor-uninstaller/lib/shadow/workspace.js
   10:9   warning  'spawn' is assigned a value but never used  no-unused-vars
  615:26  warning  'fileUri' is defined but never used         no-unused-vars
  638:27  warning  'fileUri' is defined but never used         no-unused-vars

✖ 3 problems (0 errors, 3 warnings)

Validating: lib/ui/index.js ... ✓ PASS
Validating: modules/performance/index.js ... ⚠ ESLint issues in: modules/performance/index.js

/Users/Shared/cursor/cursor-uninstaller/modules/performance/index.js
  33:19  warning  'data' is defined but never used  no-unused-vars

✖ 1 problem (0 errors, 1 warning)

Validating: modules/performance/latency-tracker.js ... ⚠ ESLint issues in: modules/performance/latency-tracker.js

/Users/Shared/cursor/cursor-uninstaller/modules/performance/latency-tracker.js
  598:29  warning  'operation' is assigned a value but never used  no-unused-vars

✖ 1 problem (0 errors, 1 warning)

Validating: tests/bench/completion-latency.js ... ✓ PASS
Validating: tests/bench/memory-usage.js ... ✓ PASS
Validating: tests/integration/ai-system-integration.test.js ... ✓ PASS
Validating: tests/integration/ai-system-v2-integration.test.js ... ✓ PASS
Validating: tests/integration/basic.test.js ... ✓ PASS
Validating: tests/integration/mocks/componentMocks.js ... ✓ PASS
Validating: tests/integration/mocks/mockComponents.js ... ✓ PASS
Validating: tests/integration/mocks/ui/index.js ... ✓ PASS
Validating: tests/integration/optimization.test.js ... ✓ PASS
Validating: tests/integration/setupJest.js ... ⚠ ESLint issues in: tests/integration/setupJest.js

/Users/Shared/cursor/cursor-uninstaller/tests/integration/setupJest.js
  1:1  warning  Unused eslint-disable directive (no problems were reported from 'no-unused-vars')

✖ 1 problem (0 errors, 1 warning)
  0 errors and 1 warning potentially fixable with the `--fix` option.

Validating: tests/integration/structure.test.js ... ✓ PASS
Validating: tests/jest-setup.js ... ✓ PASS
Validating: tests/setup.js ... ✓ PASS
ℹ JavaScript validation: 21/33 passed

=== JSON Syntax & Schema Validation ===
Validating: .eslintrc.json ... Validating: .vscode/extensions.json ... ✓ PASS
Validating: .vscode/settings.json ... ✓ PASS
Validating: package-lock.json ... ✓ PASS
Validating: package.json ... Validating: tests/bench/completion-latency-report.json ... ✓ PASS
Validating: tests/bench/memory-usage-report.json ... ✓ PASS
ℹ JSON validation: 5/7 passed

=== Import & Dependency Validation ===
⚠ Missing sourced file in scripts/test-script.sh: ./nonexistent-file.sh
ℹ Import validation: 1 issues found

=== Runtime & Type Error Validation ===
ℹ Validating package.json dependencies...
⚠ Main entry point missing: bin/uninstall_cursor.sh
ℹ TypeScript files detected
⚠ TypeScript compilation issues detected:
error TS18003: No inputs were found in config file '/var/folders/2h/hz635vg13xlf435h2l4hnm7m0000gn/T/tmp.N1yBhKbZCX/tsconfig.json'. Specified 'include' paths were '["**/*.ts"]' and 'exclude' paths were '["node_modules","dist","build"]'.
ℹ Runtime validation: 2 issues found

=== Duplicate File & Code Detection ===
ℹ Generating file hashes...

ℹ Analyzing for duplicate content...
ℹ Extracting function signatures...
ℹ Analyzing meaningful duplicates...
✓ No meaningful code duplicates found
ℹ Duplicate detection: 0 meaningful issues found

=== Directory Structure Integrity ===
ℹ Potentially orphaned files: 14
ℹ Structure validation: 0 issues found

=== Comprehensive Validation Summary ===
Performance Metrics:
  • Total execution time: 12s
  • Files discovered: 42
  • Files processed: 42
  • Processing rate: 3 files/sec

File Type Distribution:
  • Shell scripts: 2
  • JavaScript files: 33
  • JSON files: 7
  • Configuration files: 3

Validation Results:
  • Syntax errors: 0
  • Linter issues: 13
  • JSON errors: 0
  • Import problems: 1
  • Runtime issues: 2
  • Duplicates found: 0
  • Structure issues: 0
  • Total issues: 16
⚠ Codebase health: FAIR (61/100)

Debugging Recommendations (Priority Order):
  • ⚠️  Check runtime configuration and dependencies
  • 📦 Verify all import paths and dependencies
  • 💡 Review linter output for code quality improvements

Quick Fixes:
  • Run: shellcheck <script> for detailed analysis
✗ Validation completed with issues
vicd@Vics-MacBook-Air cursor-uninstaller % 