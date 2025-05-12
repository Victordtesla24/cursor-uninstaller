import { TextEncoder } from "util";
import React from "react";
import "@testing-library/jest-dom";

// Create a mock for the act function in a way that doesn't reference React directly
const mockAct = (callback) => {
  callback();
  return undefined;
};

// Import act directly from React for use with testing-library
jest.mock("@testing-library/react", () => {
  const original = jest.requireActual("@testing-library/react");
  return {
    ...original,
    // Use a mock act
    act: mockAct,
  };
});

// Mock react-dom/test-utils to redirect to our mock act
jest.mock("react-dom/test-utils", () => {
  const original = jest.requireActual("react-dom/test-utils");
  return {
    ...original,
    act: mockAct,
  };
});

// Properly mock React 18's createRoot for testing-library
jest.mock("react-dom/client", () => ({
  createRoot: (container) => ({
    render: (element) => {
      const ReactDOM = require("react-dom");
      ReactDOM.render(element, container);
    },
    unmount: () => {
      const ReactDOM = require("react-dom");
      ReactDOM.unmountComponentAtNode(container);
    },
  }),
}));

// Fix for testing-library/react-hooks to work with React 18
jest.mock("react-dom", () => {
  const originalModule = jest.requireActual("react-dom");
  const originalRender = originalModule.render;
  const originalUnmount = originalModule.unmountComponentAtNode;

  // Replace console.warn during render to suppress React 18 warning
  originalModule.render = (...args) => {
    const originalWarn = console.warn;
    console.warn = jest.fn();
    const result = originalRender(...args);
    console.warn = originalWarn;
    return result;
  };

  // Replace unmountComponentAtNode to suppress deprecation warning
  originalModule.unmountComponentAtNode = (container) => {
    const originalWarn = console.warn;
    console.warn = jest.fn();
    const result = originalUnmount(container);
    console.warn = originalWarn;
    return result;
  };

  return originalModule;
});

// Mock TextEncoder if not available
if (typeof global.TextEncoder === "undefined") {
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
if (typeof window !== "undefined") {
  Object.defineProperty(window, "matchMedia", {
    writable: true,
    value: jest.fn().mockImplementation((query) => ({
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
  if (
    args[0]?.includes &&
    (args[0].includes("ReactDOM.render is no longer supported in React 18") ||
      args[0].includes("MCP operation failed") ||
      args[0].includes("unmountComponentAtNode is deprecated") ||
      args[0].includes("ReactDOMTestUtils.act is deprecated") ||
      args[0].includes(
        "An update to Dashboard inside a test was not wrapped in act",
      ) ||
      args[0].includes(
        "An update to TestComponent inside a test was not wrapped in act",
      ) ||
      args[0].includes("not wrapped in act") ||
      // Filter styled-jsx warnings
      args[0].includes("Received `true` for a non-boolean attribute `jsx`") ||
      args[0].includes(
        "Received `true` for a non-boolean attribute `global`",
      ) ||
      // Filter expected API error messages from test cases
      args[0].includes("Error fetching dashboard data:") ||
      args[0].includes("Error fetching mock data:") ||
      args[0].includes("Error loading dashboard data:") ||
      args[0].includes("Failed to load dashboard data"))
  ) {
    // Suppress these specific warnings
    return;
  }
  originalConsoleError(...args);
};

// Mock console.warn for specific warnings
const originalConsoleWarn = console.warn;
console.warn = (...args) => {
  // Filter out specific warnings that come from mock API fallbacks
  if (
    args[0]?.includes &&
    (args[0].includes("Failed to fetch complete dashboard data") ||
      args[0].includes("Failed to parse MCP response"))
  ) {
    // These are expected in tests, so don't output them
    return;
  }
  originalConsoleWarn(...args);
};

// Mock console.log for specific test logs
const originalConsoleLog = console.log;
console.log = (...args) => {
  // Filter out specific log messages from tests
  if (
    typeof args[0] === "string" &&
    (args[0].includes("Could not find token budget edit controls") ||
      args[0].includes("Data source toggle not found") ||
      args[0].includes("Toggle button not found in current component state") ||
      args[0].includes("Theme toggle not available in loading state") ||
      args[0].includes("View tabs not available in loading state"))
  ) {
    // These are expected in tests, so don't output them
    return;
  }
  originalConsoleLog(...args);
};

// Mock process.env.NODE_ENV for testing environments
// This helps ensure libraries like React use development builds which include warnings

// Setup mock MCP client for tests
global.__MOCK_MCP_SUCCESS = true; // Flag to control mock success/failure
global.__MOCK_MCP_RESPONSE = {}; // Default response data

// Create mock MCP client with controlled behavior
global.__setupMockMcp = (options = {}) => {
  const {
    success = global.__MOCK_MCP_SUCCESS,
    response = global.__MOCK_MCP_RESPONSE,
    shouldThrow = false,
  } = options;

  // Mock functions with controlled behavior
  const createMockFn = () => {
    return jest.fn().mockImplementation((...args) => {
      if (shouldThrow) {
        throw new Error("Mock MCP error");
      }

      if (!success) {
        return Promise.reject(new Error("Mock MCP operation failed"));
      }

      return Promise.resolve(response);
    });
  };

  // Setup global MCP client
  global.window = global.window || {};
  global.window.__MCP_CLIENT = {
    useTool: createMockFn(),
    accessResource: createMockFn(),
    subscribe: jest.fn().mockReturnValue(jest.fn()), // Returns unsubscribe function
    batchResources: createMockFn(),
  };

  global.window.__MCP_INIT = jest.fn().mockImplementation(() => {
    if (!success) {
      return Promise.reject(new Error("Mock MCP initialization failed"));
    }
    return Promise.resolve(global.window.__MCP_CLIENT);
  });

  return global.window.__MCP_CLIENT;
};

// Setup default MCP mock for all tests
global.__setupMockMcp();

// Helper to reset mock between tests
afterEach(() => {
  if (global.window && global.window.__MCP_CLIENT) {
    Object.values(global.window.__MCP_CLIENT).forEach((mockFn) => {
      if (mockFn && typeof mockFn.mockClear === "function") {
        mockFn.mockClear();
      }
    });
  }

  // Reset to default settings
  global.__MOCK_MCP_SUCCESS = true;
  global.__MOCK_MCP_RESPONSE = {};
});

// jest.spyOn(console, 'log').mockImplementation(() => {});
// jest.spyOn(console, 'error').mockImplementation(() => {});
// jest.spyOn(console, 'warn').mockImplementation(() => {});
