
> cursor-uninstaller@1.0.0 revolutionary:test
> jest --config jest.config.revolutionary.js

  console.log
    🚀 Revolutionary test environment initialized

      at Object.<anonymous> (tests/revolutionary-setup.js:26:9)

  console.log
    🚀 Revolutionary test environment initialized

      at Object.<anonymous> (tests/revolutionary-setup.js:26:9)

  console.log
    🚀 Revolutionary test environment initialized

      at Object.<anonymous> (tests/revolutionary-setup.js:26:9)

  console.log
    🚀 Revolutionary test environment initialized

      at Object.<anonymous> (tests/revolutionary-setup.js:26:9)

  console.log
    🚀 Initializing Revolutionary Test Suite

      at Object.<anonymous> (tests/revolutionary-test-suite.js:32:17)

  console.log
    🚀 Revolutionary Optimizer initialized with unlimited capabilities

      at RevolutionaryOptimizer.initializeRevolutionaryOptimizations (modules/performance/revolutionary-optimizer.js:141:17)

  console.log
    🚀 Revolutionary test environment initialized

      at Object.<anonymous> (tests/revolutionary-setup.js:26:9)

bash: /Users/Shared/cursor/cursor-uninstaller/bin/uninstall_cursor.sh: No such file or directory
  console.log
    🚀 Revolutionary test environment initialized

      at Object.<anonymous> (tests/revolutionary-setup.js:26:9)

  console.log
    🚀 Revolutionary 6-Model Orchestrator initialized with models: [
      'claude-4-sonnet-thinking',
      'claude-4-opus-thinking',
      'o3',
      'gemini-2.5-pro',
      'gpt-4.1',
      'claude-3.7-sonnet-thinking'
    ]

      at SixModelOrchestrator.initializeModels (lib/ai/6-model-orchestrator.js:159:21)

  console.log
    🚀 Revolutionary AI Controller initialized with 6-model orchestration

      at RevolutionaryAIController.initialize (lib/ai/revolutionary-controller.js:151:17)

  console.debug
    Consolidated thinking steps from 0 models

      at RevolutionaryAIController.consolidateThinkingSteps (lib/ai/revolutionary-controller.js:620:17)

  console.debug
    Consolidated multimodal insights from 0 models

      at RevolutionaryAIController.consolidateMultimodalInsights (lib/ai/revolutionary-controller.js:630:17)

  console.debug
    Consolidated thinking steps from 1 models

      at RevolutionaryAIController.consolidateThinkingSteps (lib/ai/revolutionary-controller.js:620:17)

  console.debug
    Consolidated multimodal insights from 0 models

      at RevolutionaryAIController.consolidateMultimodalInsights (lib/ai/revolutionary-controller.js:630:17)

  console.log
    🚀 Revolutionary test environment initialized

      at Object.<anonymous> (tests/revolutionary-setup.js:26:9)

  console.debug
    Consolidated thinking steps from 0 models

      at RevolutionaryAIController.consolidateThinkingSteps (lib/ai/revolutionary-controller.js:620:17)

  console.debug
    Consolidated multimodal insights from 0 models

      at RevolutionaryAIController.consolidateMultimodalInsights (lib/ai/revolutionary-controller.js:630:17)

  console.debug
    Consolidated thinking steps from 0 models

      at RevolutionaryAIController.consolidateThinkingSteps (lib/ai/revolutionary-controller.js:620:17)

  console.debug
    Consolidated multimodal insights from 0 models

      at RevolutionaryAIController.consolidateMultimodalInsights (lib/ai/revolutionary-controller.js:630:17)

 FAIL  tests/integration/optimization.test.js
  Revolutionary Test Environment Setup
    ✓ should initialize revolutionary global variables (2 ms)
    ✓ should set proper performance targets (1 ms)
    ✓ should provide revolutionary request factory
  Optimization Feature Validation
    ✕ Main script syntax is valid (15 ms)
    ✓ All required dependencies are loadable
    ✕ Optimization script contains production optimization function
    ✕ Main script references optimization script correctly
    ✕ Configuration constants are properly defined
    ✕ Helper functions are available
    ✕ UI functions provide consistent interface
    ✕ Script has proper error handling
    ✕ No duplicate or conflicting optimization functions
    ✓ Dependencies in target directory are deployable (1 ms)

  ● Optimization Feature Validation › Main script syntax is valid

    expect(received).not.toThrow()

    Error name:    "Error"
    Error message: "Command failed: bash -n \"/Users/Shared/cursor/cursor-uninstaller/bin/uninstall_cursor.sh\"
    bash: /Users/Shared/cursor/cursor-uninstaller/bin/uninstall_cursor.sh: No such file or directory
    "

          10 |   test('Main script syntax is valid', () => {
          11 |     expect(() => {
        > 12 |       execSync(`bash -n "${mainScript}"`, { encoding: 'utf8' });
             |       ^
          13 |     }).not.toThrow();
          14 |   });
          15 |

          at tests/integration/optimization.test.js:12:7
          at Object.<anonymous> (node_modules/expect/build/toThrowMatchers.js:74:11)
          at Object.throwingMatcher [as toThrow] (node_modules/expect/build/index.js:320:21)
          at Object.<anonymous> (tests/integration/optimization.test.js:13:12)

      11 |     expect(() => {
      12 |       execSync(`bash -n "${mainScript}"`, { encoding: 'utf8' });
    > 13 |     }).not.toThrow();
         |            ^
      14 |   });
      15 |
      16 |   test('All required dependencies are loadable', () => {

      at Object.<anonymous> (tests/integration/optimization.test.js:13:12)

  ● Optimization Feature Validation › Optimization script contains production optimization function

    ENOENT: no such file or directory, open '/Users/Shared/cursor/cursor-uninstaller/scripts/optimize_system.sh'

      47 |
      48 |   test('Optimization script contains production optimization function', () => {
    > 49 |     const scriptContent = fs.readFileSync(optimizationScript, 'utf8');
         |                              ^
      50 |
      51 |     // Should contain the production optimization function
      52 |     expect(scriptContent).toMatch(/production_execute_optimize\s*\(\)/);

      at Object.<anonymous> (tests/integration/optimization.test.js:49:30)

  ● Optimization Feature Validation › Main script references optimization script correctly

    ENOENT: no such file or directory, open '/Users/Shared/cursor/cursor-uninstaller/bin/uninstall_cursor.sh'

      58 |
      59 |   test('Main script references optimization script correctly', () => {
    > 60 |     const scriptContent = fs.readFileSync(mainScript, 'utf8');
         |                              ^
      61 |
      62 |     // Should reference the external optimization script
      63 |     expect(scriptContent).toMatch(/scripts\/optimize_system\.sh/);

      at Object.<anonymous> (tests/integration/optimization.test.js:60:30)

  ● Optimization Feature Validation › Configuration constants are properly defined

    ENOENT: no such file or directory, open '/Users/Shared/cursor/cursor-uninstaller/lib/config.sh'

      68 |
      69 |   test('Configuration constants are properly defined', () => {
    > 70 |     const configContent = fs.readFileSync(path.join(projectRoot, 'lib', 'config.sh'), 'utf8');
         |                              ^
      71 |
      72 |     // Check essential configuration constants (updated for actual structure)
      73 |     expect(configContent).toMatch(/AI_MEMORY_LIMIT_GB=8/);

      at Object.<anonymous> (tests/integration/optimization.test.js:70:30)

  ● Optimization Feature Validation › Helper functions are available

    ENOENT: no such file or directory, open '/Users/Shared/cursor/cursor-uninstaller/lib/helpers.sh'

      77 |
      78 |   test('Helper functions are available', () => {
    > 79 |     const helpersContent = fs.readFileSync(path.join(projectRoot, 'lib', 'helpers.sh'), 'utf8');
         |                               ^
      80 |
      81 |     // Check essential helper functions (these may have different exact names)
      82 |     expect(helpersContent).toMatch(/validate.*system/);

      at Object.<anonymous> (tests/integration/optimization.test.js:79:31)

  ● Optimization Feature Validation › UI functions provide consistent interface

    ENOENT: no such file or directory, open '/Users/Shared/cursor/cursor-uninstaller/lib/ui.sh'

      86 |
      87 |   test('UI functions provide consistent interface', () => {
    > 88 |     const uiContent = fs.readFileSync(path.join(projectRoot, 'lib', 'ui.sh'), 'utf8');
         |                          ^
      89 |
      90 |     // Check essential UI functions (these may have different exact names)
      91 |     expect(uiContent).toMatch(/progress/);

      at Object.<anonymous> (tests/integration/optimization.test.js:88:26)

  ● Optimization Feature Validation › Script has proper error handling

    ENOENT: no such file or directory, open '/Users/Shared/cursor/cursor-uninstaller/bin/uninstall_cursor.sh'

       95 |
       96 |   test('Script has proper error handling', () => {
    >  97 |     const scriptContent = fs.readFileSync(mainScript, 'utf8');
          |                              ^
       98 |
       99 |     // Should have error handling and logging (updated patterns)
      100 |     expect(scriptContent).toMatch(/set -euo/); // Updated to match actual pattern

      at Object.<anonymous> (tests/integration/optimization.test.js:97:30)

  ● Optimization Feature Validation › No duplicate or conflicting optimization functions

    ENOENT: no such file or directory, open '/Users/Shared/cursor/cursor-uninstaller/scripts/optimize_system.sh'

      104 |
      105 |   test('No duplicate or conflicting optimization functions', () => {
    > 106 |     const optimizationContent = fs.readFileSync(optimizationScript, 'utf8');
          |                                    ^
      107 |
      108 |     // Should have exactly one production optimization function
      109 |     const productionOptimizeMatches = optimizationContent.match(/production_execute_optimize/g) || [];

      at Object.<anonymous> (tests/integration/optimization.test.js:106:36)

 FAIL  tests/revolutionary-test-suite.js
  ● Revolutionary Cursor AI Test Suite › Revolutionary Performance Targets › should initialize revolutionary optimizer with unlimited targets

    TypeError: RevolutionaryAIController is not a constructor

      41 |         });
      42 |
    > 43 |         aiController = new RevolutionaryAIController({
         |                        ^
      44 |             revolutionaryMode: true,
      45 |             unlimitedCapability: true
      46 |         });

      at Object.<anonymous> (tests/revolutionary-test-suite.js:43:24)

  ● Revolutionary Cursor AI Test Suite › Revolutionary Performance Targets › should achieve <200ms completion latency

    TypeError: RevolutionaryAIController is not a constructor

      41 |         });
      42 |
    > 43 |         aiController = new RevolutionaryAIController({
         |                        ^
      44 |             revolutionaryMode: true,
      45 |             unlimitedCapability: true
      46 |         });

      at Object.<anonymous> (tests/revolutionary-test-suite.js:43:24)

  ● Revolutionary Cursor AI Test Suite › Revolutionary Performance Targets › should achieve ≥98% accuracy with thinking modes

    TypeError: RevolutionaryAIController is not a constructor

      41 |         });
      42 |
    > 43 |         aiController = new RevolutionaryAIController({
         |                        ^
      44 |             revolutionaryMode: true,
      45 |             unlimitedCapability: true
      46 |         });

      at Object.<anonymous> (tests/revolutionary-test-suite.js:43:24)

  ● Revolutionary Cursor AI Test Suite › Revolutionary Performance Targets › should handle unlimited context processing

    TypeError: RevolutionaryAIController is not a constructor

      41 |         });
      42 |
    > 43 |         aiController = new RevolutionaryAIController({
         |                        ^
      44 |             revolutionaryMode: true,
      45 |             unlimitedCapability: true
      46 |         });

      at Object.<anonymous> (tests/revolutionary-test-suite.js:43:24)

  ● Revolutionary Cursor AI Test Suite › 6-Model Orchestration System › should route simple requests to o3 for ultra-fast completion

    TypeError: RevolutionaryAIController is not a constructor

      41 |         });
      42 |
    > 43 |         aiController = new RevolutionaryAIController({
         |                        ^
      44 |             revolutionaryMode: true,
      45 |             unlimitedCapability: true
      46 |         });

      at Object.<anonymous> (tests/revolutionary-test-suite.js:43:24)

  ● Revolutionary Cursor AI Test Suite › 6-Model Orchestration System › should route complex requests to Claude-4-Thinking models

    TypeError: RevolutionaryAIController is not a constructor

      41 |         });
      42 |
    > 43 |         aiController = new RevolutionaryAIController({
         |                        ^
      44 |             revolutionaryMode: true,
      45 |             unlimitedCapability: true
      46 |         });

      at Object.<anonymous> (tests/revolutionary-test-suite.js:43:24)

  ● Revolutionary Cursor AI Test Suite › 6-Model Orchestration System › should route multimodal requests to Gemini-2.5-Pro

    TypeError: RevolutionaryAIController is not a constructor

      41 |         });
      42 |
    > 43 |         aiController = new RevolutionaryAIController({
         |                        ^
      44 |             revolutionaryMode: true,
      45 |             unlimitedCapability: true
      46 |         });

      at Object.<anonymous> (tests/revolutionary-test-suite.js:43:24)

  ● Revolutionary Cursor AI Test Suite › Revolutionary Cache Performance › should achieve <1ms cache retrieval latency

    TypeError: RevolutionaryAIController is not a constructor

      41 |         });
      42 |
    > 43 |         aiController = new RevolutionaryAIController({
         |                        ^
      44 |             revolutionaryMode: true,
      45 |             unlimitedCapability: true
      46 |         });

      at Object.<anonymous> (tests/revolutionary-test-suite.js:43:24)

  ● Revolutionary Cursor AI Test Suite › Revolutionary Cache Performance › should maintain ≥80% cache hit rate

    TypeError: RevolutionaryAIController is not a constructor

      41 |         });
      42 |
    > 43 |         aiController = new RevolutionaryAIController({
         |                        ^
      44 |             revolutionaryMode: true,
      45 |             unlimitedCapability: true
      46 |         });

      at Object.<anonymous> (tests/revolutionary-test-suite.js:43:24)

  ● Revolutionary Cursor AI Test Suite › Zero Constraint Verification › should verify complete removal of token limitations

    TypeError: RevolutionaryAIController is not a constructor

      41 |         });
      42 |
    > 43 |         aiController = new RevolutionaryAIController({
         |                        ^
      44 |             revolutionaryMode: true,
      45 |             unlimitedCapability: true
      46 |         });

      at Object.<anonymous> (tests/revolutionary-test-suite.js:43:24)

  ● Revolutionary Cursor AI Test Suite › Zero Constraint Verification › should confirm revolutionary enhancement status

    TypeError: RevolutionaryAIController is not a constructor

      41 |         });
      42 |
    > 43 |         aiController = new RevolutionaryAIController({
         |                        ^
      44 |             revolutionaryMode: true,
      45 |             unlimitedCapability: true
      46 |         });

      at Object.<anonymous> (tests/revolutionary-test-suite.js:43:24)

  ● Revolutionary Cursor AI Test Suite › Benchmark Performance Validation › should meet all revolutionary performance benchmarks

    TypeError: RevolutionaryAIController is not a constructor

      41 |         });
      42 |
    > 43 |         aiController = new RevolutionaryAIController({
         |                        ^
      44 |             revolutionaryMode: true,
      45 |             unlimitedCapability: true
      46 |         });

      at Object.<anonymous> (tests/revolutionary-test-suite.js:43:24)


  ● Test suite failed to run

    TypeError: Cannot read properties of undefined (reading 'shutdown')

      74 |         // Cleanup revolutionary components
      75 |         await Promise.all([
    > 76 |             aiController.shutdown(),
         |                          ^
      77 |             modelOrchestrator.shutdown(),
      78 |             contextManager.shutdown(),
      79 |             revolutionaryCache.shutdown()

      at Object.<anonymous> (tests/revolutionary-test-suite.js:76:26)

 FAIL  tests/unit/orchestrator-model-selection.test.js
  Revolutionary Test Environment Setup
    ✓ should initialize revolutionary global variables (5 ms)
    ✓ should set proper performance targets
    ✓ should provide revolutionary request factory
  6-Model Orchestrator - Model Selection
    Instant Complexity Tasks
      ✕ should select o3 for simple completions (1 ms)
      ✕ should include validation model for parallel processing (1 ms)
    Complex Reasoning Tasks
      ✕ should select Claude-4-Sonnet-Thinking for complex refactoring
      ✕ should include o3 as speed backup for complex tasks
    Ultimate Intelligence Tasks
      ✕ should select Claude-4-Opus-Thinking for maximum complexity
    Multimodal Analysis
      ✕ should include Gemini-2.5-Pro for multimodal requests (1 ms)
    Balanced Processing
      ✕ should select multiple models for balanced complexity
    Rapid Prototyping
      ✕ should prioritize Claude-3.7-Sonnet-Thinking for rapid tasks

  ● 6-Model Orchestrator - Model Selection › Instant Complexity Tasks › should select o3 for simple completions

    TypeError: Cannot read properties of undefined (reading 'name')

      34 |             const selectedModels = orchestrator.selectModels(request);
      35 |
    > 36 |             expect(selectedModels[0].name).toBe('o3');
         |                                      ^
      37 |             expect(selectedModels[0].role).toBe('primary');
      38 |             expect(selectedModels[0].reasoning).toContain('Ultra-fast');
      39 |         });

      at Object.<anonymous> (tests/unit/orchestrator-model-selection.test.js:36:38)

  ● 6-Model Orchestrator - Model Selection › Instant Complexity Tasks › should include validation model for parallel processing

    expect(received).toHaveLength(expected)

    Matcher error: received value must have a length property whose value must be a number

    Received has type:  object
    Received has value: {"capability": "standard", "complexity": "instant", "confidence": 96, "constraints": "standard", "contextProcessing": "standard", "intelligence": "optimized", "modelDetails": [{"name": "o3", "reasoning": "Ultra-fast completion for instant needs", "role": "primary", "weight": 1}, {"name": "claude-3.7-sonnet-thinking", "reasoning": "Fast thinking mode validation", "role": "validation", "weight": 0.3}], "multimodal": false, "orchestration": "6-model", "parallelExecution": true, "reasoning": "Analyzed as instant based on content and context", "revolutionary": true, "selectedModels": ["o3", "claude-3.7-sonnet-thinking"], "selectionTime": 0.013958000000002357, "thinking": undefined, "timestamp": 1749156471334, "ultimateMode": true, "unlimited": true, "zeroConstraints": true}

      48 |             const selectedModels = orchestrator.selectModels(request);
      49 |
    > 50 |             expect(selectedModels).toHaveLength(2);
         |                                    ^
      51 |             const validationModel = selectedModels.find(m => m.role === 'validation');
      52 |             expect(validationModel.name).toBe('claude-3.7-sonnet-thinking');
      53 |         });

      at Object.<anonymous> (tests/unit/orchestrator-model-selection.test.js:50:36)

  ● 6-Model Orchestrator - Model Selection › Complex Reasoning Tasks › should select Claude-4-Sonnet-Thinking for complex refactoring

    TypeError: selectedModels.find is not a function

      65 |             const selectedModels = orchestrator.selectModels(request);
      66 |
    > 67 |             const primaryModel = selectedModels.find(m => m.role === 'primary');
         |                                                 ^
      68 |             expect(primaryModel.name).toBe('claude-4-sonnet-thinking');
      69 |             expect(primaryModel.reasoning).toContain('Advanced reasoning');
      70 |         });

      at Object.<anonymous> (tests/unit/orchestrator-model-selection.test.js:67:49)

  ● 6-Model Orchestrator - Model Selection › Complex Reasoning Tasks › should include o3 as speed backup for complex tasks

    TypeError: selectedModels.find is not a function

      79 |             const selectedModels = orchestrator.selectModels(request);
      80 |
    > 81 |             const speedBackup = selectedModels.find(m => m.role === 'speed-backup');
         |                                                ^
      82 |             expect(speedBackup.name).toBe('o3');
      83 |             expect(speedBackup.weight).toBe(0.5);
      84 |         });

      at Object.<anonymous> (tests/unit/orchestrator-model-selection.test.js:81:48)

  ● 6-Model Orchestrator - Model Selection › Ultimate Intelligence Tasks › should select Claude-4-Opus-Thinking for maximum complexity

    TypeError: selectedModels.find is not a function

       96 |             const selectedModels = orchestrator.selectModels(request);
       97 |
    >  98 |             const primaryModel = selectedModels.find(m => m.role === 'primary');
          |                                                 ^
       99 |             expect(primaryModel.name).toBe('claude-4-opus-thinking');
      100 |             expect(primaryModel.reasoning).toContain('Ultimate intelligence');
      101 |         });

      at Object.<anonymous> (tests/unit/orchestrator-model-selection.test.js:98:49)

  ● 6-Model Orchestrator - Model Selection › Multimodal Analysis › should include Gemini-2.5-Pro for multimodal requests

    TypeError: selectedModels.find is not a function

      114 |             const selectedModels = orchestrator.selectModels(request);
      115 |
    > 116 |             const multimodalModel = selectedModels.find(m => m.role === 'multimodal');
          |                                                    ^
      117 |             expect(multimodalModel).toBeDefined();
      118 |             expect(multimodalModel.name).toBe('gemini-2.5-pro');
      119 |             expect(multimodalModel.reasoning).toContain('Multimodal');

      at Object.<anonymous> (tests/unit/orchestrator-model-selection.test.js:116:52)

  ● 6-Model Orchestrator - Model Selection › Balanced Processing › should select multiple models for balanced complexity

    expect(received).toBeGreaterThan(expected)

    Matcher error: received value must be a number or bigint

    Received has value: undefined

      131 |             const selectedModels = orchestrator.selectModels(request);
      132 |
    > 133 |             expect(selectedModels.length).toBeGreaterThan(1);
          |                                           ^
      134 |             const modelNames = selectedModels.map(m => m.name);
      135 |             expect(modelNames).toContain('claude-4-sonnet-thinking');
      136 |             expect(modelNames).toContain('gpt-4.1');

      at Object.<anonymous> (tests/unit/orchestrator-model-selection.test.js:133:43)

  ● 6-Model Orchestrator - Model Selection › Rapid Prototyping › should prioritize Claude-3.7-Sonnet-Thinking for rapid tasks

    TypeError: selectedModels.find is not a function

      148 |             const selectedModels = orchestrator.selectModels(request);
      149 |
    > 150 |             const primaryModel = selectedModels.find(m => m.role === 'primary');
          |                                                 ^
      151 |             expect(primaryModel.name).toBe('claude-3.7-sonnet-thinking');
      152 |             expect(primaryModel.reasoning).toContain('Rapid thinking');
      153 |         });

      at Object.<anonymous> (tests/unit/orchestrator-model-selection.test.js:150:49)

  console.warn
    Model o3 processing failed: Primary model failed

      434 |
      435 |             } catch (error) {
    > 436 |                 console.warn(`Model ${modelConfig.name} processing failed:`, error.message);
          |                         ^
      437 |
      438 |                 // Emit error event for monitoring
      439 |                 this.emit('model-error', {

      at lib/ai/revolutionary-controller.js:436:25
          at async Promise.all (index 0)
      at RevolutionaryAIController.executeParallelProcessing (lib/ai/revolutionary-controller.js:454:16)
      at RevolutionaryAIController.processRevolutionaryCompletion (lib/ai/revolutionary-controller.js:268:29)
      at RevolutionaryAIController.requestCompletion (lib/ai/revolutionary-controller.js:185:20)
      at Object.<anonymous> (tests/integration/6-model-system-integration.test.js:412:28)

  console.debug
    Consolidated thinking steps from 0 models

      at RevolutionaryAIController.consolidateThinkingSteps (lib/ai/revolutionary-controller.js:620:17)

  console.debug
    Consolidated multimodal insights from 0 models

      at RevolutionaryAIController.consolidateMultimodalInsights (lib/ai/revolutionary-controller.js:630:17)

 FAIL  tests/integration/basic.test.js
  Revolutionary Test Environment Setup
    ✓ should initialize revolutionary global variables (4 ms)
    ✓ should set proper performance targets (1 ms)
    ✓ should provide revolutionary request factory
  Cursor Uninstaller Basic Tests
    ✕ main uninstaller script exists and is readable (1 ms)
    ✓ package.json has correct structure (1 ms)
    ✓ src directory structure is valid
    ✕ essential project files exist

  ● Cursor Uninstaller Basic Tests › main uninstaller script exists and is readable

    expect(received).toBe(expected) // Object.is equality

    Expected: true
    Received: false

      10 |   test('main uninstaller script exists and is readable', () => {
      11 |     const scriptPath = path.join(__dirname, '../../bin/uninstall_cursor.sh');
    > 12 |     expect(fs.existsSync(scriptPath)).toBe(true);
         |                                       ^
      13 |     
      14 |     const stats = fs.statSync(scriptPath);
      15 |     expect(stats.isFile()).toBe(true);

      at Object.<anonymous> (tests/integration/basic.test.js:12:39)

  ● Cursor Uninstaller Basic Tests › essential project files exist

    expect(received).toBe(expected) // Object.is equality

    Expected: true
    Received: false

      51 |     essentialFiles.forEach(file => {
      52 |       const filePath = path.join(__dirname, '../..', file);
    > 53 |       expect(fs.existsSync(filePath)).toBe(true);
         |                                       ^
      54 |     });
      55 |   });
      56 | }); 

      at tests/integration/basic.test.js:53:39
          at Array.forEach (<anonymous>)
      at Object.<anonymous> (tests/integration/basic.test.js:51:20)

  console.log
    🚀 Revolutionary test environment initialized

      at Object.<anonymous> (tests/revolutionary-setup.js:26:9)

  console.log
    🚀 Revolutionary test environment initialized

      at Object.<anonymous> (tests/revolutionary-setup.js:26:9)

  console.log
    🛑 Shutting down Revolutionary AI Controller...

      at RevolutionaryAIController.shutdown (lib/ai/revolutionary-controller.js:900:17)

  console.log
    ✅ Revolutionary AI Controller shutdown complete

      at RevolutionaryAIController.shutdown (lib/ai/revolutionary-controller.js:923:17)

  console.log
    🚀 Initializing Enhanced AI System...

      at AISystem.initialize (lib/ai/index.js:60:15)

  console.log
    ✅ Result Cache initialized

      at AISystem.initialize (lib/ai/index.js:64:15)

  console.log
    ✅ Model Selector initialized

      at AISystem.initialize (lib/ai/index.js:68:15)

  console.log
    ✅ Context Manager initialized

      at AISystem.initialize (lib/ai/index.js:72:15)

  console.log
    ✅ Performance Monitor initialized

      at AISystem.initialize (lib/ai/index.js:76:15)

 FAIL  tests/integration/structure.test.js
  Revolutionary Test Environment Setup
    ✓ should initialize revolutionary global variables (4 ms)
    ✓ should set proper performance targets
    ✓ should provide revolutionary request factory (1 ms)
  Project Directory Structure Validation
    ✕ Root directory should contain expected main files and directories (1 ms)
    ✕ bin/ directory should contain the main script (1 ms)
    ✕ lib/ directory should contain essential library files (21 ms)
    ✕ modules/ directory should contain functional modules (1 ms)
    ✕ scripts/ directory should contain expected utility scripts and resume-creation/ (1 ms)
    ✓ No development artifacts should remain in root
    ✕ Essential documentation files should exist

  ● Project Directory Structure Validation › Root directory should contain expected main files and directories

    expect(received).toContain(expected) // indexOf

    Expected value: "CHANGELOG.md"
    Received array: [".DS_Store", ".cache", ".clinerules", ".cursor", ".cursorignore", ".eslintrc.js", ".eslintrc.json", ".git", ".github", ".gitignore", …]

      16 |
      17 |     expectedRootContents.forEach(expectedItem => {
    > 18 |       expect(rootContents).toContain(expectedItem);
         |                            ^
      19 |     });
      20 |   });
      21 |

      at tests/integration/structure.test.js:18:28
          at Array.forEach (<anonymous>)
      at Object.<anonymous> (tests/integration/structure.test.js:17:26)

  ● Project Directory Structure Validation › bin/ directory should contain the main script

    expect(received).toBe(expected) // Object.is equality

    Expected: true
    Received: false

      23 |     const binPath = path.join(projectRoot, 'bin');
      24 |     expect(fs.existsSync(binPath)).toBe(true);
    > 25 |     expect(fs.existsSync(path.join(binPath, 'uninstall_cursor.sh'))).toBe(true);
         |                                                                      ^
      26 |   });
      27 |
      28 |   test('lib/ directory should contain essential library files', () => {

      at Object.<anonymous> (tests/integration/structure.test.js:25:70)

  ● Project Directory Structure Validation › lib/ directory should contain essential library files

    expect(received).toEqual(expected) // deep equality

    - Expected  - 4
    + Received  + 0

      Array [
        "ai",
        "cache",
    -   "config.sh",
    -   "error_codes.sh",
    -   "helpers.sh",
        "lang",
        "shadow",
        "ui",
    -   "ui.sh",
      ]

      34 |       'lang', 'shadow', 'ui', 'ui.sh'
      35 |     ].sort();
    > 36 |     expect(libContents).toEqual(expectedLibContents);
         |                         ^
      37 |   });
      38 |
      39 |   test('modules/ directory should contain functional modules', () => {

      at Object.<anonymous> (tests/integration/structure.test.js:36:25)

  ● Project Directory Structure Validation › modules/ directory should contain functional modules

    expect(received).toEqual(expected) // deep equality

    - Expected  - 6
    + Received  + 0

      Array [
    -   "ai_optimization.sh",
    -   "complete_removal.sh",
    -   "git_integration.sh",
    -   "installation.sh",
        "integration",
    -   "optimization.sh",
        "performance",
    -   "uninstall.sh",
      ]

      51 |       'uninstall.sh'
      52 |     ].sort();
    > 53 |     expect(modulesContents).toEqual(expectedModulesContents);
         |                             ^
      54 |   });
      55 |
      56 |   test('scripts/ directory should contain expected utility scripts and resume-creation/', () => {

      at Object.<anonymous> (tests/integration/structure.test.js:53:29)

  ● Project Directory Structure Validation › scripts/ directory should contain expected utility scripts and resume-creation/

    expect(received).toEqual(expected) // deep equality

    - Expected  - 8
    + Received  + 4

      Array [
    -   "build_release.sh",
    -   "create_dmg_package.sh",
    -   "install_cursor_uninstaller.sh",
    -   "optimize_system.sh",
    -   "resume-creation",
    -   "setup.sh",
    +   "build-cursor-ai-vsix.sh",
    +   "revolutionary-setup.sh",
        "syntax_and_shellcheck.sh",
    -   "verify.sh",
    -   "verify_simple.sh",
    +   "test-optimization-install.sh",
    +   "validate-revolutionary-implementation.sh",
      ]

      69 |       'verify_simple.sh'
      70 |     ].sort();
    > 71 |     expect(actualScriptsContents).toEqual(expectedScriptsContents);
         |                                   ^
      72 |   });
      73 |
      74 |   test('No development artifacts should remain in root', () => {

      at Object.<anonymous> (tests/integration/structure.test.js:71:35)

  ● Project Directory Structure Validation › Essential documentation files should exist

    expect(received).toBe(expected) // Object.is equality

    Expected: true
    Received: false

      87 |     docFiles.forEach(docFile => {
      88 |       const filePath = path.join(projectRoot, docFile);
    > 89 |       expect(fs.existsSync(filePath)).toBe(true);
         |                                       ^
      90 |     });
      91 |   });
      92 | }); 

      at tests/integration/structure.test.js:89:39
          at Array.forEach (<anonymous>)
      at Object.<anonymous> (tests/integration/structure.test.js:87:14)

  console.log
    ✅ AI Controller initialized

      at AIController.initialize (lib/ai/controller.js:56:13)

  console.log
    🎉 AI System fully initialized and ready

      at AISystem.initialize (lib/ai/index.js:99:15)

  console.log
    🚀 Revolutionary test environment initialized

      at Object.<anonymous> (tests/revolutionary-setup.js:26:9)

  console.debug
    Model selection for completion request: javascript, 15 tokens, priority: interactive

      at ModelSelector.selectModel (lib/ai/model-selector.js:140:15)

  console.log
    🚀 Starting AI System V2.0.0 Integration Tests...

      at Object.<anonymous> (tests/integration/ai-system-v2-integration.test.js:30:17)

  console.log
    🔧 Initializing Performance Monitoring System...

      at PerformanceMonitoringSystem.initialize (modules/performance/index.js:225:21)

  console.log
    ✅ Performance monitoring components initialized

      at PerformanceMonitoringSystem.initializeComponents (modules/performance/index.js:289:17)

  console.log
    📊 Basic performance collection started

      at PerformanceCollector.start (modules/performance/index.js:19:17)

  console.log
    📊 Performance metrics collection started

      at PerformanceMonitoringSystem.startCollection (modules/performance/index.js:302:17)

  console.log
    🔍 Real-time performance analysis started

      at PerformanceMonitoringSystem.startAnalysis (modules/performance/index.js:319:17)

  console.log
    ✅ Performance Monitoring System initialized

      at PerformanceMonitoringSystem.initialize (modules/performance/index.js:241:21)

  console.log
    📊 Thresholds: Latency=500ms, Memory=500MB

      at PerformanceMonitoringSystem.initialize (modules/performance/index.js:242:21)

  console.log
    🔧 Initializing Language Adapter Framework...

      at LanguageAdapterFramework.initialize (lib/lang/index.js:65:21)

  console.log
    ✅ Pre-initialized javascript adapter

      at LanguageAdapterFramework.preInitializeAdapters (lib/lang/index.js:94:25)

  console.log
    🚀 Revolutionary test environment initialized

      at Object.<anonymous> (tests/revolutionary-setup.js:26:9)

 PASS  tests/revolutionary-setup.js
  Revolutionary Test Environment Setup
    ✓ should initialize revolutionary global variables
    ✓ should set proper performance targets (1 ms)
    ✓ should provide revolutionary request factory

  console.log
    ✅ Pre-initialized python adapter

      at LanguageAdapterFramework.preInitializeAdapters (lib/lang/index.js:94:25)

  console.log
    🚀 Revolutionary test environment initialized

      at Object.<anonymous> (tests/revolutionary-setup.js:26:9)

 PASS  tests/integration/ultimate-6-model-validation.test.js
  Revolutionary Test Environment Setup
    ✓ should initialize revolutionary global variables (1 ms)
    ✓ should set proper performance targets
    ✓ should provide revolutionary request factory
  Ultimate 6-Model System Validation
    Ultimate Performance Validation
      ✓ should achieve <25ms average latency (ultimate speed) (1 ms)
      ✓ should achieve 99.9% accuracy with thinking modes
      ✓ should handle unlimited context with zero constraints (1 ms)
      ✓ should achieve 95%+ cache hit rate (ultimate efficiency)
    Ultimate Model Orchestration Validation
      ✓ should use all 6 models simultaneously for ultimate tasks
      ✓ should provide multimodal understanding with Gemini-2.5-Pro (1 ms)
      ✓ should demonstrate zero constraint processing
    Ultimate Capability Validation
      ✓ should provide superhuman assistance through 6-model orchestration
      ✓ should meet all ultimate targets simultaneously
    Ultimate Performance Metrics
      ✓ should provide comprehensive ultimate metrics (2 ms)
      ✓ should track model-specific ultimate performance
    Ultimate System Integration
      ✓ should demonstrate perfect end-to-end functionality (2 ms)
      ✓ should maintain zero constraint guarantee (1 ms)

 FAIL  tests/integration/6-model-system-integration.test.js
  Revolutionary Test Environment Setup
    ✓ should initialize revolutionary global variables (2 ms)
    ✓ should set proper performance targets (1 ms)
    ✓ should provide revolutionary request factory
  6-Model System Integration
    End-to-End Code Completion
      ✓ should complete simple code with ultra-fast o3 model (4 ms)
      ✕ should handle complex refactoring with Claude-4-Sonnet-Thinking (2 ms)
    Unlimited Context Processing
      ✕ should handle massive codebase analysis (4 ms)
      ✓ should maintain performance with unlimited context (1 ms)
    Multi-Model Orchestration
      ✕ should use multiple models for balanced complex task (1 ms)
      ✓ should handle multimodal requests with Gemini-2.5-Pro (1 ms)
    Revolutionary Caching Integration
      ✕ should leverage cache for repeated requests (7 ms)
      ✓ should achieve target cache hit rate
    Error Handling and Resilience
      ✕ should gracefully handle model failures with fallbacks (13 ms)
      ✕ should emit comprehensive error events for monitoring
    Performance Integration
      ✕ should meet all revolutionary performance targets (1 ms)
      ✓ should provide comprehensive metrics reporting (2 ms)
    Revolutionary Features Validation
      ✕ should demonstrate unlimited capabilities

  ● 6-Model System Integration › End-to-End Code Completion › should handle complex refactoring with Claude-4-Sonnet-Thinking

    expect(received).toHaveLength(expected)

    Expected length: 4
    Received length: 1
    Received array:  [{"model": "claude-4-sonnet-thinking", "steps": ["Analyze current code structure", "Identify functional programming opportunities", "Apply filter and map operations", "Add default parameter and optional chaining"]}]

      167 |             expect(result.refactoredCode).toContain('filter');
      168 |             expect(result.refactoredCode).toContain('map');
    > 169 |             expect(result.thinkingSteps).toHaveLength(4);
          |                                          ^
      170 |             expect(result.modelUsed).toBe('claude-4-sonnet-thinking');
      171 |             expect(result.confidence).toBeGreaterThanOrEqual(0.95);
      172 |         });

      at Object.<anonymous> (tests/integration/6-model-system-integration.test.js:169:42)

  ● 6-Model System Integration › Unlimited Context Processing › should handle massive codebase analysis

    expect(received).toBe(expected) // Object.is equality

    Expected: "claude-4-opus-thinking"
    Received: "o3"

      227 |             expect(result.analysis.dependencies).toBeDefined();
      228 |             expect(result.contextProcessed).toBe('unlimited');
    > 229 |             expect(result.modelUsed).toBe('claude-4-opus-thinking');
          |                                      ^
      230 |         });
      231 |
      232 |         test('should maintain performance with unlimited context', async () => {

      at Object.<anonymous> (tests/integration/6-model-system-integration.test.js:229:38)

  ● 6-Model System Integration › Multi-Model Orchestration › should use multiple models for balanced complex task

    expect(received).toBeGreaterThanOrEqual(expected)

    Expected: >= 0.9
    Received:    0.76925

      301 |             expect(result.multiModelResults.length).toBeGreaterThan(1);
      302 |             expect(result.synthesizedResult).toBeDefined();
    > 303 |             expect(result.confidence).toBeGreaterThanOrEqual(0.9);
          |                                       ^
      304 |         });
      305 |
      306 |         test('should handle multimodal requests with Gemini-2.5-Pro', async () => {

      at Object.<anonymous> (tests/integration/6-model-system-integration.test.js:303:39)

  ● 6-Model System Integration › Revolutionary Caching Integration › should leverage cache for repeated requests

    expect(received).toBe(expected) // Object.is equality

    Expected: true
    Received: undefined

      374 |
      375 |             expect(secondResult.success).toBe(true);
    > 376 |             expect(secondResult.cached).toBe(true);
          |                                         ^
      377 |             expect(secondResult.result).toContain('from cache');
      378 |         });
      379 |

      at Object.<anonymous> (tests/integration/6-model-system-integration.test.js:376:41)

  ● 6-Model System Integration › Error Handling and Resilience › should gracefully handle model failures with fallbacks

    expect(received).toBe(expected) // Object.is equality

    Expected: true
    Received: undefined

      413 |
      414 |             expect(result.success).toBe(true);
    > 415 |             expect(result.fallback).toBe(true);
          |                                     ^
      416 |             expect(result.modelUsed).toBe('claude-3.7-sonnet-thinking');
      417 |             expect(result.result).toContain('fallback success');
      418 |         });

      at Object.<anonymous> (tests/integration/6-model-system-integration.test.js:415:37)

  ● 6-Model System Integration › Error Handling and Resilience › should emit comprehensive error events for monitoring

    expect(received).toBeGreaterThan(expected)

    Expected: > 0
    Received:   0

      433 |             await controller.executeInstruction(failingRequest);
      434 |
    > 435 |             expect(errorEvents.length).toBeGreaterThan(0);
          |                                        ^
      436 |             expect(errorEvents[0]).toMatchObject({
      437 |                 type: 'model-error',
      438 |                 error: expect.any(Error),

      at Object.<anonymous> (tests/integration/6-model-system-integration.test.js:435:40)

  ● 6-Model System Integration › Performance Integration › should meet all revolutionary performance targets

    expect(received).toBeGreaterThanOrEqual(expected)

    Expected: >= 0.98
    Received:    0.8372499999999999

      468 |             expect(result.success).toBe(true);
      469 |             expect(endTime - startTime).toBeLessThan(200);
    > 470 |             expect(result.confidence).toBeGreaterThanOrEqual(0.98);
          |                                       ^
      471 |             expect(result.accuracy).toBeGreaterThanOrEqual(0.98);
      472 |         });
      473 |

      at Object.<anonymous> (tests/integration/6-model-system-integration.test.js:470:39)

  ● 6-Model System Integration › Revolutionary Features Validation › should demonstrate unlimited capabilities

    expect(received).toBeGreaterThanOrEqual(expected)

    Expected: >= 0.98
    Received:    0.833

      530 |             expect(result.unlimited).toBe(true);
      531 |             expect(result.revolutionary).toBe(true);
    > 532 |             expect(result.confidence).toBeGreaterThanOrEqual(0.98);
          |                                       ^
      533 |         });
      534 |     });
      535 | }); 

      at Object.<anonymous> (tests/integration/6-model-system-integration.test.js:532:39)

  console.log
    ✅ ShellCheck LSP available: 0.10.0

      at ShellAdapter.setupLSP (lib/lang/adapters/shell.js:87:25)

  console.log
    ✅ Shell syntax parser initialized

      at ShellAdapter.setupSyntaxParser (lib/lang/adapters/shell.js:107:17)

  console.log
    ✅ ShellCheck linter configured

      at ShellAdapter.setupLinter (lib/lang/adapters/shell.js:115:21)

  console.log
    ✅ Shell formatter configured

      at ShellAdapter.setupFormatter (lib/lang/adapters/shell.js:131:17)

  console.log
    ✅ Pre-initialized shell adapter

      at LanguageAdapterFramework.preInitializeAdapters (lib/lang/index.js:94:25)

  console.log
    ✅ Language Adapter Framework initialized

      at LanguageAdapterFramework.initialize (lib/lang/index.js:74:21)

  console.log
    📝 Supported languages: javascript, python, shell, bash

      at LanguageAdapterFramework.initialize (lib/lang/index.js:75:21)

  console.log
    ✅ Shadow LSP Manager initialized

      at ShadowLSPManager.initialize (lib/shadow/workspace.js:659:17)

  console.log
    ✅ Diagnostics Engine initialized

      at DiagnosticsEngine.initialize (lib/shadow/workspace.js:686:17)

  console.log
    ✅ Shadow Test Runner initialized

      at ShadowTestRunner.initialize (lib/shadow/workspace.js:719:17)

  console.log
    ✅ Shadow workspace shadow_1749156471471_yx9cqva0d initialized in 1ms

      at ShadowWorkspace._performInitialization (lib/shadow/workspace.js:163:21)

  console.log
    ✅ AI Controller initialized

      at AIController.initialize (lib/ai/controller.js:56:13)

  console.log
    ✅ All V2.0.0 components initialized

      at Object.<anonymous> (tests/integration/ai-system-v2-integration.test.js:97:17)

  console.log
    🔍 Detected language: javascript (score: 200)

      at LanguageAdapterFramework.detectLanguage (lib/lang/index.js:186:25)

  console.log
    🔍 Detected language: python (score: 200)

      at LanguageAdapterFramework.detectLanguage (lib/lang/index.js:186:25)

  console.log
    🔍 Detected language: shell (score: 200)

      at LanguageAdapterFramework.detectLanguage (lib/lang/index.js:186:25)

  console.log
    🔍 Detected language: javascript (score: 100)

      at LanguageAdapterFramework.detectLanguage (lib/lang/index.js:186:25)

  console.debug
    Applying formatting options: {"semi":true,"singleQuote":true,"tabWidth":2,"trailingComma":"es5","printWidth":80}

      at JavaScriptAdapter.performFormatting (lib/lang/adapters/javascript.js:501:21)

  console.debug
    Getting diagnostics for file: file://test.js

      at DiagnosticsEngine.getDiagnostics (lib/shadow/workspace.js:691:17)

  console.debug
    Running tests for file: test.js

      at ShadowTestRunner.runTestsForFile (lib/shadow/workspace.js:725:17)

  console.debug
    Getting diagnostics for file: file://shadow.js

      at DiagnosticsEngine.getDiagnostics (lib/shadow/workspace.js:691:17)

  console.debug
    Running tests for file: shadow.js

      at ShadowTestRunner.runTestsForFile (lib/shadow/workspace.js:725:17)

  console.debug
    Model selection for completion request: python, 15 tokens, priority: interactive

      at ModelSelector.selectModel (lib/ai/model-selector.js:140:15)

 FAIL  tests/unit/6-model-orchestrator.test.js
  Revolutionary Test Environment Setup
    ✓ should initialize revolutionary global variables
    ✓ should set proper performance targets
    ✓ should provide revolutionary request factory (6 ms)
  Revolutionary 6-Model Orchestrator
    Model Selection Algorithm
      ✓ should select o3 for instant complexity tasks (2 ms)
      ✓ should select Claude-4-Sonnet-Thinking for complex tasks
      ✓ should select Claude-4-Opus-Thinking for ultimate complexity (1 ms)
      ✓ should include Gemini-2.5-Pro for multimodal requests
      ✓ should select multiple models for balanced complexity (1 ms)
    Parallel Processing Execution
      ✕ should execute multiple models in parallel (3 ms)
      ✕ should handle model execution failures gracefully
    Thinking Mode Integration
      ✕ should enable thinking mode for Claude models (3 ms)
      ✕ should include thinking steps in results (1 ms)
    Unlimited Context Processing
      ✕ should handle unlimited context without token limits (1 ms)
      ✕ should process large codebases efficiently (1 ms)
    Performance Optimization
      ✓ should achieve target latency under 200ms (1 ms)
      ✕ should maintain high confidence scores
    Revolutionary Caching
      ✕ should cache model responses with unlimited storage (1 ms)
      ✕ should retrieve cached responses for unlimited performance (62 ms)
    Metrics and Monitoring
      ✓ should track comprehensive performance metrics (1 ms)
      ✓ should track thinking mode usage
      ✓ should track multimodal requests
    Error Handling and Resilience
      ✕ should handle network failures gracefully
      ✕ should emit error events for monitoring (1 ms)
    Revolutionary Features Integration
      ✕ should integrate all revolutionary capabilities

  ● Revolutionary 6-Model Orchestrator › Parallel Processing Execution › should execute multiple models in parallel

    expect(received).toHaveLength(expected)

    Matcher error: received value must have a length property whose value must be a number

    Received has type:  object
    Received has value: {"confidence": NaN, "metadata": {"capabilities": ["ultra-fast", "instant-completion", "real-time", "rapid-thinking", "quick-iteration", "prototyping"], "orchestrator": "6-model-revolutionary", "reasoning": {"approaches": [], "confidence": "high", "models": ["o3", "claude-3.7-sonnet-thinking"], "validation": true}, "unlimited": true}, "model": "o3", "multimodal": {"analysis": [], "enabled": false, "visual": false}, "performance": {"averageLatency": 0.1599790000000212, "modelsUsed": 2, "synthesisTime": -1749156470711.3972, "totalLatency": 0.1918750000000955}, "response": {"confidence": 0.95, "latency": 50, "modelName": "o3", "result": "completion from o3", "success": true, "thinkingMode": false}, "thinking": {"enabled": false, "models": ["claude-3.7-sonnet-thinking"], "steps": []}, "validatedBy": ["claude-3.7-sonnet-thinking"]}

      160 |             const results = await orchestrator.executeParallel(models, request);
      161 |
    > 162 |             expect(results).toHaveLength(2);
          |                             ^
      163 |             expect(results[0].modelName).toBe('o3');
      164 |             expect(results[1].modelName).toBe('claude-3.7-sonnet-thinking');
      165 |             expect(results[1].thinkingMode).toBe(true);

      at Object.<anonymous> (tests/unit/6-model-orchestrator.test.js:162:29)

  ● Revolutionary 6-Model Orchestrator › Parallel Processing Execution › should handle model execution failures gracefully

    expect(received).toHaveLength(expected)

    Matcher error: received value must have a length property whose value must be a number

    Received has type:  object
    Received has value: {"confidence": 85, "metadata": {"capabilities": ["ultra-fast", "instant-completion", "real-time"], "orchestrator": "6-model-revolutionary", "reasoning": {"approaches": [], "confidence": "high", "models": ["o3"], "validation": false}, "unlimited": true}, "model": "o3", "multimodal": {"analysis": [], "enabled": false, "visual": false}, "performance": {"averageLatency": 0.08825000000001637, "modelsUsed": 1, "synthesisTime": -1749156470711.1838, "totalLatency": 0.08825000000001637}, "response": {"confidence": 0.95, "latency": 50, "modelName": "o3", "result": "success", "success": true}, "thinking": {"enabled": false, "models": [], "steps": []}, "validatedBy": []}

      189 |             const results = await orchestrator.executeParallel(models, request);
      190 |
    > 191 |             expect(results).toHaveLength(1);
          |                             ^
      192 |             expect(results[0].success).toBe(true);
      193 |         });
      194 |     });

      at Object.<anonymous> (tests/unit/6-model-orchestrator.test.js:191:29)

  ● Revolutionary 6-Model Orchestrator › Thinking Mode Integration › should enable thinking mode for Claude models

    expect(received).toBe(expected) // Object.is equality

    Expected: true
    Received: undefined

      207 |             );
      208 |
    > 209 |             expect(modelRequest.thinkingMode).toBe(true);
          |                                               ^
      210 |             expect(modelRequest.enhancedReasoning).toBe(true);
      211 |             expect(modelRequest.stepByStepAnalysis).toBe(true);
      212 |         });

      at Object.<anonymous> (tests/unit/6-model-orchestrator.test.js:209:47)

  ● Revolutionary 6-Model Orchestrator › Thinking Mode Integration › should include thinking steps in results

    TypeError: Cannot read properties of undefined (reading 'thinkingSteps')

      232 |             const results = await orchestrator.executeParallel(models, request);
      233 |
    > 234 |             expect(results[0].thinkingSteps).toBeDefined();
          |                               ^
      235 |             expect(results[0].thinkingSteps).toHaveLength(4);
      236 |             expect(results[0].reasoning).toContain('SOLID');
      237 |         });

      at Object.<anonymous> (tests/unit/6-model-orchestrator.test.js:234:31)

  ● Revolutionary 6-Model Orchestrator › Unlimited Context Processing › should handle unlimited context without token limits

    expect(received).toBe(expected) // Object.is equality

    Expected: "unlimited"
    Received: "small"

      249 |             const complexity = orchestrator.complexityAnalyzer.analyze(largeRequest);
      250 |
    > 251 |             expect(complexity.contextSize).toBe('unlimited');
          |                                            ^
      252 |             expect(complexity.tokenLimitations).toBe('removed');
      253 |             expect(complexity.processingCapability).toBe('unlimited');
      254 |         });

      at Object.<anonymous> (tests/unit/6-model-orchestrator.test.js:251:44)

  ● Revolutionary 6-Model Orchestrator › Unlimited Context Processing › should process large codebases efficiently

    expect(received).toBeGreaterThan(expected)

    Matcher error: received value must be a number or bigint

    Received has value: undefined

      270 |
      271 |             // Should still select appropriate models despite massive size
    > 272 |             expect(selectedModels.length).toBeGreaterThan(0);
          |                                           ^
      273 |             const primaryModel = selectedModels.find(m => m.role === 'primary');
      274 |             expect(primaryModel).toBeDefined();
      275 |         });

      at Object.<anonymous> (tests/unit/6-model-orchestrator.test.js:272:43)

  ● Revolutionary 6-Model Orchestrator › Performance Optimization › should maintain high confidence scores

    TypeError: results.reduce is not a function

      314 |             const results = await orchestrator.executeParallel(models, request);
      315 |
    > 316 |             const avgConfidence = results.reduce((sum, r) => sum + r.confidence, 0) / results.length;
          |                                           ^
      317 |             expect(avgConfidence).toBeGreaterThanOrEqual(0.95);
      318 |         });
      319 |     });

      at Object.<anonymous> (tests/unit/6-model-orchestrator.test.js:316:43)

  ● Revolutionary 6-Model Orchestrator › Revolutionary Caching › should cache model responses with unlimited storage

    expect(jest.fn()).toHaveBeenCalled()

    Expected number of calls: >= 1
    Received number of calls:    0

      335 |             await orchestrator.executeParallel(models, request);
      336 |
    > 337 |             expect(mockCache.set).toHaveBeenCalled();
          |                                   ^
      338 |             const cacheCall = mockCache.set.mock.calls[0];
      339 |             expect(cacheCall[0]).toContain('o3'); // Cache key contains model name
      340 |             expect(cacheCall[1]).toEqual(expect.objectContaining({

      at Object.<anonymous> (tests/unit/6-model-orchestrator.test.js:337:35)

  ● Revolutionary 6-Model Orchestrator › Revolutionary Caching › should retrieve cached responses for unlimited performance

    TypeError: Cannot read properties of undefined (reading 'cached')

      359 |             const results = await orchestrator.executeParallel(models, request);
      360 |
    > 361 |             expect(results[0].cached).toBe(true);
          |                               ^
      362 |             expect(results[0].result).toBe('cached completion');
      363 |             expect(orchestrator._executeModel).not.toHaveBeenCalled();
      364 |         });

      at Object.<anonymous> (tests/unit/6-model-orchestrator.test.js:361:31)

  ● Revolutionary 6-Model Orchestrator › Error Handling and Resilience › should handle network failures gracefully

    expect(received).toHaveLength(expected)

    Matcher error: received value must have a length property whose value must be a number

    Received has type:  object
    Received has value: {"confidence": 85, "metadata": {"capabilities": ["rapid-thinking", "quick-iteration", "prototyping"], "orchestrator": "6-model-revolutionary", "reasoning": {"approaches": [], "confidence": "high", "models": ["claude-3.7-sonnet-thinking"], "validation": false}, "unlimited": true}, "model": "claude-3.7-sonnet-thinking", "multimodal": {"analysis": [], "enabled": false, "visual": false}, "performance": {"averageLatency": 0.04404199999999037, "modelsUsed": 1, "synthesisTime": -1749156470711.0476, "totalLatency": 0.04404199999999037}, "response": {"confidence": 0.9, "modelName": "claude-3.7-sonnet-thinking", "result": "fallback result", "success": true}, "thinking": {"enabled": false, "models": ["claude-3.7-sonnet-thinking"], "steps": []}, "validatedBy": []}

      447 |             const results = await orchestrator.executeParallel(models, request);
      448 |
    > 449 |             expect(results).toHaveLength(1);
          |                             ^
      450 |             expect(results[0].modelName).toBe('claude-3.7-sonnet-thinking');
      451 |             expect(results[0].success).toBe(true);
      452 |         });

      at Object.<anonymous> (tests/unit/6-model-orchestrator.test.js:449:29)

  ● Revolutionary 6-Model Orchestrator › Error Handling and Resilience › should emit error events for monitoring

    Unhandled error. ({
      type: 'parallelExecution',
      error: 'All models failed to provide responses',
      models: [ 'o3' ]
    })

      517 |
      518 |         } catch (error) {
    > 519 |             this.emit('error', {
          |                  ^
      520 |                 type: 'parallelExecution',
      521 |                 error: error.message,
      522 |                 models: models.map(m => m.name)

      at SixModelOrchestrator.executeParallel (lib/ai/6-model-orchestrator.js:519:18)
      at Object.<anonymous> (tests/unit/6-model-orchestrator.test.js:465:13)

  ● Revolutionary 6-Model Orchestrator › Revolutionary Features Integration › should integrate all revolutionary capabilities

    expect(received).toBeGreaterThan(expected)

    Matcher error: received value must be a number or bigint

    Received has value: undefined

      488 |
      489 |             // Should select multiple models for ultimate capabilities
    > 490 |             expect(selectedModels.length).toBeGreaterThan(2);
          |                                           ^
      491 |
      492 |             // Should include thinking models
      493 |             const thinkingModels = selectedModels.filter(m =>

      at Object.<anonymous> (tests/unit/6-model-orchestrator.test.js:490:43)

 FAIL  tests/unit/orchestrator-performance.test.js
  Revolutionary Test Environment Setup
    ✓ should initialize revolutionary global variables (3 ms)
    ✓ should set proper performance targets (1 ms)
    ✓ should provide revolutionary request factory
  6-Model Orchestrator - Performance
    Revolutionary Performance Targets
      ✓ should achieve <200ms completion latency for simple tasks (1 ms)
      ✕ should achieve ≥98% accuracy with thinking modes
      ✕ should handle unlimited context processing without degradation
    Parallel Processing Performance
      ✕ should execute multiple models concurrently for faster results (153 ms)
      ✕ should maintain performance under high concurrent load (1 ms)
    Caching Performance
      ✕ should provide sub-1ms cache retrieval for unlimited performance (51 ms)
      ✕ should achieve ≥80% cache hit rate target
    Memory and Resource Optimization
      ✕ should maintain ≤200MB memory overhead during unlimited processing (10 ms)
      ✓ should clean up resources after processing (1 ms)
    Revolutionary Metrics Tracking
      ✕ should track comprehensive performance metrics accurately
      ✓ should track thinking mode usage accurately (1 ms)

  ● 6-Model Orchestrator - Performance › Revolutionary Performance Targets › should achieve ≥98% accuracy with thinking modes

    TypeError: Cannot read properties of undefined (reading 'accuracy')

      82 |             const results = await orchestrator.executeParallel(models, complexRequest);
      83 |
    > 84 |             expect(results[0].accuracy).toBeGreaterThanOrEqual(0.98);
         |                               ^
      85 |             expect(results[0].confidence).toBeGreaterThanOrEqual(0.98);
      86 |             expect(results[0].thinkingMode).toBe(true);
      87 |         });

      at Object.<anonymous> (tests/unit/orchestrator-performance.test.js:84:31)

  ● 6-Model Orchestrator - Performance › Revolutionary Performance Targets › should handle unlimited context processing without degradation

    TypeError: Cannot read properties of undefined (reading 'contextProcessed')

      109 |             const endTime = performance.now();
      110 |
    > 111 |             expect(results[0].contextProcessed).toBe('unlimited');
          |                               ^
      112 |             expect(results[0].tokenLimitations).toBe('removed');
      113 |             expect(results[0].success).toBe(true);
      114 |             // Even with unlimited context, should maintain reasonable performance

      at Object.<anonymous> (tests/unit/orchestrator-performance.test.js:111:31)

  ● 6-Model Orchestrator - Performance › Parallel Processing Performance › should execute multiple models concurrently for faster results

    expect(received).toHaveLength(expected)

    Matcher error: received value must have a length property whose value must be a number

    Received has type:  object
    Received has value: {"confidence": NaN, "metadata": {"capabilities": ["ultra-fast", "instant-completion", "real-time", "enhanced-coding", "balanced-performance", "general-purpose", "rapid-thinking", "quick-iteration", "prototyping"], "orchestrator": "6-model-revolutionary", "reasoning": {"approaches": [], "confidence": "high", "models": ["o3", "gpt-4.1", "claude-3.7-sonnet-thinking"], "validation": true}, "unlimited": true}, "model": "o3", "multimodal": {"analysis": [], "enabled": false, "visual": false}, "performance": {"averageLatency": 101.112889, "modelsUsed": 3, "synthesisTime": -1749156470693.2007, "totalLatency": 151.18129199999998}, "response": {"confidence": 0.95, "latency": 50, "modelName": "o3", "result": "result from o3", "success": true}, "thinking": {"enabled": false, "models": ["claude-3.7-sonnet-thinking"], "steps": []}, "validatedBy": ["gpt-4.1", "claude-3.7-sonnet-thinking"]}

      149 |
      150 |             // Parallel execution should be faster than sequential
    > 151 |             expect(results).toHaveLength(3);
          |                             ^
      152 |             expect(endTime - startTime).toBeLessThan(200); // Should be close to slowest model (150ms) + overhead
      153 |         });
      154 |

      at Object.<anonymous> (tests/unit/orchestrator-performance.test.js:151:29)

  ● 6-Model Orchestrator - Performance › Parallel Processing Performance › should maintain performance under high concurrent load

    TypeError: Cannot read properties of undefined (reading 'success')

      175 |
      176 |             expect(results).toHaveLength(10);
    > 177 |             expect(results.every(r => r[0].success)).toBe(true);
          |                                            ^
      178 |             // Even under load, average per-request should be reasonable
      179 |             expect((endTime - startTime) / 10).toBeLessThan(300);
      180 |         });

      at tests/unit/orchestrator-performance.test.js:177:44
          at Array.every (<anonymous>)
      at Object.<anonymous> (tests/unit/orchestrator-performance.test.js:177:28)

  ● 6-Model Orchestrator - Performance › Caching Performance › should provide sub-1ms cache retrieval for unlimited performance

    TypeError: Cannot read properties of undefined (reading 'cached')

      199 |             const endTime = performance.now();
      200 |
    > 201 |             expect(results[0].cached).toBe(true);
          |                               ^
      202 |             expect(endTime - startTime).toBeLessThan(1); // Sub-millisecond cache access
      203 |         });
      204 |

      at Object.<anonymous> (tests/unit/orchestrator-performance.test.js:201:31)

  ● 6-Model Orchestrator - Performance › Caching Performance › should achieve ≥80% cache hit rate target

    expect(jest.fn()).toHaveBeenCalledTimes(expected)

    Expected number of calls: 10
    Received number of calls: 0

      234 |
      235 |             // Check cache statistics
    > 236 |             expect(mockCache.get).toHaveBeenCalledTimes(10);
          |                                   ^
      237 |             expect(cacheHits).toBe(10);
      238 |             // 8 hits out of 10 calls = 80% hit rate
      239 |             const hitRate = 8 / 10;

      at Object.<anonymous> (tests/unit/orchestrator-performance.test.js:236:35)

  ● 6-Model Orchestrator - Performance › Memory and Resource Optimization › should maintain ≤200MB memory overhead during unlimited processing

    expect(received).not.toThrow()

    Error name:    "Error"
    Error message: "expect(received).toBeGreaterThan(expected)·
    Matcher error: received value must be a number or bigint·
    Received has value: undefined"

          261 |             expect(() => {
          262 |                 const selectedModels = orchestrator.selectModels(massiveRequest);
        > 263 |                 expect(selectedModels.length).toBeGreaterThan(0);
              |                                               ^
          264 |             }).not.toThrow();
          265 |         });
          266 |

          at tests/unit/orchestrator-performance.test.js:263:47
          at Object.<anonymous> (node_modules/expect/build/toThrowMatchers.js:74:11)
          at Object.throwingMatcher [as toThrow] (node_modules/expect/build/index.js:320:21)
          at Object.<anonymous> (tests/unit/orchestrator-performance.test.js:264:20)

      262 |                 const selectedModels = orchestrator.selectModels(massiveRequest);
      263 |                 expect(selectedModels.length).toBeGreaterThan(0);
    > 264 |             }).not.toThrow();
          |                    ^
      265 |         });
      266 |
      267 |         test('should clean up resources after processing', async () => {

      at Object.<anonymous> (tests/unit/orchestrator-performance.test.js:264:20)

  ● 6-Model Orchestrator - Performance › Revolutionary Metrics Tracking › should track comprehensive performance metrics accurately

    expect(received).toBe(expected) // Object.is equality

    Expected: 2
    Received: 1

      304 |             expect(finalMetrics.totalRequests).toBe(initialMetrics.totalRequests + 1);
      305 |             expect(finalMetrics.successfulResponses).toBe(initialMetrics.successfulResponses + 1);
    > 306 |             expect(finalMetrics.modelUsage['claude-4-sonnet-thinking'].requests).toBe(
          |                                                                                  ^
      307 |                 initialMetrics.modelUsage['claude-4-sonnet-thinking'].requests + 1
      308 |             );
      309 |             expect(finalMetrics.averageLatency).toBeGreaterThan(0);

      at Object.<anonymous> (tests/unit/orchestrator-performance.test.js:306:82)

  console.debug
    Model selection for completion request: javascript, 15 tokens, priority: interactive

      at ModelSelector.selectModel (lib/ai/model-selector.js:140:15)

  console.debug
    Model selection for completion request: javascript, 25 tokens, priority: high

      at ModelSelector.selectModel (lib/ai/model-selector.js:140:15)

  console.debug
    Model selection for completion request: typescript, 25 tokens, priority: high

      at ModelSelector.selectModel (lib/ai/model-selector.js:140:15)

  console.debug
    Model selection for completion request: javascript, 15 tokens, priority: interactive

      at ModelSelector.selectModel (lib/ai/model-selector.js:140:15)

  console.log
    🧹 All caches cleared

      at AISystem.clearCaches (lib/ai/index.js:201:13)

  console.log
    🏃 Running benchmark with 2 scenarios...

      at AISystem.benchmark (lib/ai/index.js:270:13)

  console.debug
    Model selection for completion request: javascript, 15 tokens, priority: interactive

      at ModelSelector.selectModel (lib/ai/model-selector.js:140:15)

  console.debug
    Model selection for completion request: typescript, 25 tokens, priority: high

      at ModelSelector.selectModel (lib/ai/model-selector.js:140:15)

  console.log
    📊 Benchmark completed: 2/2 successful, 113ms avg latency

      at AISystem.benchmark (lib/ai/index.js:321:13)

  console.log
    🏃 Running benchmark with 1 scenarios...

      at AISystem.benchmark (lib/ai/index.js:270:13)

  console.debug
    Model selection for completion request: javascript, 15 tokens, priority: interactive

      at ModelSelector.selectModel (lib/ai/model-selector.js:140:15)

  console.log
    📊 Benchmark completed: 1/1 successful, 107ms avg latency

      at AISystem.benchmark (lib/ai/index.js:321:13)

  console.debug
    Model selection for completion request: javascript, 15 tokens, priority: interactive

      at ModelSelector.selectModel (lib/ai/model-selector.js:140:15)
          at async Promise.all (index 0)

  console.debug
    Model selection for completion request: javascript, 15 tokens, priority: interactive

      at ModelSelector.selectModel (lib/ai/model-selector.js:140:15)
          at async Promise.all (index 1)

  console.debug
    Model selection for completion request: javascript, 15 tokens, priority: interactive

      at ModelSelector.selectModel (lib/ai/model-selector.js:140:15)

  console.debug
    Model selection for completion request: javascript, 15 tokens, priority: interactive

      at ModelSelector.selectModel (lib/ai/model-selector.js:140:15)

  console.debug
    Model selection for completion request: javascript, 15 tokens, priority: interactive

      at ModelSelector.selectModel (lib/ai/model-selector.js:140:15)

  console.log
    🛑 Shutting down AI System...

      at AISystem.shutdown (lib/ai/index.js:334:13)

  console.log
    ✅ AI System shutdown complete

      at AISystem.shutdown (lib/ai/index.js:369:15)

  console.log
    🚀 Initializing Enhanced AI System...

      at AISystem.initialize (lib/ai/index.js:60:15)

  console.log
    ✅ Result Cache initialized

      at AISystem.initialize (lib/ai/index.js:64:15)

  console.log
    ✅ Model Selector initialized

      at AISystem.initialize (lib/ai/index.js:68:15)

  console.log
    ✅ Context Manager initialized

      at AISystem.initialize (lib/ai/index.js:72:15)

  console.log
    ✅ Performance Monitor initialized

      at AISystem.initialize (lib/ai/index.js:76:15)

  console.log
    ✅ AI Controller initialized

      at AIController.initialize (lib/ai/controller.js:56:13)

  console.log
    🎉 AI System fully initialized and ready

      at AISystem.initialize (lib/ai/index.js:99:15)

  console.debug
    Model selection for completion request: javascript, 15 tokens, priority: interactive

      at ModelSelector.selectModel (lib/ai/model-selector.js:140:15)

  console.debug
    Model selection for completion request: javascript, 15 tokens, priority: interactive

      at ModelSelector.selectModel (lib/ai/model-selector.js:140:15)

  console.log
    🛑 Shutting down AI System...

      at AISystem.shutdown (lib/ai/index.js:334:13)

  console.log
    ✅ AI System shutdown complete

      at AISystem.shutdown (lib/ai/index.js:369:15)

 PASS  tests/integration/ai-system-integration.test.js
  Revolutionary Test Environment Setup
    ✓ should initialize revolutionary global variables
    ✓ should set proper performance targets
    ✓ should provide revolutionary request factory
  AI System Integration
    System Initialization
      ✓ should initialize all components successfully (1 ms)
      ✓ should have all required components (1 ms)
    Code Completion
      ✓ should handle simple JavaScript completion (109 ms)
      ✓ should handle Python completion (95 ms)
      ✓ should use cache for repeated requests (90 ms)
    Instruction Execution
      ✓ should handle simple refactoring instruction (122 ms)
      ✓ should use powerful model for complex instructions (109 ms)
    Model Selection
      ✓ should select fast model for simple requests (83 ms)
      ✓ should provide model performance data (1 ms)
    Caching System
      ✓ should track cache statistics (1 ms)
      ✓ should allow cache clearing (1 ms)
    Performance Monitoring
      ✓ should track system metrics
      ✓ should provide optimization recommendations
    Benchmarking
      ✓ should run performance benchmark (228 ms)
      ✓ should run custom benchmark scenarios (108 ms)
    Error Handling
      ✓ should handle invalid completion requests gracefully (1 ms)
      ✓ should handle invalid instruction requests gracefully (1 ms)
      ✓ should track error statistics
    Concurrent Requests
      ✓ should handle multiple concurrent requests (323 ms)
    Memory Management
      ✓ should track memory usage (1 ms)
  Performance Requirements
    ✓ should meet latency targets for simple completions (86 ms)
    ✓ should achieve target cache hit rate (95 ms)

  console.log
    🔍 Detected language: javascript (score: 100)

      at LanguageAdapterFramework.detectLanguage (lib/lang/index.js:186:25)

  console.debug
    Getting diagnostics for file: file://test.js

      at DiagnosticsEngine.getDiagnostics (lib/shadow/workspace.js:691:17)

  console.debug
    Running tests for file: test.js

      at ShadowTestRunner.runTestsForFile (lib/shadow/workspace.js:725:17)

  console.log
    🔍 Detected language: javascript (score: 100)

      at LanguageAdapterFramework.detectLanguage (lib/lang/index.js:186:25)

  console.log
    🔍 Detected language: python (score: 100)

      at LanguageAdapterFramework.detectLanguage (lib/lang/index.js:186:25)

  console.log
    🔍 Detected language: shell (score: 350)

      at LanguageAdapterFramework.detectLanguage (lib/lang/index.js:186:25)

  console.log
    🔍 Detected language: javascript (score: 150)

      at LanguageAdapterFramework.detectLanguage (lib/lang/index.js:186:25)

  console.log
    🔍 Detected language: python (score: 150)

      at LanguageAdapterFramework.detectLanguage (lib/lang/index.js:186:25)

  console.log
    📊 Final Performance Report:

      at Object.<anonymous> (tests/integration/ai-system-v2-integration.test.js:480:21)

  console.log
    Total Operations: 10

      at Object.<anonymous> (tests/integration/ai-system-v2-integration.test.js:481:21)

  console.log
    Average Latency: 311.1652374ms

      at Object.<anonymous> (tests/integration/ai-system-v2-integration.test.js:482:21)

  console.log
    Memory Usage: 46.02MB

      at Object.<anonymous> (tests/integration/ai-system-v2-integration.test.js:483:21)

  console.log
    Success Rate: 100.0%

      at Object.<anonymous> (tests/integration/ai-system-v2-integration.test.js:484:21)

  console.log
    Health Score: 85/100

      at Object.<anonymous> (tests/integration/ai-system-v2-integration.test.js:485:21)

  console.log
    Cache Hit Rate: 10000.0%

      at Object.<anonymous> (tests/integration/ai-system-v2-integration.test.js:497:21)

  console.log
    ✅ All V2.0.0 performance targets met!

      at Object.<anonymous> (tests/integration/ai-system-v2-integration.test.js:498:21)

  console.log
    Memory growth: 0.30MB

      at Object.<anonymous> (tests/integration/ai-system-v2-integration.test.js:556:21)

  console.log
    🔄 Shutting down Performance Monitoring System...

      at PerformanceMonitoringSystem.shutdown (modules/performance/index.js:693:21)

  console.log
    ✅ Latency Tracker stopped

      at LatencyTracker.stop (modules/performance/latency-tracker.js:602:21)

  console.log
    🔄 Shutting down UI Components System...

      at UISystem.shutdown (lib/ui/index.js:723:21)

  console.log
    ✅ UI Components System shutdown complete

      at UISystem.shutdown (lib/ui/index.js:750:21)

  console.log
    🔄 Shutting down Language Adapter Framework...

      at LanguageAdapterFramework.shutdown (lib/lang/index.js:433:21)

  console.log
    🔄 Shutting down Performance Monitoring System...

      at PerformanceMonitoringSystem.shutdown (modules/performance/index.js:693:21)

  console.log
    ✅ Latency Tracker stopped

      at LatencyTracker.stop (modules/performance/latency-tracker.js:602:21)

  console.log
    ✅ Performance Monitoring System shutdown complete

      at PerformanceMonitoringSystem.shutdown (modules/performance/index.js:744:21)
          at async Promise.allSettled (index 0)

  console.log
    ✅ Performance Monitoring System shutdown complete

      at PerformanceMonitoringSystem.shutdown (modules/performance/index.js:744:21)
          at async Promise.allSettled (index 3)

  console.log
    ✅ Language Adapter Framework shutdown complete

      at LanguageAdapterFramework.shutdown (lib/lang/index.js:446:21)
          at async Promise.allSettled (index 2)

  console.log
    ✅ All components shut down

      at Object.<anonymous> (tests/integration/ai-system-v2-integration.test.js:129:17)

 PASS  tests/integration/ai-system-v2-integration.test.js
  Revolutionary Test Environment Setup
    ✓ should initialize revolutionary global variables
    ✓ should set proper performance targets (1 ms)
    ✓ should provide revolutionary request factory
  AI System V2.0.0 Integration Tests
    Language Adapter Framework
      ✓ should support all required languages
      ✓ should auto-detect JavaScript files
      ✓ should auto-detect Python files (1 ms)
      ✓ should auto-detect Shell scripts
      ✓ should initialize adapters within performance target (1 ms)
      ✓ should process files with comprehensive operations (1 ms)
    Shadow Workspace System
      ✓ should create isolated workspace
      ✓ should apply edits safely
      ✓ should maintain independence from main workspace (1 ms)
    Performance Monitoring System
      ✓ should track operation latency within target (102 ms)
      ✓ should monitor memory usage within target (1 ms)
      ✓ should detect performance degradation (4008 ms)
      ✓ should generate comprehensive performance report (1 ms)
    UI Components System
      ✓ should initialize all components
      ✓ should handle theme changes (1 ms)
      ✓ should display performance metrics
      ✓ should show notifications for alerts
    Cache System Performance
      ✓ should achieve target cache hit rate (1 ms)
      ✓ should compress data efficiently
    End-to-End AI Performance Engine
      ✓ should complete full AI workflow within performance targets (4 ms)
      ✓ should maintain 95%+ accuracy under load
      ✓ should generate final performance report (1 ms)
    System Integration Stability
      ✓ should handle component failures gracefully (1 ms)
      ✓ should maintain memory efficiency over time (1 ms)

A worker process has failed to exit gracefully and has been force exited. This is likely caused by tests leaking due to improper teardown. Try running with --detectOpenHandles to find leaks. Active timers can also cause this, ensure that .unref() was called on them.
Test Suites: 8 failed, 4 passed, 12 total
Tests:       64 failed, 117 passed, 181 total
Snapshots:   0 total
Time:        5.538 s
Ran all test suites.
