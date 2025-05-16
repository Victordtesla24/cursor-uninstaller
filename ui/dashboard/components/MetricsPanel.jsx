import React, { useMemo } from 'react';
import {
  Card,
  CardContent,
  CardHeader,
  CardTitle,
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
  Badge,
  Separator
} from "./ui/index.js";
import {
  TrendingUp,
  TrendingDown,
  Zap,
  Database,
  Clock,
  Users,
  Server,
  Activity,
  BarChart4
} from "lucide-react";

/**
 * MetricsPanel Component
 *
 * Displays key system metrics in a clean, modern card layout with animated data visualization
 *
 * @param {Object} props Component props
 * @param {Object} props.metrics System metrics data
 * @param {String} props.className Additional CSS classes
 * @param {Boolean} props.darkMode Whether dark mode is enabled
 */
function MetricsPanel({ metrics = {}, className = '', darkMode = false }) {
  // Helper to format percentage changes
  const formatChange = (value) => {
    if (value === undefined || value === null) return null;

    const formatted = Math.abs(value).toFixed(1);
    const direction = value >= 0 ? 'up' : 'down';
    return { value: formatted, direction };
  };

  // Use sensible defaults for missing metrics
  const defaultMetrics = {
    avgResponseTime: 0.8,
    cacheHitRate: 0.0,
    dailyActiveUsers: 0,
    completionRate: 0.0,
    reliability: 99.5,
  };

  // Map API metrics to component metrics with fallbacks
  const mappedMetrics = useMemo(() => ({
    responseTime: metrics?.avgResponseTime ?? defaultMetrics.avgResponseTime,
    responseTimeChange: metrics?.responseTimeChange ?? 0,
    cacheHitRate: metrics?.cacheHitRate ?? defaultMetrics.cacheHitRate,
    cacheHitRateChange: metrics?.cacheHitRateChange ?? 0,
    activeSessions: metrics?.dailyActiveUsers ?? defaultMetrics.dailyActiveUsers,
    activeSessionsChange: metrics?.activeSessionsChange ?? 0,
    systemLoad: metrics?.completionRate ?? defaultMetrics.completionRate,
    systemLoadChange: metrics?.systemLoadChange ?? 0,
    reliability: metrics?.reliability ?? defaultMetrics.reliability,
    reliabilityChange: metrics?.reliabilityChange ?? 0,
  }), [metrics]);

  // Define metrics cards with icons, formatters, and visualization settings
  const metricCards = useMemo(() => [
    {
      id: 'responseTime',
      title: 'Response Time',
      value: `${mappedMetrics.responseTime.toFixed(1)}ms`,
      change: formatChange(mappedMetrics.responseTimeChange),
      icon: <Clock className="h-4 w-4" />,
      description: 'Average AI response time',
      // For response time, down is good (faster)
      changeIsBetter: (direction) => direction === 'down',
      color: 'blue',
      progressValue: Math.min(mappedMetrics.responseTime / 10, 1) * 100, // Scale for visualization
      ariaLabel: `Response time is ${mappedMetrics.responseTime.toFixed(1)} milliseconds`
    },
    {
      id: 'cacheHitRate',
      title: 'Cache Hit Rate',
      value: `${(mappedMetrics.cacheHitRate * 100).toFixed(1)}%`,
      change: formatChange(mappedMetrics.cacheHitRateChange),
      icon: <Database className="h-4 w-4" />,
      description: 'Percentage of requests served from cache',
      // For cache hit rate, up is good
      changeIsBetter: (direction) => direction === 'up',
      color: 'emerald',
      progressValue: mappedMetrics.cacheHitRate * 100,
      ariaLabel: `Cache hit rate is ${(mappedMetrics.cacheHitRate * 100).toFixed(1)} percent`
    },
    {
      id: 'reliability',
      title: 'Reliability',
      value: `${mappedMetrics.reliability.toFixed(1)}%`,
      change: formatChange(mappedMetrics.reliabilityChange),
      icon: <Zap className="h-4 w-4" />,
      description: 'System reliability and uptime percentage',
      // For reliability, up is good
      changeIsBetter: (direction) => direction === 'up',
      color: 'indigo',
      progressValue: mappedMetrics.reliability,
      ariaLabel: `System reliability is ${mappedMetrics.reliability.toFixed(1)} percent`
    },
    {
      id: 'systemLoad',
      title: 'System Load',
      value: `${(mappedMetrics.systemLoad * 100).toFixed(1)}%`,
      change: formatChange(mappedMetrics.systemLoadChange),
      icon: <Server className="h-4 w-4" />,
      description: 'Current system resource utilization',
      // For system load, down is good (less load)
      changeIsBetter: (direction) => direction === 'down',
      color: 'amber',
      progressValue: mappedMetrics.systemLoad * 100,
      ariaLabel: `System load is ${(mappedMetrics.systemLoad * 100).toFixed(1)} percent`
    }
  ], [mappedMetrics]);

  // Get CSS classes for specific color themes
  const getColorClasses = (color, type) => {
    const colorMap = {
      blue: {
        bg: darkMode ? 'bg-blue-900/20' : 'bg-blue-100',
        bgFill: darkMode ? 'bg-blue-600/70' : 'bg-blue-500/70',
        text: darkMode ? 'text-blue-400' : 'text-blue-600',
      },
      emerald: {
        bg: darkMode ? 'bg-emerald-900/20' : 'bg-emerald-100',
        bgFill: darkMode ? 'bg-emerald-600/70' : 'bg-emerald-500/70',
        text: darkMode ? 'text-emerald-400' : 'text-emerald-600',
      },
      indigo: {
        bg: darkMode ? 'bg-indigo-900/20' : 'bg-indigo-100',
        bgFill: darkMode ? 'bg-indigo-600/70' : 'bg-indigo-500/70',
        text: darkMode ? 'text-indigo-400' : 'text-indigo-600',
      },
      amber: {
        bg: darkMode ? 'bg-amber-900/20' : 'bg-amber-100',
        bgFill: darkMode ? 'bg-amber-600/70' : 'bg-amber-500/70',
        text: darkMode ? 'text-amber-400' : 'text-amber-600',
      },
      violet: {
        bg: darkMode ? 'bg-violet-900/20' : 'bg-violet-100',
        bgFill: darkMode ? 'bg-violet-600/70' : 'bg-violet-500/70',
        text: darkMode ? 'text-violet-400' : 'text-violet-600',
      }
    };

    return colorMap[color]?.[type] || '';
  };

  // If no metrics data, show placeholder with improved loading state
  if (!metrics || Object.keys(metrics).length === 0) {
    return (
      <div
        className={`grid gap-4 ${className} grid-cols-1 sm:grid-cols-2 lg:grid-cols-4`}
        aria-label="Loading metrics dashboard"
      >
        {metricCards.map((metric) => (
          <Card
            key={metric.id}
            className="hover:shadow-md transition-all duration-200 overflow-hidden border border-border/50"
            aria-busy="true"
          >
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-sm font-medium">
                {metric.title}
              </CardTitle>
              <TooltipProvider>
                <Tooltip delayDuration={300}>
                  <TooltipTrigger asChild>
                    <div className={`rounded-full ${getColorClasses(metric.color, 'bg')} p-1.5 ${getColorClasses(metric.color, 'text')} opacity-80`}>
                      {metric.icon}
                    </div>
                  </TooltipTrigger>
                  <TooltipContent side="top">
                    <p>{metric.description}</p>
                  </TooltipContent>
                </Tooltip>
              </TooltipProvider>
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-muted-foreground animate-pulse">
                {metric.value} <span className="text-xs font-normal">(Default)</span>
              </div>
              <div className="mt-2 flex items-center gap-1">
                <span className="text-xs text-muted-foreground">Awaiting data...</span>
              </div>

              {/* Loading state for the bar */}
              <div className="mt-3 pt-3 border-t border-border">
                <div className="h-1.5 w-full bg-muted rounded-full overflow-hidden">
                  <div className="h-full rounded-full bg-muted-foreground/30 animate-pulse" style={{ width: '50%' }}></div>
                </div>
              </div>
            </CardContent>
          </Card>
        ))}
      </div>
    );
  }

  return (
    <div
      className={`grid gap-4 ${className} grid-cols-1 sm:grid-cols-2 lg:grid-cols-4`}
      aria-label="Performance metrics dashboard"
    >
      {metricCards.map((metric, index) => (
        <Card
          key={metric.id}
          className={`hover:shadow-md transition-all duration-300 overflow-hidden border border-border/60
                      animate-in fade-in slide-in-from-bottom-3
                     ${darkMode ? 'bg-card/95' : 'bg-card'}`}
          style={{ animationDelay: `${index * 75}ms` }}
          aria-labelledby={`metric-title-${metric.id}`}
        >
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium" id={`metric-title-${metric.id}`}>
              {metric.title}
            </CardTitle>
            <TooltipProvider>
              <Tooltip delayDuration={300}>
                <TooltipTrigger asChild>
                  <div
                    className={`rounded-full ${getColorClasses(metric.color, 'bg')} p-1.5 ${getColorClasses(metric.color, 'text')}`}
                    aria-hidden="true"
                  >
                    {metric.icon}
                  </div>
                </TooltipTrigger>
                <TooltipContent side="top">
                  <p>{metric.description}</p>
                </TooltipContent>
              </Tooltip>
            </TooltipProvider>
          </CardHeader>
          <CardContent className="pt-2">
            <div className="text-2xl font-bold" aria-label={metric.ariaLabel}>
              {metric.value}
            </div>

            {metric.change && (
              <div className="mt-2 flex items-center gap-1">
                <Badge
                  variant="outline"
                  className={
                    metric.changeIsBetter(metric.change.direction)
                      ? "bg-emerald-100 text-emerald-800 dark:bg-emerald-900/30 dark:text-emerald-400"
                      : "bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-400"
                  }
                  aria-label={`${metric.change.direction === 'up' ? 'Increased' : 'Decreased'} by ${metric.change.value} percent`}
                >
                  {metric.change.direction === 'up' ? (
                    <TrendingUp className="mr-1 h-3 w-3" aria-hidden="true" />
                  ) : (
                    <TrendingDown className="mr-1 h-3 w-3" aria-hidden="true" />
                  )}
                  {metric.change.value}%
                </Badge>
                <span className="text-xs text-muted-foreground">vs last period</span>
              </div>
            )}

            {/* Visual representation of the metric with animated progress */}
            <div className="mt-3 pt-3 border-t border-border">
              <div
                className="h-2 w-full bg-muted rounded-full overflow-hidden"
                role="progressbar"
                aria-valuenow={metric.progressValue}
                aria-valuemin="0"
                aria-valuemax="100"
              >
                <div
                  className={`h-full rounded-full transition-all duration-1000 ease-in-out ${getColorClasses(metric.color, 'bgFill')}`}
                  style={{ width: `${metric.progressValue}%` }}
                ></div>
              </div>
            </div>
          </CardContent>
        </Card>
      ))}
    </div>
  );
}

export default MetricsPanel;
