/**
 * @fileoverview
 * Revolutionary AI Controller - Central orchestrator for the Enhanced Cursor AI system.
 *
 * This controller manages all AI operations through advanced 6-model orchestration,
 * unlimited context processing, and revolutionary caching to achieve unprecedented
 * performance and accuracy.
 */

const SixModelOrchestrator = require('./6-model-orchestrator.js');
const UnlimitedContextManager = require('./unlimited-context-manager.js');
const RevolutionaryCache = require('../cache/revolutionary-cache.js');
const { RevolutionaryError, RevolutionaryApiError, RevolutionaryTimeoutError } = require('../system/errors.js');

class RevolutionaryController {
  /**
   * Initializes the Revolutionary AI Controller with 6-model orchestration.
   * @param {object} config - Configuration object with model settings
   */
  constructor(config = {}) {
    this.config = {
      models: {
        ultraFast: config.models?.ultraFast || 'o3',
        thinking: config.models?.thinking || ['claude-4-sonnet-thinking', 'claude-4-opus-thinking'],
        multimodal: config.models?.multimodal || 'gemini-2.5-pro',
        enhanced: config.models?.enhanced || 'gpt-4.1',
        rapid: config.models?.rapid || 'claude-3.7-sonnet-thinking'
      },
      unlimited: {
        contextProcessing: config.unlimited?.contextProcessing !== false,
        fileSize: config.unlimited?.fileSize || 'unlimited',
        projectSize: config.unlimited?.projectSize || 'unlimited',
        intelligence: config.unlimited?.intelligence || 'maximum'
      },
      revolutionary: {
        thinkingModes: config.revolutionary?.thinkingModes !== false,
        sixModelOrchestration: config.revolutionary?.sixModelOrchestration !== false,
        unlimitedCaching: config.revolutionary?.unlimitedCaching !== false,
        perfectAccuracy: config.revolutionary?.perfectAccuracy !== false
      }
    };

    // Initialize core components
    this.cache = new RevolutionaryCache({
      unlimited: this.config.revolutionary.unlimitedCaching,
      maxItems: this.config.unlimited.contextProcessing ? 50000 : 1000,
      compressionLevel: 6,
      enablePredict: true,
      parallelAccess: true
    });

    this.contextManager = new UnlimitedContextManager(this.config, this.cache);
    this.orchestrator = new SixModelOrchestrator(this.config, this.cache);

    // Performance metrics
    this.metrics = {
      completions: 0,
      cacheHits: 0,
      averageLatency: 0,
      errorCount: 0
    };

    console.log('Revolutionary AI Controller Initialized: 6-Model orchestration ready.');
  }

  /**
   * Requests a code completion with unlimited context processing.
   * @param {object} options - Completion options
   * @param {string} options.code - Code context
   * @param {string} options.language - Programming language
   * @param {string} options.context - Additional context
   * @param {string[]} [options.models] - Specific models to use
   * @param {boolean} [options.thinkingMode] - Enable thinking modes
   * @param {boolean} [options.unlimitedProcessing] - Enable unlimited processing
   * @returns {Promise<object>} Completion result
   */
  async requestCompletion(options) {
    const startTime = Date.now();
    const cacheKey = this._generateCacheKey('completion', options);

    try {
      // Check cache first for instant responses
      if (this.config.revolutionary.unlimitedCaching) {
        const cached = await this.cache.get(cacheKey);
        if (cached) {
          this.metrics.cacheHits++;
          console.log('[Controller] Cache hit - instant completion returned');
          return { ...cached, cached: true, latency: Date.now() - startTime };
        }
      }

      // Assemble unlimited context
      const assembledContext = await this.contextManager.assembleContext({
        code: options.code,
        language: options.language,
        additionalContext: options.context,
        unlimited: options.unlimitedProcessing
      });

      // Get completion from orchestrator
      const result = await this.orchestrator.getCompletion({
        context: assembledContext,
        models: options.models,
        thinkingMode: options.thinkingMode
      });

      const latency = Date.now() - startTime;
      this.metrics.completions++;
      this.metrics.averageLatency = 
        (this.metrics.averageLatency * (this.metrics.completions - 1) + latency) / this.metrics.completions;

      // Cache successful results
      if (this.config.revolutionary.unlimitedCaching && result.completion) {
        await this.cache.set(cacheKey, result, { ttl: 3600 }); // 1 hour TTL
      }

      console.log(`[Controller] Completion generated in ${latency}ms using ${result.model}`);
      return { ...result, latency, cached: false };

    } catch (error) {
      this.metrics.errorCount++;
      console.error('[Controller] Completion failed:', error.message);
      throw new RevolutionaryApiError(`Completion failed: ${error.message}`, { 
        originalError: error,
        latency: Date.now() - startTime 
      });
    }
  }

  /**
   * Executes an instruction with advanced validation and thinking modes.
   * @param {object} options - Execution options
   * @param {string} options.instruction - The instruction to execute
   * @param {string[]} [options.models] - Models to use
   * @param {boolean} [options.validation] - Enable cross-model validation
   * @param {boolean} [options.unlimitedContext] - Enable unlimited context
   * @param {boolean} [options.multimodalAnalysis] - Enable multimodal analysis
   * @returns {Promise<object>} Execution result
   */
  async executeInstruction(options) {
    const startTime = Date.now();
    const cacheKey = this._generateCacheKey('instruction', options);

    try {
      // Check cache for complex instructions
      if (this.config.revolutionary.unlimitedCaching) {
        const cached = await this.cache.get(cacheKey);
        if (cached) {
          this.metrics.cacheHits++;
          console.log('[Controller] Cache hit - instant instruction result returned');
          return { ...cached, cached: true, latency: Date.now() - startTime };
        }
      }

      // Assemble unlimited context for instruction
      const assembledContext = await this.contextManager.assembleContext({
        instruction: options.instruction,
        unlimited: options.unlimitedContext,
        multimodal: options.multimodalAnalysis
      });

      // Execute through orchestrator with thinking modes
      const result = await this.orchestrator.execute({
        context: assembledContext,
        models: options.models,
        useThinking: this.config.revolutionary.thinkingModes,
        validate: options.validation
      });

      const latency = Date.now() - startTime;

      // Cache successful instruction results
      if (this.config.revolutionary.unlimitedCaching && result.result) {
        await this.cache.set(cacheKey, result, { ttl: 1800 }); // 30 minute TTL
      }

      console.log(`[Controller] Instruction executed in ${latency}ms using ${result.model}`);
      return { ...result, latency, cached: false };

    } catch (error) {
      this.metrics.errorCount++;
      console.error('[Controller] Instruction execution failed:', error.message);
      throw new RevolutionaryApiError(`Instruction execution failed: ${error.message}`, {
        originalError: error,
        latency: Date.now() - startTime
      });
    }
  }

  /**
   * Gets performance metrics for monitoring.
   * @returns {object} Current performance metrics
   */
  getMetrics() {
    return {
      ...this.metrics,
      cacheHitRate: this.metrics.completions > 0 ? 
        (this.metrics.cacheHits / this.metrics.completions * 100).toFixed(2) + '%' : '0%',
      uptime: process.uptime(),
      memoryUsage: process.memoryUsage()
    };
  }

  /**
   * Initializes the cache from persistent storage.
   * @returns {Promise<void>}
   */
  async initialize() {
    try {
      await this.cache.load();
      console.log('[Controller] Revolutionary cache loaded successfully');
    } catch (error) {
      console.warn('[Controller] Cache initialization failed:', error.message);
    }
  }

  /**
   * Generates a cache key for the given operation and options.
   * @private
   * @param {string} operation - The operation type
   * @param {object} options - The operation options
   * @returns {string} Cache key
   */
  _generateCacheKey(operation, options) {
    const hash = require('crypto')
      .createHash('sha256')
      .update(JSON.stringify({ operation, ...options }))
      .digest('hex')
      .substring(0, 16);
    return `${operation}_${hash}`;
  }
}

module.exports = RevolutionaryController;
