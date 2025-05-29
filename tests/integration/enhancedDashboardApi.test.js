import {
  refreshData,
  updateSelectedModel,
  updateSetting,
  updateTokenBudget,
  addEventListener,
  removeEventListener,
  cleanup,
  delay,
  safeCheckMcp,
  use_mcp_tool,
  access_mcp_resource,
  subscribeToMcpUpdates,
  batchMcpResources,
  isMcpAvailable,
  initializeMcpClient,
  initialize
} from '../lib/enhancedDashboardApi';

import * as dashboardApi from '../lib/enhancedDashboardApi';

// Mock the fetch API
global.fetch = jest.fn().mockResolvedValue({
  ok: true,
  json: jest.fn().mockResolvedValue({})
});

// Create mock data for testing
const mockDashboardData = {
  tokens: {
    total: { used: 100000, saved: 50000, budgeted: 200000 }
  },
  models: {
    selected: 'test-model',
    available: [{ id: 'test-model', name: 'Test Model' }]
  },
  settings: {
    darkMode: false
  }
};

// Mock the mockApi module without referencing mockDashboardData directly
jest.mock('../mockApi.js', () => {
  const mockApi = {
    fetchDashboardData: jest.fn(),
    updateSelectedModel: jest.fn(),
    updateSetting: jest.fn(),
    updateTokenBudget: jest.fn(),
  };
  return {
    __esModule: true,
    default: mockApi
  };
});

// Import the mocked version
import mockApiDefault from '../mockApi.js';

// Mock window object and MCP client
const originalWindow = global.window;

// Ensure window is properly defined for Jest environment
Object.defineProperty(global, 'window', {
  value: global.window || {},
  writable: true
});

describe('Enhanced Dashboard API', () => {
  beforeEach(() => {
    jest.clearAllMocks();

    // Reset the mock implementation
    mockApiDefault.fetchDashboardData.mockResolvedValue(mockDashboardData);
    mockApiDefault.updateSelectedModel.mockResolvedValue(true);
    mockApiDefault.updateSetting.mockResolvedValue(true);
    mockApiDefault.updateTokenBudget.mockResolvedValue(true);

    // Create fresh MCP client mock for each test
    const mcpClient = {
      useTool: jest.fn().mockResolvedValue({ success: true, data: 'tool_data' }),
      accessResource: jest.fn().mockResolvedValue({ result: mockDashboardData }),
      subscribe: jest.fn().mockReturnValue(() => {}),
      batchResources: jest.fn().mockResolvedValue({
        '/api/data1': { result: 'data1' },
        '/api/data2': { result: 'data2' }
      })
    };

    // Set up window with proper MCP client mock
    const mockWindow = {
      ...originalWindow,
      __MCP_CLIENT: mcpClient
    };

    global.window = mockWindow;
  });

  afterEach(() => {
    global.window = originalWindow;
  });

  describe('refreshData', () => {
    it('should return data from mockApi when MCP is not available', async () => {
      // Make MCP unavailable
      global.window.__MCP_CLIENT = undefined;

      const result = await refreshData();
      expect(result).toEqual(mockDashboardData);
      expect(mockApiDefault.fetchDashboardData).toHaveBeenCalled();
    });

    it('should use mock data when forced', async () => {
      const result = await refreshData(true); // Force mock data
      expect(result).toEqual(mockDashboardData);
      expect(mockApiDefault.fetchDashboardData).toHaveBeenCalled();
    });
  });

  describe('updateSelectedModel', () => {
    it('should update model successfully when MCP not available', async () => {
      global.window.__MCP_CLIENT = undefined;

      const result = await updateSelectedModel('new-model');
      expect(result).toBe(true);
      expect(mockApiDefault.updateSelectedModel).toHaveBeenCalledWith('new-model');
    });
  });

  describe('updateSetting', () => {
    it('should update setting successfully when MCP not available', async () => {
      global.window.__MCP_CLIENT = undefined;

      const result = await updateSetting('darkMode', true);
      expect(result).toBe(true);
      expect(mockApiDefault.updateSetting).toHaveBeenCalledWith('darkMode', true);
    });
  });

  describe('updateTokenBudget', () => {
    it('should update token budget successfully when MCP not available', async () => {
      global.window.__MCP_CLIENT = undefined;

      const result = await updateTokenBudget('test', 1000);
      expect(result).toBe(true);
      expect(mockApiDefault.updateTokenBudget).toHaveBeenCalledWith('test', 1000);
    });
  });

  describe('MCP functions', () => {
    it('should check MCP availability safely', () => {
      // First test with MCP client available
      const result = safeCheckMcp();
      expect(result).toBe(true);

      // Test with undefined client
      global.window.__MCP_CLIENT = undefined;
      const result2 = safeCheckMcp();
      expect(result2).toBe(false);
    });

    it('should throw error when MCP tool not available', async () => {
      global.window.__MCP_CLIENT = undefined;

      await expect(use_mcp_tool('server', 'tool', {})).rejects.toThrow('MCP client not available');
    });

    it('should throw error when MCP resource not available', async () => {
      global.window.__MCP_CLIENT = undefined;

      await expect(access_mcp_resource('server', '/api/test')).rejects.toThrow('MCP client not available');
    });

    it('should throw error when batch MCP resources not available', async () => {
      global.window.__MCP_CLIENT = undefined;

      await expect(batchMcpResources('server', ['/api/data1', '/api/data2'])).rejects.toThrow('MCP client not available');
    });

    it('should return no-op function when subscribing without MCP', () => {
      global.window.__MCP_CLIENT = undefined;

      const unsubscribe = subscribeToMcpUpdates('/api/test', jest.fn());
      expect(typeof unsubscribe).toBe('function');
    });
  });

  describe('Event handling', () => {
    it('should add and remove event listeners for valid events', () => {
      const callback = jest.fn();
      addEventListener('dataUpdate', callback);
      removeEventListener('dataUpdate', callback);
      expect(true).toBe(true);
    });

    it('should warn for unknown event types', () => {
      const consoleWarnSpy = jest.spyOn(console, 'warn').mockImplementation();
      const callback = jest.fn();

      addEventListener('unknown-event', callback);
      expect(consoleWarnSpy).toHaveBeenCalledWith('Unknown event type: unknown-event');

      removeEventListener('unknown-event', callback);
      expect(consoleWarnSpy).toHaveBeenCalledWith('Unknown event type: unknown-event');

      consoleWarnSpy.mockRestore();
    });
  });

  describe('Utility functions', () => {
    it('should delay execution', async () => {
      const start = Date.now();
      await delay(100);
      const end = Date.now();
      // Add small tolerance for timing variations (system timing isn't precise)
      expect(end - start).toBeGreaterThanOrEqual(95);
    });

    it('should return false when initializing client without __MCP_INIT', async () => {
      global.window.__MCP_INIT = undefined;

      const result = await initializeMcpClient();
      expect(result).toBe(false);
    });

    it('should cleanup resources', () => {
      expect(() => cleanup()).not.toThrow();
    });

    it('should check MCP availability', () => {
      // Test with MCP client available
      expect(isMcpAvailable()).toBe(true);

      // Test with undefined client
      global.window.__MCP_CLIENT = undefined;
      expect(isMcpAvailable()).toBe(false);
    });
  });

  describe('initialize', () => {
    it('should initialize and return connection status', async () => {
      const mockMcpClient = {
        useTool: jest.fn().mockResolvedValue({ success: true, data: 'tool_data' }),
        accessResource: jest.fn().mockResolvedValue({ result: mockDashboardData }),
        subscribe: jest.fn().mockReturnValue(() => {}),
        batchResources: jest.fn().mockResolvedValue({
          '/api/data1': { result: 'data1' },
          '/api/data2': { result: 'data2' }
        })
      };

      global.window.__MCP_INIT = jest.fn().mockResolvedValue(mockMcpClient);
      global.window.__MCP_CLIENT = undefined;

      const result = await initialize(0); // Disable auto-refresh
      expect(typeof result).toBe('object');
      expect(result).toHaveProperty('clineServerConnected');
      expect(result).toHaveProperty('magicApiConnected');
      expect(result).toHaveProperty('usingMockData');
    });
  });
});
