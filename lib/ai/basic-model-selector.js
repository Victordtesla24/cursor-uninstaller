/**
 * @fileoverview
 * Basic Model Selector - Simple model selection logic
 *
 * NOTE: This is a basic placeholder. Actual model usage requires API keys
 * and proper implementation. There is no "6-model orchestration".
 */

const ModelSelector = require('./model-selector');

class BasicModelSelector {
  constructor(config, cache) {
    this.config = config || {};
    this.cache = cache;
    this.modelSelector = new ModelSelector();
    
    // Basic metrics - no false claims
    this.metrics = {
      totalRequests: 0,
      errors: 0
    };

    // Real models only - no fake models
    this.availableModels = {
      'claude-3-opus': { provider: 'anthropic', capabilities: ['general'] },
      'claude-3-sonnet': { provider: 'anthropic', capabilities: ['general'] },
      'claude-3-haiku': { provider: 'anthropic', capabilities: ['general'] },
      'gpt-4': { provider: 'openai', capabilities: ['general'] },
      'gpt-3.5-turbo': { provider: 'openai', capabilities: ['general'] },
      'gemini-1.5-pro': { provider: 'google', capabilities: ['general'] },
      'gemini-1.5-flash': { provider: 'google', capabilities: ['general'] }
    };
  }

  /**
   * Selects a model based on the request
   * NOTE: This is basic logic - actual execution requires API keys
   */
  selectModel(request) {
    // Simple selection - no fake "6-model orchestration"
    let selectedModel = 'claude-3-sonnet'; // Default
    
    if (request && request.requiresFastResponse) {
      selectedModel = 'gpt-3.5-turbo';
    }

    return {
      model: selectedModel,
      provider: this.availableModels[selectedModel]?.provider || 'unknown'
    };
  }

  async execute(request) {
    this.metrics.totalRequests++;
    
    // This is a placeholder - actual execution requires API integration
    console.warn('Model execution not implemented - API keys and proper integration required');
    
    return {
      success: false,
      error: 'Model execution not implemented. Please configure API keys and implement proper API integration.',
      selectedModel: this.selectModel(request)
    };
  }

  getMetrics() {
    return this.metrics;
  }

  getAvailableModels() {
    return Object.keys(this.availableModels);
  }
}

module.exports = BasicModelSelector;
