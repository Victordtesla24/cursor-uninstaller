import React, { useState, useEffect } from 'react';
import MetricsPanel from './components/MetricsPanel';
import TokenUtilization from './components/TokenUtilization';
import CostTracker from './components/CostTracker';
import UsageChart from './components/UsageChart';
import ModelSelector from './components/ModelSelector';
import SettingsPanel from './components/SettingsPanel';
import StyledJsx from './components/StyledJsx';
import Header from './components/Header';
import mockApi from './mockApi';
import * as mcpApi from './mcpApi';
import './styles.css';

/**
 * Cline AI Dashboard
 *
 * Main dashboard layout component that integrates all dashboard panels
 * Fetches data, handles state management, and coordinates component interactions
 * Implements responsive layout with appropriate grid system
 */
// Use named export for consistency with other components
export const Dashboard = () => {
  // Dashboard state
  const [dashboardData, setDashboardData] = useState(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState(null);
  const [useMockData, setUseMockData] = useState(false);
  const [refreshing, setRefreshing] = useState(false);
  const [lastRefresh, setLastRefresh] = useState(null);

  // Get the appropriate API based on mode
  const api = useMockData ? mockApi : mcpApi;

  // Fetch dashboard data
  const fetchData = async (isRefresh = false) => {
    if (isRefresh) {
      setRefreshing(true);
    } else {
      setIsLoading(true);
    }
    setError(null);

    try {
      const data = await api.fetchDashboardData();
      setDashboardData(data);
      setLastRefresh(new Date());
    } catch (error) {
      console.error('Error fetching dashboard data:', error);
      setError('Failed to load dashboard data. Please try again later.');

      // If MCP API fails, fall back to mock data
      if (!useMockData) {
        try {
          console.log('Falling back to mock data due to API error');
          const mockData = await mockApi.fetchDashboardData();
          setDashboardData(mockData);
          setUseMockData(true);
        } catch (mockError) {
          console.error('Error fetching mock data:', mockError);
        }
      }
    } finally {
      setIsLoading(false);
      setRefreshing(false);
    }
  };

  useEffect(() => {
    fetchData();

    // Set up auto-refresh every 5 minutes
    const refreshInterval = setInterval(() => fetchData(true), 5 * 60 * 1000);

    return () => clearInterval(refreshInterval);
  }, [useMockData]);

  // Handle manual refresh
  const handleRefresh = () => {
    fetchData(true);
  };

  // Handle model selection
  const handleModelSelect = async (modelId) => {
    try {
      const success = await api.updateSelectedModel(modelId);

      if (success) {
        // Update local state to reflect the change immediately
        setDashboardData(prevData => ({
          ...prevData,
          models: {
            ...prevData.models,
            selected: modelId
          }
        }));
      }
    } catch (error) {
      console.error('Error updating model:', error);
    }
  };

  // Handle setting update
  const handleUpdateSetting = async (setting, value) => {
    try {
      const success = await api.updateSetting(setting, value);

      if (success) {
        // Update local state to reflect the change immediately
        setDashboardData(prevData => ({
          ...prevData,
          settings: {
            ...prevData.settings,
            [setting]: value
          }
        }));
      }
    } catch (error) {
      console.error('Error updating setting:', error);
    }
  };

  // Handle token budget update
  const handleUpdateTokenBudget = async (budgetType, value) => {
    try {
      const success = await api.updateTokenBudget(budgetType, value);

      if (success) {
        // Update local state to reflect the change immediately
        setDashboardData(prevData => {
          const newBudgets = { ...prevData.tokens.budgets };
          const currentBudget = newBudgets[budgetType];

          newBudgets[budgetType] = {
            ...currentBudget,
            budget: value,
            remaining: Math.max(0, value - currentBudget.used)
          };

          return {
            ...prevData,
            tokens: {
              ...prevData.tokens,
              budgets: newBudgets
            }
          };
        });
      }
    } catch (error) {
      console.error('Error updating token budget:', error);
    }
  };

  // Toggle between mock and MCP data
  const toggleDataSource = () => {
    setUseMockData(!useMockData);
  };

  // Loading state
  if (isLoading && !dashboardData) {
    return (
      <div className="flex flex-col items-center justify-center min-h-[500px] dashboard loading" data-testid="dashboard-container">
        <div className="w-10 h-10 border-4 border-border border-t-primary rounded-full animate-spin mb-4" data-testid="loading-spinner"></div>
        <div className="text-muted-foreground">Loading dashboard data...</div>
      </div>
    );
  }

  // Error state
  if (error && !dashboardData) {
    return (
      <div className="flex flex-col items-center justify-center min-h-[500px] text-center">
        <div className="text-5xl mb-4">⚠️</div>
        <div className="text-xl font-semibold mb-2">Error Loading Dashboard</div>
        <div className="text-muted-foreground mb-6">{error}</div>
        <button
          className="bg-primary text-white px-4 py-2 rounded hover:bg-primary/90 transition-colors font-medium"
          onClick={() => setUseMockData(!useMockData)}
        >
          {useMockData ? 'Try MCP Data' : 'Use Mock Data'}
        </button>
      </div>
    );
  }

  return (
    <div className="flex flex-col gap-8 p-8 max-w-[1600px] mx-auto" data-testid="dashboard-container">
      <div className="flex justify-between items-center flex-wrap gap-4">
        <h1 className="text-2xl font-bold m-0">Cline AI Dashboard</h1>
        <div className="flex items-center gap-4 flex-wrap">
          <div className="flex items-center gap-4">
            <span className="text-sm text-muted-foreground">
              {useMockData ? 'Using mock data' : 'Connected'}
            </span>
            <button
              className="bg-background border border-border text-foreground px-3 py-1.5 rounded text-sm
                hover:bg-background-secondary transition-colors"
              onClick={toggleDataSource}
            >
              Switch to {useMockData ? 'Live Data' : 'Mock Data'}
            </button>
          </div>
          <button
            className={`bg-background border border-border text-foreground px-3 py-1.5 rounded text-sm
              hover:bg-background-secondary transition-colors ${refreshing ? 'opacity-70 cursor-not-allowed' : ''}`}
            onClick={handleRefresh}
            disabled={refreshing}
          >
            {refreshing ? 'Refreshing...' : 'Refresh Data'}
          </button>
        </div>
      </div>

      {lastRefresh && (
        <div className="text-xs text-muted-foreground -mt-6">
          Last updated: {lastRefresh.toLocaleTimeString()}
        </div>
      )}

      <div className="flex border-b border-border -mt-4 mb-4">
        <div className="px-6 py-3 text-sm cursor-pointer border-b-2 border-primary text-primary font-medium">Overview</div>
        <div className="px-6 py-3 text-sm cursor-pointer border-b-2 border-transparent">Usage Statistics</div>
        <div className="px-6 py-3 text-sm cursor-pointer border-b-2 border-transparent">Settings</div>
      </div>

      {/* Metrics Panel */}
      <div className="bg-card shadow-sm rounded-lg p-6">
        <MetricsPanel metrics={dashboardData?.metrics} />
      </div>

      {/* Two-column layout for TokenUtilization and CostTracker */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
        <div className="bg-card shadow-sm rounded-lg p-6">
          <TokenUtilization tokenData={dashboardData?.tokens} />
        </div>
        <div className="bg-card shadow-sm rounded-lg p-6">
          <CostTracker costData={dashboardData?.costs} />
        </div>
      </div>

      {/* Usage Chart (full width) */}
      <div className="bg-card shadow-sm rounded-lg p-6">
        <UsageChart usageData={dashboardData?.usage} />
      </div>

      {/* Two-column layout for ModelSelector and SettingsPanel */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
        <div className="bg-card shadow-sm rounded-lg p-6">
          <ModelSelector
            modelData={dashboardData?.models}
            onModelSelect={handleModelSelect}
          />
        </div>
        <div className="bg-card shadow-sm rounded-lg p-6">
          <SettingsPanel
            settings={dashboardData?.settings}
            tokenBudgets={dashboardData?.tokens?.budgets}
            onUpdateSetting={handleUpdateSetting}
            onUpdateTokenBudget={handleUpdateTokenBudget}
          />
        </div>
      </div>

      {/* Footer */}
      <div className="mt-4 pt-6 border-t border-border">
        <div className="flex justify-between items-center text-muted-foreground text-sm">
          <div>Cline AI Extension Dashboard</div>
          <div>Version 1.0.0</div>
        </div>
      </div>
    </div>
  );
};

// Keep default export for backward compatibility with existing imports
export default Dashboard;
