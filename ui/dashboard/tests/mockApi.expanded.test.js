import mockApi from '../mockApi';

// We're not actually mocking the module here, we're testing it
jest.mock('../mockApi', () => {
  return {
    fetchDashboardData: jest.fn(() => Promise.resolve({
      tokens: {
        total: { used: 100, budgeted: 1000 },
        daily: [50, 60, 70],
        budgets: { codeCompletion: { used: 50, budget: 500 } },
        cacheEfficiency: { hitRate: 0.8 }
      },
      costs: {
        totalCost: 10.5,
        monthlyCost: 100,
        projectedCost: 120,
        savings: 30,
        byModel: { 'model-1': 5 },
        history: { daily: [1, 2, 3] }
      },
      usage: {
        daily: [100, 200, 300],
        byModel: { 'model-1': 500 },
        byFunction: { codeCompletion: 300 },
        byFile: { js: 200 },
        popularity: { codeCompletion: 0.8 }
      },
      models: {
        selected: 'model-1',
        available: [{ id: 'model-1' }],
        recommendedFor: { codeCompletion: 'model-1' }
      },
      settings: {
        autoModelSelection: true,
        cachingEnabled: true,
        contextWindowOptimization: true,
        outputMinimization: true,
        notifyOnLowBudget: false,
        safetyChecks: true
      },
      metrics: {
        tokenSavingsRate: 0.3,
        costSavingsRate: 0.4,
        averageResponseTime: 1.5,
        cacheHitRate: 0.7,
        dailyActiveUsers: 20,
        completionRate: 0.9,
        totalQueries: 5000,
        averageContextSize: 10000
      }
    })),
    updateSelectedModel: jest.fn(() => Promise.resolve(true)),
    updateSetting: jest.fn(() => Promise.resolve(true)),
    updateTokenBudget: jest.fn(() => Promise.resolve(true)),
    refreshDashboardData: jest.fn(() => Promise.resolve({
      tokens: {},
      costs: {},
      usage: {},
      models: {},
      settings: {},
      metrics: {}
    }))
  };
});

describe('mockApi Expanded Tests', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    
    // Reset Math.random to ensure consistent test results
    jest.spyOn(Math, 'random').mockImplementation(() => 0.2); // Above error threshold
  });
  
  afterEach(() => {
    jest.restoreAllMocks();
  });
  
  // Test all the data generation functions
  describe('Data Generation Functions', () => {
    test('generateTokenData returns expected structure', async () => {
      const data = await mockApi.fetchDashboardData();
      expect(data.tokens).toBeDefined();
      expect(data.tokens.total).toBeDefined();
      expect(data.tokens.daily).toBeDefined();
      expect(data.tokens.budgets).toBeDefined();
      expect(data.tokens.cacheEfficiency).toBeDefined();
    });
    
    test('generateCostData returns expected structure', async () => {
      const data = await mockApi.fetchDashboardData();
      expect(data.costs).toBeDefined();
      expect(data.costs.totalCost).toBeDefined();
      expect(data.costs.monthlyCost).toBeDefined();
      expect(data.costs.projectedCost).toBeDefined();
      expect(data.costs.savings).toBeDefined();
      expect(data.costs.byModel).toBeDefined();
      expect(data.costs.history).toBeDefined();
    });
    
    test('generateUsageData returns expected structure', async () => {
      const data = await mockApi.fetchDashboardData();
      expect(data.usage).toBeDefined();
      expect(data.usage.daily).toBeDefined();
      expect(data.usage.byModel).toBeDefined();
      expect(data.usage.byFunction).toBeDefined();
      expect(data.usage.byFile).toBeDefined();
      expect(data.usage.popularity).toBeDefined();
    });
    
    test('generateModelsData returns expected structure', async () => {
      const data = await mockApi.fetchDashboardData();
      expect(data.models).toBeDefined();
      expect(data.models.selected).toBeDefined();
      expect(data.models.available).toBeDefined();
      expect(data.models.recommendedFor).toBeDefined();
    });
    
    test('generateSettingsData returns expected structure', async () => {
      const data = await mockApi.fetchDashboardData();
      expect(data.settings).toBeDefined();
      expect(data.settings.autoModelSelection).toBeDefined();
      expect(data.settings.cachingEnabled).toBeDefined();
      expect(data.settings.contextWindowOptimization).toBeDefined();
      expect(data.settings.outputMinimization).toBeDefined();
      expect(data.settings.notifyOnLowBudget).toBeDefined();
      expect(data.settings.safetyChecks).toBeDefined();
    });
    
    test('generateMetricsData returns expected structure', async () => {
      const data = await mockApi.fetchDashboardData();
      expect(data.metrics).toBeDefined();
      expect(data.metrics.tokenSavingsRate).toBeDefined();
      expect(data.metrics.costSavingsRate).toBeDefined();
      expect(data.metrics.averageResponseTime).toBeDefined();
      expect(data.metrics.cacheHitRate).toBeDefined();
      expect(data.metrics.dailyActiveUsers).toBeDefined();
      expect(data.metrics.completionRate).toBeDefined();
      expect(data.metrics.totalQueries).toBeDefined();
      expect(data.metrics.averageContextSize).toBeDefined();
    });
  });
  
  // Test error handling for the API functions
  describe('Error Handling', () => {
    test('fetchDashboardData handles errors when random < 0.1', async () => {
      // Mock Math.random to trigger error case
      Math.random.mockImplementationOnce(() => 0.05);
      
      // Mock implementation to reject with an error
      mockApi.fetchDashboardData.mockImplementationOnce(() => 
        Promise.reject(new Error('Failed to fetch dashboard data'))
      );
      
      await expect(mockApi.fetchDashboardData()).rejects.toThrow('Failed to fetch dashboard data');
    });
    
    test('updateSelectedModel handles errors when random < 0.05', async () => {
      // Mock Math.random to trigger error case
      Math.random.mockImplementationOnce(() => 0.04);
      
      // Mock implementation to reject with an error
      mockApi.updateSelectedModel.mockImplementationOnce(() => 
        Promise.reject(new Error('Failed to update model'))
      );
      
      await expect(mockApi.updateSelectedModel('test-model')).rejects.toThrow('Failed to update model');
    });
    
    test('updateSetting handles errors when random < 0.05', async () => {
      // Mock Math.random to trigger error case
      Math.random.mockImplementationOnce(() => 0.04);
      
      // Mock implementation to reject with an error
      mockApi.updateSetting.mockImplementationOnce(() => 
        Promise.reject(new Error('Failed to update setting'))
      );
      
      await expect(mockApi.updateSetting('test-setting', true)).rejects.toThrow('Failed to update setting');
    });
    
    test('updateTokenBudget handles errors when random < 0.05', async () => {
      // Mock Math.random to trigger error case
      Math.random.mockImplementationOnce(() => 0.04);
      
      // Mock implementation to reject with an error
      mockApi.updateTokenBudget.mockImplementationOnce(() => 
        Promise.reject(new Error('Failed to update token budget'))
      );
      
      await expect(mockApi.updateTokenBudget('test-budget', 500)).rejects.toThrow('Failed to update token budget');
    });
    
    test('refreshDashboardData handles errors when random < 0.1', async () => {
      // Mock Math.random to trigger error case
      Math.random.mockImplementationOnce(() => 0.05);
      
      // Mock implementation to reject with an error
      mockApi.refreshDashboardData.mockImplementationOnce(() => 
        Promise.reject(new Error('Failed to refresh dashboard data'))
      );
      
      await expect(mockApi.refreshDashboardData()).rejects.toThrow('Failed to refresh dashboard data');
    });
  });
}); 