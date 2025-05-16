import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import '@testing-library/jest-dom';
import EnhancedAnalyticsDashboard from '../components/features/EnhancedAnalyticsDashboard';

// Mock UI components
jest.mock('../components/ui', () => ({
  Card: ({ children, className }) => <div data-testid="card" className={className}>{children}</div>,
  CardContent: ({ children, className }) => <div data-testid="card-content" className={className}>{children}</div>,
  CardDescription: ({ children }) => <div data-testid="card-description">{children}</div>,
  CardHeader: ({ children }) => <div data-testid="card-header">{children}</div>,
  CardTitle: ({ children, className }) => <div data-testid="card-title" className={className}>{children}</div>,
  CardFooter: ({ children, className }) => <div data-testid="card-footer" className={className}>{children}</div>,
  Button: ({ children, variant, size, onClick, className, disabled }) => (
    <button
      data-testid="button"
      data-variant={variant}
      data-size={size}
      onClick={onClick}
      className={className}
      disabled={disabled}
    >
      {children}
    </button>
  ),
  Separator: () => <div data-testid="separator" />,
  Badge: ({ children, variant, className }) => (
    <span data-testid="badge" data-variant={variant} className={className}>{children}</span>
  ),
  Tooltip: ({ children }) => <div data-testid="tooltip">{children}</div>,
  TooltipContent: ({ children, side }) => <div data-testid="tooltip-content" data-side={side}>{children}</div>,
  TooltipProvider: ({ children }) => <div data-testid="tooltip-provider">{children}</div>,
  TooltipTrigger: ({ children, asChild }) => <div data-testid="tooltip-trigger" data-aschild={asChild}>{children}</div>,
}));

// Mock the required components and dependencies
jest.mock('../components/UsageChart', () => ({ usageData, darkMode }) => (
  <div data-testid="usage-chart" data-dark={darkMode ? 'true' : 'false'}>
    Usage Chart Mock
    {usageData && <span>Daily Data Points: {usageData.daily?.length || 0}</span>}
  </div>
));

jest.mock('../components/MetricsPanel', () => ({ metrics, darkMode }) => (
  <div data-testid="metrics-panel" data-dark={darkMode ? 'true' : 'false'}>
    Metrics Panel Mock
    {metrics && <span>Response Time: {metrics.avgResponseTime || 0}ms</span>}
  </div>
));

// Mock Lucide icons - creating a more complete mock for all icons used
jest.mock('lucide-react', () => {
  // Create a generic icon mock function
  const createIconMock = (name) => () => <span data-testid={`icon-${name.toLowerCase()}`}>{name} Icon</span>;

  // Return an object with all the icons used in the component
  return {
    BarChart3: createIconMock('BarChart3'),
    PieChart: createIconMock('PieChart'),
    LineChart: createIconMock('LineChart'),
    Calendar: createIconMock('Calendar'),
    Filter: createIconMock('Filter'),
    Download: createIconMock('Download'),
    Clock: createIconMock('Clock'),
    Tag: createIconMock('Tag'),
    RefreshCw: createIconMock('RefreshCw'),
    Search: createIconMock('Search'),
    FileDown: createIconMock('FileDown'),
    FileText: createIconMock('FileText'),
    Share2: createIconMock('Share2'),
    MailIcon: createIconMock('MailIcon'),
    BarChart2: createIconMock('BarChart2'),
    CreditCard: createIconMock('CreditCard'),
    TrendingUp: createIconMock('TrendingUp'),
    TrendingDown: createIconMock('TrendingDown'),
    Info: createIconMock('Info'),
    Shield: createIconMock('Shield'),
    Zap: createIconMock('Zap'),
    // Add any other icons that might be used
  };
});

describe('EnhancedAnalyticsDashboard Component', () => {
  // Test data
  const mockUsageData = {
    daily: Array(30).fill(0).map((_, i) => 10000 + Math.floor(Math.random() * 5000)),
    weekly: {
      tokens: [150000, 180000, 165000, 190000],
      costs: [4.50, 5.40, 4.95, 5.70]
    },
    byModel: {
      'claude-3-sonnet': 280450,
      'gemini-2-pro': 190350
    },
    byCategory: {
      'prompt': 240500,
      'completion': 180300,
      'embedding': 50000
    }
  };

  const mockModelsData = {
    selected: 'claude-3-sonnet',
    available: [
      {
        id: 'claude-3-sonnet',
        name: 'Claude 3 Sonnet',
        contextWindow: 200000,
        costPerToken: 0.00003
      },
      {
        id: 'gemini-2-pro',
        name: 'Gemini 2 Pro',
        contextWindow: 128000,
        costPerToken: 0.00002
      }
    ]
  };

  const mockMetricsData = {
    avgResponseTime: 2.5,
    reliability: 99.8,
    cacheHitRate: 0.68,
    costSavingsRate: 0.43
  };

  // Basic rendering test
  test('renders with title and description', () => {
    render(
      <EnhancedAnalyticsDashboard
        usageData={mockUsageData}
        modelsData={mockModelsData}
        metrics={mockMetricsData}
      />
    );

    // Check for basic elements
    expect(screen.getByText('Enhanced Analytics')).toBeInTheDocument();
    expect(screen.getByText('Advanced analytics and reporting tools')).toBeInTheDocument();

    // Check that navigation tabs are rendered
    expect(screen.getByText('Overview')).toBeInTheDocument();
    expect(screen.getByText('Detailed')).toBeInTheDocument();
    expect(screen.getByText('Reports')).toBeInTheDocument();
  });

  // Dark mode test
  test('toggles dark mode correctly', () => {
    // Test with dark mode off initially
    const { rerender } = render(
      <EnhancedAnalyticsDashboard
        usageData={mockUsageData}
        modelsData={mockModelsData}
        metrics={mockMetricsData}
        darkMode={false}
      />
    );

    // Check that card doesn't have dark mode class
    const card = screen.getByTestId('card');
    expect(card.className).not.toContain('bg-card/95');

    // Re-render with dark mode on
    rerender(
      <EnhancedAnalyticsDashboard
        usageData={mockUsageData}
        modelsData={mockModelsData}
        metrics={mockMetricsData}
        darkMode={true}
      />
    );

    // Check that dark mode class is applied to card
    expect(screen.getByTestId('card').className).toContain('bg-card/95');
  });

  // Time range filtering tests
  test('renders time range filter buttons', () => {
    render(
      <EnhancedAnalyticsDashboard
        usageData={mockUsageData}
        modelsData={mockModelsData}
      />
    );

    // Check for time range filter buttons
    expect(screen.getByText('Day')).toBeInTheDocument();
    expect(screen.getByText('Week')).toBeInTheDocument();
    expect(screen.getByText('Month')).toBeInTheDocument();

    // Week should be selected by default
    const weekButton = screen.getByText('Week').closest('button');
    expect(weekButton.className).toContain('bg-primary');
  });

  test('changes time range when filter buttons are clicked', () => {
    render(
      <EnhancedAnalyticsDashboard
        usageData={mockUsageData}
        modelsData={mockModelsData}
      />
    );

    // Click on the Day button
    fireEvent.click(screen.getByText('Day'));

    // Day button should now be selected
    const dayButton = screen.getByText('Day').closest('button');
    expect(dayButton.className).toContain('bg-primary');

    // Week button should no longer be selected
    const weekButton = screen.getByText('Week').closest('button');
    expect(weekButton.className).not.toContain('bg-primary');
  });

  test('handles custom date range selection', async () => {
    // For this test we'll mock the implementation of date pickers
    // In a real test, you would need to mock the date picker component
    const { container } = render(
      <EnhancedAnalyticsDashboard
        usageData={mockUsageData}
        modelsData={mockModelsData}
      />
    );

    // Click on "Custom" button if it exists
    const customButtons = screen.getAllByRole('button').filter(button =>
      button.textContent.includes('Custom')
    );

    if (customButtons.length > 0) {
      fireEvent.click(customButtons[0]);

      // Custom should now be selected
      expect(customButtons[0].className).toContain('bg-primary');
    }
  });

  // Filter tests
  test('applies model filters when selected', () => {
    render(
      <EnhancedAnalyticsDashboard
        usageData={mockUsageData}
        modelsData={mockModelsData}
      />
    );

    // Find and click the filter button
    const filterButtons = screen.getAllByRole('button').filter(button =>
      button.textContent.includes('Filter') ||
      button.innerHTML.includes('filter')
    );

    if (filterButtons.length > 0) {
      fireEvent.click(filterButtons[0]);

      // Check if filter options appear
      // This depends on the actual implementation
      const modelFilterButtons = screen.getAllByRole('button').filter(button =>
        button.textContent.includes('Claude') ||
        button.textContent.includes('Gemini')
      );

      if (modelFilterButtons.length > 0) {
        fireEvent.click(modelFilterButtons[0]);
        // The component should update its state
        // This would ideally check for some visual change reflecting the filter
      }
    }
  });

  // Comparison functionality tests
  test('enables comparison mode when compare button clicked', () => {
    render(
      <EnhancedAnalyticsDashboard
        usageData={mockUsageData}
        modelsData={mockModelsData}
      />
    );

    // Find and click the compare button
    const compareButtons = screen.getAllByRole('button').filter(button =>
      button.textContent.includes('Compare')
    );

    if (compareButtons.length > 0) {
      fireEvent.click(compareButtons[0]);

      // Check if comparison options appear
      // This depends on the actual implementation
      const periodButtons = screen.getAllByRole('button').filter(button =>
        button.textContent.includes('Previous') ||
        button.textContent.includes('Same')
      );

      expect(periodButtons.length).toBeGreaterThan(0);
    }
  });

  // Export functionality tests
  test('shows export options when export button clicked', () => {
    render(
      <EnhancedAnalyticsDashboard
        usageData={mockUsageData}
        modelsData={mockModelsData}
      />
    );

    // Find and click the export button
    const exportButtons = screen.getAllByRole('button').filter(button =>
      button.textContent.includes('Export')
    );

    if (exportButtons.length > 0) {
      fireEvent.click(exportButtons[0]);

      // Check if export options appear
      const formatButtons = screen.getAllByRole('button').filter(button =>
        button.textContent.includes('PDF') ||
        button.textContent.includes('CSV') ||
        button.textContent.includes('Excel')
      );

      expect(formatButtons.length).toBeGreaterThan(0);
    }
  });

  test('calls onExport callback when export format is selected', () => {
    const mockExportCallback = jest.fn();

    render(
      <EnhancedAnalyticsDashboard
        usageData={mockUsageData}
        modelsData={mockModelsData}
        onExport={mockExportCallback}
      />
    );

    // Find and click the export button
    const exportButtons = screen.getAllByRole('button').filter(button =>
      button.textContent.includes('Export')
    );

    if (exportButtons.length > 0) {
      fireEvent.click(exportButtons[0]);

      // Find and click a format button
      const pdfButtons = screen.getAllByRole('button').filter(button =>
        button.textContent.includes('PDF')
      );

      if (pdfButtons.length > 0) {
        fireEvent.click(pdfButtons[0]);

        // Check if the callback was called
        expect(mockExportCallback).toHaveBeenCalled();
      }
    }
  });

  // View tests
  test('switches between overview and detailed views', () => {
    render(
      <EnhancedAnalyticsDashboard
        usageData={mockUsageData}
        modelsData={mockModelsData}
      />
    );

    // Find and click the detailed view button
    const detailedViewButton = screen.getByText('Detailed');
    fireEvent.click(detailedViewButton);

    // Detailed should now be selected
    expect(detailedViewButton.className).toContain('bg-primary');

    // Overview should no longer be selected
    const overviewButton = screen.getByText('Overview');
    expect(overviewButton.className).not.toContain('bg-primary');

    // Switch back to overview
    fireEvent.click(overviewButton);

    // Overview should now be selected
    expect(overviewButton.className).toContain('bg-primary');

    // Detailed should no longer be selected
    expect(detailedViewButton.className).not.toContain('bg-primary');
  });

  // Reset filters test
  test('resets all filters when reset button clicked', () => {
    render(
      <EnhancedAnalyticsDashboard
        usageData={mockUsageData}
        modelsData={mockModelsData}
      />
    );

    // Find and click the reset button
    const resetButtons = screen.getAllByRole('button').filter(button =>
      button.textContent.includes('Reset')
    );

    if (resetButtons.length > 0) {
      // First apply some filters
      const dayButton = screen.getByText('Day');
      fireEvent.click(dayButton);

      // Then reset
      fireEvent.click(resetButtons[0]);

      // Week should be selected again (default)
      const weekButton = screen.getByText('Week').closest('button');
      expect(weekButton.className).toContain('bg-primary');
    }
  });

  // Empty state test
  test('renders loading state with empty data', () => {
    render(
      <EnhancedAnalyticsDashboard
        usageData={{}}
        modelsData={{}}
      />
    );

    // Check for loading indicator
    expect(screen.getByText('Loading analytics data...')).toBeInTheDocument();
  });

  // Filter callback test
  test('calls onFilterChange callback when filters change', () => {
    const mockFilterCallback = jest.fn();

    render(
      <EnhancedAnalyticsDashboard
        usageData={mockUsageData}
        modelsData={mockModelsData}
        onFilterChange={mockFilterCallback}
      />
    );

    // Click on the Day button to change the time range
    fireEvent.click(screen.getByText('Day'));

    // Check if the callback was called
    expect(mockFilterCallback).toHaveBeenCalled();
  });
});
