module.exports = {
  testEnvironment: 'jsdom',
  moduleNameMapper: {
    '\\.(css|less|scss)$': 'identity-obj-proxy'
  },
  setupFilesAfterEnv: [
    '@testing-library/jest-dom'
  ],
  transform: {
    '^.+\\.(js|jsx)$': 'babel-jest'
  },
  testMatch: [
    '**/tests/**/*.test.js',
    '**/tests/**/*.test.jsx'
  ],
  transformIgnorePatterns: [
    '/node_modules/(?!(@testing-library)/)'
  ],
  collectCoverage: true,
  coverageReporters: ['text', 'lcov'],
  coverageDirectory: 'coverage',
  coveragePathIgnorePatterns: [
    '/node_modules/',
    '/tests/',
    '/coverage/'
  ],
  verbose: true
};
