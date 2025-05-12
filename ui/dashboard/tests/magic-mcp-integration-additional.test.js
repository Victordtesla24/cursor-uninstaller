/**
 * Additional test coverage for magic-mcp-integration module
 * Tests standalone functions and MCP integrations
 */
const magicMcpIntegration = require('../magic-mcp-integration');
const mockApi = require('../mockApi');

// Mock the mockApi functions
jest.mock('../mockApi', () => ({
  fetchDashboardData: jest.fn().mockResolvedValue({ test: 'mock-data' }),
  updateSelectedModel: jest.fn().mockResolvedValue(true),
  updateSetting: jest.fn().mockResolvedValue(true),
  updateTokenBudget: jest.fn().mockResolvedValue(true),
  refreshDashboardData: jest.fn().mockResolvedValue({ test: 'mock-refreshed-data' })
}));

describe('Magic MCP Integration Additional Coverage Tests', () => {
  let originalWindow;

  beforeEach(() => {
    // Create window object if it doesn't exist
    if (typeof global.window === 'undefined') {
      global.window = {};
    }

    // Backup original window
    originalWindow = { ...global.window };

    // Create cline object with mock function
    global.window.cline = {
      callMcpFunction: jest.fn().mockImplementation(() => {
        return JSON.stringify({ success: true, data: { test: 'mcp-data' } });
      })
    };

    jest.clearAllMocks();
  });

  afterEach(() => {
    // Restore original window
    global.window = originalWindow;
    jest.restoreAllMocks();
  });

  describe('refreshDashboardData function', () => {
    test('uses MCP when available', async () => {
      // Mock isMcpAvailable to return true
      jest.spyOn(magicMcpIntegration, 'isMcpAvailable').mockReturnValue(true);

      const result = await magicMcpIntegration.refreshDashboardData();

      expect(global.window.cline.callMcpFunction).toHaveBeenCalledTimes(1);
      expect(mockApi.refreshDashboardData).not.toHaveBeenCalled();
      expect(result).toEqual({ success: true, data: { test: 'mcp-data' } });
    });

    test('falls back to mockApi when MCP is unavailable', async () => {
      // Mock isMcpAvailable to return false
      jest.spyOn(magicMcpIntegration, 'isMcpAvailable').mockReturnValue(false);

      // Remove window.cline to simulate unavailability
      delete global.window.cline;

      const result = await magicMcpIntegration.refreshDashboardData();

      expect(mockApi.refreshDashboardData).toHaveBeenCalledTimes(1);
      expect(result).toEqual({ test: 'mock-refreshed-data' });
    });

    test('falls back to mockApi when MCP fails', async () => {
      // Mock isMcpAvailable to return true
      jest.spyOn(magicMcpIntegration, 'isMcpAvailable').mockReturnValue(true);

      // Make callMcpFunction throw an error
      global.window.cline.callMcpFunction.mockImplementation(() => {
        throw new Error('MCP error');
      });

      const result = await magicMcpIntegration.refreshDashboardData();

      expect(global.window.cline.callMcpFunction).toHaveBeenCalledTimes(1);
      expect(mockApi.refreshDashboardData).toHaveBeenCalledTimes(1);
      expect(result).toEqual({ test: 'mock-refreshed-data' });
    });
  });

  describe('updateSetting function', () => {
    test('uses MCP when available', async () => {
      // Mock isMcpAvailable to return true
      jest.spyOn(magicMcpIntegration, 'isMcpAvailable').mockReturnValue(true);

      const result = await magicMcpIntegration.updateSetting('autoModelSelection', true);

      expect(global.window.cline.callMcpFunction).toHaveBeenCalledTimes(1);
      expect(global.window.cline.callMcpFunction).toHaveBeenCalledWith({
        serverName: 'cline-dashboard',
        toolName: 'update_setting',
        args: {
          setting: 'autoModelSelection',
          value: true
        }
      });
      expect(mockApi.updateSetting).not.toHaveBeenCalled();
      expect(result).toBe(true);
    });

    test('falls back to mockApi when MCP is unavailable', async () => {
      // Mock isMcpAvailable to return false
      jest.spyOn(magicMcpIntegration, 'isMcpAvailable').mockReturnValue(false);

      // Remove window.cline to simulate unavailability
      delete global.window.cline;

      const result = await magicMcpIntegration.updateSetting('autoModelSelection', true);

      expect(mockApi.updateSetting).toHaveBeenCalledTimes(1);
      expect(mockApi.updateSetting).toHaveBeenCalledWith('autoModelSelection', true);
      expect(result).toBe(true);
    });

    test('returns false when MCP fails', async () => {
      // Mock isMcpAvailable to return true
      jest.spyOn(magicMcpIntegration, 'isMcpAvailable').mockReturnValue(true);

      // Make callMcpFunction throw an error
      global.window.cline.callMcpFunction.mockImplementation(() => {
        throw new Error('MCP error');
      });

      const result = await magicMcpIntegration.updateSetting('autoModelSelection', true);

      expect(global.window.cline.callMcpFunction).toHaveBeenCalledTimes(1);
      expect(result).toBe(false);
    });
  });

  describe('updateTokenBudget function', () => {
    test('uses MCP when available', async () => {
      // Mock isMcpAvailable to return true
      jest.spyOn(magicMcpIntegration, 'isMcpAvailable').mockReturnValue(true);

      const result = await magicMcpIntegration.updateTokenBudget('codeCompletion', 500);

      expect(global.window.cline.callMcpFunction).toHaveBeenCalledTimes(1);
      expect(global.window.cline.callMcpFunction).toHaveBeenCalledWith({
        serverName: 'cline-dashboard',
        toolName: 'update_token_budget',
        args: {
          budgetType: 'codeCompletion',
          value: 500
        }
      });
      expect(mockApi.updateTokenBudget).not.toHaveBeenCalled();
      expect(result).toBe(true);
    });

    test('falls back to mockApi when MCP is unavailable', async () => {
      // Mock isMcpAvailable to return false
      jest.spyOn(magicMcpIntegration, 'isMcpAvailable').mockReturnValue(false);

      // Remove window.cline to simulate unavailability
      delete global.window.cline;

      const result = await magicMcpIntegration.updateTokenBudget('codeCompletion', 500);

      expect(mockApi.updateTokenBudget).toHaveBeenCalledTimes(1);
      expect(mockApi.updateTokenBudget).toHaveBeenCalledWith('codeCompletion', 500);
      expect(result).toBe(true);
    });

    test('returns false when MCP fails', async () => {
      // Mock isMcpAvailable to return true
      jest.spyOn(magicMcpIntegration, 'isMcpAvailable').mockReturnValue(true);

      // Make callMcpFunction throw an error
      global.window.cline.callMcpFunction.mockImplementation(() => {
        throw new Error('MCP error');
      });

      const result = await magicMcpIntegration.updateTokenBudget('codeCompletion', 500);

      expect(global.window.cline.callMcpFunction).toHaveBeenCalledTimes(1);
      expect(result).toBe(false);
    });
  });

  describe('fetchDashboardData function', () => {
    test('uses MCP when available', async () => {
      // Mock isMcpAvailable to return true
      jest.spyOn(magicMcpIntegration, 'isMcpAvailable').mockReturnValue(true);

      const result = await magicMcpIntegration.fetchDashboardData();

      expect(global.window.cline.callMcpFunction).toHaveBeenCalledTimes(1);
      expect(mockApi.fetchDashboardData).not.toHaveBeenCalled();
      expect(result).toEqual({ success: true, data: { test: 'mcp-data' } });
    });

    test('falls back to mockApi when MCP is unavailable', async () => {
      // Mock isMcpAvailable to return false
      jest.spyOn(magicMcpIntegration, 'isMcpAvailable').mockReturnValue(false);

      // Remove window.cline to simulate unavailability
      delete global.window.cline;

      const result = await magicMcpIntegration.fetchDashboardData();

      expect(mockApi.fetchDashboardData).toHaveBeenCalledTimes(1);
      expect(result).toEqual({ test: 'mock-data' });
    });

    test('falls back to mockApi when MCP fails', async () => {
      // Mock isMcpAvailable to return true
      jest.spyOn(magicMcpIntegration, 'isMcpAvailable').mockReturnValue(true);

      // Make callMcpFunction throw an error
      global.window.cline.callMcpFunction.mockImplementation(() => {
        throw new Error('MCP error');
      });

      const result = await magicMcpIntegration.fetchDashboardData();

      expect(global.window.cline.callMcpFunction).toHaveBeenCalledTimes(1);
      expect(mockApi.fetchDashboardData).toHaveBeenCalledTimes(1);
      expect(result).toEqual({ test: 'mock-data' });
    });
  });

  describe('updateSelectedModel function', () => {
    test('uses MCP when available', async () => {
      // Mock isMcpAvailable to return true
      jest.spyOn(magicMcpIntegration, 'isMcpAvailable').mockReturnValue(true);

      const result = await magicMcpIntegration.updateSelectedModel('claude-3-opus');

      expect(global.window.cline.callMcpFunction).toHaveBeenCalledTimes(1);
      expect(mockApi.updateSelectedModel).not.toHaveBeenCalled();
      expect(result).toBe(true);
    });

    test('falls back to mockApi when MCP is unavailable', async () => {
      // Mock isMcpAvailable to return false
      jest.spyOn(magicMcpIntegration, 'isMcpAvailable').mockReturnValue(false);

      // Remove window.cline to simulate unavailability
      delete global.window.cline;

      const result = await magicMcpIntegration.updateSelectedModel('claude-3-opus');

      expect(mockApi.updateSelectedModel).toHaveBeenCalledTimes(1);
      expect(mockApi.updateSelectedModel).toHaveBeenCalledWith('claude-3-opus');
      expect(result).toBe(true);
    });

    test('returns false when MCP fails', async () => {
      // Mock isMcpAvailable to return true
      jest.spyOn(magicMcpIntegration, 'isMcpAvailable').mockReturnValue(true);

      // Make callMcpFunction throw an error
      global.window.cline.callMcpFunction.mockImplementation(() => {
        throw new Error('MCP error');
      });

      const result = await magicMcpIntegration.updateSelectedModel('claude-3-opus');

      expect(global.window.cline.callMcpFunction).toHaveBeenCalledTimes(1);
      expect(result).toBe(false);
    });
  });
});
