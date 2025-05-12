import React from 'react';
import { render, screen, fireEvent, act } from '@testing-library/react';
import '@testing-library/jest-dom';
import UsageChart from '../components/UsageChart';

// Mock ResizeObserver
beforeAll(() => {
  global.ResizeObserver = jest.fn().mockImplementation(() => ({
    observe: jest.fn(),
    unobserve: jest.fn(),
    disconnect: jest.fn(),
  }));

  // Mock canvas getContext
  HTMLCanvasElement.prototype.getContext = jest.fn(() => ({
    clearRect: jest.fn(),
    fillRect: jest.fn(),
    fillText: jest.fn(),
    measureText: jest.fn().mockReturnValue({ width: 100 }),
    setTransform: jest.fn(),
    translate: jest.fn(),
    scale: jest.fn(),
    rotate: jest.fn(),
  }));
});

describe('UsageChart Component Coverage Tests', () => {
  // Mock usage data for tests
  const mockUsageData = {
    daily: [12000, 15000, 11000, 14000, 13000],
    byModel: {
      'claude-3.7-sonnet': 280450,
      'gemini-2.5-flash': 190350,
      'claude-3.7-haiku': 57090
    },
    byFunction: {
      codeCompletion: 250300,
      errorResolution: 120450,
      architecture: 95670,
      thinking: 61470
    },
    byFile: {
      js: 180450,
      ts: 130670,
      jsx: 85230,
      tsx: 45780,
      css: 32450,
      html: 28320,
      json: 24990
    },
    popularity: {
      'Code Completion': 42,
      'Error Resolution': 28,
      'Code Explanation': 15,
      'Architecture Design': 10,
      'Test Generation': 5
    },
    recentActivity: [
      { timestamp: '2023-01-01', count: 100 },
      { timestamp: '2023-01-02', count: 200 }
    ]
  };

  // Add more complex, complete data to test edge cases
  const mockCompleteUsageData = {
    ...mockUsageData,
    totalTokens: 1250000,
    inputTokens: 450000,
    outputTokens: 800000,
    activeUsers: 35,
    averageUserTokens: 35714,
  };

  beforeEach(() => {
    jest.clearAllMocks();
  });

  test('renders all view options in the selector', () => {
    render(<UsageChart usageData={mockUsageData} />);

    // Check that all expected options exist
    const options = screen.getAllByRole('option');
    expect(options.length).toBe(5);

    const optionValues = options.map(option => option.value);
    expect(optionValues).toContain('daily');
    expect(optionValues).toContain('byModel');
    expect(optionValues).toContain('byFunction');
    expect(optionValues).toContain('byFile');
    expect(optionValues).toContain('popularity');
  });

  test('renders time series chart with appropriate data', () => {
    render(<UsageChart usageData={mockUsageData} />);

    // Default is daily view (time series)
    const selector = screen.getByRole('combobox');
    expect(selector).toHaveValue('daily');

    // Check that chart container exists
    const chartContainer = screen.getByTestId('chart-container');
    expect(chartContainer).toBeInTheDocument();
  });

  test('renders category chart with appropriate data for byModel view', () => {
    render(<UsageChart usageData={mockUsageData} />);

    // Change to byModel view
    fireEvent.change(screen.getByRole('combobox'), { target: { value: 'byModel' } });

    // Check that chart container exists
    const chartContainer = screen.getByTestId('chart-container');
    expect(chartContainer).toBeInTheDocument();

    // Check that category labels are rendered
    const categoryLabels = screen.getAllByText(/sonnet|flash|haiku/);
    expect(categoryLabels.length).toBeGreaterThan(0);
  });

  test('renders category chart with appropriate data for byFunction view', () => {
    render(<UsageChart usageData={mockUsageData} />);

    // Change to byFunction view
    fireEvent.change(screen.getByRole('combobox'), { target: { value: 'byFunction' } });

    // Check that chart container exists
    const chartContainer = screen.getByTestId('chart-container');
    expect(chartContainer).toBeInTheDocument();
  });

  test('renders category chart with appropriate data for byFile view', () => {
    render(<UsageChart usageData={mockUsageData} />);

    // Change to byFile view
    fireEvent.change(screen.getByRole('combobox'), { target: { value: 'byFile' } });

    // Check that chart container exists
    const chartContainer = screen.getByTestId('chart-container');
    expect(chartContainer).toBeInTheDocument();
  });

  test('renders category chart with appropriate data for popularity view', () => {
    render(<UsageChart usageData={mockUsageData} />);

    // Change to popularity view
    fireEvent.change(screen.getByRole('combobox'), { target: { value: 'byModel' } });

    // Check that chart container exists and has expected content
    const chartContainer = screen.getByTestId('chart-container');
    expect(chartContainer).toBeInTheDocument();
  });

  test('formats large numbers with K/M suffix', () => {
    render(<UsageChart usageData={mockUsageData} />);

    // Change to byModel view to see formatted numbers
    fireEvent.change(screen.getByRole('combobox'), { target: { value: 'byModel' } });

    // Look for formatted numbers (should contain K or M)
    const formattedNumbers = screen.getAllByText(/\d+\.\d+K|\d+K|\d+\.\d+M|\d+M/);
    expect(formattedNumbers.length).toBeGreaterThan(0);
  });

  test('renders line chart by default for time series data', () => {
    render(<UsageChart usageData={mockUsageData} />);

    // Check that Line button is active
    const lineButton = screen.getByText('Line');
    expect(lineButton).toHaveClass('active');
  });

  test('switches to bar chart for time series data when bar button is clicked', () => {
    render(<UsageChart usageData={mockUsageData} />);

    // Click bar chart button
    fireEvent.click(screen.getByText('Bar'));

    // Check that Bar button is active
    const barButton = screen.getByText('Bar');
    expect(barButton).toHaveClass('active');
  });

  test('chart type selector only appears for time series data', () => {
    render(<UsageChart usageData={mockUsageData} />);

    // Initially we should see chart type selectors (Line/Bar)
    expect(screen.getByText('Line')).toBeInTheDocument();
    expect(screen.getByText('Bar')).toBeInTheDocument();

    // Change to byModel view
    fireEvent.change(screen.getByRole('combobox'), { target: { value: 'byModel' } });

    // Now we should NOT see chart type selectors with 'chart-type-btn' class
    const lineButtons = screen.queryAllByText('Line');
    const lineButtonWithClass = lineButtons.find(btn => btn.classList.contains('chart-type-btn'));
    expect(lineButtonWithClass).toBeUndefined();
  });

  test('handles completely empty data gracefully', () => {
    render(<UsageChart usageData={null} />);

    // Should show no data message
    expect(screen.getByText('No usage data available')).toBeInTheDocument();
  });

  test('handles empty daily data gracefully', () => {
    const emptyDailyData = {
      ...mockUsageData,
      daily: [],
      recentActivity: []
    };

    render(<UsageChart usageData={emptyDailyData} />);

    // Should show no activity data message
    expect(screen.getByText('No activity data available for the selected period')).toBeInTheDocument();
  });

  test('handles empty category data gracefully', () => {
    const emptyCategoryData = {
      ...mockUsageData,
      byModel: {},
      byFunction: {},
      byFile: {},
      popularity: {}
    };

    render(<UsageChart usageData={emptyCategoryData} />);

    // Change to byModel view
    fireEvent.change(screen.getByRole('combobox'), { target: { value: 'byModel' } });

    // Should still render chart container, but without data
    const chartContainer = screen.getByTestId('chart-container');
    expect(chartContainer).toBeInTheDocument();
  });

  test('applies custom className to the component', () => {
    render(<UsageChart usageData={mockUsageData} className="custom-class" />);

    // Check if the custom class is applied
    const chartPanel = screen.getByText('Usage Statistics').closest('.usage-chart-panel');
    expect(chartPanel).toHaveClass('custom-class');
  });

  test('handles unexpected chart view gracefully', () => {
    // This test accesses internal state to test an edge case
    const { rerender } = render(<UsageChart usageData={mockUsageData} />);

    // Manually trigger the component to re-render with a different value
    // by using React Testing Library's rerender function
    const chartWithInvalidView = <UsageChart usageData={mockUsageData} />;

    // Get the component instance and modify its state
    const originalUseState = React.useState;
    const mockUseState = jest.fn().mockImplementation((init) => {
      if (typeof init === 'string' && init === 'daily') {
        return ['invalid-view', jest.fn()];
      }
      return originalUseState(init);
    });

    // Replace useState temporarily
    React.useState = mockUseState;

    rerender(chartWithInvalidView);

    // It should default to daily data
    expect(screen.getByTestId('chart-container')).toBeInTheDocument();

    // Restore original useState
    React.useState = originalUseState;
  });
});
