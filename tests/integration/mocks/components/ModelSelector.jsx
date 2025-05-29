import React from 'react';

export const ModelSelector = ({ models, selectedModel, onModelChange, ...props }) => (
  <div data-testid="model-selector" {...props}>
    <h3>Model Selector Mock</h3>
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
  </div>
);

export default ModelSelector; 