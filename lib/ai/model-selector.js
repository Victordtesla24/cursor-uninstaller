/**
 * Model Selection Layer - Intelligent routing between fast and powerful models
 * Implements decision matrix for optimal performance vs. accuracy tradeoff
 * Target: Fast models <200ms, Powerful models <2s
 */

class ModelSelector {
  constructor(options = {}) {
    this.config = {
      // Revolutionary 6-Model Configuration
      models: {
        'claude-4-sonnet-thinking': {
          type: 'revolutionary',
          thinkingMode: true,
          maxTokens: Infinity,
          targetLatency: 100,
          maxLatency: 200,
          contextLimit: Infinity,
          strengths: ['complex_logic', 'advanced_reasoning', 'architectural_analysis', 'step_by_step_thinking'],
          unlimitedProcessing: true
        },
        'claude-4-opus-thinking': {
          type: 'ultimate',
          thinkingMode: true,
          maxTokens: Infinity,
          targetLatency: 500,
          maxLatency: 1000,
          contextLimit: Infinity,
          strengths: ['ultimate_intelligence', 'complex_problems', 'advanced_architecture', 'maximum_reasoning'],
          unlimitedProcessing: true
        },
        'o3': {
          type: 'ultra-fast',
          thinkingMode: false,
          maxTokens: Infinity,
          targetLatency: 50,
          maxLatency: 100,
          contextLimit: Infinity,
          strengths: ['instant_completion', 'rapid_response', 'real_time', 'ultra_speed'],
          unlimitedProcessing: true
        },
        'gemini-2.5-pro': {
          type: 'multimodal',
          thinkingMode: true,
          maxTokens: Infinity,
          targetLatency: 225,
          maxLatency: 300,
          contextLimit: Infinity,
          strengths: ['multimodal_understanding', 'visual_analysis', 'context_integration', 'pattern_recognition'],
          unlimitedProcessing: true,
          multimodal: true
        },
        'gpt-4.1': {
          type: 'enhanced',
          thinkingMode: false,
          maxTokens: Infinity,
          targetLatency: 250,
          maxLatency: 400,
          contextLimit: Infinity,
          strengths: ['balanced_performance', 'reliable_output', 'consistent_quality', 'enhanced_capabilities'],
          unlimitedProcessing: true
        },
        'claude-3.7-sonnet-thinking': {
          type: 'rapid-iteration',
          thinkingMode: true,
          maxTokens: Infinity,
          targetLatency: 100,
          maxLatency: 150,
          contextLimit: Infinity,
          strengths: ['rapid_iteration', 'quick_analysis', 'iterative_improvement', 'fast_thinking'],
          unlimitedProcessing: true
        }
      },

      // Revolutionary Decision thresholds
      thresholds: {
        ultraFastModelLimit: 500,          // o3 threshold
        rapidIterationLimit: 1000,         // claude-3.7-sonnet-thinking threshold
        revolutionaryThinkingLimit: 5000,  // claude-4-sonnet-thinking threshold
        ultimateIntelligenceThreshold: 10000, // claude-4-opus-thinking threshold
        multimodalAnalysisThreshold: 2000, // gemini-2.5-pro threshold
        simpleCompletionMaxChars: 200,     // Enhanced for unlimited processing
        complexityAnalysisDepth: 5,        // Enhanced analysis depth
        forceModelOverride: false,
        unlimitedContextProcessing: true
      },

      // Revolutionary model preferences by language
      languagePreferences: {
        javascript: ['o3', 'claude-4-sonnet-thinking', 'claude-3.7-sonnet-thinking', 'gpt-4.1'],
        typescript: ['claude-4-sonnet-thinking', 'gemini-2.5-pro', 'gpt-4.1', 'o3'],
        python: ['claude-4-opus-thinking', 'gemini-2.5-pro', 'claude-4-sonnet-thinking', 'o3'],
        shell: ['gpt-4.1', 'claude-3.7-sonnet-thinking', 'o3'],
        html: ['gemini-2.5-pro', 'o3', 'claude-3.7-sonnet-thinking'],
        css: ['gemini-2.5-pro', 'o3', 'claude-3.7-sonnet-thinking'],
        react: ['claude-4-sonnet-thinking', 'gemini-2.5-pro', 'o3'],
        vue: ['claude-4-sonnet-thinking', 'gemini-2.5-pro', 'o3'],
        angular: ['claude-4-sonnet-thinking', 'gpt-4.1', 'gemini-2.5-pro']
      },

      ...options
    };

    this.stats = {
      selections: 0,
      modelUsage: {},
      performanceTracker: {},
      latencyHistory: {}
    };

    // Initialize model usage stats
    Object.keys(this.config.models).forEach(model => {
      this.stats.modelUsage[model] = 0;
      this.stats.latencyHistory[model] = [];
    });
  }

  /**
   * Select optimal model based on request complexity and context
   * @param {Object} request - Request parameters including context and complexity
   * @returns {Object} Model configuration with settings
   */
  selectModel(request) {
    this.stats.selections++;

    try {
      // Parse request parameters
      const {
        code = '',
        language = 'javascript',
        context = {},
        tokenCount = 0,
        priority = 'interactive',
        requestType = 'completion',
        forceModel = null,
        complexity = null
      } = request;

      // Force specific model if requested
      if (forceModel) {
        return this.buildModelConfig(this.resolveForceModel(forceModel), request, 'forced');
      }

      // Use code and language for complexity analysis
      const codeComplexity = this.analyzeCodeComplexity(code, language);
      const complexityAnalysis = this.analyzeComplexity({ ...request, codeComplexity });

      // Apply decision matrix
      const selectedModel = this.applyDecisionMatrix(complexityAnalysis, request);

      // Build final configuration
      const modelConfig = this.buildModelConfig(selectedModel, request, 'automatic');

      // Track selection
      this.trackSelection(selectedModel, complexityAnalysis);

      return modelConfig;

    } catch (error) {
      console.warn(`Model selection failed: ${error.message}, falling back to default`);
      return this.buildModelConfig('claude-4-sonnet-thinking', request, 'fallback');
    }
  }

  /**
   * Analyze request complexity using multiple factors
   * @private
   */
  analyzeComplexity(request) {
    const {
      code = '',
      language = 'javascript',
      context = {},
      tokenCount = 0,
      requestType = 'completion',
      instruction = {}
    } = request;

    let complexityScore = 0;
    let complexityFactors = [];

    // 1. Token count analysis (primary factor)
    if (tokenCount < this.config.thresholds.fastModelTokenLimit) {
      complexityScore += 1;
      complexityFactors.push('small_context');
    } else if (tokenCount < this.config.thresholds.balancedModelTokenLimit) {
      complexityScore += 2;
      complexityFactors.push('medium_context');
    } else {
      complexityScore += 3;
      complexityFactors.push('large_context');
    }

    // 2. Request type analysis
    const requestTypeComplexity = {
      'completion': 1,
      'auto_fix': 1,
      'simple_edit': 1,
      'refactor': 2,
      'implement_function': 2,
      'debug': 2,
      'optimize': 3,
      'architecture': 3,
      'multi_file': 3
    };

    const typeComplexity = requestTypeComplexity[requestType] || 2;
    complexityScore += typeComplexity;
    complexityFactors.push(`${requestType}_type`);

    // 3. Code content analysis
    if (code.length > this.config.thresholds.simpleCompletionMaxChars) {
      complexityScore += 1;
      complexityFactors.push('long_code_input');
    }

    // 4. Language-specific complexity
    const languageComplexity = {
      'javascript': 1,
      'typescript': 2,
      'python': 1,
      'shell': 1,
      'html': 1,
      'css': 1,
      'json': 0
    };

    complexityScore += languageComplexity[language] || 1;

    // 5. Instruction complexity (for edit operations)
    if (instruction.text) {
      const instructionKeywords = [
        'refactor', 'optimize', 'redesign', 'implement', 'create',
        'analyze', 'debug', 'fix bug', 'performance', 'architecture'
      ];

      const hasComplexKeywords = instructionKeywords.some(keyword =>
        instruction.text.toLowerCase().includes(keyword)
      );

      if (hasComplexKeywords) {
        complexityScore += 2;
        complexityFactors.push('complex_instruction');
      }
    }

    // 6. Context richness
    if (context.symbols && context.symbols.length > 10) {
      complexityScore += 1;
      complexityFactors.push('rich_context');
    }

    // Determine final complexity level
    let level;
    if (complexityScore <= 3) {
      level = 'simple';
    } else if (complexityScore <= 6) {
      level = 'medium';
    } else {
      level = 'complex';
    }

    return {
      score: complexityScore,
      level,
      factors: complexityFactors,
      tokenCount,
      requestType,
      language
    };
  }

  /**
   * Apply decision matrix to select optimal model
   * @private
   */
  applyDecisionMatrix(complexity, request) {
    const { level, tokenCount, requestType, language } = complexity;
    const { priority = 'interactive', thinkingMode = null, multimodalAnalysis = null } = request;

    // Revolutionary Decision Matrix Implementation
    if (level === 'simple' && tokenCount < this.config.thresholds.ultraFastModelLimit) {
      // Ultra-fast completion for simple requests
      return this.selectFromPreferences(['o3'], language);
    }

    if (level === 'simple' && requestType === 'completion') {
      // Simple completions with rapid iteration
      return this.selectFromPreferences(['o3', 'claude-3.7-sonnet-thinking'], language);
    }

    if (level === 'medium' && tokenCount < this.config.thresholds.rapidIterationLimit && ['javascript', 'typescript', 'python'].includes(language)) {
      // Auto-fix scenarios with rapid iteration
      return this.selectFromPreferences(['claude-3.7-sonnet-thinking', 'o3'], language);
    }

    if (level === 'medium' && tokenCount < this.config.thresholds.revolutionaryThinkingLimit) {
      // Medium complexity with revolutionary thinking
      return this.selectFromPreferences(['claude-4-sonnet-thinking', 'claude-3.7-sonnet-thinking'], language);
    }

    if (level === 'complex' || tokenCount >= this.config.thresholds.revolutionaryThinkingLimit) {
      // Complex analysis and large context
      if (tokenCount > this.config.thresholds.ultimateIntelligenceThreshold || requestType === 'architecture') {
        return this.selectFromPreferences(['claude-4-opus-thinking'], language);
      } else {
        return this.selectFromPreferences(['claude-4-sonnet-thinking', 'claude-4-opus-thinking'], language);
      }
    }

    // Multimodal analysis requests
    if (multimodalAnalysis === true || requestType === 'visual_analysis') {
      return this.selectFromPreferences(['gemini-2.5-pro'], language);
    }

    // Thinking mode requests
    if (thinkingMode === true || requestType === 'reasoning') {
      if (level === 'complex') {
        return this.selectFromPreferences(['claude-4-opus-thinking'], language);
      } else {
        return this.selectFromPreferences(['claude-4-sonnet-thinking', 'claude-3.7-sonnet-thinking'], language);
      }
    }

    // High priority requests get revolutionary models
    if (priority === 'high') {
      return this.selectFromPreferences(['claude-4-sonnet-thinking', 'claude-4-opus-thinking'], language);
    }

    // Enhanced general purpose requests
    if (requestType === 'enhanced' || priority === 'enhanced') {
      return this.selectFromPreferences(['gpt-4.1'], language);
    }

    // Default to revolutionary thinking
    return this.selectFromPreferences(['claude-4-sonnet-thinking'], language);
  }

  /**
   * Select model from preferences based on language and availability
   * @private
   */
  selectFromPreferences(preferredModels, language) {
    // Get language-specific preferences
    const langPrefs = this.config.languagePreferences[language] ||
      this.config.languagePreferences.javascript;

    // Find first available model from preferences
    for (const model of preferredModels) {
      if (this.config.models[model] && langPrefs.includes(model)) {
        return model;
      }
    }

    // Fallback to first preferred model
    if (preferredModels.length > 0 && this.config.models[preferredModels[0]]) {
      return preferredModels[0];
    }

    // Final fallback
    return 'claude-4-sonnet-thinking';
  }

  /**
   * Resolve forced model specification
   * @private
   */
  resolveForceModel(forceModel) {
    if (typeof forceModel === 'string' && this.config.models[forceModel]) {
      return forceModel;
    }

    // Handle force model types (Revolutionary Models)
    const modelsByType = {
      'ultra-fast': ['o3'],
      'fast': ['claude-3.7-sonnet-thinking'],
      'balanced': ['claude-4-sonnet-thinking'],
      'powerful': ['claude-4-opus-thinking'],
      'multimodal': ['gemini-2.5-pro'],
      'enhanced': ['gpt-4.1']
    };

    if (modelsByType[forceModel]) {
      return modelsByType[forceModel][0];
    }

    // Fallback
    return 'claude-4-sonnet-thinking';
  }

  /**
   * Build final model configuration with all settings
   * @private
   */
  buildModelConfig(modelName, request, selectionReason) {
    const model = this.config.models[modelName];
    if (!model) {
      throw new Error(`Unknown model: ${modelName}`);
    }

    const { complexity = {}, priority = 'interactive' } = request;

    // Base configuration
    const config = {
      model: modelName,
      type: model.type,
      maxTokens: model.maxTokens,
      targetLatency: model.targetLatency,
      maxLatency: model.maxLatency,
      contextLimit: model.contextLimit,

      // Dynamic parameters based on request
      temperature: this.calculateTemperature(complexity.level, request.requestType),
      topP: this.calculateTopP(complexity.level),
      presencePenalty: 0,
      frequencyPenalty: 0,

      // Metadata
      selectionReason,
      complexityLevel: complexity.level,
      estimatedLatency: this.estimateLatency(modelName, complexity),

      // Model-specific optimizations
      streamingEnabled: priority === 'interactive' && model.type !== 'powerful',
      cacheEnabled: true,
      retryConfig: {
        maxRetries: model.type === 'fast' ? 2 : 1,
        backoffMs: model.type === 'fast' ? 100 : 500
      }
    };

    return config;
  }

  /**
   * Calculate temperature based on complexity and request type
   * @private
   */
  calculateTemperature(complexityLevel, requestType) {
    // Lower temperature for more deterministic outputs
    const baseTemperatures = {
      'simple': 0.1,
      'medium': 0.2,
      'complex': 0.3
    };

    const requestTypeAdjustments = {
      'completion': -0.1,
      'auto_fix': -0.1,
      'refactor': 0,
      'implement_function': 0.1,
      'creative': 0.2
    };

    const base = baseTemperatures[complexityLevel] || 0.2;
    const adjustment = requestTypeAdjustments[requestType] || 0;

    return Math.max(0, Math.min(1, base + adjustment));
  }

  /**
   * Calculate top-p based on complexity
   * @private
   */
  calculateTopP(complexityLevel) {
    const topPValues = {
      'simple': 0.8,
      'medium': 0.9,
      'complex': 0.95
    };

    return topPValues[complexityLevel] || 0.9;
  }

  /**
   * Estimate latency based on model and complexity
   * @private
   */
  estimateLatency(modelName, complexity) {
    const model = this.config.models[modelName];
    if (!model) return 500;

    const baseLatency = model.targetLatency;
    const complexityMultipliers = {
      'simple': 0.8,
      'medium': 1.0,
      'complex': 1.5
    };

    const multiplier = complexityMultipliers[complexity.level] || 1.0;
    const tokenAdjustment = Math.min(complexity.tokenCount / 1000, 2) * 50; // +50ms per 1k tokens

    return Math.round(baseLatency * multiplier + tokenAdjustment);
  }

  /**
   * Track model selection for analytics
   * @private
   */
  trackSelection(modelName, complexity) {
    this.stats.modelUsage[modelName]++;

    if (!this.stats.performanceTracker[modelName]) {
      this.stats.performanceTracker[modelName] = {
        totalSelections: 0,
        complexityDistribution: { simple: 0, medium: 0, complex: 0 }
      };
    }

    this.stats.performanceTracker[modelName].totalSelections++;
    this.stats.performanceTracker[modelName].complexityDistribution[complexity.level]++;
  }

  /**
   * Record actual latency for model performance tracking
   * @param {string} modelName - Model that was used
   * @param {number} actualLatency - Measured latency in ms
   */
  recordLatency(modelName, actualLatency) {
    if (!this.stats.latencyHistory[modelName]) {
      this.stats.latencyHistory[modelName] = [];
    }

    this.stats.latencyHistory[modelName].push({
      latency: actualLatency,
      timestamp: Date.now()
    });

    // Keep only last 100 measurements
    if (this.stats.latencyHistory[modelName].length > 100) {
      this.stats.latencyHistory[modelName] = this.stats.latencyHistory[modelName].slice(-100);
    }
  }

  /**
   * Get model performance statistics
   */
  getModelPerformance(modelName) {
    if (!modelName) {
      // Return all models performance
      const allPerformance = {};
      for (const model of Object.keys(this.config.models)) {
        allPerformance[model] = this.getModelPerformance(model);
      }
      return allPerformance;
    }

    const history = this.stats.latencyHistory[modelName] || [];
    const usage = this.stats.modelUsage[modelName] || 0;
    const tracker = this.stats.performanceTracker[modelName];

    if (history.length === 0) {
      return {
        model: modelName,
        usage,
        averageLatency: null,
        targetLatency: this.config.models[modelName]?.targetLatency,
        recentLatencies: [],
        complexityDistribution: tracker?.complexityDistribution
      };
    }

    const latencies = history.map(h => h.latency);
    const averageLatency = latencies.reduce((sum, l) => sum + l, 0) / latencies.length;
    const recentLatencies = history.slice(-10).map(h => h.latency);

    return {
      model: modelName,
      usage,
      averageLatency: Math.round(averageLatency),
      targetLatency: this.config.models[modelName]?.targetLatency,
      recentLatencies,
      performanceRatio: averageLatency / (this.config.models[modelName]?.targetLatency || 500),
      complexityDistribution: tracker?.complexityDistribution
    };
  }

  /**
   * Get selection statistics
   */
  getSelectionStats() {
    return {
      totalSelections: this.stats.selections,
      modelUsage: { ...this.stats.modelUsage },
      modelDistribution: this.calculateModelDistribution(),
      averageLatenciesByModel: this.calculateAverageLatencies()
    };
  }

  /**
   * Calculate model usage distribution
   * @private
   */
  calculateModelDistribution() {
    const total = this.stats.selections;
    if (total === 0) return {};

    const distribution = {};
    for (const [model, count] of Object.entries(this.stats.modelUsage)) {
      distribution[model] = Math.round((count / total) * 100);
    }
    return distribution;
  }

  /**
   * Calculate average latencies by model
   * @private
   */
  calculateAverageLatencies() {
    const averages = {};
    for (const [model, history] of Object.entries(this.stats.latencyHistory)) {
      if (history.length > 0) {
        const avg = history.reduce((sum, h) => sum + h.latency, 0) / history.length;
        averages[model] = Math.round(avg);
      }
    }
    return averages;
  }

  /**
   * Update model configuration
   * @param {string} modelName - Model to update
   * @param {Object} updates - Configuration updates
   */
  updateModelConfig(modelName, updates) {
    if (this.config.models[modelName]) {
      this.config.models[modelName] = {
        ...this.config.models[modelName],
        ...updates
      };
    }
  }

  /**
   * Get available models for a language
   * @param {string} language - Programming language
   * @returns {Array} Available model names
   */
  getAvailableModels(language) {
    const preferences = this.config.languagePreferences[language] ||
      this.config.languagePreferences.javascript;

    return preferences.filter(model => this.config.models[model]);
  }
}

module.exports = ModelSelector;
