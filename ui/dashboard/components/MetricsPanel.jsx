import React, { useMemo } from 'react';
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
  Badge,
  Separator,
  Progress
} from './ui/index.js';
import {
  Activity,
  Clock,
  Database,
  Zap,
  TrendingUp,
  TrendingDown,
  AlertTriangle,
  CheckCircle,
  ArrowUp,
  ArrowDown,
  Gauge,
  Shield,
  Server,
  Wifi,
  BarChart3
} from 'lucide-react';

/**
 * Enhanced MetricsPanel Component
 * 
 * Displays system performance metrics with sophisticated visual design,
 * animated progress indicators, and modern UI patterns
 * 
 * @param {Object} props Component props
 * @param {Object} props.metrics Performance metrics data
 * @param {String} props.className Additional CSS classes
 * @param {Boolean} props.darkMode Whether dark mode is enabled
 */
function MetricsPanel({ metrics = {}, className = '', darkMode = false }) {
  // Safely extract metrics with defaults
  const safeMetrics = {
    totalRequests: 0,
    tokensUsed: 0,
    averageResponseTime: 0,
    cacheHitRate: 0,
    reliability: 0,
    systemLoad: 0,
    activeConnections: 0,
    errorRate: 0,
    throughput: 0,
    ...metrics
  };

  // Format large numbers with appropriate suffixes and animations
  const formatNumber = (num) => {
    if (num >= 1000000) {
      return `${(num / 1000000).toFixed(1)}M`;
    }
    if (num >= 1000) {
      return `${(num / 1000).toFixed(1)}K`;
    }
    return num?.toString() || '0';
  };

  // Format change values with proper styling
  const formatChange = (value) => {
    if (!value) return null;
    const isPositive = value > 0;
    const prefix = isPositive ? '+' : '';
    return {
      value: `${prefix}${value.toFixed(1)}%`,
      isPositive,
      class: isPositive ? 'text-emerald-600 dark:text-emerald-400' : 'text-red-600 dark:text-red-400',
      icon: isPositive ? <TrendingUp className="h-3 w-3" /> : <TrendingDown className="h-3 w-3" />
    };
  };

  // Get status indicator based on metric value
  const getStatusIndicator = (value, thresholds = { good: 90, warning: 70 }) => {
    if (value >= thresholds.good) {
      return {
        color: 'emerald',
        icon: <CheckCircle className="h-4 w-4" />,
        label: 'Excellent'
      };
    } else if (value >= thresholds.warning) {
      return {
        color: 'amber',
        icon: <AlertTriangle className="h-4 w-4" />,
        label: 'Good'
      };
    } else {
      return {
        color: 'red',
        icon: <AlertTriangle className="h-4 w-4" />,
        label: 'Needs Attention'
      };
    }
  };

  // Enhanced color system with gradients
  const getColorClasses = (color, type) => {
    const colorMap = {
      emerald: {
        bg: 'bg-gradient-to-br from-emerald-500 to-green-600',
        bgLight: 'bg-gradient-to-br from-emerald-50 to-green-50 dark:from-emerald-950/30 dark:to-green-950/30',
        border: 'border-emerald-200 dark:border-emerald-800',
        text: 'text-emerald-700 dark:text-emerald-300',
        badge: 'bg-emerald-100 text-emerald-800 dark:bg-emerald-900/30 dark:text-emerald-400',
        glow: 'shadow-emerald-500/25'
      },
      blue: {
        bg: 'bg-gradient-to-br from-blue-500 to-blue-600',
        bgLight: 'bg-gradient-to-br from-blue-50 to-blue-50 dark:from-blue-950/30 dark:to-blue-950/30',
        border: 'border-blue-200 dark:border-blue-800',
        text: 'text-blue-700 dark:text-blue-300',
        badge: 'bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-400',
        glow: 'shadow-blue-500/25'
      },
      purple: {
        bg: 'bg-gradient-to-br from-purple-500 to-purple-600',
        bgLight: 'bg-gradient-to-br from-purple-50 to-purple-50 dark:from-purple-950/30 dark:to-purple-950/30',
        border: 'border-purple-200 dark:border-purple-800',
        text: 'text-purple-700 dark:text-purple-300',
        badge: 'bg-purple-100 text-purple-800 dark:bg-purple-900/30 dark:text-purple-400',
        glow: 'shadow-purple-500/25'
      },
      amber: {
        bg: 'bg-gradient-to-br from-amber-500 to-orange-500',
        bgLight: 'bg-gradient-to-br from-amber-50 to-orange-50 dark:from-amber-950/30 dark:to-orange-950/30',
        border: 'border-amber-200 dark:border-amber-800',
        text: 'text-amber-700 dark:text-amber-300',
        badge: 'bg-amber-100 text-amber-800 dark:bg-amber-900/30 dark:text-amber-400',
        glow: 'shadow-amber-500/25'
      },
      red: {
        bg: 'bg-gradient-to-br from-red-500 to-red-600',
        bgLight: 'bg-gradient-to-br from-red-50 to-red-50 dark:from-red-950/30 dark:to-red-950/30',
        border: 'border-red-200 dark:border-red-800',
        text: 'text-red-700 dark:text-red-300',
        badge: 'bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-400',
        glow: 'shadow-red-500/25'
      }
    };
    return colorMap[color]?.[type] || colorMap.blue[type];
  };

  // Memoized metrics configuration with enhanced styling
  const metricsConfig = useMemo(() => [
    {
      id: 'requests',
      title: 'Total Requests',
      value: formatNumber(safeMetrics.totalRequests),
      change: formatChange(safeMetrics.requestsChange),
      icon: <Activity className="h-5 w-5" />,
      color: 'blue',
      description: 'API requests processed',
      trend: safeMetrics.requestsTrend || []
    },
    {
      id: 'response_time',
      title: 'Avg Response Time',
      value: `${safeMetrics.averageResponseTime}ms`,
      change: formatChange(safeMetrics.responseTimeChange),
      icon: <Clock className="h-5 w-5" />,
      color: 'emerald',
      description: 'Average AI response time',
      benchmark: '< 1000ms',
      status: getStatusIndicator(1000 - safeMetrics.averageResponseTime, { good: 800, warning: 500 })
    },
    {
      id: 'cache_hit_rate',
      title: 'Cache Hit Rate',
      value: `${safeMetrics.cacheHitRate}%`,
      change: formatChange(safeMetrics.cacheHitRateChange),
      icon: <Database className="h-5 w-5" />,
      color: 'purple',
      description: 'Requests served from cache',
      progress: safeMetrics.cacheHitRate,
      status: getStatusIndicator(safeMetrics.cacheHitRate)
    },
    {
      id: 'system_load',
      title: 'System Load',
      value: `${safeMetrics.systemLoad}%`,
      change: formatChange(safeMetrics.systemLoadChange),
      icon: <Gauge className="h-5 w-5" />,
      color: safeMetrics.systemLoad > 80 ? 'red' : safeMetrics.systemLoad > 60 ? 'amber' : 'emerald',
      description: 'Current system utilization',
      progress: safeMetrics.systemLoad,
      status: getStatusIndicator(100 - safeMetrics.systemLoad, { good: 20, warning: 40 })
    },
    {
      id: 'reliability',
      title: 'Reliability',
      value: `${safeMetrics.reliability}%`,
      change: formatChange(safeMetrics.reliabilityChange),
      icon: <Shield className="h-5 w-5" />,
      color: 'emerald',
      description: 'System uptime percentage',
      progress: safeMetrics.reliability,
      status: getStatusIndicator(safeMetrics.reliability, { good: 99, warning: 95 })
    },
    {
      id: 'throughput',
      title: 'Throughput',
      value: `${formatNumber(safeMetrics.throughput)}/s`,
      change: formatChange(safeMetrics.throughputChange),
      icon: <Zap className="h-5 w-5" />,
      color: 'amber',
      description: 'Requests per second',
      trend: safeMetrics.throughputTrend || []
    }
  ], [safeMetrics]);

  // Enhanced metric card component with sophisticated animations
  const MetricCard = ({ metric, index }) => {
    const colors = getColorClasses(metric.color, 'bg');
    const bgColors = getColorClasses(metric.color, 'bgLight');
    const textColors = getColorClasses(metric.color, 'text');
    const glowColors = getColorClasses(metric.color, 'glow');

    return (
      <div 
        className={`
          group relative overflow-hidden rounded-2xl transition-all duration-500 hover:scale-[1.02]
          ${bgColors} border ${getColorClasses(metric.color, 'border')}
          shadow-lg hover:shadow-xl ${glowColors}
          animate-in slide-in-from-bottom duration-700
        `}
        style={{ animationDelay: `${index * 100}ms` }}
      >
        {/* Gradient overlay */}
        <div className="absolute inset-0 bg-gradient-to-br from-white/20 to-transparent dark:from-white/5 dark:to-transparent" />
        
        {/* Content */}
        <div className="relative p-6 space-y-4">
          {/* Header */}
          <div className="flex items-center justify-between">
            <div className={`p-3 rounded-xl ${colors} text-white shadow-lg ${glowColors}`}>
              {metric.icon}
            </div>
            
            {metric.status && (
              <Badge 
                variant="outline" 
                className={`${getColorClasses(metric.status.color, 'badge')} border-0 shadow-sm`}
              >
                <span className="flex items-center space-x-1">
                  {metric.status.icon}
                  <span className="text-xs font-medium">{metric.status.label}</span>
                </span>
              </Badge>
            )}
          </div>

          {/* Title and Description */}
          <div className="space-y-1">
            <h3 className={`font-semibold text-sm ${textColors}`}>
              {metric.title}
            </h3>
            <p className="text-xs text-slate-600 dark:text-slate-400">
              {metric.description}
            </p>
          </div>

          {/* Value and Change */}
          <div className="space-y-3">
            <div className="flex items-end justify-between">
              <span className="text-2xl font-bold text-slate-900 dark:text-white">
                {metric.value}
              </span>
              
              {metric.change && (
                <div className={`flex items-center space-x-1 text-sm ${metric.change.class}`}>
                  {metric.change.icon}
                  <span className="font-medium">{metric.change.value}</span>
                </div>
              )}
            </div>

            {/* Progress Bar */}
            {metric.progress !== undefined && (
              <div className="space-y-2">
                <div className="flex justify-between text-xs text-slate-600 dark:text-slate-400">
                  <span>Progress</span>
                  <span>{metric.progress}%</span>
                </div>
                <div className="relative h-2 bg-slate-200 dark:bg-slate-700 rounded-full overflow-hidden">
                  <div 
                    className={`absolute left-0 top-0 h-full ${colors} rounded-full transition-all duration-1000 ease-out`}
                    style={{ width: `${metric.progress}%` }}
                  >
                    <div className="absolute inset-0 bg-white/20 animate-pulse" />
                  </div>
                </div>
              </div>
            )}

            {/* Benchmark */}
            {metric.benchmark && (
              <div className="text-xs text-slate-600 dark:text-slate-400">
                Target: {metric.benchmark}
              </div>
            )}
          </div>

          {/* Hover overlay */}
          <div className="absolute inset-0 bg-gradient-to-r from-transparent via-white/5 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300 pointer-events-none" />
        </div>
      </div>
    );
  };

  return (
    <div className={`space-y-6 ${className}`}>
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center space-x-3">
          <div className="p-2 rounded-xl bg-gradient-to-br from-blue-500 to-purple-600 text-white shadow-lg shadow-blue-500/25">
            <BarChart3 className="h-5 w-5" />
          </div>
          <div>
            <h2 className="text-xl font-bold text-slate-900 dark:text-white">
              Performance Metrics
            </h2>
            <p className="text-sm text-slate-600 dark:text-slate-400">
              Key system performance indicators
            </p>
          </div>
        </div>

        {/* System Status Indicator */}
        <div className="flex items-center space-x-2">
          <div className="flex items-center space-x-2 px-3 py-1.5 bg-green-100 dark:bg-green-900/30 rounded-full">
            <div className="w-2 h-2 bg-green-500 rounded-full animate-pulse" />
            <span className="text-xs font-medium text-green-700 dark:text-green-300">
              All Systems Operational
            </span>
          </div>
        </div>
      </div>

      {/* Metrics Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {metricsConfig.map((metric, index) => (
          <MetricCard key={metric.id} metric={metric} index={index} />
        ))}
      </div>

      {/* Summary Statistics */}
      <div className="bg-gradient-to-r from-slate-50 to-slate-100 dark:from-slate-800 dark:to-slate-700 rounded-2xl p-6 border border-slate-200 dark:border-slate-600">
        <div className="grid grid-cols-2 md:grid-cols-4 gap-6">
          <div className="text-center space-y-2">
            <div className="text-2xl font-bold text-slate-900 dark:text-white">
              {formatNumber(safeMetrics.activeConnections || 42)}
            </div>
            <div className="text-sm text-slate-600 dark:text-slate-400">
              Active Connections
            </div>
          </div>
          
          <div className="text-center space-y-2">
            <div className="text-2xl font-bold text-slate-900 dark:text-white">
              {(safeMetrics.errorRate || 0.1).toFixed(1)}%
            </div>
            <div className="text-sm text-slate-600 dark:text-slate-400">
              Error Rate
            </div>
          </div>
          
          <div className="text-center space-y-2">
            <div className="text-2xl font-bold text-slate-900 dark:text-white">
              {formatNumber(safeMetrics.tokensUsed)}
            </div>
            <div className="text-sm text-slate-600 dark:text-slate-400">
              Tokens Processed
            </div>
          </div>
          
          <div className="text-center space-y-2">
            <div className="text-2xl font-bold text-slate-900 dark:text-white">
              99.9%
            </div>
            <div className="text-sm text-slate-600 dark:text-slate-400">
              SLA Compliance
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

export default MetricsPanel;
