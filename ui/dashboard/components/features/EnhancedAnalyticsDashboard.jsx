import React, { useState, useEffect, useMemo } from 'react';
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
  CardFooter,
  Button,
  Separator,
  Badge,
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
} from "../ui";
import {
  BarChart3,
  PieChart,
  LineChart,
  Calendar,
  Filter,
  Download,
  Clock,
  Tag,
  RefreshCw,
  Search,
  FileDown,
  FileText,
  Share2,
  MailIcon,
  BarChart2,
  CreditCard,
  TrendingUp,
  TrendingDown,
  Info,
  Shield,
  Zap
} from "lucide-react";

/**
 * Enhanced Analytics Dashboard Component
 *
 * Provides advanced analytics capabilities for token usage monitoring and analysis.
 * Features include filtering, comparison, reporting, and visualization tools.
 *
 * Key features:
 * - Time-based filtering (day, week, month, custom)
 * - Model-specific and category-based filtering
 * - Period-over-period comparisons
 * - Interactive charts and visualizations
 * - Exportable reports in various formats
 * - Scheduled report generation
 *
 * @typedef {Object} UsageData
 * @property {number[]} [daily] - Daily token usage values
 * @property {Object} [weekly] - Weekly usage data
 * @property {number[]} [weekly.tokens] - Weekly token counts
 * @property {number[]} [weekly.costs] - Weekly costs
 * @property {Object} [byModel] - Usage breakdown by model
 * @property {Object} [byCategory] - Usage breakdown by category
 *
 * @typedef {Object} ModelData
 * @property {string} [selected] - Currently selected model ID
 * @property {Array<Object>} [available] - List of available models
 * @property {Object} [performance] - Performance metrics for each model
 *
 * @typedef {Object} MetricsData
 * @property {number} [avgResponseTime] - Average response time in seconds
 * @property {number} [reliability] - Reliability percentage
 * @property {number} [cacheHitRate] - Cache hit rate percentage
 * @property {number} [costSavingsRate] - Cost savings rate percentage
 *
 * @param {Object} props - Component props
 * @param {UsageData} [props.usageData={}] - Token usage data for analysis
 * @param {ModelData} [props.modelsData={}] - Model data and performance metrics
 * @param {MetricsData} [props.metrics={}] - System performance metrics
 * @param {boolean} [props.darkMode=false] - Whether dark mode is enabled
 * @param {Function} [props.onExport] - Callback when data is exported
 * @param {Function} [props.onFilterChange] - Callback when filters are changed
 *
 * @returns {JSX.Element} Rendered analytics dashboard component
 *
 * @example
 * // Basic usage
 * <EnhancedAnalyticsDashboard
 *   usageData={usageData}
 *   modelsData={modelsData}
 * />
 *
 * @example
 * // With metrics and dark mode
 * <EnhancedAnalyticsDashboard
 *   usageData={usageData}
 *   modelsData={modelsData}
 *   metrics={metricsData}
 *   darkMode={isDarkMode}
 *   onExport={handleExport}
 * />
 */
const EnhancedAnalyticsDashboard = ({
  usageData = {},
  modelsData = {},
  metrics = {},
  darkMode = false,
  onExport,
  onFilterChange
}) => {
  // State for filters
  const [timeRange, setTimeRange] = useState('week');
  const [customDateRange, setCustomDateRange] = useState({ start: null, end: null });
  const [selectedModels, setSelectedModels] = useState([]);
  const [selectedCategories, setSelectedCategories] = useState([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [tags, setTags] = useState([]);

  // State for comparison
  const [comparisonEnabled, setComparisonEnabled] = useState(false);
  const [comparisonTimeRange, setComparisonTimeRange] = useState('previous');

  // State for data export
  const [exportFormat, setExportFormat] = useState('pdf');
  const [scheduledExports, setScheduledExports] = useState([]);
  const [exportInProgress, setExportInProgress] = useState(false);

  // State for current view
  const [currentView, setCurrentView] = useState('overview');

  // Derived state
  const [filteredData, setFilteredData] = useState(null);
  const [comparisonData, setComparisonData] = useState(null);

  // Available filter options
  const availableCategories = useMemo(() => {
    return ['prompt', 'completion', 'embedding', 'fine-tuning', 'chat', 'vision'];
  }, []);

  const availableTags = useMemo(() => {
    return ['production', 'development', 'testing', 'critical', 'experimental'];
  }, []);

  // Memoized options
  const modelOptions = useMemo(() => {
    if (!modelsData || !modelsData.available) return [];
    return modelsData.available.map(model => ({
      id: model.id,
      name: model.name,
    }));
  }, [modelsData]);

    // Effect to apply filters and generate filtered data
  useEffect(() => {
    // Simulate API call or data processing when filters change
    // This is where you would typically fetch new data based on filters
    setExportInProgress(true);
    // const timer = setTimeout(() => { // Removed timer
    setFilteredData(simulateFilteredData(usageData, {
      timeRange,
      customDateRange,
        selectedModels,
        selectedCategories,
        searchTerm,
        tags
      }));
      if (comparisonEnabled) {
        setComparisonData(simulateComparisonData(usageData, {
          timeRange,
          comparisonTimeRange
        }));
      }
      setExportInProgress(false);
      // Call onFilterChange callback if provided
      if (onFilterChange) {
        onFilterChange({
          timeRange,
          customDateRange,
          selectedModels,
          selectedCategories,
          searchTerm,
          tags
        });
      }
    // }, 500); // Simulate network delay
    // return () => clearTimeout(timer); // Removed timer cleanup
  }, [
    usageData,
    timeRange,
    customDateRange,
    selectedModels,
    selectedCategories,
    searchTerm,
    tags,
    comparisonEnabled,
    comparisonTimeRange,
    onFilterChange
  ]);

  /**
   * Simulates filtered data based on the provided filters.
   * In a real application, this function would perform actual data filtering
   * based on time range, models, categories, and tags.
   *
   * @param {UsageData} data - The raw usage data.
   * @param {object} filters - The filters to apply.
   * @param {string} filters.timeRange - The selected time range ('day', 'week', 'month', 'custom').
   * @param {object} filters.customDateRange - The custom date range { start: Date, end: Date }.
   * @param {string[]} filters.selectedModels - Array of selected model IDs.
   * @param {string[]} filters.selectedCategories - Array of selected categories.
   * @param {string} filters.searchTerm - Search term for filtering (currently not used in simulation).
   * @param {string[]} filters.tags - Array of selected tags.
   * @returns {object} An object containing simulated filtered data (totalTokens, averageDailyUsage, peakUsage, series, categories, models).
   */
  const simulateFilteredData = (data, filters) => {
    // In a real implementation, this would filter the actual data
    // For now, we'll return a modified version of the input data

    // Simulate time range filtering
    const createDataPoint = (value, date) => ({
      value,
      date: date.toISOString(),
      formattedDate: date.toLocaleDateString()
    });

    const today = new Date();
    let simulatedData = {
      totalTokens: 1250000,
      averageDailyUsage: 45000,
      peakUsage: 120000,
      series: []
    };

    // Generate time series data based on selected time range
    switch (filters.timeRange) {
      case 'day':
        // Hourly data for the day
        for (let i = 0; i < 24; i++) {
          const date = new Date(today);
          date.setHours(i, 0, 0, 0);
          const value = Math.floor(Math.random() * 8000) + 2000;
          simulatedData.series.push(createDataPoint(value, date));
        }
        break;
      case 'week':
        // Daily data for the week
        for (let i = 6; i >= 0; i--) {
          const date = new Date(today);
          date.setDate(date.getDate() - i);
          const value = Math.floor(Math.random() * 40000) + 20000;
          simulatedData.series.push(createDataPoint(value, date));
        }
        break;
      case 'month':
        // Daily data for the month
        for (let i = 29; i >= 0; i--) {
          const date = new Date(today);
          date.setDate(date.getDate() - i);
          const value = Math.floor(Math.random() * 60000) + 30000;
          simulatedData.series.push(createDataPoint(value, date));
        }
        break;
      case 'custom':
        // If custom range is set, generate daily data for that range
        if (filters.customDateRange.start && filters.customDateRange.end) {
          const start = new Date(filters.customDateRange.start);
          const end = new Date(filters.customDateRange.end);
          const daysDiff = Math.floor((end - start) / (1000 * 60 * 60 * 24)) + 1;

          for (let i = 0; i < daysDiff; i++) {
            const date = new Date(start);
            date.setDate(date.getDate() + i);
            const value = Math.floor(Math.random() * 50000) + 25000;
            simulatedData.series.push(createDataPoint(value, date));
          }
        }
        break;
      default:
        // Default to weekly
        for (let i = 6; i >= 0; i--) {
          const date = new Date(today);
          date.setDate(date.getDate() - i);
          const value = Math.floor(Math.random() * 40000) + 20000;
          simulatedData.series.push(createDataPoint(value, date));
        }
    }

    // Add category breakdown
    simulatedData.categories = {
      prompt: Math.floor(simulatedData.totalTokens * 0.4),
      completion: Math.floor(simulatedData.totalTokens * 0.35),
      embedding: Math.floor(simulatedData.totalTokens * 0.15),
      chat: Math.floor(simulatedData.totalTokens * 0.08),
      vision: Math.floor(simulatedData.totalTokens * 0.02),
    };

    // Add model breakdown
    simulatedData.models = {
      'gpt-4o': Math.floor(simulatedData.totalTokens * 0.25),
      'gpt-4-turbo': Math.floor(simulatedData.totalTokens * 0.35),
      'gpt-3.5-turbo': Math.floor(simulatedData.totalTokens * 0.4),
    };

    // Apply category filters if any
    if (filters.selectedCategories && filters.selectedCategories.length > 0) {
      // Filter categories
      const filteredCategories = {};
      for (const category of filters.selectedCategories) {
        if (simulatedData.categories[category]) {
          filteredCategories[category] = simulatedData.categories[category];
        }
      }
      simulatedData.categories = filteredCategories;

      // Adjust total tokens
      simulatedData.totalTokens = Object.values(filteredCategories).reduce((sum, value) => sum + value, 0);
    }

    // Apply model filters if any
    if (filters.selectedModels && filters.selectedModels.length > 0) {
      // Filter models
      const filteredModels = {};
      for (const model of filters.selectedModels) {
        if (simulatedData.models[model]) {
          filteredModels[model] = simulatedData.models[model];
        }
      }
      simulatedData.models = filteredModels;
    }

    // Apply tag filters
    if (filters.tags && filters.tags.length > 0) {
      // In a real implementation, this would filter by tags
      // For now, we'll just adjust the data a bit to simulate filtering
      simulatedData.totalTokens = Math.floor(simulatedData.totalTokens * 0.9);
      simulatedData.series = simulatedData.series.map(point => ({
        ...point,
        value: Math.floor(point.value * 0.9)
      }));
    }

    return simulatedData;
  };

  /**
   * Simulates comparison data based on the provided filters.
   * In a real application, this would fetch and process historical data
   * for comparison with the current period.
   *
   * @param {UsageData} data - The raw usage data (currently not used in simulation).
   * @param {object} filters - The filters defining the comparison.
   * @param {string} filters.timeRange - The time range of the current period.
   * @param {string} filters.comparisonTimeRange - The type of period to compare with ('previous', 'year').
   * @returns {object} An object containing simulated comparison data (currentPeriod, previousPeriod, percentageChange).
   */
  const simulateComparisonData = (data, filters) => {
    // In a real implementation, this would generate actual comparison data
    // For now, we'll return simulated data

    const simulatedData = {
      timeRange: filters.timeRange,
      comparisonType: filters.comparisonTimeRange,
      currentPeriod: {
        totalTokens: 1250000,
        averageDailyUsage: 45000,
        peakUsage: 120000
      },
      previousPeriod: {
        totalTokens: 1050000,
        averageDailyUsage: 38000,
        peakUsage: 105000
      },
      percentageChange: {
        totalTokens: 19.05,
        averageDailyUsage: 18.42,
        peakUsage: 14.29
      }
    };

    return simulatedData;
  };

  /**
   * Handles the change in the selected time range filter.
   * Resets the custom date range if a non-custom range is selected.
   *
   * @param {string} range - The selected time range ('day', 'week', 'month', 'custom').
   */
  const handleTimeRangeChange = (range) => {
    setTimeRange(range);
    if (range !== 'custom') {
      setCustomDateRange({ start: null, end: null });
    }
  };

  /**
   * Handles the change in the custom date range.
   *
   * @param {'start' | 'end'} type - The type of date being changed ('start' or 'end').
   * @param {string} date - The new date value (ISO string or similar).
   */
  const handleCustomDateChange = (type, date) => {
    setCustomDateRange(prev => ({
      ...prev,
      [type]: date
    }));
  };

  /**
   * Handles the selection or deselection of a model filter.
   *
   * @param {string} model - The ID of the model to toggle.
   */
  const handleModelChange = (model) => {
    setSelectedModels(prev => {
      if (prev.includes(model)) {
        return prev.filter(m => m !== model);
      } else {
        return [...prev, model];
      }
    });
  };

  /**
   * Handles the selection or deselection of a category filter.
   *
   * @param {string} category - The category to toggle.
   */
  const handleCategoryChange = (category) => {
    setSelectedCategories(prev => {
      if (prev.includes(category)) {
        return prev.filter(c => c !== category);
      } else {
        return [...prev, category];
      }
    });
  };

  /**
   * Handles the selection or deselection of a tag filter.
   *
   * @param {string} tag - The tag to toggle.
   */
  const handleTagChange = (tag) => {
    setTags(prev => {
      if (prev.includes(tag)) {
        return prev.filter(t => t !== tag);
      } else {
        return [...prev, tag];
      }
    });
  };

  /**
   * Handles the data export process.
   * Simulates an asynchronous export operation.
   *
   * @param {'pdf' | 'csv'} format - The desired export format.
   */
  const handleExportData = async (format) => {
    setExportInProgress(true);
    setExportFormat(format);

    // Simulate export process
    // await new Promise(resolve => setTimeout(resolve, 1500)); // Removed delay

    // In a real implementation, this would trigger an actual export
    console.log(`Exporting data in ${format} format`);

    if (onExport) {
      onExport({ format, data: filteredData }); // Pass format and potentially data
    }

    setExportInProgress(false);

    // Show success message (in a real implementation)
  };

  /**
   * Handles scheduling a recurring report export.
   *
   * @param {'daily' | 'weekly' | 'monthly'} frequency - The desired export frequency.
   */
  const handleScheduleExport = (frequency) => {
    const newSchedule = {
      id: `schedule-${Date.now()}`,
      format: exportFormat,
      frequency,
      nextRun: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(), // Tomorrow
      filters: {
        timeRange,
        selectedModels,
        selectedCategories,
        tags
      }
    };

    setScheduledExports(prev => [...prev, newSchedule]);
  };

  /**
   * Resets all applied filters to their default state.
   */
  const resetFilters = () => {
    setTimeRange('week');
    setCustomDateRange({ start: null, end: null });
    setSelectedModels([]);
    setSelectedCategories([]);
    setSearchTerm('');
    setTags([]);
    setComparisonEnabled(false);
  };

  /**
   * Formats a number with locale-specific separators.
   *
   * @param {number} num - The number to format.
   * @returns {string} The formatted number string.
   */
  const formatNumber = (num) => {
    return num?.toLocaleString() || '0';
  };

  // Render loading state if no data available
  if (!usageData || Object.keys(usageData).length === 0) {
    return (
      <Card className={`shadow-sm hover:shadow-md transition-shadow duration-200 ${darkMode ? 'bg-card/95' : ''}`}>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <BarChart3 className="h-5 w-5 text-primary" aria-hidden="true" />
            Enhanced Analytics
          </CardTitle>
          <CardDescription>
            Advanced analytics and reporting tools
          </CardDescription>
        </CardHeader>
        <CardContent className="flex flex-col items-center justify-center py-12 space-y-4">
          <div className="h-12 w-12 animate-spin rounded-full border-4 border-primary border-t-transparent"></div>
          <p className="text-muted-foreground">Loading analytics data...</p>
        </CardContent>
      </Card>
    );
  }

  return (
    <Card className={`shadow-sm hover:shadow-md transition-shadow duration-200 ${darkMode ? 'bg-card/95' : ''}`}>
      <CardHeader>
        <div className="flex justify-between items-start">
          <div>
            <CardTitle className="flex items-center gap-2">
              <BarChart3 className="h-5 w-5 text-primary" aria-hidden="true" />
              Enhanced Analytics
            </CardTitle>
            <CardDescription>
              Advanced analytics and reporting tools
            </CardDescription>
          </div>

          <div className="flex gap-2">
            <Button
              variant="outline"
              size="sm"
              onClick={() => setCurrentView('overview')}
              className={currentView === 'overview' ? 'bg-primary text-primary-foreground hover:bg-primary/90' : ''}
            >
              Overview
            </Button>
            <Button
              variant="outline"
              size="sm"
              onClick={() => setCurrentView('detailed')}
              className={currentView === 'detailed' ? 'bg-primary text-primary-foreground hover:bg-primary/90' : ''}
            >
              Detailed
            </Button>
            <Button
              variant="outline"
              size="sm"
              onClick={() => setCurrentView('reports')}
              className={currentView === 'reports' ? 'bg-primary text-primary-foreground hover:bg-primary/90' : ''}
            >
              Reports
            </Button>
          </div>
        </div>
      </CardHeader>

      <Separator />

      {/* Filter Section */}
      <div className="px-6 py-3 bg-muted/30 border-b">
        <div className="flex flex-wrap gap-3 justify-between items-center">
          <div className="flex gap-2 flex-wrap">
            <TooltipProvider>
              <Tooltip>
                <TooltipTrigger asChild>
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => handleTimeRangeChange('day')}
                    className={timeRange === 'day' ? 'bg-primary text-primary-foreground hover:bg-primary/90' : ''}
                  >
                    Day
                  </Button>
                </TooltipTrigger>
                <TooltipContent>
                  <p>View data for the last 24 hours</p>
                </TooltipContent>
              </Tooltip>
            </TooltipProvider>

            <TooltipProvider>
              <Tooltip>
                <TooltipTrigger asChild>
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => handleTimeRangeChange('week')}
                    className={timeRange === 'week' ? 'bg-primary text-primary-foreground hover:bg-primary/90' : ''}
                  >
                    Week
                  </Button>
                </TooltipTrigger>
                <TooltipContent>
                  <p>View data for the last 7 days</p>
                </TooltipContent>
              </Tooltip>
            </TooltipProvider>

            <TooltipProvider>
              <Tooltip>
                <TooltipTrigger asChild>
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => handleTimeRangeChange('month')}
                    className={timeRange === 'month' ? 'bg-primary text-primary-foreground hover:bg-primary/90' : ''}
                  >
                    Month
                  </Button>
                </TooltipTrigger>
                <TooltipContent>
                  <p>View data for the last 30 days</p>
                </TooltipContent>
              </Tooltip>
            </TooltipProvider>

            <TooltipProvider>
              <Tooltip>
                <TooltipTrigger asChild>
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => handleTimeRangeChange('custom')}
                    className={timeRange === 'custom' ? 'bg-primary text-primary-foreground hover:bg-primary/90' : ''}
                  >
                    <Calendar className="h-4 w-4 mr-1" />
                    Custom
                  </Button>
                </TooltipTrigger>
                <TooltipContent>
                  <p>Select a custom date range</p>
                </TooltipContent>
              </Tooltip>
            </TooltipProvider>

            {/* Advanced filters button */}
            <TooltipProvider>
              <Tooltip>
                <TooltipTrigger asChild>
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => document.getElementById('filters-panel').classList.toggle('hidden')}
                  >
                    <Filter className="h-4 w-4 mr-1" />
                    Filters
                  </Button>
                </TooltipTrigger>
                <TooltipContent>
                  <p>Show advanced filters</p>
                </TooltipContent>
              </Tooltip>
            </TooltipProvider>
          </div>

          <div className="flex gap-2">
            <TooltipProvider>
              <Tooltip>
                <TooltipTrigger asChild>
                  <Button
                    variant={comparisonEnabled ? 'default' : 'outline'}
                    size="sm"
                    onClick={() => setComparisonEnabled(!comparisonEnabled)}
                  >
                    <LineChart className="h-4 w-4 mr-1" />
                    Compare
                  </Button>
                </TooltipTrigger>
                <TooltipContent>
                  <p>Enable period-over-period comparison</p>
                </TooltipContent>
              </Tooltip>
            </TooltipProvider>

            <TooltipProvider>
              <Tooltip>
                <TooltipTrigger asChild>
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => setCurrentView('reports')} // Changed to switch to reports view
                    disabled={exportInProgress}
                  >
                    {exportInProgress ? (
                      <RefreshCw className="h-4 w-4 mr-1 animate-spin" />
                    ) : (
                      <Download className="h-4 w-4 mr-1" />
                    )}
                    Export
                  </Button>
                </TooltipTrigger>
                <TooltipContent>
                  <p>View export options and schedule reports</p>
                </TooltipContent>
              </Tooltip>
            </TooltipProvider>

            <TooltipProvider>
              <Tooltip>
                <TooltipTrigger asChild>
                  <Button
                    variant="ghost"
                    size="sm"
                    onClick={resetFilters}
                  >
                    Reset
                  </Button>
                </TooltipTrigger>
                <TooltipContent>
                  <p>Reset all filters to default</p>
                </TooltipContent>
              </Tooltip>
            </TooltipProvider>
          </div>
        </div>

        {/* Advanced filters panel (hidden by default) */}
        <div id="filters-panel" className="hidden pt-3 mt-3 border-t">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            {/* Custom date range */}
            {timeRange === 'custom' && (
              <div className="col-span-1 md:col-span-3 grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                  <label className="text-sm font-medium mb-1 block">Start Date</label>
                  <input
                    type="date"
                    className="w-full px-3 py-2 rounded-md border bg-background"
                    onChange={(e) => handleCustomDateChange('start', e.target.value)}
                    value={customDateRange.start || ''}
                  />
                </div>
                <div>
                  <label className="text-sm font-medium mb-1 block">End Date</label>
                  <input
                    type="date"
                    className="w-full px-3 py-2 rounded-md border bg-background"
                    onChange={(e) => handleCustomDateChange('end', e.target.value)}
                    value={customDateRange.end || ''}
                  />
                </div>
              </div>
            )}

            {/* Model filter */}
            <div>
              <label className="text-sm font-medium mb-1 block">Models</label>
              <div className="flex flex-wrap gap-1">
                {modelOptions.map(model => (
                  <Badge
                    key={model.id}
                    variant={selectedModels.includes(model.id) ? 'default' : 'outline'}
                    className="cursor-pointer"
                    onClick={() => handleModelChange(model.id)}
                  >
                    {model.name}
                  </Badge>
                ))}
              </div>
            </div>

            {/* Category filter */}
            <div>
              <label className="text-sm font-medium mb-1 block">Categories</label>
              <div className="flex flex-wrap gap-1">
                {availableCategories.map(category => (
                  <Badge
                    key={category}
                    variant={selectedCategories.includes(category) ? 'default' : 'outline'}
                    className="cursor-pointer capitalize"
                    onClick={() => handleCategoryChange(category)}
                  >
                    {category}
                  </Badge>
                ))}
              </div>
            </div>

            {/* Tags filter */}
            <div>
              <label className="text-sm font-medium mb-1 block">Tags</label>
              <div className="flex flex-wrap gap-1">
                {availableTags.map(tag => (
                  <Badge
                    key={tag}
                    variant={tags.includes(tag) ? 'default' : 'outline'}
                    className="cursor-pointer capitalize"
                    onClick={() => handleTagChange(tag)}
                  >
                    {tag}
                  </Badge>
                ))}
              </div>
            </div>
          </div>

          {/* Comparison options (only shown when comparison is enabled) */}
          {comparisonEnabled && (
            <div className="mt-4 pt-3 border-t">
              <label className="text-sm font-medium mb-1 block">Compare With</label>
              <div className="flex gap-2">
                <Button
                  variant={comparisonTimeRange === 'previous' ? 'default' : 'outline'}
                  size="sm"
                  onClick={() => setComparisonTimeRange('previous')}
                >
                  Previous Period
                </Button>
                <Button
                  variant={comparisonTimeRange === 'year' ? 'default' : 'outline'}
                  size="sm"
                  onClick={() => setComparisonTimeRange('year')}
                >
                  Year Ago
                </Button>
              </div>
            </div>
          )}
        </div>
      </div>

      {/* Main content based on current view */}
      <CardContent className="p-6">
        {currentView === 'overview' && (
          <div className="space-y-6">
            {/* Overview Metrics */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div className="bg-background p-4 rounded-lg border">
                <div className="text-sm text-muted-foreground">Total Tokens</div>
                <div className="text-2xl font-bold mt-1">
                  {filteredData ? formatNumber(filteredData.totalTokens) : '0'}
                </div>
                {comparisonEnabled && comparisonData && (
                  <div className={`text-xs mt-1 flex items-center ${comparisonData.percentageChange.totalTokens > 0 ? 'text-emerald-600 dark:text-emerald-400' : 'text-red-600 dark:text-red-400'}`}>
                    {comparisonData.percentageChange.totalTokens > 0 ? (
                      <>
                        <TrendingUp className="h-3 w-3 mr-1" />
                        +{comparisonData.percentageChange.totalTokens.toFixed(1)}%
                      </>
                    ) : (
                      <>
                        <TrendingDown className="h-3 w-3 mr-1" />
                        {comparisonData.percentageChange.totalTokens.toFixed(1)}%
                      </>
                    )}
                    <span className="text-muted-foreground ml-1">vs previous</span>
                  </div>
                )}
              </div>

              <div className="bg-background p-4 rounded-lg border">
                <div className="text-sm text-muted-foreground">Average Daily Usage</div>
                <div className="text-2xl font-bold mt-1">
                  {filteredData ? formatNumber(filteredData.averageDailyUsage) : '0'}
                </div>
                {comparisonEnabled && comparisonData && (
                  <div className={`text-xs mt-1 flex items-center ${comparisonData.percentageChange.averageDailyUsage > 0 ? 'text-emerald-600 dark:text-emerald-400' : 'text-red-600 dark:text-red-400'}`}>
                    {comparisonData.percentageChange.averageDailyUsage > 0 ? (
                      <>
                        <TrendingUp className="h-3 w-3 mr-1" />
                        +{comparisonData.percentageChange.averageDailyUsage.toFixed(1)}%
                      </>
                    ) : (
                      <>
                        <TrendingDown className="h-3 w-3 mr-1" />
                        {comparisonData.percentageChange.averageDailyUsage.toFixed(1)}%
                      </>
                    )}
                    <span className="text-muted-foreground ml-1">vs previous</span>
                  </div>
                )}
              </div>

              <div className="bg-background p-4 rounded-lg border">
                <div className="text-sm text-muted-foreground">Peak Usage</div>
                <div className="text-2xl font-bold mt-1">
                  {filteredData ? formatNumber(filteredData.peakUsage) : '0'}
                </div>
                {comparisonEnabled && comparisonData && (
                  <div className={`text-xs mt-1 flex items-center ${comparisonData.percentageChange.peakUsage > 0 ? 'text-emerald-600 dark:text-emerald-400' : 'text-red-600 dark:text-red-400'}`}>
                    {comparisonData.percentageChange.peakUsage > 0 ? (
                      <>
                        <TrendingUp className="h-3 w-3 mr-1" />
                        +{comparisonData.percentageChange.peakUsage.toFixed(1)}%
                      </>
                    ) : (
                      <>
                        <TrendingDown className="h-3 w-3 mr-1" />
                        {comparisonData.percentageChange.peakUsage.toFixed(1)}%
                      </>
                    )}
                    <span className="text-muted-foreground ml-1">vs previous</span>
                  </div>
                )}
              </div>
            </div>

            {/* Usage Chart - simulated placeholder */}
            <div className="bg-background p-4 rounded-lg border h-64 flex items-center justify-center">
              <div className="text-center text-muted-foreground">
                <BarChart3 className="h-10 w-10 mx-auto mb-3 opacity-50" />
                <p>Time Series Chart would be rendered here</p>
              </div>
            </div>

            {/* Category Distribution */}
            <div className="bg-background p-4 rounded-lg border">
              <h3 className="font-medium mb-4">Category Distribution</h3>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div className="bg-muted/30 rounded-lg p-4 flex items-center justify-center h-48">
                  <div className="text-center text-muted-foreground">
                    <PieChart className="h-10 w-10 mx-auto mb-3 opacity-50" />
                    <p>Category Distribution Chart</p>
                  </div>
                </div>
                <div className="space-y-2">
                  {filteredData && filteredData.categories && Object.entries(filteredData.categories).map(([category, value]) => (
                    <div key={category} className="flex justify-between items-center py-1 border-b last:border-0">
                      <span className="capitalize">{category}</span>
                      <div className="flex items-center">
                        <span className="font-medium">{formatNumber(value)}</span>
                        <Badge className="ml-2" variant="outline">
                          {Math.round((value / filteredData.totalTokens) * 100)}%
                        </Badge>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </div>
        )}

        {currentView === 'detailed' && (
          <div className="space-y-6">
            <div className="bg-background p-4 rounded-lg border">
              <h3 className="font-medium mb-4">Detailed Usage Analysis</h3>
              <div className="grid grid-cols-1 gap-4">
                <div className="bg-muted/30 rounded-lg p-4 flex items-center justify-center h-64">
                  <div className="text-center text-muted-foreground">
                    <BarChart2 className="h-10 w-10 mx-auto mb-3 opacity-50" />
                    <p>Detailed Usage Timeline</p>
                  </div>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mt-4">
                  <div className="bg-background rounded-lg border p-4">
                    <h4 className="text-sm font-medium mb-3">Model Distribution</h4>
                    {filteredData && filteredData.models && Object.entries(filteredData.models).map(([model, value]) => (
                      <div key={model} className="flex justify-between items-center py-1 border-b last:border-0">
                        <span>{model}</span>
                        <div className="flex items-center">
                          <span className="font-medium">{formatNumber(value)}</span>
                          <Badge className="ml-2" variant="outline">
                            {Math.round((value / filteredData.totalTokens) * 100)}%
                          </Badge>
                        </div>
                      </div>
                    ))}
                  </div>

                  <div className="bg-background rounded-lg border p-4">
                    <h4 className="text-sm font-medium mb-3">Usage Patterns</h4>
                    <div className="space-y-4">
                      <div className="bg-muted/30 rounded-lg p-3 text-center text-muted-foreground">
                        <Clock className="h-6 w-6 mx-auto mb-2 opacity-50" />
                        <p className="text-sm">Time of Day Usage Patterns</p>
                      </div>
                      <div className="bg-muted/30 rounded-lg p-3 text-center text-muted-foreground">
                        <Tag className="h-6 w-6 mx-auto mb-2 opacity-50" />
                        <p className="text-sm">Tag Distribution</p>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        )}

        {currentView === 'reports' && (
          <div className="space-y-6">
            <div className="bg-background p-4 rounded-lg border">
              <h3 className="font-medium mb-4">Report Generation</h3>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
                <div className="bg-muted/10 rounded-lg border p-4">
                  <h4 className="text-sm font-medium mb-3">Export Options</h4>
                  <div className="space-y-2">
                    <div className="flex items-center gap-3">
                      <Button variant="outline" size="sm" onClick={() => handleExportData('pdf')} disabled={exportInProgress}>
                        <FileText className="h-4 w-4 mr-2" />
                        PDF Report
                      </Button>
                      <Button variant="outline" size="sm" onClick={() => handleExportData('csv')} disabled={exportInProgress}>
                        <FileDown className="h-4 w-4 mr-2" />
                        CSV Export
                      </Button>
                    </div>
                    <p className="text-xs text-muted-foreground mt-2">
                      Exports include all currently selected filters and time range
                    </p>
                  </div>
                </div>

                <div className="bg-muted/10 rounded-lg border p-4">
                  <h4 className="text-sm font-medium mb-3">Schedule Reports</h4>
                  <div className="space-y-2">
                    <div className="flex items-center gap-3">
                      <Button variant="outline" size="sm" onClick={() => handleScheduleExport('daily')}>
                        <Clock className="h-4 w-4 mr-2" />
                        Daily
                      </Button>
                      <Button variant="outline" size="sm" onClick={() => handleScheduleExport('weekly')}>
                        <Calendar className="h-4 w-4 mr-2" />
                        Weekly
                      </Button>
                      <Button variant="outline" size="sm" onClick={() => handleScheduleExport('monthly')}>
                        <Calendar className="h-4 w-4 mr-2" />
                        Monthly
                      </Button>
                    </div>
                    <p className="text-xs text-muted-foreground mt-2">
                      Scheduled reports will be delivered as {exportFormat.toUpperCase()} files
                    </p>
                  </div>
                </div>
              </div>

              <div className="mt-6">
                <h4 className="text-sm font-medium mb-3">Scheduled Reports</h4>
                {scheduledExports.length > 0 ? (
                  <div className="space-y-2">
                    {scheduledExports.map(schedule => (
                      <div key={schedule.id} className="flex justify-between items-center p-3 bg-muted/20 rounded-lg">
                        <div>
                          <div className="font-medium">{schedule.frequency.charAt(0).toUpperCase() + schedule.frequency.slice(1)} {schedule.format.toUpperCase()} Report</div>
                          <div className="text-xs text-muted-foreground">Next run: {new Date(schedule.nextRun).toLocaleDateString()}</div>
                        </div>
                        <div className="flex gap-2">
                          <Button variant="outline" size="sm">
                            <Share2 className="h-4 w-4 mr-1" />
                            Share
                          </Button>
                          <Button variant="outline" size="sm">
                            <MailIcon className="h-4 w-4 mr-1" />
                            Email
                          </Button>
                        </div>
                      </div>
                    ))}
                  </div>
                ) : (
                  <div className="text-center text-muted-foreground py-6">
                    <Calendar className="h-10 w-10 mx-auto mb-3 opacity-50" />
                    <p>No scheduled reports yet</p>
                    <p className="text-xs mt-1">Schedule your first report using the options above</p>
                  </div>
                )}
              </div>
            </div>
          </div>
        )}
      </CardContent>

      <CardFooter className="bg-muted/20 py-3 text-xs text-muted-foreground flex justify-between">
        <div>
          Data last updated: {new Date().toLocaleString()}
        </div>
        <div>
          Filters: {selectedModels.length > 0 ? `${selectedModels.length} models, ` : ''}
          {selectedCategories.length > 0 ? `${selectedCategories.length} categories, ` : ''}
          {tags.length > 0 ? `${tags.length} tags, ` : ''}
          {timeRange !== 'week' ? `${timeRange} view` : 'weekly view'}
        </div>
      </CardFooter>
    </Card>
  );
};

export default EnhancedAnalyticsDashboard;
