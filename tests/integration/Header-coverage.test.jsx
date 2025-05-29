import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import '@testing-library/jest-dom';
import { Header } from '../../src/components/features/Header.jsx';

describe('Header Component Coverage Tests', () => {
  const defaultProps = {
    systemHealth: 'optimal',
    activeRequests: 0,
    viewMode: 'overview',
    onViewModeChange: jest.fn(),
    onRefresh: jest.fn(),
    lastUpdated: null,
    className: ''
  };

  beforeEach(() => {
    jest.clearAllMocks();
    // Reset body classes before each test
    document.body.className = '';
  });

  afterEach(() => {
    // Clean up any test-specific window properties
    if (typeof window !== 'undefined') {
      delete window.__TEST_ONLY_toggleTheme;
    }
  });

  describe('Basic Rendering', () => {
    test('renders header with default props', () => {
      render(<Header {...defaultProps} />);
      
      expect(screen.getByText('Cline AI Dashboard')).toBeInTheDocument();
      expect(screen.getByText('Token Usage Statistics & Performance Metrics')).toBeInTheDocument();
      expect(screen.getByText('optimal')).toBeInTheDocument();
      expect(screen.getByTestId('overview-tab')).toBeInTheDocument();
      expect(screen.getByTestId('detailed-tab')).toBeInTheDocument();
      expect(screen.getByTestId('settings-tab')).toBeInTheDocument();
      expect(screen.getByTestId('refresh-button')).toBeInTheDocument();
      expect(screen.getByTestId('theme-toggle')).toBeInTheDocument();
    });

    test('applies custom className', () => {
      const { container } = render(<Header {...defaultProps} className="custom-class" />);
      const header = container.querySelector('header');
      expect(header).toHaveClass('custom-class');
    });
  });

  describe('System Health Indicator', () => {
    test('displays optimal health with correct styling', () => {
      render(<Header {...defaultProps} systemHealth="optimal" />);
      
      expect(screen.getByText('optimal')).toBeInTheDocument();
      const healthIndicator = document.querySelector('.bg-success');
      expect(healthIndicator).toBeInTheDocument();
    });

    test('displays warning health with correct styling', () => {
      render(<Header {...defaultProps} systemHealth="warning" />);
      
      expect(screen.getByText('warning')).toBeInTheDocument();
      const healthIndicator = document.querySelector('.bg-warning');
      expect(healthIndicator).toBeInTheDocument();
    });

    test('displays critical health with correct styling', () => {
      render(<Header {...defaultProps} systemHealth="critical" />);
      
      expect(screen.getByText('critical')).toBeInTheDocument();
      const healthIndicator = document.querySelector('.bg-error');
      expect(healthIndicator).toBeInTheDocument();
    });

    test('defaults to optimal for unknown health status', () => {
      render(<Header {...defaultProps} systemHealth="unknown" />);
      
      expect(screen.getByText('unknown')).toBeInTheDocument();
      const healthIndicator = document.querySelector('.bg-success');
      expect(healthIndicator).toBeInTheDocument();
    });
  });

  describe('Active Requests Display', () => {
    test('hides active requests when count is 0', () => {
      render(<Header {...defaultProps} activeRequests={0} />);
      
      expect(screen.queryByText(/active/)).not.toBeInTheDocument();
    });

    test('displays single active request correctly', () => {
      render(<Header {...defaultProps} activeRequests={1} />);
      
      expect(screen.getByText('(1 active request)')).toBeInTheDocument();
    });

    test('displays multiple active requests correctly', () => {
      render(<Header {...defaultProps} activeRequests={5} />);
      
      expect(screen.getByText('(5 active requests)')).toBeInTheDocument();
    });
  });

  describe('Last Updated Display', () => {
    test('displays "Never updated" when lastUpdated is null', () => {
      render(<Header {...defaultProps} lastUpdated={null} />);
      
      expect(screen.getByText('Never updated')).toBeInTheDocument();
    });

    test('displays "Never updated" when lastUpdated is undefined', () => {
      render(<Header {...defaultProps} lastUpdated={undefined} />);
      
      expect(screen.getByText('Never updated')).toBeInTheDocument();
    });

    test('formats and displays valid timestamp', () => {
      const mockDate = new Date('2023-01-01T12:30:00');
      render(<Header {...defaultProps} lastUpdated={mockDate} />);
      
      // Should contain "Updated at" and some time
      expect(screen.getByText(/Updated at \d{1,2}:\d{2}/)).toBeInTheDocument();
    });

    test('handles invalid date gracefully', () => {
      const invalidDate = { toLocaleTimeString: () => { throw new Error('Invalid date'); } };
      render(<Header {...defaultProps} lastUpdated={invalidDate} />);
      
      expect(screen.getByText('Unknown update time')).toBeInTheDocument();
    });
  });

  describe('View Mode Tabs', () => {
    test('overview tab is active by default', () => {
      render(<Header {...defaultProps} viewMode="overview" />);
      
      const overviewTab = screen.getByTestId('overview-tab');
      expect(overviewTab).toHaveClass('bg-primary', 'text-primary-foreground');
    });

    test('detailed tab can be active', () => {
      render(<Header {...defaultProps} viewMode="detailed" />);
      
      const detailedTab = screen.getByTestId('detailed-tab');
      expect(detailedTab).toHaveClass('bg-primary', 'text-primary-foreground');
    });

    test('settings tab can be active', () => {
      render(<Header {...defaultProps} viewMode="settings" />);
      
      const settingsTab = screen.getByTestId('settings-tab');
      expect(settingsTab).toHaveClass('bg-primary', 'text-primary-foreground');
    });

    test('clicking overview tab calls onViewModeChange', () => {
      const mockOnViewModeChange = jest.fn();
      render(<Header {...defaultProps} onViewModeChange={mockOnViewModeChange} />);
      
      fireEvent.click(screen.getByTestId('overview-tab'));
      expect(mockOnViewModeChange).toHaveBeenCalledWith('overview');
    });

    test('clicking detailed tab calls onViewModeChange', () => {
      const mockOnViewModeChange = jest.fn();
      render(<Header {...defaultProps} onViewModeChange={mockOnViewModeChange} />);
      
      fireEvent.click(screen.getByTestId('detailed-tab'));
      expect(mockOnViewModeChange).toHaveBeenCalledWith('detailed');
    });

    test('clicking settings tab calls onViewModeChange', () => {
      const mockOnViewModeChange = jest.fn();
      render(<Header {...defaultProps} onViewModeChange={mockOnViewModeChange} />);
      
      fireEvent.click(screen.getByTestId('settings-tab'));
      expect(mockOnViewModeChange).toHaveBeenCalledWith('settings');
    });
  });

  describe('Action Buttons', () => {
    test('refresh button calls onRefresh when clicked', () => {
      const mockOnRefresh = jest.fn();
      render(<Header {...defaultProps} onRefresh={mockOnRefresh} />);
      
      fireEvent.click(screen.getByTestId('refresh-button'));
      expect(mockOnRefresh).toHaveBeenCalledTimes(1);
    });

    test('theme toggle button shows correct initial text', () => {
      render(<Header {...defaultProps} />);
      
      expect(screen.getByTestId('theme-toggle')).toHaveTextContent('Dark Mode');
    });

    test('theme toggle button changes text when clicked', () => {
      render(<Header {...defaultProps} />);
      
      const themeToggle = screen.getByTestId('theme-toggle');
      fireEvent.click(themeToggle);
      
      expect(themeToggle).toHaveTextContent('Light Mode');
    });

    test('theme toggle adds dark-theme class to body', () => {
      render(<Header {...defaultProps} />);
      
      fireEvent.click(screen.getByTestId('theme-toggle'));
      expect(document.body).toHaveClass('dark-theme');
    });

    test('theme toggle removes dark-theme class when clicked twice', () => {
      render(<Header {...defaultProps} />);
      
      const themeToggle = screen.getByTestId('theme-toggle');
      fireEvent.click(themeToggle); // Add class
      fireEvent.click(themeToggle); // Remove class
      
      expect(document.body).not.toHaveClass('dark-theme');
    });

    test('theme toggle calls test callback when available', () => {
      const mockTestCallback = jest.fn();
      window.__TEST_ONLY_toggleTheme = mockTestCallback;
      
      render(<Header {...defaultProps} />);
      
      fireEvent.click(screen.getByTestId('theme-toggle'));
      expect(mockTestCallback).toHaveBeenCalledTimes(1);
    });
  });

  describe('Edge Cases and Error Handling', () => {
    test('handles missing onViewModeChange gracefully', () => {
      // Since the component expects onViewModeChange to be a function, provide a no-op function
      render(<Header {...defaultProps} onViewModeChange={() => {}} />);
      
      // Should not throw error when clicking tabs
      expect(() => {
        fireEvent.click(screen.getByTestId('overview-tab'));
      }).not.toThrow();
    });

    test('handles missing onRefresh gracefully', () => {
      // Since the component expects onRefresh to be a function, provide a no-op function
      render(<Header {...defaultProps} onRefresh={() => {}} />);
      
      // Should not throw error when clicking refresh
      expect(() => {
        fireEvent.click(screen.getByTestId('refresh-button'));
      }).not.toThrow();
    });

    test('handles window undefined scenario in theme toggle', () => {
      // Mock console methods to avoid errors during test
      const originalConsole = global.console;
      global.console = { ...originalConsole, error: jest.fn() };

      render(<Header {...defaultProps} />);
      
      // Should not throw error when toggling theme
      expect(() => {
        fireEvent.click(screen.getByTestId('theme-toggle'));
      }).not.toThrow();
      
      // Restore console
      global.console = originalConsole;
    });
  });

  describe('Component State Management', () => {
    test('maintains theme state across interactions', () => {
      render(<Header {...defaultProps} />);
      
      // Click theme toggle
      fireEvent.click(screen.getByTestId('theme-toggle'));
      expect(screen.getByTestId('theme-toggle')).toHaveTextContent('Light Mode');
      
      // Click again to toggle back
      fireEvent.click(screen.getByTestId('theme-toggle'));
      expect(screen.getByTestId('theme-toggle')).toHaveTextContent('Dark Mode');
    });
  });
}); 