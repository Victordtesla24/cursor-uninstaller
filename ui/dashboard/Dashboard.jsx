import React, { useState, useEffect } from 'react';
import MetricsPanel from './components/MetricsPanel';
import TokenUtilization from './components/TokenUtilization';
import CostTracker from './components/CostTracker';
import UsageChart from './components/UsageChart';
import ModelSelector from './components/ModelSelector';
import SettingsPanel from './components/SettingsPanel';

// Import API modules
import mockApi from './mockApi';
import mcpApi from './mcpApi';

/**
 * Cline AI Dashboard
 *
 * Main dashboard layout component that integrates all dashboard panels
 * Fetches data, handles state management, and coordinates component interactions
 * Implements responsive layout with appropriate grid system
 */
export const Dashboard = () => {
  // Dashboard state
  const [dashboardData, setDashboardData] = useState(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState(null);
  const [useMockData, setUseMockData] = useState(false);

  // Get the appropriate API based on mode
  const api = useMockData ? mockApi : mcpApi;

  // Fetch dashboard data
  useEffect(() => {
    const fetchData = async () => {
      setIsLoading(true);
      setError(null);

      try {
        const data = await api.fetchDashboardData();
        setDashboardData(data);
      } catch (error) {
        console.error('Error fetching dashboard data:', error);
        setError('Failed to load dashboard data. Please try again later.');

        // If MCP API fails, fall back to mock data
        if (!useMockData) {
          try {
            const mockData = await mockApi.fetchDashboardData();
            setDashboardData(mockData);
            setUseMockData(true);
          } catch (mockError) {
            console.error('Error fetching mock data:', mockError);
          }
        }
      } finally {
        setIsLoading(false);
      }
    };

    fetchData();

    // Set up auto-refresh every 5 minutes
    const refreshInterval = setInterval(fetchData, 5 * 60 * 1000);

    return () => clearInterval(refreshInterval);
  }, [useMockData]);

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
      <div className="dashboard-container loading">
        <div className="loading-spinner"></div>
        <div className="loading-text">Loading dashboard data...</div>

        <style jsx>{`
          .dashboard-container.loading {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            min-height: 500px;
          }

          .loading-spinner {
            width: 40px;
            height: 40px;
            border: 4px solid var(--border-color);
            border-top: 4px solid var(--primary-color);
            border-radius: 50%;
            animation: spin 1s linear infinite;
            margin-bottom: 1rem;
          }

          .loading-text {
            color: var(--text-secondary);
          }

          @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
          }
        `}</style>
      </div>
    );
  }

  // Error state
  if (error && !dashboardData) {
    return (
      <div className="dashboard-container error">
        <div className="error-icon">⚠️</div>
        <div className="error-title">Error Loading Dashboard</div>
        <div className="error-message">{error}</div>
        <button className="retry-button" onClick={() => setUseMockData(!useMockData)}>
          {useMockData ? 'Try MCP Data' : 'Use Mock Data'}
        </button>

        <style jsx>{`
          .dashboard-container.error {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            min-height: 500px;
            text-align: center;
          }

          .error-icon {
            font-size: 3rem;
            margin-bottom: 1rem;
          }

          .error-title {
            font-size: 1.25rem;
            font-weight: 600;
            margin-bottom: 0.5rem;
          }

          .error-message {
            color: var(--text-secondary);
            margin-bottom: 1.5rem;
          }

          .retry-button {
            background-color: var(--primary-color);
            color: white;
            border: none;
            padding: 0.5rem 1rem;
            border-radius: var(--border-radius-sm);
            font-weight: 500;
            cursor: pointer;
            transition: background-color 0.2s;
          }

          .retry-button:hover {
            background-color: var(--primary-hover);
          }
        `}</style>
      </div>
    );
  }

  return (
    <div className="dashboard-container">
      <div className="dashboard-header">
        <h1>Cline AI Dashboard</h1>
        <div className="data-source-toggle">
          <span className="data-source-label">
            Data Source: <strong>{useMockData ? 'Mock Data' : 'Live Data'}</strong>
          </span>
          <button className="toggle-button" onClick={toggleDataSource}>
            Switch to {useMockData ? 'Live Data' : 'Mock Data'}
          </button>
        </div>
      </div>

      {/* Metrics Panel */}
      <div className="dashboard-section metrics-section">
        <MetricsPanel metrics={dashboardData?.metrics} />
      </div>

      {/* Two-column layout for TokenUtilization and CostTracker */}
      <div className="dashboard-row">
        <div className="dashboard-column">
          <TokenUtilization tokenData={dashboardData?.tokens} />
        </div>
        <div className="dashboard-column">
          <CostTracker costData={dashboardData?.costs} />
        </div>
      </div>

      {/* Usage Chart (full width) */}
      <div className="dashboard-section">
        <UsageChart usageData={dashboardData?.usage} />
      </div>

      {/* Two-column layout for ModelSelector and SettingsPanel */}
      <div className="dashboard-row">
        <div className="dashboard-column">
          <ModelSelector
            modelData={dashboardData?.models}
            onModelSelect={handleModelSelect}
          />
        </div>
        <div className="dashboard-column">
          <SettingsPanel
            settings={dashboardData?.settings}
            tokenBudgets={dashboardData?.tokens?.budgets}
            onUpdateSetting={handleUpdateSetting}
            onUpdateTokenBudget={handleUpdateTokenBudget}
          />
        </div>
      </div>

      {/* Footer */}
      <div className="dashboard-footer">
        <div className="footer-content">
          <div className="footer-text">Cline AI Extension Dashboard</div>
          <div className="footer-version">Version 1.0.0</div>
        </div>
      </div>

      <style jsx>{`
        .dashboard-container {
          display: flex;
          flex-direction: column;
          gap: 2rem;
          padding: 2rem;
          max-width: 1600px;
          margin: 0 auto;
        }

        .dashboard-header {
          display: flex;
          justify-content: space-between;
          align-items: center;
          flex-wrap: wrap;
          gap: 1rem;
        }

        .dashboard-header h1 {
          margin: 0;
          font-size: 1.75rem;
          font-weight: 700;
          color: var(--text-color);
        }

        .data-source-toggle {
          display: flex;
          align-items: center;
          gap: 1rem;
        }

        .data-source-label {
          font-size: 0.875rem;
          color: var(--text-secondary);
        }

        .toggle-button {
          background-color: var(--background-color);
          border: 1px solid var(--border-color);
          color: var(--text-color);
          padding: 0.375rem 0.75rem;
          border-radius: var(--border-radius-sm);
          font-size: 0.875rem;
          cursor: pointer;
          transition: all 0.2s;
        }

        .toggle-button:hover {
          background-color: var(--background-color-light);
          border-color: var(--border-color-hover);
        }

        .dashboard-row {
          display: grid;
          grid-template-columns: repeat(2, 1fr);
          gap: 2rem;
        }

        .dashboard-section {
          margin-bottom: 0;
        }

        .dashboard-footer {
          margin-top: 1rem;
          padding-top: 1.5rem;
          border-top: 1px solid var(--border-color);
        }

        .footer-content {
          display: flex;
          justify-content: space-between;
          align-items: center;
          color: var(--text-secondary);
          font-size: 0.875rem;
        }

        /* Responsive adjustments */
        @media (max-width: 1024px) {
          .dashboard-container {
            padding: 1.5rem;
            gap: 1.5rem;
          }
        }

        @media (max-width: 768px) {
          .dashboard-row {
            grid-template-columns: 1fr;
            gap: 1.5rem;
          }

          .dashboard-header {
            flex-direction: column;
            align-items: flex-start;
          }

          .data-source-toggle {
            flex-direction: column;
            align-items: flex-start;
            gap: 0.5rem;
          }
        }

        @media (max-width: 480px) {
          .dashboard-container {
            padding: 1rem;
            gap: 1.25rem;
          }

          .dashboard-header h1 {
            font-size: 1.5rem;
          }
        }
      `}</style>

      {/* Global Styles */}
      <style jsx global>{`
        :root {
          --primary-color: #007bff;
          --primary-hover: #0069d9;
          --primary-light: rgba(0, 123, 255, 0.1);
          --success-color: #28a745;
          --warning-color: #ffc107;
          --error-color: #dc3545;
          --text-color: #212529;
          --text-secondary: #6c757d;
          --background-color: #f8f9fa;
          --background-color-light: #f1f3f5;
          --card-background: #ffffff;
          --border-color: #dee2e6;
          --border-color-hover: #adb5bd;
          --border-radius-sm: 0.25rem;
          --border-radius-md: 0.5rem;
          --border-radius-lg: 1rem;
          --shadow-sm: 0 1px 3px rgba(0, 0, 0, 0.1);
          --shadow-md: 0 4px 6px rgba(0, 0, 0, 0.1);
        }

        /* Optional: Dark mode support */
        @media (prefers-color-scheme: dark) {
          :root {
            --primary-color: #0d6efd;
            --primary-hover: #0b5ed7;
            --primary-light: rgba(13, 110, 253, 0.2);
            --success-color: #198754;
            --warning-color: #ffc107;
            --error-color: #dc3545;
            --text-color: #f8f9fa;
            --text-secondary: #adb5bd;
            --background-color: #212529;
            --background-color-light: #2c3034;
            --card-background: #343a40;
            --border-color: #495057;
            --border-color-hover: #6c757d;
          }
        }

        body {
          margin: 0;
          padding: 0;
          font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Oxygen,
            Ubuntu, Cantarell, "Fira Sans", "Droid Sans", "Helvetica Neue", sans-serif;
          line-height: 1.5;
          color: var(--text-color);
          background-color: var(--background-color-light);
        }

        * {
          box-sizing: border-box;
        }

        button, input, select, textarea {
          font-family: inherit;
        }
      `}</style>
    </div>
  );
};

export default Dashboard;
