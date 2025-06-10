/**
 * @fileoverview
 * Simple performance alert system
 * Monitors system metrics and triggers alerts when thresholds are exceeded
 */

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { trackError } from './performance-reporter.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Default alert thresholds
const DEFAULT_ALERT_THRESHOLDS = {
  errorRate: 5, // 5%
  responseTime: 1000, // 1 second
  memoryUsage: 100, // 100MB
  tokenUsage: 10000, // 10,000 tokens per hour
  modelFailureRate: 20 // 20% model failure rate
};

// Current alert thresholds (can be modified at runtime)
let alertThresholds = { ...DEFAULT_ALERT_THRESHOLDS };

// Recent alerts storage
const recentAlerts = [];
const MAX_ALERTS = 100;

/**
 * Set custom alert thresholds
 * @param {object} newThresholds - New threshold values
 */
function setAlertThresholds(newThresholds) {
  alertThresholds = {
    ...alertThresholds,
    ...newThresholds
  };
  
  console.log('Alert thresholds updated:', alertThresholds);
  return alertThresholds;
}

/**
 * Reset alert thresholds to defaults
 */
function resetAlertThresholds() {
  alertThresholds = { ...DEFAULT_ALERT_THRESHOLDS };
  console.log('Alert thresholds reset to defaults');
  return alertThresholds;
}

/**
 * Get current alert thresholds
 */
function getAlertThresholds() {
  return { ...alertThresholds };
}

/**
 * Check current metrics against thresholds and trigger alerts if needed
 * @param {object} metrics - Current system metrics
 * @returns {array} Triggered alerts
 */
function checkPerformanceAlerts(metrics) {
  if (!metrics) {
    console.warn('No metrics provided for alert checking');
    return [];
  }
  
  const alerts = [];
  
  // Check error rate
  if (metrics.errorRate > alertThresholds.errorRate) {
    alerts.push({
      type: 'error_rate',
      severity: 'warning',
      threshold: alertThresholds.errorRate,
      current: metrics.errorRate,
      message: `Error rate (${metrics.errorRate.toFixed(1)}%) exceeds threshold (${alertThresholds.errorRate}%)`
    });
  }
  
  // Check response time
  if (metrics.averageLatency > alertThresholds.responseTime) {
    alerts.push({
      type: 'response_time',
      severity: 'warning',
      threshold: alertThresholds.responseTime,
      current: metrics.averageLatency,
      message: `Average response time (${metrics.averageLatency.toFixed(0)}ms) exceeds threshold (${alertThresholds.responseTime}ms)`
    });
  }
  
  // Check memory usage
  if (metrics.memoryUsage > alertThresholds.memoryUsage) {
    alerts.push({
      type: 'memory_usage',
      severity: 'warning',
      threshold: alertThresholds.memoryUsage,
      current: metrics.memoryUsage,
      message: `Memory usage (${metrics.memoryUsage.toFixed(0)}MB) exceeds threshold (${alertThresholds.memoryUsage}MB)`
    });
  }
  
  // Check model metrics if available
  if (metrics.modelMetrics) {
    Object.entries(metrics.modelMetrics).forEach(([modelName, modelMetrics]) => {
      if (modelMetrics.successRate < (100 - alertThresholds.modelFailureRate)) {
        alerts.push({
          type: 'model_failure',
          severity: 'warning',
          model: modelName,
          threshold: alertThresholds.modelFailureRate,
          current: 100 - modelMetrics.successRate,
          message: `Model ${modelName} failure rate (${(100 - modelMetrics.successRate).toFixed(1)}%) exceeds threshold (${alertThresholds.modelFailureRate}%)`
        });
      }
    });
  }
  
  // Store and log alerts
  if (alerts.length > 0) {
    const timestamp = new Date().toISOString();
    
    alerts.forEach(alert => {
      // Add timestamp to alert
      alert.timestamp = timestamp;
      
      // Store in recent alerts
      recentAlerts.unshift(alert);
      
      // Log to console
      console.warn(`⚠️ PERFORMANCE ALERT: ${alert.message}`);
      
      // Track as error for reporting
      trackError('performance_monitor', alert.message, alert.severity);
    });
    
    // Keep recent alerts list at maximum size
    while (recentAlerts.length > MAX_ALERTS) {
      recentAlerts.pop();
    }
    
    // Log alerts to file
    logAlerts(alerts);
  }
  
  return alerts;
}

/**
 * Log alerts to file
 * @param {array} alerts - Alerts to log
 */
function logAlerts(alerts) {
  try {
    // Ensure logs directory exists
    const logsDir = path.join(__dirname, '..', 'logs');
    if (!fs.existsSync(logsDir)) {
      fs.mkdirSync(logsDir, { recursive: true });
    }
    
    // Write to log file
    const logFile = path.join(logsDir, 'performance-alerts.log');
    const timestamp = new Date().toISOString();
    
    const logLines = alerts.map(alert => 
      `[${timestamp}] ${alert.severity.toUpperCase()}: ${alert.message}\n`
    );
    
    fs.appendFileSync(logFile, logLines.join(''));
  } catch (error) {
    console.error('Failed to log alerts to file:', error);
  }
}

/**
 * Get recent alerts
 * @param {number} limit - Maximum number of alerts to return
 * @returns {Array} Recent alerts
 */
function getRecentAlerts(limit = 50) {
  return recentAlerts.slice(0, limit);
}

/**
 * Clear all recent alerts
 */
function clearAlerts() {
  recentAlerts.length = 0;
  console.log('Recent alerts cleared');
}

export {
  setAlertThresholds,
  resetAlertThresholds,
  getAlertThresholds,
  checkPerformanceAlerts,
  getRecentAlerts,
  clearAlerts
};
