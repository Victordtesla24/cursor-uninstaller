module.exports = {
  testEnvironment: 'jsdom',
  rootDir: '.',
  moduleDirectories: [
    'node_modules',
    '<rootDir>/node_modules'
  ],
  moduleNameMapper: {
    '\\.(css|less|scss)$': 'identity-obj-proxy'
  },
  setupFilesAfterEnv: [
    '@testing-library/jest-dom',
    '<rootDir>/tests/setupTests.js'
  ],
  transform: {
    '^.+\\.jsx?$': ['babel-jest', {
      presets: [
        '@babel/preset-env',
        '@babel/preset-react'
      ],
    }]
  },
  testMatch: [
    '<rootDir>/tests/**/*.test.js',
    '<rootDir>/tests/**/*.test.jsx',
    '<rootDir>/../tests/**/*.test.js',
    '<rootDir>/../tests/**/*.test.jsx'
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
