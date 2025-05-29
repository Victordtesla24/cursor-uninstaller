import React from 'react';

const CostTracker = ({ costData, tokenBudget, onBudgetChange, ...props }) => (
  <div data-testid="cost-tracker" data-budget={tokenBudget} {...props}>
    <h3>Cost Tracker Mock</h3>
    {costData && (
      <div>
        <span data-testid="total-cost">Total Cost: ${costData.totalCost || 0}</span>
        <span data-testid="savings">Savings: ${costData.savings || 0}</span>
      </div>
    )}
    <button onClick={() => onBudgetChange?.('total', 100000)}>Update Budget</button>
  </div>
);

export default CostTracker; 