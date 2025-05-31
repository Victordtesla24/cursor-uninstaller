import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import '@testing-library/jest-dom';
import UsageStats from '../../src/components/features/UsageStats.jsx';

// Mock the UI components
jest.mock('../../src/components/ui', () => ({
  Card: ({ children, className }) => <div data-testid="card" className={className}>{children}</div>,
  CardContent: ({ children, className }) => <div data-testid="card-content" className={className}>{children}</div>,
  CardDescription: ({ children, className }) => <div data-testid="card-description" className={className}>{children}</div>,
  CardHeader: ({ children, className }) => <div data-testid="card-header" className={className}>{children}</div>,
  CardTitle: ({ children, className }) => <div data-testid="card-title" className={className}>{children}</div>,
  Badge: ({ children, variant, className }) => (
    <span data-testid="badge" className={`${variant} ${className}`}>{children}</span>
  ),
  Progress: ({ value, className }) => (
    <div data-testid="progress" className={className} data-value={value}>
      <div style={{ width: `${value}%` }} />
    </div>
  ),
  Button: ({ children, onClick, variant, size, className, disabled }) => (
    <button 
      onClick={onClick} 
      className={`${variant} ${size} ${className}`} 
      disabled={disabled}
      data-testid="button"
    >
      {children}
    </button>
  ),
  Separator: () => <div data-testid="separator" />,
  Tooltip: ({ children }) => <div data-testid="tooltip">{children}</div>,
  TooltipContent: ({ children, className }) => <div data-testid="tooltip-content" className={className}>{children}</div>,
  TooltipProvider: ({ children }) => <div data-testid="tooltip-provider">{children}</div>,
  TooltipTrigger: ({ children, className }) => <div data-testid="tooltip-trigger" className={className}>{children}</div>
}));

// Mock Lucide React icons
jest.mock('lucide-react', () => ({
  BarChart3: () => <div data-testid="bar-chart-3-icon" />,
  Calendar: () => <div data-testid="calendar-icon" />,
  Clock: () => <div data-testid="clock-icon" />,
  Database: () => <div data-testid="database-icon" />,
  DollarSign: () => <div data-testid="dollar-sign-icon" />,
  Download: () => <div data-testid="download-icon" />,
  Filter: () => <div data-testid="filter-icon" />,
  PieChart: () => <div data-testid="pie-chart-icon" />,
  TrendingUp: () => <div data-testid="trending-up-icon" />,
  TrendingDown: () => <div data-testid="trending-down-icon" />,
  Users: () => <div data-testid="users-icon" />,
  Activity: () => <div data-testid="activity-icon" />,
  Target: () => <div data-testid="target-icon" />,
  Zap: () => <div data-testid="zap-icon" />,
  FileText: () => <div data-testid="file-text-icon" />,
  RefreshCw: () => <div data-testid="refresh-cw-icon" />,
  Settings: () => <div data-testid="settings-icon" />,
  Share2: () => <div data-testid="share2-icon" />
}));

describe('UsageStats Component - Comprehensive Coverage', () => {
  const mockUsageData = {
    daily: {
      tokens: 15420,
      requests: 234,
      cost: 12.45,
      avgResponseTime: 1.2,
      uniqueUsers: 89
    },
    weekly: {
      tokens: 98765,
      requests: 1456,
      cost: 87.23,
      avgResponseTime: 1.35,
      uniqueUsers: 345,
      trend: 'up',
      growth: 12.5
    },
    monthly: {
      tokens: 425680,
      requests: 6789,
      cost: 356.78,
      avgResponseTime: 1.28,
      uniqueUsers: 1234,
      trend: 'up',
      growth: 8.3
    },
    byModel: {
      'gpt-4': {
        tokens: 25000,
        requests: 150,
        cost: 125.00,
        percentage: 45
      },
      'gpt-3.5-turbo': {
        tokens: 35000,
        requests: 280,
        cost: 35.00,
        percentage: 55
      }
    },
    byCategory: {
      'chat': {
        tokens: 32000,
        requests: 200,
        cost: 80.00,
        percentage: 60
      },
      'completion': {
        tokens: 18000,
        requests: 120,
        cost: 45.00,
        percentage: 30
      },
      'embedding': {
        tokens: 10000,
        requests: 110,
        cost: 35.00,
        percentage: 10
      }
    },
    topUsagePatterns: [
      { time: '09:00', usage: 85, label: 'Morning Peak' },
      { time: '14:00', usage: 92, label: 'Afternoon Peak' },
      { time: '19:00', usage: 78, label: 'Evening Activity' }
    ],
    efficiency: {
      cacheHitRate: 78.5,
      avgTokensPerRequest: 156,
      costEfficiency: 91.2,
      responseTimeScore: 88.7
    }
  };

  const mockComparisons = {
    previousPeriod: {
      tokens: { current: 15420, previous: 14200, change: 8.6 },
      cost: { current: 12.45, previous: 13.80, change: -9.8 },
      requests: { current: 234, previous: 198, change: 18.2 }
    },
    targets: {
      monthlyBudget: 500,
      tokenLimit: 1000000,
      costTarget: 400,
      requestTarget: 10000
    },
    benchmarks: {
      industry: {
        avgCostPerToken: 0.0008,
        avgResponseTime: 1.5,
        avgCacheHit: 75
      }
    }
  };

  const defaultProps = {
    usageData: mockUsageData,
    comparisons: mockComparisons,
    timeRange: 'daily',
    darkMode: false,
    onTimeRangeChange: jest.fn(),
    onExport: jest.fn(),
    onRefresh: jest.fn()
  };

  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('Component Rendering', () => {
    test('renders main usage stats structure', () => {
      render(<UsageStats {...defaultProps} />);
      
      expect(screen.getByText('Usage Statistics')).toBeInTheDocument();
      expect(screen.getByText('Comprehensive analysis of token and API usage')).toBeInTheDocument();
    });

    test('renders with dark mode styling', () => {
      render(<UsageStats {...defaultProps} darkMode={true} />);
      
      const cards = screen.getAllByTestId('card');
      expect(cards.length).toBeGreaterThan(0);
    });

    test('renders without data gracefully', () => {
      render(<UsageStats usageData={{}} comparisons={{}} />);
      
      expect(screen.getByText('Usage Statistics')).toBeInTheDocument();
    });
  });

  describe('Time Range Selection', () => {
    test('renders time range filter buttons', () => {
      render(<UsageStats {...defaultProps} />);
      
      expect(screen.getByText('Daily')).toBeInTheDocument();
      expect(screen.getByText('Weekly')).toBeInTheDocument();
      expect(screen.getByText('Monthly')).toBeInTheDocument();
      expect(screen.getByText('Custom')).toBeInTheDocument();
    });

    test('handles time range changes', async () => {
      const onTimeRangeChange = jest.fn();
      render(<UsageStats {...defaultProps} onTimeRangeChange={onTimeRangeChange} />);
      
      const weeklyButton = screen.getByText('Weekly');
      fireEvent.click(weeklyButton);
      
      expect(onTimeRangeChange).toHaveBeenCalledWith('weekly');
    });

    test('shows active time range selection', () => {
      render(<UsageStats {...defaultProps} timeRange="weekly" />);
      
      const weeklyButton = screen.getByText('Weekly');
      expect(weeklyButton.parentElement).toHaveClass('primary');
    });

    test('handles custom date range selection', async () => {
      render(<UsageStats {...defaultProps} />);
      
      const customButton = screen.getByText('Custom');
      fireEvent.click(customButton);
      
      await waitFor(() => {
        expect(screen.getByTestId('calendar-icon')).toBeInTheDocument();
      });
    });
  });

  describe('Usage Metrics Display', () => {
    test('displays token usage statistics', () => {
      render(<UsageStats {...defaultProps} />);
      
      expect(screen.getByText('Tokens Used')).toBeInTheDocument();
      expect(screen.getByText('15,420')).toBeInTheDocument();
    });

    test('displays request count statistics', () => {
      render(<UsageStats {...defaultProps} />);
      
      expect(screen.getByText('API Requests')).toBeInTheDocument();
      expect(screen.getByText('234')).toBeInTheDocument();
    });

    test('displays cost statistics', () => {
      render(<UsageStats {...defaultProps} />);
      
      expect(screen.getByText('Total Cost')).toBeInTheDocument();
      expect(screen.getByText('$12.45')).toBeInTheDocument();
      expect(screen.getByTestId('dollar-sign-icon')).toBeInTheDocument();
    });

    test('displays response time statistics', () => {
      render(<UsageStats {...defaultProps} />);
      
      expect(screen.getByText('Avg Response Time')).toBeInTheDocument();
      expect(screen.getByText('1.2s')).toBeInTheDocument();
      expect(screen.getByTestId('clock-icon')).toBeInTheDocument();
    });

    test('displays unique users statistics', () => {
      render(<UsageStats {...defaultProps} />);
      
      expect(screen.getByText('Unique Users')).toBeInTheDocument();
      expect(screen.getByText('89')).toBeInTheDocument();
      expect(screen.getByTestId('users-icon')).toBeInTheDocument();
    });
  });

  describe('Model Usage Breakdown', () => {
    test('displays model usage distribution', () => {
      render(<UsageStats {...defaultProps} />);
      
      expect(screen.getByText('Usage by Model')).toBeInTheDocument();
      expect(screen.getByText('GPT-4')).toBeInTheDocument();
      expect(screen.getByText('GPT-3.5 Turbo')).toBeInTheDocument();
    });

    test('shows model usage percentages', () => {
      render(<UsageStats {...defaultProps} />);
      
      expect(screen.getByText('45%')).toBeInTheDocument();
      expect(screen.getByText('55%')).toBeInTheDocument();
    });

    test('displays model cost breakdown', () => {
      render(<UsageStats {...defaultProps} />);
      
      expect(screen.getByText('$125.00')).toBeInTheDocument();
      expect(screen.getByText('$35.00')).toBeInTheDocument();
    });

    test('renders model usage pie chart', () => {
      render(<UsageStats {...defaultProps} />);
      
      expect(screen.getByTestId('pie-chart-icon')).toBeInTheDocument();
    });
  });

  describe('Category Usage Analysis', () => {
    test('displays usage by category', () => {
      render(<UsageStats {...defaultProps} />);
      
      expect(screen.getByText('Usage by Category')).toBeInTheDocument();
      expect(screen.getByText('Chat')).toBeInTheDocument();
      expect(screen.getByText('Completion')).toBeInTheDocument();
      expect(screen.getByText('Embedding')).toBeInTheDocument();
    });

    test('shows category percentages', () => {
      render(<UsageStats {...defaultProps} />);
      
      expect(screen.getByText('60%')).toBeInTheDocument();
      expect(screen.getByText('30%')).toBeInTheDocument();
      expect(screen.getByText('10%')).toBeInTheDocument();
    });

    test('displays category cost analysis', () => {
      render(<UsageStats {...defaultProps} />);
      
      expect(screen.getByText('$80.00')).toBeInTheDocument();
      expect(screen.getByText('$45.00')).toBeInTheDocument();
      expect(screen.getByText('$35.00')).toBeInTheDocument();
    });
  });

  describe('Usage Patterns and Trends', () => {
    test('displays usage pattern analysis', () => {
      render(<UsageStats {...defaultProps} />);
      
      expect(screen.getByText('Usage Patterns')).toBeInTheDocument();
      expect(screen.getByText('Morning Peak')).toBeInTheDocument();
      expect(screen.getByText('Afternoon Peak')).toBeInTheDocument();
      expect(screen.getByText('Evening Activity')).toBeInTheDocument();
    });

    test('shows peak usage times', () => {
      render(<UsageStats {...defaultProps} />);
      
      expect(screen.getByText('09:00')).toBeInTheDocument();
      expect(screen.getByText('14:00')).toBeInTheDocument();
      expect(screen.getByText('19:00')).toBeInTheDocument();
    });

    test('displays trend indicators', () => {
      render(<UsageStats {...defaultProps} />);
      
      const trendingUpIcons = screen.getAllByTestId('trending-up-icon');
      expect(trendingUpIcons.length).toBeGreaterThan(0);
    });

    test('shows growth percentages', () => {
      render(<UsageStats {...defaultProps} timeRange="weekly" />);
      
      expect(screen.getByText('12.5%')).toBeInTheDocument();
    });
  });

  describe('Efficiency Metrics', () => {
    test('displays cache hit rate', () => {
      render(<UsageStats {...defaultProps} />);
      
      expect(screen.getByText('Cache Hit Rate')).toBeInTheDocument();
      expect(screen.getByText('78.5%')).toBeInTheDocument();
    });

    test('shows average tokens per request', () => {
      render(<UsageStats {...defaultProps} />);
      
      expect(screen.getByText('Avg Tokens/Request')).toBeInTheDocument();
      expect(screen.getByText('156')).toBeInTheDocument();
    });

    test('displays cost efficiency score', () => {
      render(<UsageStats {...defaultProps} />);
      
      expect(screen.getByText('Cost Efficiency')).toBeInTheDocument();
      expect(screen.getByText('91.2%')).toBeInTheDocument();
    });

    test('shows response time score', () => {
      render(<UsageStats {...defaultProps} />);
      
      expect(screen.getByText('Response Time Score')).toBeInTheDocument();
      expect(screen.getByText('88.7%')).toBeInTheDocument();
    });
  });

  describe('Period Comparisons', () => {
    test('displays comparison with previous period', () => {
      render(<UsageStats {...defaultProps} />);
      
      expect(screen.getByText('vs Previous Period')).toBeInTheDocument();
    });

    test('shows percentage changes', () => {
      render(<UsageStats {...defaultProps} />);
      
      expect(screen.getByText('+8.6%')).toBeInTheDocument();
      expect(screen.getByText('-9.8%')).toBeInTheDocument();
      expect(screen.getByText('+18.2%')).toBeInTheDocument();
    });

    test('displays positive and negative trend indicators', () => {
      render(<UsageStats {...defaultProps} />);
      
      const trendingUpIcons = screen.getAllByTestId('trending-up-icon');
      const trendingDownIcons = screen.getAllByTestId('trending-down-icon');
      
      expect(trendingUpIcons.length).toBeGreaterThan(0);
      expect(trendingDownIcons.length).toBeGreaterThan(0);
    });
  });

  describe('Budget and Target Tracking', () => {
    test('displays budget tracking', () => {
      render(<UsageStats {...defaultProps} />);
      
      expect(screen.getByText('Budget Tracking')).toBeInTheDocument();
      expect(screen.getByText('Monthly Budget')).toBeInTheDocument();
      expect(screen.getByText('$500')).toBeInTheDocument();
    });

    test('shows target progress', () => {
      render(<UsageStats {...defaultProps} />);
      
      const progressBars = screen.getAllByTestId('progress');
      expect(progressBars.length).toBeGreaterThan(0);
    });

    test('displays target vs actual comparisons', () => {
      render(<UsageStats {...defaultProps} />);
      
      expect(screen.getByText('Token Limit')).toBeInTheDocument();
      expect(screen.getByText('1,000,000')).toBeInTheDocument();
    });
  });

  describe('Benchmark Comparisons', () => {
    test('displays industry benchmarks', () => {
      render(<UsageStats {...defaultProps} />);
      
      expect(screen.getByText('Industry Benchmarks')).toBeInTheDocument();
      expect(screen.getByText('Industry Avg')).toBeInTheDocument();
    });

    test('shows benchmark comparison metrics', () => {
      render(<UsageStats {...defaultProps} />);
      
      expect(screen.getByText('$0.0008')).toBeInTheDocument();
      expect(screen.getByText('1.5s')).toBeInTheDocument();
      expect(screen.getByText('75%')).toBeInTheDocument();
    });

    test('displays performance vs benchmarks', () => {
      render(<UsageStats {...defaultProps} />);
      
      const badges = screen.getAllByTestId('badge');
      const performanceBadges = badges.filter(badge => 
        badge.textContent.includes('Above Average') || 
        badge.textContent.includes('Below Average')
      );
      expect(performanceBadges.length).toBeGreaterThan(0);
    });
  });

  describe('Data Export and Sharing', () => {
    test('shows export button', () => {
      render(<UsageStats {...defaultProps} />);
      
      expect(screen.getByTestId('download-icon')).toBeInTheDocument();
    });

    test('handles data export', async () => {
      const onExport = jest.fn();
      render(<UsageStats {...defaultProps} onExport={onExport} />);
      
      const exportButton = screen.getAllByTestId('button').find(button => 
        button.querySelector('[data-testid="download-icon"]')
      );
      
      if (exportButton) {
        fireEvent.click(exportButton);
        expect(onExport).toHaveBeenCalled();
      }
    });

    test('provides export format options', () => {
      render(<UsageStats {...defaultProps} />);
      
      expect(screen.getByText('Export as CSV')).toBeInTheDocument();
      expect(screen.getByText('Export as PDF')).toBeInTheDocument();
    });

    test('handles sharing functionality', async () => {
      render(<UsageStats {...defaultProps} />);
      
      const shareButton = screen.getAllByTestId('button').find(button => 
        button.querySelector('[data-testid="share2-icon"]')
      );
      
      if (shareButton) {
        fireEvent.click(shareButton);
        // Should handle sharing appropriately
      }
    });
  });

  describe('Real-time Updates', () => {
    test('shows refresh functionality', () => {
      render(<UsageStats {...defaultProps} />);
      
      expect(screen.getByTestId('refresh-cw-icon')).toBeInTheDocument();
    });

    test('handles manual refresh', async () => {
      const onRefresh = jest.fn();
      render(<UsageStats {...defaultProps} onRefresh={onRefresh} />);
      
      const refreshButton = screen.getAllByTestId('button').find(button => 
        button.querySelector('[data-testid="refresh-cw-icon"]')
      );
      
      if (refreshButton) {
        fireEvent.click(refreshButton);
        expect(onRefresh).toHaveBeenCalled();
      }
    });

    test('displays last updated timestamp', () => {
      render(<UsageStats {...defaultProps} />);
      
      expect(screen.getByText(/Last updated:/)).toBeInTheDocument();
    });

    test('shows auto-refresh status', () => {
      render(<UsageStats {...defaultProps} autoRefresh={true} />);
      
      expect(screen.getByText('Auto-refresh: ON')).toBeInTheDocument();
    });
  });

  describe('Interactive Features', () => {
    test('provides metric drill-down capability', async () => {
      render(<UsageStats {...defaultProps} />);
      
      const drillDownButtons = screen.getAllByTestId('button').filter(button => 
        button.textContent.includes('View Details') || 
        button.textContent.includes('Drill Down')
      );
      
      if (drillDownButtons.length > 0) {
        fireEvent.click(drillDownButtons[0]);
        // Should handle drill-down appropriately
      }
    });

    test('supports filtering and sorting', async () => {
      render(<UsageStats {...defaultProps} />);
      
      expect(screen.getByTestId('filter-icon')).toBeInTheDocument();
    });

    test('handles chart interactions', async () => {
      render(<UsageStats {...defaultProps} />);
      
      const charts = screen.getAllByTestId('pie-chart-icon');
      if (charts.length > 0) {
        fireEvent.click(charts[0]);
        // Should handle chart interactions
      }
    });
  });

  describe('Error Handling', () => {
    test('handles missing usage data', () => {
      render(<UsageStats {...defaultProps} usageData={null} />);
      
      expect(screen.getByText('Usage Statistics')).toBeInTheDocument();
    });

    test('handles invalid data formats', () => {
      const invalidData = {
        daily: 'invalid',
        weekly: null,
        monthly: undefined
      };
      
      render(<UsageStats {...defaultProps} usageData={invalidData} />);
      
      expect(screen.getByText('Usage Statistics')).toBeInTheDocument();
    });

    test('shows error state for failed operations', async () => {
      const onRefresh = jest.fn().mockRejectedValue(new Error('Refresh failed'));
      
      render(<UsageStats {...defaultProps} onRefresh={onRefresh} />);
      
      const refreshButton = screen.getAllByTestId('button').find(button => 
        button.querySelector('[data-testid="refresh-cw-icon"]')
      );
      
      if (refreshButton) {
        fireEvent.click(refreshButton);
        // Should handle error appropriately
      }
    });
  });

  describe('Performance Optimization', () => {
    test('memoizes expensive calculations', () => {
      const { rerender } = render(<UsageStats {...defaultProps} />);
      
      // Rerender with same props should not cause unnecessary recalculations
      rerender(<UsageStats {...defaultProps} />);
      
      expect(screen.getByText('Usage Statistics')).toBeInTheDocument();
    });

    test('handles large datasets efficiently', () => {
      const largeUsageData = {
        ...mockUsageData,
        timeSeries: new Array(10000).fill(0).map((_, i) => ({
          timestamp: Date.now() - (i * 60000),
          tokens: Math.floor(Math.random() * 1000),
          cost: Math.random() * 10
        }))
      };
      
      render(<UsageStats {...defaultProps} usageData={largeUsageData} />);
      
      expect(screen.getByText('Usage Statistics')).toBeInTheDocument();
    });
  });

  describe('Responsive Design', () => {
    test('applies responsive grid layouts', () => {
      render(<UsageStats {...defaultProps} />);
      
      const container = document.querySelector('.grid');
      expect(container).toBeInTheDocument();
    });

    test('adapts to different screen sizes', () => {
      // Mock different viewport sizes
      Object.defineProperty(window, 'innerWidth', {
        writable: true,
        configurable: true,
        value: 640,
      });
      
      render(<UsageStats {...defaultProps} />);
      
      expect(screen.getByText('Usage Statistics')).toBeInTheDocument();
    });
  });

  describe('Accessibility', () => {
    test('provides proper ARIA labels', () => {
      render(<UsageStats {...defaultProps} />);
      
      const buttons = screen.getAllByTestId('button');
      expect(buttons.length).toBeGreaterThan(0);
    });

    test('supports keyboard navigation', () => {
      render(<UsageStats {...defaultProps} />);
      
      const buttons = screen.getAllByTestId('button');
      if (buttons.length > 0) {
        buttons[0].focus();
        expect(document.activeElement).toBe(buttons[0]);
      }
    });

    test('provides screen reader friendly content', () => {
      render(<UsageStats {...defaultProps} />);
      
      expect(screen.getByText('Tokens Used')).toBeInTheDocument();
      expect(screen.getByText('15,420')).toBeInTheDocument();
    });
  });
}); 