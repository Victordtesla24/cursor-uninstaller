export const dashboardConfig = {
  version: '1.0.0',
  refreshInterval: 1000,
  maxRetries: 3,
  timeout: 5000,
  endpoints: {
    dashboard: '/api/dashboard',
    models: '/api/models',
    settings: '/api/settings'
  },
  defaultSettings: {
    darkMode: false,
    autoRefresh: true,
    cachingEnabled: true
  },
  features: {
    advancedAnalytics: true,
    modelComparison: true,
    budgetRecommendations: true
  }
};

export default dashboardConfig; 