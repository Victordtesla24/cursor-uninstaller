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
    '^../lib/config$': '<rootDir>/src/dashboard/lib/config.js',
    '^../lib/utils$': '<rootDir>/src/dashboard/lib/utils.js',
    '^../index.jsx$': '<rootDir>/src/dashboard/index.jsx',
    
    // Map remaining dashboard component imports (from dashboard files themselves)
    '^./components/ModelSelector.jsx$': '<rootDir>/tests/integration/mocks/components/ModelSelector.jsx',
    '^./components/Header.jsx$': '<rootDir>/tests/integration/mocks/components/Header.jsx',
    
    // Map component imports from test files to mock components
    '^../components/ModelSelector$': '<rootDir>/tests/integration/mocks/components/ModelSelector.jsx',
    '^../components/ModelSelector.jsx$': '<rootDir>/tests/integration/mocks/components/ModelSelector.jsx',
    '^../components/Header$': '<rootDir>/tests/integration/mocks/components/Header.jsx',
    '^../components/Header.jsx$': '<rootDir>/tests/integration/mocks/components/Header.jsx',
    
    '^../../src/components/ui$': '<rootDir>/src/components/ui',
    '^../../src/components/ui/(.*)$': '<rootDir>/src/components/ui/$1',
    
    // UI component mappings for enhanced dashboard (only for specific dashboard imports)
    '^../components/ui/index.js$': '<rootDir>/tests/integration/mocks/ui/index.js',
    '^../components/ui/index.jsx$': '<rootDir>/tests/integration/mocks/ui/index.js',
    '^../components/ui$': '<rootDir>/tests/integration/mocks/ui/index.js',
    '^./ui/index.js$': '<rootDir>/tests/integration/mocks/ui/index.js',
    '^./ui/index.jsx$': '<rootDir>/tests/integration/mocks/ui/index.js',
    '^./ui$': '<rootDir>/tests/integration/mocks/ui/index.js',
    '^components/ui/(.*)$': '<rootDir>/src/components/ui/$1',
    '^components/ui$': '<rootDir>/src/components/ui/index.js',
    
    // Map dashboard source files  
    '^../enhancedDashboard$': '<rootDir>/src/dashboard/enhancedDashboard.jsx',
    '^../enhancedDashboard.jsx$': '<rootDir>/src/dashboard/enhancedDashboard.jsx',
    
    // Map direct dashboard imports from tests
    '^../dashboard/enhancedDashboard$': '<rootDir>/src/dashboard/enhancedDashboard.jsx',
    '^../dashboard/enhancedDashboard.jsx$': '<rootDir>/src/dashboard/enhancedDashboard.jsx',
    
    // Map src imports from tests
    '^../../src/dashboard/enhancedDashboard$': '<rootDir>/src/dashboard/enhancedDashboard.jsx',
    '^../../src/dashboard/enhancedDashboard.jsx$': '<rootDir>/src/dashboard/enhancedDashboard.jsx',
  },
  setupFilesAfterEnv: [
    '@testing-library/jest-dom',
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
