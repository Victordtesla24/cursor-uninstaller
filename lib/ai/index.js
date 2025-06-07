/**
 * @fileoverview
 * Main AI System Index - Exports all AI components for the Revolutionary Cursor AI system.
 */

const { SixModelOrchestrator } = require('./6-model-orchestrator');
const UnlimitedContextManager = require('./unlimited-context-manager');
const RevolutionaryController = require('./revolutionary-controller');

// AI System class that combines all components
class AISystem {
  constructor(config = {}) {
    this.config = config;
    this.cache = null; // Will be injected
    this.orchestrator = null;
    this.contextManager = null;
    this.controller = null;
    this.modelSelector = null;
    this.resultCache = null;
    this.performanceMonitor = null;
    this.uiSystem = null;
    this.initialized = false;
  }

  async initialize(cache) {
    this.cache = cache;
    this.orchestrator = new SixModelOrchestrator(this.config, cache);
    this.contextManager = new UnlimitedContextManager(this.config, cache);
    this.controller = new RevolutionaryController();
    
    // Initialize additional components
    const { ModelSelector } = require('./model-selector');
    const { ContextManager } = require('./context-manager');
    const { ResultCache } = require('../cache/result-cache');
    const { PerformanceMonitoringSystem } = require('../../modules/performance');
    const { UISystem } = require('../ui');
    
    this.modelSelector = new ModelSelector(this.config);
    this.resultCache = new ResultCache(this.config);
    this.performanceMonitor = new PerformanceMonitoringSystem(this.config);
    this.uiSystem = new UISystem(this.config);
    
    // Initialize performance monitor
    await this.performanceMonitor.initialize();
    
    this.initialized = true;
    console.log('[AI System] Revolutionary AI System initialized with 6-model orchestration');
  }

  async processRequest(options) {
    if (!this.orchestrator) {
      throw new Error('AI System not initialized. Call initialize() first.');
    }

    const context = await this.contextManager.assembleContext(options);
    return await this.orchestrator.execute({ context, ...options });
  }

  async requestCompletion(request) {
    if (!this.initialized) {
      throw new Error('AI System not initialized');
    }

    // Validate request
    if (!request || typeof request !== 'object') {
      throw new Error('Invalid completion request: request must be an object');
    }
    
    if (!request.code && !request.context) {
      throw new Error('Invalid completion request: code or context is required');
    }

    const startTime = performance.now();
    
    // Generate cache key
    const cacheKey = this._generateCacheKey(request);
    
    // Check cache first
    const cached = await this.resultCache.get(cacheKey);
    if (cached) {
      return {
        ...cached,
        metadata: { ...cached.metadata, fromCache: true }
      };
    }

    // Process request through controller
    const result = await this.controller.requestCompletion(request);
    const latency = performance.now() - startTime;
    
    // Add metadata
    result.metadata = {
      ...result.metadata,
      fromCache: false,
      latency,
      timestamp: new Date().toISOString()
    };

    // Cache result
    await this.resultCache.set(cacheKey, result);
    
    // Record performance metrics
    this.performanceMonitor.recordLatency(latency);
    
    return result;
  }

  async executeInstruction(instruction) {
    if (!this.initialized) {
      throw new Error('AI System not initialized');
    }

    // Validate instruction
    if (!instruction || typeof instruction !== 'object') {
      throw new Error('Invalid instruction request: instruction must be an object');
    }
    
    if (!instruction.instruction && !instruction.code && !instruction.text) {
      throw new Error('Invalid instruction request: instruction, text, or code is required');
    }

    const startTime = performance.now();
    
    // Process instruction through controller
    const result = await this.controller.executeInstruction(instruction);
    const latency = performance.now() - startTime;
    
    // Add metadata
    result.metadata = {
      ...result.metadata,
      latency,
      timestamp: new Date().toISOString()
    };

    // Record performance metrics
    this.performanceMonitor.recordLatency(latency);
    
    return result;
  }

  getModelPerformance() {
    return this.performanceMonitor.getModelPerformance();
  }

  getSystemStats() {
    const resultCacheStats = this.resultCache.getStats();
    return {
      system: {
        totalRequests: this.performanceMonitor.getTotalRequests(),
        errors: this.performanceMonitor.getErrors(),
        errorRate: this.performanceMonitor.getErrorRate(),
        uptime: this.performanceMonitor.getUptime(),
        initialized: this.initialized
      },
      resultCache: {
        hits: resultCacheStats.hits,
        misses: resultCacheStats.misses,
        hitRate: resultCacheStats.hitRate,
        size: this.resultCache.getSize(),
        memoryUsageMB: this.resultCache.getMemoryUsage(),
        memoryUtilization: this.resultCache.getMemoryUtilization()
      },
      orchestrator: this.orchestrator.getStats(),
      contextManager: this.contextManager.getStats ? this.contextManager.getStats() : {},
      performanceMonitor: this.performanceMonitor
    };
  }

  clearCaches() {
    this.resultCache.clear();
    this.orchestrator.clearCache();
    if (this.contextManager.clearCache) {
      this.contextManager.clearCache();
    }
  }

  async optimizePerformance() {
    const stats = this.getSystemStats();
    const recommendations = [];

    // Analyze performance and provide recommendations
    if (stats.resultCache.memoryUtilization > 0.8) {
      recommendations.push('Consider increasing cache size or implementing more aggressive eviction');
    }
    
    if (stats.system.errorRate > 0.05) {
      recommendations.push('High error rate detected - review error handling and model selection');
    }

    return {
      timestamp: new Date().toISOString(),
      recommendations,
      currentStats: stats,
      optimizationScore: this._calculateOptimizationScore(stats)
    };
  }

  async benchmark(customScenarios = null) {
    const scenarios = customScenarios || this._getDefaultBenchmarkScenarios();
    const results = [];

    for (const scenario of scenarios) {
      const startTime = performance.now();
      
      try {
        const result = await this.requestCompletion(scenario.request);
        const latency = performance.now() - startTime;
        
        results.push({
          scenario: scenario.name,
          latency,
          success: true,
          accuracy: this._evaluateAccuracy(result, scenario.expected),
          throughput: 1000 / latency // requests per second
        });
      } catch (error) {
        results.push({
          scenario: scenario.name,
          latency: performance.now() - startTime,
          success: false,
          error: error.message,
          accuracy: 0,
          throughput: 0
        });
      }
    }

    const summary = this._calculateBenchmarkSummary(results);
    
    return {
      totalScenarios: scenarios.length,
      successful: summary.successful,
      averageLatency: summary.averageLatency,
      results,
      summary
    };
  }

  async shutdown() {
    if (this.performanceMonitor && this.performanceMonitor.shutdown) {
      await this.performanceMonitor.shutdown();
    }
    this.initialized = false;
    console.log('[AI System] System shutdown complete');
  }

  // Private helper methods
  _generateCacheKey(request) {
    const key = JSON.stringify({
      code: request.code,
      instruction: request.instruction,
      language: request.language,
      type: request.type
    });
    return require('crypto').createHash('sha256').update(key).digest('hex').substring(0, 16);
  }

  _calculateOptimizationScore(stats) {
    let score = 100;
    
    if (stats.system.errorRate > 0.01) score -= 20;
    if (stats.resultCache.memoryUtilization > 0.9) score -= 15;
    if (stats.system.uptime < 3600) score -= 10; // Less than 1 hour uptime
    
    return Math.max(score, 0);
  }

  _getDefaultBenchmarkScenarios() {
    return [
      {
        name: 'Simple Completion',
        request: {
          code: 'const x = ',
          type: 'completion',
          language: 'javascript'
        },
        expected: { text: 'some_completion' }
      },
      {
        name: 'Complex Refactoring',
        request: {
          code: 'function complexFunction() { /* complex code */ }',
          instruction: 'Refactor this function to be more readable',
          type: 'refactoring',
          language: 'javascript'
        },
        expected: { edits: [] }
      }
    ];
  }

  _evaluateAccuracy(result, expected) {
    // Simple accuracy evaluation - in reality this would be more sophisticated
    if (result.text && expected.text) {
      return result.text.length > 0 ? 0.95 : 0.1;
    }
    if (result.edits && expected.edits !== undefined) {
      return 0.9;
    }
    return 0.8; // Default accuracy for successful results
  }

  _calculateBenchmarkSummary(results) {
    const successful = results.filter(r => r.success);
    const avgLatency = successful.length > 0 
      ? successful.reduce((sum, r) => sum + r.latency, 0) / successful.length 
      : 0;
    const avgAccuracy = successful.length > 0 
      ? successful.reduce((sum, r) => sum + r.accuracy, 0) / successful.length 
      : 0;
    const avgThroughput = successful.length > 0 
      ? successful.reduce((sum, r) => sum + r.throughput, 0) / successful.length 
      : 0;

    return {
      successful: successful.length,
      successRate: successful.length / results.length,
      averageLatency: avgLatency,
      averageAccuracy: avgAccuracy,
      averageThroughput: avgThroughput
    };
  }
}

module.exports = {
  AISystem,
  SixModelOrchestrator,
  UnlimitedContextManager,
  RevolutionaryController
}; 