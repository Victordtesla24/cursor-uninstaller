import React, { useState, useEffect, useMemo } from 'react';
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
  Plus,
  ZoomIn,
  Copy,
  BadgeCheck,
  BarChart,
  BarChart2,
  Clock,
  DollarSign,
  Cpu,
  Scale,
  Sparkles,
  CheckCircle,
  SlidersHorizontal,
  ExternalLink,
  RefreshCw
} from "lucide-react";

/**
 * ModelPerformanceComparison Component
 *
 * Allows users to compare the performance and cost-efficiency of different language models.
 * Features include side-by-side comparisons, sortable metrics, and visualization tools.
 *
 * @param {Object} props
 * @param {Object} props.modelsData - Available models and their performance data
 * @param {Object} props.usageData - Token usage data for performance comparison
 * @param {Function} props.onModelSelect - Callback when user selects a model
 * @param {Boolean} props.darkMode - Whether dark mode is enabled
 */
const ModelPerformanceComparison = ({
  modelsData = {},
  usageData = {},
  onModelSelect,
  darkMode = false
}) => {
  // State for selected models to compare
  const [selectedModels, setSelectedModels] = useState([]);
  const [comparisonMetric, setComparisonMetric] = useState('latency');
  const [viewType, setViewType] = useState('grid');
  const [showAllMetrics, setShowAllMetrics] = useState(false);
  const [refreshingData, setRefreshingData] = useState(false);
  const [abTestActive, setAbTestActive] = useState(false);
  const [abTestConfig, setAbTestConfig] = useState({
    modelA: '',
    modelB: '',
    trafficAllocation: 50,
    metricsToTrack: ['latency', 'costEfficiency']
  });

  // Core comparison metrics to always show
  const coreMetrics = useMemo(() => [
    {
      id: 'latency',
      name: 'Response Time',
      icon: <Clock className="h-4 w-4" />,
      unit: 'ms',
      description: 'Average response time per request',
      higherIsBetter: false
    },
    {
      id: 'costEfficiency',
      name: 'Cost Efficiency',
      icon: <DollarSign className="h-4 w-4" />,
      unit: '$/1K tokens',
      description: 'Average cost per 1,000 tokens',
      higherIsBetter: false
    },
    {
      id: 'tokenEfficiency',
      name: 'Token Efficiency',
      icon: <Scale className="h-4 w-4" />,
      unit: 'score',
      description: 'Efficiency score based on tokens used per task',
      higherIsBetter: true
    },
    {
      id: 'qualityScore',
      name: 'Quality Score',
      icon: <CheckCircle className="h-4 w-4" />,
      unit: 'score',
      description: 'Overall quality rating for model outputs',
      higherIsBetter: true
    }
  ], []);

  // Extended metrics only shown when "Show All Metrics" is enabled
  const extendedMetrics = useMemo(() => [
    {
      id: 'throughput',
      name: 'Throughput',
      icon: <Cpu className="h-4 w-4" />,
      unit: 'req/min',
      description: 'Number of requests processed per minute',
      higherIsBetter: true
    },
    {
      id: 'contextWindow',
      name: 'Context Window',
      icon: <LayoutGrid className="h-4 w-4" />,
      unit: 'tokens',
      description: 'Maximum context window size',
      higherIsBetter: true
    },
    {
      id: 'promptAccuracy',
      name: 'Prompt Accuracy',
      icon: <BadgeCheck className="h-4 w-4" />,
      unit: '%',
      description: 'Percentage of prompts handled accurately',
      higherIsBetter: true
    },
    {
      id: 'completionRate',
      name: 'Completion Rate',
      icon: <CheckCircle2 className="h-4 w-4" />,
      unit: '%',
      description: 'Percentage of successful completions',
      higherIsBetter: true
    },
    {
      id: 'errorRate',
      name: 'Error Rate',
      icon: <Scale className="h-4 w-4" />,
      unit: '%',
      description: 'Percentage of requests resulting in errors',
      higherIsBetter: false
    }
  ], []);

  // Combine core and extended metrics based on showAllMetrics flag
  const displayMetrics = useMemo(() => {
    return showAllMetrics ? [...coreMetrics, ...extendedMetrics] : coreMetrics;
  }, [coreMetrics, extendedMetrics, showAllMetrics]);

  // Process models data for the comparison
  const availableModels = useMemo(() => {
    if (!modelsData || !modelsData.available) return [];

    return modelsData.available.map(model => ({
      id: model.id,
      name: model.name || model.id,
      description: model.description || '',
      contextWindow: model.contextWindow || 4096,
      capabilities: model.capabilities || [],
      costPerToken: model.costPerToken || 0.0001,
      // Generate sample performance metrics if not provided
      performance: model.performance || {
        latency: Math.random() * 200 + 50, // 50-250ms
        costEfficiency: (Math.random() * 0.01 + 0.001).toFixed(5), // $0.001-$0.011 per 1K tokens
        tokenEfficiency: Math.random() * 5 + 5, // 5-10 score
        qualityScore: Math.random() * 2 + 8, // 8-10 score
        throughput: Math.floor(Math.random() * 100 + 20), // 20-120 req/min
        promptAccuracy: Math.random() * 10 + 90, // 90-100%
        completionRate: Math.random() * 5 + 95, // 95-100%
        errorRate: Math.random() * 2 // 0-2%
      }
    }));
  }, [modelsData]);

  // Handle toggling a model in the comparison
  const toggleModelSelection = (modelId) => {
    setSelectedModels(prev => {
      if (prev.includes(modelId)) {
        return prev.filter(id => id !== modelId);
      } else {
        // Limit to maximum 4 models for reasonable comparison
        if (prev.length >= 4) {
          return [...prev.slice(1), modelId]; // Remove oldest, add new
        }
        return [...prev, modelId];
      }
    });
  };

  // Get the best model for a specific metric
  const getBestModelForMetric = (metric) => {
    if (!selectedModels.length) return null;

    const metricDef = [...coreMetrics, ...extendedMetrics].find(m => m.id === metric);
    if (!metricDef) return null;

    const selectedModelObjects = availableModels.filter(model =>
      selectedModels.includes(model.id)
    );

    // Sort based on whether higher or lower is better
    return selectedModelObjects.sort((a, b) => {
      const aValue = a.performance[metric] || 0;
      const bValue = b.performance[metric] || 0;

      return metricDef.higherIsBetter
        ? bValue - aValue // Descending for higher is better
        : aValue - bValue; // Ascending for lower is better
    })[0]?.id;
  };

  // Format value based on metric
  const formatMetricValue = (value, metricId) => {
    if (value === undefined || value === null) return 'N/A';

    const metric = [...coreMetrics, ...extendedMetrics].find(m => m.id === metricId);
    if (!metric) return value.toString();

    // Format based on unit
    switch (metric.unit) {
      case 'ms':
        return `${value.toFixed(1)}ms`;
      case '$/1K tokens':
        return `$${value}`;
      case '%':
        return `${value.toFixed(1)}%`;
      case 'score':
        return value.toFixed(1);
      case 'tokens':
        return value.toLocaleString();
      case 'req/min':
        return `${Math.round(value)}/min`;
      default:
        return value.toString();
    }
  };

  // Determine if a value is the best among all selected models for a metric
  const isValueBest = (modelId, metricId) => {
    return getBestModelForMetric(metricId) === modelId;
  };

  // Run an A/B test simulation
  const handleStartAbTest = () => {
    if (!abTestConfig.modelA || !abTestConfig.modelB) {
      // Can't start test without two models
      return;
    }

    setAbTestActive(true);
    // In a real implementation, this would trigger an actual A/B test
    console.log('Starting A/B test with config:', abTestConfig);
  };

  // Stop the A/B test
  const handleStopAbTest = () => {
    setAbTestActive(false);
  };

  // Handle refreshing performance data
  const handleRefreshData = async () => {
    setRefreshingData(true);
    // In a real implementation, this would trigger a data refresh
    await new Promise(resolve => setTimeout(resolve, 1000));
    setRefreshingData(false);
  };

  // Generate sample A/B test results
  const abTestResults = useMemo(() => {
    if (!abTestActive || !abTestConfig.modelA || !abTestConfig.modelB) return null;

    const modelA = availableModels.find(model => model.id === abTestConfig.modelA);
    const modelB = availableModels.find(model => model.id === abTestConfig.modelB);

    if (!modelA || !modelB) return null;

    // Generate mock results with statistical significance
    return {
      sampleSize: Math.floor(Math.random() * 1000 + 500),
      metricsComparison: {
        latency: {
          modelA: modelA.performance.latency,
          modelB: modelB.performance.latency,
          difference: ((modelA.performance.latency - modelB.performance.latency) / modelA.performance.latency * 100).toFixed(1),
          significanceLevel: Math.random() > 0.3 ? 'high' : Math.random() > 0.5 ? 'medium' : 'low'
        },
        costEfficiency: {
          modelA: modelA.performance.costEfficiency,
          modelB: modelB.performance.costEfficiency,
          difference: ((modelA.performance.costEfficiency - modelB.performance.costEfficiency) / modelA.performance.costEfficiency * 100).toFixed(1),
          significanceLevel: Math.random() > 0.3 ? 'high' : Math.random() > 0.5 ? 'medium' : 'low'
        },
        tokenEfficiency: {
          modelA: modelA.performance.tokenEfficiency,
          modelB: modelB.performance.tokenEfficiency,
          difference: ((modelB.performance.tokenEfficiency - modelA.performance.tokenEfficiency) / modelA.performance.tokenEfficiency * 100).toFixed(1),
          significanceLevel: Math.random() > 0.3 ? 'high' : Math.random() > 0.5 ? 'medium' : 'low'
        }
      },
      conclusion: Math.random() > 0.5 ? abTestConfig.modelA : abTestConfig.modelB
    };
  }, [abTestActive, abTestConfig, availableModels]);

  // If no models data is available, show loading state
  if (!availableModels || availableModels.length === 0) {
    return (
      <Card className={`shadow-sm hover:shadow-md transition-shadow duration-200 ${darkMode ? 'bg-card/95' : ''}`}>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <BarChart3 className="h-5 w-5 text-primary" aria-hidden="true" />
            Model Performance Comparison
          </CardTitle>
          <CardDescription>
            Compare performance metrics across different models
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
              Compare performance metrics across different models
            </CardDescription>
          </div>

          <div className="flex items-center gap-2">
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
          </div>
        </div>
      </CardHeader>

      <Separator />

      <CardContent className="pt-6">
        {/* Model Selection Section */}
        <div className="mb-6">
          <h3 className="text-sm font-medium mb-3">Select Models to Compare ({selectedModels.length}/4)</h3>
          <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-3">
            {availableModels.map((model) => (
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
                <div className="text-xs text-muted-foreground line-clamp-2">
                  {model.description || `Context: ${model.contextWindow.toLocaleString()} tokens`}
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Metrics Comparison Section */}
        {selectedModels.length > 0 ? (
          <div className="mt-4">
            <h3 className="text-sm font-medium mb-3">Performance Comparison</h3>

            <div className="overflow-x-auto">
              <table className="w-full min-w-[600px] border-collapse">
                <thead>
                  <tr className="border-b">
                    <th className="text-left p-2 font-medium text-muted-foreground">Metric</th>
                    {selectedModels.map(modelId => {
                      const model = availableModels.find(m => m.id === modelId);
                      return (
                        <th key={modelId} className="text-center p-2 font-medium">
                          {model?.name || modelId}
                        </th>
                      );
                    })}
                  </tr>
                </thead>
                <tbody>
                  {displayMetrics.map(metric => (
                    <tr key={metric.id} className="border-b hover:bg-muted/30">
                      <td className="p-2">
                        <div className="flex items-center gap-2">
                          {metric.icon}
                          <TooltipProvider>
                            <Tooltip>
                              <TooltipTrigger asChild>
                                <div className="flex items-center gap-1">
                                  <span>{metric.name}</span>
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
                      {selectedModels.map(modelId => {
                        const model = availableModels.find(m => m.id === modelId);
                        const value = model?.performance[metric.id];
                        const isBest = selectedModels.length > 1 && isValueBest(modelId, metric.id);

                        return (
                          <td key={`${modelId}-${metric.id}`} className="text-center p-2">
                            <div className="flex items-center justify-center gap-1">
                              {isBest && (
                                <Badge className="bg-emerald-100 text-emerald-800 dark:bg-emerald-900/40 dark:text-emerald-400">
                                  Best
                                </Badge>
                              )}
                              {formatMetricValue(value, metric.id)}
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
        ) : (
          <div className="flex flex-col items-center justify-center py-12 text-center">
            <Sparkles className="h-12 w-12 text-muted-foreground mb-4" />
            <h3 className="text-lg font-medium mb-2">Select models to compare</h3>
            <p className="text-muted-foreground max-w-md">
              Choose at least one model to see performance metrics. Select multiple models to compare them side by side.
            </p>
          </div>
        )}

        {/* A/B Testing Section */}
        {selectedModels.length >= 2 && (
          <div className="mt-8">
            <Separator className="mb-6" />

            <div className="flex items-center justify-between mb-4">
              <h3 className="text-sm font-medium">A/B Testing</h3>

              {abTestActive ? (
                <Button
                  variant="destructive"
                  size="sm"
                  onClick={handleStopAbTest}
                >
                  Stop Test
                </Button>
              ) : (
                <Button
                  variant="outline"
                  size="sm"
                  onClick={handleStartAbTest}
                  disabled={!abTestConfig.modelA || !abTestConfig.modelB}
                >
                  Start A/B Test
                </Button>
              )}
            </div>

            {!abTestActive ? (
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div className="border rounded-lg p-4">
                  <h4 className="text-sm font-medium mb-3">Test Configuration</h4>

                  <div className="space-y-4">
                    <div>
                      <label className="text-xs text-muted-foreground block mb-1">Model A</label>
                      <select
                        className="w-full p-2 border rounded bg-background"
                        value={abTestConfig.modelA}
                        onChange={(e) => setAbTestConfig(prev => ({ ...prev, modelA: e.target.value }))}
                      >
                        <option value="">Select Model A</option>
                        {selectedModels.map(modelId => {
                          const model = availableModels.find(m => m.id === modelId);
                          return (
                            <option key={modelId} value={modelId}>
                              {model?.name || modelId}
                            </option>
                          );
                        })}
                      </select>
                    </div>

                    <div>
                      <label className="text-xs text-muted-foreground block mb-1">Model B</label>
                      <select
                        className="w-full p-2 border rounded bg-background"
                        value={abTestConfig.modelB}
                        onChange={(e) => setAbTestConfig(prev => ({ ...prev, modelB: e.target.value }))}
                      >
                        <option value="">Select Model B</option>
                        {selectedModels.map(modelId => {
                          const model = availableModels.find(m => m.id === modelId);
                          if (modelId === abTestConfig.modelA) return null;
                          return (
                            <option key={modelId} value={modelId}>
                              {model?.name || modelId}
                            </option>
                          );
                        })}
                      </select>
                    </div>

                    <div>
                      <label className="text-xs text-muted-foreground block mb-1">
                        Traffic Allocation: {abTestConfig.trafficAllocation}% to Model A, {100 - abTestConfig.trafficAllocation}% to Model B
                      </label>
                      <input
                        type="range"
                        min="10"
                        max="90"
                        step="10"
                        className="w-full"
                        value={abTestConfig.trafficAllocation}
                        onChange={(e) => setAbTestConfig(prev => ({ ...prev, trafficAllocation: parseInt(e.target.value) }))}
                      />
                    </div>
                  </div>
                </div>

                <div className="border rounded-lg p-4">
                  <h4 className="text-sm font-medium mb-3">Metrics to Track</h4>
                  <div className="space-y-2">
                    {coreMetrics.map(metric => (
                      <div key={metric.id} className="flex items-center gap-2">
                        <input
                          type="checkbox"
                          id={`track-${metric.id}`}
                          checked={abTestConfig.metricsToTrack.includes(metric.id)}
                          onChange={(e) => {
                            if (e.target.checked) {
                              setAbTestConfig(prev => ({
                                ...prev,
                                metricsToTrack: [...prev.metricsToTrack, metric.id]
                              }));
                            } else {
                              setAbTestConfig(prev => ({
                                ...prev,
                                metricsToTrack: prev.metricsToTrack.filter(id => id !== metric.id)
                              }));
                            }
                          }}
                        />
                        <label htmlFor={`track-${metric.id}`} className="text-sm flex items-center gap-1">
                          {metric.icon}
                          {metric.name}
                        </label>
                      </div>
                    ))}
                  </div>
                </div>
              </div>
            ) : (
              // Show A/B test results when active
              abTestResults && (
                <div className="border rounded-lg p-4">
                  <div className="flex justify-between items-center mb-4">
                    <h4 className="text-sm font-medium">Test Results (Sample Size: {abTestResults.sampleSize})</h4>
                    <Badge variant="outline" className="bg-primary/20 text-primary">
                      Live Test
                    </Badge>
                  </div>

                  <div className="overflow-x-auto">
                    <table className="w-full border-collapse">
                      <thead>
                        <tr className="border-b">
                          <th className="text-left p-2 text-xs font-medium text-muted-foreground">Metric</th>
                          <th className="text-center p-2 text-xs font-medium">
                            Model A:<br />
                            <span className="font-bold">{availableModels.find(m => m.id === abTestConfig.modelA)?.name}</span>
                          </th>
                          <th className="text-center p-2 text-xs font-medium">
                            Model B:<br />
                            <span className="font-bold">{availableModels.find(m => m.id === abTestConfig.modelB)?.name}</span>
                          </th>
                          <th className="text-center p-2 text-xs font-medium">Difference</th>
                          <th className="text-center p-2 text-xs font-medium">Significance</th>
                        </tr>
                      </thead>
                      <tbody>
                        {Object.entries(abTestResults.metricsComparison).map(([metricId, data]) => {
                          const metric = coreMetrics.find(m => m.id === metricId);
                          if (!metric) return null;

                          // Determine if the difference is positive or negative
                          // For "higher is better" metrics, positive difference means B is better
                          // For "lower is better" metrics, negative difference means B is better
                          const diffIsPositive = metric.higherIsBetter
                            ? parseFloat(data.difference) > 0
                            : parseFloat(data.difference) < 0;

                          // Calculate which model performed better for this metric
                          const betterModel = diffIsPositive ? 'B' : 'A';

                          return (
                            <tr key={metricId} className="border-b hover:bg-muted/30">
                              <td className="p-2">
                                <div className="flex items-center gap-2">
                                  {metric.icon}
                                  <span>{metric.name}</span>
                                </div>
                              </td>
                              <td className="text-center p-2">{formatMetricValue(data.modelA, metricId)}</td>
                              <td className="text-center p-2">{formatMetricValue(data.modelB, metricId)}</td>
                              <td className="text-center p-2">
                                <div className={`flex items-center justify-center gap-1 ${
                                  diffIsPositive
                                    ? 'text-emerald-600 dark:text-emerald-400'
                                    : 'text-red-600 dark:text-red-400'
                                }`}>
                                  {diffIsPositive ? <ArrowUp className="h-3 w-3" /> : <ArrowDown className="h-3 w-3" />}
                                  {Math.abs(parseFloat(data.difference))}%
                                </div>
                              </td>
                              <td className="text-center p-2">
                                <Badge variant="outline" className={
                                  data.significanceLevel === 'high'
                                    ? 'bg-emerald-100 text-emerald-800 dark:bg-emerald-900/40 dark:text-emerald-400'
                                    : data.significanceLevel === 'medium'
                                    ? 'bg-amber-100 text-amber-800 dark:bg-amber-900/40 dark:text-amber-400'
                                    : 'bg-gray-100 text-gray-800 dark:bg-gray-900/40 dark:text-gray-400'
                                }>
                                  {data.significanceLevel.charAt(0).toUpperCase() + data.significanceLevel.slice(1)}
                                </Badge>
                              </td>
                            </tr>
                          );
                        })}
                      </tbody>
                    </table>
                  </div>

                  <div className="mt-4 p-3 bg-muted/40 rounded-lg">
                    <div className="flex items-center gap-2">
                      <Sparkles className="h-4 w-4 text-primary" />
                      <span className="font-medium">Preliminary Conclusion:</span>
                    </div>
                    <p className="mt-1 text-sm">
                      Based on current data, <span className="font-medium">
                        {availableModels.find(m => m.id === abTestResults.conclusion)?.name}
                      </span> appears to perform better overall. Continue the test to increase statistical significance.
                    </p>
                  </div>
                </div>
              )
            )}
          </div>
        )}
      </CardContent>
    </Card>
  );
};

export default ModelPerformanceComparison;
