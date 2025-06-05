/**
 * AI Controller - Main orchestrator for all AI operations
 * Handles request routing, context assembly, and result caching
 * Target: <0.5s completion latency, intelligent model selection
 */

const EventEmitter = require('events');
const { performance } = require('perf_hooks');

class AIController extends EventEmitter {
  constructor(options = {}) {
    super();

    this.config = {
      maxConcurrentRequests: 10, // Increased for testing
      defaultTimeout: 30000, // Increased timeout for tests
      enableCaching: true,
      enableTelemetry: true,
      fastModelThreshold: 200, // tokens
      ...options
    };

    this.activeRequests = new Map();
    this.requestQueue = [];
    this.modelSelector = null;
    this.contextManager = null;
    this.resultCache = null;
    this.performanceMonitor = null;

    this.stats = {
      totalRequests: 0,
      completedRequests: 0,
      cachedResponses: 0,
      averageLatency: 0,
      errorCount: 0
    };
  }

  /**
   * Initialize AI Controller with dependencies
   * @param {Object} dependencies - Required components
   */
  async initialize(dependencies) {
    const { modelSelector, contextManager, resultCache, performanceMonitor } = dependencies;

    this.modelSelector = modelSelector;
    this.contextManager = contextManager;
    this.resultCache = resultCache;
    this.performanceMonitor = performanceMonitor;

    if (this.performanceMonitor) {
      await this.performanceMonitor.initialize();
    }

    this.emit('initialized');
    console.log('✅ AI Controller initialized');
  }

  /**
   * Request code completion with intelligent routing
   * @param {Object} request - Completion request parameters
   * @returns {Promise<Object>} Completion result
   */
  async requestCompletion(request) {
    const startTime = performance.now();
    const requestId = this.generateRequestId();

    try {
      this.stats.totalRequests++;

      // Validate request
      this.validateCompletionRequest(request);

      // Check cache first
      if (this.config.enableCaching) {
        const cached = await this.checkCache(request);
        if (cached) {
          this.stats.cachedResponses++;
          this.recordLatency(startTime);
          return this.formatResponse(cached, { fromCache: true, requestId });
        }
      }

      // Queue request if at capacity
      if (this.activeRequests.size >= this.config.maxConcurrentRequests) {
        return this.queueRequest('completion', request, requestId);
      }

      // Process request
      return await this.processCompletion(request, requestId, startTime);

    } catch (error) {
      this.stats.errorCount++;
      this.emit('error', { requestId, error: error.message, request });
      throw new AIControllerError(`Completion failed: ${error.message}`, 'COMPLETION_ERROR');
    }
  }

  /**
   * Execute instruction-based code editing
   * @param {Object} instruction - Instruction request parameters
   * @returns {Promise<Object>} Edit result
   */
  async executeInstruction(instruction) {
    const startTime = performance.now();
    const requestId = this.generateRequestId();

    try {
      this.stats.totalRequests++;

      // Validate instruction
      this.validateInstructionRequest(instruction);

      // Instructions always use powerful models and shadow workspace
      const enhancedInstruction = {
        ...instruction,
        priority: 'high',
        useShadowWorkspace: true,
        enableErrorFeedback: true
      };

      // Queue if at capacity
      if (this.activeRequests.size >= this.config.maxConcurrentRequests) {
        return this.queueRequest('instruction', enhancedInstruction, requestId);
      }

      // Process instruction
      return await this.processInstruction(enhancedInstruction, requestId, startTime);

    } catch (error) {
      this.stats.errorCount++;
      this.emit('error', { requestId, error: error.message, instruction });
      throw new AIControllerError(`Instruction failed: ${error.message}`, 'INSTRUCTION_ERROR');
    }
  }

  /**
   * Process completion request with full pipeline
   * @private
   */
  async processCompletion(request, requestId, startTime) {
    this.activeRequests.set(requestId, { type: 'completion', startTime });

    try {
      // 1. Assemble context
      const context = await this.contextManager.assembleContext(
        request.position,
        request.language,
        { priority: request.priority || 'interactive' }
      );

      // 2. Select appropriate model
      const modelConfig = this.modelSelector.selectModel({
        ...request,
        context,
        tokenCount: context.totalTokens
      });

      // 3. Generate completion
      const completion = await this.generateCompletion({
        ...request,
        context,
        modelConfig
      });

      // 4. Cache result
      if (this.config.enableCaching && completion.confidence > 0.8) {
        await this.cacheResult(request, completion);
      }

      // 5. Record metrics
      this.recordLatency(startTime);
      this.stats.completedRequests++;

      return this.formatResponse(completion, {
        requestId,
        model: modelConfig.model,
        contextTokens: context.totalTokens,
        latency: performance.now() - startTime
      });

    } finally {
      this.activeRequests.delete(requestId);
      this.processQueue();
    }
  }

  /**
   * Process instruction with shadow workspace integration
   * @private
   */
  async processInstruction(instruction, requestId, startTime) {
    this.activeRequests.set(requestId, { type: 'instruction', startTime });

    try {
      // 1. Assemble enhanced context
      const context = await this.contextManager.assembleContext(
        instruction.position || instruction.selection,
        instruction.language,
        {
          priority: 'high',
          includeProjectContext: true,
          maxTokens: 8000
        }
      );

      // 2. Use powerful model for instructions
      const modelConfig = this.modelSelector.selectModel({
        ...instruction,
        context,
        forceModel: 'powerful',
        tokenCount: context.totalTokens
      });

      // 3. Generate initial edit
      let editResult = await this.generateEdit({
        ...instruction,
        context,
        modelConfig
      });

      // 4. Shadow workspace iteration (if enabled)
      if (instruction.useShadowWorkspace && this.shadowWorkspace) {
        editResult = await this.iterateWithShadowWorkspace(editResult, instruction);
      }

      // 5. Record metrics
      this.recordLatency(startTime);
      this.stats.completedRequests++;

      return this.formatResponse(editResult, {
        requestId,
        model: modelConfig.model,
        contextTokens: context.totalTokens,
        latency: performance.now() - startTime,
        shadowIterations: editResult.iterations || 0
      });

    } finally {
      this.activeRequests.delete(requestId);
      this.processQueue();
    }
  }

  /**
   * Generate AI completion using selected model
   * @private
   */
  async generateCompletion(params) {
    const { context, modelConfig, code, position, language } = params;

    // Mock implementation - replace with actual AI model integration
    return new Promise((resolve) => {
      const latency = this.simulateModelLatency(modelConfig);

      setTimeout(() => {
        resolve({
          text: this.generateMockCompletion(code, language),
          confidence: 0.85 + (Math.random() * 0.15),
          model: modelConfig.model,
          contextUsed: context.totalTokens,
          position: position, // Include position for context tracking
          reasoning: `Completed ${language} code using ${modelConfig.model}`
        });
      }, latency);
    });
  }

  /**
   * Generate AI edit using selected model
   * @private
   */
  async generateEdit(params) {
    const { context, modelConfig, instruction, language } = params;

    // Mock implementation - replace with actual AI model integration
    return new Promise((resolve) => {
      const latency = this.simulateModelLatency(modelConfig);

      setTimeout(() => {
        resolve({
          edits: this.generateMockEdit(instruction, language),
          explanation: `Applied ${instruction?.type || 'edit'} using ${modelConfig.model}`,
          confidence: 0.90 + (Math.random() * 0.10),
          model: modelConfig.model,
          contextUsed: context.totalTokens
        });
      }, latency);
    });
  }

  /**
   * Simulate model latency based on configuration
   * @private
   */
  simulateModelLatency(modelConfig) {
    // Reduced latencies for testing
    const baseLatencies = {
      'o3-mini': 50,
      'claude-3.5-haiku': 75,
      'claude-3.5': 100,
      'gpt-4': 150
    };

    const base = baseLatencies[modelConfig.model] || 100;
    const variation = 0.8 + (Math.random() * 0.4); // ±20% variation

    return Math.round(base * variation);
  }

  /**
   * Generate mock completion for testing
   * @private
   */
  generateMockCompletion(code, language) {
    const completions = {
      javascript: {
        'const x = ': '"hello world"',
        'function ': 'calculateSum(a, b) { return a + b; }',
        'const [': 'state, setState] = useState(0);'
      },
      python: {
        'def ': 'process_data(self, data): return data',
        '[x for x in ': 'range(10) if x % 2 == 0]'
      },
      shell: {
        'for ': 'file in *.txt; do echo "Processing $file"; done'
      }
    };

    const langCompletions = completions[language] || completions.javascript;
    const match = Object.keys(langCompletions).find(key => code.includes(key));

    return match ? langCompletions[match] : 'completion';
  }

  /**
   * Generate mock edit for testing
   * @private
   */
  generateMockEdit(instruction, language) {
    // Handle undefined instruction parameter defensively
    const instructionText = instruction?.text || 'AI generated edit';

    // Use language for file extension and comment syntax
    const fileExtensions = { javascript: 'js', python: 'py', shell: 'sh' };
    const commentSyntax = { javascript: '//', python: '#', shell: '#' };

    const ext = fileExtensions[language] || 'js';
    const comment = commentSyntax[language] || '//';

    return [{
      uri: `file:///test.${ext}`,
      edits: [{
        range: { start: { line: 0, character: 0 }, end: { line: 0, character: 10 } },
        newText: `${comment} ${instructionText}`
      }]
    }];
  }

  /**
   * Check cache for existing result
   * @private
   */
  async checkCache(request) {
    if (!this.resultCache) return null;

    const cacheKey = this.generateCacheKey(request);
    return await this.resultCache.get(cacheKey);
  }

  /**
   * Cache result for future use
   * @private
   */
  async cacheResult(request, result) {
    if (!this.resultCache) return;

    const cacheKey = this.generateCacheKey(request);
    await this.resultCache.set(cacheKey, result, { ttl: 300000 }); // 5 minutes
  }

  /**
   * Generate cache key from request
   * @private
   */
  generateCacheKey(request) {
    const key = `${request.language}:${request.code?.slice(-50) || ''}:${request.position?.line || 0}`;
    return Buffer.from(key).toString('base64').slice(0, 32);
  }

  /**
   * Queue request when at capacity
   * @private
   */
  async queueRequest(type, request, requestId) {
    return new Promise((resolve, reject) => {
      this.requestQueue.push({
        type,
        request,
        requestId,
        resolve,
        reject,
        timestamp: Date.now()
      });

      // Timeout queued requests
      setTimeout(() => {
        const index = this.requestQueue.findIndex(q => q.requestId === requestId);
        if (index !== -1) {
          this.requestQueue.splice(index, 1);
          reject(new AIControllerError('Request timeout in queue', 'QUEUE_TIMEOUT'));
        }
      }, this.config.defaultTimeout);
    });
  }

  /**
   * Process next queued request
   * @private
   */
  async processQueue() {
    while (this.requestQueue.length > 0 && this.activeRequests.size < this.config.maxConcurrentRequests) {
      const queued = this.requestQueue.shift();
      if (!queued) break;

      // Process request immediately without setImmediate to avoid timing issues
      try {
        let result;
        if (queued.type === 'completion') {
          result = await this.processCompletion(queued.request, queued.requestId, performance.now());
        } else if (queued.type === 'instruction') {
          result = await this.processInstruction(queued.request, queued.requestId, performance.now());
        }
        queued.resolve(result);
      } catch (error) {
        queued.reject(error);
      }
    }
  }

  /**
   * Validate completion request
   * @private
   */
  validateCompletionRequest(request) {
    if (!request.code && !request.position) {
      throw new Error('Request must include code or position');
    }
    if (!request.language) {
      throw new Error('Request must specify language');
    }
  }

  /**
   * Validate instruction request
   * @private
   */
  validateInstructionRequest(instruction) {
    if (!instruction.text && !instruction.type) {
      throw new Error('Instruction must include text or type');
    }
  }

  /**
   * Record latency metrics
   * @private
   */
  recordLatency(startTime) {
    const latency = performance.now() - startTime;
    this.stats.averageLatency = this.stats.completedRequests === 0 ? latency :
      (this.stats.averageLatency * (this.stats.completedRequests - 1) + latency) / this.stats.completedRequests;

    if (this.performanceMonitor) {
      this.performanceMonitor.recordLatency(latency);
    }
  }

  /**
   * Generate unique request ID
   * @private
   */
  generateRequestId() {
    return `req_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }

  /**
   * Format response with metadata
   * @private
   */
  formatResponse(result, metadata) {
    return {
      ...result,
      metadata: {
        timestamp: new Date().toISOString(),
        ...metadata
      }
    };
  }

  /**
   * Get current performance statistics
   */
  getStats() {
    return {
      ...this.stats,
      activeRequests: this.activeRequests.size,
      queuedRequests: this.requestQueue.length,
      cacheHitRate: this.stats.totalRequests > 0 ?
        (this.stats.cachedResponses / this.stats.totalRequests) * 100 : 0
    };
  }

  /**
   * Cleanup and shutdown
   */
  async shutdown() {
    // Cancel active requests
    for (const [requestId] of this.activeRequests) {
      this.emit('requestCancelled', requestId);
    }
    this.activeRequests.clear();
    this.requestQueue.length = 0;

    this.emit('shutdown');
  }
}

/**
 * Custom error class for AI Controller
 */
class AIControllerError extends Error {
  constructor(message, code) {
    super(message);
    this.name = 'AIControllerError';
    this.code = code;
  }
}

module.exports = { AIController, AIControllerError };
