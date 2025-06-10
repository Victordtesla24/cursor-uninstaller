/**
 * @fileoverview
 * Simple model metrics tracking module
 * Tracks detailed performance metrics for AI models
 */

// Simple in-memory storage for model metrics
const modelMetrics = {};

/**
 * Track metrics for a model
 * @param {string} modelName - Name of the model
 * @param {number} responseTime - Response time in milliseconds
 * @param {boolean} success - Whether the request was successful
 * @param {number} tokenCount - Number of tokens used
 * @returns {object} Updated metrics for the model
 */
function trackModelMetrics(modelName, responseTime, success, tokenCount) {
  const metrics = modelMetrics[modelName] || {
    calls: 0,
    successCount: 0,
    totalTime: 0,
    avgResponseTime: 0,
    successRate: 0,
    tokenUsage: 0,
    lastUsed: null,
    lastError: null
  };
  
  metrics.calls++;
  metrics.totalTime += responseTime;
  metrics.avgResponseTime = metrics.totalTime / metrics.calls;
  if (success) {
    metrics.successCount++;
  } else {
    metrics.lastError = new Date().toISOString();
  }
  metrics.successRate = (metrics.successCount / metrics.calls) * 100;
  metrics.tokenUsage += tokenCount || 0;
  metrics.lastUsed = new Date().toISOString();
  
  modelMetrics[modelName] = metrics;
  return metrics;
}

/**
 * Get metrics for all models
 * @returns {object} Metrics for all models
 */
function getAllModelMetrics() {
  return { ...modelMetrics };
}

/**
 * Get metrics for a specific model
 * @param {string} modelName - Name of the model
 * @returns {object|null} Metrics for the model or null if not found
 */
function getModelMetrics(modelName) {
  return modelMetrics[modelName] || null;
}

/**
 * Clear all metrics
 */
function clearAllMetrics() {
  Object.keys(modelMetrics).forEach(key => delete modelMetrics[key]);
}

export {
  trackModelMetrics,
  getAllModelMetrics,
  getModelMetrics,
  clearAllMetrics
};
