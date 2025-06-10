/**
 * @fileoverview
 * Simple performance report generator
 * Creates daily performance reports as JSON files
 */

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { getAllModelMetrics } from './model-metrics.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Simple in-memory storage for recent errors
const recentErrors = [];
const MAX_ERRORS = 100;

/**
 * Add an error to the recent errors list
 * @param {string} source - Source of the error (e.g., 'gpt-client')
 * @param {string} message - Error message
 * @param {string} severity - Error severity (warning, error, critical)
 */
function trackError(source, message, severity = 'error') {
  const error = {
    timestamp: new Date().toISOString(),
    source,
    message,
    severity
  };
  
  recentErrors.unshift(error);
  
  // Keep only the most recent errors
  if (recentErrors.length > MAX_ERRORS) {
    recentErrors.pop();
  }
  
  return error;
}

/**
 * Get recent errors
 * @param {number} limit - Maximum number of errors to return
 * @returns {Array} Recent errors
 */
function getRecentErrors(limit = 50) {
  return recentErrors.slice(0, limit);
}

/**
 * Generate simple recommendations based on metrics
 * @param {object} systemPerformance - System performance metrics
 * @param {object} modelMetrics - Model metrics
 * @returns {Array} Recommendations
 */
function generateSimpleRecommendations(systemPerformance, modelMetrics) {
  const recommendations = [];
  
  // Check error rate
  if (systemPerformance && systemPerformance.errorRate > 3) {
    recommendations.push({
      type: 'error_rate',
      priority: 'high',
      message: `High error rate (${systemPerformance.errorRate.toFixed(1)}%) detected. Review recent errors.`
    });
  }
  
  // Check response time
  if (systemPerformance && systemPerformance.averageLatency > 800) {
    recommendations.push({
      type: 'performance',
      priority: 'medium',
      message: `Slow average response time (${systemPerformance.averageLatency.toFixed(0)}ms). Consider optimizing request handling.`
    });
  }
  
  // Check model efficiency
  if (systemPerformance && systemPerformance.modelEfficiency < 80) {
    recommendations.push({
      type: 'model_efficiency',
      priority: 'medium',
      message: `Low model efficiency (${systemPerformance.modelEfficiency.toFixed(1)}%). Review model selection logic.`
    });
  }
  
  // Check model-specific metrics
  if (modelMetrics) {
    Object.entries(modelMetrics).forEach(([modelName, metrics]) => {
      if (metrics.successRate < 80) {
        recommendations.push({
          type: 'model_reliability',
          priority: 'high',
          message: `${modelName} has low success rate (${metrics.successRate.toFixed(1)}%). Consider fallback options.`
        });
      }
      
      if (metrics.avgResponseTime > 1000) {
        recommendations.push({
          type: 'model_performance',
          priority: 'medium',
          message: `${modelName} has high average response time (${metrics.avgResponseTime.toFixed(0)}ms).`
        });
      }
    });
  }
  
  // Add a general recommendation if none were generated
  if (recommendations.length === 0) {
    recommendations.push({
      type: 'general',
      priority: 'low',
      message: 'System is performing well. No specific recommendations at this time.'
    });
  }
  
  return recommendations;
}

/**
 * Generate a performance report
 * @param {object} systemPerformance - System performance metrics
 * @returns {object} Performance report
 */
function generatePerformanceReport(systemPerformance) {
  const modelMetrics = getAllModelMetrics();
  
  const report = {
    timestamp: new Date().toISOString(),
    systemPerformance: systemPerformance || { note: 'No system performance data available' },
    modelMetrics,
    errors: getRecentErrors(50),
    recommendations: generateSimpleRecommendations(systemPerformance, modelMetrics)
  };
  
  // Ensure reports directory exists
  const reportsDir = path.join(__dirname, '..', 'reports');
  if (!fs.existsSync(reportsDir)) {
    fs.mkdirSync(reportsDir, { recursive: true });
  }
  
  // Write to file with timestamp in name
  const date = new Date().toISOString().split('T')[0];
  const filename = `performance-${date}.json`;
  const filePath = path.join(reportsDir, filename);
  
  fs.writeFileSync(filePath, JSON.stringify(report, null, 2));
  console.log(`📊 Performance report generated: ${filename}`);
  
  return {
    report,
    filePath
  };
}

/**
 * Schedule daily performance reports
 * @param {function} getSystemPerformance - Function to get system performance
 * @param {number} hourUTC - Hour of day (UTC) to generate report
 */
function scheduleDailyReports(getSystemPerformance, hourUTC = 0) {
  const checkAndGenerateReport = () => {
    const now = new Date();
    const currentHourUTC = now.getUTCHours();
    
    if (currentHourUTC === hourUTC) {
      try {
        const systemPerformance = getSystemPerformance();
        generatePerformanceReport(systemPerformance);
      } catch (error) {
        console.error('Failed to generate scheduled performance report:', error);
      }
    }
  };
  
  // Check every hour
  setInterval(checkAndGenerateReport, 60 * 60 * 1000);
  
  console.log(`📅 Daily performance reports scheduled for ${hourUTC}:00 UTC`);
}

export {
  trackError,
  getRecentErrors,
  generatePerformanceReport,
  scheduleDailyReports
};
