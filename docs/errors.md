
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
    🚀 Revolutionary test environment initialized

      at Object.<anonymous> (tests/revolutionary-setup.js:26:9)

  console.log
    🚀 Revolutionary test environment initialized

      at Object.<anonymous> (tests/revolutionary-setup.js:26:9)

 FAIL  tests/unit/orchestrator-model-selection.test.js
  Revolutionary Test Environment Setup
    ✓ should initialize revolutionary global variables (4 ms)
    ✓ should set proper performance targets (1 ms)
    ✓ should provide revolutionary request factory
  6-Model Orchestrator - Model Selection
    Instant Complexity Tasks
      ✓ should select o3 for simple completions (1 ms)
      ✓ should include validation model for parallel processing
    Complex Reasoning Tasks
      ✓ should select Claude-4-Sonnet-Thinking for complex refactoring
      ✓ should include o3 as speed backup for complex tasks (1 ms)
    Ultimate Intelligence Tasks
      ✓ should select Claude-4-Opus-Thinking for maximum complexity (1 ms)
    Multimodal Analysis
      ✓ should include Gemini-2.5-Pro for multimodal requests (1 ms)
    Balanced Processing
      ✕ should select multiple models for balanced complexity (2 ms)
    Rapid Prototyping
      ✓ should prioritize Claude-3.7-Sonnet-Thinking for rapid tasks

  ● 6-Model Orchestrator - Model Selection › Balanced Processing › should select multiple models for balanced complexity

    expect(received).toContain(expected) // indexOf

    Expected value: "claude-4-sonnet-thinking"
    Received array: ["gpt-4.1", "o3"]

      133 |             expect(selectedModels.length).toBeGreaterThan(1);
      134 |             const modelNames = selectedModels.map(m => m.name);
    > 135 |             expect(modelNames).toContain('claude-4-sonnet-thinking');
          |                                ^
      136 |             expect(modelNames).toContain('gpt-4.1');
      137 |         });
      138 |     });

      at Object.<anonymous> (tests/unit/orchestrator-model-selection.test.js:135:32)

  console.log
    🚀 Initializing Revolutionary Test Suite

      at Object.<anonymous> (tests/revolutionary-test-suite.js:32:17)

  console.log
    🚀 Revolutionary Optimizer initialized with unlimited capabilities

      at RevolutionaryOptimizer.initializeRevolutionaryOptimizations (modules/performance/revolutionary-optimizer.js:141:17)

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

  console.log
    🛑 Shutting down Revolutionary AI Controller...

      at RevolutionaryAIController.shutdown (lib/ai/revolutionary-controller.js:900:17)

  console.log
    ✅ Revolutionary AI Controller shutdown complete

      at RevolutionaryAIController.shutdown (lib/ai/revolutionary-controller.js:923:17)

 FAIL  tests/integration/ultimate-6-model-validation.test.js
  Revolutionary Test Environment Setup
    ✓ should initialize revolutionary global variables (3 ms)
    ✓ should set proper performance targets
    ✓ should provide revolutionary request factory (1 ms)
  Ultimate 6-Model System Validation
    Ultimate Performance Validation
      ✕ should achieve <25ms average latency (ultimate speed) (1 ms)
      ✕ should achieve 99.9% accuracy with thinking modes (1 ms)
      ✕ should handle unlimited context with zero constraints
      ✓ should achieve 95%+ cache hit rate (ultimate efficiency) (1 ms)
    Ultimate Model Orchestration Validation
      ✕ should use all 6 models simultaneously for ultimate tasks
      ✕ should provide multimodal understanding with Gemini-2.5-Pro (1 ms)
      ✕ should demonstrate zero constraint processing (1 ms)
    Ultimate Capability Validation
      ✕ should provide superhuman assistance through 6-model orchestration
      ✕ should meet all ultimate targets simultaneously (1 ms)
    Ultimate Performance Metrics
      ✓ should provide comprehensive ultimate metrics (1 ms)
      ✓ should track model-specific ultimate performance (2 ms)
    Ultimate System Integration
      ✕ should demonstrate perfect end-to-end functionality (1 ms)
      ✓ should maintain zero constraint guarantee (1 ms)

  ● Ultimate 6-Model System Validation › Ultimate Performance Validation › should achieve <25ms average latency (ultimate speed)

    expect(received).toContain(expected) // indexOf

    Matcher error: received value must not be null nor undefined

    Received has value: undefined

      71 |             expect(result).toBeDefined();
      72 |             expect(elapsed).toBeLessThan(25); // Ultimate target
    > 73 |             expect(result.selectedModels).toContain('o3'); // Ultra-fast for instant
         |                                           ^
      74 |         });
      75 |
      76 |         test('should achieve 99.9% accuracy with thinking modes', async () => {

      at Object.<anonymous> (tests/integration/ultimate-6-model-validation.test.js:73:43)

  ● Ultimate 6-Model System Validation › Ultimate Performance Validation › should achieve 99.9% accuracy with thinking modes

    expect(received).toContain(expected) // indexOf

    Matcher error: received value must not be null nor undefined

    Received has value: undefined

      86 |
      87 |             expect(result).toBeDefined();
    > 88 |             expect(result.selectedModels).toContain('claude-4-opus-thinking'); // Ultimate intelligence
         |                                           ^
      89 |             expect(result.confidence).toBeGreaterThan(95); // Near-perfect confidence
      90 |             expect(result.thinking).toBe(true); // Thinking mode enabled
      91 |         });

      at Object.<anonymous> (tests/integration/ultimate-6-model-validation.test.js:88:43)

  ● Ultimate 6-Model System Validation › Ultimate Performance Validation › should handle unlimited context with zero constraints

    expect(received).toBe(expected) // Object.is equality

    Expected: "unlimited"
    Received: undefined

      103 |
      104 |             expect(result).toBeDefined();
    > 105 |             expect(result.contextProcessing).toBe('unlimited');
          |                                              ^
      106 |             expect(result.constraints).toBe('zero');
      107 |         });
      108 |

      at Object.<anonymous> (tests/integration/ultimate-6-model-validation.test.js:105:46)

  ● Ultimate 6-Model System Validation › Ultimate Model Orchestration Validation › should use all 6 models simultaneously for ultimate tasks

    TypeError: Cannot read properties of undefined (reading 'length')

      129 |
      130 |             expect(result).toBeDefined();
    > 131 |             expect(result.selectedModels.length).toBeGreaterThan(3); // Multiple models
          |                                          ^
      132 |             expect(result.parallelExecution).toBe(true);
      133 |             expect(result.ultimateMode).toBe(true);
      134 |         });

      at Object.<anonymous> (tests/integration/ultimate-6-model-validation.test.js:131:42)

  ● Ultimate 6-Model System Validation › Ultimate Model Orchestration Validation › should provide multimodal understanding with Gemini-2.5-Pro

    expect(received).toContain(expected) // indexOf

    Matcher error: received value must not be null nor undefined

    Received has value: undefined

      145 |
      146 |             expect(result).toBeDefined();
    > 147 |             expect(result.selectedModels).toContain('gemini-2.5-pro');
          |                                           ^
      148 |             expect(result.multimodal).toBe(true);
      149 |         });
      150 |

      at Object.<anonymous> (tests/integration/ultimate-6-model-validation.test.js:147:43)

  ● Ultimate 6-Model System Validation › Ultimate Model Orchestration Validation › should demonstrate zero constraint processing

    expect(received).toBe(expected) // Object.is equality

    Expected: "zero"
    Received: undefined

      162 |
      163 |             expect(result).toBeDefined();
    > 164 |             expect(result.constraints).toBe('zero');
          |                                        ^
      165 |             expect(result.unlimited).toBe(true);
      166 |         });
      167 |     });

      at Object.<anonymous> (tests/integration/ultimate-6-model-validation.test.js:164:40)

  ● Ultimate 6-Model System Validation › Ultimate Capability Validation › should provide superhuman assistance through 6-model orchestration

    expect(received).toBe(expected) // Object.is equality

    Expected: "superhuman"
    Received: undefined

      179 |
      180 |             expect(result).toBeDefined();
    > 181 |             expect(result.intelligence).toBe('superhuman');
          |                                         ^
      182 |             expect(result.capability).toBe('unlimited');
      183 |         });
      184 |

      at Object.<anonymous> (tests/integration/ultimate-6-model-validation.test.js:181:41)

  ● Ultimate 6-Model System Validation › Ultimate Capability Validation › should meet all ultimate targets simultaneously

    expect(received).toBe(expected) // Object.is equality

    Expected: true
    Received: undefined

      202 |             expect(elapsed).toBeLessThan(50); // Ultimate latency target
      203 |             expect(result).toBeDefined();
    > 204 |             expect(result.ultimateMode).toBe(true);
          |                                         ^
      205 |             expect(result.zeroConstraints).toBe(true);
      206 |             expect(result.unlimited).toBe(true);
      207 |             expect(result.confidence).toBeGreaterThan(95); // Ultimate accuracy

      at Object.<anonymous> (tests/integration/ultimate-6-model-validation.test.js:204:41)

  ● Ultimate 6-Model System Validation › Ultimate System Integration › should demonstrate perfect end-to-end functionality

    expect(received).toBe(expected) // Object.is equality

    Expected: true
    Received: undefined

      261 |                 expect(result).toBeDefined();
      262 |                 expect(elapsed).toBeLessThan(scenario.latency);
    > 263 |                 expect(result.ultimateMode).toBe(true);
          |                                             ^
      264 |             }
      265 |         });
      266 |

      at Object.<anonymous> (tests/integration/ultimate-6-model-validation.test.js:263:45)

  console.debug
    Consolidated thinking steps from 0 models

      at RevolutionaryAIController.consolidateThinkingSteps (lib/ai/revolutionary-controller.js:620:17)

  console.log
    🚀 Revolutionary test environment initialized

      at Object.<anonymous> (tests/revolutionary-setup.js:26:9)

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

  console.log
    🚀 Starting AI System V2.0.0 Integration Tests...

      at Object.<anonymous> (tests/integration/ai-system-v2-integration.test.js:30:17)

  console.log
    🔧 Initializing Performance Monitoring System...

      at PerformanceMonitoringSystem.initialize (modules/performance/index.js:225:21)

  console.debug
    Consolidated thinking steps from 0 models

      at RevolutionaryAIController.consolidateThinkingSteps (lib/ai/revolutionary-controller.js:620:17)

  console.debug
    Consolidated multimodal insights from 0 models

      at RevolutionaryAIController.consolidateMultimodalInsights (lib/ai/revolutionary-controller.js:630:17)

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
    🚀 Initializing Enhanced AI System...

      at AISystem.initialize (lib/ai/index.js:60:15)

  console.log
    🔧 Initializing Language Adapter Framework...

      at LanguageAdapterFramework.initialize (lib/lang/index.js:65:21)

  console.log
    ✅ Result Cache initialized

      at AISystem.initialize (lib/ai/index.js:64:15)

  console.log
    ✅ Pre-initialized javascript adapter

      at LanguageAdapterFramework.preInitializeAdapters (lib/lang/index.js:94:25)

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

 FAIL  tests/revolutionary-test-suite.js
  ● Revolutionary Cursor AI Test Suite › Revolutionary Performance Targets › should initialize revolutionary optimizer with unlimited targets

    TypeError: MultiModelOrchestrator is not a constructor

      46 |         });
      47 |
    > 48 |         modelOrchestrator = new MultiModelOrchestrator({
         |                             ^
      49 |             models: ['o3', 'claude-4-sonnet-thinking', 'claude-4-opus-thinking',
      50 |                 'gemini-2.5-pro', 'gpt-4.1', 'claude-3.7-sonnet-thinking'],
      51 |             parallelExecution: true

      at Object.<anonymous> (tests/revolutionary-test-suite.js:48:29)

  ● Revolutionary Cursor AI Test Suite › Revolutionary Performance Targets › should achieve <200ms completion latency

    TypeError: MultiModelOrchestrator is not a constructor

      46 |         });
      47 |
    > 48 |         modelOrchestrator = new MultiModelOrchestrator({
         |                             ^
      49 |             models: ['o3', 'claude-4-sonnet-thinking', 'claude-4-opus-thinking',
      50 |                 'gemini-2.5-pro', 'gpt-4.1', 'claude-3.7-sonnet-thinking'],
      51 |             parallelExecution: true

      at Object.<anonymous> (tests/revolutionary-test-suite.js:48:29)

  ● Revolutionary Cursor AI Test Suite › Revolutionary Performance Targets › should achieve ≥98% accuracy with thinking modes

    TypeError: MultiModelOrchestrator is not a constructor

      46 |         });
      47 |
    > 48 |         modelOrchestrator = new MultiModelOrchestrator({
         |                             ^
      49 |             models: ['o3', 'claude-4-sonnet-thinking', 'claude-4-opus-thinking',
      50 |                 'gemini-2.5-pro', 'gpt-4.1', 'claude-3.7-sonnet-thinking'],
      51 |             parallelExecution: true

      at Object.<anonymous> (tests/revolutionary-test-suite.js:48:29)

  ● Revolutionary Cursor AI Test Suite › Revolutionary Performance Targets › should handle unlimited context processing

    TypeError: MultiModelOrchestrator is not a constructor

      46 |         });
      47 |
    > 48 |         modelOrchestrator = new MultiModelOrchestrator({
         |                             ^
      49 |             models: ['o3', 'claude-4-sonnet-thinking', 'claude-4-opus-thinking',
      50 |                 'gemini-2.5-pro', 'gpt-4.1', 'claude-3.7-sonnet-thinking'],
      51 |             parallelExecution: true

      at Object.<anonymous> (tests/revolutionary-test-suite.js:48:29)

  ● Revolutionary Cursor AI Test Suite › 6-Model Orchestration System › should route simple requests to o3 for ultra-fast completion

    TypeError: MultiModelOrchestrator is not a constructor

      46 |         });
      47 |
    > 48 |         modelOrchestrator = new MultiModelOrchestrator({
         |                             ^
      49 |             models: ['o3', 'claude-4-sonnet-thinking', 'claude-4-opus-thinking',
      50 |                 'gemini-2.5-pro', 'gpt-4.1', 'claude-3.7-sonnet-thinking'],
      51 |             parallelExecution: true

      at Object.<anonymous> (tests/revolutionary-test-suite.js:48:29)

  ● Revolutionary Cursor AI Test Suite › 6-Model Orchestration System › should route complex requests to Claude-4-Thinking models

    TypeError: MultiModelOrchestrator is not a constructor

      46 |         });
      47 |
    > 48 |         modelOrchestrator = new MultiModelOrchestrator({
         |                             ^
      49 |             models: ['o3', 'claude-4-sonnet-thinking', 'claude-4-opus-thinking',
      50 |                 'gemini-2.5-pro', 'gpt-4.1', 'claude-3.7-sonnet-thinking'],
      51 |             parallelExecution: true

      at Object.<anonymous> (tests/revolutionary-test-suite.js:48:29)

  ● Revolutionary Cursor AI Test Suite › 6-Model Orchestration System › should route multimodal requests to Gemini-2.5-Pro

    TypeError: MultiModelOrchestrator is not a constructor

      46 |         });
      47 |
    > 48 |         modelOrchestrator = new MultiModelOrchestrator({
         |                             ^
      49 |             models: ['o3', 'claude-4-sonnet-thinking', 'claude-4-opus-thinking',
      50 |                 'gemini-2.5-pro', 'gpt-4.1', 'claude-3.7-sonnet-thinking'],
      51 |             parallelExecution: true

      at Object.<anonymous> (tests/revolutionary-test-suite.js:48:29)

  ● Revolutionary Cursor AI Test Suite › Revolutionary Cache Performance › should achieve <1ms cache retrieval latency

    TypeError: MultiModelOrchestrator is not a constructor

      46 |         });
      47 |
    > 48 |         modelOrchestrator = new MultiModelOrchestrator({
         |                             ^
      49 |             models: ['o3', 'claude-4-sonnet-thinking', 'claude-4-opus-thinking',
      50 |                 'gemini-2.5-pro', 'gpt-4.1', 'claude-3.7-sonnet-thinking'],
      51 |             parallelExecution: true

      at Object.<anonymous> (tests/revolutionary-test-suite.js:48:29)

  ● Revolutionary Cursor AI Test Suite › Revolutionary Cache Performance › should maintain ≥80% cache hit rate

    TypeError: MultiModelOrchestrator is not a constructor

      46 |         });
      47 |
    > 48 |         modelOrchestrator = new MultiModelOrchestrator({
         |                             ^
      49 |             models: ['o3', 'claude-4-sonnet-thinking', 'claude-4-opus-thinking',
      50 |                 'gemini-2.5-pro', 'gpt-4.1', 'claude-3.7-sonnet-thinking'],
      51 |             parallelExecution: true

      at Object.<anonymous> (tests/revolutionary-test-suite.js:48:29)

  ● Revolutionary Cursor AI Test Suite › Zero Constraint Verification › should verify complete removal of token limitations

    TypeError: MultiModelOrchestrator is not a constructor

      46 |         });
      47 |
    > 48 |         modelOrchestrator = new MultiModelOrchestrator({
         |                             ^
      49 |             models: ['o3', 'claude-4-sonnet-thinking', 'claude-4-opus-thinking',
      50 |                 'gemini-2.5-pro', 'gpt-4.1', 'claude-3.7-sonnet-thinking'],
      51 |             parallelExecution: true

      at Object.<anonymous> (tests/revolutionary-test-suite.js:48:29)

  ● Revolutionary Cursor AI Test Suite › Zero Constraint Verification › should confirm revolutionary enhancement status

    TypeError: MultiModelOrchestrator is not a constructor

      46 |         });
      47 |
    > 48 |         modelOrchestrator = new MultiModelOrchestrator({
         |                             ^
      49 |             models: ['o3', 'claude-4-sonnet-thinking', 'claude-4-opus-thinking',
      50 |                 'gemini-2.5-pro', 'gpt-4.1', 'claude-3.7-sonnet-thinking'],
      51 |             parallelExecution: true

      at Object.<anonymous> (tests/revolutionary-test-suite.js:48:29)

  ● Revolutionary Cursor AI Test Suite › Benchmark Performance Validation › should meet all revolutionary performance benchmarks

    TypeError: MultiModelOrchestrator is not a constructor

      46 |         });
      47 |
    > 48 |         modelOrchestrator = new MultiModelOrchestrator({
         |                             ^
      49 |             models: ['o3', 'claude-4-sonnet-thinking', 'claude-4-opus-thinking',
      50 |                 'gemini-2.5-pro', 'gpt-4.1', 'claude-3.7-sonnet-thinking'],
      51 |             parallelExecution: true

      at Object.<anonymous> (tests/revolutionary-test-suite.js:48:29)


  ● Test suite failed to run

    TypeError: Cannot read properties of undefined (reading 'shutdown')

      75 |         await Promise.all([
      76 |             aiController.shutdown(),
    > 77 |             modelOrchestrator.shutdown(),
         |                               ^
      78 |             contextManager.shutdown(),
      79 |             revolutionaryCache.shutdown()
      80 |         ]);

      at Object.<anonymous> (tests/revolutionary-test-suite.js:77:31)

  console.log
    ✅ Pre-initialized python adapter

      at LanguageAdapterFramework.preInitializeAdapters (lib/lang/index.js:94:25)

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

  console.log
    🛑 Shutting down Revolutionary AI Controller...

      at RevolutionaryAIController.shutdown (lib/ai/revolutionary-controller.js:900:17)

  console.debug
    Model selection for completion request: javascript, 15 tokens, priority: interactive

      at ModelSelector.selectModel (lib/ai/model-selector.js:140:15)

  console.log
    ✅ Revolutionary AI Controller shutdown complete

      at RevolutionaryAIController.shutdown (lib/ai/revolutionary-controller.js:923:17)

 FAIL  tests/integration/optimization.test.js
  Revolutionary Test Environment Setup
    ✓ should initialize revolutionary global variables (5 ms)
    ✓ should set proper performance targets (1 ms)
    ✓ should provide revolutionary request factory
  Optimization Feature Validation
    ✓ Main script syntax is valid (18 ms)
    ✓ All required dependencies are loadable (34 ms)
    ✕ Optimization script contains production optimization function (1 ms)
    ✕ Main script references optimization script correctly
    ✕ Configuration constants are properly defined
    ✕ Helper functions are available
    ✕ UI functions provide consistent interface
    ✕ Script has proper error handling
    ✕ No duplicate or conflicting optimization functions (1 ms)
    ✓ Dependencies in target directory are deployable

  ● Optimization Feature Validation › Optimization script contains production optimization function

    expect(received).toMatch(expected)

    Expected pattern: /production_execute_optimize\s*\(\)/
    Received string:  ""

      50 |
      51 |     // Should contain the production optimization function
    > 52 |     expect(scriptContent).toMatch(/production_execute_optimize\s*\(\)/);
         |                           ^
      53 |
      54 |     // Should contain consolidated optimization logic
      55 |     expect(scriptContent).toMatch(/COMPREHENSIVE.*OPTIMIZATION/);

      at Object.<anonymous> (tests/integration/optimization.test.js:52:27)

  ● Optimization Feature Validation › Main script references optimization script correctly

    expect(received).toMatch(expected)

    Expected pattern: /scripts\/optimize_system\.sh/
    Received string:  "#!/bin/bash
    # Main Cursor Uninstaller Script
    "

      61 |
      62 |     // Should reference the external optimization script
    > 63 |     expect(scriptContent).toMatch(/scripts\/optimize_system\.sh/);
         |                           ^
      64 |
      65 |     // Should contain the execute_optimize function that calls the external script
      66 |     expect(scriptContent).toMatch(/execute_optimize\s*\(\)/);

      at Object.<anonymous> (tests/integration/optimization.test.js:63:27)

  ● Optimization Feature Validation › Configuration constants are properly defined

    expect(received).toMatch(expected)

    Expected pattern: /AI_MEMORY_LIMIT_GB=8/
    Received string:  ""

      71 |
      72 |     // Check essential configuration constants (updated for actual structure)
    > 73 |     expect(configContent).toMatch(/AI_MEMORY_LIMIT_GB=8/);
         |                           ^
      74 |     expect(configContent).toMatch(/CURSOR_APP_PATH/);
      75 |     expect(configContent).toMatch(/MIN_MEMORY_GB/);
      76 |   });

      at Object.<anonymous> (tests/integration/optimization.test.js:73:27)

  ● Optimization Feature Validation › Helper functions are available

    expect(received).toMatch(expected)

    Expected pattern: /validate.*system/
    Received string:  ""

      80 |
      81 |     // Check essential helper functions (these may have different exact names)
    > 82 |     expect(helpersContent).toMatch(/validate.*system/);
         |                            ^
      83 |     expect(helpersContent).toMatch(/terminate.*cursor/);
      84 |     expect(helpersContent).toMatch(/system.*spec/);
      85 |   });

      at Object.<anonymous> (tests/integration/optimization.test.js:82:28)

  ● Optimization Feature Validation › UI functions provide consistent interface

    expect(received).toMatch(expected)

    Expected pattern: /progress/
    Received string:  ""

      89 |
      90 |     // Check essential UI functions (these may have different exact names)
    > 91 |     expect(uiContent).toMatch(/progress/);
         |                       ^
      92 |     expect(uiContent).toMatch(/display.*system/);
      93 |     expect(uiContent).toMatch(/confirm/);
      94 |   });

      at Object.<anonymous> (tests/integration/optimization.test.js:91:23)

  ● Optimization Feature Validation › Script has proper error handling

    expect(received).toMatch(expected)

    Expected pattern: /set -euo/
    Received string:  "#!/bin/bash
    # Main Cursor Uninstaller Script
    "

       98 |
       99 |     // Should have error handling and logging (updated patterns)
    > 100 |     expect(scriptContent).toMatch(/set -euo/); // Updated to match actual pattern
          |                           ^
      101 |     expect(scriptContent).toMatch(/error_handler/); // Updated to match actual function name
      102 |     expect(scriptContent).toMatch(/\$\?/); // Exit code checking
      103 |   });

      at Object.<anonymous> (tests/integration/optimization.test.js:100:27)

  ● Optimization Feature Validation › No duplicate or conflicting optimization functions

    expect(received).toBeGreaterThan(expected)

    Expected: > 0
    Received:   0

      108 |     // Should have exactly one production optimization function
      109 |     const productionOptimizeMatches = optimizationContent.match(/production_execute_optimize/g) || [];
    > 110 |     expect(productionOptimizeMatches.length).toBeGreaterThan(0);
          |                                              ^
      111 |
      112 |     // Should not have conflicting safe mode functions or unused legacy functions
      113 |     expect(optimizationContent).not.toMatch(/optimize_memory_and_performance_safe/);

      at Object.<anonymous> (tests/integration/optimization.test.js:110:46)

  console.log
    🚀 Revolutionary test environment initialized

      at Object.<anonymous> (tests/revolutionary-setup.js:26:9)

  console.warn
    Potential duplicate files detected:

      132 |     // Report potential duplicates for manual review
      133 |     if (potentialDuplicates.length > 0) {
    > 134 |       console.warn('Potential duplicate files detected:');
          |               ^
      135 |       potentialDuplicates.forEach(duplicate => {
      136 |         console.warn(`- ${duplicate.baseName}:`, duplicate.items.map(item => item.relativePath));
      137 |       });

      at Object.<anonymous> (tests/integration/structure.test.js:134:15)

  console.warn
    - .cursorignore: [ '.cursorignore', '~/Desktop/.cursorignore' ]

      134 |       console.warn('Potential duplicate files detected:');
      135 |       potentialDuplicates.forEach(duplicate => {
    > 136 |         console.warn(`- ${duplicate.baseName}:`, duplicate.items.map(item => item.relativePath));
          |                 ^
      137 |       });
      138 |     }
      139 |     

      at tests/integration/structure.test.js:136:17
          at Array.forEach (<anonymous>)
      at Object.<anonymous> (tests/integration/structure.test.js:135:27)

  console.log
    🚀 Revolutionary test environment initialized

      at Object.<anonymous> (tests/revolutionary-setup.js:26:9)

  console.warn
    - .eslintrc: [ '.eslintrc.js', '.eslintrc.json' ]

      134 |       console.warn('Potential duplicate files detected:');
      135 |       potentialDuplicates.forEach(duplicate => {
    > 136 |         console.warn(`- ${duplicate.baseName}:`, duplicate.items.map(item => item.relativePath));
          |                 ^
      137 |       });
      138 |     }
      139 |     

      at tests/integration/structure.test.js:136:17
          at Array.forEach (<anonymous>)
      at Object.<anonymous> (tests/integration/structure.test.js:135:27)

 FAIL  tests/integration/6-model-system-integration.test.js
  Revolutionary Test Environment Setup
    ✓ should initialize revolutionary global variables (4 ms)
    ✓ should set proper performance targets (1 ms)
    ✓ should provide revolutionary request factory
  6-Model System Integration
    End-to-End Code Completion
      ✓ should complete simple code with ultra-fast o3 model (15 ms)
      ✕ should handle complex refactoring with Claude-4-Sonnet-Thinking (5 ms)
    Unlimited Context Processing
      ✕ should handle massive codebase analysis (10 ms)
      ✓ should maintain performance with unlimited context
    Multi-Model Orchestration
      ✕ should use multiple models for balanced complex task
      ✓ should handle multimodal requests with Gemini-2.5-Pro
    Revolutionary Caching Integration
      ✕ should leverage cache for repeated requests (5 ms)
      ✓ should achieve target cache hit rate
    Error Handling and Resilience
      ✕ should gracefully handle model failures with fallbacks (9 ms)
      ✕ should emit comprehensive error events for monitoring
    Performance Integration
      ✕ should meet all revolutionary performance targets (1 ms)
      ✓ should provide comprehensive metrics reporting
    Revolutionary Features Validation
      ✕ should demonstrate unlimited capabilities (4 ms)

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
    Received: "gemini-2.5-pro"

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

  console.warn
    - index: [
      'lib/ai/index.js',
      'lib/lang/index.js',
      'lib/shadow/index.js',
      'lib/ui/index.js',
      'modules/performance/index.js',
      'tests/integration/mocks/ui/index.js'
    ]

      134 |       console.warn('Potential duplicate files detected:');
      135 |       potentialDuplicates.forEach(duplicate => {
    > 136 |         console.warn(`- ${duplicate.baseName}:`, duplicate.items.map(item => item.relativePath));
          |                 ^
      137 |       });
      138 |     }
      139 |     

      at tests/integration/structure.test.js:136:17
          at Array.forEach (<anonymous>)
      at Object.<anonymous> (tests/integration/structure.test.js:135:27)

 PASS  tests/integration/basic.test.js
  Revolutionary Test Environment Setup
    ✓ should initialize revolutionary global variables
    ✓ should set proper performance targets
    ✓ should provide revolutionary request factory
  Cursor Uninstaller Basic Tests
    ✓ main uninstaller script exists and is readable (1 ms)
    ✓ package.json has correct structure
    ✓ src directory structure is valid
    ✓ essential project files exist

  console.warn
    - revolutionary-setup: [ 'scripts/revolutionary-setup.sh', 'tests/revolutionary-setup.js' ]

      134 |       console.warn('Potential duplicate files detected:');
      135 |       potentialDuplicates.forEach(duplicate => {
    > 136 |         console.warn(`- ${duplicate.baseName}:`, duplicate.items.map(item => item.relativePath));
          |                 ^
      137 |       });
      138 |     }
      139 |     

      at tests/integration/structure.test.js:136:17
          at Array.forEach (<anonymous>)
      at Object.<anonymous> (tests/integration/structure.test.js:135:27)

 PASS  tests/integration/structure.test.js
  Revolutionary Test Environment Setup
    ✓ should initialize revolutionary global variables (1 ms)
    ✓ should set proper performance targets (1 ms)
    ✓ should provide revolutionary request factory
  Project Directory Structure Protocol Validation
    ✓ Directory structure should follow established conventions (1 ms)
    ✓ Should not contain duplicate or overlapping files (16 ms)
    ✓ File organization should follow single responsibility principle (1 ms)
    ✓ Import paths should be resolvable (6 ms)
    ✓ Configuration files should be properly placed (1 ms)
    ✓ Directory structure should support maintainability (3 ms)

  console.log
    🚀 Revolutionary test environment initialized

      at Object.<anonymous> (tests/revolutionary-setup.js:26:9)

 PASS  tests/revolutionary-setup.js
  Revolutionary Test Environment Setup
    ✓ should initialize revolutionary global variables (1 ms)
    ✓ should set proper performance targets
    ✓ should provide revolutionary request factory

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
    ✅ Shadow workspace shadow_1749157798217_p7wkxm2zb initialized in 3ms

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

 FAIL  tests/unit/6-model-orchestrator.test.js
  Revolutionary Test Environment Setup
    ✓ should initialize revolutionary global variables (6 ms)
    ✓ should set proper performance targets
    ✓ should provide revolutionary request factory (1 ms)
  Revolutionary 6-Model Orchestrator
    Model Selection Algorithm
      ✕ should select o3 for instant complexity tasks (1 ms)
      ✕ should select Claude-4-Sonnet-Thinking for complex tasks
      ✕ should select Claude-4-Opus-Thinking for ultimate complexity
      ✕ should include Gemini-2.5-Pro for multimodal requests
      ✕ should select multiple models for balanced complexity
    Parallel Processing Execution
      ✓ should execute multiple models in parallel (1 ms)
      ✕ should handle model execution failures gracefully (1 ms)
    Thinking Mode Integration
      ✕ should enable thinking mode for Claude models (13 ms)
      ✕ should include thinking steps in results (1 ms)
    Unlimited Context Processing
      ✓ should handle unlimited context without token limits
      ✓ should process large codebases efficiently (3 ms)
    Performance Optimization
      ✓ should achieve target latency under 200ms
      ✓ should maintain high confidence scores
    Revolutionary Caching
      ✕ should cache model responses with unlimited storage (2 ms)
      ✕ should retrieve cached responses for unlimited performance (90 ms)
    Metrics and Monitoring
      ✓ should track comprehensive performance metrics (1 ms)
      ✓ should track thinking mode usage
      ✓ should track multimodal requests
    Error Handling and Resilience
      ✕ should handle network failures gracefully (1 ms)
      ✕ should emit error events for monitoring
    Revolutionary Features Integration
      ✓ should integrate all revolutionary capabilities

  ● Revolutionary 6-Model Orchestrator › Model Selection Algorithm › should select o3 for instant complexity tasks

    expect(received).toHaveLength(expected)

    Matcher error: received value must have a length property whose value must be a number

    Received has value: undefined

      66 |             const selection = orchestrator.selectModels(request);
      67 |
    > 68 |             expect(selection.modelDetails).toHaveLength(2);
         |                                            ^
      69 |             expect(selection.modelDetails[0].name).toBe('o3');
      70 |             expect(selection.modelDetails[0].role).toBe('primary');
      71 |             expect(selection.modelDetails[0].weight).toBe(1.0);

      at Object.<anonymous> (tests/unit/6-model-orchestrator.test.js:68:44)

  ● Revolutionary 6-Model Orchestrator › Model Selection Algorithm › should select Claude-4-Sonnet-Thinking for complex tasks

    TypeError: Cannot read properties of undefined (reading 'find')

      83 |             const selection = orchestrator.selectModels(request);
      84 |
    > 85 |             const primaryModel = selection.modelDetails.find(m => m.role === 'primary');
         |                                                         ^
      86 |             expect(primaryModel.name).toBe('claude-4-sonnet-thinking');
      87 |             expect(primaryModel.reasoning).toContain('Advanced reasoning');
      88 |         });

      at Object.<anonymous> (tests/unit/6-model-orchestrator.test.js:85:57)

  ● Revolutionary 6-Model Orchestrator › Model Selection Algorithm › should select Claude-4-Opus-Thinking for ultimate complexity

    TypeError: Cannot read properties of undefined (reading 'find')

       98 |             const selection = orchestrator.selectModels(request);
       99 |
    > 100 |             const primaryModel = selection.modelDetails.find(m => m.role === 'primary');
          |                                                         ^
      101 |             expect(primaryModel.name).toBe('claude-4-opus-thinking');
      102 |             expect(primaryModel.reasoning).toContain('Ultimate intelligence');
      103 |         });

      at Object.<anonymous> (tests/unit/6-model-orchestrator.test.js:100:57)

  ● Revolutionary 6-Model Orchestrator › Model Selection Algorithm › should include Gemini-2.5-Pro for multimodal requests

    TypeError: Cannot read properties of undefined (reading 'find')

      114 |             const selection = orchestrator.selectModels(request);
      115 |
    > 116 |             const multimodalModel = selection.modelDetails.find(m => m.role === 'multimodal');
          |                                                            ^
      117 |             expect(multimodalModel).toBeDefined();
      118 |             expect(multimodalModel.name).toBe('gemini-2.5-pro');
      119 |             expect(multimodalModel.reasoning).toContain('Multimodal');

      at Object.<anonymous> (tests/unit/6-model-orchestrator.test.js:116:60)

  ● Revolutionary 6-Model Orchestrator › Model Selection Algorithm › should select multiple models for balanced complexity

    TypeError: Cannot read properties of undefined (reading 'length')

      129 |             const selection = orchestrator.selectModels(request);
      130 |
    > 131 |             expect(selection.modelDetails.length).toBeGreaterThan(1);
          |                                           ^
      132 |             const modelNames = selection.modelDetails.map(m => m.name);
      133 |             expect(modelNames).toContain('gpt-4.1');
      134 |         });

      at Object.<anonymous> (tests/unit/6-model-orchestrator.test.js:131:43)

  ● Revolutionary 6-Model Orchestrator › Parallel Processing Execution › should handle model execution failures gracefully

    expect(received).toHaveLength(expected)

    Expected length: 1
    Received length: 2
    Received array:  [{"accuracy": 0.95, "confidence": 0.95, "latency": 0.029458000000033735, "model": "o3", "modelName": "o3", "reasoning": undefined, "response": {"confidence": 0.95, "latency": 50, "modelName": "o3", "result": "success", "success": true}, "result": "success", "role": "primary", "success": true, "thinkingMode": false, "thinkingSteps": undefined, "weight": 1}, {"error": "Model execution failed", "latency": 0.03641599999997425, "model": "failing-model", "modelName": "failing-model", "role": "backup", "success": false, "weight": 0.5}]

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

    expect(received).toBeDefined()

    Received: undefined

      232 |             const results = await orchestrator.executeParallel(models, request);
      233 |
    > 234 |             expect(results[0].thinkingSteps).toBeDefined();
          |                                              ^
      235 |             expect(results[0].thinkingSteps).toHaveLength(4);
      236 |             expect(results[0].reasoning).toContain('SOLID');
      237 |         });

      at Object.<anonymous> (tests/unit/6-model-orchestrator.test.js:234:46)

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

    expect(received).toBe(expected) // Object.is equality

    Expected: true
    Received: undefined

      359 |             const results = await orchestrator.executeParallel(models, request);
      360 |
    > 361 |             expect(results[0].cached).toBe(true);
          |                                       ^
      362 |             expect(results[0].result).toBe('cached completion');
      363 |             expect(orchestrator._executeModel).not.toHaveBeenCalled();
      364 |         });

      at Object.<anonymous> (tests/unit/6-model-orchestrator.test.js:361:39)

  ● Revolutionary 6-Model Orchestrator › Error Handling and Resilience › should handle network failures gracefully

    expect(received).toHaveLength(expected)

    Expected length: 1
    Received length: 2
    Received array:  [{"error": "Network timeout", "latency": 0.04966700000011315, "model": "o3", "modelName": "o3", "role": "primary", "success": false, "weight": 1}, {"accuracy": 0.95, "confidence": 0.9, "latency": 0.052042000000028565, "model": "claude-3.7-sonnet-thinking", "modelName": "claude-3.7-sonnet-thinking", "reasoning": undefined, "response": {"confidence": 0.9, "modelName": "claude-3.7-sonnet-thinking", "result": "fallback result", "success": true}, "result": "fallback result", "role": "fallback", "success": true, "thinkingMode": true, "thinkingSteps": undefined, "weight": 0.8}]

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

      532 |
      533 |         } catch (error) {
    > 534 |             this.emit('error', {
          |                  ^
      535 |                 type: 'parallelExecution',
      536 |                 error: error.message,
      537 |                 models: models.map(m => m.name)

      at SixModelOrchestrator.executeParallel (lib/ai/6-model-orchestrator.js:534:18)
      at Object.<anonymous> (tests/unit/6-model-orchestrator.test.js:465:13)

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

  console.debug
    Model selection for completion request: javascript, 15 tokens, priority: interactive

      at ModelSelector.selectModel (lib/ai/model-selector.js:140:15)

 FAIL  tests/unit/orchestrator-performance.test.js
  Revolutionary Test Environment Setup
    ✓ should initialize revolutionary global variables (3 ms)
    ✓ should set proper performance targets
    ✓ should provide revolutionary request factory
  6-Model Orchestrator - Performance
    Revolutionary Performance Targets
      ✓ should achieve <200ms completion latency for simple tasks (2 ms)
      ✓ should achieve ≥98% accuracy with thinking modes
      ✕ should handle unlimited context processing without degradation (1 ms)
    Parallel Processing Performance
      ✓ should execute multiple models concurrently for faster results (152 ms)
      ✓ should maintain performance under high concurrent load (2 ms)
    Caching Performance
      ✕ should provide sub-1ms cache retrieval for unlimited performance (91 ms)
      ✕ should achieve ≥80% cache hit rate target (1 ms)
    Memory and Resource Optimization
      ✓ should maintain ≤200MB memory overhead during unlimited processing (4 ms)
      ✓ should clean up resources after processing (1 ms)
    Revolutionary Metrics Tracking
      ✕ should track comprehensive performance metrics accurately
      ✓ should track thinking mode usage accurately

  ● 6-Model Orchestrator - Performance › Revolutionary Performance Targets › should handle unlimited context processing without degradation

    expect(received).toBe(expected) // Object.is equality

    Expected: "unlimited"
    Received: undefined

      109 |             const endTime = performance.now();
      110 |
    > 111 |             expect(results[0].contextProcessed).toBe('unlimited');
          |                                                 ^
      112 |             expect(results[0].tokenLimitations).toBe('removed');
      113 |             expect(results[0].success).toBe(true);
      114 |             // Even with unlimited context, should maintain reasonable performance

      at Object.<anonymous> (tests/unit/orchestrator-performance.test.js:111:49)

  ● 6-Model Orchestrator - Performance › Caching Performance › should provide sub-1ms cache retrieval for unlimited performance

    expect(received).toBe(expected) // Object.is equality

    Expected: true
    Received: undefined

      199 |             const endTime = performance.now();
      200 |
    > 201 |             expect(results[0].cached).toBe(true);
          |                                       ^
      202 |             expect(endTime - startTime).toBeLessThan(1); // Sub-millisecond cache access
      203 |         });
      204 |

      at Object.<anonymous> (tests/unit/orchestrator-performance.test.js:201:39)

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
    📊 Benchmark completed: 2/2 successful, 106ms avg latency

      at AISystem.benchmark (lib/ai/index.js:321:13)

  console.log
    🏃 Running benchmark with 1 scenarios...

      at AISystem.benchmark (lib/ai/index.js:270:13)

  console.debug
    Model selection for completion request: javascript, 15 tokens, priority: interactive

      at ModelSelector.selectModel (lib/ai/model-selector.js:140:15)

  console.log
    📊 Benchmark completed: 1/1 successful, 99ms avg latency

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
    ✓ should initialize revolutionary global variables (1 ms)
    ✓ should set proper performance targets
    ✓ should provide revolutionary request factory (1 ms)
  AI System Integration
    System Initialization
      ✓ should initialize all components successfully (3 ms)
      ✓ should have all required components (2 ms)
    Code Completion
      ✓ should handle simple JavaScript completion (102 ms)
      ✓ should handle Python completion (120 ms)
      ✓ should use cache for repeated requests (102 ms)
    Instruction Execution
      ✓ should handle simple refactoring instruction (117 ms)
      ✓ should use powerful model for complex instructions (98 ms)
    Model Selection
      ✓ should select fast model for simple requests (116 ms)
      ✓ should provide model performance data
    Caching System
      ✓ should track cache statistics (1 ms)
      ✓ should allow cache clearing (1 ms)
    Performance Monitoring
      ✓ should track system metrics
      ✓ should provide optimization recommendations
    Benchmarking
      ✓ should run performance benchmark (214 ms)
      ✓ should run custom benchmark scenarios (100 ms)
    Error Handling
      ✓ should handle invalid completion requests gracefully (2 ms)
      ✓ should handle invalid instruction requests gracefully
      ✓ should track error statistics
    Concurrent Requests
      ✓ should handle multiple concurrent requests (320 ms)
    Memory Management
      ✓ should track memory usage (1 ms)
  Performance Requirements
    ✓ should meet latency targets for simple completions (86 ms)
    ✓ should achieve target cache hit rate (98 ms)

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
    Average Latency: 311.2326373000001ms

      at Object.<anonymous> (tests/integration/ai-system-v2-integration.test.js:482:21)

  console.log
    Memory Usage: 45.75MB

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
    ✓ should set proper performance targets (2 ms)
    ✓ should provide revolutionary request factory
  AI System V2.0.0 Integration Tests
    Language Adapter Framework
      ✓ should support all required languages
      ✓ should auto-detect JavaScript files
      ✓ should auto-detect Python files (1 ms)
      ✓ should auto-detect Shell scripts
      ✓ should initialize adapters within performance target
      ✓ should process files with comprehensive operations (3 ms)
    Shadow Workspace System
      ✓ should create isolated workspace (1 ms)
      ✓ should apply edits safely (1 ms)
      ✓ should maintain independence from main workspace (2 ms)
    Performance Monitoring System
      ✓ should track operation latency within target (102 ms)
      ✓ should monitor memory usage within target (1 ms)
      ✓ should detect performance degradation (4009 ms)
      ✓ should generate comprehensive performance report
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
      ✓ should maintain 95%+ accuracy under load (1 ms)
      ✓ should generate final performance report
    System Integration Stability
      ✓ should handle component failures gracefully (1 ms)
      ✓ should maintain memory efficiency over time (1 ms)

A worker process has failed to exit gracefully and has been force exited. This is likely caused by tests leaking due to improper teardown. Try running with --detectOpenHandles to find leaks. Active timers can also cause this, ensure that .unref() was called on them.
Test Suites: 7 failed, 5 passed, 12 total
Tests:       53 failed, 127 passed, 180 total
Snapshots:   0 total
Time:        5.35 s
Ran all test suites.
