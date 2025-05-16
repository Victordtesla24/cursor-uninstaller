import React, { useState, useEffect, useMemo } from 'react';
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
  Badge,
  Button,
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
  Separator
} from './ui/index.js';
import {
  Code2,
  BrainCircuit,
  TextIcon,
  Eye,
  Calculator,
  CheckCircle,
  CheckCircle2,
  Sparkles,
  ChevronsUpDown
} from 'lucide-react';

/**
 * ModelSelector Component
 *
 * Displays available AI models with their capabilities and specifications
 * Allows users to select which model to use
 * Shows recommendations for different task types
 *
 * @param {Object} props Component props
 * @param {Array|Object} props.models Available models
 * @param {String} props.selectedModel Currently selected model ID
 * @param {Function} props.onModelChange Callback for model selection
 * @param {Function} props.onModelSelect Legacy callback for model selection
 * @param {Object} props.modelData Structured model data
 * @param {Boolean} props.darkMode Whether dark mode is enabled
 */
const ModelSelector = ({
  models,
  selectedModel,
  onModelChange,
  onModelSelect,
  modelData,
  className = '',
  darkMode = false
}) => {
  // Allow both ways of passing props for backward compatibility with tests
  // Add compatibility with both onModelChange and onModelSelect prop names
  const handleModelChange = onModelChange || onModelSelect;

  const modelInfo = modelData || {
    selected: selectedModel,
    available: models && Object.entries(models).map(([id, details]) => ({
      id,
      ...details
    })),
    recommendedFor: {}
  };

  if (!modelInfo && !models) {
    return null;
  }

  const { selected, available, recommendedFor } = modelInfo;

  // Format token count with K suffix
  const formatTokenCount = (count) => {
    if (count === undefined || count === null) {
      return '0K';
    }
    return `${(count / 1000).toFixed(0)}K`;
  };

  // Format cost per token
  const formatCostPerToken = (cost) => {
    if (cost === undefined || cost === null) {
      return '$0.00000/token';
    }
    if (cost < 0.0001) {
      return `$${(cost * 1000000).toFixed(2)}/1M tokens`;
    }
    return `$${cost.toFixed(5)}/token`;
  };

  // Helper to determine if a model is recommended for a specific task
  const isRecommendedFor = (modelId, task) => {
    return recommendedFor && recommendedFor[task] === modelId;
  };

  // Helper to get color variants for each capability
  const getCapabilityColorClass = (capability) => {
    const classes = {
      code: 'bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-300',
      reasoning: 'bg-purple-100 text-purple-700 dark:bg-purple-900/30 dark:text-purple-300',
      text: 'bg-emerald-100 text-emerald-700 dark:bg-emerald-900/30 dark:text-emerald-300',
      vision: 'bg-red-100 text-red-700 dark:bg-red-900/30 dark:text-red-300',
      math: 'bg-amber-100 text-amber-700 dark:bg-amber-900/30 dark:text-amber-300'
    };

    return classes[capability] || 'bg-gray-100 text-gray-700 dark:bg-gray-800 dark:text-gray-300';
  };

  return (
    <Card className={`${className} shadow-sm h-full`}>
      <CardHeader className="pb-3">
        <div className="flex justify-between items-center">
          <CardTitle className="text-xl">
            <div className="flex items-center">
              <Sparkles className="mr-2 h-5 w-5 text-primary" />
              Model Selection
            </div>
          </CardTitle>
          <Badge variant="outline" className="bg-muted/50 text-muted-foreground">
            {(available && available.length) || 0} available
          </Badge>
        </div>
        <CardDescription>
          Choose the best AI model for your needs
        </CardDescription>
      </CardHeader>

      <CardContent className="space-y-6">
        <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-3">
          {available && (Array.isArray(available) ? available : Object.values(available)).map((model, index) => {
            const isSelected = model.id === selected;

            // For test compatibility
            const modelId = model.id;

            // Calculate tasks this model is recommended for
            const recommendedTasks = recommendedFor ? Object.entries(recommendedFor)
              .filter(([_, recModelId]) => recModelId === model.id)
              .map(([task]) => task) : [];

            return (
              <div
                key={model.id || `model-${index}`}
                data-testid={`model-card-${model.id}`}
                className={`relative rounded-lg border overflow-hidden transition-all duration-200 hover:shadow-md ${
                  isSelected
                    ? 'border-primary bg-primary/5 dark:bg-primary/10'
                    : 'border-border hover:border-primary/60'
                }`}
                onClick={() => handleModelChange(model.id)}
              >
                <div className="p-4 space-y-4 cursor-pointer">
                  <div className="flex justify-between items-center">
                    <div
                      className="font-medium text-base"
                      data-testid={`model-name-${model.id}`}
                    >
                      {model.name}
                    </div>

                    {isSelected && (
                      <Badge className="bg-primary hover:bg-primary text-primary-foreground py-1">
                        Current
                      </Badge>
                    )}
                  </div>

                  <div className="flex flex-wrap gap-2">
                    {model.capabilities && model.capabilities.map((capability, capIndex) => (
                      <TooltipProvider key={`${model.id}-${capability}-${capIndex}`}>
                        <Tooltip>
                          <TooltipTrigger asChild>
                            <div className={`flex items-center justify-center w-8 h-8 rounded-full ${getCapabilityColorClass(capability)}`}>
                              {getCapabilityIcon(capability)}
                            </div>
                          </TooltipTrigger>
                          <TooltipContent side="top">
                            <p>{capability.charAt(0).toUpperCase() + capability.slice(1)} capability</p>
                          </TooltipContent>
                        </Tooltip>
                      </TooltipProvider>
                    ))}
                  </div>

                  <div className="grid grid-cols-2 gap-4">
                    <div>
                      <div className="text-xs text-muted-foreground">Context</div>
                      <div className="font-medium">{formatTokenCount(model.contextWindow)}</div>
                    </div>
                    <div>
                      <div className="text-xs text-muted-foreground">Cost</div>
                      <div className="font-medium">{formatCostPerToken(model.costPerToken)}</div>
                    </div>
                  </div>

                  {recommendedTasks.length > 0 && (
                    <div>
                      <div className="text-xs text-muted-foreground mb-1.5">Recommended for:</div>
                      <div className="flex flex-wrap gap-1.5">
                        {recommendedTasks.map((task, taskIndex) => (
                          <Badge
                            key={`${model.id}-${task}-${taskIndex}`}
                            variant="outline"
                            className="bg-primary/10 text-primary border-primary/20 dark:bg-primary/20 text-xs font-normal"
                          >
                            {formatTaskName(task)}
                          </Badge>
                        ))}
                      </div>
                    </div>
                  )}

                  <Button
                    variant={isSelected ? "secondary" : "default"}
                    size="sm"
                    className={`w-full mt-2 ${isSelected ? 'bg-primary/20 hover:bg-primary/20 text-primary dark:bg-primary/30' : ''}`}
                    disabled={isSelected}
                    onClick={(e) => {
                      e.stopPropagation();
                      if (!isSelected) {
                        handleModelChange(model.id);
                      }
                    }}
                  >
                    {isSelected ? (
                      <div className="flex items-center">
                        <CheckCircle2 className="mr-1 h-4 w-4" />
                        Selected
                      </div>
                    ) : 'Select'}
                  </Button>
                </div>
              </div>
            );
          })}
        </div>

        {/* Model Recommendations */}
        {recommendedFor && Object.keys(recommendedFor).length > 0 && (
          <div className="mt-auto pt-4">
            <Separator className="mb-4" />

            <div className="space-y-3">
              <h3 className="text-sm font-medium">Recommended Models by Task</h3>

              <div className="grid gap-2 sm:grid-cols-2">
                {Object.entries(recommendedFor).map(([task, modelId]) => {
                  const modelArray = Array.isArray(available) ? available : Object.values(available);
                  const recommendedModel = available && modelArray.find(model => model.id === modelId);
                  if (!recommendedModel) return null;

                  return (
                    <div key={task} className="flex items-center justify-between p-2 rounded-md border border-border">
                      <div className="text-sm">{formatTaskName(task)}</div>
                      <div className="flex items-center gap-1.5">
                        <div
                          className="w-2.5 h-2.5 rounded-full"
                          style={{ backgroundColor: getModelColor(modelId) }}
                        ></div>
                        <div className="text-sm font-medium">{recommendedModel.name.split(' ').pop()}</div>
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>
          </div>
        )}
      </CardContent>
    </Card>
  );
};

// Helper functions for icons and formatting
const getCapabilityIcon = (capability) => {
  switch (capability) {
    case 'code':
      return <Code2 className="h-4 w-4" />;
    case 'reasoning':
      return <BrainCircuit className="h-4 w-4" />;
    case 'text':
      return <TextIcon className="h-4 w-4" />;
    case 'vision':
      return <Eye className="h-4 w-4" />;
    case 'math':
      return <Calculator className="h-4 w-4" />;
    default:
      return <CheckCircle className="h-4 w-4" />;
  }
};

const formatTaskName = (task) => {
  const formattedNames = {
    codeCompletion: 'Code Completion',
    errorResolution: 'Error Resolution',
    architecture: 'Architecture',
    thinking: 'Thinking',
    basicTasks: 'Basic Tasks'
  };

  return formattedNames[task] || task.charAt(0).toUpperCase() + task.slice(1);
};

const getModelColor = (modelId) => {
  const colors = {
    'claude-3.7-sonnet': '#7b68ee',
    'gemini-2.5-flash': '#4285f4',
    'claude-3.7-haiku': '#9575cd'
  };

  return colors[modelId] || '#999';
};

export { ModelSelector };
export default ModelSelector;
