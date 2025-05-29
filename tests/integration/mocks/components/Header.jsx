import React from 'react';

const Header = ({
  title,
  subtitle,
  darkMode,
  onToggleDarkMode,
  onRefresh,
  refreshing,
  lastUpdated,
  connectionStatus,
  viewMode,
  onViewModeChange,
  viewModes = ['Overview', 'Detailed', 'Settings'],
  systemHealth,
  activeRequests,
  appName,
  isDarkMode,
  onThemeToggle,
  ...otherProps
}) => (
  <div data-testid="header" data-dark={darkMode ? 'true' : 'false'} data-viewmode={viewMode}>
    <h1>{title || appName || 'Cline AI Dashboard'}</h1>
    {subtitle && <p>{subtitle}</p>}
    {systemHealth && <div data-testid="system-health">System: {systemHealth}</div>}
    {activeRequests && <div data-testid="active-requests">Active: {activeRequests}</div>}
    <div className="view-mode-tabs">
      {viewModes.map((mode) => (
        <button
          key={mode}
          onClick={() => onViewModeChange?.(mode.toLowerCase())}
          data-testid={`view-mode-tab-${mode.toLowerCase()}`}
          className={viewMode === mode.toLowerCase() ? 'active' : ''}
        >
          {mode}
        </button>
      ))}
    </div>
    <div>
      <button onClick={onThemeToggle || onToggleDarkMode} data-testid="dark-mode-toggle">
        {(isDarkMode !== undefined ? isDarkMode : darkMode) ? 'Light Mode' : 'Dark Mode'}
      </button>
      <button onClick={onRefresh} disabled={refreshing} data-testid="refresh-button">
        {refreshing ? 'Refreshing...' : 'Refresh'}
      </button>
      {lastUpdated && <span data-testid="last-updated">Last updated: {lastUpdated}</span>}
      {connectionStatus && (
        <div data-testid="connection-status">
          Status: {connectionStatus.clineServerConnected ? 'Connected' : 'Disconnected'}
        </div>
      )}
    </div>
  </div>
);

export default Header; 