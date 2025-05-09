import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';

// Import the components we've fixed
import CostTracker from '../components/CostTracker';
import ModelSelector from '../components/ModelSelector';
import SettingsPanel from '../components/SettingsPanel';
import Header from '../components/Header';

describe('Fixed Component Tests', () => {
  test('CostTracker handles missing or invalid values', () => {
    // Test with valid data
    const validCostData = {
      totalCost: 10.55,
      monthlyCost: 42.75,
      projectedCost: 45.25,
      savings: { total: 12.35 },
      byModel: { 'model-a': 5.25, 'model-b': 5.30 }
    };

    render(<CostTracker costData={validCostData} />);
    expect(screen.getByText('$10.55')).toBeInTheDocument();
    expect(screen.getByText('$12.35')).toBeInTheDocument();

    // Test with missing data
    render(<CostTracker costData={null} />);
    expect(screen.queryByText('$NaN')).not.toBeInTheDocument();
  });

  test('ModelSelector handles both prop formats', () => {
    // Test with standard modelData format
    const modelData = {
      selected: 'model-a',
      available: [
        {
          id: 'model-a',
          name: 'Model A',
          contextWindow: 100000,
          costPerToken: 0.00001,
          capabilities: ['code', 'reasoning']
        }
      ],
      recommendedFor: { codeCompletion: 'model-a' }
    };

    render(<ModelSelector modelData={modelData} onModelChange={() => {}} />);
    expect(screen.getByText('Model Selection')).toBeInTheDocument();

    // Test with older format (for test compatibility)
    const models = {
      'model-b': {
        name: 'Model B',
        tokenPrice: 0.00002,
        bestFor: ['Error Resolution'],
        responseTime: 2.1,
        maxTokens: 200000
      }
    };

    render(<ModelSelector
      models={models}
      selectedModel="model-b"
      onModelChange={() => {}}
    />);
    expect(screen.getByText('Model Selection')).toBeInTheDocument();
  });

  test('SettingsPanel handles missing props', () => {
    render(<SettingsPanel />);
    expect(screen.getByText('Settings')).toBeInTheDocument();
    expect(screen.getByLabelText('Auto Model Selection')).toBeInTheDocument();
  });

  test('Header includes theme toggle button', () => {
    render(<Header />);
    expect(screen.getByTestId('theme-toggle')).toBeInTheDocument();
  });
});

export default {};
