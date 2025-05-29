import React, { useState, useEffect, useCallback, useRef, useMemo } from 'react';
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
  TooltipProvider,
  Badge,
  Switch
} from '../components/ui/index.js';
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
  LineChart,
  Activity,
  TrendingUp,
  Menu,
  Bell,
  Search,
  Filter,
  Download,
  Eye,
  Sparkles,
  Clock,
  DollarSign,
  Database,
  Cpu,
  Shield,
  Gauge
} from 'lucide-react';

// Animated Tabs component for view selection
function AnimatedTabs({ tabs, activeTab, onChange }) {
  return (
    <div className="relative bg-gradient-to-r from-slate-50 to-slate-100 dark:from-slate-900 dark:to-slate-800 rounded-xl p-1.5 shadow-inner border border-slate-200 dark:border-slate-700">
      <div className="flex space-x-1">
        {tabs.map((tab) => (
          <button
            key={tab.id}
            onClick={() => onChange(tab.id)}
            className={`
              relative px-6 py-3 rounded-lg text-sm font-medium transition-all duration-300 ease-out
              flex items-center space-x-2 min-w-[120px] justify-center
              ${activeTab === tab.id
                ? 'bg-white dark:bg-slate-800 text-slate-900 dark:text-white shadow-lg shadow-slate-200/50 dark:shadow-slate-900/50 border border-slate-200 dark:border-slate-600 scale-[1.02]'
                : 'text-slate-600 dark:text-slate-400 hover:text-slate-900 dark:hover:text-white hover:bg-white/50 dark:hover:bg-slate-700/50'
              }
            `}
          >
            <span className={`text-lg ${activeTab === tab.id ? 'animate-pulse' : ''}`}>
              {tab.icon}
            </span>
            <span className="font-semibold">{tab.label}</span>
            {activeTab === tab.id && (
              <div className="absolute inset-0 rounded-lg bg-gradient-to-r from-blue-500/10 to-purple-500/10 animate-pulse" />
            )}
          </button>
        ))}
      </div>
    </div>
  );
}

// Status Badge component for connection status
function StatusBadge({ connected, label, type = 'default' }) {
  const getStatusStyles = () => {
    if (connected) {
      return {
        badge: 'bg-gradient-to-r from-emerald-500 to-green-500 text-white shadow-lg shadow-emerald-500/25',
        dot: 'bg-white animate-pulse',
        glow: 'shadow-emerald-500/50'
      };
    } else {
      return {
        badge: 'bg-gradient-to-r from-amber-500 to-orange-500 text-white shadow-lg shadow-amber-500/25',
        dot: 'bg-white animate-ping',
        glow: 'shadow-amber-500/50'
      };
    }
  };

  const styles = getStatusStyles();

  return (
    <div className={`inline-flex items-center px-4 py-2 rounded-full text-sm font-medium ${styles.badge} ${styles.glow} transition-all duration-300`}>
      <div className={`w-2 h-2 rounded-full mr-2 ${styles.dot}`} />
      <span>{label}</span>
    </div>
  );
}

// Section Header component
function SectionHeader({ title, isCollapsed, onToggleCollapse, icon, actions, subtitle }) {
  return (
    <div className="flex items-center justify-between mb-6 group">
      <div className="flex items-center space-x-3">
        <div className="p-2 rounded-xl bg-gradient-to-br from-blue-500 to-purple-600 text-white shadow-lg shadow-blue-500/25">
          {icon}
        </div>
        <div>
          <h2 className="text-xl font-bold text-slate-900 dark:text-white group-hover:text-blue-600 dark:group-hover:text-blue-400 transition-colors duration-200">
            {title}
          </h2>
          {subtitle && (
            <p className="text-sm text-slate-600 dark:text-slate-400 mt-1">{subtitle}</p>
          )}
        </div>
      </div>
      <div className="flex items-center space-x-3">
        {actions}
        {onToggleCollapse && (
          <Button
            variant="ghost"
            size="sm"
            onClick={onToggleCollapse}
            className="p-2 hover:bg-slate-100 dark:hover:bg-slate-800 rounded-lg transition-all duration-200"
          >
            <ChevronDown
              className={`h-4 w-4 transition-transform duration-300 ${
                isCollapsed ? 'rotate-180' : ''
              }`}
            />
          </Button>
        )}
      </div>
    </div>
  );
}

/**
 * Enhanced Header Component with modern design
 */
function DashboardHeader({ darkMode, onToggleDarkMode, onRefresh, refreshing, lastUpdated, connectionStatus }) {
  return (
    <div className="sticky top-0 z-50 bg-white/80 dark:bg-slate-900/80 backdrop-blur-xl border-b border-slate-200 dark:border-slate-700 mb-8">
      <div className="px-8 py-6">
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-4">
            <div className="flex items-center space-x-3">
              <div className="p-3 rounded-2xl bg-gradient-to-br from-blue-600 via-purple-600 to-pink-600 text-white shadow-xl shadow-blue-500/25">
                <Sparkles className="h-8 w-8" />
              </div>
              <div>
                <h1 className="text-3xl font-bold bg-gradient-to-r from-slate-900 to-slate-600 dark:from-white dark:to-slate-300 bg-clip-text text-transparent">
                  Cline AI Dashboard
                </h1>
                <p className="text-sm text-slate-600 dark:text-slate-400 mt-1">
                  Advanced AI monitoring and optimization platform
                </p>
              </div>
            </div>
          </div>
          
          <div className="flex items-center space-x-4">
            <div className="flex items-center space-x-3 px-4 py-2 bg-slate-100 dark:bg-slate-800 rounded-xl">
              <StatusBadge 
                connected={connectionStatus?.clineServerConnected} 
                label={connectionStatus?.usingMockData ? "Mock Data" : "Live API"}
              />
            </div>
            
            <Separator orientation="vertical" className="h-8" />
            
            <div className="flex items-center space-x-2">
              <Button
                variant="ghost"
                size="sm"
                onClick={onRefresh}
                disabled={refreshing}
                className="p-3 hover:bg-slate-100 dark:hover:bg-slate-800 rounded-xl transition-all duration-200"
              >
                <RefreshCw className={`h-4 w-4 ${refreshing ? 'animate-spin' : ''}`} />
              </Button>
              
              <Button
                variant="ghost"
                size="sm"
                className="p-3 hover:bg-slate-100 dark:hover:bg-slate-800 rounded-xl"
              >
                <Bell className="h-4 w-4" />
              </Button>
              
              <Button
                variant="ghost"
                size="sm"
                onClick={onToggleDarkMode}
                className="p-3 hover:bg-slate-100 dark:hover:bg-slate-800 rounded-xl transition-all duration-200"
              >
                {darkMode ? <Sun className="h-4 w-4" /> : <Moon className="h-4 w-4" />}
              </Button>
            </div>
          </div>
        </div>
        
        {lastUpdated && (
          <div className="mt-4 flex items-center justify-between text-xs text-slate-500 dark:text-slate-400">
            <div className="flex items-center space-x-2">
              <Clock className="h-3 w-3" />
              <span>Last updated: {lastUpdated.toLocaleTimeString()}</span>
            </div>
            <div className="flex items-center space-x-4">
              <div className="flex items-center space-x-1">
                <div className="w-2 h-2 rounded-full bg-green-500 animate-pulse" />
                <span>Real-time monitoring active</span>
              </div>
            </div>
          </div>
        )}
      </div>
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
  const [refreshing, setRefreshing] = useState(false);
  const [lastUpdated, setLastUpdated] = useState(null);
  const [connectionStatus, setConnectionStatus] = useState({
    clineServerConnected: false,
    magicApiConnected: false,
    usingMockData: true
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
    setDarkMode(prev => {
      const newMode = !prev;
      document.documentElement.classList.toggle('dark', newMode);
      return newMode;
    });
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
        setLastUpdated(new Date());
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
      <div className="min-h-screen bg-gradient-to-br from-slate-50 to-slate-100 dark:from-slate-900 dark:to-slate-800 flex items-center justify-center">
        <div className="text-center space-y-6">
          <div className="relative">
            <div className="w-24 h-24 rounded-full border-4 border-slate-200 dark:border-slate-700"></div>
            <div className="absolute inset-0 w-24 h-24 rounded-full border-4 border-transparent border-t-blue-600 animate-spin"></div>
            <div className="absolute inset-2 w-20 h-20 rounded-full border-4 border-transparent border-t-purple-600 animate-spin" style={{ animationDirection: 'reverse', animationDuration: '1.5s' }}></div>
            <div className="absolute inset-0 flex items-center justify-center">
              <Sparkles className="h-8 w-8 text-blue-600 animate-pulse" />
            </div>
          </div>
          <div className="space-y-2">
            <h2 className="text-xl font-semibold text-slate-900 dark:text-white">
              Initializing Dashboard
            </h2>
            <p className="text-sm text-slate-600 dark:text-slate-400">
              Setting up your AI monitoring environment...
            </p>
          </div>
        </div>
      </div>
    );
  }

  // Show error state if no data is available
  if (error && !dashboardData) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-red-50 to-red-100 dark:from-red-900/20 dark:to-red-800/20 flex items-center justify-center p-8">
        <Card className="max-w-md w-full shadow-2xl border-red-200 dark:border-red-800">
          <CardHeader className="text-center pb-4">
            <div className="mx-auto w-16 h-16 bg-red-100 dark:bg-red-900/30 rounded-full flex items-center justify-center mb-4">
              <Shield className="h-8 w-8 text-red-600 dark:text-red-400" />
            </div>
            <CardTitle className="text-red-900 dark:text-red-100">Dashboard Error</CardTitle>
            <CardDescription className="text-red-700 dark:text-red-300">
              {error}
            </CardDescription>
          </CardHeader>
          <CardContent className="text-center space-y-4">
            <Button onClick={handleRefresh} className="w-full bg-red-600 hover:bg-red-700">
              <RefreshCw className="h-4 w-4 mr-2" />
              Retry Connection
            </Button>
          </CardContent>
        </Card>
      </div>
    );
  }

  return (
    <div className={`min-h-screen transition-all duration-500 ${darkMode ? 'dark' : ''} bg-gradient-to-br from-slate-50 via-white to-slate-100 dark:from-slate-900 dark:via-slate-800 dark:to-slate-900`}>
      <DashboardHeader 
        darkMode={darkMode}
        onToggleDarkMode={toggleDarkMode}
        onRefresh={handleRefresh}
        refreshing={refreshing}
        lastUpdated={lastUpdated}
        connectionStatus={connectionStatus}
      />

      <div className="max-w-[1600px] mx-auto px-8 pb-12 space-y-8">
        {/* Enhanced Navigation */}
        <div className="flex justify-center">
          <AnimatedTabs 
            tabs={[
              { id: 'overview', label: 'Overview', icon: <Eye className="h-4 w-4" /> },
              { id: 'detailed', label: 'Analytics', icon: <BarChart3 className="h-4 w-4" /> },
              { id: 'usage', label: 'Usage Insights', icon: <Activity className="h-4 w-4" /> },
              { id: 'recommendations', label: 'AI Recommendations', icon: <Sparkles className="h-4 w-4" /> },
              { id: 'comparison', label: 'Model Comparison', icon: <Cpu className="h-4 w-4" /> },
              { id: 'settings', label: 'Settings', icon: <SettingsIcon className="h-4 w-4" /> }
            ]} 
            activeTab={viewMode} 
            onChange={setViewMode} 
          />
        </div>

        {/* Dynamic Content Based on View Mode */}
        <div className="space-y-8 animate-in fade-in duration-500">
          {viewMode === 'overview' && (
            <div className="space-y-8">
              <SectionHeader 
                title="System Overview"
                subtitle="Key performance indicators and system health"
                icon={<Gauge className="h-5 w-5" />}
              />
              
              {/* Enhanced Metrics Grid */}
              <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
                <div className="lg:col-span-2 space-y-6">
                  <div className="bg-white/60 dark:bg-slate-800/60 backdrop-blur-xl rounded-2xl p-6 shadow-xl border border-slate-200 dark:border-slate-700">
                    <MetricsPanel 
                      metrics={dashboardData?.metrics} 
                      darkMode={darkMode}
                    />
                  </div>
                  
                  <div className="bg-white/60 dark:bg-slate-800/60 backdrop-blur-xl rounded-2xl p-6 shadow-xl border border-slate-200 dark:border-slate-700">
                    <UsageChart 
                      usageData={dashboardData?.usage} 
                      darkMode={darkMode}
                    />
                  </div>
                </div>
                
                <div className="space-y-6">
                  <div className="bg-white/60 dark:bg-slate-800/60 backdrop-blur-xl rounded-2xl p-6 shadow-xl border border-slate-200 dark:border-slate-700">
                    <TokenUtilization 
                      tokenData={dashboardData?.tokens} 
                      costData={dashboardData?.costs}
                      darkMode={darkMode}
                    />
                  </div>
                  
                  <div className="bg-white/60 dark:bg-slate-800/60 backdrop-blur-xl rounded-2xl p-6 shadow-xl border border-slate-200 dark:border-slate-700">
                    <CostTracker 
                      costData={dashboardData?.costs} 
                      darkMode={darkMode}
                    />
                  </div>
                </div>
              </div>
            </div>
          )}

          {viewMode === 'detailed' && (
            <div className="space-y-8">
              <SectionHeader 
                title="Advanced Analytics"
                subtitle="Deep insights into your AI usage patterns"
                icon={<BarChart3 className="h-5 w-5" />}
              />
              <div className="bg-white/60 dark:bg-slate-800/60 backdrop-blur-xl rounded-2xl p-8 shadow-xl border border-slate-200 dark:border-slate-700">
                <EnhancedAnalyticsDashboard 
                  usageData={dashboardData?.usage}
                  modelsData={dashboardData?.models}
                  metrics={dashboardData?.metrics}
                  darkMode={darkMode}
                />
              </div>
            </div>
          )}

          {viewMode === 'usage' && (
            <div className="space-y-8">
              <SectionHeader 
                title="Usage Insights"
                subtitle="Detailed breakdown of your AI consumption"
                icon={<Activity className="h-5 w-5" />}
              />
              <div className="bg-white/60 dark:bg-slate-800/60 backdrop-blur-xl rounded-2xl p-8 shadow-xl border border-slate-200 dark:border-slate-700">
                <UsageStats 
                  usageData={dashboardData?.usage}
                  darkMode={darkMode}
                />
              </div>
            </div>
          )}

          {viewMode === 'recommendations' && (
            <div className="space-y-8">
              <SectionHeader 
                title="AI-Powered Recommendations"
                subtitle="Smart suggestions to optimize your token usage"
                icon={<Sparkles className="h-5 w-5" />}
              />
              <div className="bg-white/60 dark:bg-slate-800/60 backdrop-blur-xl rounded-2xl p-8 shadow-xl border border-slate-200 dark:border-slate-700">
                <TokenBudgetRecommendations 
                  tokenData={dashboardData?.tokens}
                  onApplyRecommendation={handleSettingChange}
                  darkMode={darkMode}
                />
              </div>
            </div>
          )}

          {viewMode === 'comparison' && (
            <div className="space-y-8">
              <SectionHeader 
                title="Model Performance Comparison"
                subtitle="Compare and optimize your AI model selection"
                icon={<Cpu className="h-5 w-5" />}
              />
              <div className="bg-white/60 dark:bg-slate-800/60 backdrop-blur-xl rounded-2xl p-8 shadow-xl border border-slate-200 dark:border-slate-700">
                <ModelPerformanceComparison 
                  modelsData={dashboardData?.models}
                  usageData={dashboardData?.usage}
                  onModelSelect={handleModelChange}
                  darkMode={darkMode}
                />
              </div>
            </div>
          )}

          {viewMode === 'settings' && (
            <div className="space-y-8">
              <SectionHeader 
                title="Dashboard Settings"
                subtitle="Configure your dashboard preferences and token budgets"
                icon={<SettingsIcon className="h-5 w-5" />}
              />
              
              <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
                <div className="bg-white/60 dark:bg-slate-800/60 backdrop-blur-xl rounded-2xl p-8 shadow-xl border border-slate-200 dark:border-slate-700">
                  <ModelSelector 
                    modelData={dashboardData?.models}
                    onModelSelect={handleModelChange}
                    darkMode={darkMode}
                  />
                </div>
                
                <div className="bg-white/60 dark:bg-slate-800/60 backdrop-blur-xl rounded-2xl p-8 shadow-xl border border-slate-200 dark:border-slate-700">
                  <SettingsPanel 
                    settings={dashboardData?.settings}
                    tokenBudgets={dashboardData?.tokens?.budgets}
                    onSettingChange={handleSettingChange}
                    onBudgetChange={handleTokenBudgetChange}
                    darkMode={darkMode}
                  />
                </div>
              </div>
            </div>
          )}
        </div>

        {/* Enhanced Footer */}
        <div className="mt-16 pt-8 border-t border-slate-200 dark:border-slate-700">
          <div className="flex flex-col sm:flex-row justify-between items-center space-y-4 sm:space-y-0">
            <div className="flex items-center space-x-4">
              <div className="flex items-center space-x-2">
                <Sparkles className="h-5 w-5 text-blue-600 dark:text-blue-400" />
                <span className="text-sm font-medium text-slate-900 dark:text-white">
                  Cline AI Dashboard
                </span>
              </div>
              <Badge variant="outline" className="text-xs">
                v2.0.0
              </Badge>
            </div>
            
            <div className="flex items-center space-x-6 text-xs text-slate-600 dark:text-slate-400">
              <div className="flex items-center space-x-1">
                <Database className="h-3 w-3" />
                <span>
                  {dashboardData?.tokens?.usage?.total?.toLocaleString() || '0'} tokens processed
                </span>
              </div>
              <div className="flex items-center space-x-1">
                <DollarSign className="h-3 w-3" />
                <span>
                  ${dashboardData?.costs?.total?.toFixed(2) || '0.00'} total cost
                </span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default EnhancedDashboard;
