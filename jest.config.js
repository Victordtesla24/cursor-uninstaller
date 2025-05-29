module.exports = {
  testEnvironment: 'jsdom',
  rootDir: '.',
  moduleDirectories: [
    'node_modules',
    '<rootDir>/node_modules'
  ],
  moduleNameMapper: {
    '\\.(css|less|scss)$': 'identity-obj-proxy',
    '^@/(.*)$': '<rootDir>/src/$1',
    '^@components/(.*)$': '<rootDir>/src/components/$1',
    
    // Map relative imports from test files to the correct locations
    '^../mockApi$': '<rootDir>/tests/fixtures/mockApi.js',
    '^../mockApi.js$': '<rootDir>/tests/fixtures/mockApi.js',
    
    // Map dashboard lib imports
    '^../lib/enhancedDashboardApi$': '<rootDir>/src/dashboard/lib/enhancedDashboardApi.js',
    '^../index.jsx$': '<rootDir>/src/dashboard/index.jsx',
    
    // Map dashboard component imports (from dashboard files themselves)
    '^./components/CostTracker.jsx$': '<rootDir>/tests/integration/mocks/components/CostTracker.jsx',
    '^./components/MetricsPanel.jsx$': '<rootDir>/tests/integration/mocks/components/MetricsPanel.jsx',
    '^./components/TokenUtilization.jsx$': '<rootDir>/tests/integration/mocks/components/TokenUtilization.jsx',
    '^./components/UsageStats.jsx$': '<rootDir>/tests/integration/mocks/components/UsageStats.jsx',
    '^./components/ModelSelector.jsx$': '<rootDir>/tests/integration/mocks/components/ModelSelector.jsx',
    '^./components/SettingsPanel.jsx$': '<rootDir>/tests/integration/mocks/components/SettingsPanel.jsx',
    '^./components/Header.jsx$': '<rootDir>/tests/integration/mocks/components/MetricsPanel.jsx',
    
    // Map component imports from test files to mock components
    '^../components/TokenUtilization$': '<rootDir>/tests/integration/mocks/components/TokenUtilization.jsx',
    '^../components/TokenUtilization.jsx$': '<rootDir>/tests/integration/mocks/components/TokenUtilization.jsx',
    '^../components/SettingsPanel$': '<rootDir>/tests/integration/mocks/components/SettingsPanel.jsx',
    '^../components/SettingsPanel.jsx$': '<rootDir>/tests/integration/mocks/components/SettingsPanel.jsx',
    '^../components/ModelSelector$': '<rootDir>/tests/integration/mocks/components/ModelSelector.jsx',
    '^../components/ModelSelector.jsx$': '<rootDir>/tests/integration/mocks/components/ModelSelector.jsx',
    '^../components/UsageStats$': '<rootDir>/tests/integration/mocks/components/UsageStats.jsx',
    '^../components/UsageStats.jsx$': '<rootDir>/tests/integration/mocks/components/UsageStats.jsx',
    '^../components/UsageChart$': '<rootDir>/tests/integration/mocks/components/UsageChart.jsx',
    '^../components/UsageChart.jsx$': '<rootDir>/tests/integration/mocks/components/UsageChart.jsx',
    '^../components/CostTracker$': '<rootDir>/tests/integration/mocks/components/CostTracker.jsx',
    '^../components/CostTracker.jsx$': '<rootDir>/tests/integration/mocks/components/CostTracker.jsx',
    '^../components/MetricsPanel$': '<rootDir>/tests/integration/mocks/components/MetricsPanel.jsx',
    '^../components/MetricsPanel.jsx$': '<rootDir>/tests/integration/mocks/components/MetricsPanel.jsx',
    '^../components/EnhancedHeader$': '<rootDir>/tests/integration/mocks/components/MetricsPanel.jsx',
    '^../components/features/EnhancedAnalyticsDashboard$': '<rootDir>/tests/integration/mocks/components/MetricsPanel.jsx',
    
    '^../../src/components/ui$': '<rootDir>/src/components/ui',
    '^../../src/components/ui/(.*)$': '<rootDir>/src/components/ui/$1',
    
    // UI component mappings
    '^./ui/index.js$': '<rootDir>/tests/integration/mocks/ui/index.js',
    '^./ui/index.jsx$': '<rootDir>/tests/integration/mocks/ui/index.js',
    '^./ui$': '<rootDir>/tests/integration/mocks/ui/index.js',
    '^./ui/(.*)$': '<rootDir>/tests/integration/mocks/ui/index.js',
    '^components/ui/(.*)$': '<rootDir>/src/components/ui/$1',
    '^components/ui$': '<rootDir>/src/components/ui/index.js'
  },
  setupFilesAfterEnv: [
    '@testing-library/jest-dom',
    '<rootDir>/tests/integration/setupTests.js',
    '<rootDir>/tests/integration/setupJest.js'
  ],
  transform: {
    '^.+\\.(js|jsx)$': ['babel-jest', {
      presets: [
        ['@babel/preset-env', { targets: { node: 'current' } }],
        ['@babel/preset-react', { runtime: 'automatic' }]
      ],
    }]
  },
  testMatch: [
    '<rootDir>/tests/integration/**/*.test.js',
    '<rootDir>/tests/integration/**/*.test.jsx'
  ],
  transformIgnorePatterns: [
    'node_modules/(?!(.*\\.mjs$|@testing-library))'
  ],
  collectCoverage: true,
  coverageReporters: ['text', 'lcov', 'html'],
  coverageDirectory: 'coverage',
  coveragePathIgnorePatterns: [
    '/node_modules/',
    '/tests/',
    '/coverage/',
    '/docs/'
  ],
  testTimeout: 30000,
  prettierPath: null,
  roots: [
    '<rootDir>/src',
    '<rootDir>/tests'
  ],
  testEnvironmentOptions: {
    url: 'http://localhost'
  }
};
