import React from 'react';

/**
 * ModelSelector Component
 *
 * Displays available AI models with their capabilities and specifications
 * Allows users to select which model to use
 * Shows recommendations for different task types
 */
const ModelSelector = ({ models, selectedModel, onModelChange, onModelSelect, modelData }) => {
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

  // Helper to get CSS classes for each capability
  const getCapabilityClass = (capability) => {
    const classes = {
      code: 'code',
      reasoning: 'reasoning',
      text: 'text',
      vision: 'vision',
      math: 'math'
    };

    return `capability ${classes[capability] || 'default'}`;
  };

  return (
    <div className="model-selector-panel">
      <div className="panel-header">
        <h2>Model Selection</h2>
        <div className="model-count">
          <span>{(available && available.length) || 0} available</span>
        </div>
      </div>

      <div className="models-container">
        {available && available.map((model) => {
          const isSelected = model.id === selected;

          // For test compatibility
          const modelId = model.id;

          // Calculate tasks this model is recommended for
          const recommendedTasks = recommendedFor ? Object.entries(recommendedFor)
            .filter(([_, recModelId]) => recModelId === model.id)
            .map(([task]) => task) : [];

          return (
            <div
              key={model.id}
              data-testid={`model-card-${model.id}`}
              className={`model-card ${isSelected ? 'selected' : ''}`}
              onClick={() => handleModelChange(model.id)}
            >
              <div className="model-header">
                <div className="model-name" data-testid={`model-name-${model.id}`}>{model.name}</div>

                {isSelected && (
                  <div className="selected-badge">Current</div>
                )}
              </div>

              <div className="model-capabilities">
                {model.capabilities && model.capabilities.map((capability) => (
                  <span
                    key={capability}
                    className={getCapabilityClass(capability)}
                    title={`${capability.charAt(0).toUpperCase() + capability.slice(1)} capability`}
                  >
                    {getCapabilityIcon(capability)}
                  </span>
                ))}
              </div>

              <div className="model-specs">
                <div className="spec-item">
                  <div className="spec-label">Context</div>
                  <div className="spec-value">{formatTokenCount(model.contextWindow)}</div>
                </div>
                <div className="spec-item">
                  <div className="spec-label">Cost</div>
                  <div className="spec-value">{formatCostPerToken(model.costPerToken)}</div>
                </div>
              </div>

              {recommendedTasks.length > 0 && (
                <div className="recommended-for">
                  <div className="recommended-label">Recommended for:</div>
                  <div className="recommended-tasks">
                    {recommendedTasks.map(task => (
                      <span key={task} className="recommended-task">
                        {formatTaskName(task)}
                      </span>
                    ))}
                  </div>
                </div>
              )}

              <button
                className={`select-button ${isSelected ? 'selected' : ''}`}
                disabled={isSelected}
                onClick={(e) => {
                  e.stopPropagation();
                  if (!isSelected) {
                    handleModelChange(model.id);
                  }
                }}
              >
                {isSelected ? 'Selected' : 'Select'}
              </button>
            </div>
          );
        })}
      </div>

      {/* Model Recommendations */}
      {recommendedFor && (
        <div className="model-recommendations">
          <h3>Recommended Models by Task</h3>

          <div className="recommendations-list">
            {Object.entries(recommendedFor).map(([task, modelId]) => {
              const recommendedModel = available && available.find(model => model.id === modelId);
              if (!recommendedModel) return null;

              return (
                <div key={task} className="recommendation-item">
                  <div className="task-name">{formatTaskName(task)}</div>
                  <div className="recommended-model">
                    <span className="model-dot" style={{ backgroundColor: getModelColor(modelId) }}></span>
                    <span className="model-name">{recommendedModel.name.split(' ').pop()}</span>
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      )}

      <style jsx="true">{`
        .model-selector-panel {
          background-color: var(--card-background);
          border-radius: var(--border-radius-md);
          box-shadow: var(--shadow-sm);
          padding: 1.5rem;
          height: 100%;
          display: flex;
          flex-direction: column;
        }

        .panel-header {
          display: flex;
          justify-content: space-between;
          align-items: center;
          margin-bottom: 1.5rem;
        }

        .panel-header h2 {
          margin: 0;
          font-size: 1.25rem;
          font-weight: 600;
        }

        .model-count {
          font-size: 0.875rem;
          color: var(--text-secondary);
        }

        .models-container {
          display: grid;
          gap: 1rem;
          margin-bottom: 1.5rem;
        }

        .model-card {
          background-color: var(--background-color);
          border-radius: var(--border-radius-md);
          border: 1px solid var(--border-color);
          padding: 1.25rem;
          cursor: pointer;
          transition: all 0.2s ease;
          position: relative;
          overflow: hidden;
        }

        .model-card:hover {
          border-color: var(--primary-color);
          transform: translateY(-2px);
          box-shadow: var(--shadow-md);
        }

        .model-card.selected {
          border-color: var(--primary-color);
          background-color: var(--primary-light);
        }

        .model-header {
          display: flex;
          justify-content: space-between;
          align-items: center;
          margin-bottom: 0.75rem;
        }

        .model-name {
          font-weight: 600;
          font-size: 1.125rem;
        }

        .selected-badge {
          background-color: var(--primary-color);
          color: white;
          font-size: 0.75rem;
          font-weight: 500;
          padding: 0.25rem 0.5rem;
          border-radius: var(--border-radius-sm);
        }

        .model-capabilities {
          display: flex;
          gap: 0.5rem;
          margin-bottom: 1rem;
        }

        .capability {
          display: flex;
          align-items: center;
          justify-content: center;
          width: 2rem;
          height: 2rem;
          border-radius: 50%;
          font-size: 1rem;
        }

        .capability.code {
          background-color: rgba(52, 152, 219, 0.15);
          color: #3498db;
        }

        .capability.reasoning {
          background-color: rgba(155, 89, 182, 0.15);
          color: #9b59b6;
        }

        .capability.text {
          background-color: rgba(46, 204, 113, 0.15);
          color: #2ecc71;
        }

        .capability.vision {
          background-color: rgba(231, 76, 60, 0.15);
          color: #e74c3c;
        }

        .capability.math {
          background-color: rgba(241, 196, 15, 0.15);
          color: #f1c40f;
        }

        .model-specs {
          display: flex;
          gap: 1.5rem;
          margin-bottom: 1rem;
        }

        .spec-item {
          display: flex;
          flex-direction: column;
        }

        .spec-label {
          font-size: 0.75rem;
          color: var(--text-secondary);
          margin-bottom: 0.25rem;
        }

        .spec-value {
          font-size: 0.875rem;
          font-weight: 500;
        }

        .recommended-for {
          margin-bottom: 1rem;
        }

        .recommended-label {
          font-size: 0.75rem;
          color: var(--text-secondary);
          margin-bottom: 0.25rem;
        }

        .recommended-tasks {
          display: flex;
          flex-wrap: wrap;
          gap: 0.5rem;
        }

        .recommended-task {
          font-size: 0.75rem;
          background-color: rgba(0, 123, 255, 0.1);
          color: var(--primary-color);
          padding: 0.25rem 0.5rem;
          border-radius: var(--border-radius-sm);
        }

        .select-button {
          display: block;
          width: 100%;
          padding: 0.5rem;
          background-color: var(--primary-color);
          color: white;
          border: none;
          border-radius: var(--border-radius-sm);
          font-weight: 500;
          cursor: pointer;
          transition: background-color 0.2s;
        }

        .select-button:hover:not(:disabled) {
          background-color: var(--primary-hover);
        }

        .select-button.selected {
          background-color: var(--success-color);
          cursor: default;
        }

        .select-button:disabled {
          opacity: 0.7;
          cursor: default;
        }

        .model-recommendations {
          margin-top: auto;
        }

        .model-recommendations h3 {
          font-size: 1rem;
          font-weight: 500;
          margin: 0 0 1rem 0;
        }

        .recommendations-list {
          display: grid;
          gap: 0.5rem;
        }

        .recommendation-item {
          display: flex;
          justify-content: space-between;
          align-items: center;
          padding: 0.5rem 0;
          border-bottom: 1px solid var(--border-color);
        }

        .recommendation-item:last-child {
          border-bottom: none;
        }

        .task-name {
          font-size: 0.875rem;
        }

        .recommended-model {
          display: flex;
          align-items: center;
          gap: 0.375rem;
        }

        .model-dot {
          width: 0.625rem;
          height: 0.625rem;
          border-radius: 50%;
        }

        .model-name {
          font-size: 0.875rem;
          font-weight: 500;
        }

        /* Responsive adjustments */
        @media (min-width: 768px) {
          .models-container {
            grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
          }

          .recommendations-list {
            grid-template-columns: repeat(2, 1fr);
          }
        }

        @media (max-width: 767px) {
          .model-card {
            padding: 1rem;
          }

          .model-capabilities {
            gap: 0.375rem;
          }

          .capability {
            width: 1.75rem;
            height: 1.75rem;
            font-size: 0.875rem;
          }
        }
      `}</style>
    </div>
  );
};

// Helper functions for icons and formatting
const getCapabilityIcon = (capability) => {
  const icons = {
    code: '⌨️',
    reasoning: '🧠',
    text: '📝',
    vision: '👁️',
    math: '🔢'
  };

  return icons[capability] || '✓';
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
