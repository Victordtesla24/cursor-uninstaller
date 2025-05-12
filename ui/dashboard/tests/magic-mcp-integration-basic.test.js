/**
 * Simplified test file focused on basic functionality of magic-mcp-integration.js
 */

// Mock the mockApi module first
jest.mock('../mockApi', () => ({
  fetchDashboardData: jest.fn().mockResolvedValue({ mocked: true }),
  updateSelectedModel: jest.fn().mockResolvedValue(true),
  updateSetting: jest.fn().mockResolvedValue(true),
  updateTokenBudget: jest.fn().mockResolvedValue(true),
  refreshDashboardData: jest.fn().mockResolvedValue({ refreshed: true })
}));

// Import mockApi using the mock
import mockApi from '../mockApi';

// Import the module under test
import { fetchDashboardData, updateSelectedModel } from '../magic-mcp-integration';

describe('magic-mcp-integration basic tests', () => {
  // Keep track of the original window object
  const originalWindow = global.window;
  
  beforeEach(() => {
    // Set up a fresh window object for each test with cline undefined
    global.window = {
      cline: undefined  // This ensures consistent fallback behavior to mockApi
    };
    
    jest.clearAllMocks();
  });
  
  afterEach(() => {
    // Restore original window after each test
    global.window = originalWindow;
  });

  describe('Basic MCP availability checks', () => {
    test('fetchDashboardData falls back to mockApi when MCP is unavailable', async () => {
      await fetchDashboardData();
      
      // Should fall back to mockApi
      expect(mockApi.fetchDashboardData).toHaveBeenCalled();
    });
    
    test('updateSelectedModel falls back to mockApi when MCP is unavailable', async () => {
      await updateSelectedModel('test-model');
      
      // Should fall back to mockApi
      expect(mockApi.updateSelectedModel).toHaveBeenCalledWith('test-model');
    });
  });
  
  describe('Error handling', () => {
    test('fetchDashboardData handles errors gracefully', async () => {
      // Mock mockApi to throw an error
      mockApi.fetchDashboardData.mockRejectedValueOnce(new Error('Test error'));
      
      // This shouldn't throw an error
      await fetchDashboardData();
      
      // Expect that we attempted to call the mock API
      expect(mockApi.fetchDashboardData).toHaveBeenCalled();
    });
    
    test('updateSelectedModel returns false on error', async () => {
      // Mock mockApi to throw an error
      mockApi.updateSelectedModel.mockRejectedValueOnce(new Error('Test error'));
      
      // Should return false when there's an error
      const result = await updateSelectedModel('test-model');
      
      expect(result).toBe(false);
    });
  });
}); 