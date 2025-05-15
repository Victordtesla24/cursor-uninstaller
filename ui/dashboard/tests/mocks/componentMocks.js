// Mock implementations for components
import React from 'react';

// Mock TokenUtilization component
export const MockTokenUtilization = ({ tokenData = {}, costData = {}, className = '', darkMode = false }) => {
  // Simple mock that handles null and undefined gracefully
  return (
    <div 
      data-testid="mock-token-utilization"
      data-dark-mode={darkMode ? 'true' : 'false'}
      className={className}
    >
      <h3>Token Utilization</h3>
      {(!tokenData || !tokenData.usage || !tokenData.usage.total) ? (
        <p>No token usage data available</p>
      ) : (
        <>
          <p>Token usage across different categories and overall budget</p>
          <div>
            {tokenData.usage.total} / {tokenData.budgets?.total || 0}
          </div>
          <div>
            {tokenData.cacheEfficiency ? (
              <div>Cache Efficiency: {(tokenData.cacheEfficiency * 100).toFixed(1)}%</div>
            ) : null}
          </div>
          <div>
            Est. Cost: ${((tokenData.usage.total / 1000) * (costData?.averageRate || 0.002)).toFixed(2)}
          </div>
          
          {/* Mock trends if available */}
          {tokenData.trends && Object.keys(tokenData.trends).map(key => (
            <div key={key}>{key}: {tokenData.trends[key]}%</div>
          ))}
        </>
      )}
    </div>
  );
};
