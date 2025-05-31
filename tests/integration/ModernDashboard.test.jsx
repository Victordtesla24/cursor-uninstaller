import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import '@testing-library/jest-dom';
import ModernDashboard from '../../src/dashboard/ModernDashboard.jsx';

// Mock matchMedia
Object.defineProperty(window, 'matchMedia', {
  writable: true,
  value: jest.fn().mockImplementation(query => ({
    matches: false,
    media: query,
    onchange: null,
    addListener: jest.fn(),
    removeListener: jest.fn(),
    addEventListener: jest.fn(),
    removeEventListener: jest.fn(),
    dispatchEvent: jest.fn(),
  })),
});

describe('ModernDashboard Component', () => {
  beforeEach(() => {
    // Clear any existing dark mode classes
    document.documentElement.classList.remove('dark');
  });

  afterEach(() => {
    jest.clearAllTimers();
    document.documentElement.classList.remove('dark');
  });

  test('renders the modern dashboard with correct title', () => {
    render(<ModernDashboard />);
    
    // Use getAllByText to handle multiple instances
    const dashboardTitles = screen.getAllByText('Cline AI Dashboard');
    expect(dashboardTitles.length).toBeGreaterThan(0);
    expect(screen.getByText('Advanced AI monitoring and optimization platform')).toBeInTheDocument();
  });

  test('renders navigation tabs with icons', () => {
    render(<ModernDashboard />);
    
    expect(screen.getByText('Overview')).toBeInTheDocument();
    expect(screen.getByText('Analytics')).toBeInTheDocument();
    expect(screen.getByText('Usage Insights')).toBeInTheDocument();
    expect(screen.getByText('AI Recommendations')).toBeInTheDocument();
    expect(screen.getByText('Model Comparison')).toBeInTheDocument();
    expect(screen.getByText('Settings')).toBeInTheDocument();
  });

  test('shows overview content by default', () => {
    render(<ModernDashboard />);
    
    expect(screen.getByText('System Overview')).toBeInTheDocument();
    expect(screen.getByText('Key performance indicators and system health')).toBeInTheDocument();
    expect(screen.getByText('System Status')).toBeInTheDocument();
    expect(screen.getByText('API Requests')).toBeInTheDocument();
    expect(screen.getByText('Response Time')).toBeInTheDocument();
    expect(screen.getByText('Cache Hit Rate')).toBeInTheDocument();
  });

  test('switches between tab views correctly', async () => {
    render(<ModernDashboard />);
    
    // Initially should show overview
    expect(screen.getByText('System Overview')).toBeInTheDocument();
    
    // Click on Analytics tab
    fireEvent.click(screen.getByText('Analytics'));
    
    await waitFor(() => {
      expect(screen.getByText('Analytics View')).toBeInTheDocument();
      expect(screen.getByText('Advanced analytics features are being loaded...')).toBeInTheDocument();
    });
    
    // Click on Settings tab
    fireEvent.click(screen.getByText('Settings'));
    
    await waitFor(() => {
      expect(screen.getByText('Settings View')).toBeInTheDocument();
      expect(screen.getByText('Advanced settings features are being loaded...')).toBeInTheDocument();
    });
  });

  test('toggles dark mode correctly', async () => {
    render(<ModernDashboard />);
    
    // Find all buttons and look for the one with moon/sun icon
    const buttons = screen.getAllByRole('button');
    const darkModeButton = buttons.find(button => {
      const svg = button.querySelector('svg');
      return svg && (svg.classList.contains('lucide-moon') || svg.classList.contains('lucide-sun'));
    });
    
    expect(darkModeButton).toBeInTheDocument();
    
    // Initially should be light mode
    expect(document.documentElement.classList.contains('dark')).toBe(false);
    
    // Click to toggle to dark mode
    fireEvent.click(darkModeButton);
    
    await waitFor(() => {
      expect(document.documentElement.classList.contains('dark')).toBe(true);
    });
    
    // Click again to toggle back to light mode
    fireEvent.click(darkModeButton);
    
    await waitFor(() => {
      expect(document.documentElement.classList.contains('dark')).toBe(false);
    });
  });

  test('refresh button works correctly', async () => {
    jest.useFakeTimers();
    
    render(<ModernDashboard />);
    
    // Find the refresh button by looking for RefreshCw icon
    const buttons = screen.getAllByRole('button');
    const refreshButton = buttons.find(button => {
      const svg = button.querySelector('svg');
      return svg && svg.classList.contains('lucide-refresh-cw');
    });
    
    expect(refreshButton).toBeInTheDocument();
    
    // Click refresh button
    fireEvent.click(refreshButton);
    
    // Should show loading state
    expect(refreshButton).toHaveAttribute('disabled');
    
    // Fast forward time to complete the refresh
    jest.advanceTimersByTime(1000);
    
    await waitFor(() => {
      expect(refreshButton).not.toHaveAttribute('disabled');
    });
    
    jest.useRealTimers();
  });

  test('displays metrics cards with correct values', () => {
    render(<ModernDashboard />);
    
    expect(screen.getByText('Excellent')).toBeInTheDocument();
    expect(screen.getByText('All systems operational')).toBeInTheDocument();
    // Use getAllByText for multiple "0" values
    const zeroValues = screen.getAllByText('0');
    expect(zeroValues.length).toBeGreaterThan(0);
    // Use getAllByText for multiple "0ms" values
    const responseTimeValues = screen.getAllByText('0ms');
    expect(responseTimeValues.length).toBeGreaterThan(0);
    expect(screen.getByText('0.68%')).toBeInTheDocument();
  });

  test('shows status badges', () => {
    render(<ModernDashboard />);
    
    expect(screen.getByText('Real-time monitoring active')).toBeInTheDocument();
    expect(screen.getByText('Active')).toBeInTheDocument();
    expect(screen.getByText('Enabled')).toBeInTheDocument();
  });

  test('renders footer with version information', () => {
    render(<ModernDashboard />);
    
    expect(screen.getByText('v2.0.0')).toBeInTheDocument();
    expect(screen.getByText('Modern AI monitoring and optimization platform')).toBeInTheDocument();
  });

  test('active tab styling is applied correctly', () => {
    render(<ModernDashboard />);
    
    const overviewTab = screen.getByText('Overview').closest('button');
    const analyticsTab = screen.getByText('Analytics').closest('button');
    
    // Overview should be active initially
    expect(overviewTab).toHaveClass('border-blue-500', 'text-blue-600');
    expect(analyticsTab).toHaveClass('border-transparent', 'text-gray-500');
    
    // Click analytics tab
    fireEvent.click(analyticsTab);
    
    // Analytics should now be active
    expect(analyticsTab).toHaveClass('border-blue-500', 'text-blue-600');
  });

  test('handles component mounting and unmounting correctly', () => {
    const { unmount } = render(<ModernDashboard />);
    
    // Component should render without errors - use getAllByText for multiple instances
    const dashboardTitles = screen.getAllByText('Cline AI Dashboard');
    expect(dashboardTitles.length).toBeGreaterThan(0);
    
    // Should unmount without errors
    unmount();
  });

  test('renders with responsive design classes', () => {
    render(<ModernDashboard />);
    
    // Check for responsive grid classes
    const container = document.querySelector('.grid-cols-1');
    expect(container).toBeInTheDocument();
    
    // Check for responsive spacing classes
    const mainContent = document.querySelector('.max-w-7xl');
    expect(mainContent).toBeInTheDocument();
  });
}); 