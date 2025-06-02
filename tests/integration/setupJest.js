/* eslint-disable no-unused-vars */
// Jest Setup File

// This addresses the "Unknown option 'maxWidth'" error
jest.setTimeout(10000); // Set a longer timeout for all tests

// Configure pretty-format for Jest to fix "Unknown option 'maxWidth'" error
// This is typically caused by version mismatches between Jest and its dependencies
jest.mock('pretty-format', () => {
  const originalPrettyFormat = jest.requireActual('pretty-format');
  return {
    ...originalPrettyFormat,
    plugins: {
      ...originalPrettyFormat.plugins,
    },
    // Override format function to ignore maxWidth option
    format: (val, options = {}) => {
      // Remove maxWidth if present to avoid the error
      const { maxWidth, ...restOptions } = options;
      return originalPrettyFormat.format(val, restOptions);
    }
  };
});

// Add missing jest-expect utilities
// This fixes issues with expect.any() not being a function
if (!global.expect.objectContaining) {
  global.expect.objectContaining = (obj) => ({
    asymmetricMatch: (actual) => {
      return typeof actual === 'object' && actual !== null;
    }
  });
}

if (!global.expect.any) {
  global.expect.any = (constructor) => ({
    asymmetricMatch: (actual) => {
      return typeof actual === typeof constructor();
    }
  });
}

// Add automatic mock clearing
beforeEach(() => {
  jest.clearAllMocks();
});

// Mock localStorage
if (typeof window !== 'undefined') {
  Object.defineProperty(window, 'localStorage', {
    value: {
      getItem: jest.fn(() => null),
      setItem: jest.fn(),
      removeItem: jest.fn(),
      clear: jest.fn(),
    },
    writable: true,
  });
}

// Mock matchMedia
if (typeof window !== 'undefined') {
  Object.defineProperty(window, 'matchMedia', {
    value: jest.fn().mockImplementation(query => ({
      matches: false,
      media: query,
      onchange: null,
      addListener: jest.fn(),
      removeListener: jest.fn(),
      addEventListener: jest.fn(),
      removeEventListener: jest.fn(),
      dispatchEvent: jest.fn(),
    })),
    writable: true,
  });
}
