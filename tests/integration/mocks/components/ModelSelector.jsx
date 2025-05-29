import React from 'react';

export const ModelSelector = ({ models, selectedModel, onModelChange, ...props }) => {
  const handleModelCardClick = (modelId) => {
    onModelChange?.(modelId);
  };

  return (
    <div data-testid="model-selector" {...props}>
      <h3>Model Selection</h3>
      
      <select
        value={selectedModel || ''}
        onChange={(e) => onModelChange?.(e.target.value)}
        data-testid="model-select"
      >
        <option value="">Select a model</option>
        {models && Object.entries(models).map(([key, model]) => (
          <option key={key} value={key}>
            {model.name || key}
          </option>
        ))}
      </select>

      {/* Model cards for tests */}
      {models && (
        <div>
          <h4>Available Models</h4>
          {Object.entries(models).map(([key, model]) => (
            <div 
              key={key} 
              data-testid={`model-card-${key}`}
              onClick={() => handleModelCardClick(key)}
              style={{ cursor: 'pointer', padding: '10px', border: '1px solid #ccc', margin: '5px 0' }}
            >
              <div data-testid={`model-name-${key}`}>
                {model.name || key}
              </div>
              <div>Context Window: {model.contextWindow || 'N/A'}</div>
              <div>Cost per Token: ${model.costPerToken || 'N/A'}</div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
};

export default ModelSelector; 