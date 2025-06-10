/**
 * @fileoverview
 * Production Model Selector - Intelligent model selection with performance optimization
 * 
 * Implements sophisticated model selection based on request characteristics,
 * performance metrics, and availability with real-time optimization.
 */

export default class ModelSelector {
  constructor(config = {}, cache = null) {
    this.config = {
      enableLoadBalancing: true,
      enableMetrics: true,
      defaultTimeout: 30000,
      maxRetries: 2,
      preferenceWeighting: {
        latency: 0.4,
        accuracy: 0.3,
        cost: 0.2,
        availability: 0.1
      },
      ...config
    };
    
    this.cache = cache;
    this.performanceHistory = new Map();
    
    // Comprehensive metrics tracking
    this.metrics = {
      totalRequests: 0,
      successfulRequests: 0,
      errors: 0,
      averageLatency: 0,
      totalLatency: 0,
      modelUsage: new Map(),
      lastReset: Date.now()
    };

    // Production model configurations with capabilities and performance characteristics
    this.availableModels = {
      'claude-3-5-sonnet-20241022': { 
        provider: 'anthropic',
        capabilities: ['completion', 'analysis', 'reasoning'],
        targetLatency: 800,
        maxTokens: 200000,
        costPerToken: 0.000003,
        accuracy: 0.95,
        priority: 1
      },
      'claude-3-opus-20240229': { 
        provider: 'anthropic',
        capabilities: ['completion', 'analysis', 'reasoning', 'complex-tasks'],
        targetLatency: 1200,
        maxTokens: 200000,
        costPerToken: 0.000015,
        accuracy: 0.98,
        priority: 2
      },
      'claude-3-haiku-20240307': { 
        provider: 'anthropic',
        capabilities: ['completion', 'fast-response'],
        targetLatency: 400,
        maxTokens: 200000,
        costPerToken: 0.00000025,
        accuracy: 0.88,
        priority: 3
      },
      'gpt-4o': { 
        provider: 'openai',
        capabilities: ['completion', 'analysis', 'vision'],
        targetLatency: 600,
        maxTokens: 128000,
        costPerToken: 0.000005,
        accuracy: 0.93,
        priority: 4
      },
      'gpt-4-turbo': { 
        provider: 'openai',
        capabilities: ['completion', 'analysis'],
        targetLatency: 900,
        maxTokens: 128000,
        costPerToken: 0.00001,
        accuracy: 0.94,
        priority: 5
      },
      'gpt-3.5-turbo': { 
        provider: 'openai',
        capabilities: ['completion', 'fast-response'],
        targetLatency: 300,
        maxTokens: 16000,
        costPerToken: 0.0000005,
        accuracy: 0.85,
        priority: 6
      },
      'gemini-1.5-pro': { 
        provider: 'google',
        capabilities: ['completion', 'analysis', 'vision'],
        targetLatency: 700,
        maxTokens: 2000000,
        costPerToken: 0.00000125,
        accuracy: 0.91,
        priority: 7
      },
      'gemini-1.5-flash': { 
        provider: 'google',
        capabilities: ['completion', 'fast-response'],
        targetLatency: 250,
        maxTokens: 1000000,
        costPerToken: 0.000000075,
        accuracy: 0.87,
        priority: 8
      }
    };

    // Initialize performance tracking for each model
    this.initializeModelTracking();
  }

  /**
   * Initialize performance tracking for all available models
   */
  initializeModelTracking() {
    for (const modelName of Object.keys(this.availableModels)) {
      this.performanceHistory.set(modelName, {
        requests: 0,
        successes: 0,
        failures: 0,
        totalLatency: 0,
        averageLatency: 0,
        lastUsed: null,
        availability: 1.0,
        efficiency: 0.5 // Starting neutral efficiency
      });
      
      this.metrics.modelUsage.set(modelName, {
        count: 0,
        lastUsed: null,
        averagePerformance: 0.5
      });
    }
  }

  /**
   * Intelligent model selection based on request characteristics and performance
   */
  selectModel(request = {}) {
    try {
      this.metrics.totalRequests++;
      
      const candidates = this.filterModelsByCapabilities(request);
      const scoredModels = this.scoreModels(candidates, request);
      const selectedModel = this.selectOptimalModel(scoredModels, request);
      
      // Update usage tracking
      const usage = this.metrics.modelUsage.get(selectedModel.model);
      if (usage) {
        usage.count++;
        usage.lastUsed = Date.now();
      }
      
      return {
        model: selectedModel.model,
        provider: selectedModel.provider,
        confidence: selectedModel.score,
        reasoning: selectedModel.reasoning,
        estimatedLatency: selectedModel.estimatedLatency,
        timestamp: Date.now()
      };
    } catch (_error) {
      this.metrics.errors++;
      return this.getFallbackModel(request);
    }
  }

  /**
   * Filter models based on required capabilities
   */
  filterModelsByCapabilities(request) {
    const requiredCapabilities = this.extractRequiredCapabilities(request);
    const candidates = [];
    
    for (const [modelName, modelConfig] of Object.entries(this.availableModels)) {
      const performance = this.performanceHistory.get(modelName);
      
      // Check if model supports required capabilities
      const supportsCapabilities = requiredCapabilities.every(cap => 
        modelConfig.capabilities.includes(cap)
      );
      
      // Check availability and token limits
      const meetsRequirements = this.checkModelRequirements(modelConfig, request);
      
      if (supportsCapabilities && meetsRequirements && performance.availability > 0.1) {
        candidates.push({
          name: modelName,
          config: modelConfig,
          performance: performance
        });
      }
    }
    
    return candidates.length > 0 ? candidates : this.getBasicFallbacks();
  }

  /**
   * Extract required capabilities from request
   */
  extractRequiredCapabilities(request) {
    const capabilities = ['completion']; // Base capability
    
    if (request.requiresFastResponse || request.priority === 'speed') {
      capabilities.push('fast-response');
    }
    
    if (request.complexity === 'high' || request.requiresReasoning) {
      capabilities.push('reasoning');
    }
    
    if (request.hasImages || request.includesVision) {
      capabilities.push('vision');
    }
    
    if (request.requiresAnalysis || request.type === 'analysis') {
      capabilities.push('analysis');
    }
    
    return capabilities;
  }

  /**
   * Check if model meets request requirements
   */
  checkModelRequirements(modelConfig, request) {
    // Check token limits
    const estimatedTokens = this.estimateTokenUsage(request);
    if (estimatedTokens > modelConfig.maxTokens) {
      return false;
    }
    
    // Check timeout requirements
    if (request.maxLatency && modelConfig.targetLatency > request.maxLatency) {
      return false;
    }
    
    return true;
  }

  /**
   * Score models based on multiple criteria
   */
  scoreModels(candidates, request) {
    return candidates.map(candidate => {
      const latencyScore = this.calculateLatencyScore(candidate, request);
      const accuracyScore = candidate.config.accuracy;
      const costScore = this.calculateCostScore(candidate, request);
      const availabilityScore = candidate.performance.availability;
      const performanceScore = this.calculatePerformanceScore(candidate);
      
      const weights = this.config.preferenceWeighting;
      const totalScore = (
        latencyScore * weights.latency +
        accuracyScore * weights.accuracy +
        costScore * weights.cost +
        availabilityScore * weights.availability +
        performanceScore * 0.1
      );
      
      return {
        model: candidate.name,
        provider: candidate.config.provider,
        score: Math.min(1.0, Math.max(0.0, totalScore)),
        estimatedLatency: candidate.config.targetLatency,
        reasoning: this.generateSelectionReasoning(candidate, totalScore)
      };
    }).sort((a, b) => b.score - a.score);
  }

  /**
   * Calculate latency score (higher is better)
   */
  calculateLatencyScore(candidate, request) {
    const actualLatency = candidate.performance.averageLatency || candidate.config.targetLatency;
    const targetLatency = request.maxLatency || 2000;
    
    if (actualLatency <= targetLatency) {
      return 1.0 - (actualLatency / (targetLatency * 2));
    }
    
    return Math.max(0.1, 1.0 - (actualLatency / targetLatency));
  }

  /**
   * Calculate cost score (lower cost = higher score)
   */
  calculateCostScore(candidate, request) {
    const estimatedTokens = this.estimateTokenUsage(request);
    const estimatedCost = estimatedTokens * candidate.config.costPerToken;
    const maxAcceptableCost = request.maxCost || 0.1;
    
    return Math.max(0.1, 1.0 - (estimatedCost / maxAcceptableCost));
  }

  /**
   * Calculate performance score based on historical data
   */
  calculatePerformanceScore(candidate) {
    const perf = candidate.performance;
    if (perf.requests === 0) return 0.5; // Neutral for untested models
    
    const successRate = perf.successes / perf.requests;
    const efficiencyBonus = perf.efficiency > 0.7 ? 0.1 : 0;
    
    return Math.min(1.0, successRate + efficiencyBonus);
  }

  /**
   * Select the optimal model from scored candidates
   */
  selectOptimalModel(scoredModels, request) {
    if (scoredModels.length === 0) {
      return this.getFallbackModel(request);
    }
    
    // Load balancing: occasionally use second-best model to gather performance data
    if (this.config.enableLoadBalancing && scoredModels.length > 1 && Math.random() < 0.1) {
      return scoredModels[1];
    }
    
    return scoredModels[0];
  }

  /**
   * Record model execution results for performance tracking
   */
  recordModelExecution(modelName, success, latency, _error = null) {
    if (!this.availableModels[modelName]) return;
    
    const performance = this.performanceHistory.get(modelName);
    
    performance.requests++;
    performance.lastUsed = Date.now();
    
    if (success) {
      performance.successes++;
      this.metrics.successfulRequests++;
      
      if (latency && typeof latency === 'number') {
        performance.totalLatency += latency;
        performance.averageLatency = performance.totalLatency / performance.successes;
        
        this.metrics.totalLatency += latency;
        this.metrics.averageLatency = this.metrics.totalLatency / this.metrics.successfulRequests;
      }
    } else {
      performance.failures++;
      this.metrics.errors++;
      
      // Reduce availability score for failed models
      performance.availability = Math.max(0.1, performance.availability * 0.95);
    }
    
    // Update efficiency score
    performance.efficiency = performance.requests > 0 ? 
      (performance.successes / performance.requests) : 0.5;
    
    // Update model availability based on recent performance
    this.updateModelAvailability(modelName);
  }

  /**
   * Update model availability based on recent performance
   */
  updateModelAvailability(modelName) {
    const performance = this.performanceHistory.get(modelName);
    const recentFailureRate = performance.requests > 10 ? 
      (performance.failures / performance.requests) : 0;
    
    if (recentFailureRate > 0.5) {
      performance.availability = Math.max(0.1, performance.availability * 0.8);
    } else if (recentFailureRate < 0.1) {
      performance.availability = Math.min(1.0, performance.availability * 1.05);
    }
  }

  /**
   * Estimate token usage for a request
   */
  estimateTokenUsage(request) {
    let tokens = 100; // Base overhead
    
    if (request.code) {
      tokens += Math.ceil(request.code.length / 4); // Rough token estimation
    }
    
    if (request.prompt || request.text) {
      const text = request.prompt || request.text;
      tokens += Math.ceil(text.length / 4);
    }
    
    if (request.context) {
      tokens += Math.ceil(JSON.stringify(request.context).length / 4);
    }
    
    // Add response estimation
    tokens += request.maxTokens || 1000;
    
    return tokens;
  }

  /**
   * Generate selection reasoning for transparency
   */
  generateSelectionReasoning(candidate, score) {
    const reasons = [];
    
    if (candidate.config.accuracy > 0.9) {
      reasons.push('high accuracy');
    }
    
    if (candidate.config.targetLatency < 500) {
      reasons.push('fast response');
    }
    
    if (candidate.performance.efficiency > 0.8) {
      reasons.push('proven reliability');
    }
    
    if (candidate.config.costPerToken < 0.000001) {
      reasons.push('cost effective');
    }
    
    return reasons.length > 0 ? 
      `Selected for: ${reasons.join(', ')} (score: ${score.toFixed(3)})` :
      `Selected with score: ${score.toFixed(3)}`;
  }

  /**
   * Get fallback model when no suitable candidates found
   */
  getFallbackModel(_request) {
    return {
      model: 'claude-3-haiku-20240307',
      provider: 'anthropic',
      confidence: 0.5,
      reasoning: 'Fallback selection - fast and reliable',
      estimatedLatency: 400,
      timestamp: Date.now()
    };
  }

  /**
   * Get basic fallback candidates
   */
  getBasicFallbacks() {
    return [
      {
        name: 'claude-3-haiku-20240307',
        config: this.availableModels['claude-3-haiku-20240307'],
        performance: this.performanceHistory.get('claude-3-haiku-20240307')
      },
      {
        name: 'gpt-3.5-turbo',
        config: this.availableModels['gpt-3.5-turbo'],
        performance: this.performanceHistory.get('gpt-3.5-turbo')
      }
    ];
  }

  /**
   * Get comprehensive metrics
   */
  getMetrics() {
    const uptime = Date.now() - this.metrics.lastReset;
    const requestsPerSecond = this.metrics.totalRequests / (uptime / 1000);
    const successRate = this.metrics.totalRequests > 0 ? 
      (this.metrics.successfulRequests / this.metrics.totalRequests) * 100 : 0;
    
    return {
      ...this.metrics,
      uptime,
      requestsPerSecond,
      successRate,
      modelPerformance: this.getModelPerformanceData(),
      timestamp: Date.now()
    };
  }

  /**
   * Get model performance data
   */
  getModelPerformanceData() {
    const performance = {};
    
    for (const [modelName, data] of this.performanceHistory) {
      performance[modelName] = {
        ...data,
        model: modelName,
        provider: this.availableModels[modelName]?.provider
      };
    }
    
    return performance;
  }

  /**
   * Get available models list
   */
  getAvailableModels() {
    return Object.keys(this.availableModels).filter(modelName => {
      const performance = this.performanceHistory.get(modelName);
      return performance && performance.availability > 0.1;
    });
  }

  /**
   * Reset metrics (useful for testing and monitoring)
   */
  resetMetrics() {
    this.metrics = {
      totalRequests: 0,
      successfulRequests: 0,
      errors: 0,
      averageLatency: 0,
      totalLatency: 0,
      modelUsage: new Map(),
      lastReset: Date.now()
    };
    
    this.initializeModelTracking();
  }

  /**
   * Get model recommendations based on usage patterns
   */
  getModelRecommendations() {
    const recommendations = [];
    const modelData = this.getModelPerformanceData();
    
    for (const [modelName, data] of Object.entries(modelData)) {
      if (data.requests > 10) {
        if (data.efficiency < 0.7) {
          recommendations.push({
            type: 'performance',
            model: modelName,
            message: `Model ${modelName} has low efficiency (${(data.efficiency * 100).toFixed(1)}%). Consider alternatives.`,
            priority: 'medium'
          });
        }
        
        if (data.averageLatency > this.availableModels[modelName]?.targetLatency * 1.5) {
          recommendations.push({
            type: 'latency',
            model: modelName,
            message: `Model ${modelName} latency is ${data.averageLatency}ms, significantly above target.`,
            priority: 'high'
          });
        }
      }
    }
    
    return {
      recommendations,
      timestamp: Date.now(),
      totalModelsAnalyzed: Object.keys(modelData).length
    };
  }
}
