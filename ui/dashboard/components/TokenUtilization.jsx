import React, { useState } from 'react';

/**
 * TokenUtilization Component
 *
 * Displays token usage and budget information
 * Shows budgets for different token types and overall utilization
 * Provides visualizations of token usage over time
 */
const TokenUtilization = ({ tokenData = {}, className = '' }) => {
  const [activeView, setActiveView] = useState('budget');

  // Safely extract data with defaults
  const { total = {}, daily = {}, budgets = {}, cacheEfficiency = {} } = tokenData;

  // Set default values
  const safeTotal = {
    used: total.used || 0,
    saved: total.saved || 0,
    budgeted: total.budgeted || 0
  };

  const safeDaily = {
    used: daily.used || 0,
    saved: daily.saved || 0
  };

  const safeCacheEfficiency = {
    hitRate: cacheEfficiency.hitRate || 0,
    missRate: cacheEfficiency.missRate || 0,
    cacheSize: cacheEfficiency.cacheSize || 0
  };

  // Format large numbers to K/M format
  const formatNumber = (num) => {
    if (num >= 1000000) {
      return `${(num / 1000000).toFixed(1)}M`;
    } else if (num >= 1000) {
      return `${(num / 1000).toFixed(1)}K`;
    }
    return num.toString();
  };

  // Format percentage
  const formatPercentage = (value) => {
    return `${Math.round(value * 100)}%`;
  };

  // Calculate remaining tokens
  const remaining = Math.max(0, safeTotal.budgeted - safeTotal.used);

  // Calculate percentage used
  const percentUsed = safeTotal.budgeted > 0
    ? Math.min(100, Math.round((safeTotal.used / safeTotal.budgeted) * 100))
    : 0;

  // Get class based on percentage used
  const getUtilizationClass = (percent) => {
    if (percent >= 90) return 'high';
    if (percent >= 70) return 'medium';
    return 'low';
  };

  // Budget categories to display
  const budgetCategories = [
    { id: 'codeCompletion', label: 'Code Completion' },
    { id: 'errorResolution', label: 'Error Resolution' },
    { id: 'architecture', label: 'Architecture' },
    { id: 'thinking', label: 'Thinking' }
  ];

  return (
    <div className={`token-utilization-panel ${className}`}>
      <div className="panel-header">
        <h2>Token Utilization</h2>
        <div className="view-toggle">
          <button
            className={`toggle-button ${activeView === 'budget' ? 'active' : ''}`}
            onClick={() => setActiveView('budget')}
          >
            Budget
          </button>
          <button
            className={`toggle-button ${activeView === 'usage' ? 'active' : ''}`}
            onClick={() => setActiveView('usage')}
          >
            Usage
          </button>
        </div>
      </div>

      <div className="total-token-usage">
        <div className="usage-header">
          <div className="usage-label">Token Budget Utilization</div>
          <div className="usage-values">
            <span className="used-value" data-testid="token-used">{formatNumber(safeTotal.used)}</span>
            <span className="divider">/</span>
            <span className="total-value" data-testid="token-budget">{formatNumber(safeTotal.budgeted)} tokens</span>
          </div>
        </div>
        <div className="progress-bar-container">
          <div
            className={`progress-bar ${getUtilizationClass(percentUsed)}`}
            style={{ width: `${percentUsed}%` }}
          />
          <div className="progress-bar-label">{percentUsed}%</div>
        </div>
        <div className="token-stats">
          <div className="stat-item">
            <div className="stat-label">Daily Usage</div>
            <div className="stat-value">{formatNumber(safeDaily.used)}</div>
          </div>
          <div className="stat-item">
            <div className="stat-label">Tokens Saved</div>
            <div className="stat-value">{formatNumber(safeTotal.saved)}</div>
          </div>
          <div className="stat-item">
            <div className="stat-label">Remaining</div>
            <div className="stat-value">{formatNumber(remaining)}</div>
          </div>
        </div>
      </div>

      <div className="budget-categories">
        <h3>Budget Categories</h3>
        {budgetCategories.map(category => {
          const budget = budgets[category.id] || { used: 0, budget: 0 };
          const percentUsed = budget.budget > 0
            ? Math.min(100, Math.round((budget.used / budget.budget) * 100))
            : 0;

          return (
            <div key={category.id} className="budget-item">
              <div className="budget-info">
                <div className="budget-label">{category.label}</div>
                <div className="budget-values">
                  <span className="budget-display" data-testid={`budget-display-${category.id}`}>
                    {budget.used.toLocaleString()} / {budget.budget.toLocaleString()}
                  </span>
                </div>
              </div>
              <div className="budget-progress-container">
                <div
                  className={`budget-progress ${getUtilizationClass(percentUsed)}`}
                  style={{ width: `${percentUsed}%` }}
                />
              </div>
            </div>
          );
        })}
      </div>

      <div className="cache-efficiency">
        <h3>Cache Efficiency</h3>
        <div className="cache-metrics">
          <div className="cache-metric">
            <div className="pie-chart">
              <div className="pie" style={{
                backgroundImage: `conic-gradient(var(--success-color) ${safeCacheEfficiency.hitRate * 360}deg, var(--background-secondary) 0deg)`
              }}/>
              <div className="pie-center">{formatPercentage(safeCacheEfficiency.hitRate)}</div>
            </div>
            <div className="metric-label">Cache Hit Rate</div>
          </div>
          <div className="cache-size">
            <div className="size-value">{formatNumber(safeCacheEfficiency.cacheSize)}</div>
            <div className="size-label">Cached Items</div>
          </div>
        </div>
      </div>

      <style jsx="true">{`
        .token-utilization-panel {
          background-color: var(--card-background);
          border-radius: var(--border-radius-md);
          box-shadow: var(--shadow-sm);
          padding: 1.5rem;
          height: 100%;
          display: flex;
          flex-direction: column;
          flex: 1;
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
          background-color: var(--background-color);
          border-radius: var(--border-radius-sm);
          overflow: hidden;
        }

        .toggle-button {
          padding: 0.5rem 1rem;
          border: none;
          background: none;
          cursor: pointer;
          font-size: 0.875rem;
          transition: all 0.2s;
        }

        .toggle-button.active {
          background-color: var(--primary-color);
          color: white;
        }

        .total-token-usage {
          background-color: var(--background-color);
          border-radius: var(--border-radius-sm);
          padding: 1rem;
          margin-bottom: 1.5rem;
        }

        .usage-header {
          display: flex;
          justify-content: space-between;
          align-items: center;
          margin-bottom: 0.75rem;
        }

        .usage-label {
          font-weight: 500;
          font-size: 0.875rem;
        }

        .usage-values {
          font-size: 0.875rem;
        }

        .used-value {
          font-weight: 600;
        }

        .divider {
          margin: 0 0.25rem;
          color: var(--text-secondary);
        }

        .total-value {
          color: var(--text-secondary);
        }

        .progress-bar-container {
          height: 0.75rem;
          background-color: var(--background-secondary);
          border-radius: var(--border-radius-sm);
          position: relative;
          margin-bottom: 1rem;
          overflow: hidden;
        }

        .progress-bar {
          height: 100%;
          transition: width 0.3s ease;
        }

        .progress-bar.low {
          background-color: var(--success-color);
        }

        .progress-bar.medium {
          background-color: var(--warning-color);
        }

        .progress-bar.high {
          background-color: var(--error-color);
        }

        .progress-bar-label {
          position: absolute;
          top: 0;
          right: 0.5rem;
          font-size: 0.675rem;
          color: var(--text-secondary);
          line-height: 0.75rem;
        }

        .token-stats {
          display: flex;
          justify-content: space-between;
        }

        .stat-item {
          flex: 1;
          text-align: center;
        }

        .stat-label {
          font-size: 0.75rem;
          color: var(--text-secondary);
          margin-bottom: 0.25rem;
        }

        .stat-value {
          font-weight: 600;
          font-size: 0.875rem;
        }

        .budget-categories {
          margin-bottom: 1.5rem;
        }

        h3 {
          margin: 0 0 1rem 0;
          font-size: 1rem;
          font-weight: 600;
        }

        .budget-item {
          margin-bottom: 0.75rem;
        }

        .budget-info {
          display: flex;
          justify-content: space-between;
          align-items: center;
          margin-bottom: 0.375rem;
        }

        .budget-label {
          font-size: 0.875rem;
        }

        .budget-values {
          font-size: 0.75rem;
          color: var(--text-secondary);
        }

        .budget-progress-container {
          height: 0.375rem;
          background-color: var(--background-secondary);
          border-radius: var(--border-radius-sm);
          overflow: hidden;
        }

        .budget-progress {
          height: 100%;
          transition: width 0.3s ease;
        }

        .budget-progress.low {
          background-color: var(--success-color);
        }

        .budget-progress.medium {
          background-color: var(--warning-color);
        }

        .budget-progress.high {
          background-color: var(--error-color);
        }

        .cache-efficiency {
          margin-top: auto;
        }

        .cache-metrics {
          display: flex;
          align-items: center;
          gap: 2rem;
        }

        .cache-metric {
          text-align: center;
        }

        .pie-chart {
          position: relative;
          width: 5rem;
          height: 5rem;
          margin: 0 auto 0.5rem;
        }

        .pie {
          width: 100%;
          height: 100%;
          border-radius: 50%;
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
          font-size: 0.9rem;
        }

        .metric-label {
          font-size: 0.75rem;
          color: var(--text-secondary);
        }

        .cache-size {
          text-align: center;
        }

        .size-value {
          font-size: 1.5rem;
          font-weight: 600;
          margin-bottom: 0.25rem;
        }

        .size-label {
          font-size: 0.75rem;
          color: var(--text-secondary);
        }
      `}</style>
    </div>
  );
};

export default TokenUtilization;
