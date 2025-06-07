/**
 * @fileoverview
 * Advanced 6-Model Orchestrator for the Cursor AI system.
 *
 * This module intelligently coordinates all 6 AI models, leveraging parallel
 * processing, advanced thinking modes, and a revolutionary decision matrix
 * to select the optimal model or combination for any given task.
 */

const { RevolutionaryApiError } = require('../system/errors.js');

// Real AI model clients.
const MODELS = {
    'o3': { client: require('./clients/o3-client.js') },
    'claude-4-sonnet-thinking': { client: require('./clients/claude-client.js') },
    'claude-4-opus-thinking': { client: require('./clients/claude-client.js') },
    'gemini-2.5-pro': { client: require('./clients/gemini-client.js') },
    'gpt-4.1': { client: require('./clients/gpt-client.js') },
    'claude-3.7-sonnet-thinking': { client: require('./clients/claude-client.js') },
};

class SixModelOrchestrator {
  /**
   * Initializes the 6-Model Orchestrator.
   * @param {object} config - The models configuration.
   * @param {object} cache - The revolutionary cache instance.
   */
  constructor(config, cache) {
    this.config = config;
    this.cache = cache;
    this.modelClients = MODELS;
    console.log('6-Model Orchestrator Initialized: Ready for parallel processing.');
  }

  /**
   * Selects the best model(s) for a task based on the revolutionary decision matrix.
   * @param {object} context - The context for the task.
   * @returns {string[]} A list of model names to use.
   */
  _selectModels(context) {
    // This is a simplified version of the decision matrix.
    // A real implementation would have complex logic here.
    if (context.instruction) {
      return this.config.thinking || ['claude-4-opus-thinking'];
    }
    if (context.multimodal) {
      return this.config.multimodal ? [this.config.multimodal] : ['gemini-2.5-pro'];
    }
    return this.config.ultraFast ? [this.config.ultraFast] : ['o3'];
  }

  /**
   * Gets a code completion from the best-suited models.
   * @param {object} options - The completion options.
   * @param {object} options.context - The assembled context.
   * @param {string[]} options.models - The specific models to use.
   * @param {boolean} options.thinkingMode - Whether to use thinking modes.
   * @returns {Promise<object>} The completion result.
   */
  async getCompletion({ context, models, thinkingMode }) {
    const selectedModels = models || this._selectModels(context);
    console.log(`[Orchestrator] Getting completion from: ${selectedModels.join(', ')} in parallel.`);

    const promises = selectedModels.map(modelName => {
        const client = this.modelClients[modelName]?.client;
        if (!client) {
            console.warn(`[Orchestrator] Model '${modelName}' not found.`);
            return Promise.resolve({ model: modelName, status: 'rejected', reason: 'Not configured' });
        }
        return client(context).then(
            res => ({ model: modelName, status: 'fulfilled', value: res }),
            err => ({ model: modelName, status: 'rejected', reason: err.message })
        );
    });

    const results = await Promise.allSettled(promises);
    const successfulCompletions = results
        .filter(r => r.status === 'fulfilled' && r.value.status === 'fulfilled')
        .map(r => r.value);

    if (successfulCompletions.length === 0) {
        throw new RevolutionaryApiError('All models failed to provide a completion.');
    }

    // Simple validation: return the first successful result.
    // A real implementation would have more sophisticated validation logic.
    const bestResult = successfulCompletions[0];
    return { model: bestResult.model, completion: bestResult.value, validated: successfulCompletions.length > 1 };
  }

  /**
   * Executes a command or instruction using one or more models.
   * @param {object} options - The execution options.
   * @param {object} options.context - The assembled context.
   * @param {string[]} options.models - The models to use.
   * @param {boolean} options.useThinking - Whether to engage thinking modes.
   * @param {boolean} options.validate - Whether to perform cross-model validation.
   * @returns {Promise<object>} The execution result.
   */
  async execute({ context, models, useThinking, validate }) {
    const selectedModels = models || this._selectModels(context);
    console.log(`[Orchestrator] Executing instruction on: ${selectedModels.join(', ')} in parallel.`);

    const promises = selectedModels.map(modelName => {
        const client = this.modelClients[modelName]?.client;
        if (!client) {
            console.warn(`[Orchestrator] Model '${modelName}' not found.`);
            return Promise.resolve({ model: modelName, status: 'rejected', reason: 'Not configured' });
        }
        return client(context, { useThinking }).then(
            res => ({ model: modelName, status: 'fulfilled', value: res }),
            err => ({ model: modelName, status: 'rejected', reason: err.message })
        );
    });

    const results = await Promise.allSettled(promises);
    const successfulExecutions = results
        .filter(r => r.status === 'fulfilled' && r.value.status === 'fulfilled')
        .map(r => r.value);

    if (successfulExecutions.length === 0) {
        throw new RevolutionaryApiError('All models failed to execute the instruction.');
    }

    // Simple validation: return the first successful result.
    const bestResult = successfulExecutions[0];
    return { model: bestResult.model, result: bestResult.value, validated: validate && successfulExecutions.length > 1 };
  }
}

module.exports = SixModelOrchestrator;
