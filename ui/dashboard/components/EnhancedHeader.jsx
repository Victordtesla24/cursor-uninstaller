import React from 'react';

/**
 * Enhanced Header component
 * Displays the dashboard title, system health indicator, and view mode controls
 * Implements UI elements for Cline AI dashboard navigation
 * Includes indicator for mock data usage and Magic MCP API status
 */
const EnhancedHeader = ({
  systemHealth = 'optimal',
  activeRequests = 0,
  viewMode = 'overview',
  onViewModeChange,
  onRefresh,
  lastUpdated,
  usingMockData = false,
  className = ''
}) => {
  // Get system health indicator class based on status
  const getHealthClass = () => {
    switch (systemHealth) {
      case 'warning':
        return 'warning';
      case 'critical':
        return 'critical';
      case 'optimal':
      default:
        return 'optimal';
    }
  };

  // Format last updated timestamp
  const getLastUpdatedText = () => {
    if (!lastUpdated) return 'Never updated';

    try {
      const timeString = lastUpdated.toLocaleTimeString([], {
        hour: '2-digit',
        minute: '2-digit'
      });
      return `Updated at ${timeString}`;
    } catch (e) {
      return 'Unknown update time';
    }
  };

  return (
    <header className={`header ${className}`}>
      <div className="header-title-area">
        <h1 className="header-title">Cline AI Dashboard</h1>
        <div className="header-subtitle">
          Token Optimization Monitor
          {usingMockData && <span className="mock-data-indicator"> (Mock Data)</span>}
        </div>
      </div>

      <div className="header-actions">
        <div className="system-status">
          <div className={`status-indicator ${getHealthClass()}`}></div>
          <div className="status-text">
            System: {systemHealth} {activeRequests > 0 && `(${activeRequests} active)`}
          </div>
          <div className="last-updated-text">{getLastUpdatedText()}</div>
        </div>

        <div className="view-selector">
          <div
            className={`view-option ${viewMode === 'overview' ? 'active' : ''}`}
            onClick={() => onViewModeChange && onViewModeChange('overview')}
            data-testid="overview-view-option"
          >
            Overview
          </div>
          <div
            className={`view-option ${viewMode === 'detailed' ? 'active' : ''}`}
            onClick={() => onViewModeChange && onViewModeChange('detailed')}
            data-testid="detailed-view-option"
          >
            Detailed
          </div>
          <div
            className={`view-option ${viewMode === 'settings' ? 'active' : ''}`}
            onClick={() => onViewModeChange && onViewModeChange('settings')}
            data-testid="settings-view-option"
          >
            Settings
          </div>
        </div>

        <div className="action-buttons">
          <button
            className="refresh-button"
            onClick={onRefresh}
            title="Refresh dashboard data"
            data-testid="refresh-button"
          >
            🔄
          </button>

          {usingMockData && (
            <button
              className="magic-mcp-button"
              onClick={onRefresh}
              title="Using mock data - click to retry connecting to MCP server"
              data-testid="magic-mcp-button"
            >
              ✨
            </button>
          )}
        </div>
      </div>
    </header>
  );
};

export default EnhancedHeader;
