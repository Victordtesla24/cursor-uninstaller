import React, { useState, useEffect } from 'react';
import CostTracker from './components/CostTracker.jsx';
import MetricsPanel from './components/MetricsPanel.jsx';
import TokenUtilization from './components/TokenUtilization.jsx';
import UsageStats from './components/UsageStats.jsx';
import ModelSelector from './components/ModelSelector.jsx';
import SettingsPanel from './components/SettingsPanel.jsx';
import Header from './components/Header.jsx';
import './styles.css';

/**
 * Main dashboard component for Cline AI extension
 * Integrates all dashboard components and manages application state
 * Implements the token optimization visualization dashboard
 */
export const Dashboard = () => {
  // Dashboard state
  const [dashboardData, setDashboardData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [viewMode, setViewMode] = useState('overview');
  const [lastUpdated, setLastUpdated] = useState(null);
  const [isDarkMode, setIsDarkMode] = useState(false);
  const [sessionTime, setSessionTime] = useState(0);

  // Load dashboard data from MCP
  const loadDashboardData = async () => {
    setLoading(true);
    try {
      // Dynamically import to avoid loading during SSR
      const { fetchDashboardData } = await import('./magic-mcp-integration.js');
      const data = await fetchDashboardData();

      setDashboardData(data);
      setLastUpdated(new Date());
      setError(null);
    } catch (err) {
      console.error('Error loading dashboard data:', err);
      setError('Failed to load dashboard data. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  // Handle manual refresh
  const handleRefresh = () => {
    loadDashboardData();
  };

  // Handle model selection change
  const handleModelChange = async (model) => {
    if (!model) return;

    try {
      setLoading(true);
      const { updateSelectedModel } = await import('./magic-mcp-integration.js');
      const success = await updateSelectedModel(model);

      if (success) {
        await loadDashboardData();
      } else {
        setError('Failed to update model selection. Please try again.');
      }
    } catch (err) {
      console.error('Error updating model:', err);
      setError('An error occurred while updating the model.');
    } finally {
      setLoading(false);
    }
  };

  // Handle setting toggle
  const handleSettingChange = async (setting, value) => {
    try {
      setLoading(true);
      const { updateSetting } = await import('./magic-mcp-integration.js');
      const success = await updateSetting(setting, value);

      if (success) {
        await loadDashboardData();
      } else {
        setError('Failed to update setting. Please try again.');
      }
    } catch (err) {
      console.error('Error updating setting:', err);
      setError('An error occurred while updating settings.');
    } finally {
      setLoading(false);
    }
  };

  // Handle token budget update
  const handleBudgetUpdate = async (budgetType, value) => {
    try {
      setLoading(true);
      const { updateTokenBudget } = await import('./magic-mcp-integration.js');
      const success = await updateTokenBudget(budgetType, value);

      if (success) {
        await loadDashboardData();
      } else {
        setError('Failed to update token budget. Please try again.');
      }
    } catch (err) {
      console.error('Error updating token budget:', err);
      setError('An error occurred while updating token budget.');
    } finally {
      setLoading(false);
    }
  };

  // Initial data load
  useEffect(() => {
    loadDashboardData();

    // Set up periodic refresh (every 5 minutes)
    const refreshInterval = setInterval(() => {
      loadDashboardData();
    }, 5 * 60 * 1000);

    return () => clearInterval(refreshInterval);
  }, []);

  // Extract relevant data for components
  const getComponentData = () => {
    if (!dashboardData) {
      return {
        metrics: {},
        tokenData: {},
        cacheData: {},
        costData: {},
        usageData: {},
        modelData: {},
        settings: {}
      };
    }

    return {
      metrics: {
        dailyUsage: dashboardData.usage?.daily || [],
        tokenBudgets: dashboardData.tokens?.budgets || {},
        cacheEfficiency: dashboardData.tokens?.cacheEfficiency || {},
        costData: dashboardData.costs || {},
        activeRequests: dashboardData.metrics?.activeRequests || 0,
        systemHealth: dashboardData.metrics?.systemHealth || 'optimal',
        responseTime: dashboardData.metrics?.averageResponseTime || 0,
        lastCompletion: dashboardData.metrics?.lastCompletion || null
      },
      tokenData: dashboardData.tokens?.budgets || {},
      cacheData: dashboardData.tokens?.cacheEfficiency || {},
      costData: dashboardData.costs || {},
      usageData: dashboardData.usage || {},
      modelData: {
        currentModel: dashboardData.models?.selected || '',
        availableModels: dashboardData.models?.available || [],
        modelStats: dashboardData.models?.stats || {}
      },
      settings: dashboardData.settings || {}
    };
  };

  const {
    metrics,
    tokenData,
    cacheData,
    costData,
    usageData,
    modelData,
    settings
  } = getComponentData();

  // Render loading state
  if (loading && !dashboardData) {
    return (
      <div className={`dashboard loading`} data-testid="dashboard-container">
        <div className="loader"></div>
        <div className="loading-text">Loading dashboard data...</div>
      </div>
    );
  }

  const toggleTheme = () => {
    setIsDarkMode(!isDarkMode);
  };

  return (
    <div className={`dashboard-container ${isDarkMode ? 'dark-mode' : 'light-mode'}`} data-testid="dashboard-container">
      {error && (
        <div className="error-banner">
          <span>{error}</span>
          <button onClick={() => setError(null)}>Dismiss</button>
        </div>
      )}

      <Header
        systemHealth={metrics.systemHealth}
        activeRequests={metrics.activeRequests}
        viewMode={viewMode}
        onViewModeChange={setViewMode}
        onRefresh={handleRefresh}
        lastUpdated={lastUpdated}
        appName="Cline AI Dashboard"
        isDarkMode={isDarkMode}
        onThemeToggle={toggleTheme}
        sessionTime={sessionTime}
      />

      {viewMode === 'overview' && (
        <div className="dashboard-overview">
          <MetricsPanel metrics={metrics} className="dashboard-section" />
          <CostTracker costData={costData} className="dashboard-section" />
          <TokenUtilization
            tokenData={tokenData}
            cacheData={cacheData}
            className="dashboard-section"
          />
        </div>
      )}

      {viewMode === 'detailed' && (
        <div className="dashboard-detailed">
          <div className="metrics-row">
            <MetricsPanel metrics={metrics} className="dashboard-section" />
            <CostTracker costData={costData} className="dashboard-section" />
          </div>
          <div className="usage-row">
            <UsageStats usageData={usageData} className="dashboard-section full-width" />
          </div>
          <div className="model-row">
            <ModelSelector
              modelData={modelData}
              onModelChange={handleModelChange}
              className="dashboard-section"
            />
            <TokenUtilization
              tokenData={tokenData}
              cacheData={cacheData}
              className="dashboard-section"
            />
          </div>
        </div>
      )}

      {viewMode === 'settings' && (
        <div className="dashboard-settings">
          <SettingsPanel
            settings={settings}
            tokenBudgets={tokenData}
            onSettingChange={handleSettingChange}
            onBudgetChange={handleBudgetUpdate}
            className="dashboard-section full-width"
          />
        </div>
      )}

      <div className="dashboard-footer">
        <div className="footer-info">
          Cline AI Dashboard v1.0.0
        </div>
        {loading && (
          <div className="updating-indicator">
            <div className="updating-spinner"></div>
            <span>Updating...</span>
          </div>
        )}
      </div>
    </div>
  );
};

// Keep default export for backward compatibility with existing tests
export default Dashboard;
