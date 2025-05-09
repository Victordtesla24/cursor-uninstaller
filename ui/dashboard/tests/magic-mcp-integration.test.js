import { renderHook, act } from '@testing-library/react-hooks';
import { useMagicMcpDashboard } from '../magic-mcp-integration';

// Mock window.cline object before tests
global.window = {
  ...global.window,
  cline: {
    callMcpFunction: jest.fn()
  }
};

// Sample test data
const mockDashboardData = {
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

describe('useMagicMcpDashboard Hook', () => {
  // Clear all mocks before each test
  beforeEach(() => {
    jest.clearAllMocks();
  });

  // Mock the current Date
  const mockDate = new Date('2025-05-08T12:00:00Z');
  const originalDate = global.Date;

  beforeAll(() => {
    global.Date = class extends Date {
      constructor() {
        return mockDate;
      }
    };
  });

  afterAll(() => {
    global.Date = originalDate;
  });

  it('should initialize with loading state and no data', () => {
    // Mock a response that will resolve after timeout
    window.cline.callMcpFunction.mockImplementation(() => {
      return new Promise(resolve => {
        setTimeout(() => resolve(JSON.stringify(mockDashboardData)), 100);
      });
    });

    // Render the hook
    const { result } = renderHook(() => useMagicMcpDashboard());

    // Initial state should be loading with no data
    expect(result.current.isLoading).toBe(true);
    expect(result.current.data).toBeNull();
    expect(result.current.error).toBeNull();

    // Verify MCP function was called with correct parameters
    expect(window.cline.callMcpFunction).toHaveBeenCalledWith({
      serverName: 'cline-dashboard',
      resourceUri: 'cline://dashboard/all'
    });
  });

  it('should load dashboard data', async () => {
    // Mock successful response
    window.cline.callMcpFunction.mockResolvedValueOnce(JSON.stringify(mockDashboardData));

    // Render the hook with async behavior
    const { result, waitForNextUpdate } = renderHook(() => useMagicMcpDashboard());

    // Wait for the data to load
    await waitForNextUpdate();

    // Verify the data is loaded correctly
    expect(result.current.isLoading).toBe(false);
    expect(result.current.data).toEqual(mockDashboardData);
    expect(result.current.error).toBeNull();
    expect(result.current.lastUpdated).toEqual(mockDate);
  });

  it('should handle error when fetching dashboard data', async () => {
    // Mock error response
    const errorMessage = 'Failed to connect to MCP server';
    window.cline.callMcpFunction.mockRejectedValueOnce(new Error(errorMessage));

    // Render the hook with async behavior
    const { result, waitForNextUpdate } = renderHook(() => useMagicMcpDashboard());

    // Wait for the error to be processed
    await waitForNextUpdate();

    // Verify error state
    expect(result.current.isLoading).toBe(false);
    expect(result.current.data).toBeNull();
    expect(result.current.error).toBe(errorMessage);
  });

  it('should update model selection', async () => {
    // Mock successful initial data load
    window.cline.callMcpFunction.mockResolvedValueOnce(JSON.stringify(mockDashboardData));

    // Mock successful model update
    window.cline.callMcpFunction.mockResolvedValueOnce('Model updated successfully');

    // Mock successful data refresh after model update
    window.cline.callMcpFunction.mockResolvedValueOnce(JSON.stringify({
      ...mockDashboardData,
      selectedModel: 'gemini-2.5-flash'
    }));

    // Render the hook
    const { result, waitForNextUpdate } = renderHook(() => useMagicMcpDashboard());

    // Wait for initial data load
    await waitForNextUpdate();

    // Call updateModel
    let success;
    await act(async () => {
      success = await result.current.updateModel('gemini-2.5-flash');
    });

    // Verify success and MCP calls
    expect(success).toBe(true);
    expect(window.cline.callMcpFunction).toHaveBeenCalledWith({
      serverName: 'cline-dashboard',
      toolName: 'select_model',
      args: {
        model: 'gemini-2.5-flash'
      }
    });

    // Verify data was refreshed
    expect(window.cline.callMcpFunction).toHaveBeenCalledWith({
      serverName: 'cline-dashboard',
      resourceUri: 'cline://dashboard/all'
    });
  });

  it('should handle errors when updating model', async () => {
    // Mock successful initial data load
    window.cline.callMcpFunction.mockResolvedValueOnce(JSON.stringify(mockDashboardData));

    // Mock failed model update
    window.cline.callMcpFunction.mockRejectedValueOnce(new Error('Invalid model'));

    // Render the hook
    const { result, waitForNextUpdate } = renderHook(() => useMagicMcpDashboard());

    // Wait for initial data load
    await waitForNextUpdate();

    // Call updateModel with invalid model
    let success;
    await act(async () => {
      success = await result.current.updateModel('nonexistent-model');
    });

    // Verify failure
    expect(success).toBe(false);
    expect(result.current.error).toBe('Failed to switch to nonexistent-model');
  });

  it('should update settings', async () => {
    // Mock successful initial data load
    window.cline.callMcpFunction.mockResolvedValueOnce(JSON.stringify(mockDashboardData));

    // Mock successful setting update
    window.cline.callMcpFunction.mockResolvedValueOnce('Setting updated successfully');

    // Mock successful data refresh after setting update
    window.cline.callMcpFunction.mockResolvedValueOnce(JSON.stringify({
      ...mockDashboardData,
      settings: { ...mockDashboardData.settings, autoModelSelection: false }
    }));

    // Render the hook
    const { result, waitForNextUpdate } = renderHook(() => useMagicMcpDashboard());

    // Wait for initial data load
    await waitForNextUpdate();

    // Call updateSetting
    let success;
    await act(async () => {
      success = await result.current.updateSetting('autoModelSelection', false);
    });

    // Verify success and MCP calls
    expect(success).toBe(true);
    expect(window.cline.callMcpFunction).toHaveBeenCalledWith({
      serverName: 'cline-dashboard',
      toolName: 'update_setting',
      args: {
        setting: 'autoModelSelection',
        value: false
      }
    });
  });

  it('should reject invalid settings', async () => {
    // Mock successful initial data load
    window.cline.callMcpFunction.mockResolvedValueOnce(JSON.stringify(mockDashboardData));

    // Render the hook
    const { result, waitForNextUpdate } = renderHook(() => useMagicMcpDashboard());

    // Wait for initial data load
    await waitForNextUpdate();

    // Call updateSetting with invalid setting
    let success;
    await act(async () => {
      success = await result.current.updateSetting('invalidSetting', true);
    });

    // Verify rejection without calling MCP
    expect(success).toBe(false);
    expect(result.current.error).toBe('Invalid setting: invalidSetting');
    expect(window.cline.callMcpFunction).toHaveBeenCalledTimes(1); // Only the initial data load call
  });

  it('should update token budgets', async () => {
    // Mock successful initial data load
    window.cline.callMcpFunction.mockResolvedValueOnce(JSON.stringify(mockDashboardData));

    // Mock successful budget update
    window.cline.callMcpFunction.mockResolvedValueOnce('Budget updated successfully');

    // Mock successful data refresh after budget update
    const updatedData = {
      ...mockDashboardData,
      tokenBudgets: {
        ...mockDashboardData.tokenBudgets,
        codeCompletion: { used: 150, budget: 500 }
      }
    };
    window.cline.callMcpFunction.mockResolvedValueOnce(JSON.stringify(updatedData));

    // Render the hook
    const { result, waitForNextUpdate } = renderHook(() => useMagicMcpDashboard());

    // Wait for initial data load
    await waitForNextUpdate();

    // Call updateTokenBudget
    let success;
    await act(async () => {
      success = await result.current.updateTokenBudget('codeCompletion', 500);
    });

    // Verify success and MCP calls
    expect(success).toBe(true);
    expect(window.cline.callMcpFunction).toHaveBeenCalledWith({
      serverName: 'cline-dashboard',
      toolName: 'update_token_budget',
      args: {
        budgetType: 'codeCompletion',
        value: 500
      }
    });
  });

  it('should enforce budget constraints', async () => {
    // Mock successful initial data load
    window.cline.callMcpFunction.mockResolvedValueOnce(JSON.stringify(mockDashboardData));

    // Render the hook
    const { result, waitForNextUpdate } = renderHook(() => useMagicMcpDashboard());

    // Wait for initial data load
    await waitForNextUpdate();

    // Call updateTokenBudget with too large value
    let success;
    await act(async () => {
      success = await result.current.updateTokenBudget('codeCompletion', 10000);
    });

    // Verify rejection without calling MCP
    expect(success).toBe(false);
    expect(result.current.error).toBe('Invalid budget value for codeCompletion. Must be between 100 and 1000');
    expect(window.cline.callMcpFunction).toHaveBeenCalledTimes(1); // Only the initial data load call
  });

  it('should refresh dashboard data', async () => {
    // Mock successful initial data load
    window.cline.callMcpFunction.mockResolvedValueOnce(JSON.stringify(mockDashboardData));

    // Mock successful refresh request
    window.cline.callMcpFunction.mockResolvedValueOnce('Data refreshed successfully');

    // Mock successful data fetch after refresh
    const updatedData = {
      ...mockDashboardData,
      activeRequests: 2, // Changed value to verify refresh
      systemHealth: 'warning' // Changed value to verify refresh
    };
    window.cline.callMcpFunction.mockResolvedValueOnce(JSON.stringify(updatedData));

    // Render the hook
    const { result, waitForNextUpdate } = renderHook(() => useMagicMcpDashboard());

    // Wait for initial data load
    await waitForNextUpdate();

    // Call refreshData
    let success;
    await act(async () => {
      success = await result.current.refreshData();
    });

    // Verify success and MCP calls
    expect(success).toBe(true);
    expect(window.cline.callMcpFunction).toHaveBeenCalledWith({
      serverName: 'cline-dashboard',
      toolName: 'update_dashboard_data',
      args: {}
    });

    // Verify data was updated with the new values
    expect(result.current.data.activeRequests).toBe(2);
    expect(result.current.data.systemHealth).toBe('warning');
  });
});
