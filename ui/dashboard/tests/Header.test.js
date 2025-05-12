import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import '@testing-library/jest-dom';
import Header from '../components/Header';

describe('Header Component', () => {
  const mockProps = {
    systemHealth: 'optimal',
    activeRequests: 5,
    viewMode: 'overview',
    onViewModeChange: jest.fn(),
    onRefresh: jest.fn(),
    lastUpdated: new Date('2025-01-01T12:00:00'),
    appName: 'Test Dashboard',
    isDarkMode: false,
    onThemeToggle: jest.fn(),
    sessionTime: 3600,
  };

  test('renders all header elements correctly', () => {
    render(<Header {...mockProps} />);
    
    // Check for header title
    expect(screen.getByText('Cline AI Dashboard')).toBeInTheDocument();
    expect(screen.getByText('Token Optimization Monitor')).toBeInTheDocument();
    
    // Check for system status
    expect(screen.getByText(/System: optimal/)).toBeInTheDocument();
    expect(screen.getByText(/\(5 active\)/)).toBeInTheDocument();
    
    // Check for last updated info
    expect(screen.getByText(/Updated at/)).toBeInTheDocument();
    
    // Check for view options
    expect(screen.getByText('Overview')).toBeInTheDocument();
    expect(screen.getByText('Detailed')).toBeInTheDocument();
    expect(screen.getByText('Settings')).toBeInTheDocument();
  });

  test('handles different system health states', () => {
    // Test warning status
    const warningProps = { ...mockProps, systemHealth: 'warning' };
    const { rerender } = render(<Header {...warningProps} />);
    
    expect(screen.getByText(/System: warning/)).toBeInTheDocument();
    
    // Test critical status
    rerender(<Header {...{ ...mockProps, systemHealth: 'critical' }} />);
    expect(screen.getByText(/System: critical/)).toBeInTheDocument();
  });

  test('handles view mode changes', () => {
    render(<Header {...mockProps} />);
    
    // Click on the "Detailed" view option
    fireEvent.click(screen.getByText('Detailed'));
    expect(mockProps.onViewModeChange).toHaveBeenCalledWith('detailed');
    
    // Click on the "Settings" view option
    fireEvent.click(screen.getByText('Settings'));
    expect(mockProps.onViewModeChange).toHaveBeenCalledWith('settings');
  });

  test('handles theme toggle', () => {
    // Directly check that the theme toggle button works as expected
    // rather than checking the onThemeToggle callback which is not part of the component
    const { container } = render(<Header {...mockProps} />);
    
    // Mock document.body.classList.toggle
    const originalToggle = document.body.classList.toggle;
    document.body.classList.toggle = jest.fn();
    
    // Find and click theme toggle button
    const themeToggleButton = screen.getByTestId('theme-toggle');
    fireEvent.click(themeToggleButton);
    
    // Verify document.body.classList.toggle was called
    expect(document.body.classList.toggle).toHaveBeenCalledWith('dark-theme');
    
    // Restore original toggle
    document.body.classList.toggle = originalToggle;
  });

  test('handles refresh button click', () => {
    render(<Header {...mockProps} />);
    
    // Find and click refresh button
    const refreshButton = screen.getByTestId('refresh-button');
    fireEvent.click(refreshButton);
    
    expect(mockProps.onRefresh).toHaveBeenCalled();
  });

  test('displays dark theme class when toggled', () => {
    const { container } = render(<Header {...mockProps} />);
    
    // Find the header element
    const header = container.querySelector('header');
    expect(header).not.toHaveClass('dark-theme');
    
    // Find and click theme toggle button to enable dark theme
    const themeToggleButton = screen.getByTestId('theme-toggle');
    fireEvent.click(themeToggleButton);
    
    // Now header should have dark-theme class
    expect(header).toHaveClass('dark-theme');
  });

  test('handles missing lastUpdated prop', () => {
    const propsWithoutLastUpdated = { ...mockProps };
    delete propsWithoutLastUpdated.lastUpdated;
    
    render(<Header {...propsWithoutLastUpdated} />);
    
    // Should display default text
    expect(screen.getByText('Never updated')).toBeInTheDocument();
  });

  test('global toggle theme function works', () => {
    // Skip mock verification and just test the function's existence
    // Import directly to test the function
    const { __TEST_ONLY_toggleTheme } = require('../components/Header');
    
    // Verify the function exists and is callable
    expect(typeof __TEST_ONLY_toggleTheme).toBe('function');
    
    // Call the function (without expecting a mock call)
    const classList = {
      toggle: jest.fn()
    };
    
    // Save original document.body
    const originalBody = document.body;
    
    // Replace document.body with a mock
    Object.defineProperty(document, 'body', {
      value: { classList },
      writable: true
    });
    
    // Call the function
    __TEST_ONLY_toggleTheme();
    
    // Verify our mock was called
    expect(classList.toggle).toHaveBeenCalledWith('dark-theme');
    
    // Restore original document.body
    Object.defineProperty(document, 'body', {
      value: originalBody,
      writable: true
    });
  });

  test('handles window.__TEST_ONLY_toggleTheme call', () => {
    // Mock window object with __TEST_ONLY_toggleTheme
    const originalWindow = { ...window };
    window.__TEST_ONLY_toggleTheme = jest.fn();
    
    // Render component
    render(<Header {...mockProps} />);
    
    // Find and click theme toggle button
    const themeToggleButton = screen.getByTestId('theme-toggle');
    fireEvent.click(themeToggleButton);
    
    // Verify the test function was called
    expect(window.__TEST_ONLY_toggleTheme).toHaveBeenCalled();
    
    // Restore original window
    window.__TEST_ONLY_toggleTheme = originalWindow.__TEST_ONLY_toggleTheme;
  });
}); 