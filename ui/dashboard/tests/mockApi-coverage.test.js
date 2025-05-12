import mockApi from '../mockApi';

// Mock Math.random for consistent test results
const originalRandom = Math.random;

describe('mockApi Comprehensive Tests', () => {
  beforeEach(() => {
    // Always mock setTimeout to execute callback immediately
    jest.spyOn(global, 'setTimeout').mockImplementation(callback => callback());
    
    // Mock Math.random to return 0 by default (avoid errors)
    global.Math.random = jest.fn().mockReturnValue(0);
    
    // Reset API mocks
    jest.clearAllMocks();
  });

  afterEach(() => {
    // Restore original Math.random and setTimeout
    global.Math.random = originalRandom;
    jest.restoreAllMocks();
  });

  describe('Data Generation Functions', () => {
    test('all data generators return expected structure', async () => {
      // Keep Math.random returning 0 to avoid errors
      const data = await mockApi.fetchDashboardData();
      
      // Verify all expected sections are present
      expect(data).toHaveProperty('tokens');
      expect(data).toHaveProperty('costs');
      expect(data).toHaveProperty('usage');
      expect(data).toHaveProperty('models');
      expect(data).toHaveProperty('settings');
      expect(data).toHaveProperty('metrics');
      
      // Verify tokens structure
      expect(data.tokens).toHaveProperty('total');
      expect(data.tokens).toHaveProperty('daily');
      expect(data.tokens).toHaveProperty('budgets');
      expect(data.tokens).toHaveProperty('cacheEfficiency');
      
      // Verify costs structure
      expect(data.costs).toHaveProperty('totalCost');
      expect(data.costs).toHaveProperty('monthlyCost');
      expect(data.costs).toHaveProperty('projectedCost');
      expect(data.costs).toHaveProperty('savings');
      expect(data.costs).toHaveProperty('byModel');
      expect(data.costs).toHaveProperty('history');
      
      // Verify usage structure
      expect(data.usage).toHaveProperty('daily');
      expect(data.usage).toHaveProperty('byModel');
      expect(data.usage).toHaveProperty('byFunction');
      expect(data.usage).toHaveProperty('byFile');
      expect(data.usage).toHaveProperty('popularity');
      
      // Verify models structure
      expect(data.models).toHaveProperty('selected');
      expect(data.models).toHaveProperty('available');
      expect(data.models).toHaveProperty('recommendedFor');
      
      // Verify settings structure
      expect(data.settings).toHaveProperty('autoModelSelection');
      expect(data.settings).toHaveProperty('cachingEnabled');
      expect(data.settings).toHaveProperty('contextWindowOptimization');
      expect(data.settings).toHaveProperty('outputMinimization');
      expect(data.settings).toHaveProperty('notifyOnLowBudget');
      expect(data.settings).toHaveProperty('safetyChecks');
      
      // Verify metrics structure
      expect(data.metrics).toHaveProperty('tokenSavingsRate');
      expect(data.metrics).toHaveProperty('costSavingsRate');
      expect(data.metrics).toHaveProperty('averageResponseTime');
      expect(data.metrics).toHaveProperty('cacheHitRate');
      expect(data.metrics).toHaveProperty('dailyActiveUsers');
      expect(data.metrics).toHaveProperty('completionRate');
      expect(data.metrics).toHaveProperty('totalQueries');
      expect(data.metrics).toHaveProperty('averageContextSize');
    });
  });
  
  describe('API Methods', () => {
    test('fetchDashboardData returns correct data structure', async () => {
      // Ensure no error is thrown
      const data = await mockApi.fetchDashboardData();
      
      expect(data).toHaveProperty('tokens');
      expect(data).toHaveProperty('costs');
      expect(data).toHaveProperty('usage');
      expect(data).toHaveProperty('models');
      expect(data).toHaveProperty('settings');
      expect(data).toHaveProperty('metrics');
    });
    
    test('fetchDashboardData handles errors', async () => {
      // Force error by mocking Math.random to return 1.0 (>= 0.9 triggers error)
      global.Math.random = jest.fn().mockReturnValue(1.0);
      
      // Test that the promise rejects with the expected error
      let errorThrown = false;
      try {
        await mockApi.fetchDashboardData();
      } catch (error) {
        errorThrown = true;
        expect(error.message).toBe('Failed to fetch dashboard data');
      }
      
      // We should have caught an error
      expect(errorThrown).toBe(true);
    });
    
    test('updateSelectedModel returns true on success', async () => {
      // Keep Math.random returning 0 to avoid errors
      const result = await mockApi.updateSelectedModel('test-model');
      expect(result).toBe(true);
    });
    
    test('updateSelectedModel handles errors', async () => {
      // Force error by mocking Math.random to return 1.0 (>= 0.95 triggers error)
      global.Math.random = jest.fn().mockReturnValue(1.0);
      
      // Test that the promise rejects with the expected error
      let errorThrown = false;
      try {
        await mockApi.updateSelectedModel('test-model');
      } catch (error) {
        errorThrown = true;
        expect(error.message).toBe('Failed to update model');
      }
      
      // We should have caught an error
      expect(errorThrown).toBe(true);
    });
    
    test('updateSetting returns true on success', async () => {
      // Keep Math.random returning 0 to avoid errors
      const result = await mockApi.updateSetting('cachingEnabled', true);
      expect(result).toBe(true);
    });
    
    test('updateSetting handles errors', async () => {
      // Force error by mocking Math.random to return 1.0 (>= 0.95 triggers error)
      global.Math.random = jest.fn().mockReturnValue(1.0);
      
      // Test that the promise rejects with the expected error
      let errorThrown = false;
      try {
        await mockApi.updateSetting('cachingEnabled', true);
      } catch (error) {
        errorThrown = true;
        expect(error.message).toBe('Failed to update setting');
      }
      
      // We should have caught an error
      expect(errorThrown).toBe(true);
    });
    
    test('updateTokenBudget returns true on success', async () => {
      // Keep Math.random returning 0 to avoid errors
      const result = await mockApi.updateTokenBudget('codeCompletion', 500);
      expect(result).toBe(true);
    });
    
    test('updateTokenBudget handles errors', async () => {
      // Force error by mocking Math.random to return 1.0 (>= 0.95 triggers error)
      global.Math.random = jest.fn().mockReturnValue(1.0);
      
      // Test that the promise rejects with the expected error
      let errorThrown = false;
      try {
        await mockApi.updateTokenBudget('codeCompletion', 500);
      } catch (error) {
        errorThrown = true;
        expect(error.message).toBe('Failed to update token budget');
      }
      
      // We should have caught an error
      expect(errorThrown).toBe(true);
    });
    
    test('refreshDashboardData returns object with data on success', async () => {
      // Keep Math.random returning 0 to avoid errors
      const result = await mockApi.refreshDashboardData();
      
      expect(result).toHaveProperty('tokens');
      expect(result).toHaveProperty('costs');
      expect(result).toHaveProperty('usage');
      expect(result).toHaveProperty('models');
      expect(result).toHaveProperty('settings');
      expect(result).toHaveProperty('metrics');
    });
    
    test('refreshDashboardData handles errors', async () => {
      // Force error by mocking Math.random to return 1.0 (>= 0.9 triggers error)
      global.Math.random = jest.fn().mockReturnValue(1.0);
      
      // Test that the promise rejects with the expected error
      let errorThrown = false;
      try {
        await mockApi.refreshDashboardData();
      } catch (error) {
        errorThrown = true;
        expect(error.message).toBe('Failed to refresh dashboard data');
      }
      
      // We should have caught an error
      expect(errorThrown).toBe(true);
    });
  });
}); 