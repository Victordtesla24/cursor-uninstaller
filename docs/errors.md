vicd@Vics-MacBook-Air cursor-uninstaller % bash scripts/syntax_and_shellcheck.sh      
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
✓ Discovered 19 shell scripts
✓ Discovered 63 JavaScript files
✓ Discovered 10 JSON files
✓ Discovered 3 configuration files
ℹ Total files to validate: 92
Shell Scripts:
  • scripts/syntax_and_shellcheck.sh
  • scripts/test-script.sh
  • ./.cursor/retry-utils.sh
  • ./.cursor/update-error-md.sh
  • ./.cursor/install.sh
  • ./.cursor/tests/test-docker-env.sh
  • ./.cursor/tests/test-env-setup.sh
  • ./.cursor/tests/test-linting.sh
  • ./.cursor/tests/run-tests.sh
  • ./.cursor/tests/test-background-agent.sh
  • ./.cursor/tests/test-github-integration.sh
  • ./.cursor/tests/test-agent-runtime.sh
  • ./.cursor/github-setup.sh
  • ./.cursor/load-env.sh
  • ./.cursor/flush-logs.sh
  • ./.cursor/create-snapshot.sh
  • ./.cursor/cleanup.sh
  • ./scripts/syntax_and_shellcheck.sh
  • ./scripts/test-script.sh
JavaScript Files: 63 files (too many to list)
JSON Files:
  • tests/bench/memory-usage-report.json
  • tests/bench/completion-latency-report.json
  • ./.cursor/environment.json
  • ./tests/bench/memory-usage-report.json
  • ./tests/bench/completion-latency-report.json
  • ./package-lock.json
  • ./package.json
  • ./.vscode/settings.json
  • ./.vscode/extensions.json
  • ./.eslintrc.json

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
Validating: ./.cursor/retry-utils.sh ... ⚠ ShellCheck issues in: ./.cursor/retry-utils.sh

In ./.cursor/retry-utils.sh line 13:
    source "$(dirname "${BASH_SOURCE[0]}")/.cursor/load-env.sh"
           ^-- SC1091 (info): Not following: ./.cursor/load-env.sh was not specified as input (see shellcheck -x).


In ./.cursor/retry-utils.sh line 15:
    source "./.cursor/load-env.sh"
           ^---------------------^ SC1091 (info): Not following: ./.cursor/load-env.sh was not specified as input (see shellcheck -x).

Validating: ./.cursor/update-error-md.sh ... ✓ PASS
Validating: ./.cursor/install.sh ... ✓ PASS
Validating: ./.cursor/tests/test-docker-env.sh ... ⚠ ShellCheck issues in: ./.cursor/tests/test-docker-env.sh

In ./.cursor/tests/test-docker-env.sh line 532:
      docker rmi -f ${TEST_TAG} 2>/dev/null || true
                    ^---------^ SC2086 (info): Double quote to prevent globbing and word splitting.

Did you mean: 
      docker rmi -f "${TEST_TAG}" 2>/dev/null || true


In ./.cursor/tests/test-docker-env.sh line 553:
Validating: ./.cursor/tests/test-env-setup.sh ... ✓ PASS
Validating: ./.cursor/tests/test-linting.sh ... ⚠ ShellCheck issues in: ./.cursor/tests/test-linting.sh

In ./.cursor/tests/test-linting.sh line 349:
          if run_test "ESLint sample check" "eslint --no-ignore --max-warnings=0 $(cat ${js_files_output})" "$eslint_output"; then # Set max-warnings to 0
                                                                                       ^----------------^ SC2086 (info): Double quote to prevent globbing and word splitting.

Did you mean: 
          if run_test "ESLint sample check" "eslint --no-ignore --max-warnings=0 $(cat "${js_files_output}")" "$eslint_output"; then # Set max-warnings to 0


In ./.cursor/tests/test-linting.sh line 357:
Validating: ./.cursor/tests/run-tests.sh ... ⚠ ShellCheck issues in: ./.cursor/tests/run-tests.sh

In ./.cursor/tests/run-tests.sh line 129:
  source "${CURSOR_DIR}/load-env.sh"
         ^-------------------------^ SC1091 (info): Not following: ./load-env.sh was not specified as input (see shellcheck -x).

For more information:
  https://www.shellcheck.net/wiki/SC1091 -- Not following: ./load-env.sh was ...
Validating: ./.cursor/tests/test-background-agent.sh ... ✓ PASS
Validating: ./.cursor/tests/test-github-integration.sh ... ✓ PASS
Validating: ./.cursor/tests/test-agent-runtime.sh ... ✓ PASS
Validating: ./.cursor/github-setup.sh ... ⚠ ShellCheck issues in: ./.cursor/github-setup.sh

In ./.cursor/github-setup.sh line 8:
  source "$(dirname "${BASH_SOURCE[0]}")/.cursor/load-env.sh"
         ^-- SC1091 (info): Not following: ./.cursor/load-env.sh was not specified as input (see shellcheck -x).


In ./.cursor/github-setup.sh line 10:
  source "./.cursor/load-env.sh"
         ^---------------------^ SC1091 (info): Not following: ./.cursor/load-env.sh was not specified as input (see shellcheck -x).

Validating: ./.cursor/load-env.sh ... ✓ PASS
Validating: ./.cursor/flush-logs.sh ... ✓ PASS
Validating: ./.cursor/create-snapshot.sh ... ⚠ ShellCheck issues in: ./.cursor/create-snapshot.sh

In ./.cursor/create-snapshot.sh line 34:
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
                               ^---------------^ SC1091 (info): Not following: ./nvm.sh was not specified as input (see shellcheck -x).

For more information:
  https://www.shellcheck.net/wiki/SC1091 -- Not following: ./nvm.sh was not s...
Validating: ./.cursor/cleanup.sh ... ⚠ ShellCheck issues in: ./.cursor/cleanup.sh

In ./.cursor/cleanup.sh line 58:
  if ls $file 2>/dev/null; then
        ^---^ SC2086 (info): Double quote to prevent globbing and word splitting.

Did you mean: 
  if ls "$file" 2>/dev/null; then


In ./.cursor/cleanup.sh line 59:
Validating: ./scripts/syntax_and_shellcheck.sh ... ✓ PASS
Validating: ./scripts/test-script.sh ... ⚠ ShellCheck issues in: ./scripts/test-script.sh

In ./scripts/test-script.sh line 5:
source ./nonexistent-file.sh
       ^-------------------^ SC1091 (info): Not following: ./nonexistent-file.sh was not specified as input (see shellcheck -x).


In ./scripts/test-script.sh line 11:
cd $HOME
^------^ SC2164 (warning): Use 'cd ... || exit' or 'cd ... || return' in case cd fails.
   ^---^ SC2086 (info): Double quote to prevent globbing and word splitting.
ℹ Shell script validation: 10/19 passed

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
Validating: ./jest.config.js ... ✓ PASS
Validating: ./tests/bench/completion-latency.js ... ✓ PASS
Validating: ./tests/bench/memory-usage.js ... ✓ PASS
Validating: ./tests/integration/mocks/ui/index.js ... ✓ PASS
Validating: ./tests/integration/mocks/mockComponents.js ... ✓ PASS
Validating: ./tests/integration/mocks/componentMocks.js ... ✓ PASS
Validating: ./tests/integration/ai-system-integration.test.js ... ✓ PASS
Validating: ./tests/integration/basic.test.js ... ✓ PASS
Validating: ./tests/integration/setupJest.js ... ⚠ ESLint issues in: ./tests/integration/setupJest.js

/Users/Shared/cursor/cursor-uninstaller/tests/integration/setupJest.js
  1:1  warning  Unused eslint-disable directive (no problems were reported from 'no-unused-vars')

✖ 1 problem (0 errors, 1 warning)
  0 errors and 1 warning potentially fixable with the `--fix` option.

Validating: ./tests/integration/ai-system-v2-integration.test.js ... ✓ PASS
Validating: ./tests/integration/optimization.test.js ... ✓ PASS
Validating: ./tests/integration/structure.test.js ... ✓ PASS
Validating: ./tests/jest-setup.js ... ✓ PASS
Validating: ./tests/setup.js ... ✓ PASS
Validating: ./lib/ui/index.js ... ✓ PASS
Validating: ./lib/cache/result-cache.js ... ✓ PASS
Validating: ./lib/shadow/ipc.js ... ⚠ ESLint issues in: ./lib/shadow/ipc.js

/Users/Shared/cursor/cursor-uninstaller/lib/shadow/ipc.js
  398:44  warning  'payload' is defined but never used             no-unused-vars
  407:49  warning  'payload' is defined but never used             no-unused-vars
  415:43  warning  'payload' is defined but never used             no-unused-vars
  549:25  warning  'messageId' is assigned a value but never used  no-unused-vars

✖ 4 problems (0 errors, 4 warnings)

Validating: ./lib/shadow/index.js ... ✓ PASS
Validating: ./lib/shadow/workspace.js ... ⚠ ESLint issues in: ./lib/shadow/workspace.js

/Users/Shared/cursor/cursor-uninstaller/lib/shadow/workspace.js
   10:9   warning  'spawn' is assigned a value but never used  no-unused-vars
  615:26  warning  'fileUri' is defined but never used         no-unused-vars
  638:27  warning  'fileUri' is defined but never used         no-unused-vars

✖ 3 problems (0 errors, 3 warnings)

Validating: ./lib/shadow/manager.js ... ✓ PASS
Validating: ./lib/lang/index.js ... ✓ PASS
Validating: ./lib/lang/adapters/shell.js ... ⚠ ESLint issues in: ./lib/lang/adapters/shell.js

/Users/Shared/cursor/cursor-uninstaller/lib/lang/adapters/shell.js
    9:7   warning  'path' is assigned a value but never used         no-unused-vars
  130:56  warning  'options' is assigned a value but never used      no-unused-vars
  195:38  warning  'options' is assigned a value but never used      no-unused-vars
  269:53  warning  'position' is defined but never used              no-unused-vars
  494:34  warning  'filePath' is defined but never used              no-unused-vars
  503:17  warning  'errorOutput' is assigned a value but never used  no-unused-vars
  528:30  warning  'error' is defined but never used                 no-unused-vars
  653:26  warning  'indentLevel' is defined but never used           no-unused-vars
Validating: ./lib/lang/adapters/javascript.js ... ⚠ ESLint issues in: ./lib/lang/adapters/javascript.js

/Users/Shared/cursor/cursor-uninstaller/lib/lang/adapters/javascript.js
  136:56  warning  'options' is assigned a value but never used      no-unused-vars
  158:18  warning  'error' is defined but never used                 no-unused-vars
  246:35  warning  'position' is defined but never used              no-unused-vars
  327:18  warning  'error' is defined but never used                 no-unused-vars
  362:18  warning  'error' is defined but never used                 no-unused-vars
  454:18  warning  'error' is defined but never used                 no-unused-vars
  462:38  warning  'options' is assigned a value but never used      no-unused-vars
  471:53  warning  Strings must use singlequote                      quotes
Validating: ./lib/lang/adapters/base.js ... ⚠ ESLint issues in: ./lib/lang/adapters/base.js

/Users/Shared/cursor/cursor-uninstaller/lib/lang/adapters/base.js
  110:15  warning  'startTime' is assigned a value but never used  no-unused-vars
  303:36  warning  'filePath' is defined but never used            no-unused-vars
  303:46  warning  'position' is defined but never used            no-unused-vars
  303:56  warning  'options' is defined but never used             no-unused-vars
  311:35  warning  'filePath' is defined but never used            no-unused-vars
  311:45  warning  'symbol' is defined but never used              no-unused-vars
  311:53  warning  'position' is defined but never used            no-unused-vars
  319:26  warning  'filePath' is defined but never used            no-unused-vars
Validating: ./lib/lang/adapters/python.js ... ⚠ ESLint issues in: ./lib/lang/adapters/python.js

/Users/Shared/cursor/cursor-uninstaller/lib/lang/adapters/python.js
    10:9   warning  'spawn' is assigned a value but never used           no-unused-vars
   213:56  warning  'options' is assigned a value but never used         no-unused-vars
   238:18  warning  'error' is defined but never used                    no-unused-vars
   334:35  warning  'position' is defined but never used                 no-unused-vars
   558:18  warning  'error' is defined but never used                    no-unused-vars
   616:56  warning  Strings must use singlequote                         quotes
   696:19  warning  'variableRegex' is assigned a value but never used   no-unused-vars
   698:19  warning  'usedVars' is assigned a value but never used        no-unused-vars
Validating: ./lib/ai/model-selector.js ... ⚠ ESLint issues in: ./lib/ai/model-selector.js

/Users/Shared/cursor/cursor-uninstaller/lib/ai/model-selector.js
   93:9  warning  'code' is assigned a value but never used         no-unused-vars
   94:9  warning  'language' is assigned a value but never used     no-unused-vars
   95:9  warning  'context' is assigned a value but never used      no-unused-vars
   96:9  warning  'tokenCount' is assigned a value but never used   no-unused-vars
   97:9  warning  'priority' is assigned a value but never used     no-unused-vars
   98:9  warning  'requestType' is assigned a value but never used  no-unused-vars
  100:9  warning  'complexity' is assigned a value but never used   no-unused-vars

Validating: ./lib/ai/index.js ... ✓ PASS
Validating: ./lib/ai/context-manager.js ... ⚠ ESLint issues in: ./lib/ai/context-manager.js

/Users/Shared/cursor/cursor-uninstaller/lib/ai/context-manager.js
  139:51  warning  'options' is defined but never used   no-unused-vars
  252:16  warning  'error' is defined but never used     no-unused-vars
  274:26  warning  'position' is defined but never used  no-unused-vars
  274:36  warning  'language' is defined but never used  no-unused-vars
  274:46  warning  'options' is defined but never used   no-unused-vars
  291:27  warning  'language' is defined but never used  no-unused-vars
  291:37  warning  'options' is defined but never used   no-unused-vars

Validating: ./lib/ai/controller.js ... ⚠ ESLint issues in: ./lib/ai/controller.js

/Users/Shared/cursor/cursor-uninstaller/lib/ai/controller.js
  250:41  warning  'position' is assigned a value but never used  no-unused-vars
  340:33  warning  'language' is defined but never used           no-unused-vars

✖ 2 problems (0 errors, 2 warnings)

Validating: ./eslint.config.js ... ✓ PASS
Validating: ./modules/performance/index.js ... ⚠ ESLint issues in: ./modules/performance/index.js

/Users/Shared/cursor/cursor-uninstaller/modules/performance/index.js
  33:19  warning  'data' is defined but never used  no-unused-vars

✖ 1 problem (0 errors, 1 warning)

Validating: ./modules/performance/latency-tracker.js ... ⚠ ESLint issues in: ./modules/performance/latency-tracker.js

/Users/Shared/cursor/cursor-uninstaller/modules/performance/latency-tracker.js
  598:29  warning  'operation' is assigned a value but never used  no-unused-vars

✖ 1 problem (0 errors, 1 warning)

Validating: ./jest.config.enhanced.js ... ✓ PASS
ℹ JavaScript validation: 39/63 passed

=== JSON Syntax & Schema Validation ===
Validating: tests/bench/memory-usage-report.json ... ✓ PASS
Validating: tests/bench/completion-latency-report.json ... ✓ PASS
Validating: ./.cursor/environment.json ... ✓ PASS
Validating: ./tests/bench/memory-usage-report.json ... ✓ PASS
Validating: ./tests/bench/completion-latency-report.json ... ✓ PASS
Validating: ./package-lock.json ... ✓ PASS
Validating: ./package.json ... Validating: ./.vscode/settings.json ... ✓ PASS
Validating: ./.vscode/extensions.json ... ✓ PASS
Validating: ./.eslintrc.json ... ℹ JSON validation: 8/10 passed

=== Import & Dependency Validation ===
⚠ Missing sourced file in scripts/test-script.sh: ./nonexistent-file.sh
⚠ Missing sourced file in ./.cursor/retry-utils.sh: $(dirname
⚠ Missing sourced file in ./.cursor/tests/run-tests.sh: ${test_script}
⚠ Missing sourced file in ./.cursor/tests/run-tests.sh: ${CURSOR_DIR}/load-env.sh
⚠ Missing sourced file in ./.cursor/github-setup.sh: $(dirname
⚠ Missing sourced file in ./.cursor/github-setup.sh: ${CURSOR_DIR_RELATIVE_TO_SCRIPT}/retry-utils.sh
⚠ Missing sourced file in ./.cursor/create-snapshot.sh: \033[0m
⚠ Missing sourced file in ./scripts/test-script.sh: ./nonexistent-file.sh
ℹ Import validation: 8 issues found

=== Runtime & Type Error Validation ===
ℹ Validating package.json dependencies...
⚠ Main entry point missing: bin/uninstall_cursor.sh
ℹ TypeScript files detected
Version 5.8.3
tsc: The TypeScript Compiler - Version 5.8.3                                                                            
                                                                                                                     TS 
COMMON COMMANDS

  tsc
  Compiles the current project (tsconfig.json in the working directory.)

  tsc app.ts util.ts
  Ignoring tsconfig.json, compiles the specified files with default compiler options.

  tsc -b
  Build a composite project in the working directory.

  tsc --init
  Creates a tsconfig.json with the recommended settings in the working directory.

  tsc -p ./path/to/tsconfig.json
  Compiles the TypeScript project located at the specified path.

  tsc --help --all
  An expanded version of this information, showing all possible compiler options

  tsc --noEmit
  tsc --target esnext
  Compiles the current project, with additional settings.

COMMAND LINE FLAGS

     --help, -h  Print this message.

    --watch, -w  Watch input files.

          --all  Show all compiler options.

  --version, -v  Print the compiler's version.

         --init  Initializes a TypeScript project and creates a tsconfig.json file.

  --project, -p  Compile the project given the path to its configuration file, or to a folder with a 'tsconfig.json'.

   --showConfig  Print the final configuration instead of building.

    --build, -b  Build one or more projects and their dependencies, if out of date

COMMON COMPILER OPTIONS

               --pretty  Enable color and formatting in TypeScript's output to make compiler errors easier to read.
                  type:  boolean
               default:  true

      --declaration, -d  Generate .d.ts files from TypeScript and JavaScript files in your project.
                  type:  boolean
               default:  `false`, unless `composite` is set

       --declarationMap  Create sourcemaps for d.ts files.
                  type:  boolean
               default:  false

  --emitDeclarationOnly  Only output d.ts files and not JavaScript files.
                  type:  boolean
               default:  false

            --sourceMap  Create source map files for emitted JavaScript files.
                  type:  boolean
               default:  false

               --noEmit  Disable emitting files from a compilation.
                  type:  boolean
               default:  false

           --target, -t  Set the JavaScript language version for emitted JavaScript and include compatible library declarations.
                one of:  es5, es6/es2015, es2016, es2017, es2018, es2019, es2020, es2021, es2022, es2023, es2024, esnext
               default:  es5

           --module, -m  Specify what module code is generated.
                one of:  none, commonjs, amd, umd, system, es6/es2015, es2020, es2022, esnext, node16, node18, nodenext, preserve
               default:  undefined

                  --lib  Specify a set of bundled library declaration files that describe the target runtime environment.
           one or more:  es5, es6/es2015, es7/es2016, es2017, es2018, es2019, es2020, es2021, es2022, es2023, es2024, esnext, dom, dom.iterable, do                         m.asynciterable, webworker, webworker.importscripts, webworker.iterable, webworker.asynciterable, scripthost, es2015.core,                          es2015.collection, es2015.generator, es2015.iterable, es2015.promise, es2015.proxy, es2015.reflect, es2015.symbol, es2015                         .symbol.wellknown, es2016.array.include, es2016.intl, es2017.arraybuffer, es2017.date, es2017.object, es2017.sharedmemory,                          es2017.string, es2017.intl, es2017.typedarrays, es2018.asyncgenerator, es2018.asynciterable/esnext.asynciterable, es2018.                         intl, es2018.promise, es2018.regexp, es2019.array, es2019.object, es2019.string, es2019.symbol/esnext.symbol, es2019.intl,                          es2020.bigint/esnext.bigint, es2020.date, es2020.promise, es2020.sharedmemory, es2020.string, es2020.symbol.wellknown, es                         2020.intl, es2020.number, es2021.promise, es2021.string, es2021.weakref/esnext.weakref, es2021.intl, es2022.array, es2022.                         error, es2022.intl, es2022.object, es2022.string, es2022.regexp, es2023.array, es2023.collection, es2023.intl, es2024.arra                         ybuffer, es2024.collection, es2024.object/esnext.object, es2024.promise, es2024.regexp/esnext.regexp, es2024.sharedmemory,                          es2024.string/esnext.string, esnext.array, esnext.collection, esnext.intl, esnext.disposable, esnext.promise, esnext.deco                         rators, esnext.iterator, esnext.float16, decorators, decorators.legacy
               default:  undefined

              --allowJs  Allow JavaScript files to be a part of your program. Use the 'checkJS' option to get errors from these files.
                  type:  boolean
               default:  false

              --checkJs  Enable error reporting in type-checked JavaScript files.
                  type:  boolean
               default:  false

                  --jsx  Specify what JSX code is generated.
                one of:  preserve, react, react-native, react-jsx, react-jsxdev
               default:  undefined

              --outFile  Specify a file that bundles all outputs into one JavaScript file. If 'declaration' is true, also designates a file that bu                         ndles all .d.ts output.

               --outDir  Specify an output folder for all emitted files.

       --removeComments  Disable emitting comments.
                  type:  boolean
               default:  false

               --strict  Enable all strict type-checking options.
                  type:  boolean
               default:  false

                --types  Specify type package names to be included without being referenced in a source file.

      --esModuleInterop  Emit additional JavaScript to ease support for importing CommonJS modules. This enables 'allowSyntheticDefaultImports' for                          type compatibility.
                  type:  boolean
               default:  false

You can learn about all of the compiler options at https://aka.ms/tsc

⚠ TypeScript compilation issues detected
ℹ Runtime validation: 2 issues found

=== Duplicate File & Code Detection ===
ℹ Generating file hashes...
.
ℹ Analyzing for duplicate content...
⚠ Exact duplicate files found (hash: 0c0d7f20d0d3...):
  • ./lib/ai/context-manager.js
  • lib/ai/context-manager.js
⚠ Exact duplicate files found (hash: 11354f4e13b7...):
  • ./lib/shadow/manager.js
  • lib/shadow/manager.js
⚠ Exact duplicate files found (hash: 125c3da0b775...):
  • ./scripts/test-script.sh
  • scripts/test-script.sh
⚠ Exact duplicate files found (hash: 16f8cec67a82...):
  • ./tests/integration/setupJest.js
  • tests/integration/setupJest.js
⚠ Exact duplicate files found (hash: 21e4a51cbbac...):
  • ./tests/bench/memory-usage.js
  • tests/bench/memory-usage.js
⚠ Exact duplicate files found (hash: 25398108a1f3...):
  • ./modules/performance/index.js
  • modules/performance/index.js
⚠ Exact duplicate files found (hash: 287f1648b79a...):
  • ./lib/ai/controller.js
  • lib/ai/controller.js
⚠ Exact duplicate files found (hash: 2ddc6e30271c...):
  • ./lib/ai/index.js
  • lib/ai/index.js
⚠ Exact duplicate files found (hash: 398b3d9ebc21...):
  • ./tests/jest-setup.js
  • tests/jest-setup.js
⚠ Exact duplicate files found (hash: 3b97aaec99da...):
  • ./lib/lang/adapters/javascript.js
  • lib/lang/adapters/javascript.js
⚠ Exact duplicate files found (hash: 534de13af7b3...):
  • ./tests/integration/optimization.test.js
  • tests/integration/optimization.test.js
⚠ Exact duplicate files found (hash: 704b71f071f4...):
  • ./lib/lang/adapters/shell.js
  • lib/lang/adapters/shell.js
⚠ Exact duplicate files found (hash: 723069a34825...):
  • ./tests/integration/ai-system-v2-integration.test.js
  • tests/integration/ai-system-v2-integration.test.js
⚠ Exact duplicate files found (hash: 82de3e68a809...):
  • ./tests/integration/basic.test.js
  • tests/integration/basic.test.js
⚠ Exact duplicate files found (hash: 85b623b3f57c...):
  • ./tests/integration/structure.test.js
  • tests/integration/structure.test.js
⚠ Exact duplicate files found (hash: 8ca69dada182...):
  • ./scripts/syntax_and_shellcheck.sh
  • scripts/syntax_and_shellcheck.sh
⚠ Exact duplicate files found (hash: 937c89a78df4...):
  • ./lib/ui/index.js
  • lib/ui/index.js
⚠ Exact duplicate files found (hash: 93e1fdb53de5...):
  • ./tests/bench/completion-latency.js
  • tests/bench/completion-latency.js
⚠ Exact duplicate files found (hash: a83931f96591...):
  • ./tests/integration/mocks/mockComponents.js
  • tests/integration/mocks/mockComponents.js
⚠ Exact duplicate files found (hash: aa6afc2bac29...):
  • ./tests/bench/memory-usage-report.json
  • tests/bench/memory-usage-report.json
⚠ Exact duplicate files found (hash: abd1ea3fe535...):
  • ./tests/integration/ai-system-integration.test.js
  • tests/integration/ai-system-integration.test.js
⚠ Exact duplicate files found (hash: ad7869d88655...):
  • ./lib/shadow/index.js
  • lib/shadow/index.js
⚠ Exact duplicate files found (hash: b8ca360a5e87...):
  • ./modules/performance/latency-tracker.js
  • modules/performance/latency-tracker.js
⚠ Exact duplicate files found (hash: c88a510f8c5a...):
  • ./lib/lang/index.js
  • lib/lang/index.js
⚠ Exact duplicate files found (hash: ca1fc7fd3642...):
  • ./tests/integration/mocks/ui/index.js
  • tests/integration/mocks/ui/index.js
⚠ Exact duplicate files found (hash: cc90eee8df49...):
  • ./tests/bench/completion-latency-report.json
  • tests/bench/completion-latency-report.json
⚠ Exact duplicate files found (hash: cd77bc216518...):
  • ./tests/setup.js
  • tests/setup.js
⚠ Exact duplicate files found (hash: cebee47f297a...):
  • ./lib/shadow/ipc.js
  • lib/shadow/ipc.js
⚠ Exact duplicate files found (hash: d37a247af3c4...):
  • ./lib/lang/adapters/base.js
  • lib/lang/adapters/base.js
⚠ Exact duplicate files found (hash: db8d38906f97...):
  • ./lib/ai/model-selector.js
  • lib/ai/model-selector.js
⚠ Exact duplicate files found (hash: dbc4a9cb6b9d...):
  • ./lib/lang/adapters/python.js
  • lib/lang/adapters/python.js
⚠ Exact duplicate files found (hash: de1e249a82a8...):
  • ./lib/cache/result-cache.js
  • lib/cache/result-cache.js
⚠ Exact duplicate files found (hash: e6199e03d798...):
  • ./lib/shadow/workspace.js
  • lib/shadow/workspace.js
⚠ Exact duplicate files found (hash: fc270acc5d13...):
  • ./tests/integration/mocks/componentMocks.js
  • tests/integration/mocks/componentMocks.js
ℹ Extracting function signatures...
ℹ Analyzing meaningful duplicates...
✓ No meaningful code duplicates found
ℹ Duplicate detection: 34 meaningful issues found

=== Directory Structure Integrity ===
⚠ Misplaced files detected:
  • ./.cursor/retry-utils.sh (shell script in unexpected location)
  • ./.cursor/update-error-md.sh (shell script in unexpected location)
  • ./.cursor/install.sh (shell script in unexpected location)
  • ./.cursor/tests/test-docker-env.sh (shell script in unexpected location)
  • ./.cursor/tests/test-env-setup.sh (shell script in unexpected location)
  • ./.cursor/tests/test-linting.sh (shell script in unexpected location)
  • ./.cursor/tests/run-tests.sh (shell script in unexpected location)
  • ./.cursor/tests/test-background-agent.sh (shell script in unexpected location)
  • ./.cursor/tests/test-github-integration.sh (shell script in unexpected location)
  • ./.cursor/tests/test-agent-runtime.sh (shell script in unexpected location)
  • ./.cursor/github-setup.sh (shell script in unexpected location)
  • ./.cursor/load-env.sh (shell script in unexpected location)
  • ./.cursor/flush-logs.sh (shell script in unexpected location)
  • ./.cursor/create-snapshot.sh (shell script in unexpected location)
  • ./.cursor/cleanup.sh (shell script in unexpected location)
  • ./scripts/syntax_and_shellcheck.sh (shell script in unexpected location)
  • ./scripts/test-script.sh (shell script in unexpected location)
  • ./tests/integration/ai-system-integration.test.js (test file outside tests/ directory)
  • ./tests/integration/basic.test.js (test file outside tests/ directory)
  • ./tests/integration/ai-system-v2-integration.test.js (test file outside tests/ directory)
  • ./tests/integration/optimization.test.js (test file outside tests/ directory)
  • ./tests/integration/structure.test.js (test file outside tests/ directory)
ℹ Potentially orphaned files: 29
ℹ Structure validation: 22 issues found

=== Comprehensive Validation Summary ===
Performance Metrics:
  • Total execution time: 25s
  • Files discovered: 92
  • Files processed: 92
  • Processing rate: 3 files/sec

File Type Distribution:
  • Shell scripts: 19
  • JavaScript files: 63
  • JSON files: 10
  • Configuration files: 3

Validation Results:
  • Syntax errors: 0
  • Linter issues: 33
  • JSON errors: 0
  • Import problems: 8
  • Runtime issues: 2
  • Duplicates found: 34
  • Structure issues: 22
  • Total issues: 99
✗ Codebase health: POOR (0/100)

Debugging Recommendations (Priority Order):
  • ⚠️  Check runtime configuration and dependencies
  • 📦 Verify all import paths and dependencies
  • 🔄 Consolidate duplicate code per .clinerules protocols
  • 💡 Review linter output for code quality improvements
  • 📁 Reorganize project structure following conventions

Quick Fixes:
  • Run: shellcheck <script> for detailed analysis
✗ Validation completed with issues
vicd@Vics-MacBook-Air cursor-uninstaller % 