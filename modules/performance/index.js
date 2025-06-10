/**
 * @fileoverview
 * Performance Monitoring System - Production Implementation
 * Real-time performance tracking, optimization recommendations, and alerting
 */

const EventEmitter = require('events');
const os = require('os');

class PerformanceMonitoringSystem extends EventEmitter {
  constructor(config = {}) {
    super();
    
    this.config = {
      alertThresholds: {
        latency: 500,
        memoryUsage: 512, // MB
        cpuUsage: 80, // percentage
        errorRate: 0.05 // 5%
      },
      retentionPeriod: 300000, // 5 minutes
      samplingInterval: 5000, // 5 seconds
      enableCPUMonitoring: true,
      enableMemoryMonitoring: true,
      enableOptimizationHints: true,
      ...config
    };

    // Core metrics storage
    this.metrics = {
      latency: [],
      throughput: 0,
      cacheHitRate: 0,
      errorRate: 0,
      memoryUsage: 0,
      cpuUsage: 0
    };

    // Advanced tracking
    this.operations = new Map(); // operationName -> metrics
    this.alerts = [];
    this.trends = new Map(); // metric -> trend data
    this.optimizationHints = [];
    
    // System monitoring
    this.systemMetrics = {
      memory: { used: 0, total: 0, percentage: 0 },
      cpu: { usage: 0, cores: os.cpus().length },
      disk: { usage: 0 },
      network: { in: 0, out: 0 }
    };

    // Performance baselines
    this.baselines = {
      latency: { p50: 100, p95: 300, p99: 500 },
      memoryUsage: { baseline: 128, warning: 256, critical: 512 },
      throughput: { target: 100 } // requests per second
    };

    this.startTime = Date.now();
    this.operationCount = 0;
    this.totalLatency = 0;
    this.errorCount = 0;
    this.callbacks = {};
    this.initialized = false;
    this.monitoringInterval = null;

    console.log('[Performance Monitor] Initialized with production monitoring capabilities');
  }

  /**
   * Initialize the performance monitoring system
   */
  async initialize() {
    try {
      console.log('[Performance Monitor] Starting system monitoring...');
      
      // Start real-time monitoring
      await this.startSystemMonitoring();
      
      // Initialize baseline measurements
      await this.calibrateBaselines();
      
      this.initialized = true;
      this.emit('initialized');
      
      console.log('✓ Performance monitoring system initialized successfully');
      
      return { success: true, timestamp: new Date().toISOString() };
    } catch (error) {
      console.error(`Performance monitoring initialization failed: ${error.message}`);
      return { success: false, error: error.message };
    }
  }

  /**
   * Start system monitoring with real-time metrics collection
   */
  async startSystemMonitoring() {
    if (this.monitoringInterval) {
      clearInterval(this.monitoringInterval);
    }

    this.monitoringInterval = setInterval(async () => {
      try {
        await this.collectSystemMetrics();
        this.analyzePerformanceTrends();
        this.checkAlertThresholds();
        this.generateOptimizationHints();
        this.cleanupOldMetrics();
      } catch (error) {
        console.error(`System monitoring error: ${error.message}`);
      }
    }, this.config.samplingInterval);

    // Initial collection
    await this.collectSystemMetrics();
  }

  /**
   * Collect real system metrics
   */
  async collectSystemMetrics() {
    try {
      // Memory metrics
      const memUsage = process.memoryUsage();
      const systemMem = {
        used: memUsage.heapUsed,
        total: memUsage.heapTotal,
        percentage: (memUsage.heapUsed / memUsage.heapTotal) * 100
      };

      // CPU metrics (averaged over sampling period)
      const cpuUsage = await this.getCPUUsage();

      // Update system metrics
      this.systemMetrics.memory = systemMem;
      this.systemMetrics.cpu.usage = cpuUsage;
      this.metrics.memoryUsage = Math.round(memUsage.heapUsed / 1024 / 1024);
      this.metrics.cpuUsage = cpuUsage;

      // Record trends
      this.recordTrend('memory', systemMem.percentage);
      this.recordTrend('cpu', cpuUsage);
      this.recordTrend('latency', this.getAverageLatency());

    } catch (error) {
      console.error(`Metrics collection failed: ${error.message}`);
    }
  }

  /**
   * Get real CPU usage percentage
   */
  async getCPUUsage() {
    return new Promise((resolve) => {
      const startMeasure = process.cpuUsage();
      const startTime = Date.now();

      setTimeout(() => {
        const elapTime = Date.now() - startTime;
        const elapUsage = process.cpuUsage(startMeasure);

        // Calculate CPU percentage
        const totalUsage = elapUsage.user + elapUsage.system;
        const totalTime = elapTime * 1000; // Convert to microseconds
        const cpuPercent = (totalUsage / totalTime) * 100;

        resolve(Math.min(100, Math.max(0, cpuPercent)));
      }, 100);
    });
  }

  /**
   * Track operation performance with comprehensive metrics
   */
  async trackOperation(operationName, operationFn) {
    const operationId = `${operationName}_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    const startTime = Date.now();
    const startMemory = process.memoryUsage().heapUsed;
    
    try {
      // Initialize operation tracking
      const operation = {
        name: operationName,
        id: operationId,
        startTime,
        startMemory,
        status: 'running'
      };

      // Execute operation
      const result = await operationFn();
      
      // Calculate metrics
      const endTime = Date.now();
      const latency = endTime - startTime;
      const memoryDelta = process.memoryUsage().heapUsed - startMemory;
      
      // Update operation tracking
      operation.endTime = endTime;
      operation.latency = latency;
      operation.memoryDelta = memoryDelta;
      operation.status = 'completed';

      // Record metrics
      this.recordOperationMetrics(operationName, {
        latency,
        memoryDelta,
        success: true,
        timestamp: endTime
      });

      this.recordLatency(latency);
      this.totalLatency += latency;
      this.operationCount++;
      
      // Performance analysis
      const performance = this.analyzeOperationPerformance(operationName, latency);
      
      // Alert on performance degradation
      if (latency > this.config.alertThresholds.latency) {
        this.triggerAlert({
          type: 'performance_degradation',
          severity: latency > this.config.alertThresholds.latency * 2 ? 'critical' : 'warning',
          message: `Operation ${operationName} exceeded ${this.config.alertThresholds.latency}ms threshold with ${latency}ms`,
          operationName,
          latency,
          timestamp: new Date().toISOString(),
          recommendations: this.getLatencyOptimizationHints(operationName, latency)
        });
      }
      
      // Log operation completion with performance data
      if (!this.config.quietMode) {
        console.log(`[Performance Monitor] ${operationName} completed in ${latency}ms (${performance.rating})`);
      }
      
      // Enhanced result formatting for compatibility
      if (result && typeof result === 'object' && 'success' in result) {
        return {
          ...result,
          performance: {
            latency,
            memoryDelta,
            rating: performance.rating,
            operationId
          },
          operationName,
          timestamp: new Date().toISOString()
        };
      }
      
      if (result && typeof result === 'object' && 'language' in result) {
        return {
          ...result,
          performance: {
            latency,
            memoryDelta,
            rating: performance.rating,
            operationId
          },
          operationName,
          timestamp: new Date().toISOString()
        };
      }
      
      return {
        result,
        performance: {
          latency,
          memoryDelta,
          rating: performance.rating,
          operationId
        },
        operationName,
        timestamp: new Date().toISOString()
      };

    } catch (error) {
      const latency = Date.now() - startTime;
      
      // Record error metrics
      this.recordOperationMetrics(operationName, {
        latency,
        memoryDelta: process.memoryUsage().heapUsed - startMemory,
        success: false,
        error: error.message,
        timestamp: Date.now()
      });

      this.errorCount++;
      this.metrics.errorRate = this.errorCount / (this.operationCount + this.errorCount);

      console.error(`[Performance Monitor] Operation ${operationName} failed in ${latency}ms: ${error.message}`);
      
      this.triggerAlert({
        type: 'operation_failure',
        severity: 'error',
        message: `Operation ${operationName} failed: ${error.message}`,
        operationName,
        latency,
        error: error.message,
        timestamp: new Date().toISOString()
      });

      throw error;
    }
  }

  /**
   * Record operation-specific metrics
   */
  recordOperationMetrics(operationName, metrics) {
    if (!this.operations.has(operationName)) {
      this.operations.set(operationName, {
        totalCalls: 0,
        totalLatency: 0,
        totalMemory: 0,
        successCount: 0,
        errorCount: 0,
        lastCall: null,
        latencyHistory: [],
        memoryHistory: []
      });
    }

    const opMetrics = this.operations.get(operationName);
    opMetrics.totalCalls++;
    opMetrics.totalLatency += metrics.latency;
    opMetrics.totalMemory += metrics.memoryDelta || 0;
    opMetrics.lastCall = metrics.timestamp;

    if (metrics.success) {
      opMetrics.successCount++;
    } else {
      opMetrics.errorCount++;
    }

    // Track latency history
    opMetrics.latencyHistory.push({
      latency: metrics.latency,
      timestamp: metrics.timestamp
    });

    // Keep only recent history
    if (opMetrics.latencyHistory.length > 100) {
      opMetrics.latencyHistory.shift();
    }

    // Track memory usage
    if (metrics.memoryDelta !== undefined) {
      opMetrics.memoryHistory.push({
        delta: metrics.memoryDelta,
        timestamp: metrics.timestamp
      });

      if (opMetrics.memoryHistory.length > 100) {
        opMetrics.memoryHistory.shift();
      }
    }
  }

  /**
   * Analyze operation performance and provide rating
   */
  analyzeOperationPerformance(operationName, latency) {
    const baselines = this.baselines.latency;
    
    let rating = 'excellent';
    let recommendations = [];

    if (latency > baselines.p99) {
      rating = 'poor';
      recommendations.push('Consider optimizing algorithm or caching');
    } else if (latency > baselines.p95) {
      rating = 'degraded';
      recommendations.push('Monitor for potential bottlenecks');
    } else if (latency > baselines.p50) {
      rating = 'acceptable';
    }

    return { rating, recommendations };
  }

  /**
   * Get latency optimization hints
   */
  getLatencyOptimizationHints(operationName, latency) {
    const hints = [];

    if (latency > 1000) {
      hints.push('Consider implementing caching for this operation');
      hints.push('Check for inefficient database queries or API calls');
    }

    if (latency > 500) {
      hints.push('Consider breaking down the operation into smaller chunks');
      hints.push('Implement async processing where possible');
    }

    // Operation-specific hints
    if (operationName.includes('completion') || operationName.includes('ai')) {
      hints.push('Consider using streaming responses');
      hints.push('Implement request batching');
    }

    return hints;
  }

  /**
   * Record performance trends
   */
  recordTrend(metric, value) {
    if (!this.trends.has(metric)) {
      this.trends.set(metric, []);
    }

    const trend = this.trends.get(metric);
    trend.push({
      value,
      timestamp: Date.now()
    });

    // Keep only recent data points
    if (trend.length > 720) { // 1 hour at 5-second intervals
      trend.shift();
    }
  }

  /**
   * Analyze performance trends
   */
  analyzePerformanceTrends() {
    for (const [metric, data] of this.trends.entries()) {
      if (data.length < 10) continue; // Need enough data points

      const recent = data.slice(-10);
      const older = data.slice(-20, -10);

      if (older.length === 0) continue;

      const recentAvg = recent.reduce((sum, point) => sum + point.value, 0) / recent.length;
      const olderAvg = older.reduce((sum, point) => sum + point.value, 0) / older.length;

      const trendDirection = recentAvg > olderAvg ? 'increasing' : 'decreasing';
      const changePercent = Math.abs((recentAvg - olderAvg) / olderAvg) * 100;

      // Alert on significant trends
      if (changePercent > 25) {
        this.emit('trend_detected', {
          metric,
          direction: trendDirection,
          change: changePercent,
          current: recentAvg,
          previous: olderAvg
        });
      }
    }
  }

  /**
   * Check alert thresholds
   */
  checkAlertThresholds() {
    const thresholds = this.config.alertThresholds;

    // Memory usage alert
    if (this.metrics.memoryUsage > thresholds.memoryUsage) {
      this.triggerAlert({
        type: 'high_memory_usage',
        severity: 'warning',
        message: `Memory usage (${this.metrics.memoryUsage}MB) exceeds threshold (${thresholds.memoryUsage}MB)`,
        value: this.metrics.memoryUsage,
        threshold: thresholds.memoryUsage,
        timestamp: new Date().toISOString()
      });
    }

    // CPU usage alert
    if (this.metrics.cpuUsage > thresholds.cpuUsage) {
      this.triggerAlert({
        type: 'high_cpu_usage',
        severity: 'warning',
        message: `CPU usage (${this.metrics.cpuUsage.toFixed(1)}%) exceeds threshold (${thresholds.cpuUsage}%)`,
        value: this.metrics.cpuUsage,
        threshold: thresholds.cpuUsage,
        timestamp: new Date().toISOString()
      });
    }

    // Error rate alert
    if (this.metrics.errorRate > thresholds.errorRate) {
      this.triggerAlert({
        type: 'high_error_rate',
        severity: 'critical',
        message: `Error rate (${(this.metrics.errorRate * 100).toFixed(1)}%) exceeds threshold (${thresholds.errorRate * 100}%)`,
        value: this.metrics.errorRate,
        threshold: thresholds.errorRate,
        timestamp: new Date().toISOString()
      });
    }
  }

  /**
   * Generate optimization hints
   */
  generateOptimizationHints() {
    const hints = [];

    // Memory optimization
    if (this.metrics.memoryUsage > this.baselines.memoryUsage.warning) {
      hints.push({
        type: 'memory',
        priority: 'high',
        message: 'Consider implementing garbage collection optimizations',
        details: 'Memory usage is approaching warning levels'
      });
    }

    // Latency optimization
    const avgLatency = this.getAverageLatency();
    if (avgLatency > this.baselines.latency.p95) {
      hints.push({
        type: 'latency',
        priority: 'medium',
        message: 'Consider implementing caching or optimization',
        details: `Average latency (${avgLatency}ms) exceeds P95 baseline`
      });
    }

    // Operation-specific optimizations
    for (const [opName, metrics] of this.operations.entries()) {
      const avgOpLatency = metrics.totalLatency / metrics.totalCalls;
      if (avgOpLatency > 200 && metrics.totalCalls > 10) {
        hints.push({
          type: 'operation',
          priority: 'medium',
          operation: opName,
          message: `Optimize ${opName} operation`,
          details: `Average latency: ${avgOpLatency.toFixed(1)}ms`
        });
      }
    }

    this.optimizationHints = hints;
  }

  /**
   * Trigger performance alert
   */
  triggerAlert(alert) {
    this.alerts.push({
      ...alert,
      id: `alert_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`
    });

    // Keep only recent alerts
    if (this.alerts.length > 1000) {
      this.alerts.shift();
    }

    // Emit alert event
    this.emit('alert', alert);

    // Call registered callback
    if (this.callbacks.onAlert) {
      this.callbacks.onAlert(alert);
    }

    // Log critical alerts
    if (alert.severity === 'critical') {
      console.error(`🚨 CRITICAL ALERT: ${alert.message}`);
    } else if (alert.severity === 'warning') {
      console.warn(`⚠️  WARNING: ${alert.message}`);
    }
  }

  /**
   * Calibrate performance baselines
   */
  async calibrateBaselines() {
    // Simple operation to establish baseline
    const calibrationStart = Date.now();
    
    // Perform some basic operations to establish baseline
    for (let i = 0; i < 10; i++) {
      await new Promise(resolve => setTimeout(resolve, 1));
    }
    
    const calibrationTime = Date.now() - calibrationStart;
    
    // Adjust baselines based on system performance
    if (calibrationTime > 50) {
      this.baselines.latency.p50 *= 1.5;
      this.baselines.latency.p95 *= 1.5;
      this.baselines.latency.p99 *= 1.5;
    }

    console.log('📊 Performance baselines calibrated');
  }

  /**
   * Clean up old metrics
   */
  cleanupOldMetrics() {
    const cutoff = Date.now() - this.config.retentionPeriod;

    // Clean up trends
    for (const [metric, data] of this.trends.entries()) {
      const filtered = data.filter(point => point.timestamp > cutoff);
      this.trends.set(metric, filtered);
    }

    // Clean up alerts
    this.alerts = this.alerts.filter(alert => 
      new Date(alert.timestamp).getTime() > cutoff
    );
  }

  // Backward compatibility methods (existing interface)

  getCurrentMetrics() {
    return {
      averageLatency: this.operationCount > 0 ? this.totalLatency / this.operationCount : 0,
      totalOperations: this.operationCount,
      memoryUsageMB: Math.round(process.memoryUsage().heapUsed / 1024 / 1024),
      cpuUsage: this.metrics.cpuUsage,
      errorRate: this.metrics.errorRate
    };
  }

  recordLatency(latency) {
    this.metrics.latency.push({
      value: latency,
      timestamp: Date.now()
    });
    
    if (this.metrics.latency.length > 1000) {
      this.metrics.latency.shift();
    }
  }

  getTotalRequests() {
    return this.operationCount + this.errorCount;
  }

  getErrors() {
    return this.errorCount;
  }

  getErrorRate() {
    const total = this.getTotalRequests();
    return total > 0 ? this.errorCount / total : 0;
  }

  getUptime() {
    const uptime = Math.floor((Date.now() - this.startTime) / 1000);
    return Math.max(uptime, 1);
  }

  getModelPerformance() {
    const models = ['gpt-3.5-turbo', 'gpt-4', 'claude-3-sonnet', 'claude-3-opus', 'gemini-pro'];
    const performance = {};
    
    models.forEach(modelName => {
      const opMetrics = this.operations.get(`ai_${modelName}`) || {
        totalCalls: 0,
        totalLatency: 0,
        successCount: 0
      };

      performance[modelName] = {
        model: modelName,
        usage: Math.min(100, (opMetrics.totalCalls / this.operationCount) * 100) || 0,
        targetLatency: 200,
        averageLatency: opMetrics.totalCalls > 0 ? 
          Math.round(opMetrics.totalLatency / opMetrics.totalCalls) : 
          this.getAverageLatency(),
        requests: opMetrics.totalCalls,
        successRate: opMetrics.totalCalls > 0 ? 
          (opMetrics.successCount / opMetrics.totalCalls) * 100 : 100
      };
    });
    
    return performance;
  }

  getAverageLatency() {
    if (this.metrics.latency.length === 0) return 0;
    const sum = this.metrics.latency.reduce((acc, metric) => {
      return acc + (typeof metric === 'number' ? metric : metric.value);
    }, 0);
    return Math.round(sum / this.metrics.latency.length);
  }

  updateThroughput(requestCount) {
    const uptime = (Date.now() - this.startTime) / 1000;
    this.metrics.throughput = requestCount / uptime;
  }

  updateCacheHitRate(hits, total) {
    this.metrics.cacheHitRate = total > 0 ? (hits / total) * 100 : 0;
  }

  getMetrics() {
    return {
      ...this.metrics,
      averageLatency: this.getAverageLatency(),
      uptime: (Date.now() - this.startTime) / 1000,
      totalOperations: this.operationCount,
      errorCount: this.errorCount
    };
  }

  async generateSummary() {
    const memoryUsage = process.memoryUsage();
    const summary = {
      totalOperations: this.operationCount || 0,
      averageLatency: this.operationCount > 0 ? this.totalLatency / this.operationCount : 0,
      memoryUsageMB: Math.round(memoryUsage.heapUsed / 1024 / 1024),
      uptime: Date.now() - this.startTime,
      healthScore: this._calculateHealthScore(),
      overallSuccessRate: this.getTotalRequests() > 0 ? 
        ((this.getTotalRequests() - this.errorCount) / this.getTotalRequests()) : 0.95,
      cpuUsage: this.metrics.cpuUsage,
      errorRate: this.getErrorRate(),
      optimizationHints: this.optimizationHints.slice(0, 5),
      alerts: this.alerts.filter(a => 
        Date.now() - new Date(a.timestamp).getTime() < 300000
      ).slice(0, 10)
    };
    
    return {
      timestamp: new Date().toISOString(),
      summary,
      metrics: summary,
      memoryUsageMB: summary.memoryUsageMB,
      totalOperations: summary.totalOperations,
      averageLatency: summary.averageLatency,
      healthScore: summary.healthScore
    };
  }

  _calculateHealthScore() {
    const avgLatency = this.getAverageLatency();
    const errorRate = this.getErrorRate();
    const memoryUsage = this.metrics.memoryUsage;
    const cpuUsage = this.metrics.cpuUsage;

    // Component scores (0-100)
    const latencyScore = Math.max(0, 100 - (avgLatency / 5));
    const errorScore = Math.max(0, 100 - (errorRate * 1000));
    const memoryScore = Math.max(0, 100 - (memoryUsage / 5));
    const cpuScore = Math.max(0, 100 - cpuUsage);

    // Weighted average
    const weightedScore = (
      latencyScore * 0.3 +
      errorScore * 0.3 +
      memoryScore * 0.2 +
      cpuScore * 0.2
    );

    return Math.min(100, Math.max(0, Math.round(weightedScore)));
  }

  async generateReport() {
    const metrics = this.getMetrics();
    const summary = await this.generateSummary();
    
    return {
      timestamp: new Date().toISOString(),
      metrics: metrics,
      summary: summary.summary,
      performance: {
        ...metrics,
        operations: Object.fromEntries(this.operations.entries()),
        trends: Object.fromEntries(this.trends.entries()),
        baselines: this.baselines
      },
      status: this._determineSystemStatus(),
      recommendations: this.generateRecommendations()
    };
  }

  _determineSystemStatus() {
    const healthScore = this._calculateHealthScore();
    
    if (healthScore >= 90) return 'optimal';
    if (healthScore >= 70) return 'good';
    if (healthScore >= 50) return 'degraded';
    return 'critical';
  }

  generateRecommendations() {
    const recommendations = [];
    const avgLatency = this.getAverageLatency();
    const memoryUsage = this.metrics.memoryUsage;
    const errorRate = this.getErrorRate();

    if (avgLatency > 300) {
      recommendations.push({
        type: 'performance',
        priority: 'high',
        message: 'Consider implementing caching or optimizing slow operations'
      });
    }

    if (memoryUsage > 256) {
      recommendations.push({
        type: 'memory',
        priority: 'medium',
        message: 'Monitor memory usage and consider garbage collection optimization'
      });
    }

    if (errorRate > 0.02) {
      recommendations.push({
        type: 'reliability',
        priority: 'high',
        message: 'Investigate and fix error sources to improve reliability'
      });
    }

    return recommendations;
  }

  async shutdown() {
    console.log('[Performance Monitor] Shutting down...');
    
    if (this.monitoringInterval) {
      clearInterval(this.monitoringInterval);
      this.monitoringInterval = null;
    }

    this.initialized = false;
    this.emit('shutdown');
    
    console.log('✓ Performance monitoring system shutdown complete');
    
    return { success: true, timestamp: new Date().toISOString() };
  }
}

module.exports = { PerformanceMonitoringSystem };
