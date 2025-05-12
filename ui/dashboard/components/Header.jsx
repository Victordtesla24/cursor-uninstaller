import React, { useState } from 'react';
import StyledJsx from './StyledJsx';

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
    <header className={`header ${className} ${isDarkTheme ? 'dark-theme' : ''}`}>
      <div className="header-title-area">
        <h1 className="header-title">Cline AI Dashboard</h1>
        <div className="header-subtitle">Token Optimization Monitor</div>
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

        <button
          className="theme-toggle"
          onClick={toggleTheme}
          title="Toggle dark/light theme"
          data-testid="theme-toggle"
        >
          {isDarkTheme ? '☀️' : '🌙'}
        </button>

        <button
          className="refresh-button"
          onClick={onRefresh}
          title="Refresh dashboard data"
          data-testid="refresh-button"
        >
          🔄
        </button>
      </div>

      <StyledJsx>{`
        .header {
          display: flex;
          justify-content: space-between;
          align-items: center;
          padding: 1rem 1.5rem;
          background-color: var(--card-background, #ffffff);
          border-radius: var(--border-radius-md, 8px);
          box-shadow: var(--shadow-sm, 0 1px 3px rgba(0,0,0,0.1));
          margin-bottom: 1.5rem;
        }

        .header.dark-theme {
          background-color: var(--dark-background, #1a1a1a);
          color: var(--dark-text, #f5f5f5);
        }

        .header-title {
          margin: 0;
          font-size: 1.5rem;
          font-weight: 600;
        }

        .header-subtitle {
          font-size: 0.875rem;
          color: var(--text-secondary, #666);
        }

        .header-actions {
          display: flex;
          align-items: center;
          gap: 1.5rem;
        }

        .system-status {
          display: flex;
          align-items: center;
          gap: 0.5rem;
          font-size: 0.875rem;
        }

        .status-indicator {
          width: 0.75rem;
          height: 0.75rem;
          border-radius: 50%;
        }

        .status-indicator.optimal {
          background-color: var(--success-color, #10b981);
        }

        .status-indicator.warning {
          background-color: var(--warning-color, #f59e0b);
        }

        .status-indicator.critical {
          background-color: var(--error-color, #ef4444);
        }

        .last-updated-text {
          font-size: 0.75rem;
          color: var(--text-secondary, #666);
          margin-left: 0.5rem;
        }

        .view-selector {
          display: flex;
          background-color: var(--background-color, #f1f5f9);
          border-radius: var(--border-radius-md, 8px);
          overflow: hidden;
        }

        .view-option {
          padding: 0.5rem 1rem;
          font-size: 0.875rem;
          cursor: pointer;
          transition: background-color 0.2s;
        }

        .view-option:hover {
          background-color: rgba(0, 0, 0, 0.05);
        }

        .view-option.active {
          background-color: var(--primary-color, #3b82f6);
          color: white;
        }

        .theme-toggle,
        .refresh-button {
          background: none;
          border: none;
          font-size: 1rem;
          cursor: pointer;
          width: 2rem;
          height: 2rem;
          display: flex;
          align-items: center;
          justify-content: center;
          border-radius: 50%;
          transition: background-color 0.2s;
        }

        .theme-toggle:hover,
        .refresh-button:hover {
          background-color: var(--background-color, #f1f5f9);
        }

        @media (max-width: 768px) {
          .header {
            flex-direction: column;
            align-items: flex-start;
            gap: 1rem;
          }

          .header-actions {
            width: 100%;
            flex-wrap: wrap;
            gap: 1rem;
          }

          .view-selector {
            width: 100%;
            justify-content: space-between;
          }

          .view-option {
            flex: 1;
            text-align: center;
          }
        }

        @media (max-width: 480px) {
          .system-status {
            width: 100%;
            justify-content: space-between;
          }

          .theme-toggle,
          .refresh-button {
            margin-left: auto;
          }
        }
      `}</StyledJsx>
    </header>
  );
};

// For test compatibility
export const __TEST_ONLY_toggleTheme = () => {
  document.body.classList.toggle('dark-theme');
};

// Change named export to default export
export default Header;
