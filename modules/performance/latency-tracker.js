/**
 * Latency Tracker - High-precision latency monitoring and analysis
 * Tracks operation latency with percentile analysis and trend detection
 * Target: <0.5s completion latency, 95%+ first-pass accuracy tracking
 */

const EventEmitter = require('events');

class LatencyTracker extends EventEmitter {
    constructor(options = {}) {
        super();

        this.config = {
            threshold: options.threshold || 500, // 0.5s
            alertThreshold: options.alertThreshold || 2000, // 2s
            sampleSize: options.sampleSize || 1000, // Keep last 1000 samples
            percentiles: options.percentiles || [50, 75, 90, 95, 99],
            enableTrendAnalysis: options.enableTrendAnalysis !== false,
            trendWindow: options.trendWindow || 100, // Last 100 operations
            enableOperationBreakdown: options.enableOperationBreakdown !== false,
            ...options
        };

        this.state = {
            initialized: false,
            tracking: false,
            activeOperations: new Map(),
            completedOperations: [],
            operationStats: new Map()
        };

        this.metrics = {
            totalOperations: 0,
            successfulOperations: 0,
            failedOperations: 0,
            totalLatency: 0,
            averageLatency: 0,
            currentPercentiles: new Map(),
            trends: [],
            violations: []
        };

        this.timers = {
            cleanupInterval: null,
            analysisInterval: null
        };
    }

    /**
     * Initialize the latency tracker
     * @returns {Promise<void>}
     */
    async initialize() {
        if (this.state.initialized) return;

        try {
            this.state.tracking = true;
            this.state.initialized = true;

            // Start cleanup interval
            this.timers.cleanupInterval = setInterval(() => {
                this.cleanupOldOperations();
            }, 60000); // Every minute

            // Start analysis interval if trend analysis is enabled
            if (this.config.enableTrendAnalysis) {
                this.timers.analysisInterval = setInterval(() => {
                    this.analyzeTrends();
                }, 30000); // Every 30 seconds
            }

            console.log('✅ Latency Tracker initialized');
            console.log(`📊 Target: ${this.config.threshold}ms, Alert: ${this.config.alertThreshold}ms`);

        } catch (error) {
            console.error('❌ Latency tracker initialization failed:', error.message);
            throw error;
        }
    }

    /**
     * Start tracking an operation
     * @param {string} operation - Operation name
     * @param {Object} context - Operation context
     * @returns {string} Operation ID
     */
    startOperation(operation, context = {}) {
        if (!this.state.tracking) return null;

        const operationId = this.generateOperationId();
        const startTime = process.hrtime.bigint();

        this.state.activeOperations.set(operationId, {
            id: operationId,
            operation,
            startTime,
            startTimestamp: Date.now(),
            context,
            phases: new Map() // For phase-level tracking
        });

        return operationId;
    }

    /**
     * Start tracking a phase within an operation
     * @param {string} operationId - Operation ID
     * @param {string} phase - Phase name
     */
    startPhase(operationId, phase) {
        const operation = this.state.activeOperations.get(operationId);
        if (!operation) return;

        operation.phases.set(phase, {
            startTime: process.hrtime.bigint(),
            startTimestamp: Date.now()
        });
    }

    /**
     * Complete a phase within an operation
     * @param {string} operationId - Operation ID
     * @param {string} phase - Phase name
     */
    completePhase(operationId, phase) {
        const operation = this.state.activeOperations.get(operationId);
        if (!operation || !operation.phases.has(phase)) return;

        const phaseData = operation.phases.get(phase);
        const endTime = process.hrtime.bigint();
        const duration = Number(endTime - phaseData.startTime) / 1000000; // Convert to milliseconds

        operation.phases.set(phase, {
            ...phaseData,
            endTime,
            duration,
            completed: true
        });
    }

    /**
     * Complete tracking an operation
     * @param {string} operationId - Operation ID
     * @param {boolean} success - Operation success status
     * @param {Object} metadata - Additional metadata
     */
    completeOperation(operationId, success = true, metadata = {}) {
        const operation = this.state.activeOperations.get(operationId);
        if (!operation) return;

        const endTime = process.hrtime.bigint();
        const duration = Number(endTime - operation.startTime) / 1000000; // Convert to milliseconds

        // Create completed operation record
        const completedOperation = {
            ...operation,
            endTime,
            endTimestamp: Date.now(),
            duration,
            success,
            metadata,
            phases: Object.fromEntries(operation.phases)
        };

        // Add to completed operations
        this.state.completedOperations.push(completedOperation);

        // Update metrics
        this.updateMetrics(completedOperation);

        // Update operation-specific stats
        this.updateOperationStats(completedOperation);

        // Check for threshold violations
        this.checkThresholdViolations(completedOperation);

        // Remove from active operations
        this.state.activeOperations.delete(operationId);

        // Cleanup if needed
        if (this.state.completedOperations.length > this.config.sampleSize) {
            this.state.completedOperations = this.state.completedOperations
                .slice(-this.config.sampleSize);
        }

        // Emit completion event
        this.emit('operationCompleted', completedOperation);

        return completedOperation;
    }

    /**
     * Complete operation by name and duration (for backward compatibility)
     * @private
     */
    completeOperationByDuration(operation, duration, success = true) {
        const timestamp = Date.now();

        const operationData = {
            id: `${operation}_${timestamp}`,
            operation,
            // Ensure we round timestamps to integers before BigInt conversion
            startTime: BigInt(Math.round(timestamp - duration)) * BigInt(1000000),
            endTime: BigInt(Math.round(timestamp)) * BigInt(1000000),
            startTimestamp: timestamp - duration,
            endTimestamp: timestamp,
            duration,
            success,
            phase: 'completed'
        };

        // Update state
        this.state.completedOperations.push(operationData);
        this.state.totalOperations++;

        if (success) {
            this.state.successfulOperations++;
        } else {
            this.state.failedOperations++;
        }

        // Update metrics if method exists
        if (typeof this.updateMetrics === 'function') {
            this.updateMetrics(operationData);
        }

        // Cleanup old operations to prevent memory issues
        this.cleanupOldOperations();
    }

    /**
     * Update overall metrics
     * @private
     */
    updateMetrics(operation) {
        this.metrics.totalOperations++;
        this.metrics.totalLatency += operation.duration;
        this.metrics.averageLatency = this.metrics.totalLatency / this.metrics.totalOperations;

        if (operation.success) {
            this.metrics.successfulOperations++;
        } else {
            this.metrics.failedOperations++;
        }

        // Update percentiles
        this.updatePercentiles();
    }

    /**
     * Update operation-specific statistics
     * @private
     */
    updateOperationStats(operation) {
        const key = operation.operation;

        if (!this.state.operationStats.has(key)) {
            this.state.operationStats.set(key, {
                operation: key,
                count: 0,
                successCount: 0,
                failedCount: 0,
                totalDuration: 0,
                averageDuration: 0,
                minDuration: Infinity,
                maxDuration: 0,
                lastExecution: null,
                violationCount: 0,
                durations: []
            });
        }

        const stats = this.state.operationStats.get(key);
        stats.count++;
        stats.totalDuration += operation.duration;
        stats.averageDuration = stats.totalDuration / stats.count;
        stats.minDuration = Math.min(stats.minDuration, operation.duration);
        stats.maxDuration = Math.max(stats.maxDuration, operation.duration);
        stats.lastExecution = operation.endTimestamp;

        if (operation.success) {
            stats.successCount++;
        } else {
            stats.failedCount++;
        }

        // Track recent durations for percentiles
        stats.durations.push(operation.duration);
        if (stats.durations.length > 100) {
            stats.durations = stats.durations.slice(-100);
        }

        // Check for violations
        if (operation.duration > this.config.threshold) {
            stats.violationCount++;
        }
    }

    /**
     * Update percentile calculations
     * @private
     */
    updatePercentiles() {
        if (this.state.completedOperations.length === 0) return;

        const durations = this.state.completedOperations
            .map(op => op.duration)
            .sort((a, b) => a - b);

        for (const percentile of this.config.percentiles) {
            const index = Math.ceil((percentile / 100) * durations.length) - 1;
            this.metrics.currentPercentiles.set(percentile, durations[Math.max(0, index)]);
        }
    }

    /**
     * Check for threshold violations
     * @private
     */
    checkThresholdViolations(operation) {
        if (operation.duration > this.config.threshold) {
            const violation = {
                operation: operation.operation,
                duration: operation.duration,
                threshold: this.config.threshold,
                severity: operation.duration > this.config.alertThreshold ? 'critical' : 'warning',
                timestamp: operation.endTimestamp,
                metadata: operation.metadata
            };

            this.metrics.violations.push(violation);

            // Keep only recent violations
            if (this.metrics.violations.length > 100) {
                this.metrics.violations = this.metrics.violations.slice(-100);
            }

            this.emit('thresholdViolation', violation);

            if (violation.severity === 'critical') {
                this.emit('criticalLatency', violation);
            }
        }
    }

    /**
     * Analyze performance trends
     * @private
     */
    analyzeTrends() {
        if (this.state.completedOperations.length < this.config.trendWindow) return;

        try {
            const recentOperations = this.state.completedOperations
                .slice(-this.config.trendWindow);

            const trend = this.calculateTrend(recentOperations);

            if (trend) {
                this.metrics.trends.push({
                    timestamp: Date.now(),
                    ...trend
                });

                // Keep only recent trends
                if (this.metrics.trends.length > 50) {
                    this.metrics.trends = this.metrics.trends.slice(-50);
                }

                // Emit trend events
                if (trend.direction === 'degrading' && trend.significance > 0.1) {
                    this.emit('performanceDegradation', trend);
                } else if (trend.direction === 'improving' && trend.significance > 0.1) {
                    this.emit('performanceImprovement', trend);
                }
            }

        } catch (error) {
            console.warn('Trend analysis failed:', error.message);
        }
    }

    /**
     * Calculate performance trend
     * @private
     */
    calculateTrend(operations) {
        if (operations.length < 10) return null;

        const durations = operations.map(op => op.duration);
        const halfPoint = Math.floor(durations.length / 2);

        const firstHalf = durations.slice(0, halfPoint);
        const secondHalf = durations.slice(-halfPoint);

        const firstAvg = firstHalf.reduce((sum, d) => sum + d, 0) / firstHalf.length;
        const secondAvg = secondHalf.reduce((sum, d) => sum + d, 0) / secondHalf.length;

        const change = secondAvg - firstAvg;
        const changePercent = (change / firstAvg) * 100;

        return {
            direction: change > 0 ? 'degrading' : 'improving',
            changeMs: Math.abs(change),
            changePercent: Math.abs(changePercent),
            significance: Math.abs(changePercent) / 100,
            firstHalfAvg: firstAvg,
            secondHalfAvg: secondAvg,
            sampleSize: operations.length
        };
    }

    /**
     * Get current metrics snapshot
     * @returns {Object} Current metrics
     */
    getCurrentMetrics() {
        const successRate = this.metrics.totalOperations > 0
            ? this.metrics.successfulOperations / this.metrics.totalOperations
            : 0;

        const violationRate = this.metrics.totalOperations > 0
            ? this.metrics.violations.length / this.metrics.totalOperations
            : 0;

        return {
            totalOperations: this.metrics.totalOperations,
            successfulOperations: this.metrics.successfulOperations,
            failedOperations: this.metrics.failedOperations,
            successRate: Math.round(successRate * 1000) / 1000,
            averageLatency: Math.round(this.metrics.averageLatency),
            percentiles: Object.fromEntries(this.metrics.currentPercentiles),
            violations: this.metrics.violations.length,
            violationRate: Math.round(violationRate * 1000) / 1000,
            recentViolations: this.metrics.violations.slice(-10),
            activeOperations: this.state.activeOperations.size,
            operationStats: Object.fromEntries(this.state.operationStats),
            trends: this.metrics.trends.slice(-5),
            thresholds: {
                target: this.config.threshold,
                alert: this.config.alertThreshold
            }
        };
    }

    /**
     * Get performance summary
     * @returns {Object} Performance summary
     */
    getPerformanceSummary() {
        const metrics = this.getCurrentMetrics();

        const meetsLatencyTarget = metrics.averageLatency <= this.config.threshold;
        const meetsAccuracyTarget = metrics.successRate >= 0.95;

        return {
            meetsTargets: meetsLatencyTarget && meetsAccuracyTarget,
            latencyTarget: {
                target: this.config.threshold,
                actual: metrics.averageLatency,
                status: meetsLatencyTarget ? 'pass' : 'fail'
            },
            accuracyTarget: {
                target: 0.95,
                actual: metrics.successRate,
                status: meetsAccuracyTarget ? 'pass' : 'fail'
            },
            healthScore: this.calculateHealthScore(metrics),
            recommendations: this.generateRecommendations(metrics)
        };
    }

    /**
     * Calculate health score based on performance metrics
     * @private
     */
    calculateHealthScore(metrics) {
        let score = 100;

        // Deduct for high latency
        if (metrics.averageLatency > this.config.threshold) {
            const excess = metrics.averageLatency - this.config.threshold;
            score -= Math.min(30, (excess / this.config.threshold) * 30);
        }

        // Deduct for low success rate
        if (metrics.successRate < 0.95) {
            score -= (0.95 - metrics.successRate) * 100;
        }

        // Deduct for recent violations
        const recentViolations = this.metrics.violations.filter(v =>
            Date.now() - v.timestamp < 300000 // 5 minutes
        ).length;
        score -= recentViolations * 2;

        return Math.max(0, Math.min(100, Math.round(score)));
    }

    /**
     * Generate performance recommendations
     * @private
     */
    generateRecommendations(metrics) {
        const recommendations = [];

        if (metrics.averageLatency > this.config.threshold) {
            recommendations.push({
                type: 'performance',
                priority: 'high',
                message: `Average latency (${metrics.averageLatency}ms) exceeds target (${this.config.threshold}ms)`,
                suggestions: [
                    'Review slow operations and optimize critical paths',
                    'Consider caching strategies for frequently accessed data',
                    'Evaluate model selection criteria for faster response times'
                ]
            });
        }

        if (metrics.successRate < 0.95) {
            recommendations.push({
                type: 'reliability',
                priority: 'high',
                message: `Success rate (${(metrics.successRate * 100).toFixed(1)}%) is below target (95%)`,
                suggestions: [
                    'Investigate and fix error-prone operations',
                    'Implement better error handling and retry mechanisms',
                    'Review input validation and edge case handling'
                ]
            });
        }

        if (metrics.violationRate > 0.1) {
            recommendations.push({
                type: 'stability',
                priority: 'medium',
                message: `High violation rate (${(metrics.violationRate * 100).toFixed(1)}%) indicates inconsistent performance`,
                suggestions: [
                    'Identify operations with high latency variance',
                    'Implement performance budgets for critical operations',
                    'Consider load balancing and resource optimization'
                ]
            });
        }

        return recommendations;
    }

    /**
     * Cleanup old operations and reset counters if needed
     * @private
     */
    cleanupOldOperations() {
        // Clean up stale active operations (older than 5 minutes)
        const staleThreshold = Date.now() - 300000;

        for (const [id, operation] of this.state.activeOperations.entries()) {
            if (operation.startTimestamp < staleThreshold) {
                console.warn(`Cleaning up stale operation: ${operation.operation} (${id})`);
                this.state.activeOperations.delete(id);
            }
        }

        // Clean up old violations
        this.metrics.violations = this.metrics.violations.filter(v =>
            Date.now() - v.timestamp < 3600000 // Keep 1 hour
        );
    }

    /**
     * Generate unique operation ID
     * @private
     */
    generateOperationId() {
        return `op_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    }

    /**
     * Stop the latency tracker
     * @returns {Promise<void>}
     */
    async stop() {
        try {
            this.state.tracking = false;

            // Clear intervals
            if (this.timers.cleanupInterval) {
                clearInterval(this.timers.cleanupInterval);
                this.timers.cleanupInterval = null;
            }

            if (this.timers.analysisInterval) {
                clearInterval(this.timers.analysisInterval);
                this.timers.analysisInterval = null;
            }

            // Complete any remaining active operations
            for (const [id, operation] of this.state.activeOperations.entries()) {
                this.completeOperation(id, false, { reason: 'tracker_shutdown' });
            }

            console.log('✅ Latency Tracker stopped');

        } catch (error) {
            console.error('Latency tracker shutdown failed:', error.message);
        }
    }

    /**
     * Record latency for a completed operation (backward compatibility)
     * @param {number} latency - Latency in milliseconds
     * @param {string} operation - Operation name (optional)
     */
    recordLatency(latency, operation = 'unknown') {
        this.completeOperationByDuration(operation, latency, true);
    }

    /**
     * Get statistics (backward compatibility)
     * @returns {Object} Statistics in expected format
     */
    getStats() {
        const metrics = this.getCurrentMetrics();

        return {
            totalOperations: metrics.totalOperations,
            successfulOperations: metrics.successfulOperations,
            failedOperations: metrics.failedOperations,
            averageLatency: metrics.averageLatency,
            latencies: this.state.completedOperations.map(op => op.duration),
            percentiles: metrics.percentiles,
            violations: metrics.violations,
            recentViolations: metrics.recentViolations
        };
    }
}

module.exports = LatencyTracker; 