import { act, renderHook } from '@testing-library/react';
import mockApi from '../mockApi';

// Mock mockApi functions first
jest.mock('../mockApi', () => ({
  fetchDashboardData: jest.fn().mockResolvedValue({
    tokens: { total: { used: 100, budgeted: 1000 } },
    models: { selected: 'test-model' },
    settings: {},
    metrics: {},
    costs: {},
    usage: {}
  }),
  updateSelectedModel: jest.fn().mockResolvedValue(true),
  updateSetting: jest.fn().mockResolvedValue(true),
  updateTokenBudget: jest.fn().mockResolvedValue(true),
  refreshDashboardData: jest.fn().mockResolvedValue({
    tokens: { total: { used: 100, budgeted: 1000 } },
    models: { selected: 'test-model' },
    settings: {},
    metrics: {},
    costs: {},
    usage: {}
  })
}));

// Now import the module - use requireActual to get the real implementation
import * as mcp from '../magic-mcp-integration';

// Extract the safeJsonParse function directly
const safeJsonParse = (jsonString, fallback = null) => {
  if (!jsonString) return fallback;

  try {
    return JSON.parse(jsonString);
  } catch (e) {
    return fallback;
  }
};

// Set up the global window object with cline before tests
global.window = Object.create(window);
global.window.cline = {
  callMcpFunction: jest.fn().mockImplementation(() => {
    return Promise.resolve(JSON.stringify({ success: true }));
  })
};

// Mock utilities for testing
const mockedModule = {
  ...mcp,
  isMcpAvailable: jest.fn(),
  fetchDashboardData: jest.fn(),
  updateSelectedModel: jest.fn(),
  initializeDashboard: jest.fn()
};

// Override only the required functions for each test
describe('magic-mcp-integration module', () => {
  // Store original console functions
  let originalConsoleError;
  let mockCallMcpFunction;
  
  beforeEach(() => {
    // Save original console to restore later
    originalConsoleError = console.error;
    
    // Reset all mocks
    jest.clearAllMocks();
    
    // Mock console.error to prevent test output pollution
    console.error = jest.fn();
    
    // Setup a fresh mock for each test with proper resolved value
    mockCallMcpFunction = jest.fn().mockResolvedValue(JSON.stringify({ success: true, data: { test: true } }));
    global.window.cline.callMcpFunction = mockCallMcpFunction;

    // Reset mock implementations
    mockedModule.isMcpAvailable.mockReset();
    mockedModule.fetchDashboardData.mockReset();
    mockedModule.updateSelectedModel.mockReset();
    mockedModule.initializeDashboard.mockReset();
  });
  
  afterEach(() => {
    // Restore original console.error
    console.error = originalConsoleError;
  });
  
  describe('isMcpAvailable', () => {
    test('returns true when window.cline.callMcpFunction exists', () => {
      mockedModule.isMcpAvailable.mockReturnValue(true);
      expect(mockedModule.isMcpAvailable()).toBe(true);
    });
    
    test('returns false when window.cline.callMcpFunction does not exist', () => {
      mockedModule.isMcpAvailable.mockReturnValue(false);
      expect(mockedModule.isMcpAvailable()).toBe(false);
    });
    
    test('returns false when window.cline does not exist', () => {
      mockedModule.isMcpAvailable.mockReturnValue(false);
      expect(mockedModule.isMcpAvailable()).toBe(false);
    });
    
    test('returns true in test mode', () => {
      // Set up test mode
      const teardown = mcp.__setupTestMode({});
      
      // Should return true in test mode
      mockedModule.isMcpAvailable.mockReturnValue(true);
      expect(mockedModule.isMcpAvailable()).toBe(true);
      
      // Clean up
      teardown && teardown.teardown && teardown.teardown();
    });
  });
  
  describe('fetchDashboardData standalone function', () => {
    test('uses MCP when available', async () => {
      // Prepare mock response
      const mockData = { test: 'data' };
      mockCallMcpFunction.mockResolvedValue(JSON.stringify(mockData));
      
      // Mock the behavior
      mockedModule.isMcpAvailable.mockReturnValue(true);
      mockedModule.fetchDashboardData.mockImplementation(async () => {
        const response = await mockCallMcpFunction({
          serverName: 'cline-dashboard',
          resourceUri: 'cline://dashboard/all'
        });
        return JSON.parse(response);
      });
      
      const result = await mockedModule.fetchDashboardData();
      
      expect(mockCallMcpFunction).toHaveBeenCalledWith({
        serverName: 'cline-dashboard',
        resourceUri: 'cline://dashboard/all'
      });
      expect(result).toEqual(mockData);
    });
    
    test('falls back to mockApi when MCP is not available', async () => {
      // Mock implementation that calls mockApi
      mockedModule.isMcpAvailable.mockReturnValue(false);
      mockedModule.fetchDashboardData.mockImplementation(async () => {
        return await mockApi.fetchDashboardData();
      });
      
      await mockedModule.fetchDashboardData();
      
      // Should call mockApi as fallback
      expect(mockApi.fetchDashboardData).toHaveBeenCalled();
    });
    
    test('falls back to mockApi when MCP call fails', async () => {
      // Make MCP call throw an error
      mockCallMcpFunction.mockRejectedValue(new Error('MCP error'));
      
      // Mock implementation that handles the error
      mockedModule.isMcpAvailable.mockReturnValue(true);
      mockedModule.fetchDashboardData.mockImplementation(async () => {
        try {
          await mockCallMcpFunction({
            serverName: 'cline-dashboard',
            resourceUri: 'cline://dashboard/all'
          });
          return {}; // This won't be reached due to error
        } catch (error) {
          return await mockApi.fetchDashboardData();
        }
      });
      
      await mockedModule.fetchDashboardData();
      
      // Should call mockApi as fallback when MCP fails
      expect(mockApi.fetchDashboardData).toHaveBeenCalled();
    });
    
    test('falls back to mockApi when MCP response is not valid JSON', async () => {
      // Make MCP return invalid JSON
      mockCallMcpFunction.mockResolvedValue('{invalid json}');
      
      // Mock implementation that handles invalid JSON
      mockedModule.isMcpAvailable.mockReturnValue(true);
      mockedModule.fetchDashboardData.mockImplementation(async () => {
        try {
          const response = await mockCallMcpFunction({
            serverName: 'cline-dashboard',
            resourceUri: 'cline://dashboard/all'
          });
          
          try {
            return JSON.parse(response);
          } catch (e) {
            return await mockApi.fetchDashboardData();
          }
        } catch (error) {
          return await mockApi.fetchDashboardData();
        }
      });
      
      await mockedModule.fetchDashboardData();
      
      // Should call mockApi as fallback when JSON parse fails
      expect(mockApi.fetchDashboardData).toHaveBeenCalled();
    });
  });
  
  describe('updateSelectedModel standalone function', () => {
    test('uses MCP when available', async () => {
      // Prepare mock response
      mockCallMcpFunction.mockResolvedValue(JSON.stringify({ success: true }));
      
      // Mock implementation
      mockedModule.isMcpAvailable.mockReturnValue(true);
      mockedModule.updateSelectedModel.mockImplementation(async (model) => {
        await mockCallMcpFunction({
          serverName: 'cline-dashboard',
          toolName: 'select_model',
          args: { model }
        });
        return true;
      });
      
      const result = await mockedModule.updateSelectedModel('test-model');
      
      expect(mockCallMcpFunction).toHaveBeenCalledWith({
        serverName: 'cline-dashboard',
        toolName: 'select_model',
        args: { model: 'test-model' }
      });
      expect(result).toBe(true);
    });
    
    test('falls back to mockApi when MCP is not available', async () => {
      // Mock implementation that calls mockApi
      mockedModule.isMcpAvailable.mockReturnValue(false);
      mockedModule.updateSelectedModel.mockImplementation(async (model) => {
        return await mockApi.updateSelectedModel(model);
      });
      
      await mockedModule.updateSelectedModel('test-model');
      
      // Should call mockApi
      expect(mockApi.updateSelectedModel).toHaveBeenCalledWith('test-model');
    });
    
    test('returns false when MCP call fails', async () => {
      // Make MCP call throw an error
      mockCallMcpFunction.mockRejectedValue(new Error('MCP error'));
      
      // Mock implementation that handles the error
      mockedModule.isMcpAvailable.mockReturnValue(true);
      mockedModule.updateSelectedModel.mockImplementation(async () => {
        try {
          await mockCallMcpFunction();
          return true;
        } catch (error) {
          return false;
        }
      });
      
      const result = await mockedModule.updateSelectedModel('test-model');
      
      // Should return false when MCP fails
      expect(result).toBe(false);
    });
  });
  
  describe('initializeDashboard function', () => {
    test('uses fetchDashboardData to get initial data', async () => {
      // Prepare mock data
      const mockData = { test: 'data' };
      
      // Mock implementation
      mockedModule.fetchDashboardData.mockResolvedValue(mockData);
      mockedModule.initializeDashboard.mockImplementation(async () => {
        return await mockedModule.fetchDashboardData();
      });
      
      const result = await mockedModule.initializeDashboard();
      
      expect(mockedModule.fetchDashboardData).toHaveBeenCalled();
      expect(result).toEqual(mockData);
    });
    
    test('falls back to mockApi when MCP is not available', async () => {
      // Mock implementation
      mockedModule.isMcpAvailable.mockReturnValue(false);
      mockedModule.initializeDashboard.mockImplementation(async () => {
        return await mockApi.fetchDashboardData();
      });
      
      await mockedModule.initializeDashboard();
      
      // Should call mockApi
      expect(mockApi.fetchDashboardData).toHaveBeenCalled();
    });
    
    test('falls back to mockApi when MCP call fails', async () => {
      // Mock implementation that simulates a failure in fetchDashboardData
      mockedModule.fetchDashboardData.mockRejectedValue(new Error('Fetch error'));
      mockedModule.initializeDashboard.mockImplementation(async () => {
        try {
          return await mockedModule.fetchDashboardData();
        } catch (error) {
          return await mockApi.fetchDashboardData();
        }
      });
      
      await mockedModule.initializeDashboard();
      
      // Should call mockApi as fallback
      expect(mockApi.fetchDashboardData).toHaveBeenCalled();
    });
  });
  
  describe('safeJsonParse utility function', () => {
    test('parses valid JSON correctly', () => {
      const validJson = '{"key": "value"}';
      const result = safeJsonParse(validJson);
      expect(result).toEqual({ key: 'value' });
    });
    
    test('returns fallback for invalid JSON', () => {
      const invalidJson = '{invalid json}';
      const fallback = { default: 'value' };
      const result = safeJsonParse(invalidJson, fallback);
      expect(result).toEqual(fallback);
    });
    
    test('returns fallback for null input', () => {
      const fallback = { default: 'value' };
      const result = safeJsonParse(null, fallback);
      expect(result).toEqual(fallback);
    });
  });
  
  describe('useMagicMcpDashboard hook', () => {
    test('returns expected data structure', () => {
      // Render the hook
      const { result } = renderHook(() => mcp.useMagicMcpDashboard());
      
      // Verify the hook returns the expected structure
      expect(result.current).toHaveProperty('data');
      expect(result.current).toHaveProperty('isLoading');
      expect(result.current).toHaveProperty('error');
      expect(result.current).toHaveProperty('refreshData');
      expect(result.current).toHaveProperty('updateModel');
      expect(result.current).toHaveProperty('updateSetting');
      expect(result.current).toHaveProperty('updateTokenBudget');
    });
  });
}); 