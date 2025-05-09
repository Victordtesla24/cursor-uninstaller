import React, { useState } from 'react';

/**
 * UsageChart Component
 *
 * Displays usage statistics in various chart formats
 * Includes token usage over time, usage by model, function, and file type
 * Provides filtering options and chart type selection
 */
const UsageChart = ({ usageData }) => {
  const [chartView, setChartView] = useState('daily');
  const [chartType, setChartType] = useState('line');

  if (!usageData) {
    return null;
  }

  // Helper to format numbers with K/M suffix
  const formatNumber = (num) => {
    if (num >= 1000000) {
      return `${(num / 1000000).toFixed(1)}M`;
    }
    if (num >= 1000) {
      return `${(num / 1000).toFixed(1)}K`;
    }
    return num.toString();
  };

  // Get chart data based on selected view
  const getChartData = () => {
    switch (chartView) {
      case 'daily':
        return usageData.daily;
      case 'byModel':
        return usageData.byModel;
      case 'byFunction':
        return usageData.byFunction;
      case 'byFile':
        return usageData.byFile;
      case 'popularity':
        return usageData.popularity;
      default:
        return usageData.daily;
    }
  };

  const data = getChartData();
  const isTimeSeries = chartView === 'daily';
  const isBarChart = !isTimeSeries || chartType === 'bar';

  // Render chart based on the data type
  const renderChart = () => {
    if (isTimeSeries) {
      return renderTimeSeriesChart(data);
    } else {
      return renderCategoryChart(data);
    }
  };

  // Render a time series chart (daily usage)
  const renderTimeSeriesChart = (timeData) => {
    const maxValue = Math.max(...timeData);

    return (
      <div className={`chart ${chartType}-chart time-series`}>
        {chartType === 'line' ? (
          // Line chart with area
          <svg className="line-chart-svg" viewBox={`0 0 ${timeData.length} 100`}>
            {/* Area under the line */}
            <defs>
              <linearGradient id="areaGradient" x1="0%" y1="0%" x2="0%" y2="100%">
                <stop offset="0%" stopColor="var(--primary-color)" stopOpacity="0.3" />
                <stop offset="100%" stopColor="var(--primary-color)" stopOpacity="0.05" />
              </linearGradient>
            </defs>

            {/* Line */}
            <polyline
              className="line"
              points={timeData.map((val, i) => `${i}, ${100 - (val / maxValue) * 95}`).join(' ')}
            />

            {/* Area under the line */}
            <polygon
              className="area"
              points={`
                0,100
                ${timeData.map((val, i) => `${i},${100 - (val / maxValue) * 95}`).join(' ')}
                ${timeData.length - 1},100
              `}
              fill="url(#areaGradient)"
            />

            {/* Data points */}
            {timeData.map((val, i) => (
              <circle
                key={i}
                cx={i}
                cy={100 - (val / maxValue) * 95}
                r="1.5"
                className="data-point"
                data-tooltip={`Day ${i + 1}: ${formatNumber(val)} tokens`}
              />
            ))}
          </svg>
        ) : (
          // Bar chart for time series
          <div className="bar-chart">
            {timeData.map((value, index) => {
              const height = `${(value / maxValue) * 100}%`;

              return (
                <div key={index} className="chart-bar-container">
                  <div
                    className="chart-bar"
                    style={{ height }}
                    title={`Day ${index + 1}: ${formatNumber(value)} tokens`}
                  />
                  {index % 5 === 0 && (
                    <div className="chart-label">{index + 1}</div>
                  )}
                </div>
              );
            })}
          </div>
        )}
      </div>
    );
  };

  // Render a category chart (by model, function, file type)
  const renderCategoryChart = (categoryData) => {
    const entries = Object.entries(categoryData);
    const maxValue = Math.max(...entries.map(([_, value]) => value));

    // For the popularity chart, we want to sort by value
    const sortedEntries = chartView === 'popularity'
      ? entries.sort((a, b) => b[1] - a[1])
      : entries;

    // Take only the top items for cleaner visualization
    const displayEntries = sortedEntries.slice(0, 8);

    return (
      <div className="bar-chart horizontal">
        {displayEntries.map(([category, value], index) => {
          const width = `${(value / maxValue) * 100}%`;

          // Format category name for display
          let displayName = category;
          if (chartView === 'byModel') {
            displayName = category.split('-').pop(); // Get the last part of the model name
          }

          return (
            <div key={category} className="chart-bar-row">
              <div className="category-label">{displayName}</div>
              <div className="bar-container">
                <div
                  className="bar"
                  style={{ width }}
                  title={`${displayName}: ${formatNumber(value)} tokens`}
                />
                <span className="bar-value">{formatNumber(value)}</span>
              </div>
            </div>
          );
        })}
      </div>
    );
  };

  return (
    <div className="usage-chart-panel">
      <div className="panel-header">
        <h2>Usage Statistics</h2>
        <div className="chart-controls">
          <div className="chart-view-selector">
            <select
              value={chartView}
              onChange={(e) => setChartView(e.target.value)}
            >
              <option value="daily">Daily Usage</option>
              <option value="byModel">By Model</option>
              <option value="byFunction">By Function</option>
              <option value="byFile">By File Type</option>
              <option value="popularity">By Popularity</option>
            </select>
          </div>

          {chartView === 'daily' && (
            <div className="chart-type-toggle">
              <button
                className={`toggle-button ${chartType === 'line' ? 'active' : ''}`}
                onClick={() => setChartType('line')}
              >
                Line
              </button>
              <button
                className={`toggle-button ${chartType === 'bar' ? 'active' : ''}`}
                onClick={() => setChartType('bar')}
              >
                Bar
              </button>
            </div>
          )}
        </div>
      </div>

      <div className="chart-container">
        {renderChart()}
      </div>

      <style jsx="true">{`
        .usage-chart-panel {
          background-color: var(--card-background);
          border-radius: var(--border-radius-md);
          box-shadow: var(--shadow-sm);
          padding: 1.5rem;
          height: 100%;
        }

        .panel-header {
          display: flex;
          justify-content: space-between;
          align-items: center;
          margin-bottom: 1.5rem;
          flex-wrap: wrap;
          gap: 1rem;
        }

        .panel-header h2 {
          margin: 0;
          font-size: 1.25rem;
          font-weight: 600;
        }

        .chart-controls {
          display: flex;
          gap: 1rem;
          align-items: center;
        }

        .chart-view-selector select,
        .chart-type-selector select {
          padding: 0.375rem 0.75rem;
          border-radius: var(--border-radius-sm);
          border: 1px solid var(--border-color);
          background-color: var(--background-color);
          font-size: 0.875rem;
          cursor: pointer;
        }

        .chart-type-toggle {
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

        .chart-container {
          height: 300px;
          position: relative;
        }

        .chart {
          width: 100%;
          height: 100%;
        }

        /* Line Chart Styles */
        .line-chart-svg {
          width: 100%;
          height: 100%;
          overflow: visible;
        }

        .line {
          fill: none;
          stroke: var(--primary-color);
          stroke-width: 2;
          stroke-linecap: round;
          stroke-linejoin: round;
        }

        .data-point {
          fill: var(--primary-color);
          cursor: pointer;
        }

        .data-point:hover {
          fill: var(--primary-hover);
          r: 3;
        }

        /* Bar Chart Styles */
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

        /* Horizontal Bar Chart */
        .bar-chart.horizontal {
          flex-direction: column;
          gap: 0.75rem;
          height: 100%;
          justify-content: flex-start;
        }

        .chart-bar-row {
          display: flex;
          align-items: center;
          width: 100%;
          height: 2rem;
        }

        .category-label {
          width: 5rem;
          font-size: 0.75rem;
          color: var(--text-secondary);
          overflow: hidden;
          text-overflow: ellipsis;
          white-space: nowrap;
          padding-right: 1rem;
        }

        .bar-container {
          flex: 1;
          height: 1rem;
          background-color: var(--background-color);
          border-radius: var(--border-radius-sm);
          position: relative;
          overflow: hidden;
        }

        .bar {
          height: 100%;
          background-color: var(--primary-color);
          border-radius: var(--border-radius-sm);
          transition: width 0.3s ease;
        }

        .bar-value {
          position: absolute;
          right: 0.5rem;
          top: 50%;
          transform: translateY(-50%);
          font-size: 0.75rem;
          font-weight: 500;
        }

        /* Responsive adjustments */
        @media (max-width: 768px) {
          .panel-header {
            flex-direction: column;
            align-items: flex-start;
          }

          .chart-controls {
            width: 100%;
            justify-content: space-between;
          }

          .chart-container {
            height: 250px;
          }

          .category-label {
            width: 4rem;
          }
        }

        @media (max-width: 480px) {
          .chart-controls {
            flex-direction: column;
            align-items: flex-start;
            gap: 0.5rem;
          }

          .chart-view-selector,
          .chart-type-toggle {
            width: 100%;
          }

          .chart-type-toggle {
            display: grid;
            grid-template-columns: 1fr 1fr;
          }

          .chart-container {
            height: 200px;
          }
        }
      `}</style>
    </div>
  );
};

export default UsageChart;
