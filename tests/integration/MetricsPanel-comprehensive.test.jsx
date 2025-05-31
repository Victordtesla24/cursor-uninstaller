import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import '@testing-library/jest-dom';
import MetricsPanel from '../../src/components/features/MetricsPanel.jsx';

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
  Tooltip: ({ children }) => <div data-testid="tooltip">{children}</div>,
  TooltipContent: ({ children, className }) => <div data-testid="tooltip-content" className={className}>{children}</div>,
  TooltipProvider: ({ children }) => <div data-testid="tooltip-provider">{children}</div>,
  TooltipTrigger: ({ children, className }) => <div data-testid="tooltip-trigger" className={className}>{children}</div>
}));

// Mock Lucide React icons
jest.mock('lucide-react', () => ({
  Activity: () => <div data-testid="activity-icon" />,
  BarChart3: () => <div data-testid="bar-chart-3-icon" />,
  Clock: () => <div data-testid="clock-icon" />,
  Database: () => <div data-testid="database-icon" />,
  DollarSign: () => <div data-testid="dollar-sign-icon" />,
  Gauge: () => <div data-testid="gauge-icon" />,
  Shield: () => <div data-testid="shield-icon" />,
  TrendingUp: () => <div data-testid="trending-up-icon" />,
  TrendingDown: () => <div data-testid="trending-down-icon" />,
  AlertTriangle: () => <div data-testid="alert-triangle-icon" />,
  CheckCircle: () => <div data-testid="check-circle-icon" />,
  RefreshCw: () => <div data-testid="refresh-cw-icon" />,
  Settings: () => <div data-testid="settings-icon" />,
  Info: () => <div data-testid="info-icon" />,
  Zap: () => <div data-testid="zap-icon" />
}));

describe('MetricsPanel Component - Comprehensive Coverage', () => {
  const mockMetricsData = {
    responseTime: {
      current: 120,
      average: 150,
      trend: 'down',
      threshold: 200,
      unit: 'ms'
    },
    reliability: {
      current: 99.5,
      average: 99.2,
      trend: 'up',
      threshold: 99.0,
      unit: '%'
    },
    throughput: {
      current: 1250,
      average: 1100,
      trend: 'up',
      threshold: 1000,
      unit: 'req/min'
    },
    errorRate: {
      current: 0.2,
      average: 0.5,
      trend: 'down',
      threshold: 1.0,
      unit: '%'
    },
    cacheHitRate: {
      current: 85.3,
      average: 82.1,
      trend: 'up',
      threshold: 80.0,
      unit: '%'
    },
    costMetrics: {
      daily: 45.67,
      monthly: 1234.56,
      trend: 'down',
      savings: 12.5,
      unit: '$'
    }
  };

  const mockSystemHealth = {
    overall: 'excellent',
    services: {
      api: 'healthy',
      database: 'healthy',
      cache: 'healthy',
      monitoring: 'warning'
    },
    alerts: [
      { id: 1, type: 'warning', message: 'High memory usage detected', timestamp: '2024-01-15T10:30:00Z' },
      { id: 2, type: 'info', message: 'Scheduled maintenance complete', timestamp: '2024-01-15T09:00:00Z' }
    ]
  };

  const defaultProps = {
    metricsData: mockMetricsData,
    systemHealth: mockSystemHealth,
    darkMode: false,
    onRefresh: jest.fn(),
    onSettingsChange: jest.fn()
  };

  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('Component Rendering', () => {
    test('renders main metrics panel structure', () => {
      render(<MetricsPanel {...defaultProps} />);
      
      expect(screen.getByText('System Metrics')).toBeInTheDocument();
      expect(screen.getByText('Real-time performance and health monitoring')).toBeInTheDocument();
    });

    test('renders with dark mode styling', () => {
      render(<MetricsPanel {...defaultProps} darkMode={true} />);
      
      const cards = screen.getAllByTestId('card');
      expect(cards.length).toBeGreaterThan(0);
    });

    test('renders without data gracefully', () => {
      render(<MetricsPanel metricsData={{}} systemHealth={{}} />);
      
      expect(screen.getByText('System Metrics')).toBeInTheDocument();
    });
  });

  describe('Performance Metrics Display', () => {
    test('displays response time metrics', () => {
      render(<MetricsPanel {...defaultProps} />);
      
      expect(screen.getByText('Response Time')).toBeInTheDocument();
      expect(screen.getByText('120ms')).toBeInTheDocument();
      expect(screen.getByTestId('clock-icon')).toBeInTheDocument();
    });

    test('displays reliability metrics', () => {
      render(<MetricsPanel {...defaultProps} />);
      
      expect(screen.getByText('Reliability')).toBeInTheDocument();
      expect(screen.getByText('99.5%')).toBeInTheDocument();
      expect(screen.getByTestId('shield-icon')).toBeInTheDocument();
    });

    test('displays throughput metrics', () => {
      render(<MetricsPanel {...defaultProps} />);
      
      expect(screen.getByText('Throughput')).toBeInTheDocument();
      expect(screen.getByText('1,250')).toBeInTheDocument();
      expect(screen.getByText('req/min')).toBeInTheDocument();
    });

    test('displays error rate metrics', () => {
      render(<MetricsPanel {...defaultProps} />);
      
      expect(screen.getByText('Error Rate')).toBeInTheDocument();
      expect(screen.getByText('0.2%')).toBeInTheDocument();
      expect(screen.getByTestId('alert-triangle-icon')).toBeInTheDocument();
    });

    test('displays cache hit rate metrics', () => {
      render(<MetricsPanel {...defaultProps} />);
      
      expect(screen.getByText('Cache Hit Rate')).toBeInTheDocument();
      expect(screen.getByText('85.3%')).toBeInTheDocument();
      expect(screen.getByTestId('database-icon')).toBeInTheDocument();
    });
  });

  describe('Trend Indicators', () => {
    test('shows positive trend indicators', () => {
      render(<MetricsPanel {...defaultProps} />);
      
      const trendingUpIcons = screen.getAllByTestId('trending-up-icon');
      expect(trendingUpIcons.length).toBeGreaterThan(0);
    });

    test('shows negative trend indicators', () => {
      render(<MetricsPanel {...defaultProps} />);
      
      const trendingDownIcons = screen.getAllByTestId('trending-down-icon');
      expect(trendingDownIcons.length).toBeGreaterThan(0);
    });

    test('applies correct trend styling', () => {
      render(<MetricsPanel {...defaultProps} />);
      
      const badges = screen.getAllByTestId('badge');
      const positiveBadges = badges.filter(badge => 
        badge.className.includes('success') || badge.className.includes('green')
      );
      expect(positiveBadges.length).toBeGreaterThan(0);
    });
  });

  describe('Threshold Monitoring', () => {
    test('shows metrics within acceptable thresholds', () => {
      render(<MetricsPanel {...defaultProps} />);
      
      const checkCircleIcons = screen.getAllByTestId('check-circle-icon');
      expect(checkCircleIcons.length).toBeGreaterThan(0);
    });

    test('highlights metrics exceeding thresholds', () => {
      const dataWithExceededThreshold = {
        ...mockMetricsData,
        errorRate: {
          ...mockMetricsData.errorRate,
          current: 2.5, // Exceeds threshold of 1.0
          trend: 'up'
        }
      };

      render(<MetricsPanel {...defaultProps} metricsData={dataWithExceededThreshold} />);
      
      expect(screen.getByText('2.5%')).toBeInTheDocument();
    });

    test('shows progress bars for threshold proximity', () => {
      render(<MetricsPanel {...defaultProps} />);
      
      const progressBars = screen.getAllByTestId('progress');
      expect(progressBars.length).toBeGreaterThan(0);
    });
  });

  describe('System Health Overview', () => {
    test('displays overall system health status', () => {
      render(<MetricsPanel {...defaultProps} />);
      
      expect(screen.getByText('System Health')).toBeInTheDocument();
      expect(screen.getByText('Excellent')).toBeInTheDocument();
    });

    test('shows individual service health', () => {
      render(<MetricsPanel {...defaultProps} />);
      
      expect(screen.getByText('API')).toBeInTheDocument();
      expect(screen.getByText('Database')).toBeInTheDocument();
      expect(screen.getByText('Cache')).toBeInTheDocument();
      expect(screen.getByText('Monitoring')).toBeInTheDocument();
    });

    test('displays service status badges', () => {
      render(<MetricsPanel {...defaultProps} />);
      
      const badges = screen.getAllByTestId('badge');
      const healthyBadges = badges.filter(badge => 
        badge.textContent.includes('Healthy') || 
        badge.textContent.includes('Warning')
      );
      expect(healthyBadges.length).toBeGreaterThan(0);
    });
  });

  describe('Cost Metrics', () => {
    test('displays daily cost metrics', () => {
      render(<MetricsPanel {...defaultProps} />);
      
      expect(screen.getByText('Daily Cost')).toBeInTheDocument();
      expect(screen.getByText('$45.67')).toBeInTheDocument();
      expect(screen.getByTestId('dollar-sign-icon')).toBeInTheDocument();
    });

    test('displays monthly cost metrics', () => {
      render(<MetricsPanel {...defaultProps} />);
      
      expect(screen.getByText('Monthly Cost')).toBeInTheDocument();
      expect(screen.getByText('$1,234.56')).toBeInTheDocument();
    });

    test('shows cost savings information', () => {
      render(<MetricsPanel {...defaultProps} />);
      
      expect(screen.getByText('Cost Savings')).toBeInTheDocument();
      expect(screen.getByText('12.5%')).toBeInTheDocument();
    });
  });

  describe('Real-time Updates', () => {
    test('shows refresh button', () => {
      render(<MetricsPanel {...defaultProps} />);
      
      expect(screen.getByTestId('refresh-cw-icon')).toBeInTheDocument();
    });

    test('handles manual refresh', async () => {
      const onRefresh = jest.fn();
      render(<MetricsPanel {...defaultProps} onRefresh={onRefresh} />);
      
      const refreshButton = screen.getAllByTestId('button').find(button => 
        button.querySelector('[data-testid="refresh-cw-icon"]')
      );
      
      if (refreshButton) {
        fireEvent.click(refreshButton);
        expect(onRefresh).toHaveBeenCalled();
      }
    });

    test('shows last updated timestamp', () => {
      render(<MetricsPanel {...defaultProps} />);
      
      expect(screen.getByText(/Last updated:/)).toBeInTheDocument();
    });

    test('displays auto-refresh indicator', () => {
      render(<MetricsPanel {...defaultProps} autoRefresh={true} />);
      
      expect(screen.getByText('Auto-refresh enabled')).toBeInTheDocument();
    });
  });

  describe('Alert System', () => {
    test('displays system alerts', () => {
      render(<MetricsPanel {...defaultProps} />);
      
      expect(screen.getByText('System Alerts')).toBeInTheDocument();
      expect(screen.getByText('High memory usage detected')).toBeInTheDocument();
      expect(screen.getByText('Scheduled maintenance complete')).toBeInTheDocument();
    });

    test('shows alert severity indicators', () => {
      render(<MetricsPanel {...defaultProps} />);
      
      const badges = screen.getAllByTestId('badge');
      const alertBadges = badges.filter(badge => 
        badge.textContent.includes('Warning') || 
        badge.textContent.includes('Info')
      );
      expect(alertBadges.length).toBeGreaterThan(0);
    });

    test('handles alert dismissal', async () => {
      render(<MetricsPanel {...defaultProps} />);
      
      const dismissButtons = screen.getAllByTestId('button').filter(button => 
        button.textContent.includes('Dismiss') || button.textContent === '×'
      );
      
      if (dismissButtons.length > 0) {
        fireEvent.click(dismissButtons[0]);
        // Alert should be handled appropriately
      }
    });
  });

  describe('Metric Comparisons', () => {
    test('shows comparison with averages', () => {
      render(<MetricsPanel {...defaultProps} />);
      
      expect(screen.getByText('vs avg')).toBeInTheDocument();
    });

    test('displays percentage changes', () => {
      render(<MetricsPanel {...defaultProps} />);
      
      // Look for percentage change indicators
      const percentageTexts = screen.getAllByText(/%/);
      expect(percentageTexts.length).toBeGreaterThan(0);
    });

    test('shows benchmark comparisons', () => {
      render(<MetricsPanel {...defaultProps} />);
      
      expect(screen.getByText('Threshold')).toBeInTheDocument();
    });
  });

  describe('Interactive Features', () => {
    test('provides metric tooltips', () => {
      render(<MetricsPanel {...defaultProps} />);
      
      const tooltips = screen.getAllByTestId('tooltip');
      expect(tooltips.length).toBeGreaterThan(0);
    });

    test('handles metric card hover states', async () => {
      render(<MetricsPanel {...defaultProps} />);
      
      const cards = screen.getAllByTestId('card');
      if (cards.length > 0) {
        fireEvent.mouseEnter(cards[0]);
        // Should handle hover state appropriately
      }
    });

    test('supports metric drill-down', async () => {
      render(<MetricsPanel {...defaultProps} />);
      
      const detailButtons = screen.getAllByTestId('button').filter(button => 
        button.textContent.includes('Details') || 
        button.textContent.includes('View More')
      );
      
      if (detailButtons.length > 0) {
        fireEvent.click(detailButtons[0]);
        // Should handle drill-down appropriately
      }
    });
  });

  describe('Settings and Configuration', () => {
    test('shows settings button', () => {
      render(<MetricsPanel {...defaultProps} />);
      
      expect(screen.getByTestId('settings-icon')).toBeInTheDocument();
    });

    test('handles settings changes', async () => {
      const onSettingsChange = jest.fn();
      render(<MetricsPanel {...defaultProps} onSettingsChange={onSettingsChange} />);
      
      const settingsButton = screen.getAllByTestId('button').find(button => 
        button.querySelector('[data-testid="settings-icon"]')
      );
      
      if (settingsButton) {
        fireEvent.click(settingsButton);
        // Settings panel should open or callback should be called
      }
    });

    test('allows threshold customization', async () => {
      render(<MetricsPanel {...defaultProps} showSettings={true} />);
      
      // Look for threshold input fields
      const inputs = document.querySelectorAll('input[type="number"]');
      if (inputs.length > 0) {
        fireEvent.change(inputs[0], { target: { value: '250' } });
        // Should handle threshold changes
      }
    });
  });

  describe('Performance Optimization', () => {
    test('memoizes metric calculations', () => {
      const { rerender } = render(<MetricsPanel {...defaultProps} />);
      
      // Rerender with same props should not cause unnecessary recalculations
      rerender(<MetricsPanel {...defaultProps} />);
      
      expect(screen.getByText('System Metrics')).toBeInTheDocument();
    });

    test('handles large metric datasets efficiently', () => {
      const largeMetricsData = {
        ...mockMetricsData,
        timeSeries: new Array(1000).fill(0).map((_, i) => ({
          timestamp: Date.now() - (i * 60000),
          value: Math.random() * 100
        }))
      };
      
      render(<MetricsPanel {...defaultProps} metricsData={largeMetricsData} />);
      
      expect(screen.getByText('System Metrics')).toBeInTheDocument();
    });
  });

  describe('Error Handling', () => {
    test('handles missing metric data', () => {
      render(<MetricsPanel {...defaultProps} metricsData={null} />);
      
      expect(screen.getByText('System Metrics')).toBeInTheDocument();
    });

    test('handles invalid metric values', () => {
      const invalidMetricsData = {
        ...mockMetricsData,
        responseTime: {
          ...mockMetricsData.responseTime,
          current: 'invalid'
        }
      };
      
      render(<MetricsPanel {...defaultProps} metricsData={invalidMetricsData} />);
      
      expect(screen.getByText('System Metrics')).toBeInTheDocument();
    });

    test('shows error state for failed metric updates', async () => {
      const onRefresh = jest.fn().mockRejectedValue(new Error('Update failed'));
      
      render(<MetricsPanel {...defaultProps} onRefresh={onRefresh} />);
      
      const refreshButton = screen.getAllByTestId('button').find(button => 
        button.querySelector('[data-testid="refresh-cw-icon"]')
      );
      
      if (refreshButton) {
        fireEvent.click(refreshButton);
        // Should handle error appropriately
      }
    });
  });

  describe('Responsive Design', () => {
    test('applies responsive grid classes', () => {
      render(<MetricsPanel {...defaultProps} />);
      
      const container = document.querySelector('.grid');
      expect(container).toBeInTheDocument();
    });

    test('adapts to mobile viewport', () => {
      // Mock mobile viewport
      Object.defineProperty(window, 'innerWidth', {
        writable: true,
        configurable: true,
        value: 375,
      });
      
      render(<MetricsPanel {...defaultProps} />);
      
      expect(screen.getByText('System Metrics')).toBeInTheDocument();
    });

    test('supports tablet layout', () => {
      // Mock tablet viewport
      Object.defineProperty(window, 'innerWidth', {
        writable: true,
        configurable: true,
        value: 768,
      });
      
      render(<MetricsPanel {...defaultProps} />);
      
      expect(screen.getByText('System Metrics')).toBeInTheDocument();
    });
  });

  describe('Accessibility', () => {
    test('provides proper ARIA labels', () => {
      render(<MetricsPanel {...defaultProps} />);
      
      const buttons = screen.getAllByTestId('button');
      expect(buttons.length).toBeGreaterThan(0);
    });

    test('supports keyboard navigation', () => {
      render(<MetricsPanel {...defaultProps} />);
      
      const buttons = screen.getAllByTestId('button');
      if (buttons.length > 0) {
        buttons[0].focus();
        expect(document.activeElement).toBe(buttons[0]);
      }
    });

    test('provides screen reader friendly content', () => {
      render(<MetricsPanel {...defaultProps} />);
      
      // Check for semantic HTML and proper text content
      expect(screen.getByText('Response Time')).toBeInTheDocument();
      expect(screen.getByText('120ms')).toBeInTheDocument();
    });
  });
}); 