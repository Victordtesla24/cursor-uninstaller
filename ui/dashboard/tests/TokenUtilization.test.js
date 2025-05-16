import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import TokenUtilization from '../components/TokenUtilization';

describe('TokenUtilization Component', () => {
  const mockTokenData = {
    usage: { total: 528000 },
    budgets: {
      total: 750000,
      codeCompletion: 300000,
      errorResolution: 200000,
      architecture: 150000,
      thinking: 100000
    },
    cacheEfficiency: 0.68
  };

  const mockCostData = {
    averageRate: 0.002
  };

  test('renders empty state when no data is provided', () => {
    render(<TokenUtilization tokenData={{}} />);

    // Component should render title
    expect(screen.getByText('Token Utilization')).toBeInTheDocument();

    // Should show no data message
    expect(screen.getByText('No token usage data available')).toBeInTheDocument();
  });

  test('renders token utilization with data', () => {
    render(<TokenUtilization tokenData={mockTokenData} costData={mockCostData} />);

    // Check component title
    expect(screen.getByText('Token Utilization')).toBeInTheDocument();

    // Check for the description text
    expect(screen.getByText('Token usage across different categories and overall budget')).toBeInTheDocument();

    // Check for "Overall Budget" with a function to detect the text that might be split across elements
    expect(screen.getByText((content, element) => {
      return element.tagName.toLowerCase() === 'h3' && content.includes('Overall Budget');
    })).toBeInTheDocument();

    // Check for "Budget Categories" heading
    expect(screen.getByText('Budget Categories')).toBeInTheDocument();

    // Check for cache efficiency
    expect(screen.getByText('Cache Efficiency')).toBeInTheDocument();
    expect(screen.getByText((content) => content.includes('Tokens saved through caching'))).toBeInTheDocument();
  });

  test('renders with minimal data', () => {
    // This test uses the most minimal data structure that will not trigger the empty state
    const minimalData = {
      usage: { total: 150000 },
      budgets: { total: 200000 }
    };

    const { container } = render(<TokenUtilization tokenData={minimalData} />);

    // Should render the main component
    expect(screen.getByText('Token Utilization')).toBeInTheDocument();

    // Check for the description text which means we're not seeing the empty state
    expect(screen.getByText('Token usage across different categories and overall budget')).toBeInTheDocument();

    // Look for the usage numbers in the container's text content
    expect(container.textContent).toContain('150,000');
    expect(container.textContent).toContain('200,000');
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
    expect(screen.getByText('Token usage across different categories and overall budget')).toBeInTheDocument();

    // Container should include the usage number
    expect(container.textContent).toContain('100');
  });
});
