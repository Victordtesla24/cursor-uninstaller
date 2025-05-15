import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import TokenUtilization from '../components/TokenUtilization';

describe('TokenUtilization Coverage Tests', () => {
  const mockTokenData = {
    usage: {
      total: 550000,
      completion: 275000,
      chat: 150000,
      embedding: 125000
    },
    budgets: {
      total: 900000,
      completion: 450000,
      chat: 250000,
      embedding: 200000
    },
    cacheEfficiency: 0.32,
    trends: {
      completion: -5.2,
      chat: 3.7,
      embedding: -1.8
    }
  };

  const mockCostData = {
    averageRate: 0.015
  };

  test('renders with token usage data', () => {
    render(<TokenUtilization tokenData={mockTokenData} costData={mockCostData} />);
    
    // Check component title
    expect(screen.getByText('Token Utilization')).toBeInTheDocument();
    
    // Check usage metrics
    expect(screen.getByText(/550,000 \/ 900,000/)).toBeInTheDocument();
    
    // Check percentage calculation
    expect(screen.getByText('61% used')).toBeInTheDocument();
    
    // Check cost estimation - using a more flexible approach since text is now split across elements
    expect(screen.getByText('Est. Cost:')).toBeInTheDocument();
    expect(screen.getByText('$8.25')).toBeInTheDocument();
  });

  test('renders trend indicators correctly', () => {
    render(<TokenUtilization tokenData={mockTokenData} costData={mockCostData} />);
    
    // Check for trend indicators
    const decreaseTrend = screen.getByText(/5\.2%/);
    expect(decreaseTrend).toBeInTheDocument();
    
    const increaseTrend = screen.getByText(/3\.7%/);
    expect(increaseTrend).toBeInTheDocument();
  });

  test('handles no data gracefully', () => {
    render(<TokenUtilization />);
    
    expect(screen.getByText('Token Utilization')).toBeInTheDocument();
    expect(screen.getByText('No token usage data available')).toBeInTheDocument();
    expect(screen.getByText('Token usage metrics will appear here when available')).toBeInTheDocument();
  });
});
