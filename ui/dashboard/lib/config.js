/**
 * Dashboard Configuration
 *
 * Contains configuration settings for the Cline AI Dashboard
 * Defines refresh intervals, theme variables, and application settings
 */

// Dashboard configuration
export const dashboardConfig = {
  // Dashboard version
  version: '1.0.0',

  // Data refresh interval in milliseconds (5 seconds)
  refreshInterval: 5000,

  // Default settings
  defaultSettings: {
    autoModelSelection: true,
    cachingEnabled: true,
    contextWindowOptimization: true,
    outputMinimization: true,
    notifyOnLowBudget: true,
    safetyChecks: true
  },

  // Default token budgets
  defaultTokenBudgets: {
    codeCompletion: 300,
    errorResolution: 1500,
    architecture: 2000,
    thinking: 2000
  },

  // API endpoints (used in production, not in mock mode)
  endpoints: {
    dashboard: '/api/dashboard',
    models: '/api/models',
    settings: '/api/settings',
    tokenBudget: '/api/token-budget'
  }
};

// Theme configuration
export const themeConfig = {
  light: {
    // Base colors
    appBackground: '#f5f7fa',
    cardBackground: '#ffffff',
    textColor: '#1e293b',
    textSecondary: '#64748b',
    borderColor: '#e2e8f0',

    // Primary colors
    primaryColor: '#3b82f6',
    primaryLight: '#60a5fa',
    primaryDark: '#2563eb',

    // Status colors
    successColor: '#10b981',
    warningColor: '#f59e0b',
    errorColor: '#ef4444',
    errorLight: '#fee2e2',

    // UI elements
    shadowSm: '0 1px 2px 0 rgba(0, 0, 0, 0.05)',
    borderRadiusSm: '0.25rem',
    borderRadiusMd: '0.375rem',
    borderRadiusLg: '0.5rem',

    // Typography
    fontFamily: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif'
  },
  dark: {
    // Base colors
    appBackground: '#0f172a',
    cardBackground: '#1e293b',
    textColor: '#e2e8f0',
    textSecondary: '#94a3b8',
    borderColor: '#334155',

    // Primary colors
    primaryColor: '#3b82f6',
    primaryLight: '#60a5fa',
    primaryDark: '#2563eb',

    // Status colors
    successColor: '#10b981',
    warningColor: '#f59e0b',
    errorColor: '#ef4444',
    errorLight: '#450a0a',

    // UI elements
    shadowSm: '0 1px 2px 0 rgba(0, 0, 0, 0.1)',
    borderRadiusSm: '0.25rem',
    borderRadiusMd: '0.375rem',
    borderRadiusLg: '0.5rem',

    // Typography
    fontFamily: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif'
  }
};

export default {
  dashboardConfig,
  themeConfig
};
