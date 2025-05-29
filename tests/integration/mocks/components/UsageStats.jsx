import React from 'react';

const UsageStats = ({ usageData, timeFrame, ...props }) => (
  <div data-testid="usage-stats" data-timeframe={timeFrame} {...props}>
    <h3>Usage Stats Mock</h3>
    {usageData && (
      <div>
        <span data-testid="total-requests">Total Requests: {usageData.totalRequests || 0}</span>
        <span data-testid="total-tokens">Total Tokens: {usageData.totalTokens || 0}</span>
        <span data-testid="average-response-time">Average Response Time: {usageData.averageResponseTime || 0}ms</span>
      </div>
    )}
  </div>
);

export default UsageStats; 