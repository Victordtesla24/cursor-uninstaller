import React from 'react';
import { render, screen } from '@testing-library/react';
// Fix to use only the default export
import UsageStats from '../components/UsageStats.jsx';

describe('UsageStats Component Comprehensive Tests', () => {
  const mockData = {
    daily: [10, 20, 30, 40, 50],
    byModel: {
      'claude-3.7-sonnet': 1000,
      'gemini-2.5-flash': 500,
      'gpt-4': 250
    },
    byFunction: {
      'codeCompletion': 800,
      'debugging': 500,
      'explanation': 300,
      'refactoring': 150
    },
    byFile: {
      'javascript': 700,
      'python': 400,
      'typescript': 300,
      'markdown': 200,
      'json': 100
    },
    popularity: {
      'Code Generation': 1200,
      'Code Explanation': 800,
      'Refactoring': 500,
      'Documentation': 300,
      'Bug Fixing': 200
    }
  };

  test('renders all view modes correctly', () => {
    const { container } = render(<UsageStats usageData={mockData} />);

    // Default view should be daily
    expect(screen.getByText('Daily Token Usage (Last 30 Days)')).toBeInTheDocument();

    // Switch to breakdown view by clicking the button
    const breakdownTab = Array.from(container.querySelectorAll('.view-tab')).find(
      tab => tab.textContent === 'Breakdown'
    );
    breakdownTab.click();

    expect(screen.getByText('Usage by Model')).toBeInTheDocument();
    expect(screen.getByText('Usage by Function')).toBeInTheDocument();
    expect(screen.getByText('Usage by File Type')).toBeInTheDocument();

    // Switch to popularity view by clicking the button
    const popularityTab = Array.from(container.querySelectorAll('.view-tab')).find(
      tab => tab.textContent === 'Popularity'
    );
    popularityTab.click();

    expect(screen.getByText('Feature Popularity')).toBeInTheDocument();
  });

  test('renders all chart types in breakdown view', () => {
    const { container } = render(<UsageStats usageData={mockData} />);

    // Switch to breakdown view
    const breakdownTab = Array.from(container.querySelectorAll('.view-tab')).find(
      tab => tab.textContent === 'Breakdown'
    );
    breakdownTab.click();

    // Check model breakdown
    expect(screen.getByText('Usage by Model')).toBeInTheDocument();
    expect(screen.getByText('claude-3.7-sonnet')).toBeInTheDocument();
    expect(screen.getByText('gemini-2.5-flash')).toBeInTheDocument();
    expect(screen.getByText('gpt-4')).toBeInTheDocument();

    // Check function breakdown - display names have first letter capitalized
    expect(screen.getByText('Usage by Function')).toBeInTheDocument();
    expect(screen.getByText('CodeCompletion')).toBeInTheDocument();
    expect(screen.getByText('Debugging')).toBeInTheDocument();
    expect(screen.getByText('Explanation')).toBeInTheDocument();
    expect(screen.getByText('Refactoring')).toBeInTheDocument();

    // Check file type breakdown
    expect(screen.getByText('Usage by File Type')).toBeInTheDocument();
    expect(screen.getByText('javascript')).toBeInTheDocument();
    expect(screen.getByText('python')).toBeInTheDocument();
    expect(screen.getByText('typescript')).toBeInTheDocument();
    expect(screen.getByText('markdown')).toBeInTheDocument();
    expect(screen.getByText('json')).toBeInTheDocument();
  });

  test('renders popularity chart correctly', () => {
    const { container } = render(<UsageStats usageData={mockData} />);

    // Switch to popularity view
    const popularityTab = Array.from(container.querySelectorAll('.view-tab')).find(
      tab => tab.textContent === 'Popularity'
    );
    popularityTab.click();

    // Check popularity chart
    expect(screen.getByText('Feature Popularity')).toBeInTheDocument();
    expect(screen.getByText('Code Generation')).toBeInTheDocument();
    expect(screen.getByText('Code Explanation')).toBeInTheDocument();
    expect(screen.getByText('Refactoring')).toBeInTheDocument();
    expect(screen.getByText('Documentation')).toBeInTheDocument();
    expect(screen.getByText('Bug Fixing')).toBeInTheDocument();
  });

  test('calculates percentages correctly', () => {
    const { container } = render(<UsageStats usageData={mockData} />);

    // Switch to breakdown view to see percentages
    const breakdownTab = Array.from(container.querySelectorAll('.view-tab')).find(
      tab => tab.textContent === 'Breakdown'
    );
    breakdownTab.click();

    // Check that there are percentage elements
    // Don't test exact count as it can be implementation-dependent
    const percentageElements = container.querySelectorAll('.breakdown-percentage');
    expect(percentageElements.length).toBeGreaterThan(0);

    // Verify the specific percentages for key models
    expect(screen.getByText('57%')).toBeInTheDocument();
  });

  test('formats numbers with comma separators', () => {
    const largeNumberData = {
      ...mockData,
      byModel: {
        'claude-3.7-sonnet': 1000000,
        'gemini-2.5-flash': 500000
      }
    };

    const { container } = render(<UsageStats usageData={largeNumberData} />);

    // Switch to breakdown view
    const breakdownTab = Array.from(container.querySelectorAll('.view-tab')).find(
      tab => tab.textContent === 'Breakdown'
    );
    breakdownTab.click();

    // Check formatted numbers
    expect(screen.getByText('1,000,000')).toBeInTheDocument();
    expect(screen.getByText('500,000')).toBeInTheDocument();
  });

  test('applies custom class name', () => {
    const { container } = render(<UsageStats usageData={mockData} className="custom-class" />);
    expect(container.firstChild).toHaveClass('custom-class');
  });

  test('handles empty data sections gracefully', () => {
    const partialData = {
      daily: [10, 20, 30],
      // Missing byModel, byFunction, byFile, and popularity
    };

    const { container } = render(<UsageStats usageData={partialData} />);

    // Daily view should work
    expect(screen.getByText('Daily Token Usage (Last 30 Days)')).toBeInTheDocument();

    // Switch to breakdown view - should render without crashing
    const breakdownTab = Array.from(container.querySelectorAll('.view-tab')).find(
      tab => tab.textContent === 'Breakdown'
    );
    breakdownTab.click();

    // Switch to popularity view - should render without crashing
    const popularityTab = Array.from(container.querySelectorAll('.view-tab')).find(
      tab => tab.textContent === 'Popularity'
    );
    popularityTab.click();
  });

  test('handles zero values in charts', () => {
    const zeroData = {
      daily: [0, 0, 0, 0, 0],
      byModel: {
        'claude-3.7-sonnet': 0,
        'gemini-2.5-flash': 0
      }
    };

    const { container } = render(<UsageStats usageData={zeroData} />);
    expect(screen.getByText('Daily Token Usage (Last 30 Days)')).toBeInTheDocument();

    // Switch to breakdown view
    const breakdownTab = Array.from(container.querySelectorAll('.view-tab')).find(
      tab => tab.textContent === 'Breakdown'
    );
    breakdownTab.click();

    expect(screen.getByText('Usage by Model')).toBeInTheDocument();

    // Should show 0%
    const percentages = container.querySelectorAll('.breakdown-percentage');
    expect(percentages.length).toBeGreaterThan(0);
    expect(Array.from(percentages).some(el => el.textContent === '0%')).toBe(true);
  });

  test('handles empty arrays and objects', () => {
    const emptyData = {
      daily: [],
      byModel: {},
      byFunction: {},
      byFile: {},
      popularity: {}
    };

    const { container } = render(<UsageStats usageData={emptyData} />);

    // Switch to breakdown view
    const breakdownTab = Array.from(container.querySelectorAll('.view-tab')).find(
      tab => tab.textContent === 'Breakdown'
    );
    breakdownTab.click();

    // Switch to popularity view
    const popularityTab = Array.from(container.querySelectorAll('.view-tab')).find(
      tab => tab.textContent === 'Popularity'
    );
    popularityTab.click();

    // No charts should be rendered, but component should not crash
    expect(screen.queryByText('Daily Token Usage (Last 30 Days)')).not.toBeInTheDocument();
    expect(screen.queryByText('Usage by Model')).not.toBeInTheDocument();
    expect(screen.queryByText('Feature Popularity')).not.toBeInTheDocument();
  });

  test('renders correctly when no data is provided', () => {
    const { container } = render(<UsageStats />);

    // Check for empty state message
    expect(screen.getByText('No usage data available yet')).toBeInTheDocument();

    // Should not have view tabs when no data is provided
    expect(container.querySelector('.view-tabs')).toBeNull();
  });
});
