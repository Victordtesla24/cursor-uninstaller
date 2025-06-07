/**
 * @fileoverview
 * Model Selector - Intelligent model selection for the Revolutionary AI system.
 */

class ModelSelector {
  constructor(config = {}) {
    this.config = config;
    this.models = {
      'o3': { speed: 'ultra-fast', complexity: 'simple', thinking: false },
      'claude-4-sonnet-thinking': { speed: 'fast', complexity: 'complex', thinking: true },
      'claude-4-opus-thinking': { speed: 'slow', complexity: 'ultimate', thinking: true },
      'gemini-2.5-pro': { speed: 'medium', complexity: 'multimodal', thinking: false },
      'gpt-4.1': { speed: 'medium', complexity: 'enhanced', thinking: false },
      'claude-3.7-sonnet-thinking': { speed: 'rapid', complexity: 'balanced', thinking: true }
    };
    console.log('[Model Selector] Initialized for intelligent model selection');
  }

  selectOptimalModel(task) {
    const { complexity, multimodal, speed } = task;

    if (multimodal) return 'gemini-2.5-pro';
    if (speed === 'ultra-fast') return 'o3';
    if (complexity === 'ultimate') return 'claude-4-opus-thinking';
    if (complexity === 'complex') return 'claude-4-sonnet-thinking';
    if (speed === 'rapid') return 'claude-3.7-sonnet-thinking';
    
    return 'gpt-4.1'; // Default enhanced model
  }

  selectMultipleModels(task) {
    const primary = this.selectOptimalModel(task);
    const models = [primary];

    // Add validation models for complex tasks
    if (task.complexity === 'ultimate' || task.complexity === 'complex') {
      models.push('o3'); // Speed backup
      if (task.validation) {
        models.push('gpt-4.1'); // Validation model
      }
    }

    return models;
  }

  getModelCapabilities(modelName) {
    return this.models[modelName] || null;
  }
}

module.exports = { ModelSelector }; 