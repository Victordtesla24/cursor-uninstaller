/**
 * MCP API for Cline AI Dashboard
 *
 * Interfaces with the Cline Dashboard MCP server to provide real data
 * Shares the same interface as mockApi for seamless switching between real and mock data
 * Leverages MCP tools and resources to fetch and update dashboard data
 */

import { use_mcp_tool, access_mcp_resource } from './lib/enhancedDashboardApi';
import mockApi from './mockApi';

// Helper function to handle MCP errors consistently
const handleMcpError = (operation, error) => {
  console.error(`MCP operation failed (${operation}):`, error);
  return false;
};

// MCP server name constant
const MCP_SERVER = 'cline-dashboard';
// Fetch all dashboard data from MCP resources
export const fetchDashboardData = async () => {
  try {
    // First try to get all data in a single request
    try {
      if (!window.cline || !window.cline.callMcpFunction) {
        const mockData = await mockApi.fetchDashboardData();
        return mockData;
      }

      const response = await window.cline.callMcpFunction({
        serverName: MCP_SERVER,
        resourceUri: 'cline://dashboard/all'
      });

      if (!response) {
        const mockData = await mockApi.fetchDashboardData();
        return mockData;
      }

      try {
        return JSON.parse(response);
      } catch (parseError) {
        console.warn('Failed to parse MCP response:', parseError);
        const mockData = await mockApi.fetchDashboardData();
        return mockData;
      }
    } catch (error) {
      console.warn('Failed to fetch complete dashboard data in single request, falling back to mockApi');
      const mockData = await mockApi.fetchDashboardData();
      return mockData;
    }
  } catch (error) {
    console.error('Error fetching dashboard data:', error);
    const mockData = await mockApi.fetchDashboardData();
    return mockData;
  }
};

// Update the selected model using the select_model tool
export const updateSelectedModel = async (modelId) => {
  try {
    if (!window.cline || !window.cline.callMcpFunction) {
      return false;
    }

    await window.cline.callMcpFunction({
      serverName: MCP_SERVER,
      toolName: 'select_model',
      args: {
        model: modelId
      }
    });

    return true;
  } catch (error) {
    return handleMcpError('update model', error);
  }
};

// Update a setting using the update_setting tool
export const updateSetting = async (setting, value) => {
  try {
    if (!window.cline || !window.cline.callMcpFunction) {
      return false;
    }

    await window.cline.callMcpFunction({
      serverName: MCP_SERVER,
      toolName: 'update_setting',
      args: {
        setting,
        value
      }
    });

    return true;
  } catch (error) {
    return handleMcpError('update setting', error);
  }
};

// Update a token budget using the update_token_budget tool
export const updateTokenBudget = async (budgetType, value) => {
  try {
    if (!window.cline || !window.cline.callMcpFunction) {
      return false;
    }

    await window.cline.callMcpFunction({
      serverName: MCP_SERVER,
      toolName: 'update_token_budget',
      args: {
        budgetType,
        value
      }
    });

    return true;
  } catch (error) {
    return handleMcpError('update token budget', error);
  }
};

// Refresh dashboard data
export const refreshDashboardData = async () => {
  try {
    if (!window.cline || !window.cline.callMcpFunction) {
      return false;
    }

    await window.cline.callMcpFunction({
      serverName: MCP_SERVER,
      toolName: 'update_dashboard_data',
      args: {}
    });

    return true;
  } catch (error) {
    return handleMcpError('refresh dashboard data', error);
  }
};

// For backward compatibility
export default {
  fetchDashboardData,
  updateSelectedModel,
  updateSetting,
  updateTokenBudget,
  refreshDashboardData
};
