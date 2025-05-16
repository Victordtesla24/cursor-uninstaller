/**
 * MCP API for Cline AI Dashboard
 *
 * Interfaces with the Cline Dashboard MCP server to provide real data
 * Shares the same interface as mockApi for seamless switching between real and mock data
 * Leverages MCP tools and resources to fetch and update dashboard data
 */

import mockApi from './mockApi';

// Helper function to handle MCP errors consistently
const handleMcpError = (operation, error) => {
  // Only log errors in non-test environments
  if (process.env.NODE_ENV !== 'test') {
    console.error(`MCP operation failed (${operation}):`, error);
  }
  return false;
};

// Utility function to safely parse JSON
const safeJsonParse = (jsonString, fallback = null) => {
  if (!jsonString) return fallback;

  try {
    return JSON.parse(jsonString);
  } catch (e) {
    // Only log in non-test environments
    if (process.env.NODE_ENV !== 'test') {
      console.warn('Failed to parse MCP response:', e);
    }
    return fallback;
  }
};

// Check if MCP is available - improved detection logic
const isMcpAvailable = () => {
  try {
    return typeof window !== 'undefined' &&
           window?.cline?.callMcpFunction !== undefined &&
           typeof window.cline.callMcpFunction === 'function';
  } catch (e) {
    return false;
  }
};

// MCP server name constant
const MCP_SERVER = 'cline-dashboard';

// Safe MCP function call wrapper
const safeMcpCall = async (operation, callback, fallback) => {
  try {
    if (!isMcpAvailable()) {
      console.warn(`MCP not available for operation: ${operation}`);
      return fallback();
    }

    return await callback();
  } catch (error) {
    console.error(`Error in MCP operation (${operation}):`, error);
    return fallback();
  }
};

// Fetch all dashboard data from MCP resources
export const fetchDashboardData = async () => {
  return safeMcpCall(
    'fetch dashboard data',
    async () => {
      const response = await window.cline.callMcpFunction({
        serverName: MCP_SERVER,
        resourceUri: 'cline://dashboard/all'
      });

      if (!response) {
        throw new Error('Empty response from MCP');
      }

      const parsedData = safeJsonParse(response);
      if (!parsedData) {
        throw new Error('Failed to parse MCP response');
      }

      return parsedData;
    },
    async () => {
      // Use mock data as fallback
      return await mockApi.fetchDashboardData();
    }
  );
};

// Update the selected model using the select_model tool
export const updateSelectedModel = async (modelId) => {
  return safeMcpCall(
    'update model',
    async () => {
      await window.cline.callMcpFunction({
        serverName: MCP_SERVER,
        toolName: 'select_model',
        args: {
          model: modelId
        }
      });
      return true;
    },
    () => true // Return success even with mock data
  );
};

// Update a setting using the update_setting tool
export const updateSetting = async (setting, value) => {
  return safeMcpCall(
    'update setting',
    async () => {
      await window.cline.callMcpFunction({
        serverName: MCP_SERVER,
        toolName: 'update_setting',
        args: {
          setting,
          value
        }
      });
      return true;
    },
    () => true // Return success even with mock data
  );
};

// Update a token budget using the update_token_budget tool
export const updateTokenBudget = async (budgetType, value) => {
  return safeMcpCall(
    'update token budget',
    async () => {
      await window.cline.callMcpFunction({
        serverName: MCP_SERVER,
        toolName: 'update_token_budget',
        args: {
          budgetType,
          value
        }
      });
      return true;
    },
    () => true // Return success even with mock data
  );
};

// Refresh dashboard data
export const refreshDashboardData = async () => {
  return safeMcpCall(
    'refresh dashboard data',
    async () => {
      await window.cline.callMcpFunction({
        serverName: MCP_SERVER,
        toolName: 'update_dashboard_data',
        args: {}
      });
      return true;
    },
    () => true // Return success even with mock data
  );
};

// For backward compatibility
export default {
  fetchDashboardData,
  updateSelectedModel,
  updateSetting,
  updateTokenBudget,
  refreshDashboardData
};
