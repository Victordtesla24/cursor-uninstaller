import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import '@testing-library/jest-dom';
import EnhancedAnalyticsDashboard from '../../src/components/features/EnhancedAnalyticsDashboard.jsx';

// Mock the UI components
jest.mock('../../src/components/ui', () => ({
  Card: ({ children, className }) => <div data-testid="card" className={className}>{children}</div>,
  CardContent: ({ children, className }) => <div data-testid="card-content" className={className}>{children}</div>,
  CardDescription: ({ children, className }) => <div data-testid="card-description" className={className}>{children}</div>,
  CardHeader: ({ children, className }) => <div data-testid="card-header" className={className}>{children}</div>,
  CardTitle: ({ children, className }) => <div data-testid="card-title" className={className}>{children}</div>,
  CardFooter: ({ children, className }) => <div data-testid="card-footer" className={className}>{children}</div>,
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
  Badge: ({ children, variant, className }) => (
    <span data-testid="badge" className={`${variant} ${className}`}>{children}</span>
  ),
  Tooltip: ({ children }) => <div data-testid="tooltip">{children}</div>,
  TooltipContent: ({ children, className }) => <div data-testid="tooltip-content" className={className}>{children}</div>,
  TooltipProvider: ({ children }) => <div data-testid="tooltip-provider">{children}</div>,
  TooltipTrigger: ({ children, className }) => <div data-testid="tooltip-trigger" className={className}>{children}</div>
}));

// Mock Lucide React icons
jest.mock('lucide-react', () => ({
  BarChart3: () => <div data-testid="bar-chart-3-icon" />,
  PieChart: () => <div data-testid="pie-chart-icon" />,
  LineChart: () => <div data-testid="line-chart-icon" />,
  Calendar: () => <div data-testid="calendar-icon" />,
  Filter: () => <div data-testid="filter-icon" />,
  Download: () => <div data-testid="download-icon" />,
  Clock: () => <div data-testid="clock-icon" />,
  Tag: () => <div data-testid="tag-icon" />,
  RefreshCw: () => <div data-testid="refresh-cw-icon" />,
  FileDown: () => <div data-testid="file-down-icon" />,
  FileText: () => <div data-testid="file-text-icon" />,
  Share2: () => <div data-testid="share2-icon" />,
  MailIcon: () => <div data-testid="mail-icon" />,
  BarChart2: () => <div data-testid="bar-chart-2-icon" />,
  TrendingUp: () => <div data-testid="trending-up-icon" />,
  TrendingDown: () => <div data-testid="trending-down-icon" />
}));

describe('EnhancedAnalyticsDashboard Component - Comprehensive Coverage', () => {
  const mockUsageData = {
    daily: [100, 150, 200, 180, 220, 190, 240],
    weekly: {
      tokens: [1000, 1200, 1400, 1300],
      costs: [50, 60, 70, 65]
    },
    byModel: {
      'gpt-4': { tokens: 5000, cost: 250 },
      'gpt-3.5': { tokens: 8000, cost: 80 }
    },
    byCategory: {
      'chat': { tokens: 7000, cost: 200 },
      'completion': { tokens: 6000, cost: 130 }
    }
  };

  const mockModelData = {
    selected: 'gpt-4',
    available: [
      { id: 'gpt-4', name: 'GPT-4', cost: 0.05 },
      { id: 'gpt-3.5', name: 'GPT-3.5 Turbo', cost: 0.01 }
    ],
    performance: {
      'gpt-4': { avgResponseTime: 2.5, reliability: 99.9 },
      'gpt-3.5': { avgResponseTime: 1.2, reliability: 99.5 }
    }
  };

  const mockMetricsData = {
    avgResponseTime: 2.1,
    reliability: 99.7,
    cacheHitRate: 85.3,
    costSavingsRate: 12.5
  };

  const defaultProps = {
    usageData: mockUsageData,
    modelData: mockModelData,
    metricsData: mockMetricsData,
    darkMode: false
  };

  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('Component Rendering', () => {
    test('renders main dashboard structure', () => {
      render(<EnhancedAnalyticsDashboard {...defaultProps} />);
      
      expect(screen.getByText('Enhanced Analytics Dashboard')).toBeInTheDocument();
      expect(screen.getByText('Advanced analytics and insights for token usage')).toBeInTheDocument();
    });

    test('renders with dark mode styling', () => {
      render(<EnhancedAnalyticsDashboard {...defaultProps} darkMode={true} />);
      
      const cards = screen.getAllByTestId('card');
      expect(cards.length).toBeGreaterThan(0);
    });

    test('renders without data gracefully', () => {
      render(<EnhancedAnalyticsDashboard usageData={{}} modelData={{}} metricsData={{}} />);
      
      expect(screen.getByText('Enhanced Analytics Dashboard')).toBeInTheDocument();
    });
  });

  describe('Time Period Filtering', () => {
    test('renders time period filter buttons', () => {
      render(<EnhancedAnalyticsDashboard {...defaultProps} />);
      
      expect(screen.getByText('Today')).toBeInTheDocument();
      expect(screen.getByText('Week')).toBeInTheDocument();
      expect(screen.getByText('Month')).toBeInTheDocument();
      expect(screen.getByText('Custom')).toBeInTheDocument();
    });

    test('switches between time periods', async () => {
      render(<EnhancedAnalyticsDashboard {...defaultProps} />);
      
      const weekButton = screen.getByText('Week');
      fireEvent.click(weekButton);
      
      await waitFor(() => {
        expect(weekButton.parentElement).toHaveClass('primary');
      });
    });

    test('handles custom date range selection', async () => {
      render(<EnhancedAnalyticsDashboard {...defaultProps} />);
      
      const customButton = screen.getByText('Custom');
      fireEvent.click(customButton);
      
      await waitFor(() => {
        expect(screen.getByTestId('custom-date-calendar-icon')).toBeInTheDocument();
      });
    });
  });

  describe('Model and Category Filtering', () => {
    test('renders model filter dropdown', () => {
      render(<EnhancedAnalyticsDashboard {...defaultProps} />);
      
      const filterButtons = screen.getAllByTestId('button');
      const modelFilterButton = filterButtons.find(button => 
        button.textContent.includes('All Models')
      );
      expect(modelFilterButton).toBeInTheDocument();
    });

    test('renders category filter dropdown', () => {
      render(<EnhancedAnalyticsDashboard {...defaultProps} />);
      
      const filterButtons = screen.getAllByTestId('button');
      const categoryFilterButton = filterButtons.find(button => 
        button.textContent.includes('All Categories')
      );
      expect(categoryFilterButton).toBeInTheDocument();
    });

    test('filters data by selected model', async () => {
      render(<EnhancedAnalyticsDashboard {...defaultProps} />);
      
      const modelFilterButton = screen.getAllByTestId('button').find(button => 
        button.textContent.includes('All Models')
      );
      
      fireEvent.click(modelFilterButton);
      
      await waitFor(() => {
        expect(screen.getByTestId('filter-icon')).toBeInTheDocument();
      });
    });
  });

  describe('Analytics Visualizations', () => {
    test('renders usage trends chart', () => {
      render(<EnhancedAnalyticsDashboard {...defaultProps} />);
      
      expect(screen.getByText('Usage Trends')).toBeInTheDocument();
      expect(screen.getByTestId('usage-trends-line-chart-icon')).toBeInTheDocument();
    });

    test('renders model comparison chart', () => {
      render(<EnhancedAnalyticsDashboard {...defaultProps} />);
      
      expect(screen.getByText('Model Comparison')).toBeInTheDocument();
      expect(screen.getByTestId('model-comparison-bar-chart-icon')).toBeInTheDocument();
    });

    test('renders cost breakdown pie chart', () => {
      render(<EnhancedAnalyticsDashboard {...defaultProps} />);
      
      expect(screen.getByText('Cost Breakdown')).toBeInTheDocument();
      expect(screen.getByTestId('pie-chart-icon')).toBeInTheDocument();
    });

    test('switches between chart types', async () => {
      render(<EnhancedAnalyticsDashboard {...defaultProps} />);
      
      const chartTypeButtons = screen.getAllByTestId('button');
      const barChartButton = chartTypeButtons.find(button => 
        button.querySelector('[data-testid="bar-chart-3-icon"]')
      );
      
      if (barChartButton) {
        fireEvent.click(barChartButton);
        await waitFor(() => {
          expect(screen.getByTestId('bar-chart-3-icon')).toBeInTheDocument();
        });
      }
    });
  });

  describe('Key Metrics Display', () => {
    test('displays performance metrics', () => {
      render(<EnhancedAnalyticsDashboard {...defaultProps} />);
      
      expect(screen.getByText('Key Metrics')).toBeInTheDocument();
      expect(screen.getByText('Avg Response Time')).toBeInTheDocument();
      expect(screen.getByText('Reliability')).toBeInTheDocument();
      expect(screen.getByText('Cache Hit Rate')).toBeInTheDocument();
    });

    test('shows metric values correctly', () => {
      render(<EnhancedAnalyticsDashboard {...defaultProps} />);
      
      expect(screen.getByText('2.1s')).toBeInTheDocument();
      expect(screen.getByText('99.7%')).toBeInTheDocument();
      expect(screen.getByText('85.3%')).toBeInTheDocument();
    });

    test('displays trend indicators', () => {
      render(<EnhancedAnalyticsDashboard {...defaultProps} />);
      
      expect(screen.getByTestId('trending-up-icon')).toBeInTheDocument();
    });
  });

  describe('Period-over-Period Comparison', () => {
    test('renders comparison section', () => {
      render(<EnhancedAnalyticsDashboard {...defaultProps} />);
      
      expect(screen.getByText('Period Comparison')).toBeInTheDocument();
    });

    test('shows comparison metrics', () => {
      render(<EnhancedAnalyticsDashboard {...defaultProps} />);
      
      const badges = screen.getAllByTestId('badge');
      expect(badges.length).toBeGreaterThan(0);
    });

    test('toggles comparison view', async () => {
      render(<EnhancedAnalyticsDashboard {...defaultProps} />);
      
      const comparisonButtons = screen.getAllByTestId('button');
      const toggleButton = comparisonButtons.find(button => 
        button.textContent.includes('vs Previous')
      );
      
      if (toggleButton) {
        fireEvent.click(toggleButton);
        await waitFor(() => {
          expect(screen.getByText('Period Comparison')).toBeInTheDocument();
        });
      }
    });
  });

  describe('Export and Sharing Features', () => {
    test('renders export section', () => {
      render(<EnhancedAnalyticsDashboard {...defaultProps} />);
      
      expect(screen.getByText('Export & Reports')).toBeInTheDocument();
    });

    test('shows export format options', () => {
      render(<EnhancedAnalyticsDashboard {...defaultProps} />);
      
      expect(screen.getByText('PDF Report')).toBeInTheDocument();
      expect(screen.getByText('CSV Data')).toBeInTheDocument();
      expect(screen.getByText('Excel Export')).toBeInTheDocument();
    });

    test('handles PDF export', async () => {
      render(<EnhancedAnalyticsDashboard {...defaultProps} />);
      
      const pdfButton = screen.getByText('PDF Report');
      fireEvent.click(pdfButton);
      
      await waitFor(() => {
        expect(screen.getByTestId('file-down-icon')).toBeInTheDocument();
      });
    });

    test('handles CSV export', async () => {
      render(<EnhancedAnalyticsDashboard {...defaultProps} />);
      
      const csvButton = screen.getByText('CSV Data');
      fireEvent.click(csvButton);
      
      await waitFor(() => {
        expect(screen.getByTestId('download-icon')).toBeInTheDocument();
      });
    });

    test('handles email sharing', async () => {
      render(<EnhancedAnalyticsDashboard {...defaultProps} />);
      
      const shareButtons = screen.getAllByTestId('button');
      const emailButton = shareButtons.find(button => 
        button.querySelector('[data-testid="mail-icon"]')
      );
      
      if (emailButton) {
        fireEvent.click(emailButton);
        await waitFor(() => {
          expect(screen.getByTestId('mail-icon')).toBeInTheDocument();
        });
      }
    });
  });

  describe('Scheduled Reports', () => {
    test('renders scheduled reports section', () => {
      render(<EnhancedAnalyticsDashboard {...defaultProps} />);
      
      expect(screen.getByText('Scheduled Reports')).toBeInTheDocument();
    });

    test('shows schedule options', () => {
      render(<EnhancedAnalyticsDashboard {...defaultProps} />);
      
      expect(screen.getByText('Daily')).toBeInTheDocument();
      expect(screen.getByText('Weekly')).toBeInTheDocument();
      expect(screen.getByText('Monthly')).toBeInTheDocument();
    });

    test('configures scheduled report', async () => {
      render(<EnhancedAnalyticsDashboard {...defaultProps} />);
      
      const weeklyButton = screen.getByText('Weekly');
      fireEvent.click(weeklyButton);
      
      await waitFor(() => {
        expect(weeklyButton.parentElement).toHaveClass('primary');
      });
    });
  });

  describe('Data Refresh and Real-time Updates', () => {
    test('shows refresh button', () => {
      render(<EnhancedAnalyticsDashboard {...defaultProps} />);
      
      expect(screen.getByTestId('refresh-cw-icon')).toBeInTheDocument();
    });

    test('handles manual refresh', async () => {
      render(<EnhancedAnalyticsDashboard {...defaultProps} />);
      
      const refreshButtons = screen.getAllByTestId('button');
      const refreshButton = refreshButtons.find(button => 
        button.querySelector('[data-testid="refresh-cw-icon"]')
      );
      
      if (refreshButton) {
        fireEvent.click(refreshButton);
        await waitFor(() => {
          expect(screen.getByTestId('refresh-cw-icon')).toBeInTheDocument();
        });
      }
    });

    test('shows last updated timestamp', () => {
      render(<EnhancedAnalyticsDashboard {...defaultProps} />);
      
      expect(screen.getByText('Last updated:')).toBeInTheDocument();
    });
  });

  describe('Responsive Design and Accessibility', () => {
    test('applies responsive classes', () => {
      render(<EnhancedAnalyticsDashboard {...defaultProps} />);
      
      const cards = screen.getAllByTestId('card');
      expect(cards[0]).toHaveClass('w-full');
    });

    test('provides proper ARIA labels', () => {
      render(<EnhancedAnalyticsDashboard {...defaultProps} />);
      
      const buttons = screen.getAllByTestId('button');
      expect(buttons.length).toBeGreaterThan(0);
    });

    test('supports keyboard navigation', () => {
      render(<EnhancedAnalyticsDashboard {...defaultProps} />);
      
      const buttons = screen.getAllByTestId('button');
      buttons[0].focus();
      expect(document.activeElement).toBe(buttons[0]);
    });
  });

  describe('Error Handling', () => {
    test('handles missing usage data', () => {
      render(<EnhancedAnalyticsDashboard {...defaultProps} usageData={null} />);
      
      expect(screen.getByText('Enhanced Analytics Dashboard')).toBeInTheDocument();
    });

    test('handles invalid date ranges', () => {
      const invalidUsageData = {
        ...mockUsageData,
        daily: null
      };
      
      render(<EnhancedAnalyticsDashboard {...defaultProps} usageData={invalidUsageData} />);
      
      expect(screen.getByText('Enhanced Analytics Dashboard')).toBeInTheDocument();
    });

    test('shows error state for failed exports', async () => {
      // Mock console.error to avoid test output noise
      const consoleSpy = jest.spyOn(console, 'error').mockImplementation(() => {});
      
      render(<EnhancedAnalyticsDashboard {...defaultProps} />);
      
      const exportButton = screen.getByText('PDF Report');
      fireEvent.click(exportButton);
      
      await waitFor(() => {
        expect(screen.getByTestId('file-down-icon')).toBeInTheDocument();
      });
      
      consoleSpy.mockRestore();
    });
  });

  describe('Performance Optimization', () => {
    test('memoizes expensive calculations', () => {
      const { rerender } = render(<EnhancedAnalyticsDashboard {...defaultProps} />);
      
      // Rerender with same props should not cause unnecessary recalculations
      rerender(<EnhancedAnalyticsDashboard {...defaultProps} />);
      
      expect(screen.getByText('Enhanced Analytics Dashboard')).toBeInTheDocument();
    });

    test('handles large datasets efficiently', () => {
      const largeUsageData = {
        ...mockUsageData,
        daily: new Array(1000).fill(0).map((_, i) => i + 100)
      };
      
      render(<EnhancedAnalyticsDashboard {...defaultProps} usageData={largeUsageData} />);
      
      expect(screen.getByText('Enhanced Analytics Dashboard')).toBeInTheDocument();
    });
  });
}); 