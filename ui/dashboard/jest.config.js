module.exports = {
  testEnvironment: 'jsdom',
  rootDir: '.',
  moduleDirectories: [
    'node_modules',
    '<rootDir>/node_modules'
  ],
  moduleNameMapper: {
    '\\.(css|less|scss)$': 'identity-obj-proxy',
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
  ]
};
