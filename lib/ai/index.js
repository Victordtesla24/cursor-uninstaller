/**
 * AI System Integration - Main entry point for the enhanced AI system
 * Integrates all AI components and provides unified interface
 * Target: Complete system initialization and orchestration
 */

const { AIController, AIControllerError } = require('./controller');
const ModelSelector = require('./model-selector');
const ContextManager = require('./context-manager');
const ResultCache = require('../cache/result-cache');

class AISystem {
  constructor(options = {}) {
    this.config = {
      enableCaching: true,
      enableMetrics: true,
      maxConcurrentRequests: 2,
      defaultTimeout: 5000,
      quietMode: process.env.NODE_ENV === 'test', // Suppress expected error logs during testing
      modelSelection: {
        enableIntelligentRouting: true,
        fastModelThreshold: 200
      },
      contextManagement: {
        maxContextTokens: 8000,
        cacheContexts: true
      },
      resultCaching: {
        maxSize: 1000,
        maxMemoryMB: 100,
        defaultTTL: 300000
      },
      ...options
    };

    this.controller = null;
    this.modelSelector = null;
    this.contextManager = null;
    this.resultCache = null;
    this.performanceMonitor = null;

    this.initialized = false;
    this.stats = {
      startTime: null,
      totalRequests: 0,
      errors: 0
    };
  }

  /**
   * Initialize the AI system with all components
   */
  async initialize() {
    if (this.initialized) {
      console.warn('AI System already initialized');
      return;
    }

    try {
      console.log('🚀 Initializing Enhanced AI System...');

      // 1. Initialize Result Cache
      this.resultCache = new ResultCache(this.config.resultCaching);
      console.log('✅ Result Cache initialized');

      // 2. Initialize Model Selector
      this.modelSelector = new ModelSelector(this.config.modelSelection);
      console.log('✅ Model Selector initialized');

      // 3. Initialize Context Manager
      this.contextManager = new ContextManager(this.config.contextManagement);
      console.log('✅ Context Manager initialized');

      // 4. Initialize Performance Monitor
      this.performanceMonitor = new PerformanceMonitor();
      console.log('✅ Performance Monitor initialized');

      // 5. Initialize AI Controller with dependencies
      this.controller = new AIController({
        maxConcurrentRequests: this.config.maxConcurrentRequests,
        defaultTimeout: this.config.defaultTimeout,
        enableCaching: this.config.enableCaching,
        enableTelemetry: this.config.enableMetrics
      });

      await this.controller.initialize({
        modelSelector: this.modelSelector,
        contextManager: this.contextManager,
        resultCache: this.resultCache,
        performanceMonitor: this.performanceMonitor
      });

      // 6. Set up event handlers
      this.setupEventHandlers();

      this.initialized = true;
      this.stats.startTime = Date.now();

      console.log('🎉 AI System fully initialized and ready');

    } catch (error) {
      console.error('❌ Failed to initialize AI System:', error.message);
      throw new Error(`AI System initialization failed: ${error.message}`);
    }
  }

  /**
   * Request code completion
   * @param {Object} request - Completion request
   * @returns {Promise<Object>} Completion result
   */
  async requestCompletion(request) {
    this.ensureInitialized();

    try {
      this.stats.totalRequests++;
      return await this.controller.requestCompletion(request);
    } catch (error) {
      this.stats.errors++;
      throw error;
    }
  }

  /**
   * Execute instruction-based editing
   * @param {Object} instruction - Instruction request
   * @returns {Promise<Object>} Edit result
   */
  async executeInstruction(instruction) {
    this.ensureInitialized();

    try {
      this.stats.totalRequests++;
      return await this.controller.executeInstruction(instruction);
    } catch (error) {
      this.stats.errors++;
      throw error;
    }
  }

  /**
   * Get comprehensive system statistics
   * @returns {Object} System statistics
   */
  getSystemStats() {
    this.ensureInitialized();

    const uptime = this.stats.startTime ? Date.now() - this.stats.startTime : 0;

    return {
      system: {
        initialized: this.initialized,
        uptime,
        totalRequests: this.stats.totalRequests,
        errors: this.stats.errors,
        errorRate: this.stats.totalRequests > 0 ?
          (this.stats.errors / this.stats.totalRequests) * 100 : 0
      },
      controller: this.controller.getStats(),
      modelSelector: this.modelSelector.getSelectionStats(),
      contextManager: this.contextManager.getStats(),
      resultCache: this.resultCache.getStats(),
      performanceMonitor: this.performanceMonitor.getStats()
    };
  }

  /**
   * Get model performance data
   * @param {string} modelName - Optional specific model name
   * @returns {Object} Model performance statistics
   */
  getModelPerformance(modelName) {
    this.ensureInitialized();
    return this.modelSelector.getModelPerformance(modelName);
  }

  /**
   * Update model configuration
   * @param {string} modelName - Model to update
   * @param {Object} config - New configuration
   */
  updateModelConfig(modelName, config) {
    this.ensureInitialized();
    this.modelSelector.updateModelConfig(modelName, config);
  }

  /**
   * Clear all caches
   */
  clearCaches() {
    this.ensureInitialized();

    if (this.resultCache) {
      this.resultCache.clear();
    }

    if (this.contextManager) {
      this.contextManager.clearCache();
    }

    console.log('🧹 All caches cleared');
  }

  /**
   * Optimize system performance based on current metrics
   */
  async optimizePerformance() {
    this.ensureInitialized();

    const stats = this.getSystemStats();
    const optimizations = [];

    // Check cache performance
    if (stats.resultCache.hitRate < 30) {
      optimizations.push('Consider increasing cache TTL or size');
    }

    // Check model selection efficiency
    const modelPerf = this.getModelPerformance();
    for (const [model, perf] of Object.entries(modelPerf)) {
      if (perf.performanceRatio > 1.5) {
        optimizations.push(`Model ${model} is consistently slow`);
      }
    }

    // Check context manager efficiency
    if (stats.contextManager.averageAssemblyTime > 100) {
      optimizations.push('Context assembly is slow, consider reducing context radius');
    }

    return {
      timestamp: new Date().toISOString(),
      recommendations: optimizations,
      currentStats: stats
    };
  }

  /**
   * Benchmark system performance
   * @param {Object} scenarios - Test scenarios to run
   * @returns {Promise<Object>} Benchmark results
   */
  async benchmark(scenarios = null) {
    this.ensureInitialized();

    const defaultScenarios = [
      {
        name: 'Simple JavaScript Completion',
        request: {
          code: 'const x = ',
          language: 'javascript',
          position: { line: 0, character: 10 }
        },
        type: 'completion'
      },
      {
        name: 'Complex TypeScript Refactor',
        instruction: {
          text: 'Refactor this function to use async/await',
          language: 'typescript',
          selection: { start: { line: 0, character: 0 }, end: { line: 10, character: 0 } }
        },
        type: 'instruction'
      }
    ];

    const testScenarios = scenarios || defaultScenarios;
    const results = [];

    console.log(`🏃 Running benchmark with ${testScenarios.length} scenarios...`);

    for (const scenario of testScenarios) {
      const startTime = performance.now();

      try {
        let result;
        if (scenario.type === 'completion') {
          result = await this.requestCompletion(scenario.request);
        } else if (scenario.type === 'instruction') {
          result = await this.executeInstruction(scenario.instruction);
        }

        const latency = performance.now() - startTime;

        results.push({
          scenario: scenario.name,
          success: true,
          latency: Math.round(latency),
          model: result.metadata?.model,
          fromCache: result.metadata?.fromCache || false
        });

      } catch (error) {
        const latency = performance.now() - startTime;

        results.push({
          scenario: scenario.name,
          success: false,
          latency: Math.round(latency),
          error: error.message
        });
      }
    }

    // Calculate aggregate metrics
    const successful = results.filter(r => r.success);
    const avgLatency = successful.length > 0 ?
      successful.reduce((sum, r) => sum + r.latency, 0) / successful.length : 0;

    const benchmarkResult = {
      timestamp: new Date().toISOString(),
      totalScenarios: testScenarios.length,
      successful: successful.length,
      failed: results.length - successful.length,
      successRate: (successful.length / results.length) * 100,
      averageLatency: Math.round(avgLatency),
      results,
      systemStats: this.getSystemStats()
    };

    console.log(`📊 Benchmark completed: ${successful.length}/${testScenarios.length} successful, ${Math.round(avgLatency)}ms avg latency`);

    return benchmarkResult;
  }

  /**
   * Shutdown the AI system gracefully
   */
  async shutdown() {
    if (!this.initialized) {
      return;
    }

    console.log('🛑 Shutting down AI System...');

    try {
      this.initialized = false; // Set this first to stop monitoring

      // Clear monitoring interval
      if (this.monitoringInterval) {
        clearInterval(this.monitoringInterval);
        this.monitoringInterval = null;
      }

      // Shutdown components in reverse order of initialization
      if (this.performanceMonitor) {
        await this.performanceMonitor.shutdown();
      }

      if (this.controller) {
        await this.controller.shutdown();
      }

      if (this.resultCache) {
        this.resultCache.shutdown();
      }

      if (this.contextManager) {
        this.contextManager.clearCache();
      }

      // Reset component references
      this.controller = null;
      this.modelSelector = null;
      this.contextManager = null;
      this.resultCache = null;
      this.performanceMonitor = null;

      console.log('✅ AI System shutdown complete');

    } catch (error) {
      console.error('❌ Error during shutdown:', error.message);
      throw error; // Rethrow to indicate shutdown failure
    }
  }

  /**
   * Setup event handlers for system monitoring
   * @private
   */
  setupEventHandlers() {
    this.controller.on('error', (error) => {
      // Only log errors if not in quiet mode or if they're unexpected
      if (!this.config.quietMode || this.isUnexpectedError(error)) {
        console.error('AI Controller Error:', error);
      }
      this.stats.errors++;
    });

    this.controller.on('requestCancelled', (requestId) => {
      if (!this.config.quietMode) {
        console.warn(`Request ${requestId} was cancelled`);
      }
    });

    // Setup performance monitoring - only in production, never in test mode
    if (this.config.enableMetrics && process.env.NODE_ENV !== 'test') {
      this.monitoringInterval = setInterval(() => {
        if (!this.initialized) {
          // Clear interval if system is shut down
          clearInterval(this.monitoringInterval);
          this.monitoringInterval = null;
          return;
        }

        const stats = this.getSystemStats();
        if (stats.system.errorRate > 10 && !this.config.quietMode) {
          console.warn(`⚠️ High error rate detected: ${stats.system.errorRate.toFixed(1)}%`);
        }
      }, 30000); // Check every 30 seconds
    }
  }

  /**
   * Determine if error is unexpected (should always be logged)
   * @private
   */
  isUnexpectedError(error) {
    const expectedErrors = [
      'Request must include code or position',
      'Instruction must include text or type',
      'Request timeout in queue',
      'QUEUE_TIMEOUT'
    ];

    const errorMessage = error.error || error.message || '';
    const errorCode = error.code || '';

    // In test mode with quiet enabled, suppress all expected errors
    if (this.config.quietMode) {
      return !expectedErrors.some(expected =>
        errorMessage.includes(expected) || errorCode.includes(expected)
      );
    }

    return !expectedErrors.some(expected =>
      errorMessage.includes(expected) || errorCode.includes(expected)
    );
  }

  /**
   * Ensure system is initialized
   * @private
   */
  ensureInitialized() {
    if (!this.initialized) {
      throw new Error('AI System not initialized. Call initialize() first.');
    }
  }
}

/**
 * Simple Performance Monitor for tracking system metrics
 */
class PerformanceMonitor {
  constructor() {
    this.metrics = {
      requests: [],
      latencies: [],
      errors: []
    };
    this.monitoringInterval = null;
    this.isShutdown = false;
  }

  async initialize() {
    this.isShutdown = false;
    // Only start internal monitoring in production, not during tests
    if (process.env.NODE_ENV !== 'test') {
      this.startInternalMonitoring();
    }
  }

  startInternalMonitoring() {
    // Only start if not already running and not shutdown
    if (!this.monitoringInterval && !this.isShutdown) {
      this.monitoringInterval = setInterval(() => {
        if (this.isShutdown) {
          clearInterval(this.monitoringInterval);
          this.monitoringInterval = null;
          return;
        }
        // Periodic cleanup of old metrics
        this.performPeriodicCleanup();
      }, 60000); // Every minute
    }
  }

  performPeriodicCleanup() {
    // Keep only last 1000 measurements for each metric type
    if (this.metrics.latencies.length > 1000) {
      this.metrics.latencies = this.metrics.latencies.slice(-1000);
    }
    if (this.metrics.requests.length > 1000) {
      this.metrics.requests = this.metrics.requests.slice(-1000);
    }
    if (this.metrics.errors.length > 1000) {
      this.metrics.errors = this.metrics.errors.slice(-1000);
    }
  }

  recordLatency(latency) {
    if (this.isShutdown) return;

    this.metrics.latencies.push({
      value: latency,
      timestamp: Date.now()
    });

    // Keep only last 1000 measurements
    if (this.metrics.latencies.length > 1000) {
      this.metrics.latencies = this.metrics.latencies.slice(-1000);
    }
  }

  getStats() {
    const latencies = this.metrics.latencies.map(l => l.value);

    if (latencies.length === 0) {
      return {
        averageLatency: 0,
        p95Latency: 0,
        p99Latency: 0,
        totalMeasurements: 0
      };
    }

    const sorted = [...latencies].sort((a, b) => a - b);
    const p95Index = Math.floor(sorted.length * 0.95);
    const p99Index = Math.floor(sorted.length * 0.99);

    return {
      averageLatency: Math.round(latencies.reduce((sum, l) => sum + l, 0) / latencies.length),
      p95Latency: sorted[p95Index] || 0,
      p99Latency: sorted[p99Index] || 0,
      totalMeasurements: latencies.length
    };
  }

  async shutdown() {
    this.isShutdown = true;

    // Clear the monitoring interval
    if (this.monitoringInterval) {
      clearInterval(this.monitoringInterval);
      this.monitoringInterval = null;
    }

    // Clear metrics
    this.metrics = { requests: [], latencies: [], errors: [] };
  }
}

module.exports = {
  AISystem,
  AIController,
  AIControllerError,
  ModelSelector,
  ContextManager,
  ResultCache,
  PerformanceMonitor
};
