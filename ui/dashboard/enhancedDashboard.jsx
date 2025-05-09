import React, { useState, useEffect } from 'react';
import enhancedDashboardApi from './lib/enhancedDashboardApi.js';
import { dashboardConfig } from './lib/config.js';

// Import dashboard components
import MetricsPanel from './components/MetricsPanel.jsx';
import TokenUtilization from './components/TokenUtilization.jsx';
import CostTracker from './components/CostTracker.jsx';
import UsageStats from './components/UsageStats.jsx';
import ModelSelector from './components/ModelSelector.jsx';
import SettingsPanel from './components/SettingsPanel.jsx';

/**
 * Enhanced Dashboard Component for Cline AI Extension
 *
 * Comprehensive dashboard displaying AI usage metrics, token utilization,
 * cost tracking, and settings management in compliance with token optimization protocols
 */
export const EnhancedDashboard = () => {
  // Dashboard state
  const [dashboardData, setDashboardData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [connectionStatus, setConnectionStatus] = useState({
    clineServerConnected: false,
    magicApiConnected: false,
    usingMockData: true
  });

  // Layout state
  const [activeTab, setActiveTab] = useState('overview');
  const [collapsedSections, setCollapsedSections] = useState({});

  // Toggle section collapse
  const toggleSection = (sectionId) => {
    setCollapsedSections(prev => ({
      ...prev,
      [sectionId]: !prev[sectionId]
    }));
  };

  // Initialize dashboard on mount
  useEffect(() => {
    const initializeDashboard = async () => {
      try {
        setLoading(true);

        // Initialize API and fetch initial data
        const status = await enhancedDashboardApi.initialize(dashboardConfig.refreshInterval);
        setConnectionStatus(status);

        // Setup event listeners
        enhancedDashboardApi.addEventListener('dataUpdate', handleDataUpdate);
        enhancedDashboardApi.addEventListener('connectionStatus', handleConnectionUpdate);
        enhancedDashboardApi.addEventListener('error', handleError);

        // Get cached data if available
        const cachedData = enhancedDashboardApi.getCachedData();
        if (cachedData) {
          setDashboardData(cachedData);
        }

        setLoading(false);
      } catch (err) {
        console.error('Failed to initialize dashboard:', err);
        setError('Failed to initialize dashboard. Please try again later.');
        setLoading(false);
      }
    };

    initializeDashboard();

    // Clean up on unmount
    return () => {
      enhancedDashboardApi.removeEventListener('dataUpdate', handleDataUpdate);
      enhancedDashboardApi.removeEventListener('connectionStatus', handleConnectionUpdate);
      enhancedDashboardApi.removeEventListener('error', handleError);
      enhancedDashboardApi.cleanup();
    };
  }, []);

  // Event handlers
  const handleDataUpdate = (data) => {
    setDashboardData(data);
  };

  const handleConnectionUpdate = (status) => {
    setConnectionStatus(status);
  };

  const handleError = (err) => {
    console.error('Dashboard error:', err);
    setError(err.message || 'An error occurred');
  };

  // Handler for model selection
  const handleModelChange = async (model) => {
    try {
      const success = await enhancedDashboardApi.updateSelectedModel(model);
      if (!success) {
        setError('Failed to update model. Please try again.');
      }
    } catch (err) {
      console.error('Error updating model:', err);
      setError('Failed to update model. Please try again.');
    }
  };

  // Handler for settings changes
  const handleSettingChange = async (setting, value) => {
    try {
      const success = await enhancedDashboardApi.updateSetting(setting, value);
      if (!success) {
        setError('Failed to update setting. Please try again.');
      }
    } catch (err) {
      console.error('Error updating setting:', err);
      setError('Failed to update setting. Please try again.');
    }
  };

  // Handler for token budget changes
  const handleBudgetChange = async (budgetType, value) => {
    try {
      const success = await enhancedDashboardApi.updateTokenBudget(budgetType, value);
      if (!success) {
        setError('Failed to update token budget. Please try again.');
      }
    } catch (err) {
      console.error('Error updating token budget:', err);
      setError('Failed to update token budget. Please try again.');
    }
  };

  // Refresh data handler
  const handleRefresh = async () => {
    try {
      setLoading(true);
      await enhancedDashboardApi.refreshData();
      setLoading(false);
    } catch (err) {
      console.error('Error refreshing data:', err);
      setError('Failed to refresh data. Please try again.');
      setLoading(false);
    }
  };

  // Dismiss error handler
  const dismissError = () => {
    setError(null);
  };

  // Render connection status indicator
  const renderConnectionStatus = () => {
    const { clineServerConnected, usingMockData } = connectionStatus;

    return (
      <div className="connection-status">
        <div className="status-indicator">
          <div
            className={`status-dot ${clineServerConnected ? 'connected' : 'disconnected'}`}
            title={clineServerConnected ? 'Connected to Cline API' : 'Disconnected from Cline API'}
          ></div>
          <span className="status-text">
            {clineServerConnected ? 'Connected' : 'Disconnected'}
          </span>
        </div>
        {usingMockData && (
          <div className="mock-data-indicator">
            Using mock data
          </div>
        )}
      </div>
    );
  };

  // Render loading state
  if (loading && !dashboardData) {
    return (
      <div className="dashboard-loading">
        <div className="loading-spinner"></div>
        <div className="loading-text">Loading Cline AI Dashboard...</div>
      </div>
    );
  }

  // Extract data for components
  const metricsData = dashboardData?.metrics || {};
  const tokenData = dashboardData?.tokens || {};
  const costData = dashboardData?.costs || {};
  const usageData = dashboardData?.usage || {};
  const modelData = dashboardData?.models || {};
  const settings = dashboardData?.settings || {};

  return (
    <div className="enhanced-dashboard">
      {/* Dashboard Header */}
      <div className="dashboard-header">
        <div className="header-title">
          <h1>Cline AI Dashboard</h1>
          <div className="header-subtitle">
            Token Optimization and Analysis
          </div>
        </div>

        <div className="header-actions">
          {renderConnectionStatus()}

          <button
            className="refresh-button"
            onClick={handleRefresh}
            disabled={loading}
          >
            {loading ? 'Refreshing...' : 'Refresh Data'}
          </button>
        </div>
      </div>

      {/* Error Display */}
      {error && (
        <div className="error-container">
          <div className="error-message">{error}</div>
          <button className="error-dismiss" onClick={dismissError}>Dismiss</button>
        </div>
      )}

      {/* Tab Navigation */}
      <div className="dashboard-tabs">
        <button
          className={`tab-button ${activeTab === 'overview' ? 'active' : ''}`}
          onClick={() => setActiveTab('overview')}
        >
          Overview
        </button>
        <button
          className={`tab-button ${activeTab === 'usage' ? 'active' : ''}`}
          onClick={() => setActiveTab('usage')}
        >
          Usage Statistics
        </button>
        <button
          className={`tab-button ${activeTab === 'settings' ? 'active' : ''}`}
          onClick={() => setActiveTab('settings')}
        >
          Settings
        </button>
      </div>

      {/* Dashboard Content */}
      <div className="dashboard-content">
        {/* Overview Tab */}
        {activeTab === 'overview' && (
          <div className="overview-tab">
            <div className="metrics-section">
              <MetricsPanel
                metrics={{
                  ...metricsData,
                  tokenBudgets: tokenData.budgets,
                  costData: costData,
                  cacheEfficiency: tokenData.cacheEfficiency
                }}
              />
            </div>

            <div className="main-panels">
              <div className="panel token-panel">
                <TokenUtilization
                  tokenData={tokenData}
                  cacheData={tokenData.cacheEfficiency}
                />
              </div>

              <div className="panel cost-panel">
                <CostTracker costData={costData} />
              </div>
            </div>

            <div className="model-section">
              <ModelSelector
                modelData={modelData}
                onModelChange={handleModelChange}
              />
            </div>
          </div>
        )}

        {/* Usage Statistics Tab */}
        {activeTab === 'usage' && (
          <div className="usage-tab">
            <UsageStats usageData={usageData} />
          </div>
        )}

        {/* Settings Tab */}
        {activeTab === 'settings' && (
          <div className="settings-tab">
            <SettingsPanel
              settings={settings}
              tokenBudgets={tokenData}
              onSettingChange={handleSettingChange}
              onBudgetChange={handleBudgetChange}
            />
          </div>
        )}
      </div>

      {/* Dashboard Footer */}
      <div className="dashboard-footer">
        <div className="footer-info">
          <div className="footer-text">
            Cline AI Dashboard
          </div>
          <div className="footer-version">
            Version {dashboardConfig.version}
          </div>
        </div>

        <div className="footer-links">
          <a href="#" className="footer-link">Documentation</a>
          <a href="#" className="footer-link">Support</a>
          <a href="#" className="footer-link">Feedback</a>
        </div>
      </div>

      <style jsx>{`
        /* Dashboard Layout */
        .enhanced-dashboard {
          display: flex;
          flex-direction: column;
          font-family: var(--font-family);
          color: var(--text-color);
          background-color: var(--app-background);
          min-height: 100vh;
        }

        /* Header Styles */
        .dashboard-header {
          display: flex;
          justify-content: space-between;
          align-items: center;
          padding: 1.5rem;
          background-color: var(--card-background);
          border-bottom: 1px solid var(--border-color);
        }

        .header-title h1 {
          margin: 0;
          font-size: 1.5rem;
          font-weight: 600;
        }

        .header-subtitle {
          color: var(--text-secondary);
          font-size: 0.875rem;
          margin-top: 0.25rem;
        }

        .header-actions {
          display: flex;
          align-items: center;
          gap: 1.5rem;
        }

        .connection-status {
          display: flex;
          flex-direction: column;
          align-items: flex-end;
        }

        .status-indicator {
          display: flex;
          align-items: center;
          gap: 0.5rem;
        }

        .status-dot {
          width: 10px;
          height: 10px;
          border-radius: 50%;
        }

        .status-dot.connected {
          background-color: var(--success-color);
        }

        .status-dot.disconnected {
          background-color: var(--warning-color);
        }

        .status-text {
          font-size: 0.875rem;
          font-weight: 500;
        }

        .mock-data-indicator {
          font-size: 0.75rem;
          color: var(--text-secondary);
          margin-top: 0.25rem;
        }

        .refresh-button {
          padding: 0.5rem 1rem;
          background-color: var(--primary-color);
          color: white;
          border: none;
          border-radius: var(--border-radius-md);
          font-weight: 500;
          cursor: pointer;
          transition: background-color 0.15s;
        }

        .refresh-button:hover {
          background-color: var(--primary-dark);
        }

        .refresh-button:disabled {
          background-color: var(--border-color);
          cursor: not-allowed;
        }

        /* Error Display */
        .error-container {
          margin: 1rem;
          padding: 0.75rem 1rem;
          background-color: var(--error-light);
          border: 1px solid var(--error-color);
          border-radius: var(--border-radius-md);
          display: flex;
          justify-content: space-between;
          align-items: center;
        }

        .error-message {
          color: var(--error-color);
          font-weight: 500;
        }

        .error-dismiss {
          background: none;
          border: none;
          color: var(--error-color);
          cursor: pointer;
          font-weight: 500;
          padding: 0.25rem 0.5rem;
        }

        .error-dismiss:hover {
          text-decoration: underline;
        }

        /* Tabs Navigation */
        .dashboard-tabs {
          display: flex;
          border-bottom: 1px solid var(--border-color);
          padding: 0 1.5rem;
        }

        .tab-button {
          padding: 1rem 1.5rem;
          background: none;
          border: none;
          font-size: 1rem;
          font-weight: 500;
          color: var(--text-secondary);
          cursor: pointer;
          border-bottom: 2px solid transparent;
          transition: all 0.15s;
        }

        .tab-button:hover {
          color: var(--text-color);
        }

        .tab-button.active {
          color: var(--primary-color);
          border-bottom-color: var(--primary-color);
        }

        /* Dashboard Content */
        .dashboard-content {
          flex: 1;
          padding: 1.5rem;
          overflow-y: auto;
        }

        /* Overview Tab */
        .overview-tab {
          display: flex;
          flex-direction: column;
          gap: 1.5rem;
        }

        .metrics-section {
          margin-bottom: 1rem;
        }

        .main-panels {
          display: grid;
          grid-template-columns: repeat(2, 1fr);
          gap: 1.5rem;
          margin-bottom: 1.5rem;
        }

        .panel {
          background-color: var(--card-background);
          border-radius: var(--border-radius-md);
          padding: 1.5rem;
          box-shadow: var(--shadow-sm);
        }

        .model-section {
          margin-bottom: 1.5rem;
        }

        /* Loading State */
        .dashboard-loading {
          display: flex;
          flex-direction: column;
          align-items: center;
          justify-content: center;
          height: 100vh;
          background-color: var(--app-background);
        }

        .loading-spinner {
          width: 40px;
          height: 40px;
          border: 3px solid var(--border-color);
          border-radius: 50%;
          border-top-color: var(--primary-color);
          animation: spin 1s ease-in-out infinite;
          margin-bottom: 1rem;
        }

        @keyframes spin {
          to { transform: rotate(360deg); }
        }

        .loading-text {
          color: var(--text-secondary);
          font-size: 1rem;
        }

        /* Footer */
        .dashboard-footer {
          display: flex;
          justify-content: space-between;
          align-items: center;
          padding: 1rem 1.5rem;
          background-color: var(--card-background);
          border-top: 1px solid var(--border-color);
          margin-top: auto;
        }

        .footer-info {
          display: flex;
          flex-direction: column;
        }

        .footer-text {
          font-size: 0.875rem;
          font-weight: 500;
        }

        .footer-version {
          font-size: 0.75rem;
          color: var(--text-secondary);
          margin-top: 0.25rem;
        }

        .footer-links {
          display: flex;
          gap: 1.5rem;
        }

        .footer-link {
          color: var(--text-secondary);
          font-size: 0.875rem;
          text-decoration: none;
          transition: color 0.15s;
        }

        .footer-link:hover {
          color: var(--primary-color);
          text-decoration: underline;
        }

        /* Responsive Adjustments */
        @media (max-width: 1024px) {
          .main-panels {
            grid-template-columns: 1fr;
          }
        }

        @media (max-width: 768px) {
          .dashboard-header {
            flex-direction: column;
            align-items: flex-start;
            gap: 1rem;
          }

          .header-actions {
            width: 100%;
            justify-content: space-between;
          }

          .dashboard-tabs {
            padding: 0;
          }

          .tab-button {
            flex: 1;
            padding: 0.75rem 0.5rem;
            font-size: 0.875rem;
          }

          .dashboard-content {
            padding: 1rem;
          }
        }
      `}</style>
    </div>
  );
};

export default EnhancedDashboard;
