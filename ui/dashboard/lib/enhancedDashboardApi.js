/**
 * Enhanced Dashboard API Utilities
 *
 * Provides wrapper functions for MCP tools and resources with enhanced functionality
 * Implements error handling, retry logic, and convenience methods
 * Abstracts MCP interaction details to simplify the main API implementation
 */

// Max retry attempts for MCP operations
const MAX_RETRIES = 3;

// Delay between retry attempts (in ms)
const RETRY_DELAY = 500;

// Helper function to delay execution (for retries)
const delay = (ms) => new Promise(resolve => setTimeout(resolve, ms));

/**
 * Enhanced wrapper for using MCP tools with retry logic
 *
 * @param {string} serverName - The MCP server name
 * @param {string} toolName - The tool to execute
 * @param {object} args - The arguments to pass to the tool
 * @param {object} options - Additional options (retries, timeout, etc)
 * @returns {Promise<any>} - The result of the MCP tool execution
 */
export const use_mcp_tool = async (serverName, toolName, args, options = {}) => {
  const { retries = MAX_RETRIES, logErrors = true } = options;
  let lastError;

  for (let attempt = 0; attempt < retries + 1; attempt++) {
    try {
      // Real implementation would call the MCP API through a generated client
      // For now, we're simulating the API call structure

      if (window.__MCP_CLIENT && typeof window.__MCP_CLIENT.useTool === 'function') {
        return await window.__MCP_CLIENT.useTool(serverName, toolName, args);
      }

      // If no MCP client is available, throw an error
      throw new Error('MCP client not available');
    } catch (error) {
      lastError = error;

      if (logErrors) {
        console.error(`MCP tool "${toolName}" failed (attempt ${attempt + 1}/${retries + 1}):`, error);
      }

      // If we've reached the max retries, throw the last error
      if (attempt >= retries) {
        throw new Error(`MCP tool "${toolName}" failed after ${retries + 1} attempts: ${error.message}`);
      }

      // Wait before retrying
      await delay(RETRY_DELAY * Math.pow(2, attempt)); // Exponential backoff
    }
  }

  // This should never happen, but just in case
  throw lastError;
};

/**
 * Enhanced wrapper for accessing MCP resources with retry logic
 *
 * @param {string} serverName - The MCP server name
 * @param {string} uri - The resource URI to access
 * @param {object} options - Additional options (retries, timeout, etc)
 * @returns {Promise<any>} - The resource data
 */
export const access_mcp_resource = async (serverName, uri, options = {}) => {
  const { retries = MAX_RETRIES, logErrors = true } = options;
  let lastError;

  for (let attempt = 0; attempt < retries + 1; attempt++) {
    try {
      // Real implementation would call the MCP API through a generated client
      // For now, we're simulating the API call structure

      if (window.__MCP_CLIENT && typeof window.__MCP_CLIENT.accessResource === 'function') {
        return await window.__MCP_CLIENT.accessResource(serverName, uri);
      }

      // If no MCP client is available, throw an error
      throw new Error('MCP client not available');
    } catch (error) {
      lastError = error;

      if (logErrors) {
        console.error(`MCP resource "${uri}" access failed (attempt ${attempt + 1}/${retries + 1}):`, error);
      }

      // If we've reached the max retries, throw the last error
      if (attempt >= retries) {
        throw new Error(`MCP resource "${uri}" access failed after ${retries + 1} attempts: ${error.message}`);
      }

      // Wait before retrying
      await delay(RETRY_DELAY * Math.pow(2, attempt)); // Exponential backoff
    }
  }

  // This should never happen, but just in case
  throw lastError;
};

/**
 * Register a callback for MCP data updates
 * Allows components to subscribe to real-time MCP data changes
 *
 * @param {string} resourceUri - The resource URI to watch for updates
 * @param {Function} callback - The callback to execute when data changes
 * @returns {Function} - A function to unsubscribe from updates
 */
export const subscribeToMcpUpdates = (resourceUri, callback) => {
  if (window.__MCP_CLIENT && typeof window.__MCP_CLIENT.subscribe === 'function') {
    return window.__MCP_CLIENT.subscribe(resourceUri, callback);
  }

  // If no MCP client is available, return a no-op unsubscribe function
  console.warn(`Unable to subscribe to updates for ${resourceUri}: MCP client not available`);
  return () => {};
};

/**
 * Batch multiple MCP resource requests into a single operation
 * Optimizes dashboard loading by reducing number of separate requests
 *
 * @param {string} serverName - The MCP server name
 * @param {string[]} uris - Array of resource URIs to fetch
 * @returns {Promise<object>} - Object with URI keys and resource data values
 */
export const batchMcpResources = async (serverName, uris) => {
  if (window.__MCP_CLIENT && typeof window.__MCP_CLIENT.batchResources === 'function') {
    return await window.__MCP_CLIENT.batchResources(serverName, uris);
  }

  // If no batch function is available, fall back to individual requests
  const results = {};
  await Promise.all(uris.map(async (uri) => {
    try {
      results[uri] = await access_mcp_resource(serverName, uri);
    } catch (error) {
      console.error(`Failed to fetch resource ${uri} in batch:`, error);
      results[uri] = null;
    }
  }));

  return results;
};

/**
 * Check if the MCP client is available and properly initialized
 *
 * @returns {boolean} - True if MCP client is available and ready
 */
export const isMcpAvailable = () => {
  return !!(window.__MCP_CLIENT &&
    typeof window.__MCP_CLIENT.useTool === 'function' &&
    typeof window.__MCP_CLIENT.accessResource === 'function');
};

/**
 * Initialize the dashboard MCP client with configuration options
 *
 * @param {object} config - Configuration options for the MCP client
 * @returns {Promise<boolean>} - True if initialization was successful
 */
export const initializeMcpClient = async (config = {}) => {
  try {
    // Real implementation would initialize the MCP client with the provided config
    // For now, we're just simulating this process

    if (!window.__MCP_CLIENT && typeof window.__MCP_INIT === 'function') {
      window.__MCP_CLIENT = await window.__MCP_INIT(config);
      return true;
    }

    return false;
  } catch (error) {
    console.error('Failed to initialize MCP client:', error);
    return false;
  }
};
