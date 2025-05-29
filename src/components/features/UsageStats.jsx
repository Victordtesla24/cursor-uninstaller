import React, { useState } from 'react';

/**
 * Usage Stats Component
 *
 * Displays detailed usage statistics for the Cline AI extension
 * Shows historical data, usage breakdowns, and usage patterns
 * Implements interactive charts and data visualizations
 */
export default function UsageStats({ usageData = {}, className = '' }) {
  const [viewMode, setViewMode] = useState('daily');

  // Format large numbers with comma separators
  const formatNumber = (num) => {
    if (!num) return '0';
    return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',');
  };

  // Calculate percentage for distribution charts
  const calculatePercentage = (value, total) => {
    if (!total) return 0;
    return Math.round((value / total) * 100);
  };

  // Get appropriate color for chart segments
  const getChartColor = (index) => {
    const colors = [
      '#3b82f6', // Blue
      '#10b981', // Green
      '#f59e0b', // Orange
      '#ef4444', // Red
      '#8b5cf6', // Purple
      '#06b6d4', // Cyan
      '#ec4899'  // Pink
    ];

    return colors[index % colors.length];
  };

  // Render daily usage chart
  const renderDailyUsage = () => {
    const { daily } = usageData;
    if (!daily || daily.length === 0) return null;

    // Get max value for scaling
    const maxValue = Math.max(...daily);

    return (
      <div className="chart-section">
        <h3>Daily Token Usage (Last 30 Days)</h3>
        <div className="daily-chart">
          {daily.map((value, index) => {
            const height = maxValue ? (value / maxValue) * 100 : 0;
            const isCurrent = index === daily.length - 1;

            return (
              <div key={index} className="day-column">
                <div
                  className={`day-bar ${isCurrent ? 'current-day' : ''}`}
                  style={{
                    height: `${height}%`,
                    backgroundColor: isCurrent ? '#3b82f6' : '#64748b'
                  }}
                  title={`Day ${daily.length - index}: ${formatNumber(value)} tokens`}
                ></div>
              </div>
            );
          })}
        </div>
        <div className="chart-legend">
          <div className="legend-item">
            <div className="legend-color" style={{ backgroundColor: '#3b82f6' }}></div>
            <div className="legend-label">Current Day</div>
          </div>
          <div className="legend-item">
            <div className="legend-color" style={{ backgroundColor: '#64748b' }}></div>
            <div className="legend-label">Previous Days</div>
          </div>
        </div>
      </div>
    );
  };

  // Render model usage breakdown
  const renderModelBreakdown = () => {
    const { byModel } = usageData;
    if (!byModel || Object.keys(byModel).length === 0) return null;

    // Calculate total for percentages
    const total = Object.values(byModel).reduce((sum, value) => sum + value, 0);

    return (
      <div className="breakdown-section">
        <h3>Usage by Model</h3>
        <div className="breakdown-chart">
          {Object.entries(byModel).map(([model, value], index) => {
            const percentage = calculatePercentage(value, total);

            return (
              <div key={model} className="breakdown-item">
                <div className="breakdown-header">
                  <div className="breakdown-name">
                    <div
                      className="color-indicator"
                      style={{ backgroundColor: getChartColor(index) }}
                    ></div>
                    <span>{model}</span>
                  </div>
                  <div className="breakdown-value">{formatNumber(value)}</div>
                </div>
                <div className="breakdown-bar-container">
                  <div
                    className="breakdown-bar"
                    style={{
                      width: `${percentage}%`,
                      backgroundColor: getChartColor(index)
                    }}
                  ></div>
                </div>
                <div className="breakdown-percentage">{percentage}%</div>
              </div>
            );
          })}
        </div>
      </div>
    );
  };

  // Render function usage breakdown
  const renderFunctionBreakdown = () => {
    const { byFunction } = usageData;
    if (!byFunction || Object.keys(byFunction).length === 0) return null;

    // Calculate total for percentages
    const total = Object.values(byFunction).reduce((sum, value) => sum + value, 0);

    return (
      <div className="breakdown-section">
        <h3>Usage by Function</h3>
        <div className="breakdown-chart">
          {Object.entries(byFunction).map(([func, value], index) => {
            const percentage = calculatePercentage(value, total);
            const displayName = func.charAt(0).toUpperCase() + func.slice(1);

            return (
              <div key={func} className="breakdown-item">
                <div className="breakdown-header">
                  <div className="breakdown-name">
                    <div
                      className="color-indicator"
                      style={{ backgroundColor: getChartColor(index) }}
                    ></div>
                    <span>{displayName}</span>
                  </div>
                  <div className="breakdown-value">{formatNumber(value)}</div>
                </div>
                <div className="breakdown-bar-container">
                  <div
                    className="breakdown-bar"
                    style={{
                      width: `${percentage}%`,
                      backgroundColor: getChartColor(index)
                    }}
                  ></div>
                </div>
                <div className="breakdown-percentage">{percentage}%</div>
              </div>
            );
          })}
        </div>
      </div>
    );
  };

  // Render file type usage breakdown
  const renderFileTypeBreakdown = () => {
    const { byFile } = usageData;
    if (!byFile || Object.keys(byFile).length === 0) return null;

    // Calculate total for percentages
    const total = Object.values(byFile).reduce((sum, value) => sum + value, 0);

    return (
      <div className="breakdown-section">
        <h3>Usage by File Type</h3>
        <div className="breakdown-chart">
          {Object.entries(byFile).map(([fileType, value], index) => {
            const percentage = calculatePercentage(value, total);

            return (
              <div key={fileType} className="breakdown-item">
                <div className="breakdown-header">
                  <div className="breakdown-name">
                    <div
                      className="color-indicator"
                      style={{ backgroundColor: getChartColor(index) }}
                    ></div>
                    <span>{fileType}</span>
                  </div>
                  <div className="breakdown-value">{formatNumber(value)}</div>
                </div>
                <div className="breakdown-bar-container">
                  <div
                    className="breakdown-bar"
                    style={{
                      width: `${percentage}%`,
                      backgroundColor: getChartColor(index)
                    }}
                  ></div>
                </div>
                <div className="breakdown-percentage">{percentage}%</div>
              </div>
            );
          })}
        </div>
      </div>
    );
  };

  // Render popularity chart
  const renderPopularityChart = () => {
    const { popularity } = usageData;
    if (!popularity || Object.keys(popularity).length === 0) return null;

    // Calculate total for percentages
    const total = Object.values(popularity).reduce((sum, value) => sum + value, 0);

    // Sort by usage (descending)
    const sortedPopularity = Object.entries(popularity)
      .sort(([, a], [, b]) => b - a);

    return (
      <div className="breakdown-section">
        <h3>Feature Popularity</h3>
        <div className="popularity-chart">
          {sortedPopularity.map(([feature, value], index) => {
            const percentage = calculatePercentage(value, total);

            return (
              <div key={feature} className="popularity-item">
                <div className="popularity-label">{feature}</div>
                <div className="popularity-bar-container">
                  <div
                    className="popularity-bar"
                    style={{
                      width: `${percentage}%`,
                      backgroundColor: getChartColor(index)
                    }}
                  ></div>
                  <div className="popularity-percentage">{percentage}%</div>
                </div>
              </div>
            );
          })}
        </div>
      </div>
    );
  };

  // Render empty state if no data
  if (!usageData || Object.keys(usageData).length === 0) {
    return (
      <div className={`usage-stats ${className}`}>
        <div className="section-header">
          <h2>Usage Statistics</h2>
        </div>
        <div className="empty-state">
          <p>No usage data available yet</p>
        </div>
      </div>
    );
  }

  return (
    <div className={`usage-stats ${className}`}>
      <div className="section-header">
        <h2>Usage Statistics</h2>
        <div className="view-tabs">
          <button
            className={`view-tab ${viewMode === 'daily' ? 'active' : ''}`}
            onClick={() => setViewMode('daily')}
          >
            Daily
          </button>
          <button
            className={`view-tab ${viewMode === 'breakdown' ? 'active' : ''}`}
            onClick={() => setViewMode('breakdown')}
          >
            Breakdown
          </button>
          <button
            className={`view-tab ${viewMode === 'popularity' ? 'active' : ''}`}
            onClick={() => setViewMode('popularity')}
          >
            Popularity
          </button>
        </div>
      </div>

      <div className="stats-content">
        {viewMode === 'daily' && (
          <div className="daily-view">
            {renderDailyUsage()}
          </div>
        )}

        {viewMode === 'breakdown' && (
          <div className="breakdown-view">
            <div className="breakdown-row">
              {renderModelBreakdown()}
              {renderFunctionBreakdown()}
            </div>
            <div className="breakdown-row">
              {renderFileTypeBreakdown()}
            </div>
          </div>
        )}

        {viewMode === 'popularity' && (
          <div className="popularity-view">
            {renderPopularityChart()}
          </div>
        )}
      </div>

      <style jsx="true">{`
        .usage-stats {
          display: flex;
          flex-direction: column;
        }

        .section-header {
          display: flex;
          justify-content: space-between;
          align-items: center;
          margin-bottom: 1rem;
        }

        .section-header h2 {
          margin: 0;
          font-size: 1.25rem;
        }

        .view-tabs {
          display: flex;
        }

        .view-tab {
          padding: 0.375rem 0.75rem;
          background: none;
          border: none;
          border-bottom: 2px solid transparent;
          cursor: pointer;
          font-size: 0.875rem;
          color: var(--text-secondary);
          transition: all 0.15s;
        }

        .view-tab:hover {
          color: var(--text-color);
        }

        .view-tab.active {
          color: var(--primary-color);
          border-bottom-color: var(--primary-color);
          font-weight: 500;
        }

        .stats-content {
          flex: 1;
        }

        /* Daily usage chart */
        .chart-section {
          margin-bottom: 1.5rem;
        }

        .chart-section h3 {
          font-size: 1rem;
          margin-top: 0;
          margin-bottom: 1rem;
        }

        .daily-chart {
          display: flex;
          align-items: flex-end;
          height: 200px;
          gap: 3px;
          margin-bottom: 0.5rem;
        }

        .day-column {
          flex: 1;
          height: 100%;
          display: flex;
          align-items: flex-end;
        }

        .day-bar {
          width: 100%;
          min-height: 1px;
          border-radius: 2px 2px 0 0;
          transition: height 0.3s;
        }

        .day-bar.current-day {
          background-color: var(--primary-color);
        }

        .chart-legend {
          display: flex;
          gap: 1rem;
          margin-top: 0.5rem;
        }

        .legend-item {
          display: flex;
          align-items: center;
          gap: 0.375rem;
          font-size: 0.75rem;
        }

        .legend-color {
          width: 12px;
          height: 12px;
          border-radius: 2px;
        }

        /* Breakdown charts */
        .breakdown-view {
          display: flex;
          flex-direction: column;
          gap: 1.5rem;
        }

        .breakdown-row {
          display: grid;
          grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
          gap: 1.5rem;
        }

        .breakdown-section {
          margin-bottom: 1rem;
        }

        .breakdown-section h3 {
          font-size: 1rem;
          margin-top: 0;
          margin-bottom: 1rem;
        }

        .breakdown-chart {
          display: flex;
          flex-direction: column;
          gap: 1rem;
        }

        .breakdown-item {
          display: flex;
          flex-direction: column;
          gap: 0.25rem;
        }

        .breakdown-header {
          display: flex;
          justify-content: space-between;
          align-items: center;
        }

        .breakdown-name {
          display: flex;
          align-items: center;
          gap: 0.5rem;
          font-size: 0.875rem;
        }

        .color-indicator {
          width: 12px;
          height: 12px;
          border-radius: 2px;
        }

        .breakdown-value {
          font-size: 0.875rem;
          font-weight: 500;
        }

        .breakdown-bar-container {
          height: 8px;
          background-color: var(--border-color);
          border-radius: 4px;
          overflow: hidden;
        }

        .breakdown-bar {
          height: 100%;
          transition: width 0.3s;
        }

        .breakdown-percentage {
          font-size: 0.75rem;
          color: var(--text-secondary);
          align-self: flex-end;
        }

        /* Popularity chart */
        .popularity-chart {
          display: flex;
          flex-direction: column;
          gap: 1rem;
        }

        .popularity-item {
          display: flex;
          flex-direction: column;
          gap: 0.25rem;
        }

        .popularity-label {
          font-size: 0.875rem;
          font-weight: 500;
        }

        .popularity-bar-container {
          display: flex;
          align-items: center;
          gap: 0.5rem;
        }

        .popularity-bar {
          height: 24px;
          background-color: var(--primary-color);
          border-radius: 4px;
          transition: width 0.3s;
        }

        .popularity-percentage {
          font-size: 0.875rem;
          font-weight: 500;
          min-width: 40px;
        }

        .empty-state {
          display: flex;
          justify-content: center;
          align-items: center;
          padding: 2rem;
          background-color: var(--background-color);
          border-radius: var(--border-radius-md);
          color: var(--text-secondary);
        }

        @media (max-width: 768px) {
          .section-header {
            flex-direction: column;
            align-items: flex-start;
            gap: 0.5rem;
          }

          .view-tabs {
            width: 100%;
            justify-content: space-between;
          }

          .breakdown-row {
            grid-template-columns: 1fr;
          }
        }
      `}</style>
    </div>
  );
}
