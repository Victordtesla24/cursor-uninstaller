import React, { useState } from 'react';

/**
 * Header component
 * Displays the dashboard title, system health indicator, and view mode controls
 * Implements UI elements for Cline AI dashboard navigation
 */
export const Header = ({
  systemHealth = 'optimal',
  activeRequests = 0,
  viewMode = 'overview',
  onViewModeChange,
  onRefresh,
  lastUpdated,
  className = ''
}) => {
  const [isDarkTheme, setIsDarkTheme] = useState(false);

  // Function to toggle theme
  const toggleTheme = () => {
    setIsDarkTheme(!isDarkTheme);
    document.body.classList.toggle('dark-theme');

    // For test compatibility
    if (typeof window !== 'undefined') {
      window.__TEST_ONLY_toggleTheme && window.__TEST_ONLY_toggleTheme();
    }
  };

  // Get system health indicator class based on status
  const getHealthClass = () => {
    switch (systemHealth) {
      case 'warning':
        return 'bg-warning';
      case 'critical':
        return 'bg-error';
      case 'optimal':
      default:
        return 'bg-success';
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
    <header className={`flex justify-between items-center mb-4 pb-3 border-b border-border ${className}`}>
      <div className="flex flex-col">
        <h1 className="text-2xl font-semibold m-0">
          Cline AI Dashboard
        </h1>
        <div className="text-sm text-muted-foreground">
          Token Usage Statistics & Performance Metrics
        </div>
      </div>

      <div className="flex items-center gap-4">
        <div className="flex items-center gap-2">
          <div className={`w-2.5 h-2.5 rounded-full ${getHealthClass()}`}></div>
          <span className="text-sm font-medium">{systemHealth}</span>
          {activeRequests > 0 && (
            <span className="text-sm text-muted-foreground ml-2">
              ({activeRequests} active {activeRequests === 1 ? 'request' : 'requests'})
            </span>
          )}
          <span className="text-sm text-muted-foreground ml-3">
            {getLastUpdatedText()}
          </span>
        </div>

        <div className="flex bg-card border border-border rounded-md overflow-hidden">
          <button
            className={`px-3 py-1 cursor-pointer text-sm font-medium transition-colors ${
              viewMode === 'overview'
                ? 'bg-primary text-primary-foreground'
                : 'hover:bg-background'
            }`}
            onClick={() => onViewModeChange('overview')}
            data-testid="overview-tab"
          >
            Overview
          </button>
          <button
            className={`px-3 py-1 cursor-pointer text-sm font-medium transition-colors ${
              viewMode === 'detailed'
                ? 'bg-primary text-primary-foreground'
                : 'hover:bg-background'
            }`}
            onClick={() => onViewModeChange('detailed')}
            data-testid="detailed-tab"
          >
            Detailed
          </button>
          <button
            className={`px-3 py-1 cursor-pointer text-sm font-medium transition-colors ${
              viewMode === 'settings'
                ? 'bg-primary text-primary-foreground'
                : 'hover:bg-background'
            }`}
            onClick={() => onViewModeChange('settings')}
            data-testid="settings-tab"
          >
            Settings
          </button>
        </div>

        <div className="flex gap-2">
          <button
            className="bg-card border border-border rounded-md px-3 py-1 cursor-pointer transition-all hover:bg-background hover:shadow-sm"
            onClick={onRefresh}
            data-testid="refresh-button"
          >
            Refresh
          </button>
          <button
            className="bg-primary-foreground border border-border rounded-md px-3 py-1 cursor-pointer transition-all hover:bg-primary hover:text-primary-foreground"
            onClick={toggleTheme}
            data-testid="theme-toggle"
          >
            {isDarkTheme ? 'Light Mode' : 'Dark Mode'}
          </button>
        </div>
      </div>
    </header>
  );
};

export default Header;
