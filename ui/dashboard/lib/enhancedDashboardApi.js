/**
 * Enhanced Dashboard API Module
 *
 * A comprehensive API layer for the Cline AI Dashboard that provides a unified interface
 * for data fetching, updates, and event handling. This module implements a robust fallback
 * strategy using MCP (Magic Control Protocol) when available and automatically falls back
 * to mock data when MCP is unavailable.
 *
 * Key features:
 * - Transparent MCP integration with automatic fallback
 * - In-memory caching to reduce API calls
 * - Retry mechanisms with exponential backoff
 * - Event subscription system for real-time updates
 * - Comprehensive error handling and logging
 *
 * @module enhancedDashboardApi
 */

import * as mockApi from '../mockApi.js';

// Max retry attempts for MCP operations
const MAX_RETRIES = 3;

// Delay between retry attempts (in ms)
const RETRY_DELAY = 500;

/**
 * Helper function to delay execution (for retries).
 *
 * @param {number} ms - The number of milliseconds to delay.
 * @returns {Promise<void>} A promise that resolves after the specified delay.
 */
export const delay = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

/**
 * Safely checks if the MCP client is available in the window object.
 * Prevents recursion issues during the check.
 *
 * @returns {boolean} True if the MCP client is available and has necessary methods, false otherwise.
 */
export const safeCheckMcp = () => {
  try {
    return typeof window !== 'undefined' &&
           window.__MCP_CLIENT !== undefined &&
           typeof window.__MCP_CLIENT.useTool === 'function' &&
           typeof window.__MCP_CLIENT.accessResource === 'function';
  } catch (e) {
    console.error("Error checking MCP client:", e);
    return false;
  }
};

/**
 * Enhanced wrapper for using MCP tools with retry logic.
 *
 * This function provides a robust interface to MCP tools with built-in
 * retry logic and exponential backoff for improved reliability.
 *
 * @param {string} serverName - The MCP server name.
 * @param {string} toolName - The tool to execute.
 * @param {object} args - The arguments to pass to the tool.
 * @param {object} [options={}] - Additional options for the request.
 * @param {number} [options.maxRetries=MAX_RETRIES] - Maximum number of retry attempts.
 * @returns {Promise<object>} The result of the tool call.
 *
 * @throws {Error} If the MCP client is not available or all retry attempts fail.
 *
 * @example
 * // Basic usage
 * try {
 *   const result = await use_mcp_tool('cline-dashboard', 'updateModel', { modelId: 'gpt-4' });
 *   console.log('Model updated successfully:', result);
 * } catch (error) {
 *   console.error('Failed to update model:', error);
 * }
 */
export const use_mcp_tool = async (
  serverName,
  toolName,
  args,
  options = {},
) => {
  // Check if MCP client is available
  if (!safeCheckMcp()) {
    throw new Error("MCP client not available");
  }

  let lastError;
  const maxRetries = options.maxRetries || MAX_RETRIES;

  // Try up to maxRetries times
  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      console.log(
        `Attempt ${attempt} to use MCP tool ${serverName}.${toolName}`,
      );
      const result = await window.__MCP_CLIENT.useTool(
        serverName,
        toolName,
        args,
      );
      return result;
    } catch (error) {
      console.error(
        `Error using MCP tool (attempt ${attempt}/${maxRetries}):`,
        error,
      );
      lastError = error;

      // Only delay if we're going to retry
      if (attempt < maxRetries) {
        // Exponential backoff
        await delay(RETRY_DELAY * attempt);
      }
    }
  }

  // If we've exhausted all retries, throw the last error
  throw new Error(
    `MCP tool call to ${serverName}.${toolName} failed after ${maxRetries} attempts: ${lastError?.message || "Unknown error"}`,
  );
};

/**
 * Enhanced wrapper for accessing MCP resources with retry logic.
 *
 * @param {string} serverName - The MCP server name.
 * @param {string} uri - The resource URI to access.
 * @param {object} [options={}] - Additional options for the request.
 * @returns {Promise<object>} The result of the resource access.
 * @throws {Error} If the MCP client is not available or all retry attempts fail.
 */
export const access_mcp_resource = async (serverName, uri, options = {}) => {
  // Check if MCP client is available
  if (!safeCheckMcp()) {
    throw new Error("MCP client not available");
  }

  let lastError;
  const maxRetries = options.maxRetries || MAX_RETRIES;

  // Try up to maxRetries times
  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      console.log(
        `Attempt ${attempt} to access MCP resource ${serverName}:${uri}`,
      );
      const result = await window.__MCP_CLIENT.accessResource(serverName, uri);
      return result;
    } catch (error) {
      console.error(
        `Error accessing MCP resource (attempt ${attempt}/${maxRetries}):`,
        error,
      );
      lastError = error;

      // Only delay if we're going to retry
      if (attempt < maxRetries) {
        // Exponential backoff
        await delay(RETRY_DELAY * attempt);
      }
    }
  }

  // If we've exhausted all retries, throw the last error
  throw new Error(
    `MCP resource access to ${serverName}:${uri} failed after ${maxRetries} attempts: ${lastError?.message || "Unknown error"}`,
  );
};

/**
 * Subscribe to updates from an MCP resource.
 *
 * @param {string} resourceUri - The resource URI to subscribe to.
 * @param {Function} callback - The callback to execute when the resource updates.
 * @returns {Function} A function to unsubscribe.
 */
export const subscribeToMcpUpdates = (resourceUri, callback) => {
  if (!safeCheckMcp()) {
    console.warn("MCP client not available for subscriptions");
    return () => {}; // Return a no-op function
  }

  // Return the unsubscribe function provided by the MCP client
  return window.__MCP_CLIENT.subscribe(resourceUri, callback);
};

/**
 * Request multiple MCP resources in a single batch.
 *
 * @param {string} serverName - The MCP server name.
 * @param {string[]} uris - The resource URIs to access.
 * @param {object} [options={}] - Additional options for the request.
 * @returns {Promise<object>} An object mapping URIs to their results.
 * @throws {Error} If the MCP client is not available.
 */
export const batchMcpResources = async (serverName, uris, options = {}) => {
  if (!safeCheckMcp()) {
    throw new Error("MCP client not available");
  }

  // If the MCP client supports batching, use it
  if (window.__MCP_CLIENT.batchResources) {
    return await window.__MCP_CLIENT.batchResources(serverName, uris);
  }

  // Otherwise, fall back to individual requests
  console.warn(
    "MCP client does not support batch requests, falling back to individual requests",
  );
  const results = {};

  await Promise.all(
    uris.map(async (uri) => {
      try {
        results[uri] = await access_mcp_resource(serverName, uri, options);
      } catch (error) {
        console.error(`Error accessing ${uri}:`, error);
        results[uri] = null;
      }
    }),
  );

  return results;
};

/**
 * Check if MCP client is available.
 *
 * @returns {boolean} Whether the MCP client is available.
 */
export const isMcpAvailable = () => {
  return safeCheckMcp();
};

/**
 * Initialize the MCP client.
 *
 * @param {object} [config={}] - Configuration for the MCP client.
 * @returns {Promise<boolean>} Whether initialization succeeded.
 */
export const initializeMcpClient = async (config = {}) => {
  if (typeof window === 'undefined' || !window.__MCP_INIT) {
    console.error("MCP initialization function not available");
    return false;
  }

  try {
    window.__MCP_CLIENT = await window.__MCP_INIT(config);
    console.log("MCP client initialized successfully");
    return true;
  } catch (error) {
    console.error("Failed to initialize MCP client:", error);
    return false;
  }
};

// Event listeners storage
const eventListeners = {
  dataUpdate: [],
  connectionStatus: [],
  error: [],
};

// Cached data for performance
let cachedDashboardData = null;
let lastRefreshTime = 0;
const CACHE_TTL = 30000; // Cache validity in ms (30 seconds)

// Refresh interval reference
let refreshIntervalId = null;

/**
 * Main API implementation
 * Provides functions to fetch and update dashboard data
 * Uses MCP when available, falls back to mockApi when unavailable
 * Emits events for data updates and errors
 */

/**
 * Refresh dashboard data.
 *
 * Fetches the latest dashboard data from the API or returns cached data if it's still valid.
 * Uses MCP if available, with automatic fallback to mock data.
 *
 * @param {boolean} [forceMockData=false] - Force using mock data even if MCP is available.
 * @returns {Promise<object>} The dashboard data object containing tokens, models, settings, etc.
 *
 * @throws {Error} If data fetching fails and no cache is available.
 *
 * @example
 * // Basic usage
 * const dashboardData = await refreshData();
 *
 * @example
 * // Force using mock data for testing
 * const mockData = await refreshData(true);
 */
export async function refreshData(forceMockData = false) {
  console.log("Refreshing dashboard data...");

  // Check if we should use cached data
  const now = Date.now();
  if (cachedDashboardData && (now - lastRefreshTime < CACHE_TTL)) {
    console.log("Using cached dashboard data");
    return cachedDashboardData;
  }

  let data;
  const useMcp = isMcpAvailable() && !forceMockData;

  try {
    if (useMcp) {
      console.log("Fetching data from MCP...");
      try {
        // Try to get data from MCP client
        data = await fetchDataFromMcp();
      } catch (mcpError) {
        console.error("Error fetching data from MCP, falling back to mock data:", mcpError);
        // Fall back to mock data
        data = await mockApi.mockApi.fetchDashboardData();
      }
    } else {
      console.log("MCP not available or mock data forced, using mock API...");
      data = await mockApi.mockApi.fetchDashboardData();
    }

    // Cache the data
    cachedDashboardData = data;
    lastRefreshTime = now;

    // Emit data update event
    for (const callback of eventListeners.dataUpdate) {
      callback(data);
    }

    return data;
  } catch (error) {
    console.error("Error refreshing dashboard data:", error);

    // Emit error event
    for (const callback of eventListeners.error) {
      callback(error);
    }

    // Return cached data if available, otherwise throw
    if (cachedDashboardData) {
      return cachedDashboardData;
    }

    throw error;
  }
}

/**
 * Fetches dashboard data from the MCP client.
 * This is an internal helper function.
 *
 * @returns {Promise<object>} The dashboard data from MCP.
 * @throws {Error} If accessing the MCP resource fails or returns invalid data.
 */
async function fetchDataFromMcp() {
  try {
    // In a production environment, this would make a real request to the MCP API
    // For now, we'll access a resource and expect it to return dashboard data
    const rawResponse = await access_mcp_resource('cline-dashboard', '/api/dashboard/data');
    const data = rawResponse && rawResponse.result ? rawResponse.result : rawResponse; // Extract data if wrapped

    // If the response doesn't have the expected structure, throw an error
    if (!data || !data.tokens || !data.models) {
      console.warn("Invalid data format received from MCP, falling back to mock data", data);
      throw new Error("Invalid data format");
    }

    return data;
  } catch (error) {
    console.error("Error accessing MCP resource:", error);
    throw error;
  }
}

/**
 * Update the selected model.
 *
 * Changes the currently selected AI model in the dashboard.
 * Updates both the server state and local cache.
 *
 * @param {string} modelId - The ID of the model to select.
 * @returns {Promise<boolean>} Whether the update succeeded.
 *
 * @throws {Error} If the update fails and cannot be completed via fallback.
 *
 * @example
 * // Select a new model
 * await updateSelectedModel('gpt-4');
 *
 * @example
 * // Error handling
 * try {
 *   await updateSelectedModel('claude-3-sonnet');
 * } catch (error) {
 *   console.error('Failed to update model:', error);
 * }
 */
export async function updateSelectedModel(modelId) {
  console.log(`Updating selected model to: ${modelId}`);

  try {
    if (isMcpAvailable()) {
      try {
        // Try to update via MCP
        await use_mcp_tool('cline-dashboard', 'updateModel', { modelId });
      } catch (mcpError) {
        console.error("Error updating model via MCP, falling back to mock API:", mcpError);
        // Fall back to mock API
        await mockApi.mockApi.updateSelectedModel(modelId);
      }
    } else {
      // Use mock API directly
      await mockApi.mockApi.updateSelectedModel(modelId);
    }

    // Refresh cached data if available
    if (cachedDashboardData && cachedDashboardData.models) {
      cachedDashboardData.models.selected = modelId;
    }

    return true;
  } catch (error) {
    console.error("Error updating selected model:", error);

    // Emit error event
    for (const callback of eventListeners.error) {
      callback(error);
    }

    throw error;
  }
}

/**
 * Update a dashboard setting.
 *
 * @param {string} key - The setting key.
 * @param {any} value - The setting value.
 * @returns {Promise<boolean>} Whether the update succeeded.
 * @throws {Error} If the update fails and cannot be completed via fallback.
 */
export async function updateSetting(key, value) {
  console.log(`Updating setting ${key} to:`, value);

  try {
    if (isMcpAvailable()) {
      try {
        // Try to update via MCP
        await use_mcp_tool('cline-dashboard', 'updateSetting', { key, value });
      } catch (mcpError) {
        console.error("Error updating setting via MCP, falling back to mock API:", mcpError);
        // Fall back to mock API
        await mockApi.mockApi.updateSetting(key, value);
      }
    } else {
      // Use mock API directly
      await mockApi.mockApi.updateSetting(key, value);
    }

    // Update cached data if available
    if (cachedDashboardData && cachedDashboardData.settings) {
      cachedDashboardData.settings[key] = value;
    }

    return true;
  } catch (error) {
    console.error(`Error updating setting ${key}:`, error);

    // Emit error event
    for (const callback of eventListeners.error) {
      callback(error);
    }

    throw error;
  }
}

/**
 * Update token budget.
 *
 * @param {string} budgetType - The type of budget to update (e.g., 'daily', 'weekly', 'monthly').
 * @param {number} value - The new budget value.
 * @returns {Promise<boolean>} Whether the update succeeded.
 * @throws {Error} If the update fails and cannot be completed via fallback.
 */
export async function updateTokenBudget(budgetType, value) {
  console.log(`Updating token budget ${budgetType} to: ${value}`);

  try {
    if (isMcpAvailable()) {
      try {
        // Try to update via MCP
        await use_mcp_tool('cline-dashboard', 'updateTokenBudget', { budgetType, value });
      } catch (mcpError) {
        console.error("Error updating token budget via MCP, falling back to mock API:", mcpError);
        // Fall back to mock API
        await mockApi.mockApi.updateTokenBudget(budgetType, value);
      }
    } else {
      // Use mock API directly
      await mockApi.mockApi.updateTokenBudget(budgetType, value);
    }

    // Update cached data if available
    if (cachedDashboardData && cachedDashboardData.tokens && cachedDashboardData.tokens.budgets) {
      if (!cachedDashboardData.tokens.budgets[budgetType]) {
        cachedDashboardData.tokens.budgets[budgetType] = { budget: value };
      } else {
        cachedDashboardData.tokens.budgets[budgetType].budget = value;
      }
    }

    return true;
  } catch (error) {
    console.error(`Error updating token budget ${budgetType}:`, error);

    // Emit error event
    for (const callback of eventListeners.error) {
      callback(error);
    }

    throw error;
  }
}

/**
 * Add an event listener for API events.
 *
 * @param {'dataUpdate' | 'connectionStatus' | 'error'} event - The event to listen for.
 * @param {Function} callback - The callback to execute when the event occurs.
 */
export function addEventListener(event, callback) {
  if (eventListeners[event]) {
    eventListeners[event].push(callback);
  } else {
    console.warn(`Unknown event type: ${event}`);
  }
}

/**
 * Remove an event listener.
 *
 * @param {'dataUpdate' | 'connectionStatus' | 'error'} event - The event to stop listening for.
 * @param {Function} callback - The callback to remove.
 */
export function removeEventListener(event, callback) {
  if (eventListeners[event]) {
    const index = eventListeners[event].indexOf(callback);
    if (index !== -1) {
      eventListeners[event].splice(index, 1);
    }
  } else {
     console.warn(`Unknown event type: ${event}`);
  }
}

/**
 * Clean up resources used by the API module.
 * Clears refresh intervals and event listeners.
 */
export function cleanup() {
  console.log("Cleaning up enhanced dashboard API resources...");
  // Clear refresh interval
  if (refreshIntervalId) {
    clearInterval(refreshIntervalId);
    refreshIntervalId = null;
  }

  // Clear event listeners
  Object.keys(eventListeners).forEach((event) => {
    eventListeners[event] = [];
  });

  // Clear cache
  cachedDashboardData = null;
}

/**
 * Initialize the API module.
 * Sets up the MCP client and starts the data refresh interval.
 *
 * @param {number} [refreshInterval=5000] - Interval in ms for automatic data refresh. Set to 0 to disable auto-refresh.
 * @returns {Promise<object>} An object indicating the connection status.
 */
export async function initialize(refreshInterval = 5000) {
  console.log("Initializing enhanced dashboard API...");

  let mcpAvailable = false;
  let puppeteerAvailable = false;

  // Try to initialize MCP client if not already initialized
  if (!window.__MCP_CLIENT && window.__MCP_INIT) {
    try {
      const mcpInitialized = await initializeMcpClient({
        apiKey: "53498dc92288a232c236c00f5c982f89456f3e7699b760e6746b133abb023bea",
      });
      console.log(`MCP client initialized: ${mcpInitialized}`);
    } catch (error) {
      console.error("Failed to initialize MCP client:", error);
    }
  }

  // Check MCP availability
  mcpAvailable = isMcpAvailable();
  console.log(`MCP available: ${mcpAvailable}`);

  // Check Puppeteer availability (example of checking another MCP server)
  if (mcpAvailable) {
    try {
      // Try to access the Puppeteer server status resource
      const testResponse = await access_mcp_resource('github.com/modelcontextprotocol/servers/tree/main/src/puppeteer', 'console://logs', { maxRetries: 1 });
      puppeteerAvailable = testResponse !== null && testResponse !== undefined; // Simple check if resource access didn't throw
      console.log(`Puppeteer MCP server available: ${puppeteerAvailable}`);

      if (puppeteerAvailable) {
        window.PUPPETEER_MCP_AVAILABLE = true;
      }
    } catch (error) {
      console.error("Error checking Puppeteer MCP server:", error);
      puppeteerAvailable = false;
    }
  }

  // Set up refresh interval
  if (refreshInterval > 0) {
    console.log(`Setting up refresh interval: ${refreshInterval}ms`);
    clearInterval(refreshIntervalId);
    refreshIntervalId = setInterval(() => {
      refreshData().catch((err) => {
        console.error("Error refreshing data:", err);
        for (const callback of eventListeners.error) {
          callback(err);
        }
      });
    }, refreshInterval);
  } else {
     console.log("Auto-refresh disabled.");
  }

  // Initial data fetch
  console.log("Fetching initial data...");
  try {
    await refreshData();
  } catch (error) {
    console.error("Error during initial data fetch:", error);
    for (const callback of eventListeners.error) {
      callback(error);
    }
  }

  // Emit initial connection status
  const connectionStatus = {
    clineServerConnected: mcpAvailable && !puppeteerAvailable, // If we only have MCP but not Puppeteer
    magicApiConnected: mcpAvailable && puppeteerAvailable, // If we have both MCP and Puppeteer
    usingMockData: !mcpAvailable || !puppeteerAvailable, // Using mock data if either is unavailable
  };
  for (const callback of eventListeners.connectionStatus) {
    callback(connectionStatus);
  }

  return connectionStatus;
}
