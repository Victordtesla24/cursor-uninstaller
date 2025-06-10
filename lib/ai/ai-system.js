/**
 * @fileoverview
 * AI System - Main orchestrator for the enhanced AI development tools
 * Integrates all AI components with performance monitoring and caching
 */

const AIController = require('./ai-controller');
const ModelSelector = require('./model-selector');
const ContextManager = require('./context-manager');
const PerformanceOptimizer = require('./performance-optimizer');
const ResultCache = require('../cache/result-cache');
const { BasicError, ApiError } = require('../system/errors');

/**
 * Main AI System class that orchestrates all AI components
 */
class AISystem {
  constructor(options = {}) {
    this.options = {
      enableCaching: true,
      enableMetrics: true,
      quietMode: false,
      resultCaching: {
        maxSize: 1000,
        maxMemoryMB: 50,
        defaultTTL: 300000 // 5 minutes
      },
      ...options
    };

    this.initialized = false;
    this.startTime = Date.now();
    this.totalRequests = 0;
    this.errors = 0;
    this.shutdownRequested = false;

    // Core components
    this.controller = null;
    this.modelSelector = null;
    this.contextManager = null;
    this.resultCache = null;
    this.performanceMonitor = null;
  }

  /**
   * Initialize all AI system components
   */
  async initialize() {
    try {
      if (this.initialized) {
        return;
      }

      // Initialize core components
      this.modelSelector = new ModelSelector();
      this.contextManager = new ContextManager();
      this.controller = new AIController({
        modelSelector: this.modelSelector,
        contextManager: this.contextManager,
        quietMode: this.options.quietMode
      });

      // Initialize the controller
      await this.controller.initialize();

      // Initialize caching if enabled
      if (this.options.enableCaching) {
        this.resultCache = new ResultCache(this.options.resultCaching);
      }

      // Initialize performance monitoring if enabled
      if (this.options.enableMetrics) {
        this.performanceMonitor = new PerformanceOptimizer({
          quietMode: this.options.quietMode
        });
      }

      this.initialized = true;

      if (!this.options.quietMode) {
        console.log('AI System initialized successfully');
      }
    } catch (error) {
      this.errors++;
      throw new BasicError(`Failed to initialize AI System: ${error.message}`);
    }
  }

  /**
   * Shutdown the AI system gracefully
   */
  async shutdown() {
    try {
      this.shutdownRequested = true;

      if (this.resultCache) {
        this.resultCache.clear();
      }

      if (this.performanceMonitor) {
        await this.performanceMonitor.shutdown();
      }

      this.initialized = false;

      if (!this.options.quietMode) {
        console.log('AI System shutdown complete');
      }
    } catch (error) {
      this.errors++;
      throw new BasicError(`Failed to shutdown AI System: ${error.message}`);
    }
  }

  /**
   * Request code completion
   */
  async requestCompletion(request) {
    if (!this.initialized) {
      throw new BasicError('AI System not initialized');
    }

    if (!request || !request.code || !request.language) {
      throw new BasicError('Invalid completion request: missing required fields');
    }

    this.totalRequests++;
    const startTime = performance.now();

    try {
      // Check cache first if enabled
      if (this.options.enableCaching && this.resultCache) {
        const cacheKey = this._generateCacheKey('completion', request);
        const cached = await this.resultCache.get(cacheKey);
        
        if (cached && cached.text) {
          return {
            ...cached,
            metadata: {
              ...cached.metadata,
              fromCache: true,
              timestamp: Date.now()
            }
          };
        }
      }

      // Generate completion using controller
      const result = await this.controller.generateCompletion(
        request.code,
        request.language,
        request.position || { line: 0, character: request.code.length }
      );

      const latency = performance.now() - startTime;

      const response = {
        text: result.completion || result.text || 'completion_placeholder',
        confidence: result.confidence || 0.8,
        metadata: {
          model: result.model || 'claude-3.7-sonnet-thinking',
          fromCache: false,
          timestamp: Date.now(),
          latency,
          requestId: this._generateRequestId()
        }
      };

      // Cache result if enabled
      if (this.options.enableCaching && this.resultCache) {
        const cacheKey = this._generateCacheKey('completion', request);
        await this.resultCache.set(cacheKey, response);
      }

      return response;
    } catch (error) {
      this.errors++;
      throw new ApiError(`Completion request failed: ${error.message}`);
    }
  }

  /**
   * Execute instruction/refactoring request
   */
  async executeInstruction(instruction) {
    if (!this.initialized) {
      throw new BasicError('AI System not initialized');
    }

    if (!instruction || (!instruction.text && !instruction.instruction)) {
      throw new BasicError('Invalid instruction request: missing required fields');
    }

    this.totalRequests++;
    const startTime = performance.now();

    try {
      // Check cache first if enabled
      if (this.options.enableCaching && this.resultCache) {
        const cacheKey = this._generateCacheKey('instruction', instruction);
        const cached = await this.resultCache.get(cacheKey);
        
        if (cached && cached.result) {
          return {
            ...cached,
            metadata: {
              ...cached.metadata,
              fromCache: true,
              timestamp: Date.now()
            }
          };
        }
      }

      // Execute instruction using controller
      const result = await this.controller.executeInstruction(
        instruction.text || instruction.instruction,
        instruction.language || 'javascript',
        instruction.selection
      );

      const latency = performance.now() - startTime;

      const response = {
        result: result.result || result.text || 'instruction_result',
        edits: result.edits || [],
        explanation: result.explanation || 'Instruction executed successfully',
        metadata: {
          model: result.model || 'claude-4-sonnet-thinking',
          fromCache: false,
          timestamp: Date.now(),
          latency,
          requestId: this._generateRequestId()
        }
      };

      // Cache result if enabled
      if (this.options.enableCaching && this.resultCache) {
        const cacheKey = this._generateCacheKey('instruction', instruction);
        await this.resultCache.set(cacheKey, response);
      }

      return response;
    } catch (error) {
      this.errors++;
      throw new ApiError(`Instruction execution failed: ${error.message}`);
    }
  }

  /**
   * Get comprehensive system statistics
   */
  getSystemStats() {
    const uptime = Date.now() - this.startTime;
    const errorRate = this.totalRequests > 0 ? (this.errors / this.totalRequests) * 100 : 0;

    let cacheStats = {
      hits: 0,
      misses: 0,
      hitRate: 0,
      size: 0,
      memoryUsageMB: 0,
      memoryUtilization: 0
    };

    if (this.resultCache) {
      cacheStats = this.resultCache.getStats();
    }

    let performanceStats = {
      averageLatency: 0,
      requestsPerSecond: 0,
      memoryUsage: process.memoryUsage()
    };

    if (this.performanceMonitor) {
      performanceStats = this.performanceMonitor.getStats();
    }

    return {
      system: {
        initialized: this.initialized,
        uptime,
        totalRequests: this.totalRequests,
        errors: this.errors,
        errorRate
      },
      resultCache: cacheStats,
      performanceMonitor: performanceStats
    };
  }

  /**
   * Get model performance data
   */
  getModelPerformance() {
    if (this.performanceMonitor) {
      return this.performanceMonitor.getModelPerformance();
    }

    // Return default data if performance monitoring is disabled
    return {
      'claude-3.7-sonnet-thinking': {
        model: 'claude-3.7-sonnet-thinking',
        usage: { requests: 0, averageLatency: 0 },
        targetLatency: 300
      },
      'claude-4-sonnet-thinking': {
        model: 'claude-4-sonnet-thinking',
        usage: { requests: 0, averageLatency: 0 },
        targetLatency: 500
      },
      'o3': {
        model: 'o3',
        usage: { requests: 0, averageLatency: 0 },
        targetLatency: 200
      }
    };
  }

  /**
   * Clear all caches
   */
  clearCaches() {
    if (this.resultCache) {
      this.resultCache.clear();
    }
    if (this.contextManager) {
      this.contextManager.clearCache();
    }
  }

  /**
   * Optimize system performance
   */
  async optimizePerformance() {
    const currentStats = this.getSystemStats();
    
    const recommendations = [];

    // Cache optimization
    if (currentStats.resultCache.hitRate < 50) {
      recommendations.push({
        type: 'cache',
        priority: 'medium',
        message: 'Consider increasing cache size for better hit rate'
      });
    }

    // Memory optimization
    if (currentStats.resultCache.memoryUtilization > 80) {
      recommendations.push({
        type: 'memory',
        priority: 'high',
        message: 'High memory utilization detected, consider cache cleanup'
      });
    }

    // Error rate optimization
    if (currentStats.system.errorRate > 5) {
      recommendations.push({
        type: 'reliability',
        priority: 'high',
        message: 'High error rate detected, review request validation'
      });
    }

    return {
      timestamp: Date.now(),
      recommendations,
      currentStats
    };
  }

  /**
   * Run performance benchmark
   */
  async benchmark(customScenarios = null) {
    const scenarios = customScenarios || [
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
        name: 'Python Function Completion',
        request: {
          code: 'def calculate():\n    return ',
          language: 'python',
          position: { line: 1, character: 11 }
        },
        type: 'completion'
      },
      {
        name: 'Basic Refactoring',
        request: {
          instruction: 'Add error handling',
          language: 'javascript',
          selection: { start: { line: 0, character: 0 }, end: { line: 5, character: 0 } }
        },
        type: 'instruction'
      }
    ];

    const results = [];
    let totalLatency = 0;
    let successful = 0;

    for (const scenario of scenarios) {
      const startTime = performance.now();
      let success = false;

      try {
        if (scenario.type === 'completion') {
          await this.requestCompletion(scenario.request);
        } else if (scenario.type === 'instruction') {
          await this.executeInstruction(scenario.request);
        }
        success = true;
        successful++;
      } catch (error) {
        console.warn(`Benchmark scenario "${scenario.name}" failed:`, error.message);
      }

      const latency = performance.now() - startTime;
      totalLatency += latency;

      results.push({
        scenario: scenario.name,
        success,
        latency,
        timestamp: Date.now()
      });
    }

    return {
      totalScenarios: scenarios.length,
      successful,
      failed: scenarios.length - successful,
      averageLatency: totalLatency / scenarios.length,
      results,
      timestamp: Date.now()
    };
  }

  /**
   * Generate cache key for request
   */
  _generateCacheKey(type, request) {
    // Create a normalized request object for consistent caching
    const normalizedRequest = {
      type,
      code: request.code || '',
      language: request.language || '',
      instruction: request.instruction || request.text || '',
      // Exclude volatile fields like timestamps and positions for better cache consistency
      maxTokens: request.maxTokens,
      temperature: request.temperature
    };
    
    const key = JSON.stringify(normalizedRequest);
    // Use full hash to avoid collisions instead of truncating
    return require('crypto').createHash('sha256').update(key).digest('hex');
  }

  /**
   * Generate unique request ID
   */
  _generateRequestId() {
    return `req_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }
}

module.exports = AISystem;
