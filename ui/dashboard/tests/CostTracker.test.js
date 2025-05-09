import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import '@testing-library/jest-dom';
import CostTracker from '../components/CostTracker';

describe('CostTracker Component', () => {
  const mockCostData = {
    totalCost: 25.50,
    monthlyCost: 175.80,
    projectedCost: 190.25,
    savings: {
      total: 15.30,
      caching: 5.60,
      optimization: 9.70
    },
    byModel: {
      'claude-3-sonnet': 18.75,
      'gemini-2-5-flash': 6.75
    },
    history: {
      daily: [2.50, 3.20, 1.80, 4.10, 2.90, 3.60, 2.10],
      weekly: [15.40, 17.80, 14.60, 16.90],
      monthly: [68.30, 72.60, 75.80, 83.20]
    }
  };

  test('renders cost information correctly', () => {
    render(<CostTracker costData={mockCostData} />);

    // Check for panel title
    expect(screen.getByText('Cost Metrics')).toBeInTheDocument();

    // Check for key metric values
    expect(screen.getByText('$25.50')).toBeInTheDocument(); // Total cost
    expect(screen.getByText('$190.25')).toBeInTheDocument(); // Projected cost
    expect(screen.getByText('$15.30')).toBeInTheDocument(); // Total savings

    // Check for model breakdown
    expect(screen.getByText('sonnet')).toBeInTheDocument();
    expect(screen.getByText('flash')).toBeInTheDocument();

    // Check for savings breakdown section
    expect(screen.getByText('Savings Breakdown')).toBeInTheDocument();
  });

  test('changes timeframe when selector is changed', () => {
    render(<CostTracker costData={mockCostData} />);

    // Default is daily view
    const timeframeSelector = screen.getByRole('combobox');
    expect(timeframeSelector.value).toBe('daily');

    // Change to weekly view
    fireEvent.change(timeframeSelector, { target: { value: 'weekly' } });
    expect(timeframeSelector.value).toBe('weekly');

    // Change to monthly view
    fireEvent.change(timeframeSelector, { target: { value: 'monthly' } });
    expect(timeframeSelector.value).toBe('monthly');
  });

  test('handles null or undefined data gracefully', () => {
    render(<CostTracker costData={null} />);

    // Component should not render anything when data is null
    expect(screen.queryByText('Cost Metrics')).not.toBeInTheDocument();

    // Now try with empty data
    render(<CostTracker costData={{}} />);

    // Component should render default values
    expect(screen.getByText('Cost Metrics')).toBeInTheDocument();

    // Find total cost specifically - look for the primary cost card
    const costCards = screen.getAllByText('$0.00');
    expect(costCards.length).toBeGreaterThan(0);

    // Check for default "No data" messages
    expect(screen.getByText('No historical data available')).toBeInTheDocument();
    expect(screen.getByText('No model cost data available')).toBeInTheDocument();
  });
});
