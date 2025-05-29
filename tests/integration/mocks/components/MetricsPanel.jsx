import React from 'react';

const MetricsPanel = ({ metrics, darkMode, ...props }) => {
  let totalRequests = 0;
  if (metrics?.dailyUsage && Array.isArray(metrics.dailyUsage)) {
    totalRequests = metrics.dailyUsage.reduce((sum, day) => sum + (day.requests || 0), 0);
  } else if (metrics?.requests && typeof metrics.requests === 'object') {
    totalRequests = Object.values(metrics.requests).reduce((sum, val) => sum + (val || 0), 0);
  } else if (metrics?.totalRequests) {
    totalRequests = metrics.totalRequests;
  }

  return (
    <div data-testid="metrics-panel" data-dark={darkMode ? 'true' : 'false'} {...props}>
      <h3>System Metrics</h3>
      {metrics && (
        <div>
          <span>Response Time: {metrics.avgResponseTime || 0}ms</span>
          <span>Success Rate: {metrics.successRate || 0}%</span>
          <span>Error Rate: {metrics.errorRate || 0}%</span>
          <span data-testid="total-requests-value">{totalRequests}</span>
        </div>
      )}
    </div>
  );
};

export default MetricsPanel; 