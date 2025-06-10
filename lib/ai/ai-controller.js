/**
 * @fileoverview
 * AI Controller - Production Implementation
 * Orchestrates AI requests across multiple providers with intelligent routing,
 * fallback mechanisms, and comprehensive error handling.
 */

const ClaudeClient = require('./clients/claude-client');
const GPTClient = require('./clients/gpt-client');
const GeminiClient = require('./clients/gemini-client');
const BasicModelSelector = require('./model-selector');
const ContextManager = require('./context-manager');

class AIController {
  constructor(config = {}) {
    this.config = {
      enableFallback: true,
      maxConcurrentRequests: 5,
      requestTimeout: 30000,
      retryAttempts: 2,
      quietMode: false,
      ...config
    };

    // Initialize API clients
    this.clients = {
      claude: new ClaudeClient(config.claude || {}),
      gpt: new GPTClient(config.gpt || {}),
      gemini: new GeminiClient(config.gemini || {})
    };

    this.modelSelector = new BasicModelSelector(this.config, null);
    this.contextManager = new ContextManager();
    
    // Request tracking
    this.activeRequests = new Map();
    this.requestCounter = 0;
    this.metrics = {
      totalRequests: 0,
      successfulRequests: 0,
      failedRequests: 0,
      providerUsage: {},
      averageLatency: 0,
      lastError: null
    };

    this.isInitialized = false;
    
    // Initialize provider usage tracking
    Object.keys(this.clients).forEach(provider => {
      this.metrics.providerUsage[provider] = {
        requests: 0,
        successes: 0,
        failures: 0,
        totalLatency: 0
      };
    });
  }

  /**
   * Initialize the AI Controller and test client connections
   * @returns {Promise<Object>} Initialization result
   */
  async initialize() {
    try {
      if (!this.config.quietMode) {
        console.log('AI Controller initializing...');
      }

      // Test client configurations (but don't fail if no API keys)
      const clientStatuses = {};
      for (const [name, client] of Object.entries(this.clients)) {
        const status = client.getStatus();
        clientStatuses[name] = status;
        
        if (!this.config.quietMode && status.configured) {
          console.log(`✓ ${name} client configured`);
        }
      }

      // Initialize context manager
      await this.contextManager.initialize();

      this.isInitialized = true;
      
      if (!this.config.quietMode) {
        console.log('AI Controller initialized successfully');
      }

      return { 
        success: true, 
        clients: clientStatuses,
        timestamp: new Date().toISOString()
      };
    } catch (error) {
      console.error('Failed to initialize AI Controller:', error.message);
      return { 
        success: false, 
        error: error.message,
        timestamp: new Date().toISOString()
      };
    }
  }

  /**
   * Execute an AI request with intelligent routing and fallback
   * @param {Object} request - The AI request
   * @returns {Promise<Object>} Execution result
   */
  async execute(request) {
    if (!this.isInitialized) {
      return { 
        success: false, 
        error: 'Controller not initialized. Please call initialize() first.',
        timestamp: new Date().toISOString()
      };
    }

    // Validate request
    const validation = this.validateRequest(request);
    if (!validation.valid) {
      return {
        success: false,
        error: validation.error,
        timestamp: new Date().toISOString()
      };
    }

    // Check concurrent request limits
    if (this.activeRequests.size >= this.config.maxConcurrentRequests) {
      return {
        success: false,
        error: 'Maximum concurrent requests reached. Please try again later.',
        timestamp: new Date().toISOString()
      };
    }

    const requestId = this.generateRequestId();
    const startTime = Date.now();

    try {
      // Track active request
      this.activeRequests.set(requestId, {
        startTime,
        request: { ...request, id: requestId }
      });

      // Select model and provider
      const modelSelection = this.modelSelector.selectModel(request);
      const provider = this.getProviderForModel(modelSelection.model);

      if (!this.config.quietMode) {
        console.log(`Executing request ${requestId} with ${provider}:${modelSelection.model}`);
      }

      // Prepare context if needed
      let context = null;
      if (request.code && request.language) {
        context = await this.contextManager.prepareContext(request);
      }

      // Execute request with selected provider
      let result = await this.executeWithProvider(provider, request, modelSelection, context);

      // If primary provider fails and fallback is enabled, try alternatives
      if (!result.success && this.config.enableFallback) {
        const fallbackProviders = this.getFallbackProviders(provider);
        
        for (const fallbackProvider of fallbackProviders) {
          if (!this.config.quietMode) {
            console.log(`Trying fallback provider: ${fallbackProvider}`);
          }
          
          const fallbackModelSelection = this.modelSelector.selectModel({
            ...request,
            provider: fallbackProvider
          });
          
          result = await this.executeWithProvider(fallbackProvider, request, fallbackModelSelection, context);
          
          if (result.success) {
            result.metadata = {
              ...result.metadata,
              usedFallback: true,
              originalProvider: provider,
              fallbackProvider: fallbackProvider
            };
            break;
          }
        }
      }

      // Track metrics
      const latency = Date.now() - startTime;
      this.updateMetrics(provider, result.success, latency);

      // Add execution metadata
      result.metadata = {
        ...result.metadata,
        requestId,
        latency,
        provider,
        model: modelSelection.model,
        timestamp: new Date().toISOString()
      };

      return result;

    } catch (error) {
      const latency = Date.now() - startTime;
      this.metrics.lastError = error.message;
      
      console.error(`Request ${requestId} failed:`, error.message);
      
      return {
        success: false,
        error: `Execution failed: ${error.message}`,
        metadata: {
          requestId,
          latency,
          timestamp: new Date().toISOString()
        }
      };
    } finally {
      // Clean up active request tracking
      this.activeRequests.delete(requestId);
    }
  }

  /**
   * Execute request with specific provider
   * @param {string} provider - Provider name
   * @param {Object} request - Request object
   * @param {Object} modelSelection - Model selection info
   * @param {Object} context - Prepared context
   * @returns {Promise<Object>} Execution result
   */
  async executeWithProvider(provider, request, modelSelection, context) {
    const client = this.clients[provider];
    if (!client) {
      return {
        success: false,
        error: `Unknown provider: ${provider}`
      };
    }

    if (!client.isConfigured()) {
      return {
        success: false,
        error: `Provider ${provider} not configured. Please set the appropriate API key.`
      };
    }

    try {
      // Build prompt with context
      const prompt = this.buildPrompt(request, context);
      
      // Prepare options
      const options = {
        model: modelSelection.model,
        maxTokens: request.maxTokens || 1000,
        temperature: request.temperature || 0.7,
        ...request.options
      };

      // Execute completion request
      const result = await client.complete(prompt, options);

      if (result.success) {
        // Post-process result if needed
        return {
          success: true,
          text: result.text,
          usage: result.usage,
          metadata: {
            model: result.model,
            provider: provider,
            ...result.metadata
          }
        };
      } else {
        return {
          success: false,
          error: result.error,
          metadata: {
            model: result.model,
            provider: provider
          }
        };
      }

    } catch (error) {
      return {
        success: false,
        error: `Provider ${provider} execution failed: ${error.message}`,
        metadata: {
          provider: provider
        }
      };
    }
  }

  /**
   * Build prompt from request and context
   * @param {Object} request - Request object
   * @param {Object} context - Context object
   * @returns {string} Built prompt
   */
  buildPrompt(request, context) {
    if (request.prompt) {
      return request.prompt;
    }

    // For completion requests
    if (request.code && request.type === 'completion') {
      let prompt = `Complete this ${request.language} code:\n\n${request.code}`;
      
      if (context && context.symbols && context.symbols.length > 0) {
        const relevantSymbols = context.symbols.slice(0, 5);
        prompt += `\n\nRelevant context:\n`;
        relevantSymbols.forEach(symbol => {
          prompt += `- ${symbol.kind} ${symbol.name}: ${symbol.detail}\n`;
        });
      }
      
      return prompt;
    }

    // For instruction requests
    if (request.instruction) {
      let prompt = request.instruction;
      
      if (request.code) {
        prompt += `\n\nCode:\n${request.code}`;
      }
      
      if (context && context.framework) {
        prompt += `\n\nFramework: ${context.framework.name}`;
      }
      
      return prompt;
    }

    // For chat/text requests
    if (request.text) {
      return request.text;
    }

    return 'Please provide a helpful response.';
  }

  /**
   * Validate request object
   * @param {Object} request - Request to validate
   * @returns {Object} Validation result
   */
  validateRequest(request) {
    if (!request || typeof request !== 'object') {
      return { valid: false, error: 'Request must be an object' };
    }

    // Check for required fields based on request type
    if (request.type === 'completion') {
      if (!request.code || !request.language) {
        return { valid: false, error: 'Completion requests require code and language fields' };
      }
    } else if (request.type === 'instruction') {
      if (!request.instruction) {
        return { valid: false, error: 'Instruction requests require instruction field' };
      }
    } else if (!request.prompt && !request.text && !request.instruction) {
      return { valid: false, error: 'Request must have prompt, text, or instruction field' };
    }

    return { valid: true };
  }

  /**
   * Get provider for a given model
   * @param {string} model - Model name
   * @returns {string} Provider name
   */
  getProviderForModel(model) {
    if (model.includes('claude')) return 'claude';
    if (model.includes('gpt')) return 'gpt';
    if (model.includes('gemini')) return 'gemini';
    
    // Default fallback
    return 'claude';
  }

  /**
   * Get fallback providers for a given provider
   * @param {string} provider - Primary provider
   * @returns {Array<string>} Fallback providers
   */
  getFallbackProviders(provider) {
    const fallbackMap = {
      claude: ['gpt', 'gemini'],
      gpt: ['claude', 'gemini'],
      gemini: ['claude', 'gpt']
    };

    return fallbackMap[provider] || [];
  }

  /**
   * Update metrics for a request
   * @param {string} provider - Provider used
   * @param {boolean} success - Whether request succeeded
   * @param {number} latency - Request latency in ms
   */
  updateMetrics(provider, success, latency) {
    this.metrics.totalRequests++;
    
    if (success) {
      this.metrics.successfulRequests++;
    } else {
      this.metrics.failedRequests++;
    }

    // Update provider-specific metrics
    const providerMetrics = this.metrics.providerUsage[provider];
    if (providerMetrics) {
      providerMetrics.requests++;
      providerMetrics.totalLatency += latency;
      
      if (success) {
        providerMetrics.successes++;
      } else {
        providerMetrics.failures++;
      }
    }

    // Update average latency
    const totalLatency = Object.values(this.metrics.providerUsage)
      .reduce((sum, p) => sum + p.totalLatency, 0);
    this.metrics.averageLatency = this.metrics.totalRequests > 0 ? 
      totalLatency / this.metrics.totalRequests : 0;
  }

  /**
   * Generate unique request ID
   * @returns {string} Request ID
   */
  generateRequestId() {
    return `req_${Date.now()}_${++this.requestCounter}`;
  }

  /**
   * Test connections to all configured providers
   * @returns {Promise<Object>} Connection test results
   */
  async testConnections() {
    const results = {};
    
    for (const [name, client] of Object.entries(this.clients)) {
      if (client.isConfigured()) {
        try {
          results[name] = await client.testConnection();
        } catch (error) {
          results[name] = {
            success: false,
            error: error.message
          };
        }
      } else {
        results[name] = {
          success: false,
          error: 'Not configured'
        };
      }
    }
    
    return results;
  }

  /**
   * Get controller status and metrics
   * @returns {Object} Status object
   */
  getStatus() {
    const clientStatuses = {};
    for (const [name, client] of Object.entries(this.clients)) {
      clientStatuses[name] = client.getStatus();
    }

    return {
      initialized: this.isInitialized,
      activeRequests: this.activeRequests.size,
      metrics: { ...this.metrics },
      clients: clientStatuses,
      config: {
        enableFallback: this.config.enableFallback,
        maxConcurrentRequests: this.config.maxConcurrentRequests,
        requestTimeout: this.config.requestTimeout
      },
      timestamp: new Date().toISOString()
    };
  }

  /**
   * Shutdown the controller and clean up resources
   * @returns {Promise<Object>} Shutdown result
   */
  async shutdown() {
    if (!this.config.quietMode) {
      console.log('Shutting down AI Controller...');
    }

    // Wait for active requests to complete (with timeout)
    const shutdownTimeout = 10000; // 10 seconds
    const startTime = Date.now();
    
    while (this.activeRequests.size > 0 && (Date.now() - startTime) < shutdownTimeout) {
      await new Promise(resolve => setTimeout(resolve, 100));
    }

    if (this.activeRequests.size > 0) {
      console.warn(`Forced shutdown with ${this.activeRequests.size} active requests`);
      this.activeRequests.clear();
    }

    this.isInitialized = false;
    
    if (!this.config.quietMode) {
      console.log('AI Controller shutdown complete');
    }

    return { 
      success: true,
      timestamp: new Date().toISOString()
    };
  }

  /**
   * Clear metrics and reset counters
   */
  clearMetrics() {
    this.metrics = {
      totalRequests: 0,
      successfulRequests: 0,
      failedRequests: 0,
      providerUsage: {},
      averageLatency: 0,
      lastError: null
    };

    // Reinitialize provider usage tracking
    Object.keys(this.clients).forEach(provider => {
      this.metrics.providerUsage[provider] = {
        requests: 0,
        successes: 0,
        failures: 0,
        totalLatency: 0
      };
    });
  }
}

module.exports = AIController;
