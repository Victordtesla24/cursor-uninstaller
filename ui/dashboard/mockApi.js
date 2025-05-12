/**
 * Mock API for Cline AI Dashboard
 *
 * Provides simulated data for dashboard development and testing
 * Mimics the structure and behavior of the real MCP API
 * Implements realistic data patterns and randomization for testing different states
 */

// Helper function for simulating API delay
const delay = (ms) => new Promise(resolve => setTimeout(resolve, ms));

// Generate mock token utilization data
const generateTokenData = () => {
  return {
    total: {
      used: 527890,
      saved: 312450,
      budgeted: 750000
    },
    daily: {
      used: 18450,
      saved: 10320,
      budgeted: 25000
    },
    budgets: {
      codeCompletion: {
        used: 275420,
        budget: 300000,
        remaining: 24580
      },
      errorResolution: {
        used: 125640,
        budget: 200000,
        remaining: 74360
      },
      architecture: {
        used: 89430,
        budget: 150000,
        remaining: 60570
      },
      thinking: {
        used: 37400,
        budget: 100000,
        remaining: 62600
      }
    },
    cacheEfficiency: {
      hitRate: 0.68,
      missRate: 0.32,
      totalCached: 4250,
      totalHits: 2890
    }
  };
};

// Generate mock cost metrics data
const generateCostData = () => {
  return {
    totalCost: 4.79,
    monthlyCost: 22.45,
    projectedCost: 25.12,
    savings: {
      total: 3.65,
      caching: 1.85,
      optimization: 1.20,
      modelSelection: 0.60
    },
    byModel: {
      'claude-3.7-sonnet': 2.85,
      'gemini-2.5-flash': 1.35,
      'claude-3.7-haiku': 0.59
    },
    history: {
      daily: Array.from({ length: 30 }, (_, i) =>
        Math.round((3 + Math.sin(i / 3) * 2 + Math.random() * 0.8) * 100) / 100
      ),
      weekly: Array.from({ length: 12 }, (_, i) =>
        Math.round((15 + Math.sin(i / 2) * 5 + Math.random() * 2) * 100) / 100
      ),
      monthly: Array.from({ length: 6 }, (_, i) =>
        Math.round((20 + i * 1.5 + Math.random() * 5) * 100) / 100
      )
    }
  };
};

// Generate mock usage statistics data
const generateUsageData = () => {
  return {
    daily: Array.from({ length: 30 }, (_, i) =>
      Math.round(10000 + Math.sin(i / 5) * 5000 + Math.random() * 2000)
    ),
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
    byFile: {
      js: 180450,
      ts: 130670,
      jsx: 85230,
      tsx: 45780,
      css: 32450,
      html: 28320,
      json: 24990
    },
    popularity: {
      'Code Completion': 42,
      'Error Resolution': 28,
      'Code Explanation': 15,
      'Architecture Design': 10,
      'Test Generation': 5
    }
  };
};

// Generate mock models data
const generateModelsData = () => {
  return {
    selected: 'claude-3.7-sonnet',
    available: [
      {
        id: 'claude-3.7-sonnet',
        name: 'Claude 3.7 Sonnet',
        contextWindow: 200000,
        costPerToken: 0.000015,
        capabilities: ['code', 'reasoning', 'text', 'vision', 'math']
      },
      {
        id: 'gemini-2.5-flash',
        name: 'Gemini 2.5 Flash',
        contextWindow: 128000,
        costPerToken: 0.000008,
        capabilities: ['code', 'reasoning', 'text']
      },
      {
        id: 'claude-3.7-haiku',
        name: 'Claude 3.7 Haiku',
        contextWindow: 48000,
        costPerToken: 0.000003,
        capabilities: ['code', 'text', 'reasoning']
      }
    ],
    recommendedFor: {
      codeCompletion: 'gemini-2.5-flash',
      errorResolution: 'claude-3.7-sonnet',
      architecture: 'claude-3.7-sonnet',
      thinking: 'claude-3.7-sonnet',
      basicTasks: 'claude-3.7-haiku'
    }
  };
};

// Generate mock settings data
const generateSettingsData = () => {
  return {
    autoModelSelection: true,
    cachingEnabled: true,
    contextWindowOptimization: true,
    outputMinimization: true,
    notifyOnLowBudget: false,
    safetyChecks: true
  };
};

// Generate mock metrics data
const generateMetricsData = () => {
  return {
    tokenSavingsRate: 0.37,
    costSavingsRate: 0.43,
    averageResponseTime: 2.4,
    cacheHitRate: 0.68,
    dailyActiveUsers: 25,
    completionRate: 0.94,
    totalQueries: 8750,
    averageContextSize: 14250
  };
};

// Mock API methods
const mockApi = {
  // Fetch all dashboard data
  fetchDashboardData: async () => {
    // Simulate network delay
    await delay(800);

    // Simulate error in 10% of cases to test error handling
    // Only in tests where Math.random is explicitly set to trigger this
    // Default to not throwing in normal usage
    if (Math.random() >= 0.9) {
      throw new Error('Failed to fetch dashboard data');
    }

    return {
      tokens: generateTokenData(),
      costs: generateCostData(),
      usage: generateUsageData(),
      models: generateModelsData(),
      settings: generateSettingsData(),
      metrics: generateMetricsData()
    };
  },

  // Update selected model
  updateSelectedModel: async (modelId) => {
    await delay(300);

    // Simulate error in 5% of cases
    // Only in tests where Math.random is explicitly set to trigger this
    // Default to not throwing in normal usage
    if (Math.random() >= 0.95) {
      throw new Error('Failed to update model');
    }

    return true;
  },

  // Update setting
  updateSetting: async (setting, value) => {
    await delay(200);

    // Simulate error in 5% of cases
    // Only in tests where Math.random is explicitly set to trigger this
    // Default to not throwing in normal usage
    if (Math.random() >= 0.95) {
      throw new Error('Failed to update setting');
    }

    return true;
  },

  // Update token budget
  updateTokenBudget: async (budgetType, value) => {
    await delay(250);

    // Simulate error in 5% of cases
    // Only in tests where Math.random is explicitly set to trigger this
    // Default to not throwing in normal usage
    if (Math.random() >= 0.95) {
      throw new Error('Failed to update token budget');
    }

    return true;
  },

  // Refresh dashboard data
  refreshDashboardData: async () => {
    await delay(500);

    // Simulate error in 10% of cases
    // Only in tests where Math.random is explicitly set to trigger this
    // Default to not throwing in normal usage
    if (Math.random() >= 0.9) {
      throw new Error('Failed to refresh dashboard data');
    }

    return {
      tokens: generateTokenData(),
      costs: generateCostData(),
      usage: generateUsageData(),
      models: generateModelsData(),
      settings: generateSettingsData(),
      metrics: generateMetricsData()
    };
  }
};

export default mockApi;
