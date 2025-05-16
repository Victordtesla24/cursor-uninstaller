import React, { useState, useEffect, useCallback, useRef } from 'react';
import {
  Header,
  CostTracker,
  ModelSelector,
  SettingsPanel,
  TokenUtilization,
  UsageChart,
  UsageStats,
  EnhancedHeader,
  MetricsPanel,
  TokenBudgetRecommendations,
  EnhancedAnalyticsDashboard,
  ModelPerformanceComparison
} from './components';
import {
  Card,
  CardHeader,
  CardContent,
  CardFooter,
  CardTitle,
  CardDescription,
  Separator,
  Button,
  Tooltip,
  TooltipTrigger,
  TooltipContent,
  TooltipProvider
} from './components/ui';
import * as enhancedDashboardApi from './lib/enhancedDashboardApi';
import { dashboardConfig } from "./lib/config.js";
import { cn } from "./lib/utils.js";
import {
  LayoutDashboard,
  BarChart3,
  Settings as SettingsIcon,
  RefreshCw,
  AlertCircle,
  ChevronDown,
  Wifi,
  WifiOff,
  ArrowUpRight,
  ArrowDownRight,
  Moon,
  Sun,
  BarChart2,
  Lightbulb,
  LineChart
} from "lucide-react";

// Animated Tabs component for view selection
function AnimatedTabs({ tabs, activeTab, onChange }) {
  return (
    <div className="relative flex items-center rounded-lg bg-muted/50 p-1">
      {tabs.map((tab) => (
        <button
          key={tab.id}
          onClick={() => onChange(tab.id)}
          className={cn(
            "relative z-10 flex items-center gap-2 rounded-md px-4 py-2 text-sm font-medium transition-all duration-200",
            activeTab === tab.id
              ? "text-primary-foreground"
              : "text-muted-foreground hover:text-foreground"
          )}
        >
          {tab.icon}
          <span>{tab.label}</span>

          {activeTab === tab.id && (
            <span className="absolute inset-0 z-[-1] rounded-md bg-primary shadow-sm animate-in fade-in duration-200" />
          )}
        </button>
      ))}
    </div>
  );
}
// End AnimatedTabs component

// Status Badge component for connection status
function StatusBadge({ connected, label }) {
  return (
    <div
      className={cn(
        "inline-flex items-center gap-1.5 rounded-full px-2.5 py-0.5 text-xs font-medium transition-colors",
        connected
          ? "bg-emerald-100 text-emerald-800 dark:bg-emerald-900/30 dark:text-emerald-400"
          : "bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-400"
      )}
    >
      {connected ? <Wifi className="h-3 w-3" /> : <WifiOff className="h-3 w-3" />}
      {label}
    </div>
  );
}

// Section Header component
function SectionHeader({ title, isCollapsed, onToggleCollapse, icon }) {
  return (
    <div
      className="flex cursor-pointer items-center justify-between border-b border-border p-4"
      onClick={onToggleCollapse}
    >
      <div className="flex items-center gap-2">
        {icon}
        <h3 className="text-lg font-medium">{title}</h3>
      </div>
      <ChevronDown
        className={cn(
          "h-5 w-5 text-muted-foreground transition-transform",
          !isCollapsed && "rotate-180"
        )}
      />
    </div>
  );
}

/**
 * Enhanced Dashboard Component
 *
 * This is the main dashboard component that integrates all dashboard
 * functionality into a single component. It features:
 * - Real-time data updates
 * - Model selection
 * - Settings management
 * - Cost tracking
 * - Token utilization visualization
 * - Usage statistics
 * - Budget recommendations
 * - Advanced analytics
 * - Model performance comparison
 *
 * It merges functionality from both Dashboard.jsx and index.jsx into a single
 * consolidated component that serves as the primary entry point for the dashboard.
 */
const EnhancedDashboard = () => {
  // Application state
  const [dashboardData, setDashboardData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [settings, setSettings] = useState({});
  const [selectedModel, setSelectedModel] = useState(null);
  const [showAdvancedSettings, setShowAdvancedSettings] = useState(false);
  const [refreshTimestamp, setRefreshTimestamp] = useState(Date.now());
  const [tokenBudget, setTokenBudget] = useState(null);
  const [useMockData, setUseMockData] = useState(false); // Flag for switching between mock and real data
  const [viewMode, setViewMode] = useState('overview'); // From index.jsx: Control which view is shown
  const [darkMode, setDarkMode] = useState(() => {
    // Initialize from localStorage or system preference
    const savedMode = localStorage.getItem('darkMode');
    if (savedMode !== null) {
      return savedMode === 'true';
    }
    // Check system preference as fallback
    return window.matchMedia('(prefers-color-scheme: dark)').matches;
  });

  // Refs for managing API calls
  const refreshTimeoutRef = useRef(null);
  const isInitialLoad = useRef(true);
  const isPendingRefresh = useRef(false);

  // Set dark mode class on body
  useEffect(() => {
    if (darkMode) {
      document.documentElement.classList.add('dark');
    } else {
      document.documentElement.classList.remove('dark');
    }
    // Save preference to localStorage
    localStorage.setItem('darkMode', darkMode.toString());
  }, [darkMode]);

  // Function to toggle dark mode
  const toggleDarkMode = useCallback(() => {
    setDarkMode(prev => !prev);
  }, []);

  // Function to toggle between mock and real data (from Dashboard.jsx)
  const toggleDataSource = useCallback(() => {
    setUseMockData(prev => !prev);
  }, []);
  // End toggleDataSource

  // Function to fetch dashboard data
  const fetchDashboardData = useCallback(async () => {
    if (isPendingRefresh.current) return;

    isPendingRefresh.current = true;
    setLoading(isInitialLoad.current);

    try {
      // Use the consolidated enhancedDashboardApi with mock data fallback capability
      const data = await enhancedDashboardApi.refreshData(useMockData);

      if (data) {
        setDashboardData(data);
        setSettings(data.settings || {});
        setSelectedModel(data.models?.selected);
        setTokenBudget(data.tokens?.budgets?.total?.budget);
        setError(null);
      }
    } catch (err) {
      console.error('Error fetching dashboard data:', err);
      setError(err.message || 'Failed to load dashboard data');

      // Only show error state if we have no existing data
      if (!dashboardData) {
        setDashboardData(null);
      }
    } finally {
      setLoading(false);
      isInitialLoad.current = false;
      isPendingRefresh.current = false;
      setRefreshTimestamp(Date.now());
    }
  }, [dashboardData, useMockData]);

  // Initial data load
  useEffect(() => {
    fetchDashboardData();

    // Set up polling for updates
    const setupPolling = () => {
      const pollingInterval = dashboardConfig.refreshInterval || 30000; // 30 seconds default

      if (refreshTimeoutRef.current) {
        clearTimeout(refreshTimeoutRef.current);
      }

      refreshTimeoutRef.current = setTimeout(() => {
        fetchDashboardData();
        setupPolling();
      }, pollingInterval);
    };

    setupPolling();

    // Clean up on unmount
    return () => {
      if (refreshTimeoutRef.current) {
        clearTimeout(refreshTimeoutRef.current);
      }
    };
  }, [fetchDashboardData]);

  // Handle model selection
  const handleModelChange = useCallback(async (modelId) => {
    try {
      const success = await enhancedDashboardApi.updateSelectedModel(modelId);
      if (success) {
        setSelectedModel(modelId);
        // Trigger a refresh after a short delay to get updated data
        setTimeout(fetchDashboardData, 500);
      }
    } catch (err) {
      console.error('Error changing model:', err);
      setError(`Failed to change model: ${err.message}`);
    }
  }, [fetchDashboardData]);

  // Handle settings updates
  const handleSettingChange = useCallback(async (key, value) => {
    try {
      const success = await enhancedDashboardApi.updateSetting(key, value);
      if (success) {
        setSettings(prev => ({
          ...prev,
          [key]: value
        }));
      }
    } catch (err) {
      console.error(`Error updating setting ${key}:`, err);
      setError(`Failed to update setting: ${err.message}`);
    }
  }, []);

  // Handle token budget updates
  const handleTokenBudgetChange = useCallback(async (budgetType, value) => {
    try {
      const success = await enhancedDashboardApi.updateTokenBudget(budgetType, value);
      if (success) {
        setTokenBudget(value);
        // Refresh to get updated token budget data
        fetchDashboardData();
      }
    } catch (err) {
      console.error('Error updating token budget:', err);
      setError(`Failed to update token budget: ${err.message}`);
    }
  }, [fetchDashboardData]);

  // Force a manual refresh
  const handleRefresh = useCallback(() => {
    if (!isPendingRefresh.current) {
      fetchDashboardData();
    }
  }, [fetchDashboardData]);

  // Toggle advanced settings visibility
  const toggleAdvancedSettings = useCallback(() => {
    setShowAdvancedSettings(prev => !prev);
  }, []);

  // Handle view mode change (from index.jsx)
  const handleViewModeChange = useCallback((mode) => {
    setViewMode(mode);
  }, []);

  // Handle applying a budget recommendation
  const handleApplyRecommendation = useCallback(async (category, recommendedBudget) => {
    try {
      const success = await enhancedDashboardApi.updateTokenBudget(category, recommendedBudget);
      if (success) {
        if (category === 'total') {
          setTokenBudget(recommendedBudget);
        }
        // Refresh to get updated token budget data
        fetchDashboardData();
      }
    } catch (err) {
      console.error('Error applying budget recommendation:', err);
      setError(`Failed to apply recommendation: ${err.message}`);
    }
  }, [fetchDashboardData]);

  // Show loading state if initial load is in progress
  if (loading && isInitialLoad.current) {
    return (
      <div className="flex h-screen w-full items-center justify-center bg-background">
        <div className="flex flex-col items-center gap-4">
          <div className="h-10 w-10 animate-spin rounded-full border-4 border-primary border-t-transparent"></div>
          <h2 className="text-xl font-semibold">Loading Dashboard...</h2>
        </div>
      </div>
    );
  }

  // Show error state if no data is available
  if (error && !dashboardData) {
    return (
      <div className="flex h-screen w-full flex-col items-center justify-center gap-4 bg-background p-6">
        <div className="flex h-12 w-12 items-center justify-center rounded-full bg-red-100 text-red-600 dark:bg-red-900/30 dark:text-red-400">
          <AlertCircle className="h-6 w-6" />
        </div>
        <h2 className="text-xl font-semibold">Error Loading Dashboard</h2>
        <p className="text-center text-muted-foreground">{error}</p>
        <Button
          onClick={() => setUseMockData(!useMockData)}
          className="mt-2"
        >
          {useMockData ? 'Try MCP Data' : 'Use Mock Data'}
        </Button>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-background">
      <div className="mx-auto max-w-screen-xl p-4">
        {/* Header */}
        <header className="mb-6 flex flex-col gap-4 border-b pb-4 md:flex-row md:items-center md:justify-between">
          <div className="flex items-center gap-3">
            <h1 className="text-2xl font-bold tracking-tight">Cline AI Dashboard</h1>
            <StatusBadge
              connected={!useMockData}
              label={useMockData ? "Mock Data" : "Live API"}
            />
          </div>

          <div className="flex flex-col gap-4 sm:flex-row sm:items-center">
            <AnimatedTabs
              tabs={[
                { id: 'overview', label: 'Overview', icon: <LayoutDashboard className="h-4 w-4" /> },
                { id: 'detailed', label: 'Detailed', icon: <BarChart3 className="h-4 w-4" /> },
                { id: 'analytics', label: 'Analytics', icon: <LineChart className="h-4 w-4" /> },
                { id: 'comparison', label: 'Models', icon: <BarChart2 className="h-4 w-4" /> },
                { id: 'recommendations', label: 'Recommendations', icon: <Lightbulb className="h-4 w-4" /> },
                { id: 'settings', label: 'Settings', icon: <SettingsIcon className="h-4 w-4" /> }
              ]}
              activeTab={viewMode}
              onChange={setViewMode}
            />

            <div className="flex items-center gap-2">
              <TooltipProvider>
                <Tooltip>
                  <TooltipTrigger asChild>
                    <Button
                      variant="outline"
                      size="icon"
                      onClick={toggleDarkMode}
                      className="h-9 w-9"
                    >
                      {darkMode ? <Sun className="h-4 w-4" /> : <Moon className="h-4 w-4" />}
                    </Button>
                  </TooltipTrigger>
                  <TooltipContent side="bottom">
                    <p>{darkMode ? 'Switch to light mode' : 'Switch to dark mode'}</p>
                  </TooltipContent>
                </Tooltip>
              </TooltipProvider>

              <TooltipProvider>
                <Tooltip>
                  <TooltipTrigger asChild>
                    <Button
                      variant="outline"
                      size="icon"
                      onClick={handleRefresh}
                      disabled={isPendingRefresh.current}
                      className="h-9 w-9"
                    >
                      <RefreshCw className={`h-4 w-4 ${isPendingRefresh.current ? 'animate-spin' : ''}`} />
                    </Button>
                  </TooltipTrigger>
                  <TooltipContent side="bottom">
                    <p>Refresh dashboard data</p>
                  </TooltipContent>
                </Tooltip>
              </TooltipProvider>

              {useMockData && (
                <TooltipProvider>
                  <Tooltip>
                    <TooltipTrigger asChild>
                      <Button
                        variant="outline"
                        size="sm"
                        onClick={toggleDataSource}
                        className="gap-1 text-xs"
                      >
                        <Wifi className="h-3 w-3" />
                        Try Live API
                      </Button>
                    </TooltipTrigger>
                    <TooltipContent side="bottom">
                      <p>Attempt to connect to MCP server</p>
                    </TooltipContent>
                  </Tooltip>
                </TooltipProvider>
              )}
            </div>
          </div>
        </header>

        {/* Show error banner for non-fatal errors */}
        {error && dashboardData && (
          <div className="mb-6 flex items-center justify-between rounded-lg bg-red-100 px-4 py-3 text-red-800 dark:bg-red-900/30 dark:text-red-400">
            <div className="flex items-center gap-2">
              <AlertCircle className="h-5 w-5" />
              <span>{error}</span>
            </div>
            <Button
              variant="ghost"
              size="sm"
              onClick={() => setError(null)}
              className="h-8 hover:bg-red-200 dark:hover:bg-red-900/50"
            >
              Dismiss
            </Button>
          </div>
        )}

        {/* Main dashboard content based on view mode */}
        <main className="pb-8">
          {viewMode === 'overview' && (
            <div className="space-y-6">
              {/* Top metrics */}
              <div className="grid grid-cols-1 gap-6 md:grid-cols-3">
                {/* Metrics Panel */}
                <Card className="col-span-1 md:col-span-3">
                  <CardHeader>
                    <CardTitle>Performance Metrics</CardTitle>
                    <CardDescription>Key system performance indicators</CardDescription>
                  </CardHeader>
                  <CardContent>
                    {dashboardData && (
                      <MetricsPanel
                        metrics={dashboardData.metrics}
                        darkMode={darkMode}
                      />
                    )}
                  </CardContent>
                </Card>

                {/* Token Utilization */}
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-base">
                      Token Utilization
                    </CardTitle>
                    <CardDescription>Current token usage efficiency</CardDescription>
                  </CardHeader>
                  <CardContent>
                    {dashboardData && (
                      <TokenUtilization
                        tokenData={dashboardData.tokens}
                        selectedModel={selectedModel}
                      />
                    )}
                  </CardContent>
                </Card>

                {/* Cost Tracker */}
                <Card className="col-span-1 md:col-span-2">
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-base">
                      Cost Tracking
                    </CardTitle>
                    <CardDescription>Budget and current spending</CardDescription>
                  </CardHeader>
                  <CardContent>
                    {dashboardData && (
                      <CostTracker
                        costData={dashboardData.costs}
                        tokenBudget={tokenBudget}
                        onBudgetChange={handleTokenBudgetChange}
                      />
                    )}
                  </CardContent>
                </Card>
              </div>

              {/* Usage Chart */}
              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2 text-base">
                    Usage Trends
                  </CardTitle>
                  <CardDescription>Token usage over time</CardDescription>
                </CardHeader>
                <CardContent className="h-[300px]">
                  {dashboardData && (
                    <UsageChart
                      usageData={dashboardData.usage}
                      darkMode={darkMode}
                    />
                  )}
                </CardContent>
              </Card>
            </div>
          )}

          {viewMode === 'detailed' && (
            <div className="space-y-6">
              {/* Detailed Metrics & Stats */}
              <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-base">
                      Performance Metrics
                    </CardTitle>
                    <CardDescription>System performance data</CardDescription>
                  </CardHeader>
                  <CardContent>
                    {dashboardData && (
                      <MetricsPanel
                        metrics={dashboardData.metrics}
                        darkMode={darkMode}
                      />
                    )}
                  </CardContent>
                </Card>

                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-base">
                      Usage Statistics
                    </CardTitle>
                    <CardDescription>Key usage metrics</CardDescription>
                  </CardHeader>
                  <CardContent>
                    {dashboardData && (
                      <UsageStats
                        usageData={dashboardData.usage}
                        lastUpdate={refreshTimestamp}
                      />
                    )}
                  </CardContent>
                </Card>
              </div>

              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2 text-base">
                    Usage Trends
                  </CardTitle>
                  <CardDescription>Token usage over time</CardDescription>
                </CardHeader>
                <CardContent className="h-[300px]">
                  {dashboardData && (
                    <UsageChart
                      usageData={dashboardData.usage}
                      darkMode={darkMode}
                    />
                  )}
                </CardContent>
              </Card>

              <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-base">
                      Model Selection
                    </CardTitle>
                    <CardDescription>Choose a language model</CardDescription>
                  </CardHeader>
                  <CardContent>
                    {dashboardData && (
                      <ModelSelector
                        models={dashboardData.models}
                        selectedModel={selectedModel}
                        onModelSelect={handleModelChange}
                      />
                    )}
                  </CardContent>
                </Card>

                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-base">
                      Token Utilization
                    </CardTitle>
                    <CardDescription>Current token usage efficiency</CardDescription>
                  </CardHeader>
                  <CardContent>
                    {dashboardData && (
                      <TokenUtilization
                        tokenData={dashboardData.tokens}
                        selectedModel={selectedModel}
                      />
                    )}
                  </CardContent>
                </Card>
              </div>
            </div>
          )}

          {viewMode === 'analytics' && (
            <div className="space-y-6">
              {dashboardData && (
                <EnhancedAnalyticsDashboard
                  usageData={dashboardData.usage}
                  modelsData={dashboardData.models}
                  darkMode={darkMode}
                />
              )}
            </div>
          )}

          {viewMode === 'comparison' && (
            <div className="space-y-6">
              {dashboardData && (
                <ModelPerformanceComparison
                  modelsData={dashboardData.models}
                  usageData={dashboardData.usage}
                  onModelSelect={handleModelChange}
                  darkMode={darkMode}
                />
              )}
            </div>
          )}

          {viewMode === 'recommendations' && (
            <div className="space-y-6">
              {dashboardData && (
                <TokenBudgetRecommendations
                  tokenData={dashboardData.tokens}
                  onApplyRecommendation={handleApplyRecommendation}
                  darkMode={darkMode}
                />
              )}
            </div>
          )}

          {viewMode === 'settings' && (
            <Card>
              <CardHeader>
                <div className="flex flex-col items-start justify-between gap-2 sm:flex-row sm:items-center">
                  <div>
                    <CardTitle className="flex items-center gap-2">
                      <SettingsIcon className="h-5 w-5" />
                      Dashboard Settings
                    </CardTitle>
                    <CardDescription>Configure dashboard behavior</CardDescription>
                  </div>

                  <TooltipProvider>
                    <Tooltip>
                      <TooltipTrigger asChild>
                        <Button
                          variant="outline"
                          size="sm"
                          onClick={toggleAdvancedSettings}
                        >
                          {showAdvancedSettings ? 'Hide Advanced' : 'Show Advanced'}
                        </Button>
                      </TooltipTrigger>
                      <TooltipContent>
                        <p>Toggle visibility of advanced settings</p>
                      </TooltipContent>
                    </Tooltip>
                  </TooltipProvider>
                </div>
              </CardHeader>

              <CardContent>
                {dashboardData && (
                  <SettingsPanel
                    settings={settings}
                    tokenBudgets={dashboardData.tokens?.budgets}
                    onSettingChange={handleSettingChange}
                    onBudgetChange={handleTokenBudgetChange}
                    showAdvanced={showAdvancedSettings}
                  />
                )}
              </CardContent>

              <CardFooter className="flex flex-col-reverse items-start justify-between gap-4 sm:flex-row sm:items-center">
                <span className="text-sm text-muted-foreground">
                  Last updated: {new Date(refreshTimestamp).toLocaleTimeString()}
                </span>

                <Button
                  onClick={handleRefresh}
                  disabled={isPendingRefresh.current}
                  className="flex items-center gap-2"
                >
                  <RefreshCw className={`h-4 w-4 ${isPendingRefresh.current ? 'animate-spin' : ''}`} />
                  {isPendingRefresh.current ? 'Refreshing...' : 'Refresh Dashboard'}
                </Button>
              </CardFooter>
            </Card>
          )}
        </main>

        {/* Dashboard footer */}
        <footer className="mt-auto border-t pt-6">
          <div className="flex flex-col items-center justify-between gap-4 text-sm text-muted-foreground sm:flex-row">
            <div>
              Cline AI Dashboard v{dashboardConfig.version || '1.0.0'}
            </div>

            {loading && !isInitialLoad.current && (
              <div className="flex items-center gap-2">
                <div className="h-3 w-3 animate-spin rounded-full border-2 border-primary border-t-transparent"></div>
                <span>Updating...</span>
              </div>
            )}

            <div className="flex items-center gap-2">
              <StatusBadge
                connected={!useMockData}
                label={useMockData ? "Using mock data" : "Connected to live API"}
              />
            </div>
          </div>
        </footer>
      </div>
    </div>
  );
};

export default EnhancedDashboard;
