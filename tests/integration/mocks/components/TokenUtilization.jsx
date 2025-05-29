import React from 'react';

const TokenUtilization = ({ tokenData, selectedModel, ...props }) => (
  <div data-testid="token-utilization" data-model={selectedModel} {...props}>
    <h3>Token Utilization Mock</h3>
    {tokenData && (
      <div>
        <span data-testid="total-used">Total: {tokenData.total?.used || 0}</span>
        <span data-testid="total-limit">Limit: {tokenData.total?.limit || 0}</span>
        <span data-testid="cache-hit-rate">Cache Hit Rate: {tokenData.cacheHitRate || 0}%</span>
      </div>
    )}
  </div>
);

export default TokenUtilization; 