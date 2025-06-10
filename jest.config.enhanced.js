// Enhanced Jest Configuration for ES Modules
export default {
  testEnvironment: 'node',
  rootDir: '.',
  preset: null,
  moduleNameMapper: {
    '^(\\.{1,2}/.*)\\.js$': '$1'
  },
  transform: {},
  moduleDirectories: [
    'node_modules',
    '<rootDir>/node_modules'
  ],
  setupFilesAfterEnv: [
    '<rootDir>/tests/integration/setupJest.js'
  ],
  testMatch: [
    '<rootDir>/tests/unit/**/*.test.js',
    '<rootDir>/tests/integration/**/*.test.js'
  ],
  transformIgnorePatterns: [
    'node_modules/(?!(.*\\.mjs$))'
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
    '<rootDir>/tests'
  ]
};
