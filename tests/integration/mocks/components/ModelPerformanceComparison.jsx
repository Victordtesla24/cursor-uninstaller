import React from 'react';

const ModelPerformanceComparison = ({ 
  modelsData, 
  usageData, 
  onModelSelect, 
  darkMode, 
  ...props 
}) => (
  <div data-testid="model-performance-comparison" data-dark={darkMode ? 'true' : 'false'} {...props}>
    <h3>Model Performance Comparison Mock</h3>
    {modelsData && (
      <div>
        <div>Comparing {Object.keys(modelsData).length} models</div>
        <button onClick={() => onModelSelect?.('recommended-model')}>
          Select Recommended Model
        </button>
      </div>
    )}
    {usageData && (
      <div>
        <span>Usage Data Available</span>
      </div>
    )}
  </div>
);

export default ModelPerformanceComparison; 