import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import '@testing-library/jest-dom';
import UsageStats from '../components/UsageStats';

// Mock data for testing UsageStats component
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
  }
};

describe('UsageStats Component', () => {
  test('renders the usage stats component', () => {
    render(<UsageStats usageData={mockUsageData} />);
    expect(screen.getByText('Usage Statistics')).toBeInTheDocument();
  });

  test('renders empty state when no data is provided', () => {
    render(<UsageStats usageData={{}} />);
    expect(screen.getByText('No usage data available yet')).toBeInTheDocument();
  });

  test('renders daily view by default', () => {
    render(<UsageStats usageData={mockUsageData} />);
    expect(screen.getByText('Daily Token Usage (Last 30 Days)')).toBeInTheDocument();
  });

  test('switches to breakdown view when clicked', () => {
    render(<UsageStats usageData={mockUsageData} />);
    fireEvent.click(screen.getByText('Breakdown'));
    expect(screen.getByText('Usage by Model')).toBeInTheDocument();
    expect(screen.getByText('Usage by Function')).toBeInTheDocument();
  });

  test('switches to popularity view when clicked', () => {
    render(<UsageStats usageData={mockUsageData} />);
    fireEvent.click(screen.getByText('Popularity'));
    expect(screen.getByText('Feature Popularity')).toBeInTheDocument();
  });

  test('formats numbers with comma separators', () => {
    render(<UsageStats usageData={mockUsageData} />);
    fireEvent.click(screen.getByText('Breakdown'));
    // The value 280,450 should be displayed with comma separator
    expect(screen.getByText('280,450')).toBeInTheDocument();
  });

  test('calculates percentages correctly', () => {
    render(<UsageStats usageData={mockUsageData} />);
    fireEvent.click(screen.getByText('Popularity'));
    // Code Completion is 42 out of total 100, so should be 42%
    expect(screen.getByText('42%')).toBeInTheDocument();
  });

  test('handles undefined or empty data sections gracefully', () => {
    const partialData = {
      daily: mockUsageData.daily,
      // Missing byModel, byFunction, etc.
    };
    render(<UsageStats usageData={partialData} />);
    
    // Should still render the daily view
    expect(screen.getByText('Daily Token Usage (Last 30 Days)')).toBeInTheDocument();
    
    // But when switching to breakdown, nothing should render for missing sections
    fireEvent.click(screen.getByText('Breakdown'));
    expect(screen.queryByText('Usage by Model')).not.toBeInTheDocument();
  });

  test('renders null for chart sections with empty arrays', () => {
    const dataWithEmptyDaily = {
      ...mockUsageData,
      daily: [] // Empty array
    };
    render(<UsageStats usageData={dataWithEmptyDaily} />);
    
    // Should not render the daily chart section when array is empty
    expect(screen.queryByText('Daily Token Usage (Last 30 Days)')).not.toBeInTheDocument();
  });

  test('applies className prop correctly', () => {
    const { container } = render(<UsageStats usageData={mockUsageData} className="custom-class" />);
    expect(container.firstChild).toHaveClass('custom-class');
  });
}); 