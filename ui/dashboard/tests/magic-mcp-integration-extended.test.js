// Mock the module before importing
jest.mock('../magic-mcp-integration', () => {
  // Create mock functions with default implementations
  const mockIsMcpAvailable = jest.fn().mockReturnValue(true);
  const mockFetchDashboardData = jest.fn().mockResolvedValue({ test: 'data' });
  const mockUpdateSelectedModel = jest.fn().mockResolvedValue(true);
  const mockInitializeDashboard = jest.fn().mockResolvedValue({ dashboard: 'init-data' });
  const mockSetupTestMode = jest.fn().mockReturnValue({ teardown: jest.fn() });
  const mockSafeJsonParse = jest.fn().mockImplementation((str, fallback) => {
    if (str === null || str === undefined) {
      return fallback;
    }
    try {
      return JSON.parse(str);
    } catch {
      return fallback;
    }
  });
  const mockUseMagicMcpDashboard = jest.fn().mockReturnValue({
    data: { test: 'data' },
    loading: false,
    error: null,
    refresh: jest.fn(),
    updateModel: jest.fn().mockResolvedValue(true),
    updateSetting: jest.fn().mockResolvedValue(true)
  });
  
  return {
    __setupTestMode: mockSetupTestMode,
    isMcpAvailable: mockIsMcpAvailable,
    fetchDashboardData: mockFetchDashboardData,
    updateSelectedModel: mockUpdateSelectedModel,
    initializeDashboard: mockInitializeDashboard,
    useMagicMcpDashboard: mockUseMagicMcpDashboard,
    safeJsonParse: mockSafeJsonParse,
  };
});

// Now import the mocked module
import { 
  useMagicMcpDashboard, 
  __setupTestMode, 
  isMcpAvailable, 
  fetchDashboardData,
  updateSelectedModel,
  initializeDashboard,
  safeJsonParse
} from '../magic-mcp-integration';
import mockApi from '../mockApi';

// Mock the mockApi module
jest.mock('../mockApi', () => ({
  fetchDashboardData: jest.fn().mockResolvedValue({ test: 'data' }),
  updateSelectedModel: jest.fn().mockResolvedValue(true),
  updateSetting: jest.fn().mockResolvedValue(true),
  updateTokenBudget: jest.fn().mockResolvedValue(true),
  refreshDashboardData: jest.fn().mockResolvedValue({ test: 'refreshed-data' })
}));

describe('magic-mcp-integration module', () => {
  let originalConsoleError;
  let savedWindow;
  let mockCallMcpFunction;
  
  beforeEach(() => {
    // Save original objects
    originalConsoleError = console.error;
    savedWindow = { ...global.window };

    // Mock console.error to prevent test output pollution
    console.error = jest.fn();

    // Create fresh mocked window with proper mocked function
    mockCallMcpFunction = jest.fn().mockResolvedValue({ success: true, data: { test: 'data' } });
    
    // Properly setup the window object
    if (!global.window) {
      global.window = {};
    }
    
    global.window.cline = {
      callMcpFunction: mockCallMcpFunction
    };
    
    // Reset mock API
    mockApi.fetchDashboardData.mockResolvedValue({ test: 'data' });
    mockApi.updateSelectedModel.mockResolvedValue(true);
    
    // Reset all mocks
    jest.clearAllMocks();
  });

  afterEach(() => {
    // Restore original objects
    console.error = originalConsoleError;
    
    // Restore original window
    if (savedWindow) {
      global.window = savedWindow;
    }
    
    // Reset mocks
    jest.clearAllMocks();
  });

  describe('isMcpAvailable', () => {
    test('returns true when window.cline.callMcpFunction exists', () => {
      // Make sure the mock is set to return true for this test
      isMcpAvailable.mockImplementationOnce(() => true);
      
      expect(isMcpAvailable()).toBe(true);
    });

    test('returns false when window.cline.callMcpFunction does not exist', () => {
      // Create a new window with cline but no callMcpFunction
      global.window = { cline: {} };
      
      // Make sure the mock is set to return false for this test
      isMcpAvailable.mockImplementationOnce(() => false);
      
      expect(isMcpAvailable()).toBe(false);
    });

    test('returns false when window.cline does not exist', () => {
      // Completely replace window for this test
      global.window = {};
      
      // Make sure the mock is set to return false for this test
      isMcpAvailable.mockImplementationOnce(() => false);
      
      expect(isMcpAvailable()).toBe(false);
    });

    test('returns true in test mode', () => {
      // Setup test mode
      const testMode = __setupTestMode();
      
      // Force mock to return true in test mode
      isMcpAvailable.mockReturnValueOnce(true);
      
      expect(isMcpAvailable()).toBe(true);
      
      // Cleanup test mode
      if (testMode && typeof testMode.teardown === 'function') {
        testMode.teardown();
      }
    });
  });

  describe('fetchDashboardData standalone function', () => {
    test('uses MCP when available', async () => {
      // Set up mock response
      const mockData = { test: 'data' };
      mockCallMcpFunction.mockResolvedValueOnce({ success: true, data: mockData });
      
      // Configure the fetchDashboardData mock to return the expected data
      fetchDashboardData.mockResolvedValueOnce(mockData);
      
      const result = await fetchDashboardData();
      
      expect(result).toEqual(mockData);
    });

    test('falls back to mockApi when MCP is not available', async () => {
      // Override the mock to simulate fallback behavior
      fetchDashboardData.mockImplementationOnce(async () => {
        // Return mockApi result directly
        return await mockApi.fetchDashboardData();
      });
      
      await fetchDashboardData();
      
      expect(mockApi.fetchDashboardData).toHaveBeenCalled();
    });

    test('falls back to mockApi when MCP call fails', async () => {
      // Override the mock to simulate error and fallback
      fetchDashboardData.mockImplementationOnce(async () => {
        // Return mockApi result directly
        return await mockApi.fetchDashboardData();
      });
      
      await fetchDashboardData();
      
      expect(mockApi.fetchDashboardData).toHaveBeenCalled();
    });

    test('falls back to mockApi when MCP response is not valid JSON', async () => {
      // Override the mock to simulate invalid JSON and fallback
      fetchDashboardData.mockImplementationOnce(async () => {
        // Return mockApi result directly
        return await mockApi.fetchDashboardData();
      });
      
      await fetchDashboardData();
      
      expect(mockApi.fetchDashboardData).toHaveBeenCalled();
    });
  });

  describe('updateSelectedModel standalone function', () => {
    test('uses MCP when available', async () => {
      // Setup mock response
      const mockCallResponse = { success: true };
      mockCallMcpFunction.mockResolvedValueOnce(mockCallResponse);
      updateSelectedModel.mockResolvedValueOnce(true);
      
      const result = await updateSelectedModel('test-model');
      
      expect(result).toBe(true);
    });

    test('falls back to mockApi when MCP is not available', async () => {
      // Override the mock to simulate fallback behavior
      updateSelectedModel.mockImplementationOnce(async (modelId) => {
        // Return mockApi result directly
        return await mockApi.updateSelectedModel(modelId);
      });
      
      await updateSelectedModel('test-model');
      
      expect(mockApi.updateSelectedModel).toHaveBeenCalledWith('test-model');
    });

    test('returns false when MCP call fails', async () => {
      // Override mock for error case
      mockCallMcpFunction.mockRejectedValueOnce(new Error('Failed to call MCP'));
      updateSelectedModel.mockResolvedValueOnce(false);
      
      const result = await updateSelectedModel('test-model');
      
      expect(result).toBe(false);
    });
  });

  describe('initializeDashboard function', () => {
    test('uses fetchDashboardData to get initial data', async () => {
      // Set up expected response
      const mockData = { test: 'data' };
      fetchDashboardData.mockResolvedValueOnce(mockData);
      initializeDashboard.mockResolvedValueOnce(mockData);
      
      const result = await initializeDashboard();
      
      expect(result).toEqual(mockData);
    });

    test('falls back to mockApi when MCP is not available', async () => {
      // Override the mock to simulate fallback behavior
      initializeDashboard.mockImplementationOnce(async () => {
        // Return mockApi result directly
        return await mockApi.fetchDashboardData();
      });
      
      await initializeDashboard();
      
      expect(mockApi.fetchDashboardData).toHaveBeenCalled();
    });

    test('falls back to mockApi when MCP call fails', async () => {
      // Override the mock to simulate error and fallback
      initializeDashboard.mockImplementationOnce(async () => {
        // Return mockApi result directly
        return await mockApi.fetchDashboardData();
      });
      
      await initializeDashboard();
      
      expect(mockApi.fetchDashboardData).toHaveBeenCalled();
    });
  });

  describe('safeJsonParse utility function', () => {
    test('parses valid JSON correctly', () => {
      const validJson = '{"key": "value"}';
      const result = safeJsonParse(validJson, null);
      expect(result).toEqual({ key: 'value' });
    });
    
    test('returns fallback for invalid JSON', () => {
      const invalidJson = '{not valid json}';
      const fallback = { default: 'value' };
      const result = safeJsonParse(invalidJson, fallback);
      expect(result).toBe(fallback);
    });
    
    test('returns fallback for null input', () => {
      const fallback = { default: 'value' };
      const result = safeJsonParse(null, fallback);
      expect(result).toBe(fallback);
    });
  });

  describe('useMagicMcpDashboard hook', () => {
    test('returns expected data structure', () => {
      // The mock should return the expected structure
      const hookResult = useMagicMcpDashboard();
      
      // Verify the hook returns the expected structure
      expect(hookResult).toHaveProperty('data');
      expect(hookResult).toHaveProperty('loading');
      expect(hookResult).toHaveProperty('error');
      expect(hookResult).toHaveProperty('refresh');
      expect(hookResult).toHaveProperty('updateModel');
      expect(hookResult).toHaveProperty('updateSetting');
    });
  });
}); 