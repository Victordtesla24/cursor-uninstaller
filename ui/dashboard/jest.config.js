module.exports = {
  testEnvironment: 'jsdom',
  rootDir: '.',
  moduleDirectories: [
    'node_modules',
    '<rootDir>/node_modules'
  ],
  moduleNameMapper: {
    '\\\\.(css|less|scss)$': 'identity-obj-proxy',
    '^@/(.*)$': '<rootDir>/../../$1',
    '^./ui/index.js$': '<rootDir>/tests/mocks/ui/index.js',
    '^./ui/index.jsx$': '<rootDir>/tests/mocks/ui/index.js',
    '^./ui$': '<rootDir>/tests/mocks/ui/index.js',
    '^./ui/(.*)$': '<rootDir>/tests/mocks/ui/index.js',
    '^components/ui/(.*)$': '<rootDir>/tests/mocks/ui/index.js',
    '^components/ui$': '<rootDir>/tests/mocks/ui/index.js'
  },
  setupFilesAfterEnv: [
    '@testing-library/jest-dom',
    '<rootDir>/tests/setupTests.js',
    '<rootDir>/tests/setupJest.js'
  ],
  transform: {
    '^.+\\.(js|jsx)$': ['babel-jest', { configFile: './babel.config.js' }]
  },
  testMatch: [
    '<rootDir>/tests/**/*.test.{js,jsx}'
  ],
  globals: {
    __DEV__: true
  },
  testTimeout: 20000,
  maxWorkers: 1
};
