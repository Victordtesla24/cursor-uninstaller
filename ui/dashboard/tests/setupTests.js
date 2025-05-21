import { TextEncoder } from "util";
import React from "react";
import "@testing-library/jest-dom";
import * as componentMocks from "./mocks/componentMocks";

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

// Mock UI components from @/components/ui/...
jest.mock("../../../components/ui/card", () => {
  const Card = ({ className, children, ...props }) => (
    <div className={`mock-card ${className || ''}`} {...props}>{children}</div>
  );
  const CardHeader = ({ className, children, ...props }) => (
    <div className={`mock-card-header ${className || ''}`} {...props}>{children}</div>
  );
  const CardTitle = ({ className, children, ...props }) => (
    <h3 className={`mock-card-title ${className || ''}`} {...props}>{children}</h3>
  );
  const CardDescription = ({ className, children, ...props }) => (
    <p className={`mock-card-description ${className || ''}`} {...props}>{children}</p>
  );
  const CardContent = ({ className, children, ...props }) => (
    <div className={`mock-card-content ${className || ''}`} {...props}>{children}</div>
  );
  const CardFooter = ({ className, children, ...props }) => (
    <div className={`mock-card-footer ${className || ''}`} {...props}>{children}</div>
  );
  return { Card, CardHeader, CardTitle, CardDescription, CardContent, CardFooter };
});

jest.mock("../../../components/ui/tooltip", () => {
  const TooltipProvider = ({ children }) => <>{children}</>;
  const Tooltip = ({ children }) => <>{children}</>;
  const TooltipTrigger = ({ className, children, ...props }) => <span className={`mock-tooltip-trigger ${className || ''}`} {...props}>{children}</span>;
  const TooltipContent = ({ className, children, ...props }) => <div className={`mock-tooltip-content ${className || ''}`} {...props}>{children}</div>;
  return { TooltipProvider, Tooltip, TooltipTrigger, TooltipContent };
});

jest.mock("../../../components/ui/badge", () => ({
  Badge: ({ className, children, ...props }) => <div className={`mock-badge ${className || ''}`} {...props}>{children}</div>
}));

jest.mock("../../../components/ui/separator", () => ({
  Separator: ({ className, ...props }) => <hr className={`mock-separator ${className || ''}`} {...props} />
}));

jest.mock("../../../components/ui/button", () => ({
  Button: ({ className, children, ...props }) => <button className={`mock-button ${className || ''}`} {...props}>{children}</button>
}));

jest.mock("../../../components/ui/progress", () => ({
  Progress: ({ className, value, ...props }) => <div className={`mock-progress ${className || ''}`} role="progressbar" aria-valuenow={value} {...props}>Progress: {value}%</div>
}));

jest.mock("../../../components/ui/switch", () => ({
  Switch: ({ className, checked, ...props }) => <input type="checkbox" className={`mock-switch ${className || ''}`} defaultChecked={checked} {...props} />
}));

jest.mock("../../../components/ui/input", () => ({
  Input: ({ className, ...props }) => <input className={`mock-input ${className || ''}`} {...props} />
}));

jest.mock("../../../components/ui/label", () => ({
  Label: ({ className, children, ...props }) => <label className={`mock-label ${className || ''}`} {...props}>{children}</label>
}));

jest.mock("../../../components/ui/collapsible", () => {
  const Collapsible = ({ className, children, ...props }) => <div className={`mock-collapsible ${className || ''}`} {...props}>{children}</div>;
  const CollapsibleTrigger = ({ className, children, ...props }) => <button className={`mock-collapsible-trigger ${className || ''}`} {...props}>{children}</button>;
  const CollapsibleContent = ({ className, children, ...props }) => <div className={`mock-collapsible-content ${className || ''}`} {...props}>{children}</div>;
  return { Collapsible, CollapsibleTrigger, CollapsibleContent };
});

jest.mock("../../../components/ui/accordion", () => {
   const Accordion = ({ className, children, ...props }) => <div className={`mock-accordion ${className || ''}`} {...props}>{children}</div>;
   const AccordionItem = ({ className, children, ...props }) => <div className={`mock-accordion-item ${className || ''}`} {...props}>{children}</div>;
   const AccordionTrigger = ({ className, children, ...props }) => <button className={`mock-accordion-trigger ${className || ''}`} {...props}>{children}</button>;
   const AccordionContent = ({ className, children, ...props }) => <div className={`mock-accordion-content ${className || ''}`} {...props}>{children}</div>;
   return { Accordion, AccordionItem, AccordionTrigger, AccordionContent };
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

// Global mocks
global.ResizeObserver = jest.fn().mockImplementation(() => ({
  observe: jest.fn(),
  unobserve: jest.fn(),
  disconnect: jest.fn(),
}));
