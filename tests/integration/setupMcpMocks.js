/**
 * Setup file for MCP test mocks
 * Creates and configures mock functions for window.cline.callMcpFunction
 * and other MCP-related functionality
 */

// Mock console methods to prevent test noise
const originalConsoleError = console.error;
console.error = (...args) => {
  if (
    args[0]?.includes &&
    (args[0].includes('MCP') ||
      args[0].includes('test was not wrapped in act') ||
      args[0].includes('act(...)') ||
      args[0].includes('unmountComponentAtNode'))
  ) {
    // Suppress expected test warnings
    return;
  }
  originalConsoleError(...args);
};

// Helper to create a clean window.cline mock
export const setupClineMock = () => {
  // Ensure window object exists even in Node environment
  if (typeof window === 'undefined') {
    global.window = {};
  }

  // Setup mock if needed
  if (!window.cline) {
    window.cline = {};
  }

  // Setup fresh mock cline object for tests
  window.cline.callMcpFunction = jest.fn().mockImplementation(async () => {
    // Default implementation returns success
    return JSON.stringify({ success: true });
  });

  return window.cline;
};

// Mock data factory for dashboard data
export const createMockDashboardData = (overrides = {}) => {
  const defaultData = {
    dailyUsage: [
      { date: '2025-05-01', requests: 120, tokens: 15000, responseTime: 1.5 }
    ],
    modelStats: {
      'claude-3.7-sonnet': {
        name: 'Claude 3.7 Sonnet',
        tokenPrice: 0.03,
        maxTokens: 200000
      },
      'gemini-2.5-flash': {
        name: 'Gemini 2.5 Flash',
        tokenPrice: 0.002,
        maxTokens: 128000
      }
    },
    costData: {
      currentMonth: 1.38,
      previousMonth: 1.56,
      savings: 0.60
    },
    tokenBudgets: {
      codeCompletion: { used: 150, budget: 300 },
      errorResolution: { used: 875, budget: 1500 },
      architecture: { used: 1200, budget: 2000 },
      thinking: { used: 1800, budget: 2000 },
      total: { used: 4100, budget: 5000 }
    },
    cacheEfficiency: {
      hitRate: 0.65,
      missRate: 0.35,
      cacheSize: 228,
      L1Hits: 98,
      L2Hits: 96,
      L3Hits: 46
    },
    activeRequests: 4,
    systemHealth: 'optimal',
    selectedModel: 'claude-3.7-sonnet',
    settings: {
      autoModelSelection: true,
      cachingEnabled: true,
      contextWindowOptimization: true,
      outputMinimization: true,
      notifyOnLowBudget: false,
      safetyChecks: true
    }
  };

  return { ...defaultData, ...overrides };
};

// Helper to mock Date for consistent testing
export const mockDate = new Date('2025-05-08T12:00:00Z');

// Setup a fake date constructor for tests
export const setupDateMock = () => {
  const originalDate = global.Date;
  global.Date = class extends Date {
    constructor() {
      return mockDate;
    }
  };

  return () => {
    global.Date = originalDate;
  };
};
