// Mock implementations for components

// Mock TokenUtilization component
export const MockTokenUtilization = ({ tokenData = {}, costData = {}, className = '', darkMode = false }) => {
  // Simple mock that handles null and undefined gracefully
  const mockElement = {
    type: 'div',
    props: {
      'data-testid': 'mock-token-utilization',
      'data-dark-mode': darkMode ? 'true' : 'false',
      className: className
    },
    children: []
  };

  if (!tokenData || !tokenData.usage || !tokenData.usage.total) {
    mockElement.children.push('No token usage data available');
  } else {
    mockElement.children.push('Token usage across different categories and overall budget');
    mockElement.children.push(`${tokenData.usage.total} / ${tokenData.budgets?.total || 0}`);
    
    if (tokenData.cacheEfficiency) {
      mockElement.children.push(`Cache Efficiency: ${(tokenData.cacheEfficiency * 100).toFixed(1)}%`);
    }
    
    const estimatedCost = ((tokenData.usage.total / 1000) * (costData?.averageRate || 0.002)).toFixed(2);
    mockElement.children.push(`Est. Cost: $${estimatedCost}`);

    // Mock trends if available
    if (tokenData.trends && typeof tokenData.trends === 'object') {
      Object.keys(tokenData.trends).forEach(key => {
        mockElement.children.push(`${key}: ${tokenData.trends[key]}%`);
      });
    }
  }

  return mockElement;
};
