import React, { useState } from 'react';

const EnhancedAnalyticsDashboard = ({ 
  usageData, 
  modelsData, 
  darkMode, 
  onExport, 
  onFilterChange, 
  onCompareToggle, 
  ...props 
}) => {
  const [selectedTimeRange, setSelectedTimeRange] = useState('week');
  const [viewMode, setViewMode] = useState('overview');
  const [comparisonMode, setComparisonMode] = useState(false);
  const [showExportOptions, setShowExportOptions] = useState(false);

  const handleTimeRangeChange = (range) => {
    setSelectedTimeRange(range);
    onFilterChange?.({ timeRange: range, viewMode });
  };

  const handleViewToggle = (view) => {
    setViewMode(view);
  };

  const handleCompareClick = () => {
    setComparisonMode(!comparisonMode);
    onCompareToggle?.(!comparisonMode);
  };

  const handleFilterClick = () => {
    onFilterChange?.({ timeRange: selectedTimeRange, viewMode });
  };

  const handleExportClick = () => {
    setShowExportOptions(!showExportOptions);
  };

  // Handle loading state with empty data
  if (!usageData || Object.keys(usageData).length === 0) {
    return (
      <div data-testid="enhanced-analytics-dashboard" data-dark={darkMode ? 'true' : 'false'}>
        <h2>Enhanced Analytics Dashboard Mock</h2>
        <div>Loading analytics data...</div>
      </div>
    );
  }

  return (
    <div data-testid="enhanced-analytics-dashboard" data-dark={darkMode ? 'true' : 'false'}>
      <h2>Enhanced Analytics Dashboard Mock</h2>
      
      {/* Time Range Filters */}
      <div data-testid="time-range-filters">
        <button 
          className={selectedTimeRange === 'day' ? 'bg-primary text-white' : ''}
          onClick={() => handleTimeRangeChange('day')}
        >
          Day
        </button>
        <button 
          className={selectedTimeRange === 'week' ? 'bg-primary text-white' : ''}
          onClick={() => handleTimeRangeChange('week')}
        >
          Week
        </button>
        <button 
          className={selectedTimeRange === 'month' ? 'bg-primary text-white' : ''}
          onClick={() => handleTimeRangeChange('month')}
        >
          Month
        </button>
        <button 
          className={selectedTimeRange === 'custom' ? 'bg-primary text-white' : ''}
          onClick={() => handleTimeRangeChange('custom')}
        >
          Custom
        </button>
      </div>

      {/* View Toggle */}
      <div data-testid="view-toggle">
        <button 
          className={viewMode === 'overview' ? 'bg-primary text-white' : ''}
          onClick={() => handleViewToggle('overview')}
        >
          Overview
        </button>
        <button 
          className={viewMode === 'detailed' ? 'bg-primary text-white' : ''}
          onClick={() => handleViewToggle('detailed')}
        >
          Detailed
        </button>
        <button 
          className={viewMode === 'reports' ? 'bg-primary text-white' : ''}
          onClick={() => handleViewToggle('reports')}
        >
          Reports
        </button>
      </div>

      {/* Action Buttons */}
      <div data-testid="action-buttons">
        <button onClick={handleFilterClick}>Filter</button>
        <button onClick={handleCompareClick}>Compare</button>
        <button onClick={handleExportClick}>Export</button>
        <button onClick={() => setSelectedTimeRange('week')}>Reset</button>
      </div>

      {/* Export Options - Rendered conditionally */}
      {showExportOptions && (
        <div data-testid="export-options-container">
          <h4>Export Options</h4>
          <button data-testid="export-option" onClick={() => { onExport?.('csv'); setShowExportOptions(false); }}>Export as CSV</button>
          <button data-testid="export-option" onClick={() => { onExport?.('pdf'); setShowExportOptions(false); }}>Export as PDF</button>
        </div>
      )}

      {/* Content Card */}
      <div className={`bg-card ${darkMode ? 'bg-card/95' : 'light'}`} data-testid="card">
        <h3>Enhanced Analytics</h3>
        <p>Advanced analytics and reporting tools</p>
        
        {comparisonMode && (
          <div data-testid="comparison-section">
            <h4>Comparison View</h4>
            <span data-testid="comparison-metric-value">Metric A: 100</span>
            <span data-testid="comparison-metric-value">Metric B: 200</span>
          </div>
        )}

        <div data-testid="analytics-content">
          <div>
            <h4>Analytics Overview</h4>
            <div>Summary statistics and key metrics would go here</div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default EnhancedAnalyticsDashboard; 