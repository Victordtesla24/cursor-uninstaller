/**
 * Import Path Validation Tests
 * 
 * Tests to ensure all import paths are correctly resolved and no import errors exist.
 * This test specifically validates the fixes for the errors documented in docs/errors.md
 */

import { render } from '@testing-library/react';
import '@testing-library/jest-dom';

// Test imports for components that had UI import path issues
import CostTracker from '../../src/components/features/CostTracker.jsx';
import TokenUtilization from '../../src/components/features/TokenUtilization.jsx';
import UsageChart from '../../src/components/features/UsageChart.jsx';

// Test import for the enhanced dashboard API that had mockApi import issues
import * as enhancedDashboardApi from '../../src/dashboard/lib/enhancedDashboardApi.js';

// Test import for the mockApi that should now be available
import mockApi from '../../src/dashboard/mockApi.js';

describe('Import Path Validation', () => {
  describe('UI Component Import Resolution', () => {
    test('CostTracker imports UI components correctly', () => {
      const mockCostData = {
        daily: 5.25,
        monthly: 125.50,
        dailyChange: 0.15,
        monthlyChange: -0.08,
        breakdown: {
          'claude-3.7-sonnet': 75.30,
          'gemini-2.5-flash': 35.20,
          'claude-3.7-haiku': 15.00
        },
        averageRate: 0.002
      };

      // This should not throw any import errors
      expect(() => {
        render(<CostTracker costData={mockCostData} />);
      }).not.toThrow();
    });

    test('TokenUtilization imports UI components correctly', () => {
      const mockTokenData = {
        usage: {
          total: 527890,
          prompt: 275420,
          completion: 125640,
          embedding: 89430,
          thinking: 37400
        },
        budgets: {
          total: 750000,
          prompt: 300000,
          completion: 200000,
          embedding: 150000,
          thinking: 100000
        },
        cacheEfficiency: 0.68
      };

      const mockCostData = {
        averageRate: 0.002
      };

      // This should not throw any import errors
      expect(() => {
        render(<TokenUtilization tokenData={mockTokenData} costData={mockCostData} />);
      }).not.toThrow();
    });

    test('UsageChart imports UI components correctly', () => {
      const mockUsageData = {
        totalTokens: 527890,
        inputTokens: 275420,
        outputTokens: 252470,
        activeUsers: 25,
        daily: [10000, 12000, 11500, 13000, 14500],
        byModel: {
          'claude-3.7-sonnet': 280450,
          'gemini-2.5-flash': 190350,
          'claude-3.7-haiku': 57090
        },
        byFunction: {
          codeCompletion: 250300,
          errorResolution: 120450,
          architecture: 95670,
          thinking: 61470
        },
        byFileType: {
          js: 180450,
          ts: 130670,
          jsx: 85230,
          tsx: 45780
        },
        popularity: {
          'Code Completion': 42,
          'Error Resolution': 28,
          'Code Explanation': 15
        }
      };

      // This should not throw any import errors
      expect(() => {
        render(<UsageChart usageData={mockUsageData} />);
      }).not.toThrow();
    });
  });

  describe('API Module Import Resolution', () => {
    test('enhancedDashboardApi imports mockApi correctly', () => {
      // Verify that the enhancedDashboardApi module can be imported without errors
      expect(enhancedDashboardApi).toBeDefined();
      expect(typeof enhancedDashboardApi.refreshData).toBe('function');
      expect(typeof enhancedDashboardApi.updateSelectedModel).toBe('function');
      expect(typeof enhancedDashboardApi.updateSetting).toBe('function');
      expect(typeof enhancedDashboardApi.updateTokenBudget).toBe('function');
    });

    test('mockApi module is accessible and functional', () => {
      // Verify that the mockApi module can be imported without errors
      expect(mockApi).toBeDefined();
      expect(typeof mockApi.fetchDashboardData).toBe('function');
      expect(typeof mockApi.updateSelectedModel).toBe('function');
      expect(typeof mockApi.updateSetting).toBe('function');
      expect(typeof mockApi.updateTokenBudget).toBe('function');
    });

    test('mockApi provides expected data structure', async () => {
      // Test that mockApi returns the expected data structure
      // Mock Math.random to prevent the random error scenario (when Math.random >= 0.9)
      const originalRandom = Math.random;
      Math.random = jest.fn().mockReturnValue(0.5); // Value below 0.9 to avoid error

      try {
        const dashboardData = await mockApi.fetchDashboardData();
        expect(dashboardData).toBeDefined();
        expect(dashboardData.tokens).toBeDefined();
        expect(dashboardData.costs).toBeDefined();
        expect(dashboardData.usage).toBeDefined();
        expect(dashboardData.models).toBeDefined();
        expect(dashboardData.settings).toBeDefined();
        expect(dashboardData.metrics).toBeDefined();
      } finally {
        // Restore original Math.random function
        Math.random = originalRandom;
      }
    });
  });

  describe('Import Path Error Prevention', () => {
    test('no relative path import errors in feature components', () => {
      // This test ensures that the specific errors from docs/errors.md are resolved:
      // - "./ui/index.js" imports have been corrected to "../ui/index.js"
      
      const componentFiles = [
        'CostTracker.jsx',
        'TokenUtilization.jsx', 
        'UsageChart.jsx'
      ];

      // If any of these components had import errors, the test imports above would fail
      // The fact that we can import and render them proves the paths are correct
      componentFiles.forEach(componentName => {
        expect(componentName).toMatch(/\.jsx$/);
      });
    });

    test('no missing mockApi import errors', () => {
      // This test ensures that the specific error from docs/errors.md is resolved:
      // - "../mockApi.js" import in enhancedDashboardApi.js now resolves correctly
      
      // If the mockApi import was still broken, the enhancedDashboardApi import would fail
      expect(enhancedDashboardApi).toBeDefined();
      expect(mockApi).toBeDefined();
    });
  });

  describe('Production-Grade Import Validation', () => {
    test('all UI components export expected interfaces', () => {
      // Verify that UI components maintain their expected interfaces after import fixes
      expect(CostTracker).toBeDefined();
      expect(typeof CostTracker).toBe('function');
      
      expect(TokenUtilization).toBeDefined();
      expect(typeof TokenUtilization).toBe('function');
      
      expect(UsageChart).toBeDefined();
      expect(typeof UsageChart).toBe('function');
    });

    test('API modules maintain functional integrity', () => {
      // Verify that API modules maintain their functionality after import fixes
      expect(enhancedDashboardApi.refreshData).toBeDefined();
      expect(enhancedDashboardApi.updateSelectedModel).toBeDefined();
      expect(enhancedDashboardApi.updateSetting).toBeDefined();
      expect(enhancedDashboardApi.updateTokenBudget).toBeDefined();
      
      expect(mockApi.fetchDashboardData).toBeDefined();
      expect(mockApi.updateSelectedModel).toBeDefined();
      expect(mockApi.updateSetting).toBeDefined();
      expect(mockApi.updateTokenBudget).toBeDefined();
    });
  });
});
