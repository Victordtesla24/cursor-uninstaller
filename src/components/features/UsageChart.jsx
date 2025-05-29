import React, { useState, useEffect, useRef, useCallback, useMemo } from 'react';
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
  Separator,
  Badge,
  Button
} from './ui/index.js';
import {
  BarChart3,
  LineChart,
  Calendar,
  Layers,
  FileType,
  Code,
  ActivityIcon,
  Info,
  TrendingUp,
  Cpu,
  FileText,
  Star
} from 'lucide-react';
import Chart from 'chart.js/auto';

/**
 * UsageChart Component
 *
 * Displays usage statistics in various chart formats
 * Includes token usage over time, usage by model, function, and file type
 * Provides filtering options and chart type selection
 *
 * @param {Object} props Component props
 * @param {Object} props.usageData Token usage data
 * @param {String} props.className Additional CSS classes
 * @param {Boolean} props.darkMode Whether dark mode is enabled
 */
const UsageChart = ({ usageData = {}, className = '', darkMode = false }) => {
  const [chartView, setChartView] = useState('daily');
  const [chartType, setChartType] = useState('line');
  const chartRef = useRef(null);
  const chartInstance = useRef(null);

  // Safely extract data with defaults
  const safeUsageData = {
    totalTokens: 0,
    inputTokens: 0,
    outputTokens: 0,
    activeUsers: 0,
    ...usageData
  };

  // Format large numbers with appropriate suffixes
  const formatNumber = (num) => {
    if (num >= 1000000) {
      return `${(num / 1000000).toFixed(1)}M`;
    }
    if (num >= 1000) {
      return `${(num / 1000).toFixed(1)}K`;
    }
    return num?.toString() || '0';
  };

  // Get chart data based on current view
  const getChartData = () => {
    if (!usageData) {
      return [];
    }
    
    switch (chartView) {
      case 'daily':
        return usageData.daily || [];
      case 'byModel':
        return usageData.byModel || {};
      case 'byFunction':
        return usageData.byFunction || {};
      case 'byFile':
        return usageData.byFileType || {};
      case 'popularity':
        return usageData.popularity || {};
      default:
        return [];
    }
  };

  // Generate consistent colors for charts
  const getChartColors = (count = 8) => [
    'rgba(99, 102, 241, 0.7)',   // indigo
    'rgba(59, 130, 246, 0.7)',   // blue
    'rgba(16, 185, 129, 0.7)',   // emerald
    'rgba(245, 158, 11, 0.7)',   // amber
    'rgba(239, 68, 68, 0.7)',    // red
    'rgba(168, 85, 247, 0.7)',   // purple
    'rgba(236, 72, 153, 0.7)',   // pink
    'rgba(14, 165, 233, 0.7)'    // sky
  ];

  // Get appropriate icon for current view
  const getViewIcon = () => {
    switch (chartView) {
      case 'daily': return <TrendingUp className="h-4 w-4" />;
      case 'byModel': return <Cpu className="h-4 w-4" />;
      case 'byFunction': return <Code className="h-4 w-4" />;
      case 'byFile': return <FileText className="h-4 w-4" />;
      case 'popularity': return <Star className="h-4 w-4" />;
      default: return <BarChart3 className="h-4 w-4" />;
    }
  };

  // Render the appropriate chart when component mounts or data changes
  useEffect(() => {
    if (!chartRef.current || !usageData) {
      return;
    }

    // If a chart already exists, destroy it
    if (chartInstance.current) {
      chartInstance.current.destroy();
    }

    const data = getChartData();
    const isTimeSeries = chartView === 'daily';
    const ctx = chartRef.current.getContext('2d');
    const colors = getChartColors();

    // Configure different chart types
    if (isTimeSeries) {
      // Time series data (daily)
      const labels = data.map((_, i) => `Day ${i + 1}`);

      chartInstance.current = new Chart(ctx, {
        type: chartType,
        data: {
          labels,
          datasets: [{
            label: 'Token Usage',
            data,
            backgroundColor: colors[0],
            borderColor: colors[0].replace('0.7', '1'),
            borderWidth: 1,
            tension: 0.3,
            fill: chartType === 'line',
          }]
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          plugins: {
            legend: {
              display: false
            },
            tooltip: {
              callbacks: {
                label: (context) => `${formatNumber(context.raw)} tokens`
              }
            }
          },
          scales: {
            y: {
              beginAtZero: true,
              ticks: {
                callback: (value) => formatNumber(value)
              }
            }
          },
          animation: {
            duration: 1000
          }
        }
      });
    } else {
      // Category data (models, functions, file types, popularity)
      const entries = Object.entries(data);

      // For the popularity chart, sort by value
      const sortedEntries = chartView === 'popularity'
        ? entries.sort((a, b) => b[1] - a[1])
        : entries;

      // Take top entries for cleaner visualization
      const topEntries = sortedEntries.slice(0, 8);
      const labels = topEntries.map(([label]) => label);
      const values = topEntries.map(([_, value]) => value);

      chartInstance.current = new Chart(ctx, {
        type: 'bar',
        data: {
          labels,
          datasets: [{
            label: 'Usage',
            data: values,
            backgroundColor: colors.slice(0, values.length),
            borderWidth: 0
          }]
        },
        options: {
          indexAxis: 'y',
          responsive: true,
          maintainAspectRatio: false,
          plugins: {
            legend: {
              display: false
            },
            tooltip: {
              callbacks: {
                label: (context) => `${formatNumber(context.raw)} tokens`
              }
            }
          },
          scales: {
            x: {
              beginAtZero: true,
              ticks: {
                callback: (value) => formatNumber(value)
              }
            }
          },
          animation: {
            duration: 700
          }
        }
      });
    }

    // Clean up on unmount
    return () => {
      if (chartInstance.current) {
        chartInstance.current.destroy();
      }
    };
  }, [chartView, chartType, usageData]);

  // Early return for completely empty data - MOVED AFTER useEffect
  if (!usageData) {
    return (
      <Card className={`${className} shadow-sm`}>
        <CardHeader>
          <CardTitle className="flex items-center">
            <BarChart3 className="mr-2 h-5 w-5 text-primary" />
            Usage Statistics
          </CardTitle>
          <CardDescription>
            Token usage trends and patterns
          </CardDescription>
        </CardHeader>
        <CardContent className="flex flex-col items-center justify-center gap-3 h-48 text-muted-foreground">
          <Info className="h-10 w-10 text-amber-500 opacity-80" />
          <p className="text-center">No usage data available</p>
        </CardContent>
      </Card>
    );
  }

  return (
    <Card className={`${className} shadow-sm hover:shadow-md transition-shadow duration-200`}>
      <CardHeader className="pb-3">
        <CardTitle className="flex items-center">
          <BarChart3 className="mr-2 h-5 w-5 text-primary" />
          Usage Statistics
        </CardTitle>
        <CardDescription>
          Token usage trends and patterns
        </CardDescription>
      </CardHeader>

      <CardContent className="space-y-4">
        {/* Chart Controls */}
        <div className="flex flex-col sm:flex-row gap-3 items-start sm:items-center justify-between">
          <div className="flex items-center gap-2">
            {getViewIcon()}
            <select
              value={chartView}
              onChange={(e) => setChartView(e.target.value)}
              className="bg-transparent border border-input rounded-md px-2 py-1 text-sm focus-visible:ring-1 focus-visible:ring-primary"
            >
              <option value="daily">Daily Usage</option>
              <option value="byModel">By Model</option>
              <option value="byFunction">By Function</option>
              <option value="byFile">By File Type</option>
              <option value="popularity">By Popularity</option>
            </select>
          </div>

          {chartView === 'daily' && (
            <div className="flex items-center gap-1 border border-input rounded-md overflow-hidden">
              <Button
                variant={chartType === 'line' ? 'secondary' : 'ghost'}
                size="sm"
                className="p-1 h-8"
                onClick={() => setChartType('line')}
              >
                <LineChart className="h-4 w-4" />
                <span className="ml-1.5 text-xs">Line</span>
              </Button>
              <Button
                variant={chartType === 'bar' ? 'secondary' : 'ghost'}
                size="sm"
                className="p-1 h-8"
                onClick={() => setChartType('bar')}
              >
                <BarChart3 className="h-4 w-4" />
                <span className="ml-1.5 text-xs">Bar</span>
              </Button>
            </div>
          )}
        </div>

        <Separator className="my-1" />

        {/* Usage Summary Metrics */}
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 py-2">
          <div className="text-center p-2">
            <div className="text-xs text-muted-foreground mb-1">Total Tokens</div>
            <div className="text-lg font-bold">{formatNumber(safeUsageData.totalTokens || 0)}</div>
          </div>
          <div className="text-center p-2">
            <div className="text-xs text-muted-foreground mb-1">Input Tokens</div>
            <div className="text-lg font-bold">{formatNumber(safeUsageData.inputTokens || 0)}</div>
          </div>
          <div className="text-center p-2">
            <div className="text-xs text-muted-foreground mb-1">Output Tokens</div>
            <div className="text-lg font-bold">{formatNumber(safeUsageData.outputTokens || 0)}</div>
          </div>
          <div className="text-center p-2">
            <div className="text-xs text-muted-foreground mb-1">Active Users</div>
            <div className="text-lg font-bold">{formatNumber(safeUsageData.activeUsers || 0)}</div>
          </div>
        </div>

        {/* Chart Canvas */}
        <div className="relative h-[300px] w-full">
          <canvas ref={chartRef} />
        </div>

        {/* Legend for categorical data */}
        {chartView !== 'daily' && (
          <div className="flex flex-wrap gap-2 justify-center mt-2">
            {Object.entries(getChartData()).slice(0, 8).map(([category, _], index) => (
              <Badge
                key={category}
                variant="outline"
                className="flex items-center gap-1.5"
              >
                <div
                  className="w-2 h-2 rounded-full"
                  style={{ backgroundColor: getChartColors()[index % 8] }}
                />
                <span className="text-xs">{category}</span>
              </Badge>
            ))}
          </div>
        )}
      </CardContent>
    </Card>
  );
};

export default UsageChart;
