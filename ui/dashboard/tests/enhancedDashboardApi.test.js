import {
  use_mcp_tool,
  access_mcp_resource,
  subscribeToMcpUpdates,
  batchMcpResources,
  isMcpAvailable,
  initializeMcpClient
} from '../lib/enhancedDashboardApi';

// Mock the actual implementation to avoid async delays
jest.mock('../lib/enhancedDashboardApi', () => {
  // Get the actual implementation
  const actualModule = jest.requireActual('../lib/enhancedDashboardApi');

  // Override delay function to make tests run faster
  const mockDelay = jest.fn(() => Promise.resolve());

  return {
    ...actualModule,
    delay: mockDelay
  };
});

// Spy on console methods to reduce noise
beforeAll(() => {
  jest.spyOn(console, 'error').mockImplementation(() => {});
  jest.spyOn(console, 'warn').mockImplementation(() => {});
});

afterAll(() => {
  jest.restoreAllMocks();
});

describe('Enhanced Dashboard API', () => {
  // Store original window object
  const originalWindow = global.window;
  let mockMcpClient;

  beforeEach(() => {
    // Create fresh mock for each test
    mockMcpClient = {
      useTool: jest.fn().mockResolvedValue({ data: 'test-result' }),
      accessResource: jest.fn().mockResolvedValue({ data: 'resource-data' }),
      subscribe: jest.fn().mockReturnValue(() => {}),
      batchResources: jest.fn().mockResolvedValue({
        'test://uri1': { data: 'data1' },
        'test://uri2': { data: 'data2' }
      })
    };

    // Set up window object before each test - ensure it's created as a new object
    global.window = Object.create(null);
    global.window.__MCP_CLIENT = mockMcpClient;
    global.window.__MCP_INIT = jest.fn().mockResolvedValue(mockMcpClient);
  });

  afterEach(() => {
    // Restore window to its original state
    global.window = originalWindow;
  });

  describe('use_mcp_tool', () => {
    test('successfully calls MCP tool', async () => {
      // Re-mock the function to ensure it returns correct data
      window.__MCP_CLIENT.useTool.mockResolvedValueOnce({ data: 'test-result' });

      const result = await use_mcp_tool('test-server', 'test-tool', { param: 'value' });

      expect(window.__MCP_CLIENT.useTool).toHaveBeenCalledWith('test-server', 'test-tool', { param: 'value' });
      expect(result).toEqual({ data: 'test-result' });
    });

    test('retries when MCP tool fails', async () => {
      // Mock implementation to fail once then succeed
      window.__MCP_CLIENT.useTool
        .mockRejectedValueOnce(new Error('Test error'))
        .mockResolvedValueOnce({ data: 'retry-success' });

      const result = await use_mcp_tool('test-server', 'test-tool', { param: 'value' });

      expect(window.__MCP_CLIENT.useTool).toHaveBeenCalledTimes(2);
      expect(result).toEqual({ data: 'retry-success' });
    });

    test('throws after max retries', async () => {
      // Always reject
      window.__MCP_CLIENT.useTool.mockRejectedValue(new Error('Persistent error'));

      // Should throw after MAX_RETRIES attempts
      await expect(use_mcp_tool('test-server', 'test-tool', { param: 'value' }))
        .rejects.toThrow(/failed after/);
    });

    test('throws when MCP client not available', async () => {
      // Temporarily remove MCP client
      const tempClient = window.__MCP_CLIENT;
      window.__MCP_CLIENT = undefined;

      await expect(use_mcp_tool('test-server', 'test-tool', { param: 'value' }))
        .rejects.toThrow('MCP client not available');

      // Restore client for other tests
      window.__MCP_CLIENT = tempClient;
    });
  });

  describe('access_mcp_resource', () => {
    test('successfully accesses MCP resource', async () => {
      // Re-mock to ensure it returns correct data
      window.__MCP_CLIENT.accessResource.mockResolvedValueOnce({ data: 'resource-data' });

      const result = await access_mcp_resource('test-server', 'test://resource');

      expect(window.__MCP_CLIENT.accessResource).toHaveBeenCalledWith('test-server', 'test://resource');
      expect(result).toEqual({ data: 'resource-data' });
    });

    test('retries when resource access fails', async () => {
      // Mock implementation to fail once then succeed
      window.__MCP_CLIENT.accessResource
        .mockRejectedValueOnce(new Error('Test error'))
        .mockResolvedValueOnce({ data: 'retry-success' });

      const result = await access_mcp_resource('test-server', 'test://resource');

      expect(window.__MCP_CLIENT.accessResource).toHaveBeenCalledTimes(2);
      expect(result).toEqual({ data: 'retry-success' });
    });

    test('throws after max retries', async () => {
      // Always reject
      window.__MCP_CLIENT.accessResource.mockRejectedValue(new Error('Persistent error'));

      // Should throw after MAX_RETRIES attempts
      await expect(access_mcp_resource('test-server', 'test://resource'))
        .rejects.toThrow(/failed after/);
    });

    test('throws when MCP client not available', async () => {
      // Temporarily remove MCP client
      const tempClient = window.__MCP_CLIENT;
      window.__MCP_CLIENT = undefined;

      await expect(access_mcp_resource('test-server', 'test://resource'))
        .rejects.toThrow('MCP client not available');

      // Restore client for other tests
      window.__MCP_CLIENT = tempClient;
    });
  });

  describe('subscribeToMcpUpdates', () => {
    test('subscribes to MCP updates', () => {
      const callback = jest.fn();
      const unsubscribe = subscribeToMcpUpdates('test://resource', callback);

      expect(window.__MCP_CLIENT.subscribe).toHaveBeenCalledWith('test://resource', callback);
      expect(typeof unsubscribe).toBe('function');
    });

    test('returns no-op function when MCP client not available', () => {
      // Temporarily remove MCP client
      const tempClient = window.__MCP_CLIENT;
      window.__MCP_CLIENT = undefined;

      const callback = jest.fn();
      const unsubscribe = subscribeToMcpUpdates('test://resource', callback);

      expect(typeof unsubscribe).toBe('function');
      expect(() => unsubscribe()).not.toThrow();

      // Restore client for other tests
      window.__MCP_CLIENT = tempClient;
    });
  });

  describe('batchMcpResources', () => {
    test('batches multiple resource requests', async () => {
      // Re-mock to ensure it returns correct data
      window.__MCP_CLIENT.batchResources.mockResolvedValueOnce({
        'test://uri1': { data: 'data1' },
        'test://uri2': { data: 'data2' }
      });

      const uris = ['test://uri1', 'test://uri2'];
      const result = await batchMcpResources('test-server', uris);

      expect(window.__MCP_CLIENT.batchResources).toHaveBeenCalledWith('test-server', uris);
      expect(result).toEqual({
        'test://uri1': { data: 'data1' },
        'test://uri2': { data: 'data2' }
      });
    });

    test('falls back to individual requests when batch function not available', async () => {
      // Create a temporary client without batchResources
      const tempClient = { ...window.__MCP_CLIENT };
      delete tempClient.batchResources;

      // Replace the client with our modified version
      window.__MCP_CLIENT = tempClient;

      // Mock individual resource access
      window.__MCP_CLIENT.accessResource
        .mockImplementation((server, uri) => {
          if (uri === 'test://uri1') return Promise.resolve({ data: 'data1' });
          if (uri === 'test://uri2') return Promise.resolve({ data: 'data2' });
          return Promise.reject(new Error('Unknown URI'));
        });

      const uris = ['test://uri1', 'test://uri2'];
      const result = await batchMcpResources('test-server', uris);

      expect(window.__MCP_CLIENT.accessResource).toHaveBeenCalledTimes(2);
      expect(result).toEqual({
        'test://uri1': { data: 'data1' },
        'test://uri2': { data: 'data2' }
      });

      // Restore the original client
      window.__MCP_CLIENT = mockMcpClient;
    });

    test('handles individual request failures in fallback mode', async () => {
      // Create a temporary client without batchResources
      const tempClient = { ...window.__MCP_CLIENT };
      delete tempClient.batchResources;

      // Replace the client with our modified version
      window.__MCP_CLIENT = tempClient;

      // Mock one request to fail
      window.__MCP_CLIENT.accessResource
        .mockImplementation((server, uri) => {
          if (uri === 'test://uri1') return Promise.resolve({ data: 'data1' });
          if (uri === 'test://uri2') return Promise.reject(new Error('Test error'));
          return Promise.reject(new Error('Unknown URI'));
        });

      const uris = ['test://uri1', 'test://uri2'];
      const result = await batchMcpResources('test-server', uris);

      // The fallback mode should set failed requests to null
      expect(result).toEqual({
        'test://uri1': { data: 'data1' },
        'test://uri2': null
      });

      // Restore the original client
      window.__MCP_CLIENT = mockMcpClient;
    });
  });

  describe('isMcpAvailable', () => {
    test('returns true when MCP client is available', () => {
      // Ensure the client is properly set up
      expect(window.__MCP_CLIENT).toBeDefined();
      expect(typeof window.__MCP_CLIENT.useTool).toBe('function');
      expect(typeof window.__MCP_CLIENT.accessResource).toBe('function');

      // Now test the function
      expect(isMcpAvailable()).toBe(true);
    });

    test('returns false when MCP client is not available', () => {
      // Temporarily remove MCP client
      const tempClient = window.__MCP_CLIENT;
      window.__MCP_CLIENT = undefined;

      expect(isMcpAvailable()).toBe(false);

      // Restore client for other tests
      window.__MCP_CLIENT = tempClient;
    });

    test('returns false when MCP client lacks required methods', () => {
      // Create a client without the required methods
      const tempClient = { ...window.__MCP_CLIENT };
      delete tempClient.useTool;

      // Replace the client with our modified version
      window.__MCP_CLIENT = tempClient;

      expect(isMcpAvailable()).toBe(false);

      // Restore the original client
      window.__MCP_CLIENT = mockMcpClient;
    });
  });

  describe('initializeMcpClient', () => {
    test('initializes MCP client successfully', async () => {
      // Temporarily remove MCP client to test initialization
      window.__MCP_CLIENT = undefined;

      // Mock the initialization function to return our mock client
      window.__MCP_INIT.mockResolvedValueOnce(mockMcpClient);

      const result = await initializeMcpClient({ apiKey: 'test-key' });

      expect(window.__MCP_INIT).toHaveBeenCalledWith({ apiKey: 'test-key' });
      expect(result).toBe(true);
      expect(window.__MCP_CLIENT).toBeDefined();
    });

    test('returns false when initialization fails', async () => {
      // Temporarily remove MCP client to test initialization
      window.__MCP_CLIENT = undefined;

      // Make the initialization fail
      window.__MCP_INIT.mockRejectedValueOnce(new Error('Init failed'));

      const result = await initializeMcpClient({ apiKey: 'test-key' });

      expect(result).toBe(false);
    });

    test('returns false when MCP_INIT is not available', async () => {
      // Temporarily remove MCP client and init function
      window.__MCP_CLIENT = undefined;
      const tempInit = window.__MCP_INIT;
      window.__MCP_INIT = undefined;

      const result = await initializeMcpClient({ apiKey: 'test-key' });

      expect(result).toBe(false);

      // Restore init function
      window.__MCP_INIT = tempInit;
    });
  });
});
