import React from 'react';
import {
  Badge,
  Button,
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger
} from '../ui/index.js';
import {
  Code2,
  BrainCircuit,
  TextIcon,
  Eye,
  Calculator,
  CheckCircle,
  CheckCircle2
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
  darkMode = false // Changed _darkMode to darkMode
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

  // Helper to get color variants for each capability
  const getCapabilityColorClass = (capability) => {
    const classes = {
      code: 'bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-300',
      reasoning: 'bg-purple-100 text-purple-700 dark:bg-purple-900/30 dark:text-purple-300',
      text: 'bg-emerald-100 text-emerald-700 dark:bg-emerald-900/30 dark:text-emerald-300',
      vision: 'bg-red-100 text-red-700 dark:bg-red-900/30 dark:text-red-300',
      math: 'bg-amber-100 text-amber-700 dark:bg-amber-900/30 dark:text-amber-300'
    };

    return classes[capability] || (darkMode ? 'bg-slate-700 text-slate-300' : 'bg-slate-100 text-slate-700');
  };

  // Removed outer Card wrapper
  return (
    <div className={`${className} h-full space-y-6`}>
      <div className="flex justify-between items-center">
        {/* Title is now part of the parent component (Dashboard.jsx) */}
        {/* <h3 className={`text-xl font-semibold ${darkMode ? 'text-slate-100' : 'text-slate-800'}`}>Model Selection</h3> */}
        <Badge variant="outline" className={`${darkMode ? 'bg-slate-700 text-slate-300 border-slate-600' : 'bg-slate-100 text-slate-600 border-slate-300'} text-sm px-3 py-1`}>
          {(available && available.length) || 0} available
        </Badge>
      </div>
      {/* <p className={`text-sm ${darkMode ? 'text-slate-400' : 'text-slate-500'} mb-6`}>Choose the best AI model for your needs</p> */}

      <div className="grid gap-5 md:grid-cols-2 xl:grid-cols-3">
        {available && (Array.isArray(available) ? available : Object.values(available)).map((model, index) => {
          const isSelected = model.id === selected;
          const recommendedTasks = recommendedFor ? Object.entries(recommendedFor)
            .filter(([, recModelId]) => recModelId === model.id)
            .map(([task]) => task) : [];

          return (
            <div
              key={model.id || `model-${index}`}
              data-testid={`model-card-${model.id}`}
              className={`relative rounded-xl border overflow-hidden transition-all duration-300 hover:shadow-xl cursor-pointer group
                ${isSelected
                  ? (darkMode ? 'border-blue-500 bg-blue-600/10 ring-2 ring-blue-500' : 'border-blue-500 bg-blue-50 ring-2 ring-blue-500')
                  : (darkMode ? 'border-slate-700 hover:border-blue-600/70 bg-slate-800/70 hover:bg-slate-700/70' : 'border-slate-200 hover:border-blue-400 bg-white hover:bg-slate-50/50')
                }`}
              onClick={() => handleModelChange(model.id)}
            >
              <div className="p-5 space-y-4">
                <div className="flex justify-between items-start">
                  <h4 className={`font-semibold text-md ${darkMode ? 'text-slate-100' : 'text-slate-800'} group-hover:${darkMode ? 'text-blue-300' : 'text-blue-600'} transition-colors`}
                      data-testid={`model-name-${model.id}`}>
                    {model.name}
                  </h4>
                  {isSelected && (
                    <Badge className={`${darkMode ? 'bg-blue-500 text-white' : 'bg-blue-600 text-white'} text-xs px-2.5 py-1 shadow-md`}>
                      Current
                    </Badge>
                  )}
                </div>

                <div className="flex flex-wrap gap-2">
                  {model.capabilities && model.capabilities.map((capability, capIndex) => (
                    <TooltipProvider key={`${model.id}-${capability}-${capIndex}`}>
                      <Tooltip>
                        <TooltipTrigger asChild>
                          <div className={`flex items-center justify-center w-9 h-9 rounded-lg ${getCapabilityColorClass(capability)} shadow-sm`}>
                            {getCapabilityIcon(capability)}
                          </div>
                        </TooltipTrigger>
                        <TooltipContent side="top" className={`${darkMode ? 'bg-slate-700 text-slate-200 border-slate-600' : 'bg-slate-800 text-white border-slate-700'}`}>
                          <p>{capability.charAt(0).toUpperCase() + capability.slice(1)}</p>
                        </TooltipContent>
                      </Tooltip>
                    </TooltipProvider>
                  ))}
                </div>

                <div className="grid grid-cols-2 gap-x-4 gap-y-2 text-xs pt-2">
                  <div>
                    <div className={`${darkMode ? 'text-slate-400' : 'text-slate-500'}`}>Context Window</div>
                    <div className={`font-medium ${darkMode ? 'text-slate-200' : 'text-slate-700'}`}>{formatTokenCount(model.contextWindow)}</div>
                  </div>
                  <div>
                    <div className={`${darkMode ? 'text-slate-400' : 'text-slate-500'}`}>Est. Cost/Token</div>
                    <div className={`font-medium ${darkMode ? 'text-slate-200' : 'text-slate-700'}`}>{formatCostPerToken(model.costPerToken)}</div>
                  </div>
                </div>

                {recommendedTasks.length > 0 && (
                  <div className="pt-2">
                    <div className={`text-xs ${darkMode ? 'text-slate-400' : 'text-slate-500'} mb-1.5`}>Recommended for:</div>
                    <div className="flex flex-wrap gap-1.5">
                      {recommendedTasks.map((task, taskIndex) => (
                        <Badge
                          key={`${model.id}-${task}-${taskIndex}`}
                          variant="outline"
                          className={`${darkMode ? 'bg-blue-600/20 text-blue-300 border-blue-500/30' : 'bg-blue-100 text-blue-700 border-blue-300/50'} text-xs px-2 py-0.5 font-normal`}
                        >
                          {formatTaskName(task)}
                        </Badge>
                      ))}
                    </div>
                  </div>
                )}

                <Button
                  variant={isSelected ? "secondary" : (darkMode ? "outlineDark" : "outline")}
                  size="sm"
                  className={`w-full mt-3 text-sm transition-all duration-200
                    ${isSelected 
                      ? (darkMode ? 'bg-blue-500/30 hover:bg-blue-500/40 text-blue-200 cursor-not-allowed' : 'bg-blue-100 hover:bg-blue-100 text-blue-600 cursor-not-allowed')
                      : (darkMode ? 'border-slate-600 hover:bg-blue-600 hover:text-white hover:border-blue-600' : 'border-slate-300 hover:bg-blue-500 hover:text-white hover:border-blue-500')
                    }`}
                  disabled={isSelected}
                  onClick={(e) => {
                    e.stopPropagation();
                    if (!isSelected) {
                      handleModelChange(model.id);
                    }
                  }}
                >
                  {isSelected ? (
                    <div className="flex items-center justify-center">
                      <CheckCircle2 className="mr-1.5 h-4 w-4" />
                      Selected
                    </div>
                  ) : 'Select'}
                </Button>
              </div>
            </div>
          );
        })}
      </div>

      {recommendedFor && Object.keys(recommendedFor).length > 0 && (
        <div className="mt-8 pt-6 border-t ${darkMode ? 'border-slate-700' : 'border-slate-200'}">
          <h4 className={`text-sm font-semibold mb-3 ${darkMode ? 'text-slate-200' : 'text-slate-700'}`}>Recommended Models by Task</h4>
          <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
            {Object.entries(recommendedFor).map(([task, modelId]) => {
              const modelArray = Array.isArray(available) ? available : Object.values(available);
              const recommendedModel = available && modelArray.find(model => model.id === modelId);
              if (!recommendedModel) return null;

              return (
                <div key={task} className={`flex items-center justify-between p-3 rounded-lg border ${darkMode ? 'border-slate-700 bg-slate-800/50' : 'border-slate-200 bg-slate-50/70'}`}>
                  <div className={`text-sm ${darkMode ? 'text-slate-300' : 'text-slate-600'}`}>{formatTaskName(task)}</div>
                  <div className="flex items-center gap-2">
                    <div
                      className="w-3 h-3 rounded-full"
                      style={{ backgroundColor: getModelColor(modelId, darkMode) }} // Pass darkMode to getModelColor
                    ></div>
                    <div className={`text-sm font-medium ${darkMode ? 'text-slate-200' : 'text-slate-700'}`}>{recommendedModel.name.split(' ').pop()}</div>
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      )}
    </div>
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

const getModelColor = (modelId, darkMode) => { // Added darkMode parameter
  const colorsLight = {
    'claude-3.7-sonnet': '#7b68ee',    // MediumPurple
    'gemini-2.5-flash': '#4285F4',     // Google Blue
    'claude-3.7-haiku': '#9575cd',     // MediumPurple (lighter shade)
  };
  const colorsDark = { // Slightly adjusted for dark mode visibility if needed
    'claude-3.7-sonnet': '#8a7ff0',
    'gemini-2.5-flash': '#699eff',
    'claude-3.7-haiku': '#a18eda',
  };
  return darkMode ? (colorsDark[modelId] || '#bbb') : (colorsLight[modelId] || '#777');
};

export { ModelSelector };
export default ModelSelector;
