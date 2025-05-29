import React from 'react';

const MetricsPanel = ({ metrics, darkMode, ...props }) => (
  <div data-testid="metrics-panel" data-dark={darkMode ? 'true' : 'false'} {...props}>
    <h3>Metrics Panel Mock</h3>
    {metrics && (
      <div>
        <span>Response Time: {metrics.avgResponseTime || 0}ms</span>
        <span>Success Rate: {metrics.successRate || 0}%</span>
        <span>Error Rate: {metrics.errorRate || 0}%</span>
      </div>
    )}
  </div>
);

export default MetricsPanel; 