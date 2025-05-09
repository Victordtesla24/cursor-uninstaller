import { TextEncoder } from 'util';
import React from 'react';
import '@testing-library/jest-dom';

// Properly mock React 18's createRoot for testing-library
jest.mock('react-dom/client', () => ({
  createRoot: (container) => ({
    render: (element) => {
      const ReactDOM = require('react-dom');
      ReactDOM.render(element, container);
    },
    unmount: () => {
      const ReactDOM = require('react-dom');
      ReactDOM.unmountComponentAtNode(container);
    }
  })
}));

// Fix for testing-library/react-hooks to work with React 18
jest.mock('react-dom', () => {
  const originalModule = jest.requireActual('react-dom');
  const originalRender = originalModule.render;

  // Replace console.warn during render to suppress React 18 warning
  originalModule.render = (...args) => {
    const originalWarn = console.warn;
    console.warn = jest.fn();
    const result = originalRender(...args);
    console.warn = originalWarn;
    return result;
  };

  return originalModule;
});

// Mock TextEncoder if not available
if (typeof global.TextEncoder === 'undefined') {
  global.TextEncoder = TextEncoder;
}

// Set up a global fetch mock
global.fetch = jest.fn(() => {
  return Promise.resolve({
    ok: true,
    json: () => Promise.resolve({}),
    text: () => Promise.resolve("{}"),
  });
});

// Add global mocks for browser APIs
if (typeof window !== 'undefined') {
  Object.defineProperty(window, 'matchMedia', {
    writable: true,
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
  });
}

// Mock console.error to catch and silence expected test warnings
const originalConsoleError = console.error;
console.error = (...args) => {
  // Filter out specific React 18 warnings we can't easily fix in tests
  if (args[0]?.includes && (
    args[0].includes('ReactDOM.render is no longer supported in React 18') ||
    args[0].includes('MCP operation failed')
  )) {
    // Suppress these specific warnings
    return;
  }
  originalConsoleError(...args);
};
