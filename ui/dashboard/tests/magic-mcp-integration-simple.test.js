/**
 * Test file focused on specific error handling for magic-mcp-integration.js
 */

// Mock mockApi
jest.mock('../mockApi', () => ({
  fetchDashboardData: jest.fn().mockResolvedValue({ mocked: true }),
  updateSelectedModel: jest.fn().mockResolvedValue(true)
}));

// Import mockApi using the mock
import mockApi from '../mockApi';

// Import the module under test
import { fetchDashboardData, updateSelectedModel } from '../magic-mcp-integration';

describe('magic-mcp-integration simple tests', () => {
  // Keep track of the original window object
  const originalWindow = global.window;
  
  beforeEach(() => {
    // Set up a fresh window object for each test
    global.window = {
      cline: undefined  // Start with cline undefined to ensure consistent fallback behavior
    };
    
    jest.clearAllMocks();
  });
  
  afterEach(() => {
    // Restore original window after each test
    global.window = originalWindow;
  });
  
  test('fetchDashboardData calls mockApi when MCP is not available', async () => {
    // With cline undefined, MCP should be considered unavailable
    await fetchDashboardData();
    
    // Should fall back to mockApi
    expect(mockApi.fetchDashboardData).toHaveBeenCalled();
  });
  
  test('updateSelectedModel calls mockApi when MCP is not available', async () => {
    // With cline undefined, MCP should be considered unavailable
    await updateSelectedModel('test-model');
    
    // Should fall back to mockApi
    expect(mockApi.updateSelectedModel).toHaveBeenCalledWith('test-model');
  });
}); 