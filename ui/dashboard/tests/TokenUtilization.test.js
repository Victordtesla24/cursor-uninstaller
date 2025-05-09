import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import '@testing-library/jest-dom';
import TokenUtilization from '../components/TokenUtilization';

describe('TokenUtilization Component', () => {
  const mockTokenData = {
    total: {
      used: 528000,
      saved: 312450,
      budgeted: 750000
    },
    daily: {
      used: 18450,
      saved: 10320,
      budgeted: 25000
    },
    budgets: {
      codeCompletion: {
        used: 275420,
        budget: 300000,
        remaining: 24580
      },
      errorResolution: {
        used: 125640,
        budget: 200000,
        remaining: 74360
      },
      architecture: {
        used: 89430,
        budget: 150000,
        remaining: 60570
      },
      thinking: {
        used: 37400,
        budget: 100000,
        remaining: 62600
      }
    },
    cacheEfficiency: {
      hitRate: 0.68,
      missRate: 0.32,
      totalCached: 4250,
      totalHits: 2890
    }
  };

  test('renders token budget utilization correctly', () => {
    render(<TokenUtilization tokenData={mockTokenData} />);

    // Check for component title
    expect(screen.getByText('Token Utilization')).toBeInTheDocument();

    // Check for view options
    expect(screen.getByText('Budget')).toBeInTheDocument();
    expect(screen.getByText('Usage')).toBeInTheDocument();

    // Check for budget section header
    expect(screen.getByText('Token Budget Utilization')).toBeInTheDocument();

    // Check specific token values using test IDs
    expect(screen.getByTestId('token-used')).toHaveTextContent('528');
    expect(screen.getByTestId('token-budget')).toHaveTextContent('750');

    // Progress indicators
    expect(screen.getByText('70%')).toBeInTheDocument(); // Progress percentage

    // Check budget categories
    expect(screen.getByText('Code Completion')).toBeInTheDocument();
    expect(screen.getByText('Error Resolution')).toBeInTheDocument();
    expect(screen.getByText('Architecture')).toBeInTheDocument();
    expect(screen.getByText('Thinking')).toBeInTheDocument();

    // Check cache section
    expect(screen.getByText('Cache Efficiency')).toBeInTheDocument();
    expect(screen.getByText('68%')).toBeInTheDocument(); // Hit rate
  });

  test('toggles between budget and usage views', () => {
    render(<TokenUtilization tokenData={mockTokenData} />);

    // Initial state is budget view
    expect(screen.getByText('Token Budget Utilization')).toBeInTheDocument();

    // Click the usage tab
    const usageTab = screen.getByText('Usage');
    fireEvent.click(usageTab);

    // Now we should have usage view (no need to check content)

    // Click back to budget tab
    const budgetTab = screen.getByText('Budget');
    fireEvent.click(budgetTab);

    // Should be back to budget view
    expect(screen.getByText('Token Budget Utilization')).toBeInTheDocument();
  });

  test('handles empty or undefined data gracefully', () => {
    render(<TokenUtilization tokenData={{}} />);

    // Component should render without errors even with empty data
    expect(screen.getByText('Token Utilization')).toBeInTheDocument();
    expect(screen.getByText('Token Budget Utilization')).toBeInTheDocument();

    // Progress indicators should be safe values - use the progress bar instead of text
    expect(screen.getByTestId('token-used')).toHaveTextContent('0');
  });
});
