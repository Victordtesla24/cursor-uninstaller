import React from 'react';

/**
 * Metrics Panel Component
 *
 * Displays key metrics in a grid of metric cards
 * Each metric includes a label, value, and optional comparison/trend
 */
const MetricsPanel = ({ metrics }) => {
  if (!metrics) {
    return null;
  }

  // Define metrics configuration with labels, formatters, and icons
  const metricConfig = [
    {
      id: 'tokenSavingsRate',
      label: 'Token Savings',
      format: (value) => `${(value * 100).toFixed(0)}%`,
      icon: '💰',
      positiveDirection: 'up',
      tooltip: 'Percentage of tokens saved through optimization techniques'
    },
    {
      id: 'costSavingsRate',
      label: 'Cost Savings',
      format: (value) => `${(value * 100).toFixed(0)}%`,
      icon: '💎',
      positiveDirection: 'up',
      tooltip: 'Percentage of cost saved through token optimization'
    },
    {
      id: 'averageResponseTime',
      label: 'Avg. Response',
      format: (value) => `${value.toFixed(1)}s`,
      icon: '⚡',
      positiveDirection: 'down',
      tooltip: 'Average response time in seconds'
    },
    {
      id: 'cacheHitRate',
      label: 'Cache Hit Rate',
      format: (value) => `${(value * 100).toFixed(0)}%`,
      icon: '🔄',
      positiveDirection: 'up',
      tooltip: 'Percentage of requests served from cache'
    },
    {
      id: 'dailyActiveUsers',
      label: 'Daily Users',
      format: (value) => value,
      icon: '👥',
      tooltip: 'Number of active users in the last 24 hours'
    },
    {
      id: 'completionRate',
      label: 'Completion Rate',
      format: (value) => `${(value * 100).toFixed(0)}%`,
      icon: '✅',
      positiveDirection: 'up',
      tooltip: 'Percentage of successfully completed requests'
    },
    {
      id: 'totalQueries',
      label: 'Total Queries',
      format: (value) => value.toLocaleString(),
      icon: '🔍',
      tooltip: 'Total number of queries processed'
    },
    {
      id: 'averageContextSize',
      label: 'Avg. Context Size',
      format: (value) => `${(value / 1000).toFixed(1)}K`,
      icon: '📊',
      tooltip: 'Average context window size in tokens'
    }
  ];

  return (
    <div className="metrics-panel">
      <div className="panel-header">
        <h2>Key Metrics</h2>
        <div className="header-actions">
          <button className="refresh-button" title="Refresh metrics data">
            <span className="refresh-icon">↻</span>
          </button>
          <div className="time-period-selector">
            <select defaultValue="day">
              <option value="day">Today</option>
              <option value="week">This Week</option>
              <option value="month">This Month</option>
            </select>
          </div>
        </div>
      </div>

      <div className="metrics-grid">
        {metricConfig.map((config) => {
          const value = metrics[config.id];

          // Skip if metric is not available
          if (value === undefined) return null;

          return (
            <div key={config.id} className="metric-card" title={config.tooltip}>
              <div className="metric-icon">{config.icon}</div>
              <div className="metric-content">
                <div className="metric-label">{config.label}</div>
                <div className="metric-value">{config.format(value)}</div>

                {/* Optional trend indicator */}
                {config.positiveDirection && (
                  <div className={`metric-trend ${getTrendClass(value, config.positiveDirection)}`}>
                    {getTrendIcon(value, config.positiveDirection)}
                  </div>
                )}
              </div>
            </div>
          );
        })}
      </div>

      <style jsx>{`
        .metrics-panel {
          background-color: var(--card-background);
          border-radius: var(--border-radius-md);
          box-shadow: var(--shadow-sm);
          padding: 1.5rem;
          overflow: hidden;
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

        .header-actions {
          display: flex;
          align-items: center;
          gap: 0.75rem;
        }

        .refresh-button {
          display: flex;
          align-items: center;
          justify-content: center;
          width: 2rem;
          height: 2rem;
          border-radius: 50%;
          border: 1px solid var(--border-color);
          background: transparent;
          cursor: pointer;
          transition: all 0.2s;
        }

        .refresh-button:hover {
          background-color: var(--background-color);
          border-color: var(--border-color-hover);
        }

        .refresh-icon {
          font-size: 1rem;
        }

        .time-period-selector select {
          padding: 0.375rem 0.75rem;
          border-radius: var(--border-radius-sm);
          border: 1px solid var(--border-color);
          background-color: var(--background-color);
          font-size: 0.875rem;
          cursor: pointer;
        }

        .metrics-grid {
          display: grid;
          grid-template-columns: repeat(4, 1fr);
          gap: 1rem;
        }

        .metric-card {
          display: flex;
          align-items: center;
          gap: 0.75rem;
          padding: 1rem;
          background-color: var(--background-color);
          border-radius: var(--border-radius-sm);
          transition: transform 0.2s, box-shadow 0.2s;
        }

        .metric-card:hover {
          transform: translateY(-2px);
          box-shadow: var(--shadow-md);
        }

        .metric-icon {
          display: flex;
          align-items: center;
          justify-content: center;
          width: 2.5rem;
          height: 2.5rem;
          border-radius: 0.75rem;
          background-color: var(--primary-light);
          font-size: 1.25rem;
        }

        .metric-content {
          flex: 1;
          display: flex;
          flex-direction: column;
        }

        .metric-label {
          font-size: 0.75rem;
          color: var(--text-secondary);
          margin-bottom: 0.25rem;
        }

        .metric-value {
          font-size: 1.125rem;
          font-weight: 600;
        }

        .metric-trend {
          display: flex;
          align-items: center;
          font-size: 0.75rem;
          margin-top: 0.25rem;
        }

        .metric-trend.positive {
          color: var(--success-color);
        }

        .metric-trend.negative {
          color: var(--error-color);
        }

        .metric-trend.neutral {
          color: var(--text-secondary);
        }

        /* Responsive adjustments */
        @media (max-width: 1200px) {
          .metrics-grid {
            grid-template-columns: repeat(3, 1fr);
          }
        }

        @media (max-width: 768px) {
          .metrics-grid {
            grid-template-columns: repeat(2, 1fr);
          }
        }

        @media (max-width: 480px) {
          .metrics-grid {
            grid-template-columns: 1fr;
          }

          .panel-header {
            flex-direction: column;
            align-items: flex-start;
            gap: 0.75rem;
          }

          .header-actions {
            width: 100%;
            justify-content: space-between;
          }
        }
      `}</style>
    </div>
  );
};

// Helper function to determine trend class based on value and positive direction
const getTrendClass = (value, positiveDirection) => {
  // This is a simplified version - in a real app, you'd compare with historical data
  const threshold = positiveDirection === 'up' ? 0.5 : 0.3;

  if (positiveDirection === 'up') {
    return value >= threshold ? 'positive' : 'negative';
  } else {
    return value <= threshold ? 'positive' : 'negative';
  }
};

// Helper function to get trend icon
const getTrendIcon = (value, positiveDirection) => {
  const threshold = positiveDirection === 'up' ? 0.5 : 0.3;

  if (positiveDirection === 'up') {
    return value >= threshold ? '↑ Good' : '↓ Improve';
  } else {
    return value <= threshold ? '↓ Good' : '↑ Improve';
  }
};

export default MetricsPanel;
