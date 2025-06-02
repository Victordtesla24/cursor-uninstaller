import React, { useState, useEffect } from 'react';
import {
  RefreshCw,
  Sun,
  Moon,
  BarChart3,
  Activity,
  Settings,
  TrendingUp,
  DollarSign,
  Zap,
  Eye,
  Gauge,
  Clock,
  Database
} from 'lucide-react';
import {
  Card,
  CardHeader,
  CardContent,
  CardTitle,
  Button,
  Badge
} from '../components/ui/index.js';
import {
  MetricCard
} from '../components/features/index.js';

// Modern Header Component
const ModernHeader = ({ darkMode, onToggleDarkMode, onRefresh, isRefreshing, lastUpdated }) => {
  return (
    <div className="glass-strong border-b border-gray-200/50 dark:border-gray-700/50 sticky top-0 z-50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-16">
          {/* Left Section - Title and Status */}
          <div className="flex items-center space-x-4">
            <div className="flex items-center space-x-3">
              <div className="p-2 bg-blue-600 rounded-lg animate-glow">
                <Activity className="h-6 w-6 text-white" />
              </div>
              <div>
                <h1 className="text-xl font-bold text-gray-900 dark:text-white">
                  Cline AI Dashboard
                </h1>
                <p className="text-sm text-gray-500 dark:text-gray-400">
                  Advanced AI monitoring and optimization platform
                </p>
              </div>
            </div>
            
            <div className="flex items-center space-x-2">
              <Badge variant="secondary" className="bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-400">
                <div className="w-2 h-2 bg-green-500 rounded-full mr-2 animate-pulse-soft"></div>
                Real-time monitoring active
              </Badge>
            </div>
          </div>

          {/* Right Section - Controls */}
          <div className="flex items-center space-x-3">
            {lastUpdated && (
              <span className="text-sm text-gray-500 dark:text-gray-400">
                Last updated: {lastUpdated}
              </span>
            )}
            
            <Button
              variant="ghost"
              size="sm"
              onClick={onRefresh}
              disabled={isRefreshing}
              className="p-2 hover-lift"
            >
              <RefreshCw className={`h-4 w-4 ${isRefreshing ? 'animate-spin' : ''}`} />
            </Button>
            
            <Button
              variant="ghost"
              size="sm"
              onClick={onToggleDarkMode}
              className="p-2 hover-lift"
            >
              {darkMode ? (
                <Sun className="h-4 w-4" />
              ) : (
                <Moon className="h-4 w-4" />
              )}
            </Button>
          </div>
        </div>
      </div>
    </div>
  );
};

// Navigation Tabs Component
const NavigationTabs = ({ activeTab, onTabChange }) => {
  const tabs = [
    { id: 'overview', label: 'Overview', icon: Eye },
    { id: 'analytics', label: 'Analytics', icon: BarChart3 },
    { id: 'usage', label: 'Usage Insights', icon: TrendingUp },
    { id: 'recommendations', label: 'AI Recommendations', icon: Zap },
    { id: 'comparison', label: 'Model Comparison', icon: Gauge },
    { id: 'settings', label: 'Settings', icon: Settings }
  ];

  return (
    <div className="glass border-b border-gray-200/50 dark:border-gray-700/50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <nav className="flex space-x-8">
          {tabs.map((tab) => {
            const Icon = tab.icon;
            const isActive = activeTab === tab.id;
            
            return (
              <button
                key={tab.id}
                onClick={() => onTabChange(tab.id)}
                className={`flex items-center space-x-2 py-3 px-3 rounded-t-md border-b-2 font-medium text-sm transition-all duration-150 ease-in-out focus:outline-none focus-visible:ring-2 focus-visible:ring-blue-500 focus-visible:ring-offset-2 dark:focus-visible:ring-offset-gray-900 ${
                  isActive
                    ? 'border-blue-500 text-blue-600 dark:text-blue-400 bg-blue-50 dark:bg-blue-900/30'
                    : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300 hover:bg-gray-100 dark:text-gray-400 dark:hover:text-gray-300 dark:hover:bg-gray-800/60'
                }`}
              >
                <Icon className="h-4 w-4" />
                <span>{tab.label}</span>
              </button>
            );
          })}
        </nav>
      </div>
    </div>
  );
};

// Mock Data
const mockData = {
  systemHealth: 'excellent',
  activeRequests: 0,
  responseTime: '0ms',
  cacheHitRate: '0.68%',
  totalRequests: 0,
  apiRequestsProcessed: 0,
  avgResponseTime: 0
};

// Main Dashboard Component
const ModernDashboard = () => {
  const [darkMode, setDarkMode] = useState(false);
  const [activeTab, setActiveTab] = useState('overview');
  const [isRefreshing, setIsRefreshing] = useState(false);
  const [lastUpdated, setLastUpdated] = useState(new Date().toLocaleTimeString());
  const [data, setData] = useState(mockData);

  // Toggle dark mode
  const toggleDarkMode = () => {
    setDarkMode(!darkMode);
    document.documentElement.classList.toggle('dark');
  };

  // Handle refresh
  const handleRefresh = () => {
    setIsRefreshing(true);
    setLastUpdated(new Date().toLocaleTimeString());
    
    // Simulate API call
    setTimeout(() => {
      setData({ ...mockData });
      setIsRefreshing(false);
    }, 1000);
  };

  // Apply dark mode on mount
  useEffect(() => {
    if (darkMode) {
      document.documentElement.classList.add('dark');
    } else {
      document.documentElement.classList.remove('dark');
    }
  }, [darkMode]);

  // Auto-refresh every 30 seconds
  useEffect(() => {
    const interval = setInterval(() => {
      setLastUpdated(new Date().toLocaleTimeString());
    }, 30000);

    return () => clearInterval(interval);
  }, []);

  return (
    <div className={`min-h-screen bg-gray-50 dark:bg-gray-900 transition-colors ${darkMode ? 'dark' : ''}`}>
      {/* Header */}
      <ModernHeader
        darkMode={darkMode}
        onToggleDarkMode={toggleDarkMode}
        onRefresh={handleRefresh}
        isRefreshing={isRefreshing}
        lastUpdated={lastUpdated}
      />

      {/* Navigation */}
      <NavigationTabs
        activeTab={activeTab}
        onTabChange={setActiveTab}
      />

      {/* Main Content */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 animate-slide-up">
        {activeTab === 'overview' && (
          <div className="space-y-8">
            <div className="flex items-center justify-between">
              <div>
                <h2 className="text-2xl font-bold text-gray-900 dark:text-white text-gradient-blue">
                  System Overview
                </h2>
                <p className="text-gray-600 dark:text-gray-400 mt-1">
                  Key performance indicators and system health
                </p>
              </div>
            </div>

            {/* System Status */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
              <MetricCard
                title="System Status"
                value="Excellent"
                icon={Activity}
                description="All systems operational"
                color="green"
                className="hover-lift"
              />
              
              <MetricCard
                title="API Requests"
                value={data.activeRequests}
                icon={Database}
                description="Active requests"
                color="blue"
                className="hover-lift"
              />
              
              <MetricCard
                title="Response Time"
                value={data.responseTime}
                icon={Clock}
                description="Avg latency: 0.6% of target"
                color="amber"
                className="hover-lift"
              />
              
              <MetricCard
                title="Cache Hit Rate"
                value={data.cacheHitRate}
                icon={Gauge}
                description="Requests served from cache"
                color="purple"
                className="hover-lift"
              />
            </div>

            {/* Additional Metrics */}
            <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
              <Card className="dashboard-card animate-slide-up hover-lift shadow-medium">
                <CardHeader>
                  <CardTitle className="flex items-center space-x-2">
                    <BarChart3 className="h-5 w-5 text-blue-600 animate-pulse-soft" />
                    <span>Total Requests</span>
                  </CardTitle>
                </CardHeader>
                <CardContent className="p-6">
                  <div className="text-3xl font-bold text-gray-900 dark:text-white">
                    {data.totalRequests}
                  </div>
                  <p className="text-sm text-gray-500 dark:text-gray-400 mt-1">
                    0% API requests processed
                  </p>
                </CardContent>
              </Card>

              <Card className="dashboard-card animate-scale-in hover-lift shadow-medium">
                <CardHeader>
                  <CardTitle className="flex items-center space-x-2">
                    <TrendingUp className="h-5 w-5 text-green-600 animate-pulse-soft" />
                    <span>Avg Response Time</span>
                  </CardTitle>
                </CardHeader>
                <CardContent className="p-6">
                  <div className="text-3xl font-bold text-gray-900 dark:text-white">
                    {data.avgResponseTime}ms
                  </div>
                  <div className="w-full bg-gray-200 dark:bg-gray-700 rounded-full h-2 mt-3">
                    <div className="bg-blue-600 h-2 rounded-full animate-shimmer" style={{ width: '45%' }}></div>
                  </div>
                </CardContent>
              </Card>

              <Card className="dashboard-card animate-scale-in hover-lift shadow-medium">
                <CardHeader>
                  <CardTitle className="flex items-center space-x-2">
                    <DollarSign className="h-5 w-5 text-purple-600 animate-pulse-soft" />
                    <span className="text-gradient-purple">System Health</span>
                  </CardTitle>
                </CardHeader>
                <CardContent className="p-6">
                  <div className="space-y-3">
                    <div className="flex items-center justify-between">
                      <span className="text-sm text-gray-600 dark:text-gray-400">Status</span>
                      <Badge variant="secondary" className="bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-400">Active</Badge>
                    </div>
                    <div className="flex items-center justify-between">
                      <span className="text-sm text-gray-600 dark:text-gray-400">Monitoring</span>
                      <Badge variant="secondary" className="bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-400">Enabled</Badge>
                    </div>
                  </div>
                </CardContent>
              </Card>
            </div>
          </div>
        )}

        {activeTab === 'analytics' && (
          <div className="space-y-8 animate-fade-in">
            <div className="text-center py-12">
              <BarChart3 className="h-12 w-12 text-gray-400 mx-auto mb-4 animate-float" />
              <h3 className="text-lg font-medium text-gray-900 dark:text-white mb-2 text-gradient-blue">
                Analytics View
              </h3>
              <p className="text-gray-500 dark:text-gray-400">
                Advanced analytics features are being loaded...
              </p>
            </div>
          </div>
        )}

        {activeTab === 'usage' && (
          <div className="space-y-8 animate-fade-in">
            <div className="text-center py-12">
              <TrendingUp className="h-12 w-12 text-gray-400 mx-auto mb-4 animate-float" />
              <h3 className="text-lg font-medium text-gray-900 dark:text-white mb-2 text-gradient-green">
                Usage Insights
              </h3>
              <p className="text-gray-500 dark:text-gray-400">
                Usage analytics features are being loaded...
              </p>
            </div>
          </div>
        )}

        {activeTab === 'recommendations' && (
          <div className="space-y-8 animate-fade-in">
            <div className="text-center py-12">
              <Zap className="h-12 w-12 text-gray-400 mx-auto mb-4 animate-float" />
              <h3 className="text-lg font-medium text-gray-900 dark:text-white mb-2 text-gradient-purple">
                AI Recommendations
              </h3>
              <p className="text-gray-500 dark:text-gray-400">
                AI recommendation features are being loaded...
              </p>
            </div>
          </div>
        )}

        {activeTab === 'comparison' && (
          <div className="space-y-8 animate-fade-in">
            <div className="text-center py-12">
              <Gauge className="h-12 w-12 text-gray-400 mx-auto mb-4 animate-float" />
              <h3 className="text-lg font-medium text-gray-900 dark:text-white mb-2 text-gradient-blue">
                Model Comparison
              </h3>
              <p className="text-gray-500 dark:text-gray-400">
                Model comparison features are being loaded...
              </p>
            </div>
          </div>
        )}

        {activeTab === 'settings' && (
          <div className="space-y-8 animate-fade-in">
            <div className="text-center py-12">
              <Settings className="h-12 w-12 text-gray-400 mx-auto mb-4 animate-float" />
              <h3 className="text-lg font-medium text-gray-900 dark:text-white mb-2 text-gradient-green">
                Settings View
              </h3>
              <p className="text-gray-500 dark:text-gray-400">
                Advanced settings features are being loaded...
              </p>
            </div>
          </div>
        )}
      </main>

      {/* Footer */}
      <footer className="bg-white dark:bg-gray-900 border-t border-gray-200 dark:border-gray-700 mt-12">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-4">
              <Badge variant="outline">v2.0.0</Badge>
              <span className="text-sm text-gray-500 dark:text-gray-400">
                Modern AI monitoring and optimization platform
              </span>
            </div>
            <div className="text-sm text-gray-500 dark:text-gray-400">
              © 2024 Cline AI Dashboard
            </div>
          </div>
        </div>
      </footer>
    </div>
  );
};

export default ModernDashboard;
