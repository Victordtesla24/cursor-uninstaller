import React, { useState, useEffect, useRef, useCallback } from 'react';
import {
  Badge,
  Button
} from '../ui/index.js';
import {
  BarChart3,
  LineChart,
  TrendingUp,
  TrendingDown,
  Activity,
  PieChart,
  Code,
  Cpu,
  FileText,
  Star
} from 'lucide-react';
import Chart from 'chart.js/auto';

// Enhanced Chart Type Selector
function ChartTypeSelector({ activeType, onTypeChange }) {
  const chartTypes = [
    { id: 'line', icon: LineChart, label: 'Trend' },
    { id: 'bar', icon: BarChart3, label: 'Compare' },
    { id: 'doughnut', icon: PieChart, label: 'Distribution' }
  ];

  return (
    <div className="flex bg-slate-100 dark:bg-slate-800 rounded-lg p-1">
      {chartTypes.map((type) => {
        const Icon = type.icon;
        return (
          <button
            key={type.id}
            onClick={() => onTypeChange(type.id)}
            className={`
              px-3 py-2 rounded-md text-xs font-medium transition-all duration-200 flex items-center space-x-1
              ${activeType === type.id
                ? 'bg-white dark:bg-slate-700 text-blue-600 dark:text-blue-400 shadow-sm'
                : 'text-slate-600 dark:text-slate-400 hover:text-slate-900 dark:hover:text-white'
              }
            `}
          >
            <Icon className="w-3 h-3" />
            <span>{type.label}</span>
          </button>
        );
      })}
    </div>
  );
}

/**
 * Enhanced UsageChart Component with modern visualizations
 */
const UsageChart = ({ usageData = {}, darkMode, className = '' }) => { // Added darkMode prop
  const [chartView, setChartView] = useState('daily');
  const [chartType, setChartType] = useState('line');
  const chartRef = useRef(null);
  const chartInstance = useRef(null);
  const [isAnimating, setIsAnimating] = useState(false);

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
  const getChartData = useCallback(() => {
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
  }, [usageData, chartView]);

  // Generate consistent colors for charts
  const getChartColors = useCallback(() => [
    'rgba(99, 102, 241, 0.8)',   // indigo
    'rgba(59, 130, 246, 0.8)',   // blue
    'rgba(16, 185, 129, 0.8)',   // emerald
    'rgba(245, 158, 11, 0.8)',   // amber
    'rgba(239, 68, 68, 0.8)',    // red
    'rgba(168, 85, 247, 0.8)',   // purple
    'rgba(236, 72, 153, 0.8)',   // pink
    'rgba(14, 165, 233, 0.8)'    // sky
  ], []);



  // Calculate trend for display
  const getTrend = () => {
    const data = getChartData();
    if (!Array.isArray(data) || data.length < 2) return { direction: 'stable', value: 0 };
    
    const recent = data.slice(-2);
    const current = recent[1]?.tokens || recent[1]?.value || 0;
    const previous = recent[0]?.tokens || recent[0]?.value || 0;
    const change = current - previous;
    const percentage = previous > 0 ? ((change / previous) * 100) : 0;
    
    return {
      direction: change > 0 ? 'up' : change < 0 ? 'down' : 'stable',
      value: Math.abs(percentage).toFixed(1)
    };
  };

  // Enhanced chart creation with modern styling
  const createChart = useCallback(() => {
    if (!chartRef.current) return;

    // Destroy existing chart
    if (chartInstance.current) {
      chartInstance.current.destroy();
      chartInstance.current = null;
    }

    const ctx = chartRef.current.getContext('2d');
    if (!ctx) {
      console.error('Failed to create chart: can\'t acquire context from the given item');
      return;
    }

    const data = getChartData();
    const colors = getChartColors();

    const chartConfig = {
      type: chartType,
      data: {
        labels: Array.isArray(data) 
          ? data.map((item, index) => item.label || item.timestamp || `Day ${index + 1}`)
          : Object.keys(data),
        datasets: [{
          label: 'Token Usage',
          data: Array.isArray(data) 
            ? data.map(item => item.tokens || item.value || 0)
            : Object.values(data),
          backgroundColor: chartType === 'doughnut' ? colors : colors[0],
          borderColor: chartType === 'doughnut' ? '#ffffff' : colors[0],
          borderWidth: 2,
          tension: chartType === 'line' ? 0.4 : 0,
          fill: chartType === 'line'
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        animation: {
          duration: 1000,
          easing: 'easeInOutCubic',
          onProgress: () => setIsAnimating(true),
          onComplete: () => setIsAnimating(false)
        },
        plugins: {
          legend: {
            position: 'top',
            labels: {
              padding: 20,
              font: { size: 12, weight: '500' },
              color: darkMode ? '#94a3b8' : '#64748b', // Adjusted for dark mode
              usePointStyle: true
            }
          },
          tooltip: {
            backgroundColor: darkMode ? 'rgba(30, 41, 59, 0.9)' : 'rgba(15, 23, 42, 0.9)', // Adjusted for dark mode
            titleColor: darkMode ? '#e2e8f0' : '#f1f5f9', // Adjusted for dark mode
            bodyColor: darkMode ? '#94a3b8' : '#cbd5e1', // Adjusted for dark mode
            borderColor: darkMode ? '#475569' : '#334155', // Adjusted for dark mode
            borderWidth: 1,
            cornerRadius: 8,
            padding: 12,
            callbacks: {
              label: (context) => `${context.dataset.label}: ${context.parsed.y?.toLocaleString() || context.parsed}`
            }
          }
        },
        scales: chartType !== 'doughnut' ? {
          x: {
            grid: {
              color: darkMode ? 'rgba(71, 85, 105, 0.2)' : 'rgba(226, 232, 240, 0.3)', // Adjusted for dark mode
              drawBorder: false
            },
            ticks: {
              color: darkMode ? '#94a3b8' : '#64748b', // Adjusted for dark mode
              font: { size: 11 }
            }
          },
          y: {
            grid: {
              color: darkMode ? 'rgba(71, 85, 105, 0.2)' : 'rgba(226, 232, 240, 0.3)', // Adjusted for dark mode
              drawBorder: false
            },
            ticks: {
              color: darkMode ? '#94a3b8' : '#64748b', // Adjusted for dark mode
              font: { size: 11 },
              callback: function(value) {
                return value.toLocaleString();
              }
            }
          }
        } : {}
      }
    };

    try {
      chartInstance.current = new Chart(ctx, chartConfig);
    } catch (error) {
      console.error('Error creating chart:', error);
    }
  }, [chartType, darkMode, getChartData, getChartColors]); // Dependencies optimized

  // Chart view options
  const chartViews = [
    { id: 'daily', label: 'Daily Usage', icon: <TrendingUp className="h-3 w-3" /> },
    { id: 'byModel', label: 'By Model', icon: <Cpu className="h-3 w-3" /> },
    { id: 'byFunction', label: 'By Function', icon: <Code className="h-3 w-3" /> },
    { id: 'byFile', label: 'File Types', icon: <FileText className="h-3 w-3" /> },
    { id: 'popularity', label: 'Popularity', icon: <Star className="h-3 w-3" /> }
  ];

  // Effect to update chart when data or settings change
  useEffect(() => {
    const timeoutId = setTimeout(createChart, 100);
    return () => clearTimeout(timeoutId);
  }, [createChart]);

  // Cleanup on unmount
  useEffect(() => {
    return () => {
      if (chartInstance.current) {
        chartInstance.current.destroy();
      }
    };
  }, []);

  const trend = getTrend();

  // Removed outer Card wrapper
  return (
    <div className={`${className} ${darkMode ? 'bg-slate-800' : 'bg-white'} p-6 rounded-xl shadow-lg`}>
      <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between mb-5">
        <div className="flex items-center space-x-3 mb-3 sm:mb-0">
          <div className={`p-2 rounded-lg ${darkMode ? 'bg-blue-600/30 text-blue-300' : 'bg-blue-100 text-blue-600'}`}>
            <Activity className="h-5 w-5" />
          </div>
          <div>
            <h3 className={`text-lg font-semibold ${darkMode ? 'text-slate-100' : 'text-slate-800'}`}>
              Usage Analytics
            </h3>
            <p className={`text-sm ${darkMode ? 'text-slate-400' : 'text-slate-500'}`}>
              Token consumption and performance trends
            </p>
          </div>
        </div>
        
        <div className="flex items-center space-x-3">
          {trend.direction !== 'stable' && (
            <Badge variant={trend.direction === 'up' ? (darkMode ? 'successOutline' : 'success') : (darkMode ? 'destructiveOutline' : 'destructive')} className="flex items-center space-x-1 text-xs px-2 py-1">
              {trend.direction === 'up' ? (
                <TrendingUp className="w-3 h-3" />
              ) : (
                <TrendingDown className="w-3 h-3" />
              )}
              <span>{trend.value}%</span>
            </Badge>
          )}
          <ChartTypeSelector activeType={chartType} onTypeChange={setChartType} />
        </div>
      </div>

      <div className={`flex flex-wrap gap-2 mb-5 p-1 rounded-lg ${darkMode ? 'bg-slate-700/50' : 'bg-slate-100'}`}>
        {chartViews.map((view) => (
          <Button
            key={view.id}
            variant={chartView === view.id ? (darkMode ? 'primaryDark' : 'primary') : 'ghost'}
            size="sm"
            onClick={() => setChartView(view.id)}
            className={`flex-grow sm:flex-none flex items-center space-x-1.5 text-xs px-3 py-1.5 rounded-md transition-all
              ${chartView === view.id 
                ? (darkMode ? 'bg-blue-600 text-white hover:bg-blue-500' : 'bg-blue-500 text-white hover:bg-blue-600')
                : (darkMode ? 'text-slate-300 hover:bg-slate-600 hover:text-white' : 'text-slate-600 hover:bg-slate-200 hover:text-slate-800')
              }`}
          >
            {view.icon}
            <span>{view.label}</span>
          </Button>
        ))}
      </div>
      
      <div className="relative">
        {isAnimating && (
          <div className={`absolute inset-0 ${darkMode ? 'bg-blue-500/10' : 'bg-blue-500/5'} rounded-lg animate-pulse z-10`} />
        )}
        <div className="relative h-[300px] sm:h-[320px] w-full"> {/* Adjusted height for responsiveness */}
          <canvas ref={chartRef} />
        </div>
      </div>
      
      <div className="mt-6 grid grid-cols-2 md:grid-cols-4 gap-4 text-center">
        {[
          { label: 'Total Tokens', value: safeUsageData.totalTokens, color: 'blue' },
          { label: 'Input Tokens', value: safeUsageData.inputTokens, color: 'emerald' },
          { label: 'Output Tokens', value: safeUsageData.outputTokens, color: 'amber' },
          { label: 'Active Users', value: safeUsageData.activeUsers, color: 'purple' }
        ].map(stat => (
          <div key={stat.label} className={`p-3 rounded-lg ${darkMode ? `bg-slate-700/70 border border-slate-600/50` : `bg-slate-50 border border-slate-200/70`}`}>
            <div className={`text-xs font-medium ${darkMode ? `text-${stat.color}-400` : `text-${stat.color}-600`}`}>{stat.label}</div>
            <div className={`text-lg font-bold ${darkMode ? `text-${stat.color}-300` : `text-${stat.color}-700`}`}>
              {formatNumber(stat.value)}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

export default UsageChart;
