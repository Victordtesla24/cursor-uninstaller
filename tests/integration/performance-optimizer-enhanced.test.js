
/**
 * Enhanced Performance Optimizer Tests
 * Tests for production-grade functionality and error handling
 */

import PerformanceOptimizer from '../../lib/ai/performance-optimizer.js';

describe('Performance Optimizer - Production Features', () => {
  let optimizer;

  beforeEach(() => {
    optimizer = new PerformanceOptimizer({ quietMode: true });
  });

  afterEach(async () => {
    if (optimizer) {
      await optimizer.shutdown();
    }
  });

  describe('Health Monitoring', () => {
    test('should provide comprehensive health assessment', async () => {
      await optimizer.initialize();
      
      const health = optimizer.getComprehensiveHealth();
      
      expect(health).toHaveProperty('overall');
      expect(health).toHaveProperty('components');
      expect(health).toHaveProperty('recommendations');
      expect(health).toHaveProperty('metrics');
      expect(health.components).toHaveProperty('latency');
      expect(health.components).toHaveProperty('memory');
      expect(health.components).toHaveProperty('requests');
      expect(health.components).toHaveProperty('errors');
    });

    test('should track performance trends', async () => {
      await optimizer.initialize();
      
      const trends = optimizer.getPerformanceTrends();
      
      expect(trends).toHaveProperty('latencyTrend');
      expect(trends).toHaveProperty('errorTrend');
      expect(trends).toHaveProperty('memoryTrend');
      expect(trends).toHaveProperty('requestsTrend');
      expect(trends.latencyTrend).toHaveProperty('direction');
      expect(trends.latencyTrend).toHaveProperty('confidence');
    });

    test('should export performance data', async () => {
      await optimizer.initialize();
      
      const exportData = optimizer.exportPerformanceData();
      
      expect(exportData).toHaveProperty('metrics');
      expect(exportData).toHaveProperty('alerts');
      expect(exportData).toHaveProperty('errors');
      expect(exportData).toHaveProperty('timestamp');
      expect(exportData).toHaveProperty('version');
    });
  });

  describe('Error Handling', () => {
    test('should handle invalid configurations gracefully', async () => {
      const invalidOptimizer = new PerformanceOptimizer({ 
        sampleInterval: -1,
        quietMode: true 
      });
      
      const result = await invalidOptimizer.initialize();
      expect(result).toHaveProperty('success');
      
      await invalidOptimizer.shutdown();
    });

    test('should record and track errors properly', async () => {
      await optimizer.initialize();
      
      const testError = new Error('Test error for tracking');
      optimizer.recordError(testError);
      
      const recentErrors = optimizer.getRecentErrors();
      expect(recentErrors.length).toBeGreaterThan(0);
      expect(recentErrors[0]).toHaveProperty('message');
      expect(recentErrors[0]).toHaveProperty('timestamp');
    });
  });

  describe('Performance Metrics', () => {
    test('should generate realistic performance recommendations', async () => {
      await optimizer.initialize();
      
      // Simulate some requests with varying performance
      optimizer.recordRequest({ model: 'test-model', latency: 500, success: true });
      optimizer.recordRequest({ model: 'test-model', latency: 1500, success: true });
      optimizer.recordRequest({ model: 'test-model', latency: 300, success: false });
      
      const recommendations = optimizer.generateRecommendations();
      
      expect(recommendations).toHaveProperty('recommendations');
      expect(recommendations).toHaveProperty('summary');
      expect(Array.isArray(recommendations.recommendations)).toBe(true);
    });

    test('should handle memory monitoring', async () => {
      await optimizer.initialize();
      optimizer.startMonitoring();
      
      // Wait for at least one metrics collection cycle
      await new Promise(resolve => setTimeout(resolve, 1100));
      
      const stats = optimizer.getStats();
      expect(stats).toHaveProperty('memoryUsage');
      expect(typeof stats.memoryUsage).toBe('number');
      expect(stats.memoryUsage).toBeGreaterThanOrEqual(0);
      
      optimizer.stopMonitoring();
    });
  });
});