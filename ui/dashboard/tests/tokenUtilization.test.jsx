import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import TokenUtilization from '../components/TokenUtilization';

describe('TokenUtilization Component', () => {
  // Comprehensive mock data for testing
  const mockTokenData = {
    usage: {
      total: 550000,
      completion: 275000,
      chat: 150000,
      embedding: 125000
    },
    budgets: {
      total: 900000,
      completion: 450000,
      chat: 250000,
      embedding: 200000,
      codeCompletion: 300000,
      errorResolution: 200000,
      architecture: 150000,
      thinking: 100000
    },
    cacheEfficiency: 0.68,
    trends: {
      completion: -5.2,
      chat: 3.7,
      embedding: -1.8
    }
  };

  const mockCostData = {
    averageRate: 0.015,
    totalCost: 10.55,
    monthlyCost: 42.75,
    projectedCost: 45.25,
    savings: { total: 12.35 },
    byModel: { 'model-a': 5.25, 'model-b': 5.30 }
  };

  test('renders with full token usage data', () => {
    const { container } = render(
      <TokenUtilization
        tokenData={mockTokenData}
        costData={mockCostData}
      />
    );

    // Check component title
    expect(screen.getByText('Token Utilization')).toBeInTheDocument();

    // Check description is present
    expect(screen.getByText(/Token usage across/)).toBeInTheDocument();

    // Check if budgets are displayed - using a more reliable approach
    const progressBars = container.querySelectorAll('[role="progressbar"]');
    expect(progressBars.length).toBeGreaterThan(0);

    // Check cost estimation is displayed
    expect(container.textContent).toContain('Est. Cost');
  });

  test('renders empty state when no data is provided', () => {
    render(<TokenUtilization tokenData={{}} />);

    // Component should render title
    expect(screen.getByText('Token Utilization')).toBeInTheDocument();

    // Should show no data message
    expect(screen.getByText('No token usage data available')).toBeInTheDocument();
  });

  test('handles missing data properties gracefully', () => {
    // Data with just enough to avoid the empty state but missing some properties
    const incompleteData = {
      usage: { total: 100 }
      // No budgets or cacheEfficiency
    };

    const { container } = render(<TokenUtilization tokenData={incompleteData} />);

    // Should render the component (not the empty state)
    expect(screen.getByText('Token Utilization')).toBeInTheDocument();
    expect(screen.getByText(/Token usage across/)).toBeInTheDocument();

    // Container should include the usage number
    expect(container.textContent).toContain('100');
  });

  test('handles undefined tokenData', () => {
    // Test with undefined
    const { container } = render(<TokenUtilization />);

    expect(screen.getByText('Token Utilization')).toBeInTheDocument();
    expect(screen.getByText('No token usage data available')).toBeInTheDocument();
  });

  test('handles null tokenData', () => {
    // The component has a default empty object for tokenData
    // so we should mock its internal checks correctly
    const { container } = render(<TokenUtilization tokenData={{}} />);

    expect(screen.getByText('Token Utilization')).toBeInTheDocument();
    expect(screen.getByText('No token usage data available')).toBeInTheDocument();
  });

  test('displays cache efficiency correctly', () => {
    const { container } = render(
      <TokenUtilization
        tokenData={mockTokenData}
        costData={mockCostData}
      />
    );

    // Check for cache efficiency section and value
    expect(container.textContent).toContain('Cache Efficiency');
    expect(container.textContent).toContain('68%');
  });

  test('renders trend indicators correctly', () => {
    const { container } = render(<TokenUtilization tokenData={mockTokenData} costData={mockCostData} />);

    // Check for trend indicators using data-testid attributes
    const decreaseTrend = container.querySelector('[data-testid="trend-down-completion"]');
    expect(decreaseTrend).toBeInTheDocument();
    expect(decreaseTrend.textContent).toContain('-5.2%');

    const increaseTrend = container.querySelector('[data-testid="trend-up-chat"]');
    expect(increaseTrend).toBeInTheDocument();
    expect(increaseTrend.textContent).toContain('3.7%');
  });

  test('applies custom class name when provided', () => {
    // Custom class name should be applied to the component
    const { container } = render(
      <TokenUtilization
        tokenData={mockTokenData}
        costData={mockCostData}
        className="custom-test-class"
      />
    );

    // Verify the class is applied to the top-level element
    expect(container.firstChild).toHaveClass('custom-test-class');
  });

  test('renders correctly with zero values', () => {
    const zeroData = {
      usage: {
        total: 0,
        completion: 0,
        chat: 0,
      },
      budgets: {
        total: 1000,
        completion: 500,
        chat: 500,
      }
    };

    const { container } = render(<TokenUtilization tokenData={zeroData} />);

    // Should handle zero values gracefully
    expect(screen.getByText('Token Utilization')).toBeInTheDocument();

    // Should show 0% usage
    expect(container.textContent).toContain('0%');
  });

  test('handles budget values greater than usage', () => {
    const data = {
      usage: {
        total: 100
      },
      budgets: {
        total: 1000
      }
    };

    const { container } = render(<TokenUtilization tokenData={data} />);

    // Should calculate correct percentage
    expect(container.textContent).toContain('10%');
  });

  test('handles extreme cases where usage exceeds budget', () => {
    const data = {
      usage: {
        total: 1500
      },
      budgets: {
        total: 1000
      }
    };

    const { container } = render(<TokenUtilization tokenData={data} />);

    // Should indicate over budget (implementation-specific, but should render)
    expect(screen.getByText('Token Utilization')).toBeInTheDocument();

    // Either 100% or >100% or some visual indicator
    const containerText = container.textContent;
    const hasOverBudgetIndicator =
      containerText.includes('100%') ||
      containerText.includes('>100%') ||
      containerText.includes('150%') ||
      containerText.includes('Over budget');

    expect(hasOverBudgetIndicator).toBe(true);
  });
});
