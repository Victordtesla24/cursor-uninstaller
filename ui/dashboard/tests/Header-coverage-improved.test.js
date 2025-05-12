/**
 * Improved test coverage for Header component
 * Focus on branch coverage to improve it above 85%
 */
import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import '@testing-library/jest-dom';
import { Header } from '../components/Header';

// Mock the theme toggle function
global.__TEST_ONLY_toggleTheme = jest.fn();

describe('Header Component Branch Coverage', () => {
  // Reset mocks before each test
  beforeEach(() => {
    jest.clearAllMocks();
  });

  // Test health status indicator classes
  test('renders correct status class for optimal health', () => {
    render(<Header systemHealth="optimal" lastUpdated={new Date()} onRefresh={() => {}} />);

    const statusIndicator = document.querySelector('.status-indicator');
    expect(statusIndicator).toHaveClass('optimal');
  });

  test('renders correct status class for warning health', () => {
    render(<Header systemHealth="warning" lastUpdated={new Date()} onRefresh={() => {}} />);

    const statusIndicator = document.querySelector('.status-indicator');
    expect(statusIndicator).toHaveClass('warning');
  });

  test('renders correct status class for critical health', () => {
    render(<Header systemHealth="critical" lastUpdated={new Date()} onRefresh={() => {}} />);

    const statusIndicator = document.querySelector('.status-indicator');
    expect(statusIndicator).toHaveClass('critical');
  });

  test('renders fallback status class for unrecognized health status', () => {
    render(<Header systemHealth="nonexistent-status" lastUpdated={new Date()} onRefresh={() => {}} />);

    const statusIndicator = document.querySelector('.status-indicator');
    // Should default to optimal status when unrecognized
    expect(statusIndicator).toHaveClass('optimal');
  });

  test('renders with active requests count when specified', () => {
    render(
      <Header
        systemHealth="optimal"
        activeRequests={3}
        lastUpdated={new Date()}
        onRefresh={() => {}}
      />
    );

    const statusText = screen.getByText(/\(3 active\)/i);
    expect(statusText).toBeInTheDocument();
  });

  test('renders with all view options and passes active state correctly', () => {
    const onViewModeChange = jest.fn();

    render(
      <Header
        systemHealth="optimal"
        lastUpdated={new Date()}
        onRefresh={() => {}}
        viewMode="overview"
        onViewModeChange={onViewModeChange}
      />
    );

    // Check that overview tab is active
    const overviewTab = screen.getByTestId('overview-view-option');
    expect(overviewTab).toHaveClass('active');

    // Check that detailed tab is not active
    const detailedTab = screen.getByTestId('detailed-view-option');
    expect(detailedTab).not.toHaveClass('active');

    // Click detailed tab
    fireEvent.click(detailedTab);
    expect(onViewModeChange).toHaveBeenCalledWith('detailed');
  });

  test('renders with various date formats', () => {
    // Test with recent date (should show time)
    const recentDate = new Date();
    const { rerender } = render(<Header systemHealth="optimal" lastUpdated={recentDate} onRefresh={() => {}} />);

    // Check for time format in the output
    const dateDisplay = screen.getByText(/updated at/i);
    expect(dateDisplay.textContent).toMatch(/Updated at/);

    // Test with null date
    rerender(<Header systemHealth="optimal" lastUpdated={null} onRefresh={() => {}} />);

    // Should show "never" for null date
    const nullDateDisplay = screen.getByText(/never updated/i);
    expect(nullDateDisplay).toBeInTheDocument();
  });

  test('handles date formatting errors gracefully', () => {
    // Create a date object that will throw an error when toLocaleTimeString is called
    const badDate = {};
    badDate.toLocaleTimeString = () => { throw new Error('Bad date'); };

    render(<Header systemHealth="optimal" lastUpdated={badDate} onRefresh={() => {}} />);

    // Should show fallback text
    const fallbackText = screen.getByText(/unknown update time/i);
    expect(fallbackText).toBeInTheDocument();
  });

  test('refresh button triggers onRefresh callback', () => {
    const refreshMock = jest.fn();
    render(<Header systemHealth="optimal" lastUpdated={new Date()} onRefresh={refreshMock} />);

    const refreshButton = screen.getByTestId('refresh-button');
    fireEvent.click(refreshButton);

    expect(refreshMock).toHaveBeenCalledTimes(1);
  });

  test('theme toggle button changes theme', () => {
    render(<Header systemHealth="optimal" lastUpdated={new Date()} onRefresh={() => {}} />);

    const themeToggle = screen.getByTestId('theme-toggle');
    fireEvent.click(themeToggle);

    expect(global.__TEST_ONLY_toggleTheme).toHaveBeenCalledTimes(1);
  });

  test('toggles dark theme class on header', () => {
    const { container } = render(<Header systemHealth="optimal" lastUpdated={new Date()} onRefresh={() => {}} />);

    const header = container.querySelector('.header');
    expect(header).not.toHaveClass('dark-theme');

    const themeToggle = screen.getByTestId('theme-toggle');
    fireEvent.click(themeToggle);

    // Now the header should have dark theme class
    expect(header).toHaveClass('dark-theme');
  });

  test('checks all view option clicks', () => {
    const viewChangeMock = jest.fn();
    render(
      <Header
        systemHealth="optimal"
        lastUpdated={new Date()}
        onRefresh={() => {}}
        viewMode="overview"
        onViewModeChange={viewChangeMock}
      />
    );

    // Click each view mode option
    const viewOptions = [
      { element: screen.getByTestId('overview-view-option'), mode: 'overview' },
      { element: screen.getByTestId('detailed-view-option'), mode: 'detailed' },
      { element: screen.getByTestId('settings-view-option'), mode: 'settings' }
    ];

    for (const { element, mode } of viewOptions) {
      fireEvent.click(element);
      expect(viewChangeMock).toHaveBeenCalledWith(mode);
    }

    // Make sure the right number of calls were made
    expect(viewChangeMock).toHaveBeenCalledTimes(viewOptions.length);
  });

  test('renders with className passed as prop', () => {
    const { container } = render(
      <Header
        systemHealth="optimal"
        lastUpdated={new Date()}
        onRefresh={() => {}}
        className="custom-header-class"
      />
    );

    const header = container.querySelector('.header');
    expect(header).toHaveClass('custom-header-class');
  });
});
