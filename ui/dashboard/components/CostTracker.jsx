import React, { useState } from 'react';

/**
 * CostTracker Component
 *
 * Displays cost metrics and savings information
 * Includes cost breakdown by model and savings breakdown by type
 * Provides historical cost charts
 */
const CostTracker = ({ costData, className }) => {
  const [timeframe, setTimeframe] = useState('daily');

  if (!costData) {
    return null;
  }

  // Safely extract and provide defaults for all properties
  const {
    totalCost = 0,
    monthlyCost = 0,
    projectedCost = 0,
    savings = { total: 0 },
    byModel = {},
    history = {}
  } = costData;

  // Get the appropriate history data based on the selected timeframe
  const chartData = history && history[timeframe] ? history[timeframe] : [];

  // Format currency with 2 decimal places
  const formatCurrency = (value) => {
    // Handle edge cases where value is not a number
    if (value === undefined || value === null) {
      return '$0.00';
    }

    // Ensure value is a number
    const numValue = typeof value === 'number' ? value : parseFloat(value);

    // Check if conversion resulted in a valid number
    if (isNaN(numValue)) {
      return '$0.00';
    }

    return `$${numValue.toFixed(2)}`;
  };

  // Calculate percentage saved
  const savingsPercentage = Math.round((savings.total / (totalCost + savings.total)) * 100);

  return (
    <div className={`cost-tracker-panel ${className || ''}`}>
      <div className="panel-header">
        <h2>Cost Metrics</h2>
        <div className="timeframe-selector">
          <select
            value={timeframe}
            onChange={(e) => setTimeframe(e.target.value)}
          >
            <option value="daily">Daily</option>
            <option value="weekly">Weekly</option>
            <option value="monthly">Monthly</option>
          </select>
        </div>
      </div>

      {/* Cost Overview */}
      <div className="cost-overview">
        <div className="cost-card primary">
          <div className="cost-label">Total Cost</div>
          <div className="cost-value">{formatCurrency(totalCost)}</div>
        </div>
        <div className="cost-card">
          <div className="cost-label">Monthly Projected</div>
          <div className="cost-value">{formatCurrency(projectedCost)}</div>
        </div>
        <div className="cost-card">
          <div className="cost-label">Total Savings</div>
          <div className="cost-value positive">{formatCurrency(savings.total)}</div>
          <div className="savings-percentage">({savingsPercentage}% saved)</div>
        </div>
      </div>

      {/* Cost Chart */}
      <div className="cost-chart">
        <h3>Cost History</h3>
        <div className="chart-container">
          {chartData.length > 0 ? (
            <div className="bar-chart">
              {chartData.map((value, index) => {
                const maxValue = Math.max(...chartData);
                const height = `${(value / maxValue) * 100}%`;

                return (
                  <div key={index} className="chart-bar-container">
                    <div
                      className="chart-bar"
                      style={{ height }}
                      title={`${formatCurrency(value)}`}
                    />
                    <div className="chart-label">{index + 1}</div>
                  </div>
                );
              })}
            </div>
          ) : (
            <div className="no-data">No historical data available</div>
          )}
        </div>
      </div>

      {/* Cost Breakdown */}
      <div className="cost-breakdowns">
        {/* Cost by Model */}
        <div className="cost-breakdown">
          <h3>Cost by Model</h3>
          <div className="breakdown-items">
            {Object.keys(byModel).length > 0 ? (
              Object.entries(byModel).map(([model, cost]) => {
                // Format model name for display
                const displayName = model.split('-').pop();

                // Calculate percentage of total cost
                const percentage = totalCost > 0 ? Math.round((cost / totalCost) * 100) : 0;

                return (
                  <div key={model} className="breakdown-item">
                    <div className="item-info">
                      <div className="item-name">{displayName}</div>
                      <div className="item-value">{formatCurrency(cost)}</div>
                    </div>
                    <div className="item-bar-container">
                      <div
                        className="item-bar"
                        style={{ width: `${percentage}%` }}
                      />
                      <div className="item-percentage">{percentage}%</div>
                    </div>
                  </div>
                );
              })
            ) : (
              <div className="no-data">No model cost data available</div>
            )}
          </div>
        </div>

        {/* Savings Breakdown */}
        <div className="cost-breakdown">
          <h3>Savings Breakdown</h3>
          <div className="breakdown-items">
            {savings && Object.keys(savings).filter(key => key !== 'total').length > 0 ? (
              Object.entries(savings)
                .filter(([key]) => key !== 'total')
                .map(([savingType, amount]) => {
                  // Format saving type for display
                  const displayName = savingType.charAt(0).toUpperCase() + savingType.slice(1);

                  // Calculate percentage of total savings
                  const percentage = savings.total > 0 ? Math.round((amount / savings.total) * 100) : 0;

                  return (
                    <div key={savingType} className="breakdown-item">
                      <div className="item-info">
                        <div className="item-name">{displayName}</div>
                        <div className="item-value positive">{formatCurrency(amount)}</div>
                      </div>
                      <div className="item-bar-container">
                        <div
                          className="item-bar savings"
                          style={{ width: `${percentage}%` }}
                        />
                        <div className="item-percentage">{percentage}%</div>
                      </div>
                    </div>
                  );
                })
            ) : (
              <div className="no-data">No savings data available</div>
            )}
          </div>
        </div>
      </div>

      <style jsx="true">{`
        .cost-tracker-panel {
          background-color: var(--card-background);
          border-radius: var(--border-radius-md);
          box-shadow: var(--shadow-sm);
          padding: 1.5rem;
          height: 100%;
          display: flex;
          flex-direction: column;
        }

        .panel-header {
          display: flex;
          justify-content: space-between;
          align-items: center;
          margin-bottom: 1.5rem;
        }

        .panel-header h2 {
          margin: 0;
          font-size: 1.25rem;
          font-weight: 600;
        }

        .timeframe-selector select {
          padding: 0.375rem 0.75rem;
          border-radius: var(--border-radius-sm);
          border: 1px solid var(--border-color);
          background-color: var(--background-color);
          font-size: 0.875rem;
          cursor: pointer;
        }

        .cost-overview {
          display: grid;
          grid-template-columns: repeat(3, 1fr);
          gap: 1rem;
          margin-bottom: 1.5rem;
        }

        .cost-card {
          padding: 1rem;
          background-color: var(--background-color);
          border-radius: var(--border-radius-sm);
          text-align: center;
        }

        .cost-card.primary {
          background-color: var(--primary-light);
        }

        .cost-label {
          font-size: 0.75rem;
          color: var(--text-secondary);
          margin-bottom: 0.5rem;
        }

        .cost-value {
          font-size: 1.5rem;
          font-weight: 600;
        }

        .cost-value.positive {
          color: var(--success-color);
        }

        .savings-percentage {
          font-size: 0.75rem;
          color: var(--success-color);
          margin-top: 0.25rem;
        }

        .cost-chart {
          margin-bottom: 1.5rem;
        }

        h3 {
          font-size: 1rem;
          font-weight: 500;
          margin: 0 0 1rem 0;
        }

        .chart-container {
          height: 8rem;
          padding: 0.5rem 0;
        }

        .bar-chart {
          display: flex;
          align-items: flex-end;
          height: 100%;
          gap: 0.25rem;
        }

        .chart-bar-container {
          flex: 1;
          display: flex;
          flex-direction: column;
          align-items: center;
          height: 100%;
        }

        .chart-bar {
          width: 100%;
          background-color: var(--primary-color);
          border-radius: var(--border-radius-sm) var(--border-radius-sm) 0 0;
          transition: height 0.3s ease;
          min-height: 4px;
        }

        .chart-label {
          font-size: 0.625rem;
          color: var(--text-secondary);
          margin-top: 0.25rem;
        }

        .no-data {
          height: 100%;
          display: flex;
          align-items: center;
          justify-content: center;
          color: var(--text-secondary);
          font-size: 0.875rem;
        }

        .cost-breakdowns {
          display: grid;
          grid-template-columns: 1fr;
          gap: 1.5rem;
        }

        .breakdown-items {
          display: flex;
          flex-direction: column;
          gap: 0.75rem;
        }

        .breakdown-item {
          display: flex;
          flex-direction: column;
          gap: 0.25rem;
        }

        .item-info {
          display: flex;
          justify-content: space-between;
          align-items: baseline;
        }

        .item-name {
          font-size: 0.875rem;
        }

        .item-value {
          font-size: 0.875rem;
          font-weight: 500;
        }

        .item-value.positive {
          color: var(--success-color);
        }

        .item-bar-container {
          height: 0.5rem;
          background-color: var(--background-color);
          border-radius: var(--border-radius-sm);
          position: relative;
          overflow: hidden;
        }

        .item-bar {
          height: 100%;
          background-color: var(--primary-color);
          border-radius: var(--border-radius-sm);
          transition: width 0.3s ease;
        }

        .item-bar.savings {
          background-color: var(--success-color);
        }

        .item-percentage {
          position: absolute;
          right: 0.25rem;
          top: 50%;
          transform: translateY(-50%);
          font-size: 0.625rem;
          font-weight: 600;
          color: var(--text-color);
        }

        /* Responsive adjustments */
        @media (max-width: 768px) {
          .cost-overview {
            grid-template-columns: 1fr;
            gap: 0.75rem;
          }
        }
      `}</style>
    </div>
  );
};

export default CostTracker;
