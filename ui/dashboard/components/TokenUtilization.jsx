import React from 'react';

/**
 * TokenUtilization Component
 *
 * Displays token usage and budget information
 * Includes progress bars for total utilization and budget categories
 * Shows cache efficiency metrics
 */
const TokenUtilization = ({ tokenData }) => {
  if (!tokenData) {
    return null;
  }

  const { total, daily, budgets, cacheEfficiency } = tokenData;

  // Calculate percent used for total tokens
  const totalPercent = Math.min(100, Math.round((total.used / total.budgeted) * 100));
  const totalUsedFormatted = Math.round(total.used / 1000).toLocaleString() + 'K';
  const totalBudgetFormatted = Math.round(total.budgeted / 1000).toLocaleString() + 'K';

  // Budget categories for display
  const budgetCategories = [
    {
      id: 'codeCompletion',
      label: 'Code Completion',
      color: 'var(--primary-color)'
    },
    {
      id: 'errorResolution',
      label: 'Error Resolution',
      color: 'var(--success-color)'
    },
    {
      id: 'architecture',
      label: 'Architecture',
      color: '#8e44ad' // Purple
    },
    {
      id: 'thinking',
      label: 'Thinking',
      color: '#3498db' // Blue
    }
  ];

  return (
    <div className="token-utilization-panel">
      <div className="panel-header">
        <h2>Token Utilization</h2>
        <div className="header-actions">
          <div className="view-toggle">
            <button className="toggle-button active">Total</button>
            <button className="toggle-button">Daily</button>
          </div>
        </div>
      </div>

      {/* Main token usage progress bar */}
      <div className="total-token-usage">
        <div className="usage-header">
          <div className="usage-label">Total Token Usage</div>
          <div className="usage-values">
            <span className="used-value">{totalUsedFormatted}</span>
            <span className="divider">/</span>
            <span className="total-value">{totalBudgetFormatted}</span>
          </div>
        </div>

        <div className="progress-bar-container">
          <div
            className="progress-bar"
            style={{ width: `${totalPercent}%` }}
            data-tooltip={`${totalPercent}% of budget used`}
          />
          <div className="progress-bar-label">{totalPercent}%</div>
        </div>

        <div className="token-stats">
          <div className="stat-item">
            <div className="stat-label">Daily Usage</div>
            <div className="stat-value">{Math.round(daily.used / 1000)}K</div>
          </div>
          <div className="stat-item">
            <div className="stat-label">Tokens Saved</div>
            <div className="stat-value">{Math.round(total.saved / 1000)}K</div>
          </div>
          <div className="stat-item">
            <div className="stat-label">Remaining</div>
            <div className="stat-value">{Math.round((total.budgeted - total.used) / 1000)}K</div>
          </div>
        </div>
      </div>

      {/* Budget category breakdown */}
      <div className="budget-categories">
        <h3>Budget Categories</h3>

        {budgetCategories.map(category => {
          const budget = budgets[category.id];
          if (!budget) return null;

          const percentUsed = Math.min(100, Math.round((budget.used / budget.budget) * 100));
          const bgColor = percentUsed > 90 ? 'var(--error-color)' : category.color;

          return (
            <div key={category.id} className="budget-category">
              <div className="category-header">
                <div className="category-name">{category.label}</div>
                <div className="category-values">
                  <span className="used-value">{Math.round(budget.used / 1000)}K</span>
                  <span className="divider">/</span>
                  <span className="total-value">{Math.round(budget.budget / 1000)}K</span>
                </div>
              </div>

              <div className="category-progress-container">
                <div
                  className="category-progress"
                  style={{ width: `${percentUsed}%`, backgroundColor: bgColor }}
                />
                <div className="category-percent">{percentUsed}%</div>
              </div>
            </div>
          );
        })}
      </div>

      {/* Cache efficiency section */}
      <div className="cache-efficiency">
        <h3>Cache Efficiency</h3>

        <div className="cache-metrics">
          <div className="cache-metric">
            <div className="pie-chart">
              <div
                className="pie"
                style={{
                  backgroundImage: `conic-gradient(
                    var(--success-color) 0% ${cacheEfficiency.hitRate * 100}%,
                    var(--background-color) ${cacheEfficiency.hitRate * 100}% 100%
                  )`
                }}
              />
              <div className="pie-center">
                {Math.round(cacheEfficiency.hitRate * 100)}%
              </div>
            </div>
            <div className="metric-label">Hit Rate</div>
          </div>

          <div className="cache-stats">
            <div className="cache-stat">
              <div className="stat-label">Cache Entries</div>
              <div className="stat-value">{cacheEfficiency.totalCached.toLocaleString()}</div>
            </div>
            <div className="cache-stat">
              <div className="stat-label">Cache Hits</div>
              <div className="stat-value">{cacheEfficiency.totalHits.toLocaleString()}</div>
            </div>
            <div className="cache-stat">
              <div className="stat-label">Miss Rate</div>
              <div className="stat-value">{Math.round(cacheEfficiency.missRate * 100)}%</div>
            </div>
          </div>
        </div>
      </div>

      <style jsx>{`
        .token-utilization-panel {
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

        .view-toggle {
          display: flex;
          border: 1px solid var(--border-color);
          border-radius: var(--border-radius-sm);
          overflow: hidden;
        }

        .toggle-button {
          padding: 0.375rem 0.75rem;
          background-color: transparent;
          border: none;
          font-size: 0.875rem;
          cursor: pointer;
          transition: all 0.2s;
        }

        .toggle-button.active {
          background-color: var(--primary-color);
          color: white;
        }

        .total-token-usage {
          margin-bottom: 1.5rem;
        }

        .usage-header {
          display: flex;
          justify-content: space-between;
          align-items: center;
          margin-bottom: 0.5rem;
        }

        .usage-label {
          font-size: 0.875rem;
          font-weight: 500;
        }

        .usage-values {
          font-size: 0.875rem;
          color: var(--text-secondary);
        }

        .used-value {
          font-weight: 500;
        }

        .divider {
          margin: 0 0.25rem;
        }

        .progress-bar-container {
          height: 1rem;
          background-color: var(--background-color);
          border-radius: var(--border-radius-sm);
          position: relative;
          overflow: hidden;
          margin-bottom: 0.5rem;
        }

        .progress-bar {
          height: 100%;
          background-color: var(--primary-color);
          border-radius: var(--border-radius-sm);
          transition: width 0.3s ease;
        }

        .progress-bar-label {
          position: absolute;
          right: 0.5rem;
          top: 50%;
          transform: translateY(-50%);
          font-size: 0.75rem;
          font-weight: 600;
        }

        .token-stats {
          display: flex;
          justify-content: space-between;
          margin-top: 1rem;
        }

        .stat-item {
          text-align: center;
          flex: 1;
        }

        .stat-label {
          font-size: 0.75rem;
          color: var(--text-secondary);
          margin-bottom: 0.25rem;
        }

        .stat-value {
          font-size: 0.875rem;
          font-weight: 600;
        }

        .budget-categories {
          margin-bottom: 1.5rem;
        }

        .budget-categories h3, .cache-efficiency h3 {
          font-size: 1rem;
          font-weight: 500;
          margin: 0 0 1rem 0;
        }

        .budget-category {
          margin-bottom: 0.75rem;
        }

        .category-header {
          display: flex;
          justify-content: space-between;
          margin-bottom: 0.25rem;
          font-size: 0.875rem;
        }

        .category-name {
          font-weight: 500;
        }

        .category-values {
          font-size: 0.75rem;
          color: var(--text-secondary);
        }

        .category-progress-container {
          height: 0.5rem;
          background-color: var(--background-color);
          border-radius: var(--border-radius-sm);
          position: relative;
          overflow: hidden;
        }

        .category-progress {
          height: 100%;
          border-radius: var(--border-radius-sm);
          transition: width 0.3s ease;
        }

        .category-percent {
          position: absolute;
          right: 0.25rem;
          top: 50%;
          transform: translateY(-50%);
          font-size: 0.625rem;
          font-weight: 600;
        }

        .cache-efficiency {
          margin-top: auto;
        }

        .cache-metrics {
          display: flex;
          align-items: center;
          gap: 1.5rem;
        }

        .cache-metric {
          display: flex;
          flex-direction: column;
          align-items: center;
        }

        .pie-chart {
          position: relative;
          width: 5rem;
          height: 5rem;
          margin-bottom: 0.5rem;
        }

        .pie {
          width: 100%;
          height: 100%;
          border-radius: 50%;
          position: relative;
        }

        .pie-center {
          position: absolute;
          top: 50%;
          left: 50%;
          transform: translate(-50%, -50%);
          width: 3.5rem;
          height: 3.5rem;
          background-color: var(--card-background);
          border-radius: 50%;
          display: flex;
          align-items: center;
          justify-content: center;
          font-weight: 600;
          font-size: 1rem;
        }

        .metric-label {
          font-size: 0.875rem;
        }

        .cache-stats {
          display: flex;
          flex-wrap: wrap;
          gap: 1rem;
          flex: 1;
        }

        .cache-stat {
          flex-basis: calc(50% - 0.5rem);
        }

        .cache-stat .stat-label {
          margin-bottom: 0.125rem;
        }

        /* Responsive adjustments */
        @media (max-width: 768px) {
          .cache-metrics {
            flex-direction: column;
            align-items: flex-start;
            gap: 1rem;
          }

          .cache-metric {
            width: 100%;
            flex-direction: row;
            gap: 1rem;
          }

          .pie-chart {
            width: 4rem;
            height: 4rem;
            margin-bottom: 0;
          }

          .pie-center {
            width: 2.5rem;
            height: 2.5rem;
            font-size: 0.875rem;
          }
        }

        @media (max-width: 480px) {
          .token-stats {
            flex-direction: column;
            gap: 0.75rem;
          }

          .stat-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
          }

          .cache-stats {
            gap: 0.5rem;
          }

          .cache-stat {
            flex-basis: 100%;
          }
        }
      `}</style>
    </div>
  );
};

export default TokenUtilization;
