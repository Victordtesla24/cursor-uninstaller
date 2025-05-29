import React from 'react';

const TokenBudgetRecommendations = ({ 
  tokenData, 
  onApplyRecommendation, 
  darkMode, 
  ...props 
}) => (
  <div data-testid="token-budget-recommendations" data-dark={darkMode ? 'true' : 'false'} {...props}>
    <h3>Token Budget Recommendations Mock</h3>
    {tokenData && (
      <div>
        <div>Budget recommendations based on current usage</div>
        <button onClick={() => onApplyRecommendation?.('total', 1000000)}>
          Apply Recommendation
        </button>
      </div>
    )}
  </div>
);

export default TokenBudgetRecommendations; 