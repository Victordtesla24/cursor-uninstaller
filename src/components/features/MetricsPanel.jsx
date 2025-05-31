import React, { useState, useEffect } from 'react';
import {
  Badge,
  Progress,
  Button,
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger
} from '../ui/index.js';
import MetricCard from './MetricCard.jsx';
import {
  Activity,
  TrendingUp,
  TrendingDown,
  Zap,
  Clock,
  Target,
  AlertTriangle,
  CheckCircle,
  BarChart3,
  Gauge,
  Cpu,
  Database,
  Settings,
  RefreshCw,
  Shield
} from 'lucide-react';

// Performance Status Indicator
function PerformanceStatus({ status, label }) {
  const statusConfig = {
    excellent: {
      icon: CheckCircle,
      color: 'text-emerald-600 dark:text-emerald-400',
      bg: 'bg-emerald-100 dark:bg-emerald-900/20',
      label: 'Excellent'
    },
    good: {
      icon: CheckCircle,
      color: 'text-blue-600 dark:text-blue-400',
      bg: 'bg-blue-100 dark:bg-blue-900/20',
      label: 'Good'
    },
    warning: {
      icon: AlertTriangle,
      color: 'text-amber-600 dark:text-amber-400',
      bg: 'bg-amber-100 dark:bg-amber-900/20',
      label: 'Needs Attention'
    },
    critical: {
      icon: AlertTriangle,
      color: 'text-red-600 dark:text-red-400',
      bg: 'bg-red-100 dark:bg-red-900/20',
      label: 'Critical'
    }
  };

  const config = statusConfig[status] || statusConfig.good;
  const Icon = config.icon;

  return (
    <div className={`inline-flex items-center px-3 py-2 rounded-full text-sm font-medium ${config.bg} ${config.color}`}>
      <Icon className="w-4 h-4 mr-2" />
      <span>{label || config.label}</span>
    </div>
  );
}

/**
 * Enhanced MetricsPanel Component with modern design
 */
const MetricsPanel = ({ metricsData = {}, darkMode, className = '' }) => { // Added darkMode prop
  const [isVisible, setIsVisible] = useState(false);

  // Animation effect on mount
  useEffect(() => {
    const timer = setTimeout(() => setIsVisible(true), 100);
    return () => clearTimeout(timer);
  }, []);

  // Safely extract metrics with defaults - handle both old and new data structures
  const safeMetrics = {
    totalRequests: metricsData?.totalRequests || 0,
    avgResponseTime: metricsData?.avgResponseTime || metricsData?.responseTime?.current || 0,
    cacheHitRate: metricsData?.cacheHitRate || metricsData?.cacheHitRate?.current || 0,
    systemLoad: metricsData?.systemLoad || 0,
    memoryUsage: metricsData?.memoryUsage || 0,
    errorRate: metricsData?.errorRate?.current || metricsData?.errorRate || 0,
    throughput: metricsData?.throughput?.current || metricsData?.throughput || 0,
    activeConnections: metricsData?.activeConnections || 0,
    reliability: metricsData?.reliability?.current || 0,
    costMetrics: metricsData?.costMetrics || {}
  };

  // Calculate system health status
  const getSystemHealth = () => {
    const { avgResponseTime, systemLoad, errorRate, memoryUsage } = safeMetrics;
    
    if (avgResponseTime > 5000 || systemLoad > 90 || errorRate > 5 || memoryUsage > 90) {
      return 'critical';
    }
    if (avgResponseTime > 2000 || systemLoad > 70 || errorRate > 2 || memoryUsage > 70) {
      return 'warning';
    }
    if (avgResponseTime < 1000 && systemLoad < 50 && errorRate < 1 && memoryUsage < 50) {
      return 'excellent';
    }
    return 'good';
  };

  // Format numbers with appropriate units
  const formatMetricValue = (value, type) => {
    if (typeof value !== 'number') return '0';
    
    switch (type) {
      case 'time':
        return value < 1000 ? `${value.toFixed(0)}ms` : `${(value / 1000).toFixed(1)}s`;
      case 'percentage':
        return `${value.toFixed(1)}%`;
      case 'bytes':
        if (value < 1024) return `${value.toFixed(0)}B`;
        if (value < 1024 * 1024) return `${(value / 1024).toFixed(1)}KB`;
        if (value < 1024 * 1024 * 1024) return `${(value / (1024 * 1024)).toFixed(1)}MB`;
        return `${(value / (1024 * 1024 * 1024)).toFixed(1)}GB`;
      case 'rate':
        return value >= 1000 ? `${(value / 1000).toFixed(1)}K/s` : `${value.toFixed(0)}/s`;
      default:
        return value >= 1000 ? `${(value / 1000).toFixed(1)}K` : value.toFixed(0);
    }
  };

  // Calculate performance trends (mock data for demonstration)
  const getTrend = (current, baseline = 100) => {
    const change = ((current - baseline) / baseline) * 100;
    return {
      direction: change > 5 ? 'up' : change < -5 ? 'down' : 'stable',
      percentage: Math.abs(change).toFixed(1)
    };
  };

  const systemHealth = getSystemHealth();

  // The outer Card is removed as MetricsPanel is already wrapped in Dashboard.jsx
  return (
    <div className={`space-y-6 ${className} ${isVisible ? 'animate-fade-in' : 'opacity-0'}`}>
      {/* System Overview Header - simplified as the main title is in Dashboard.jsx */}
      <div className={`p-4 rounded-lg ${darkMode ? 'bg-slate-800/50' : 'bg-slate-50/50'}`}>
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-3">
            <div className={`p-2 rounded-lg ${darkMode ? 'bg-purple-600/30 text-purple-300' : 'bg-purple-100 text-purple-600'} shadow-md`}>
              <Gauge className="h-5 w-5" />
            </div>
            <div>
              <h3 className={`text-md font-semibold ${darkMode ? 'text-slate-100' : 'text-slate-800'}`}>
                System Metrics
              </h3>
              <p className={`text-xs ${darkMode ? 'text-slate-400' : 'text-slate-500'}`}>
                Key real-time indicators
              </p>
            </div>
          </div>
          <div className="flex items-center space-x-2">
            <PerformanceStatus status={systemHealth} />
            <TooltipProvider>
              <Tooltip>
                <TooltipTrigger asChild>
                  <Button
                    variant="outline"
                    size="sm"
                    className="h-8 w-8 p-0"
                    data-testid="button"
                  >
                    <Settings className="h-4 w-4" data-testid="settings-icon" />
                  </Button>
                </TooltipTrigger>
                <TooltipContent>
                  <p>Settings</p>
                </TooltipContent>
              </Tooltip>
            </TooltipProvider>
            <TooltipProvider>
              <Tooltip>
                <TooltipTrigger asChild>
                  <Button
                    variant="outline"
                    size="sm"
                    className="h-8 w-8 p-0"
                    data-testid="button"
                  >
                    <RefreshCw className="h-4 w-4" data-testid="refresh-cw-icon" />
                  </Button>
                </TooltipTrigger>
                <TooltipContent>
                  <p>Refresh</p>
                </TooltipContent>
              </Tooltip>
            </TooltipProvider>
          </div>
        </div>
      </div>

      {/* Primary Metrics Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
        <MetricCard
          title="Response Time"
          value={`${safeMetrics.avgResponseTime}ms`}
          change={`${getTrend(safeMetrics.avgResponseTime, 2000).direction === 'up' ? '+' : '-'}${getTrend(safeMetrics.avgResponseTime, 2000).percentage}%`}
          trend={getTrend(safeMetrics.avgResponseTime, 2000).direction === 'up' ? 'down' : 'up'} // Inverted
          icon={Clock}
          color="green"
          description="Average response time"
          target={1000}
          data-testid="card"
        />
        <MetricCard
          title="Reliability"
          value={`${safeMetrics.reliability}%`}
          change={`+${getTrend(safeMetrics.reliability, 99).percentage}%`}
          trend={getTrend(safeMetrics.reliability, 99).direction}
          icon={Shield}
          color="blue"
          description="System reliability"
          data-testid="card"
        />
        <MetricCard
          title="Throughput"
          value={safeMetrics.throughput?.toLocaleString() || '0'}
          change={`+${getTrend(safeMetrics.throughput, 500).percentage}%`}
          trend={getTrend(safeMetrics.throughput, 500).direction}
          icon={Activity}
          color="green"
          description="req/min"
          data-testid="card"
        />
        <MetricCard
          title="Error Rate"
          value={`${safeMetrics.errorRate}%`}
          change={`${getTrend(safeMetrics.errorRate, 1).direction === 'up' ? '+' : '-'}${getTrend(safeMetrics.errorRate, 1).percentage}%`}
          trend={getTrend(safeMetrics.errorRate, 1).direction === 'up' ? 'down' : 'up'} // Inverted
          icon={AlertTriangle}
          color="amber"
          description="System error percentage"
          data-testid="card"
        />
      </div>

      {/* Secondary Metrics Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
        <MetricCard
          title="Cache Hit Rate"
          value={`${safeMetrics.cacheHitRate}%`}
          change={`+${getTrend(safeMetrics.cacheHitRate, 85).percentage}%`}
          trend={getTrend(safeMetrics.cacheHitRate, 85).direction}
          icon={Database}
          color="purple"
          description="Cache efficiency"
          target={90}
          data-testid="card"
        />
        <MetricCard
          title="System Load"
          value={formatMetricValue(safeMetrics.systemLoad, 'percentage')}
          change={`${getTrend(safeMetrics.systemLoad, 45).direction === 'up' ? '+' : '-'}${getTrend(safeMetrics.systemLoad, 45).percentage}%`}
          trend={getTrend(safeMetrics.systemLoad, 45).direction === 'up' ? 'down' : 'up'} // Inverted
          icon={Cpu}
          color="purple"
          description="Current CPU utilization"
          target={80}
          data-testid="card"
        />
        <MetricCard
          title="Memory Usage"
          value={formatMetricValue(safeMetrics.memoryUsage, 'percentage')}
          trend={getTrend(safeMetrics.memoryUsage, 60).direction === 'up' ? 'down' : 'up'} // Inverted
          icon={Database}
          color="blue"
          description="RAM utilization"
          target={75}
          data-testid="card"
        />
        <MetricCard
          title="Active Connections"
          value={formatMetricValue(safeMetrics.activeConnections)}
          change={`+${getTrend(safeMetrics.activeConnections, 150).percentage}%`}
          trend={getTrend(safeMetrics.activeConnections, 150).direction}
          icon={Target}
          color="purple"
          description="Concurrent users"
        />
      </div>

      {/* Performance Indicators - Refined Look */}
      <div className={`mt-6 p-5 rounded-xl ${darkMode ? 'bg-slate-800/60' : 'bg-slate-100/70'} border ${darkMode ? 'border-slate-700' : 'border-slate-200'}`}>
        <h3 className={`text-sm font-semibold mb-4 flex items-center ${darkMode ? 'text-slate-100' : 'text-slate-700'}`}>
          <Activity className="w-4 h-4 mr-2 text-blue-500" />
          Key Performance Indicators
        </h3>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-x-6 gap-y-4">
          {[
            { label: 'Response Time', value: safeMetrics.avgResponseTime, target: 1000, lowerIsBetter: true, unit: 'ms' },
            { label: 'System Health', value: systemHealth === 'excellent' ? 100 : systemHealth === 'good' ? 75 : systemHealth === 'warning' ? 50 : 25, target: 100, unit: '%' },
            { label: 'Cache Efficiency', value: safeMetrics.cacheHitRate, target: 90, unit: '%' }
          ].map(indicator => {
            const progressValue = indicator.lowerIsBetter 
              ? Math.max(0, 100 - ((indicator.value / (indicator.target * 1.5)) * 100)) // Adjusted for better visual representation
              : (indicator.value / indicator.target) * 100;
            
            let statusText = '';
            let statusColor = '';
            if (indicator.label === 'Response Time') {
              statusText = indicator.value < 1000 ? 'Excellent' : indicator.value < 2000 ? 'Good' : 'Needs Attention';
              statusColor = indicator.value < 1000 ? (darkMode ? 'text-emerald-400' : 'text-emerald-600') : indicator.value < 2000 ? (darkMode ? 'text-amber-400' : 'text-amber-600') : (darkMode ? 'text-red-400' : 'text-red-600');
            } else if (indicator.label === 'System Health') {
              statusText = systemHealth.charAt(0).toUpperCase() + systemHealth.slice(1);
              statusColor = systemHealth === 'excellent' ? (darkMode ? 'text-emerald-400' : 'text-emerald-600') : systemHealth === 'good' ? (darkMode ? 'text-blue-400' : 'text-blue-600') : systemHealth === 'warning' ? (darkMode ? 'text-amber-400' : 'text-amber-600') : (darkMode ? 'text-red-400' : 'text-red-600');
            } else { // Cache Efficiency
              statusText = indicator.value > 80 ? 'High' : indicator.value > 60 ? 'Medium' : 'Low';
              statusColor = indicator.value > 80 ? (darkMode ? 'text-emerald-400' : 'text-emerald-600') : indicator.value > 60 ? (darkMode ? 'text-amber-400' : 'text-amber-600') : (darkMode ? 'text-red-400' : 'text-red-600');
            }

            return (
              <div key={indicator.label} className="flex items-center justify-between">
                <span className={`text-xs ${darkMode ? 'text-slate-300' : 'text-slate-600'}`}>{indicator.label}</span>
                <div className="flex items-center space-x-2">
                  <Progress value={Math.min(100, Math.max(0, progressValue))} className="w-16 h-1.5" />
                  <span className={`text-xs font-medium ${statusColor}`}>
                    {statusText}
                  </span>
                </div>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
};

export default MetricsPanel;
