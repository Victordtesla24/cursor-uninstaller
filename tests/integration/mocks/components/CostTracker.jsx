import React from 'react';

const formatCurrency = (value) => {
  const num = parseFloat(value);
  if (isNaN(num)) return '0.00';
  return num.toFixed(2);
};

const CostTracker = ({ costData, timeFrame, ...props }) => {
  // Helper function to safely render data
  const safeRender = (data) => {
    if (typeof data === 'object' && data !== null) {
      return JSON.stringify(data);
    }
    return data;
  };

  const renderSavingsBreakdown = () => {
    if (!costData?.savings || typeof costData.savings !== 'object') {
      return null;
    }
    
    return (
      <div>
        <h4>Cost Savings Breakdown</h4>
        {Object.entries(costData.savings).map(([key, value]) => (
          <div key={key}>
            <span>{`${key}: $${formatCurrency(value)}`}</span>
          </div>
        ))}
      </div>
    );
  };

  return (
    <div data-testid="cost-tracker" data-timeframe={timeFrame} {...props}>
      <h3>Cost Metrics</h3>
      {costData && (
        <div>
          <span data-testid="total-cost">{`Total Cost: $${formatCurrency(costData.totalCost || costData.total || 0)}`}</span>
          <span data-testid="monthly-cost">{`Monthly: $${formatCurrency(costData.monthlyCost || 0)}`}</span>
          <span data-testid="projected-cost">{`Projected: $${formatCurrency(costData.projectedCost || 0)}`}</span>
          
          {/* Render savings breakdown properly */}
          {renderSavingsBreakdown()}
          
          {/* Model breakdown */}
          {costData.byModel && (
            <div>
              <h4>Cost by Model</h4>
              {Object.entries(costData.byModel).map(([model, cost]) => (
                <div key={model}>
                  <span>{`${model}: $${formatCurrency(cost)}`}</span>
                </div>
              ))}
            </div>
          )}
        </div>
      )}
    </div>
  );
};

export default CostTracker; 