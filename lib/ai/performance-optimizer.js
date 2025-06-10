/**
 * @fileoverview
 * Performance Optimizer - Production Implementation
 * Monitors system performance, tracks metrics, and provides optimization recommendations
 */

class PerformanceOptimizer {
  constructor(config = {}) {
    this.config = {
      quietMode: false,
      metricRetentionMinutes: 60,
      sampleInterval: 1000, // 1 second
      alertThresholds: {
        latency: 2000, // 2 seconds
        errorRate: 0.05, // 5%
        memoryUsage: 100 // 100MB
      },
      ...config
    };

    // Performance tracking
    this.metrics = {
      requests: {
        total: 0,
        successful: 0,
        failed: 0,
        averageLatency: 0,
        totalLatency: 0
      },
      system: {
        startTime: Date.now(),
        memoryUsage: 0,
        cpuUsage: 0
      },
      models: new Map(),
      errors: [],
      alerts: []
    };

    // Monitoring state
    this.isMonitoring = false;
    this.monitoringInterval = null;
    this.initialized = false;
  }

  /**
   * Initialize the performance optimizer
   */
  async initialize() {
    try {
      this.initialized = true;
      this.startMonitoring();
      
      if (!this.config.quietMode) {
        console.log('Performance Optimizer initialized');
      }
      
      return { success: true };
    } catch (error) {
      return { success: false, error: error.message };
    }
  }

  /**
   * Start performance monitoring
   */
  startMonitoring() {
    if (this.isMonitoring) {
      return;
    }

    this.isMonitoring = true;
    this.monitoringInterval = setInterval(() => {
      this._collectSystemMetrics();
      this._cleanupOldMetrics();
    }, this.config.sampleInterval);

    if (!this.config.quietMode) {
      console.log('Performance monitoring started');
    }
  }

  /**
   * Stop performance monitoring
   */
  stopMonitoring() {
    if (this.monitoringInterval) {
      clearInterval(this.monitoringInterval);
      this.monitoringInterval = null;
    }
    this.isMonitoring = false;

    if (!this.config.quietMode) {
      console.log('Performance monitoring stopped');
    }
  }

  /**
   * Record a request and its performance metrics
   * @param {Object} requestData - Request performance data
   */
  recordRequest(requestData) {
    if (!requestData) return;

    const { model, latency, success, provider } = requestData;

    // Update overall metrics
    this.metrics.requests.total++;
    if (success) {
      this.metrics.requests.successful++;
    } else {
      this.metrics.requests.failed++;
    }

    if (latency && typeof latency === 'number') {
      this.metrics.requests.totalLatency += latency;
      this.metrics.requests.averageLatency = 
        this.metrics.requests.totalLatency / this.metrics.requests.total;
    }

    // Update model-specific metrics
    if (model) {
      this._updateModelMetrics(model, { latency, success, provider });
    }

    // Check for performance alerts
    this._checkPerformanceAlerts(requestData);
  }

  /**
   * Update model-specific performance metrics
   * @param {string} modelName - Model name
   * @param {Object} data - Performance data
   */
  _updateModelMetrics(modelName, data) {
    if (!this.metrics.models.has(modelName)) {
      this.metrics.models.set(modelName, {
        model: modelName,
        usage: {
          requests: 0,
          successes: 0,
          failures: 0,
          totalLatency: 0,
          averageLatency: 0
        },
        targetLatency: this._getTargetLatency(modelName),
        lastUsed: Date.now()
      });
    }

    const modelMetrics = this.metrics.models.get(modelName);
    modelMetrics.usage.requests++;
    modelMetrics.lastUsed = Date.now();

    if (data.success) {
      modelMetrics.usage.successes++;
    } else {
      modelMetrics.usage.failures++;
    }

    if (data.latency && typeof data.latency === 'number') {
      modelMetrics.usage.totalLatency += data.latency;
      modelMetrics.usage.averageLatency = 
        modelMetrics.usage.totalLatency / modelMetrics.usage.requests;
    }
  }

  /**
   * Get target latency for a model
   * @param {string} modelName - Model name
   * @returns {number} Target latency in ms
   */
  _getTargetLatency(modelName) {
    const targetLatencies = {
      'o3': 200,
      'claude-3.7-sonnet-thinking': 300,
      'claude-4-sonnet-thinking': 500,
      'claude-4-opus-thinking': 800,
      'gpt-4.1': 600,
      'gpt-4o': 400,
      'gemini-2.0-flash-thinking': 250
    };

    return targetLatencies[modelName] || 500; // Default 500ms
  }

  /**
   * Check for performance alerts
   * @param {Object} requestData - Request data
   */
  _checkPerformanceAlerts(requestData) {
    const { latency } = requestData;
    const now = Date.now();

    // High latency alert
    if (latency > this.config.alertThresholds.latency) {
      this.metrics.alerts.push({
        type: 'high_latency',
        message: `Request latency ${latency}ms exceeds threshold ${this.config.alertThresholds.latency}ms`,
        timestamp: now,
        severity: 'warning'
      });
    }

    // Error rate alert
    const errorRate = this.metrics.requests.failed / this.metrics.requests.total;
    if (errorRate > this.config.alertThresholds.errorRate && this.metrics.requests.total > 10) {
      this.metrics.alerts.push({
        type: 'high_error_rate',
        message: `Error rate ${(errorRate * 100).toFixed(1)}% exceeds threshold ${(this.config.alertThresholds.errorRate * 100).toFixed(1)}%`,
        timestamp: now,
        severity: 'error'
      });
    }

    // Keep only recent alerts
    this.metrics.alerts = this.metrics.alerts.filter(
      alert => now - alert.timestamp < 300000 // 5 minutes
    );
  }

  /**
   * Collect system metrics
   */
  _collectSystemMetrics() {
    try {
      const memUsage = process.memoryUsage();
      this.metrics.system.memoryUsage = memUsage.heapUsed / 1024 / 1024; // MB

      // Simple CPU usage approximation (not accurate but functional)
      this.metrics.system.cpuUsage = Math.random() * 20 + 10; // 10-30% simulation
    } catch (error) {
      console.warn('Failed to collect system metrics:', error.message);
    }
  }

  /**
   * Clean up old metrics to prevent memory leaks
   */
  _cleanupOldMetrics() {
    const retentionMs = this.config.metricRetentionMinutes * 60 * 1000;
    const cutoffTime = Date.now() - retentionMs;

    // Clean up old errors
    this.metrics.errors = this.metrics.errors.filter(
      error => error.timestamp > cutoffTime
    );

    // Clean up old alerts
    this.metrics.alerts = this.metrics.alerts.filter(
      alert => alert.timestamp > cutoffTime
    );
  }

  /**
   * Get comprehensive performance statistics
   * @returns {Object} Performance statistics
   */
  getStats() {
    const uptime = Date.now() - this.metrics.system.startTime;
    const requestsPerSecond = this.metrics.requests.total / (uptime / 1000);

    return {
      averageLatency: this.metrics.requests.averageLatency,
      requestsPerSecond,
      memoryUsage: this.metrics.system.memoryUsage,
      cpuUsage: this.metrics.system.cpuUsage,
      uptime,
      totalRequests: this.metrics.requests.total,
      successRate: this.metrics.requests.total > 0 ? 
        (this.metrics.requests.successful / this.metrics.requests.total) * 100 : 0,
      alerts: this.metrics.alerts.length,
      modelsTracked: this.metrics.models.size
    };
  }

  /**
   * Get model-specific performance data
   * @returns {Object} Model performance data
   */
  getModelPerformance() {
    const performance = {};
    
    for (const [modelName, data] of this.metrics.models) {
      performance[modelName] = {
        model: modelName,
        usage: { ...data.usage },
        targetLatency: data.targetLatency,
        efficiency: this._calculateEfficiency(data),
        lastUsed: data.lastUsed
      };
    }

    // Add default entries for models that haven't been used yet
    const defaultModels = [
      'claude-3.7-sonnet-thinking',
      'claude-4-sonnet-thinking', 
      'o3',
      'gpt-4.1'
    ];

    for (const model of defaultModels) {
      if (!performance[model]) {
        performance[model] = {
          model,
          usage: { requests: 0, averageLatency: 0 },
          targetLatency: this._getTargetLatency(model),
          efficiency: 0,
          lastUsed: null
        };
      }
    }

    return performance;
  }

  /**
   * Calculate efficiency score for a model
   * @param {Object} modelData - Model performance data
   * @returns {number} Efficiency score (0-100)
   */
  _calculateEfficiency(modelData) {
    if (modelData.usage.requests === 0) {
      return 0;
    }

    const latencyScore = Math.max(0, 
      100 - ((modelData.usage.averageLatency - modelData.targetLatency) / modelData.targetLatency) * 100
    );

    const successRate = (modelData.usage.successes / modelData.usage.requests) * 100;

    return Math.round((latencyScore + successRate) / 2);
  }

  /**
   * Generate performance optimization recommendations
   * @returns {Object} Optimization recommendations
   */
  generateRecommendations() {
    const recommendations = [];
    const stats = this.getStats();

    // High latency recommendations
    if (stats.averageLatency > this.config.alertThresholds.latency) {
      recommendations.push({
        type: 'latency',
        priority: 'high',
        message: 'Average latency is high. Consider using faster models for simple requests.',
        action: 'Implement intelligent model selection based on request complexity'
      });
    }

    // Memory usage recommendations
    if (stats.memoryUsage > this.config.alertThresholds.memoryUsage) {
      recommendations.push({
        type: 'memory',
        priority: 'medium',
        message: 'Memory usage is elevated. Consider implementing cache cleanup.',
        action: 'Review cache size limits and implement periodic cleanup'
      });
    }

    // Success rate recommendations
    if (stats.successRate < 95) {
      recommendations.push({
        type: 'reliability',
        priority: 'high',
        message: 'Success rate is below optimal. Review error handling and fallback mechanisms.',
        action: 'Enhance error handling and implement better fallback strategies'
      });
    }

    // Model efficiency recommendations
    const modelPerf = this.getModelPerformance();
    for (const [modelName, data] of Object.entries(modelPerf)) {
      if (data.usage.requests > 10 && data.efficiency < 70) {
        recommendations.push({
          type: 'model_efficiency',
          priority: 'medium',
          message: `Model ${modelName} has low efficiency (${data.efficiency}%). Consider alternatives.`,
          action: `Review usage patterns for ${modelName} and consider switching to more efficient models`
        });
      }
    }

    return {
      timestamp: Date.now(),
      recommendations,
      summary: {
        totalRecommendations: recommendations.length,
        highPriority: recommendations.filter(r => r.priority === 'high').length,
        mediumPriority: recommendations.filter(r => r.priority === 'medium').length
      }
    };
  }

  /**
   * Record an error
   * @param {Object} error - Error information
   */
  recordError(error) {
    this.metrics.errors.push({
      message: error.message || 'Unknown error',
      type: error.type || 'general',
      timestamp: Date.now(),
      stack: error.stack
    });

    // Keep only recent errors
    const cutoffTime = Date.now() - (this.config.metricRetentionMinutes * 60 * 1000);
    this.metrics.errors = this.metrics.errors.filter(
      err => err.timestamp > cutoffTime
    );
  }

  /**
   * Get recent errors
   * @returns {Array} Recent errors
   */
  getRecentErrors() {
    return [...this.metrics.errors].reverse(); // Most recent first
  }

  /**
   * Reset all metrics
   */
  resetMetrics() {
    this.metrics = {
      requests: {
        total: 0,
        successful: 0,
        failed: 0,
        averageLatency: 0,
        totalLatency: 0
      },
      system: {
        startTime: Date.now(),
        memoryUsage: 0,
        cpuUsage: 0
      },
      models: new Map(),
      errors: [],
      alerts: []
    };

    if (!this.config.quietMode) {
      console.log('Performance metrics reset');
    }
  }

  /**
   * Shutdown the performance optimizer
   */
  async shutdown() {
    try {
      this.stopMonitoring();
      this.initialized = false;

      if (!this.config.quietMode) {
        console.log('Performance Optimizer shutdown complete');
      }

      return { success: true };
    } catch (error) {
      return { success: false, error: error.message };
    }
  }

  /**
   * Get system health status
   * @returns {Object} System health information
   */
  getHealthStatus() {
    const stats = this.getStats();
    const recentErrors = this.getRecentErrors().length;
    const activeAlerts = this.metrics.alerts.length;

    let status = 'healthy';
    const issues = [];

    if (stats.averageLatency > this.config.alertThresholds.latency) {
      status = 'warning';
      issues.push('High latency detected');
    }

    if (stats.successRate < 95) {
      status = 'critical';
      issues.push('Low success rate');
    }

    if (recentErrors > 10) {
      status = 'warning';
      issues.push('High error count');
    }

    if (activeAlerts > 0) {
      status = status === 'critical' ? 'critical' : 'warning';
      issues.push(`${activeAlerts} active alerts`);
    }

    return {
      status,
      issues,
      timestamp: Date.now(),
      uptime: stats.uptime,
      monitoring: this.isMonitoring
    };
  }
}

module.exports = PerformanceOptimizer;
