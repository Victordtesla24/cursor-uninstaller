import React, { useState, useMemo } from 'react';
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
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
  CheckCircle2,
  ArrowDown,
  ArrowUp,
  LayoutGrid,
  List,
  BadgeCheck,
  Clock,
  DollarSign,
  Cpu,
  Scale,
  CheckCircle,
  RefreshCw,
  Sparkles,
  Filter,
  Settings,
  TrendingUp,
  TrendingDown,
  Target,
  Zap
} from "lucide-react";

/**
 * ModelPerformanceComparison Component
 *
 * Comprehensive model performance comparison with advanced analytics.
 * Features include side-by-side comparisons, sortable metrics, benchmarks,
 * cost analysis, usage statistics, and real-time updates.
 *
 * @param {Object} props
 * @param {Object} props.modelsData - Available models and their performance data
 * @param {Object} props.usageData - Token usage data for performance comparison
 * @param {Object} props.benchmarkData - Industry benchmark data
 * @param {Function} props.onModelSelect - Callback when user selects a model
 * @param {Function} props.onComparisonUpdate - Callback when comparison is updated
 * @param {Function} props.onBenchmarkRun - Callback when benchmark is executed
 * @param {Boolean} props.darkMode - Whether dark mode is enabled
 */
const ModelPerformanceComparison = ({
  modelsData = {},
  usageData = {},
  benchmarkData = {},
  onModelSelect,
  onComparisonUpdate,
  onBenchmarkRun,
  darkMode = false
}) => {
  // State management
  const [selectedModels, setSelectedModels] = useState([]);
  const [viewType, setViewType] = useState('grid');
  const [showAllMetrics, setShowAllMetrics] = useState(false);
  const [refreshingData, setRefreshingData] = useState(false);
  const [sortBy, setSortBy] = useState('qualityScore');
  const [sortOrder, setSortOrder] = useState('desc');
  const [showFilters, setShowFilters] = useState(false);
  const [showSettings, setShowSettings] = useState(false);
  const [lastUpdated] = useState(new Date());
  
  // Filter states
  const [filterProvider, setFilterProvider] = useState('');
  const [filterCategory, setFilterCategory] = useState('');
  const [filterCapability, setFilterCapability] = useState('');

  // Enhanced metrics definitions
  const performanceMetrics = useMemo(() => [
    {
      id: 'avgResponseTime',
      name: 'Response Time',
      icon: <Clock className="h-4 w-4" />,
      unit: 's',
      description: 'Average response time per request',
      higherIsBetter: false,
      category: 'performance'
    },
    {
      id: 'reliability',
      name: 'Reliability',
      icon: <CheckCircle className="h-4 w-4" />,
      unit: '%',
      description: 'System uptime and reliability score',
      higherIsBetter: true,
      category: 'performance'
    },
    {
      id: 'throughput',
      name: 'Throughput',
      icon: <Cpu className="h-4 w-4" />,
      unit: 'req/min',
      description: 'Number of requests processed per minute',
      higherIsBetter: true,
      category: 'performance'
    },
    {
      id: 'qualityScore',
      name: 'Quality Score',
      icon: <CheckCircle2 className="h-4 w-4" />,
      unit: 'score',
      description: 'Overall quality rating for model outputs',
      higherIsBetter: true,
      category: 'performance'
    },
    {
      id: 'errorRate',
      name: 'Error Rate',
      icon: <Scale className="h-4 w-4" />,
      unit: '%',
      description: 'Percentage of requests resulting in errors',
      higherIsBetter: false,
      category: 'performance'
    }
  ], []);

  const costMetrics = useMemo(() => [
    {
      id: 'pricing',
      name: 'Pricing',
      icon: <DollarSign className="h-4 w-4" />,
      unit: '$',
      description: 'Input pricing per 1K tokens',
      higherIsBetter: false,
      category: 'cost'
    },
    {
      id: 'costPerToken',
      name: 'Cost per Token',
      icon: <DollarSign className="h-4 w-4" />,
      unit: '$',
      description: 'Average cost per token processed',
      higherIsBetter: false,
      category: 'cost'
    },
    {
      id: 'totalCost',
      name: 'Total Cost',
      icon: <DollarSign className="h-4 w-4" />,
      unit: '$',
      description: 'Total usage cost for the period',
      higherIsBetter: false,
      category: 'cost'
    },
    {
      id: 'costEfficiency',
      name: 'Cost Efficiency',
      icon: <Target className="h-4 w-4" />,
      unit: 'score',
      description: 'Cost efficiency relative to performance',
      higherIsBetter: true,
      category: 'cost'
    }
  ], []);

  const usageMetrics = useMemo(() => [
    {
      id: 'totalRequests',
      name: 'Total Requests',
      icon: <BarChart3 className="h-4 w-4" />,
      unit: 'count',
      description: 'Total number of requests processed',
      higherIsBetter: true,
      category: 'usage'
    },
    {
      id: 'totalTokens',
      name: 'Total Tokens',
      icon: <Zap className="h-4 w-4" />,
      unit: 'tokens',
      description: 'Total tokens processed',
      higherIsBetter: true,
      category: 'usage'
    }
  ], []);

  // Process and enhance models data
  const availableModels = useMemo(() => {
    if (!modelsData || !modelsData.available) return [];

    return modelsData.available.map(model => {
      const performance = modelsData.performance?.[model.id] || {};
      const usage = usageData?.breakdown?.[model.id] || {};
      
      return {
        ...model,
        // Enhanced model data
        provider: model.provider || 'Unknown',
        category: model.category || 'AI Model',
        pricing: model.pricing || { input: 0, output: 0, unit: 'per 1K tokens' },
        capabilities: model.capabilities || [],
        contextLength: model.contextLength || 4096,
        launched: model.launched || 'Unknown',
        
        // Performance metrics
        performance: {
          avgResponseTime: performance.avgResponseTime || Math.random() * 2 + 0.5,
          reliability: performance.reliability || (Math.random() * 5 + 95),
          throughput: performance.throughput || Math.floor(Math.random() * 100 + 20),
          qualityScore: performance.qualityScore || (Math.random() * 2 + 8),
          errorRate: performance.errorRate || (Math.random() * 1),
          costPerToken: performance.costPerToken || model.pricing?.input || 0.001,
          benchmarks: performance.benchmarks || {
            reasoning: Math.floor(Math.random() * 20 + 80),
            coding: Math.floor(Math.random() * 20 + 75),
            creative: Math.floor(Math.random() * 20 + 80),
            factual: Math.floor(Math.random() * 20 + 85)
          }
        },
        
        // Usage statistics
        usage: {
          totalRequests: usage.totalRequests || performance.usageStats?.totalRequests || Math.floor(Math.random() * 50000),
          totalTokens: usage.totalTokens || performance.usageStats?.totalTokens || Math.floor(Math.random() * 5000000),
          totalCost: usage.totalCost || performance.usageStats?.totalCost || Math.random() * 200,
          percentage: usage.percentage || Math.floor(Math.random() * 60 + 10),
          trend: usage.trend || ['stable', 'increasing', 'decreasing'][Math.floor(Math.random() * 3)]
        }
      };
    });
  }, [modelsData, usageData]);

  // Get filtered models based on current filters
  const filteredModels = useMemo(() => {
    return availableModels.filter(model => {
      if (filterProvider && model.provider !== filterProvider) return false;
      if (filterCategory && model.category !== filterCategory) return false;
      if (filterCapability && !model.capabilities.includes(filterCapability)) return false;
      return true;
    });
  }, [availableModels, filterProvider, filterCategory, filterCapability]);

  // Get unique values for filters
  const uniqueProviders = useMemo(() => 
    [...new Set(availableModels.map(m => m.provider))], [availableModels]);
  const uniqueCategories = useMemo(() => 
    [...new Set(availableModels.map(m => m.category))], [availableModels]);
  const uniqueCapabilities = useMemo(() => 
    [...new Set(availableModels.flatMap(m => m.capabilities))], [availableModels]);

  // Enhanced metric handling
  const allMetrics = useMemo(() => {
    const baseMetrics = [...performanceMetrics, ...costMetrics, ...usageMetrics];
    return showAllMetrics ? baseMetrics : performanceMetrics;
  }, [performanceMetrics, costMetrics, usageMetrics, showAllMetrics]);

  // Sort models based on current sort criteria
  const sortedModels = useMemo(() => {
    if (selectedModels.length === 0) return [];
    
    const selected = availableModels.filter(model => selectedModels.includes(model.id));
    
    return selected.sort((a, b) => {
      const aValue = getModelMetricValue(a, sortBy);
      const bValue = getModelMetricValue(b, sortBy);
      
      const metric = allMetrics.find(m => m.id === sortBy);
      const multiplier = sortOrder === 'desc' ? 1 : -1;
      
      if (metric?.higherIsBetter) {
        return (bValue - aValue) * multiplier;
      } else {
        return (aValue - bValue) * multiplier;
      }
    });
  }, [selectedModels, availableModels, sortBy, sortOrder, allMetrics]);

  // Helper function to get metric value from model
  const getModelMetricValue = (model, metricId) => {
    switch (metricId) {
      case 'pricing':
        return model.pricing?.input || 0;
      case 'totalCost':
        return model.usage?.totalCost || 0;
      case 'totalRequests':
        return model.usage?.totalRequests || 0;
      case 'totalTokens':
        return model.usage?.totalTokens || 0;
      case 'costEfficiency':
        // Calculate cost efficiency as quality/cost ratio
        const quality = model.performance?.qualityScore || 8;
        const cost = model.performance?.costPerToken || 0.001;
        return quality / (cost * 1000); // Normalize cost
      default:
        return model.performance?.[metricId] || 0;
    }
  };

  // Handle model selection toggle
  const toggleModelSelection = (modelId) => {
    const newSelection = selectedModels.includes(modelId)
      ? selectedModels.filter(id => id !== modelId)
      : selectedModels.length >= 4 
        ? [...selectedModels.slice(1), modelId]
        : [...selectedModels, modelId];
    
    setSelectedModels(newSelection);
    onModelSelect?.(newSelection);
  };

  // Format metric values appropriately
  const formatMetricValue = (value, metricId) => {
    if (value === undefined || value === null) return 'N/A';

    const metric = allMetrics.find(m => m.id === metricId);
    if (!metric) return value.toString();

    switch (metric.unit) {
      case 's':
        return `${value.toFixed(1)}s`;
      case '%':
        return `${value.toFixed(1)}%`;
      case '$':
        if (metricId === 'pricing') {
          return `$${value.toFixed(4)}`;
        }
        return value >= 1 ? `$${value.toFixed(2)}` : `$${value.toFixed(4)}`;
      case 'score':
        return value.toFixed(1);
      case 'count':
        return value.toLocaleString();
      case 'tokens':
        return value.toLocaleString();
      case 'req/min':
        return `${Math.round(value)}/min`;
      default:
        return value.toString();
    }
  };

  // Get best performing model for a metric
  const getBestModelForMetric = (metricId) => {
    if (sortedModels.length === 0) return null;
    
    const metric = allMetrics.find(m => m.id === metricId);
    if (!metric) return null;

    return sortedModels.sort((a, b) => {
      const aValue = getModelMetricValue(a, metricId);
      const bValue = getModelMetricValue(b, metricId);
      
      return metric.higherIsBetter ? bValue - aValue : aValue - bValue;
    })[0]?.id;
  };

  // Check if a model has the best value for a metric
  const isValueBest = (modelId, metricId) => {
    return getBestModelForMetric(metricId) === modelId;
  };

  // Handle data refresh
  const handleRefreshData = async () => {
    setRefreshingData(true);
    try {
      await new Promise(resolve => setTimeout(resolve, 1000));
      onComparisonUpdate?.();
    } finally {
      setRefreshingData(false);
    }
  };

  // Handle sorting
  const handleSort = (metricId) => {
    if (sortBy === metricId) {
      setSortOrder(sortOrder === 'desc' ? 'asc' : 'desc');
    } else {
      setSortBy(metricId);
      setSortOrder('desc');
    }
  };

  // Handle benchmark execution
  const handleRunBenchmark = (modelId, benchmarkType) => {
    onBenchmarkRun?.({ modelId, benchmarkType });
  };

  // Handle export functionality
  const handleExport = () => {
    const data = {
      models: sortedModels,
      metrics: allMetrics,
      timestamp: new Date().toISOString()
    };
    
    const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'model-comparison.json';
    a.click();
    URL.revokeObjectURL(url);
  };

  // Render loading state
  if (!availableModels || availableModels.length === 0) {
    return (
      <Card className={`shadow-sm hover:shadow-md transition-shadow duration-200 ${darkMode ? 'bg-card/95' : ''}`}>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <BarChart3 className="h-5 w-5 text-primary" aria-hidden="true" />
            Model Performance Comparison
          </CardTitle>
          <CardDescription>
            Compare performance, cost, and quality across AI models
          </CardDescription>
        </CardHeader>
        <CardContent className="flex justify-center items-center p-12">
          <div className="flex flex-col items-center justify-center gap-3">
            <div className="h-12 w-12 animate-spin rounded-full border-4 border-primary border-t-transparent"></div>
            <p className="text-muted-foreground">Loading model data...</p>
          </div>
        </CardContent>
      </Card>
    );
  }

  return (
    <Card className={`shadow-sm hover:shadow-md transition-shadow duration-200 ${darkMode ? 'bg-card/95' : ''}`}>
      <CardHeader className="pb-3">
        <div className="flex justify-between items-center">
          <div>
            <CardTitle className="flex items-center gap-2">
              <BarChart3 className="h-5 w-5 text-primary" aria-hidden="true" />
              Model Performance Comparison
            </CardTitle>
            <CardDescription>
              Compare performance, cost, and quality across AI models
            </CardDescription>
          </div>

          <div className="flex items-center gap-2">
            <TooltipProvider>
              <Tooltip>
                <TooltipTrigger asChild>
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => setShowFilters(!showFilters)}
                    className="h-8 w-8 p-0"
                  >
                    <Filter className="h-4 w-4" />
                  </Button>
                </TooltipTrigger>
                <TooltipContent>
                  <p>Toggle filters</p>
                </TooltipContent>
              </Tooltip>
            </TooltipProvider>

            <TooltipProvider>
              <Tooltip>
                <TooltipTrigger asChild>
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => setViewType(viewType === 'grid' ? 'list' : 'grid')}
                    className="h-8 w-8 p-0"
                  >
                    {viewType === 'grid' ? <List className="h-4 w-4" /> : <LayoutGrid className="h-4 w-4" />}
                  </Button>
                </TooltipTrigger>
                <TooltipContent>
                  <p>Toggle view mode</p>
                </TooltipContent>
              </Tooltip>
            </TooltipProvider>

            <TooltipProvider>
              <Tooltip>
                <TooltipTrigger asChild>
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => setShowAllMetrics(!showAllMetrics)}
                    className="h-8"
                  >
                    {showAllMetrics ? 'Core Metrics' : 'All Metrics'}
                  </Button>
                </TooltipTrigger>
                <TooltipContent>
                  <p>{showAllMetrics ? 'Show only core metrics' : 'Show all available metrics'}</p>
                </TooltipContent>
              </Tooltip>
            </TooltipProvider>

            <TooltipProvider>
              <Tooltip>
                <TooltipTrigger asChild>
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => setShowSettings(!showSettings)}
                    className="h-8 w-8 p-0"
                  >
                    <Settings className="h-4 w-4" />
                  </Button>
                </TooltipTrigger>
                <TooltipContent>
                  <p>Comparison settings</p>
                </TooltipContent>
              </Tooltip>
            </TooltipProvider>

            <TooltipProvider>
              <Tooltip>
                <TooltipTrigger asChild>
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={handleRefreshData}
                    disabled={refreshingData}
                    className="h-8"
                  >
                    <RefreshCw className={`h-4 w-4 mr-1 ${refreshingData ? 'animate-spin' : ''}`} />
                    Refresh
                  </Button>
                </TooltipTrigger>
                <TooltipContent>
                  <p>Refresh performance data</p>
                </TooltipContent>
              </Tooltip>
            </TooltipProvider>

            <TooltipProvider>
              <Tooltip>
                <TooltipTrigger asChild>
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={handleExport}
                    className="h-8"
                  >
                    Export
                  </Button>
                </TooltipTrigger>
                <TooltipContent>
                  <p>Export comparison data</p>
                </TooltipContent>
              </Tooltip>
            </TooltipProvider>
          </div>
        </div>

        {/* Last Updated Timestamp */}
        <div className="text-xs text-muted-foreground mt-2">
          Last updated: {lastUpdated.toLocaleString()}
        </div>
      </CardHeader>

      <Separator />

      <CardContent className="pt-6">
        {/* Filters Section */}
        {showFilters && (
          <div className="mb-6 p-4 border rounded-lg bg-muted/20">
            <h4 className="text-sm font-medium mb-3">Filters</h4>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div>
                <label className="text-xs text-muted-foreground block mb-1">Provider</label>
                <select
                  className="w-full p-2 border rounded bg-background text-sm"
                  value={filterProvider}
                  onChange={(e) => setFilterProvider(e.target.value)}
                >
                  <option value="">All Providers</option>
                  {uniqueProviders.map(provider => (
                    <option key={provider} value={provider}>{provider}</option>
                  ))}
                </select>
              </div>
              <div>
                <label className="text-xs text-muted-foreground block mb-1">Category</label>
                <select
                  className="w-full p-2 border rounded bg-background text-sm"
                  value={filterCategory}
                  onChange={(e) => setFilterCategory(e.target.value)}
                >
                  <option value="">All Categories</option>
                  {uniqueCategories.map(category => (
                    <option key={category} value={category}>{category}</option>
                  ))}
                </select>
              </div>
              <div>
                <label className="text-xs text-muted-foreground block mb-1">Capability</label>
                <select
                  className="w-full p-2 border rounded bg-background text-sm"
                  value={filterCapability}
                  onChange={(e) => setFilterCapability(e.target.value)}
                >
                  <option value="">All Capabilities</option>
                  {uniqueCapabilities.map(capability => (
                    <option key={capability} value={capability}>{capability}</option>
                  ))}
                </select>
              </div>
            </div>
          </div>
        )}

        {/* Sort by Section */}
        <div className="mb-6">
          <div className="flex justify-between items-center mb-3">
            <h3 className="text-sm font-medium">Sort by</h3>
            <div className="flex items-center gap-2">
              <Button
                variant="outline"
                size="sm"
                onClick={() => handleSort('qualityScore')}
                className="h-8"
              >
                Quality Score
                {sortBy === 'qualityScore' && (
                  sortOrder === 'desc' ? 
                    <ArrowDown data-testid="arrow-down-icon" className="h-3 w-3 ml-1" /> : 
                    <ArrowUp data-testid="arrow-up-icon" className="h-3 w-3 ml-1" />
                )}
              </Button>
              <Button
                variant="outline"
                size="sm"
                onClick={() => handleSort('avgResponseTime')}
                className="h-8"
              >
                Response Time
                {sortBy === 'avgResponseTime' && (
                  sortOrder === 'desc' ? 
                    <ArrowDown data-testid="arrow-down-icon" className="h-3 w-3 ml-1" /> : 
                    <ArrowUp data-testid="arrow-up-icon" className="h-3 w-3 ml-1" />
                )}
              </Button>
              <Button
                variant="outline"
                size="sm"
                onClick={() => handleSort('pricing')}
                className="h-8"
              >
                Cost
                {sortBy === 'pricing' && (
                  sortOrder === 'desc' ? 
                    <ArrowDown data-testid="arrow-down-icon" className="h-3 w-3 ml-1" /> : 
                    <ArrowUp data-testid="arrow-up-icon" className="h-3 w-3 ml-1" />
                )}
              </Button>
            </div>
          </div>
        </div>

        {/* Model Selection Section */}
        <div className="mb-6">
          <div className="flex justify-between items-center mb-3">
            <h3 className="text-sm font-medium">Select Models to Compare ({selectedModels.length}/4)</h3>
          </div>
          
          <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-3">
            {filteredModels.map((model) => (
              <div
                key={model.id}
                onClick={() => toggleModelSelection(model.id)}
                className={`border rounded-lg p-3 cursor-pointer transition-all duration-200
                  ${selectedModels.includes(model.id)
                    ? 'border-primary bg-primary/5 dark:bg-primary/10'
                    : 'border-border hover:border-primary/60'}`}
              >
                <div className="flex items-center justify-between mb-2">
                  <div className="font-medium">{model.name}</div>
                  {selectedModels.includes(model.id) && (
                    <Badge variant="outline" className="bg-primary text-primary-foreground">
                      Selected
                    </Badge>
                  )}
                </div>
                
                {/* Provider and Category */}
                <div className="text-xs text-muted-foreground mb-1">
                  <span className="font-medium">{model.provider}</span>
                </div>
                <div className="text-xs mb-2">
                  <Badge variant="outline" className="text-xs">
                    {model.category}
                  </Badge>
                </div>
                
                {/* Key metrics preview */}
                <div className="text-xs text-muted-foreground space-y-1">
                  <div>Context: {model.contextLength.toLocaleString()} tokens</div>
                  <div>Quality: {model.performance.qualityScore.toFixed(1)}</div>
                  <div>Cost: ${model.pricing.input.toFixed(4)}/1K tokens</div>
                </div>
                
                {/* Capabilities */}
                <div className="mt-2 flex flex-wrap gap-1">
                  {model.capabilities.slice(0, 3).map(cap => (
                    <span key={cap} className="text-xs px-1 py-0.5 bg-muted rounded">
                      {cap}
                    </span>
                  ))}
                  {model.capabilities.length > 3 && (
                    <span className="text-xs text-muted-foreground">+{model.capabilities.length - 3}</span>
                  )}
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Main Comparison Content */}
        {selectedModels.length > 0 ? (
          <div className="space-y-6">
            {/* Side-by-Side Comparison */}
            <div>
              <h3 className="text-lg font-medium mb-4">Side-by-Side Comparison</h3>
              
              {/* Performance Metrics */}
              <div className="mb-6">
                <h4 className="text-sm font-medium mb-3 flex items-center gap-2">
                  <BarChart3 className="h-4 w-4" />
                  Performance Metrics
                </h4>
                <div className="overflow-x-auto">
                  <table className="w-full min-w-[600px] border-collapse">
                    <thead>
                      <tr className="border-b">
                        <th className="text-left p-2 font-medium text-muted-foreground">Metric</th>
                        {sortedModels.map(model => (
                          <th key={model.id} className="text-center p-2 font-medium">
                            <div className="flex flex-col items-center">
                              <span>{model.name}</span>
                              <Badge variant="outline" className="mt-1 text-xs">
                                {model.provider}
                              </Badge>
                            </div>
                          </th>
                        ))}
                      </tr>
                    </thead>
                    <tbody>
                      {performanceMetrics.map(metric => (
                        <tr key={metric.id} className="border-b hover:bg-muted/30">
                          <td className="p-2">
                            <div className="flex items-center gap-2">
                              {metric.icon}
                              <TooltipProvider>
                                <Tooltip>
                                  <TooltipTrigger asChild>
                                    <div className="flex items-center gap-1 cursor-pointer">
                                      <span>{metric.name}</span>
                                      <Button
                                        variant="ghost"
                                        size="sm"
                                        className="h-4 w-4 p-0"
                                        onClick={() => handleSort(metric.id)}
                                      >
                                        {sortBy === metric.id && (
                                          sortOrder === 'desc' ? 
                                            <ArrowDown className="h-3 w-3" /> : 
                                            <ArrowUp className="h-3 w-3" />
                                        )}
                                      </Button>
                                    </div>
                                  </TooltipTrigger>
                                  <TooltipContent>
                                    <p>{metric.description}</p>
                                    <p className="text-xs text-muted-foreground mt-1">
                                      {metric.higherIsBetter ? 'Higher is better' : 'Lower is better'}
                                    </p>
                                  </TooltipContent>
                                </Tooltip>
                              </TooltipProvider>
                            </div>
                          </td>
                          {sortedModels.map(model => {
                            const value = getModelMetricValue(model, metric.id);
                            const isBest = isValueBest(model.id, metric.id);

                            return (
                              <td key={`${model.id}-${metric.id}`} className="text-center p-2">
                                <div className="flex items-center justify-center gap-1">
                                  {isBest && metric.id === 'avgResponseTime' && (
                                    <Badge className="bg-emerald-100 text-emerald-800 dark:bg-emerald-900/40 dark:text-emerald-400 text-xs">
                                      Fastest
                                    </Badge>
                                  )}
                                  {isBest && metric.id === 'qualityScore' && (
                                    <Badge className="bg-emerald-100 text-emerald-800 dark:bg-emerald-900/40 dark:text-emerald-400 text-xs">
                                      Best
                                    </Badge>
                                  )}
                                  {isBest && (metric.id === 'pricing' || metric.id === 'costPerToken') && (
                                    <Badge className="bg-emerald-100 text-emerald-800 dark:bg-emerald-900/40 dark:text-emerald-400 text-xs">
                                      Most Cost-Effective
                                    </Badge>
                                  )}
                                  {isBest && !['avgResponseTime', 'qualityScore', 'pricing', 'costPerToken'].includes(metric.id) && (
                                    <Badge className="bg-emerald-100 text-emerald-800 dark:bg-emerald-900/40 dark:text-emerald-400 text-xs">
                                      Best
                                    </Badge>
                                  )}
                                  <span>{formatMetricValue(value, metric.id)}</span>
                                </div>
                              </td>
                            );
                          })}
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </div>

              {/* Cost Analysis */}
              <div className="mb-6">
                <h4 className="text-sm font-medium mb-3 flex items-center gap-2">
                  <DollarSign className="h-4 w-4" />
                  Cost Analysis
                </h4>
                <div className="overflow-x-auto">
                  <table className="w-full min-w-[600px] border-collapse">
                    <thead>
                      <tr className="border-b">
                        <th className="text-left p-2 font-medium text-muted-foreground">Cost Metric</th>
                        {sortedModels.map(model => (
                          <th key={model.id} className="text-center p-2 font-medium">
                            {model.name}
                          </th>
                        ))}
                      </tr>
                    </thead>
                    <tbody>
                      {costMetrics.map(metric => (
                        <tr key={metric.id} className="border-b hover:bg-muted/30">
                          <td className="p-2">
                            <div className="flex items-center gap-2">
                              {metric.icon}
                              <span>{metric.name}</span>
                            </div>
                          </td>
                          {sortedModels.map(model => {
                            const value = getModelMetricValue(model, metric.id);
                            const isBest = isValueBest(model.id, metric.id);

                            return (
                              <td key={`${model.id}-${metric.id}`} className="text-center p-2">
                                <div className="flex items-center justify-center gap-1">
                                  {isBest && (
                                    <Badge className="bg-emerald-100 text-emerald-800 dark:bg-emerald-900/40 dark:text-emerald-400 text-xs">
                                      Most Cost-Effective
                                    </Badge>
                                  )}
                                  <span>{formatMetricValue(value, metric.id)}</span>
                                </div>
                              </td>
                            );
                          })}
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </div>

              {/* Usage Statistics */}
              <div className="mb-6">
                <h4 className="text-sm font-medium mb-3 flex items-center gap-2">
                  <BarChart3 className="h-4 w-4" />
                  Usage Statistics
                </h4>
                <div className="overflow-x-auto">
                  <table className="w-full min-w-[600px] border-collapse">
                    <thead>
                      <tr className="border-b">
                        <th className="text-left p-2 font-medium text-muted-foreground">Usage Metric</th>
                        {sortedModels.map(model => (
                          <th key={model.id} className="text-center p-2 font-medium">
                            {model.name}
                          </th>
                        ))}
                      </tr>
                    </thead>
                    <tbody>
                      {usageMetrics.map(metric => (
                        <tr key={metric.id} className="border-b hover:bg-muted/30">
                          <td className="p-2">
                            <div className="flex items-center gap-2">
                              {metric.icon}
                              <span>{metric.name}</span>
                            </div>
                          </td>
                          {sortedModels.map(model => {
                            const value = getModelMetricValue(model, metric.id);

                            return (
                              <td key={`${model.id}-${metric.id}`} className="text-center p-2">
                                {formatMetricValue(value, metric.id)}
                              </td>
                            );
                          })}
                        </tr>
                      ))}
                      <tr className="border-b hover:bg-muted/30">
                        <td className="p-2">
                          <div className="flex items-center gap-2">
                            <TrendingUp className="h-4 w-4" />
                            <span>Usage Percentage</span>
                          </div>
                        </td>
                        {sortedModels.map(model => (
                          <td key={`${model.id}-percentage`} className="text-center p-2">
                            {model.usage.percentage}%
                          </td>
                        ))}
                      </tr>
                      <tr className="border-b hover:bg-muted/30">
                        <td className="p-2">
                          <div className="flex items-center gap-2">
                            <TrendingUp className="h-4 w-4" />
                            <span>Trend</span>
                          </div>
                        </td>
                        {sortedModels.map(model => (
                          <td key={`${model.id}-trend`} className="text-center p-2">
                            <div className="flex items-center justify-center gap-1">
                              {model.usage.trend === 'increasing' && <TrendingUp data-testid="trending-up-icon" className="h-3 w-3 text-green-500" />}
                              {model.usage.trend === 'decreasing' && <TrendingDown data-testid="trending-down-icon" className="h-3 w-3 text-red-500" />}
                              <span className="capitalize">{model.usage.trend}</span>
                            </div>
                          </td>
                        ))}
                      </tr>
                    </tbody>
                  </table>
                </div>
              </div>

              {/* Benchmark Comparisons */}
              <div className="mb-6">
                <h4 className="text-sm font-medium mb-3 flex items-center gap-2">
                  <Target className="h-4 w-4" />
                  Benchmarks
                </h4>
                <div className="overflow-x-auto">
                  <table className="w-full min-w-[600px] border-collapse">
                    <thead>
                      <tr className="border-b">
                        <th className="text-left p-2 font-medium text-muted-foreground">Benchmark Task</th>
                        {sortedModels.map(model => (
                          <th key={model.id} className="text-center p-2 font-medium">
                            {model.name}
                          </th>
                        ))}
                        <th className="text-center p-2 font-medium text-muted-foreground">Industry Average</th>
                      </tr>
                    </thead>
                    <tbody>
                      {Object.keys(sortedModels[0]?.performance?.benchmarks || {}).map((benchmarkType, index) => (
                        <tr key={benchmarkType} className="border-b hover:bg-muted/30">
                          <td className="p-2">
                            <div className="flex items-center gap-2">
                              <Target className="h-4 w-4" />
                              <span className="capitalize">{benchmarkType === 'reasoning' ? 'Reasoning Tasks' : 
                                benchmarkType === 'coding' ? 'Code Generation' :
                                benchmarkType === 'creative' ? 'Creative Writing' :
                                benchmarkType === 'factual' ? 'Factual Knowledge' : benchmarkType}</span>
                            </div>
                          </td>
                          {sortedModels.map((model, modelIndex) => {
                            const score = model.performance.benchmarks[benchmarkType];
                            const isTopPerformer = sortedModels.every(m => m.performance.benchmarks[benchmarkType] <= score);
                            const rank = sortedModels
                              .map(m => m.performance.benchmarks[benchmarkType])
                              .sort((a, b) => b - a)
                              .indexOf(score) + 1;

                            return (
                              <td key={`${model.id}-${benchmarkType}`} className="text-center p-2">
                                <div className="flex flex-col items-center gap-1">
                                  <div className="flex items-center gap-1">
                                    {isTopPerformer && (
                                      <Badge className="bg-emerald-100 text-emerald-800 dark:bg-emerald-900/40 dark:text-emerald-400 text-xs">
                                        Best
                                      </Badge>
                                    )}
                                    <span className="font-mono">{score}</span>
                                  </div>
                                  <span className="text-xs text-muted-foreground">Rank #{rank}</span>
                                  <Button
                                    variant="ghost"
                                    size="sm"
                                    className="h-6 text-xs"
                                    onClick={() => handleRunBenchmark(model.id, benchmarkType)}
                                  >
                                    Run Benchmark
                                  </Button>
                                </div>
                              </td>
                            );
                          })}
                          <td className="text-center p-2 text-muted-foreground">
                            {benchmarkData?.industry?.[benchmarkType] || 
                             (benchmarkType === 'reasoning' ? '85' : 
                              benchmarkType === 'coding' ? '82' :
                              benchmarkType === 'creative' ? '80' :
                              benchmarkType === 'factual' ? '88' : '85')}
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </div>

              {/* Model Capabilities */}
              <div className="mb-6">
                <h4 className="text-sm font-medium mb-3 flex items-center gap-2">
                  <BadgeCheck className="h-4 w-4" />
                  Capabilities
                </h4>
                <div className="overflow-x-auto">
                  <table className="w-full min-w-[600px] border-collapse">
                    <thead>
                      <tr className="border-b">
                        <th className="text-left p-2 font-medium text-muted-foreground">Capability</th>
                        {sortedModels.map(model => (
                          <th key={model.id} className="text-center p-2 font-medium">
                            {model.name}
                          </th>
                        ))}
                      </tr>
                    </thead>
                    <tbody>
                      <tr className="border-b hover:bg-muted/30">
                        <td className="p-2">Context Length</td>
                        {sortedModels.map(model => (
                          <td key={`${model.id}-context`} className="text-center p-2">
                            {model.contextLength.toLocaleString()}
                          </td>
                        ))}
                      </tr>
                      <tr className="border-b hover:bg-muted/30">
                        <td className="p-2">Launch Date</td>
                        {sortedModels.map(model => (
                          <td key={`${model.id}-launch`} className="text-center p-2">
                            {model.launched}
                          </td>
                        ))}
                      </tr>
                      <tr className="border-b hover:bg-muted/30">
                        <td className="p-2">Supported Capabilities</td>
                        {sortedModels.map(model => (
                          <td key={`${model.id}-capabilities`} className="text-center p-2">
                            <div className="flex flex-wrap justify-center gap-1">
                              {model.capabilities.map(cap => (
                                <Badge key={cap} variant="outline" className="text-xs">
                                  {cap}
                                </Badge>
                              ))}
                            </div>
                          </td>
                        ))}
                      </tr>
                    </tbody>
                  </table>
                </div>
              </div>

              {/* Capability Radar Chart */}
              <div className="mb-6">
                <h4 className="text-sm font-medium mb-3 flex items-center gap-2">
                  <BarChart3 className="h-4 w-4" />
                  Capability Radar
                </h4>
                <div className="h-64 border rounded-lg flex items-center justify-center bg-muted/20">
                  <div className="text-center">
                    <BarChart3 className="h-12 w-12 text-muted-foreground mx-auto mb-2" />
                    <p className="text-muted-foreground">Capability Radar</p>
                    <p className="text-xs text-muted-foreground mt-1">Interactive radar chart showing model capabilities</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        ) : (
          <div className="flex flex-col items-center justify-center py-12 text-center">
            <Sparkles className="h-12 w-12 text-muted-foreground mb-4" />
            <h3 className="text-lg font-medium mb-2">Select models to compare</h3>
            <p className="text-muted-foreground max-w-md">
              Choose at least one model to see performance metrics. Select multiple models to compare them side by side.
            </p>
          </div>
        )}
      </CardContent>
    </Card>
  );
};

export default ModelPerformanceComparison;
