/**
 * MCP API for Cline AI Dashboard
 *
 * Interfaces with the Cline Dashboard MCP server to provide real data
 * Shares the same interface as mockApi for seamless switching between real and mock data
 * Leverages MCP tools and resources to fetch and update dashboard data
 */

import { use_mcp_tool, access_mcp_resource } from './lib/enhancedDashboardApi';

// Helper function to handle MCP errors consistently
const handleMcpError = (operation, error) => {
  console.error(`MCP operation failed (${operation}):`, error);
  throw new Error(`Failed to ${operation}: ${error.message || 'Unknown error'}`);
};

// MCP server name constant
const MCP_SERVER = 'cline-dashboard';

// MCP API methods
const mcpApi = {
  // Fetch all dashboard data from MCP resources
  fetchDashboardData: async () => {
    try {
      // First try to get all data in a single request
      try {
        const allData = await access_mcp_resource(MCP_SERVER, 'cline://dashboard/all');
        return allData;
      } catch (error) {
        console.warn('Failed to fetch complete dashboard data in single request, falling back to individual requests');
      }

      // If that fails, fetch individual data points
      const [tokens, costs, usage, models, settings, metrics] = await Promise.all([
        access_mcp_resource(MCP_SERVER, 'cline://dashboard/tokens'),
        access_mcp_resource(MCP_SERVER, 'cline://dashboard/costs'),
        access_mcp_resource(MCP_SERVER, 'cline://dashboard/usage'),
        access_mcp_resource(MCP_SERVER, 'cline://dashboard/models'),
        access_mcp_resource(MCP_SERVER, 'cline://dashboard/settings'),
        access_mcp_resource(MCP_SERVER, 'cline://dashboard/metrics')
      ]);

      return {
        tokens,
        costs,
        usage,
        models,
        settings,
        metrics
      };
    } catch (error) {
      handleMcpError('fetch dashboard data', error);
    }
  },

  // Update the selected model using the select_model tool
  updateSelectedModel: async (modelId) => {
    try {
      const result = await use_mcp_tool(MCP_SERVER, 'select_model', {
        model: modelId
      });

      // Optionally refresh the dashboard data after changing the model
      try {
        await this.refreshDashboardData();
      } catch (refreshError) {
        console.warn('Failed to refresh dashboard data after model update:', refreshError);
      }

      return result.success || false;
    } catch (error) {
      handleMcpError('update model', error);
    }
  },

  // Update a setting using the update_setting tool
  updateSetting: async (setting, value) => {
    try {
      const result = await use_mcp_tool(MCP_SERVER, 'update_setting', {
        setting,
        value
      });

      return result.success || false;
    } catch (error) {
      handleMcpError('update setting', error);
    }
  },

  // Update a token budget using the update_token_budget tool
  updateTokenBudget: async (budgetType, value) => {
    try {
      const result = await use_mcp_tool(MCP_SERVER, 'update_token_budget', {
        budgetType,
        value
      });

      return result.success || false;
    } catch (error) {
      handleMcpError('update token budget', error);
    }
  },

  // Refresh dashboard data
  refreshDashboardData: async () => {
    try {
      // Update the dashboard with fresh data
      await use_mcp_tool(MCP_SERVER, 'update_dashboard_data', {});

      // Then fetch the updated data
      return await this.fetchDashboardData();
    } catch (error) {
      handleMcpError('refresh dashboard data', error);
    }
  }
};

export default mcpApi;
