/**
 * @fileoverview
 * Main AI System Index - Exports all AI components for the development tools.
 */

const AISystem = require('./ai-system');
const ModelSelector = require('./model-selector');
const ContextManager = require('./context-manager');
const AIController = require('./ai-controller');
const PerformanceOptimizer = require('./performance-optimizer');
const { BasicError, ApiError, TimeoutError, ConfigError } = require('../system/errors');

// Export all AI components including the main AISystem orchestrator
module.exports = {
  AISystem,
  ModelSelector,
  ContextManager,
  AIController,
  PerformanceOptimizer,
  Errors: {
    BasicError,
    ApiError,
    TimeoutError,
    ConfigError
  }
};
