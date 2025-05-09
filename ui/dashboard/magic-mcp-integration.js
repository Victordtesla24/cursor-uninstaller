/**
 * MCP Integration Module for Cline AI Dashboard
 * Handles all communication with the MCP server for retrieving and updating dashboard data
 *
 * This module provides functions to:
 * - Fetch dashboard metrics and data
 * - Update AI model selection
 * - Update token optimization settings
 * - Update token budgets
 * - Refresh dashboard data
 */

// Utility function to safely parse JSON with fallback
const safeJsonParse = (jsonString, fallback = {}) => {
  try {
    return JSON.parse(jsonString);
  } catch (e) {
    console.error('Error parsing JSON:', e);
    return fallback;
  }
};

/**
 * Fetch dashboard data from the MCP server
 * @returns {Promise<Object>} Dashboard data including metrics, usage, tokens, costs, etc.
 */
export const fetchDashboardData = async () => {
  try {
    // Check if window.cline exists (VSCode extension context)
    if (typeof window !== 'undefined' && window.cline && window.cline.mcp) {
      const response = await window.cline.mcp.fetchDashboardData();

      if (!response || typeof response !== 'string') {
        console.error('Invalid response from MCP server:', response);
        // Fall back to mock data if necessary
        return await import('./mockApi.js').then(module => module.fetchDashboardData());
      }

      return safeJsonParse(response);
    }

    // If not in VSCode or window.cline is not available, use mock data
    return await import('./mockApi.js').then(module => module.fetchDashboardData());
  } catch (error) {
    console.error('Error fetching dashboard data from MCP server:', error);
    // Fall back to mock data in case of error
    return await import('./mockApi.js').then(module => module.fetchDashboardData());
  }
};

/**
 * Update the selected AI model
 * @param {string} model - Model identifier (e.g., 'claude-3.7-sonnet', 'gemini-2.5-flash')
 * @returns {Promise<boolean>} Success status
 */
export const updateSelectedModel = async (model) => {
  try {
    // Check if window.cline exists (VSCode extension context)
    if (typeof window !== 'undefined' && window.cline && window.cline.mcp) {
      await window.cline.mcp.selectModel({ model });
      return true;
    }

    // For non-VSCode environments, simulate success
    console.log(`Model would be updated to: ${model}`);
    return true;
  } catch (error) {
    console.error('Error updating selected model:', error);
    return false;
  }
};

/**
 * Update a Cline AI setting
 * @param {string} setting - Setting name (e.g., 'autoModelSelection', 'cachingEnabled')
 * @param {boolean} value - Setting value
 * @returns {Promise<boolean>} Success status
 */
export const updateSetting = async (setting, value) => {
  try {
    // Check if window.cline exists (VSCode extension context)
    if (typeof window !== 'undefined' && window.cline && window.cline.mcp) {
      await window.cline.mcp.updateSetting({ setting, value });
      return true;
    }

    // For non-VSCode environments, simulate success
    console.log(`Setting ${setting} would be updated to: ${value}`);
    return true;
  } catch (error) {
    console.error('Error updating setting:', error);
    return false;
  }
};

/**
 * Update a token budget
 * @param {string} budgetType - Budget type ('codeCompletion', 'errorResolution', etc.)
 * @param {number} value - Budget value in tokens
 * @returns {Promise<boolean>} Success status
 */
export const updateTokenBudget = async (budgetType, value) => {
  try {
    // Check if window.cline exists (VSCode extension context)
    if (typeof window !== 'undefined' && window.cline && window.cline.mcp) {
      await window.cline.mcp.updateTokenBudget({ budgetType, value });
      return true;
    }

    // For non-VSCode environments, simulate success
    console.log(`Token budget for ${budgetType} would be updated to: ${value}`);
    return true;
  } catch (error) {
    console.error('Error updating token budget:', error);
    return false;
  }
};

/**
 * Refresh dashboard data with fresh metrics
 * @returns {Promise<boolean>} Success status
 */
export const refreshDashboardData = async () => {
  try {
    // Check if window.cline exists (VSCode extension context)
    if (typeof window !== 'undefined' && window.cline && window.cline.mcp) {
      await window.cline.mcp.updateDashboardData();
      return true;
    }

    // For non-VSCode environments, simulate success
    console.log('Dashboard data would be refreshed');
    return true;
  } catch (error) {
    console.error('Error refreshing dashboard data:', error);
    return false;
  }
};

/**
 * Initialize the dashboard by checking MCP server availability
 * @returns {Promise<boolean>} Initialization status
 */
export const initializeDashboard = async () => {
  try {
    // Check if window.cline exists (VSCode extension context)
    if (typeof window !== 'undefined' && window.cline && window.cline.mcp) {
      // Attempt to connect to MCP server
      await window.cline.mcp.ping();
      console.log('Successfully connected to Cline AI MCP server');
      return true;
    }

    // For non-VSCode environments, log that we're using mock data
    console.log('Running in standalone mode with mock data');
    return false;
  } catch (error) {
    console.error('Failed to initialize MCP connection:', error);
    console.log('Running with mock data due to MCP connection failure');
    return false;
  }
};
