import React, { useState, useMemo } from 'react';
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
  Badge,
  Progress,
  Button,
  Separator,
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger
} from "../ui";
import {
  BarChart3,
  Calendar,
  Clock,
  Database,
  DollarSign,
  Download,
  Filter,
  PieChart,
  TrendingUp,
  TrendingDown,
  Users,
  Activity,
  Target,
  Zap,
  FileText,
  RefreshCw,
  Settings,
  Share2
} from "lucide-react";

/**
 * Usage Stats Component
 *
 * Displays detailed usage statistics for the Cline AI extension
 * Shows historical data, usage breakdowns, and usage patterns
 * Implements interactive charts and data visualizations
 */
export default function UsageStats({ 
  usageData = {}, 
  comparisons = {}, 
  timeRange = 'daily',
  darkMode = false,
  onTimeRangeChange = () => {},
  onExport = () => {},
  onRefresh = () => {},
  className = '' 
}) {
  const [currentTimeRange, setCurrentTimeRange] = useState(timeRange);
  const [selectedMetric, setSelectedMetric] = useState('tokens');

  // Format large numbers with comma separators
  const formatNumber = (num) => {
    if (!num && num !== 0) return '0';
    return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',');
  };

  // Format currency
  const formatCurrency = (amount) => {
    if (!amount && amount !== 0) return '$0.00';
    return `$${Number(amount).toFixed(2)}`;
  };

  // Format percentage
  const formatPercent = (value) => {
    if (!value && value !== 0) return '0%';
    return `${value}%`;
  };

  // Safe data access with fallbacks
  const safeUsageData = useMemo(() => {
    return {
      daily: usageData.daily || {},
      weekly: usageData.weekly || {},
      monthly: usageData.monthly || {},
      byModel: usageData.byModel || {},
      byCategory: usageData.byCategory || {},
      topUsagePatterns: usageData.topUsagePatterns || [],
      efficiency: usageData.efficiency || {}
    };
  }, [usageData]);

  const safeComparisons = useMemo(() => {
    return {
      previousPeriod: comparisons.previousPeriod || {},
      targets: comparisons.targets || {},
      benchmarks: comparisons.benchmarks || {}
    };
  }, [comparisons]);

  // Handle time range change
  const handleTimeRangeChange = (newRange) => {
    setCurrentTimeRange(newRange);
    onTimeRangeChange(newRange);
  };

  // Get current period data based on selected time range
  const getCurrentPeriodData = () => {
    const data = safeUsageData[currentTimeRange] || {};
    return {
      tokens: data.tokens || 0,
      requests: data.requests || 0,
      cost: data.cost || 0,
      avgResponseTime: data.avgResponseTime || 0,
      uniqueUsers: data.uniqueUsers || 0,
      trend: data.trend || 'up',
      growth: data.growth || 0
    };
  };

  const currentData = getCurrentPeriodData();

  // Early return for loading state
  if (Object.keys(usageData).length === 0) {
    return (
      <Card className={`${darkMode ? 'bg-card/95' : ''} ${className}`}>
        <CardHeader>
          <CardTitle>Usage Statistics</CardTitle>
          <CardDescription>Comprehensive analysis of token and API usage</CardDescription>
        </CardHeader>
        <CardContent className="flex flex-col items-center justify-center py-12">
          <div className="h-12 w-12 animate-spin rounded-full border-4 border-primary border-t-transparent"></div>
          <p className="text-muted-foreground mt-4">Loading usage data...</p>
        </CardContent>
      </Card>
    );
  }

  return (
    <div className={`space-y-6 ${className}`}>
      {/* Main Usage Statistics Card */}
      <Card className={darkMode ? 'bg-card/95' : ''}>
        <CardHeader>
          <div className="flex justify-between items-start">
            <div>
              <CardTitle className="flex items-center gap-2">
                <BarChart3 className="h-5 w-5 text-primary" />
                Usage Statistics
              </CardTitle>
              <CardDescription>
                Comprehensive analysis of token and API usage
              </CardDescription>
            </div>
            <div className="flex gap-2">
              <Button
                variant="outline"
                size="sm"
                onClick={() => handleTimeRangeChange('daily')}
                className={currentTimeRange === 'daily' ? 'bg-primary text-primary-foreground' : ''}
              >
                Daily
              </Button>
              <Button
                variant="outline"
                size="sm"
                onClick={() => handleTimeRangeChange('weekly')}
                className={currentTimeRange === 'weekly' ? 'bg-primary text-primary-foreground' : ''}
              >
                Weekly
              </Button>
              <Button
                variant="outline"
                size="sm"
                onClick={() => handleTimeRangeChange('monthly')}
                className={currentTimeRange === 'monthly' ? 'bg-primary text-primary-foreground' : ''}
              >
                Monthly
              </Button>
              <Button
                variant="outline"
                size="sm"
                onClick={() => handleTimeRangeChange('custom')}
                className={currentTimeRange === 'custom' ? 'bg-primary text-primary-foreground' : ''}
              >
                Custom
              </Button>
            </div>
          </div>
        </CardHeader>

        <Separator />

        <CardContent className="p-6">
          {/* Key Metrics Overview */}
          <div className="grid grid-cols-1 md:grid-cols-5 gap-4 mb-6">
            <div className="text-center">
              <div className="text-sm text-muted-foreground">Total Tokens</div>
              <div className="text-2xl font-bold">{formatNumber(currentData.tokens)}</div>
              <div className="text-xs text-muted-foreground">{currentTimeRange}</div>
            </div>
            <div className="text-center">
              <div className="text-sm text-muted-foreground">Total Requests</div>
              <div className="text-2xl font-bold">{formatNumber(currentData.requests)}</div>
              <div className="text-xs text-muted-foreground">{currentTimeRange}</div>
            </div>
            <div className="text-center">
              <div className="text-sm text-muted-foreground">Total Cost</div>
              <div className="text-2xl font-bold">{formatCurrency(currentData.cost)}</div>
              <div className="text-xs text-muted-foreground">{currentTimeRange}</div>
            </div>
            <div className="text-center">
              <div className="text-sm text-muted-foreground">Avg Response Time</div>
              <div className="text-2xl font-bold">{currentData.avgResponseTime}s</div>
              <div className="text-xs text-muted-foreground">average</div>
            </div>
            <div className="text-center">
              <div className="text-sm text-muted-foreground">Active Users</div>
              <div className="text-2xl font-bold">{formatNumber(currentData.uniqueUsers)}</div>
              <div className="text-xs text-muted-foreground">{currentTimeRange}</div>
            </div>
          </div>

          {/* Model Usage Analysis */}
          <div className="mb-6">
            <h3 className="text-lg font-semibold mb-4 flex items-center gap-2">
              <Database className="h-5 w-5" />
              Model Usage Analysis
            </h3>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <h4 className="text-sm font-medium mb-3">Usage by Model</h4>
                <div className="space-y-3">
                  {Object.entries(safeUsageData.byModel).map(([model, data]) => (
                    <div key={model} className="flex justify-between items-center">
                      <div className="flex items-center gap-2">
                        <div className="w-3 h-3 bg-primary rounded-full"></div>
                        <span className="capitalize">{model}</span>
                      </div>
                      <div className="text-right">
                        <div className="font-medium">{formatNumber(data.tokens || 0)}</div>
                        <div className="text-sm text-muted-foreground">{formatPercent(data.percentage || 0)}</div>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
              <div>
                <h4 className="text-sm font-medium mb-3">Model Performance</h4>
                <div className="space-y-3">
                  {Object.entries(safeUsageData.byModel).map(([model, data]) => (
                    <div key={model} className="space-y-1">
                      <div className="flex justify-between text-sm">
                        <span className="capitalize">{model}</span>
                        <span>{formatCurrency(data.cost || 0)}</span>
                      </div>
                      <Progress value={data.percentage || 0} className="h-2" />
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </div>

          {/* Category Usage Analysis */}
          <div className="mb-6">
            <h3 className="text-lg font-semibold mb-4 flex items-center gap-2">
              <PieChart className="h-5 w-5" />
              Usage by Category
            </h3>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              {Object.entries(safeUsageData.byCategory).map(([category, data]) => (
                <div key={category} className="bg-muted/20 rounded-lg p-4">
                  <div className="flex justify-between items-start mb-2">
                    <h4 className="font-medium capitalize">{category}</h4>
                    <Badge variant="outline">{formatPercent(data.percentage || 0)}</Badge>
                  </div>
                  <div className="text-2xl font-bold mb-1">{formatNumber(data.tokens || 0)}</div>
                  <div className="text-sm text-muted-foreground">{formatCurrency(data.cost || 0)}</div>
                  <div className="text-sm text-muted-foreground">{formatNumber(data.requests || 0)} requests</div>
                </div>
              ))}
            </div>
          </div>

          {/* Usage Patterns and Trends */}
          <div className="mb-6">
            <h3 className="text-lg font-semibold mb-4 flex items-center gap-2">
              <Activity className="h-5 w-5" />
              Usage Patterns
            </h3>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              {safeUsageData.topUsagePatterns.map((pattern, index) => (
                <div key={index} className="bg-muted/20 rounded-lg p-4 text-center">
                  <div className="text-lg font-bold">{pattern.time}</div>
                  <div className="text-sm text-muted-foreground">{pattern.label}</div>
                  <div className="text-2xl font-bold text-primary mt-2">{pattern.usage}%</div>
                  <div className="flex items-center justify-center gap-1 mt-2">
                    <TrendingUp className="h-4 w-4 text-green-500" />
                    <span className="text-sm text-green-500">{currentData.growth}%</span>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Efficiency Metrics */}
          <div className="mb-6">
            <h3 className="text-lg font-semibold mb-4 flex items-center gap-2">
              <Zap className="h-5 w-5" />
              Efficiency Metrics
            </h3>
            <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
              <div className="text-center">
                <div className="text-sm text-muted-foreground">Cache Hit Rate</div>
                <div className="text-2xl font-bold">{formatPercent(safeUsageData.efficiency.cacheHitRate || 0)}</div>
              </div>
              <div className="text-center">
                <div className="text-sm text-muted-foreground">Avg Tokens/Request</div>
                <div className="text-2xl font-bold">{formatNumber(safeUsageData.efficiency.avgTokensPerRequest || 0)}</div>
              </div>
              <div className="text-center">
                <div className="text-sm text-muted-foreground">Cost Efficiency</div>
                <div className="text-2xl font-bold">{formatPercent(safeUsageData.efficiency.costEfficiency || 0)}</div>
              </div>
              <div className="text-center">
                <div className="text-sm text-muted-foreground">Response Time Score</div>
                <div className="text-2xl font-bold">{formatPercent(safeUsageData.efficiency.responseTimeScore || 0)}</div>
              </div>
            </div>
          </div>

          {/* Period Comparisons */}
          <div className="mb-6">
            <h3 className="text-lg font-semibold mb-4 flex items-center gap-2">
              <TrendingUp className="h-5 w-5" />
              vs Previous Period
            </h3>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              {Object.entries(safeComparisons.previousPeriod).map(([metric, data]) => (
                <div key={metric} className="bg-muted/20 rounded-lg p-4 text-center">
                  <div className="text-sm text-muted-foreground capitalize">{metric}</div>
                  <div className="text-xl font-bold">{formatNumber(data.current || 0)}</div>
                  <div className={`flex items-center justify-center gap-1 mt-2 ${
                    (data.change || 0) >= 0 ? 'text-green-500' : 'text-red-500'
                  }`}>
                    {(data.change || 0) >= 0 ? (
                      <TrendingUp className="h-4 w-4" />
                    ) : (
                      <TrendingDown className="h-4 w-4" />
                    )}
                    <span className="text-sm">
                      {(data.change || 0) >= 0 ? '+' : ''}{(data.change || 0).toFixed(1)}%
                    </span>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Budget and Target Tracking */}
          <div className="mb-6">
            <h3 className="text-lg font-semibold mb-4 flex items-center gap-2">
              <Target className="h-5 w-5" />
              Budget Tracking
            </h3>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <h4 className="text-sm font-medium mb-3">Monthly Budget</h4>
                <div className="space-y-3">
                  <div className="flex justify-between">
                    <span>Current Spend</span>
                    <span className="font-bold">{formatCurrency(currentData.cost)}</span>
                  </div>
                  <div className="flex justify-between">
                    <span>Budget Limit</span>
                    <span className="font-bold">{formatCurrency(safeComparisons.targets.monthlyBudget || 0)}</span>
                  </div>
                  <Progress 
                    value={((currentData.cost || 0) / (safeComparisons.targets.monthlyBudget || 1)) * 100} 
                    className="h-3"
                  />
                </div>
              </div>
              <div>
                <h4 className="text-sm font-medium mb-3">Token Limit</h4>
                <div className="space-y-3">
                  <div className="flex justify-between">
                    <span>Current Usage</span>
                    <span className="font-bold">{formatNumber(currentData.tokens)}</span>
                  </div>
                  <div className="flex justify-between">
                    <span>Token Limit</span>
                    <span className="font-bold">{formatNumber(safeComparisons.targets.tokenLimit || 0)}</span>
                  </div>
                  <Progress 
                    value={((currentData.tokens || 0) / (safeComparisons.targets.tokenLimit || 1)) * 100} 
                    className="h-3"
                  />
                </div>
              </div>
            </div>
          </div>

          {/* Industry Benchmarks */}
          <div className="mb-6">
            <h3 className="text-lg font-semibold mb-4 flex items-center gap-2">
              <Users className="h-5 w-5" />
              Industry Benchmarks
            </h3>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div className="bg-muted/20 rounded-lg p-4 text-center">
                <div className="text-sm text-muted-foreground">Industry Avg</div>
                <div className="text-sm text-muted-foreground">Cost per Token</div>
                <div className="text-xl font-bold">{formatCurrency(safeComparisons.benchmarks.industry?.avgCostPerToken || 0)}</div>
                <Badge variant="outline" className="mt-2">Above Average</Badge>
              </div>
              <div className="bg-muted/20 rounded-lg p-4 text-center">
                <div className="text-sm text-muted-foreground">Industry Avg</div>
                <div className="text-sm text-muted-foreground">Response Time</div>
                <div className="text-xl font-bold">{safeComparisons.benchmarks.industry?.avgResponseTime || 0}s</div>
                <Badge variant="outline" className="mt-2">Below Average</Badge>
              </div>
              <div className="bg-muted/20 rounded-lg p-4 text-center">
                <div className="text-sm text-muted-foreground">Industry Avg</div>
                <div className="text-sm text-muted-foreground">Cache Hit Rate</div>
                <div className="text-xl font-bold">{formatPercent(safeComparisons.benchmarks.industry?.avgCacheHit || 0)}</div>
                <Badge variant="outline" className="mt-2">Above Average</Badge>
              </div>
            </div>
          </div>

          {/* Data Export and Sharing */}
          <div className="mb-6">
            <h3 className="text-lg font-semibold mb-4 flex items-center gap-2">
              <Download className="h-5 w-5" />
              Export & Share
            </h3>
            <div className="flex flex-wrap gap-3">
              <Button variant="outline" onClick={() => onExport('csv')}>
                <FileText className="h-4 w-4 mr-2" />
                Export as CSV
              </Button>
              <Button variant="outline" onClick={() => onExport('pdf')}>
                <FileText className="h-4 w-4 mr-2" />
                Export as PDF
              </Button>
              <Button variant="outline">
                <Share2 className="h-4 w-4 mr-2" />
                Share Report
              </Button>
              <Button variant="outline" onClick={onRefresh}>
                <RefreshCw className="h-4 w-4 mr-2" />
                Refresh Data
              </Button>
            </div>
          </div>

          {/* Real-time Updates */}
          <div className="mb-6">
            <h3 className="text-lg font-semibold mb-4 flex items-center gap-2">
              <Clock className="h-5 w-5" />
              Real-time Updates
            </h3>
            <div className="bg-muted/20 rounded-lg p-4">
              <div className="flex justify-between items-center">
                <div>
                  <div className="font-medium">Auto-refresh enabled</div>
                  <div className="text-sm text-muted-foreground">
                    Last updated: {new Date().toLocaleTimeString()}
                  </div>
                </div>
                <div className="flex gap-2">
                  <Button variant="outline" size="sm">
                    <Settings className="h-4 w-4 mr-2" />
                    Settings
                  </Button>
                  <Button variant="outline" size="sm" onClick={onRefresh}>
                    <RefreshCw className="h-4 w-4 mr-2" />
                    Refresh Now
                  </Button>
                </div>
              </div>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
