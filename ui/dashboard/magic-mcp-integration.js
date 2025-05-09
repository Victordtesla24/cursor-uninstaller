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

import { useState, useEffect } from 'react';
import mockApi from './mockApi';

// Utility function to safely parse JSON with fallback
const safeJsonParse = (jsonString, fallback = null) => {
  if (!jsonString) return fallback;

  try {
    return JSON.parse(jsonString);
  } catch (e) {
    console.error('Error parsing JSON:', e);
    return fallback;
  }
};

/**
 * Hook for using the Magic MCP Dashboard functionality
 * @returns {Object} Dashboard data, loading state, error state, and update functions
 */
export function useMagicMcpDashboard() {
  const [data, setData] = useState(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState(null);
  const [lastUpdated, setLastUpdated] = useState(null);

  // Fetch dashboard data from the MCP server
  const fetchData = async () => {
    setIsLoading(true);
    setError(null);

    try {
      if (!window.cline || !window.cline.callMcpFunction) {
        const mockData = await mockApi.fetchDashboardData();
        setData(mockData);
        setLastUpdated(new Date());
        setIsLoading(false);
        return;
      }

      const response = await window.cline.callMcpFunction({
        serverName: 'cline-dashboard',
        resourceUri: 'cline://dashboard/all'
      });

      const parsedData = safeJsonParse(response);

      if (!parsedData) {
        const mockData = await mockApi.fetchDashboardData();
        setData(mockData);
      } else {
        setData(parsedData);
      }

      setLastUpdated(new Date());
    } catch (err) {
      console.error('Error fetching dashboard data:', err);
      setError(err.message || 'Failed to fetch dashboard data');
    } finally {
      setIsLoading(false);
    }
  };

  // Initialize component by fetching data
  useEffect(() => {
    fetchData();
  }, []);

  /**
   * Update the selected AI model
   * @param {string} model - Model identifier (e.g., 'claude-3.7-sonnet', 'gemini-2.5-flash')
   * @returns {Promise<boolean>} Success status
   */
  const updateModel = async (model) => {
    try {
      if (!window.cline || !window.cline.callMcpFunction) {
        setError(`Cannot update model: MCP server not available`);
        return false;
      }

      await window.cline.callMcpFunction({
        serverName: 'cline-dashboard',
        toolName: 'select_model',
        args: {
          model: model
        }
      });

      // Refresh the data to show the changes
      await fetchData();
      return true;
    } catch (err) {
      console.error(`Error updating model to ${model}:`, err);
      setError(`Failed to switch to ${model}`);
      return false;
    }
  };

  /**
   * Update a Cline AI setting
   * @param {string} setting - Setting name (e.g., 'autoModelSelection', 'cachingEnabled')
   * @param {boolean} value - Setting value
   * @returns {Promise<boolean>} Success status
   */
  const updateSetting = async (setting, value) => {
    // Validate setting name
    const validSettings = [
      'autoModelSelection',
      'cachingEnabled',
      'contextWindowOptimization',
      'outputMinimization',
      'notifyOnLowBudget',
      'safetyChecks'
    ];

    if (!validSettings.includes(setting)) {
      setError(`Invalid setting: ${setting}`);
      return false;
    }

    try {
      if (!window.cline || !window.cline.callMcpFunction) {
        setError(`Cannot update setting: MCP server not available`);
        return false;
      }

      await window.cline.callMcpFunction({
        serverName: 'cline-dashboard',
        toolName: 'update_setting',
        args: {
          setting: setting,
          value: value
        }
      });

      // Refresh the data to show the changes
      await fetchData();
      return true;
    } catch (err) {
      console.error(`Error updating setting ${setting}:`, err);
      setError(`Failed to update ${setting}`);
      return false;
    }
  };

  /**
   * Update a token budget
   * @param {string} budgetType - Budget type ('codeCompletion', 'errorResolution', etc.)
   * @param {number} value - Budget value in tokens
   * @returns {Promise<boolean>} Success status
   */
  const updateTokenBudget = async (budgetType, value) => {
    // Validate budget type
    const validBudgetTypes = [
      'codeCompletion',
      'errorResolution',
      'architecture',
      'thinking'
    ];

    if (!validBudgetTypes.includes(budgetType)) {
      setError(`Invalid budget type: ${budgetType}`);
      return false;
    }

    // Apply constraints based on budget type
    if (budgetType === 'codeCompletion') {
      if (value < 100 || value > 1000) {
        setError(`Invalid budget value for ${budgetType}. Must be between 100 and 1000`);
        return false;
      }
    } else {
      // For other budget types
      if (value < 100 || value > 5000) {
        setError(`Invalid budget value for ${budgetType}. Must be between 100 and 5000`);
        return false;
      }
    }

    try {
      if (!window.cline || !window.cline.callMcpFunction) {
        setError(`Cannot update token budget: MCP server not available`);
        return false;
      }

      await window.cline.callMcpFunction({
        serverName: 'cline-dashboard',
        toolName: 'update_token_budget',
        args: {
          budgetType: budgetType,
          value: value
        }
      });

      // Refresh the data to show the changes
      await fetchData();
      return true;
    } catch (err) {
      console.error(`Error updating token budget for ${budgetType}:`, err);
      setError(`Failed to update ${budgetType} budget`);
      return false;
    }
  };

  /**
   * Refresh dashboard data with fresh metrics
   * @returns {Promise<boolean>} Success status
   */
  const refreshData = async () => {
    try {
      if (!window.cline || !window.cline.callMcpFunction) {
        setError(`Cannot refresh data: MCP server not available`);
        return false;
      }

      await window.cline.callMcpFunction({
        serverName: 'cline-dashboard',
        toolName: 'update_dashboard_data',
        args: {}
      });

      // Fetch the updated data
      await fetchData();
      return true;
    } catch (err) {
      console.error('Error refreshing dashboard data:', err);
      setError('Failed to refresh dashboard data');
      return false;
    }
  };

  return {
    data,
    isLoading,
    error,
    lastUpdated,
    updateModel,
    updateSetting,
    updateTokenBudget,
    refreshData
  };
}

/**
 * Fetch dashboard data from the MCP server
 * For backward compatibility with non-hook usage
 * @returns {Promise<Object>} Dashboard data
 */
export const fetchDashboardData = async () => {
  try {
    if (!window.cline || !window.cline.callMcpFunction) {
      return mockApi.fetchDashboardData();
    }

    const response = await window.cline.callMcpFunction({
      serverName: 'cline-dashboard',
      resourceUri: 'cline://dashboard/all'
    });

    const parsedData = safeJsonParse(response);

    if (!parsedData) {
      return mockApi.fetchDashboardData();
    }

    return parsedData;
  } catch (error) {
    console.error('Error fetching dashboard data:', error);
    return mockApi.fetchDashboardData();
  }
};

// For backward compatibility
export const updateSelectedModel = async (model) => {
  if (!window.cline || !window.cline.callMcpFunction) {
    return false;
  }

  try {
    await window.cline.callMcpFunction({
      serverName: 'cline-dashboard',
      toolName: 'select_model',
      args: {
        model: model
      }
    });
    return true;
  } catch (error) {
    console.error('Error updating model:', error);
    return false;
  }
};

// Initialize the dashboard by checking MCP server availability
export const initializeDashboard = async () => {
  try {
    if (!window.cline || !window.cline.callMcpFunction) {
      console.log('Running in standalone mode with mock data');
      return false;
    }

    const response = await window.cline.callMcpFunction({
      serverName: 'cline-dashboard',
      resourceUri: 'cline://dashboard/metrics'
    });

    if (response) {
      console.log('Successfully connected to Cline AI MCP server');
      return true;
    }

    console.log('Running with mock data due to MCP connection failure');
    return false;
  } catch (error) {
    console.error('Failed to initialize MCP connection:', error);
    console.log('Running with mock data due to MCP connection failure');
    return false;
  }
};
