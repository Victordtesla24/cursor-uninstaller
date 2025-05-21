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
    cacheEfficiency: 0.68,
    trends: {
      completion: -5.2,
      chat: 3.7,
      embedding: -1.8
    }
  };

  const mockCostData = {
    averageRate: 0.015,
    totalCost: 10.55,
    monthlyCost: 42.75,
    projectedCost: 45.25
  };

  test('renders token budgets categories in test', () => {
    const { container } = render(
      <TokenUtilization
        tokenData={mockTokenData}
        costData={mockCostData}
      />
    );

    // Check if budget categories heading is present
    expect(screen.getByText('Budget Categories')).toBeInTheDocument();
    
    // Check specific categories
    expect(screen.getByText('completion')).toBeInTheDocument();
    expect(screen.getByText('chat')).toBeInTheDocument();
    expect(screen.getByText('embedding')).toBeInTheDocument();
  });

  test('renders trend indicators correctly', () => {
    const { container } = render(
      <TokenUtilization
        tokenData={mockTokenData}
        costData={mockCostData}
      />
    );

    // Check for trend indicators using a more flexible approach
    // Instead of using regex which can be problematic, look for fixed values and content
    const allBadges = container.querySelectorAll('.mock-badge');
    
    // Check content across all badges for the trend values we expect
    const badgeTexts = Array.from(allBadges).map(badge => badge.textContent);
    
    // Check if any badge contains our trend values
    const hasTrend52 = badgeTexts.some(text => text.includes('-5.2'));
    const hasTrend37 = badgeTexts.some(text => text.includes('3.7'));
    
    expect(hasTrend52).toBe(true);
    expect(hasTrend37).toBe(true);
  });

  test('renders cache efficiency section', () => {
    render(
      <TokenUtilization
        tokenData={mockTokenData}
        costData={mockCostData}
      />
    );

    // Check if cache efficiency elements are present
    expect(screen.getByText('Cache Efficiency')).toBeInTheDocument();
    expect(screen.getByText('68%')).toBeInTheDocument();
    
    // Check for tokens saved text
    expect(screen.getByText(/Tokens saved through caching/)).toBeInTheDocument();
  });
  
  test('renders cost estimation correctly', () => {
    const { container } = render(
      <TokenUtilization
        tokenData={mockTokenData}
        costData={mockCostData}
      />
    );
    
    // Check if cost display is present - using more flexible approach
    expect(container.textContent).toContain('Est. Cost');
    
    // Check if the estimated cost value is displayed
    // We know it should be $8.25 based on the math in component
    // 550,000 tokens * 0.015 / 1000 = $8.25
    expect(container.textContent).toContain('$8.25');
  });

  test('handles no data gracefully', () => {
    render(<TokenUtilization />);

    expect(screen.getByText('Token Utilization')).toBeInTheDocument();
    expect(screen.getByText('No token usage data available')).toBeInTheDocument();
    expect(screen.getByText('Token usage metrics will appear here when available')).toBeInTheDocument();
  });
});
