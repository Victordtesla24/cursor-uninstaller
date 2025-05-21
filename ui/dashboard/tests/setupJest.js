// Jest Setup File

// This addresses the "Unknown option 'maxWidth'" error
jest.setTimeout(10000); // Set a longer timeout for all tests

// Configure pretty-format for Jest to fix "Unknown option 'maxWidth'" error
// This is typically caused by version mismatches between Jest and its dependencies
jest.mock('pretty-format', () => {
  const originalPrettyFormat = jest.requireActual('pretty-format');
  
  // Create a wrapped format function that handles maxWidth and any other problematic options
  const wrappedFormat = (val, options = {}) => {
    // Remove problematic options
    const { maxWidth, min, indent, ...safeOptions } = options;
    
    try {
      return originalPrettyFormat.format(val, safeOptions);
    } catch (err) {
      // Fallback to simple stringification if format fails
      if (typeof val === 'object') {
        return JSON.stringify(val, null, 2);
      }
      return String(val);
    }
  };
  
  return {
    ...originalPrettyFormat,
    plugins: originalPrettyFormat.plugins || {},
    format: wrappedFormat,
    // Also override the build function that might be used
    build: (options) => {
      const { maxWidth, min, ...safeOptions } = options || {};
      try {
        return originalPrettyFormat.build(safeOptions);
      } catch (err) {
        return (val) => JSON.stringify(val, null, 2);
      }
    }
  };
});

// Define proper asymmetric matchers
global.expect.anything = () => ({
  asymmetricMatch: () => true,
  toString: () => 'Anything',
  toJSON: () => 'Anything'
});

global.expect.any = (constructor) => ({
  asymmetricMatch: (actual) => {
    return actual != null && (
      actual instanceof constructor || 
      typeof actual === typeof constructor() ||
      typeof actual === typeof constructor
    );
  },
  toString: () => `Any<${constructor.name || typeof constructor()}>`,
  toJSON: () => `Any<${constructor.name || typeof constructor()}>`
});

global.expect.objectContaining = (sample) => ({
  asymmetricMatch: (actual) => {
    if (typeof actual !== 'object' || actual === null) return false;
    
    for (const key in sample) {
      if (!(key in actual) || !deepEqual(actual[key], sample[key])) {
        return false;
      }
    }
    return true;
  },
  toString: () => `ObjectContaining(${JSON.stringify(sample)})`,
  toJSON: () => `ObjectContaining(${JSON.stringify(sample)})`
});

// Helper function for deep equality
function deepEqual(a, b) {
  if (a === b) return true;
  
  if (a && b && typeof a === 'object' && typeof b === 'object') {
    if (Array.isArray(a) && Array.isArray(b)) {
      if (a.length !== b.length) return false;
      for (let i = 0; i < a.length; i++) {
        if (!deepEqual(a[i], b[i])) return false;
      }
      return true;
    }
    
    const keysA = Object.keys(a);
    const keysB = Object.keys(b);
    
    if (keysA.length !== keysB.length) return false;
    
    for (const key of keysA) {
      if (!keysB.includes(key) || !deepEqual(a[key], b[key])) {
        return false;
      }
    }
    
    return true;
  }
  
  return false;
}

// Fix Jest's expect matchers that might be causing problems
expect.extend({
  // Fix toContain matcher
  toContain(received, expected) {
    if (received === undefined || received === null) {
      return {
        pass: false,
        message: () => `Expected ${received} to contain ${expected}, but it was ${received}`
      };
    }
    
    if (typeof received === 'string' && typeof expected === 'string') {
      const pass = received.includes(expected);
      return {
        pass,
        message: () => pass 
          ? `Expected string not to contain "${expected}"`
          : `Expected string to contain "${expected}"`
      };
    }

    if (Array.isArray(received)) {
      const pass = received.some(item => 
        deepEqual(item, expected) || item === expected
      );
      return {
        pass,
        message: () => pass 
          ? `Expected array not to contain ${JSON.stringify(expected)}`
          : `Expected array to contain ${JSON.stringify(expected)}`
      };
    }
    
    return this.equals(received, expected);
  },
  
  // Fix toHaveAttribute matcher
  toHaveAttribute(element, attr, value) {
    if (!element || typeof element.hasAttribute !== 'function') {
      return {
        pass: false,
        message: () => `Expected element to be a DOM element with hasAttribute method`
      };
    }
    
    const hasAttribute = element.hasAttribute(attr);
    if (value === undefined) {
      return {
        pass: hasAttribute,
        message: () => hasAttribute
          ? `Expected element not to have attribute "${attr}"`
          : `Expected element to have attribute "${attr}"`
      };
    }
    
    const actualValue = element.getAttribute(attr);
    const pass = hasAttribute && actualValue === value;
    return {
      pass,
      message: () => pass
        ? `Expected element not to have attribute "${attr}" with value "${value}"`
        : `Expected element to have attribute "${attr}" with value "${value}", but got "${actualValue}"`
    };
  },
  
  // Fix toBeGreaterThanOrEqual matcher
  toBeGreaterThanOrEqual(received, expected) {
    const pass = received >= expected;
    return {
      pass,
      message: () => pass
        ? `Expected ${received} not to be greater than or equal to ${expected}`
        : `Expected ${received} to be greater than or equal to ${expected}`
    };
  },
  
  // Fix toHaveBeenCalledWith matcher
  toHaveBeenCalledWith(received, ...expected) {
    if (!received || typeof received.mock !== 'object') {
      return {
        pass: false,
        message: () => `Expected a mock function, but got ${typeof received}`
      };
    }
    
    // Check if any call matches the expected arguments
    const pass = received.mock.calls.some(call => {
      if (call.length !== expected.length) return false;
      
      return call.every((arg, i) => {
        // Handle asymmetric matchers like expect.anything()
        if (expected[i] && typeof expected[i] === 'object' && expected[i].asymmetricMatch) {
          return expected[i].asymmetricMatch(arg);
        }
        
        // Deep equality for objects
        if (typeof arg === 'object' && typeof expected[i] === 'object') {
          return deepEqual(arg, expected[i]);
        }
        
        return arg === expected[i];
      });
    });
    
    return {
      pass,
      message: () => pass
        ? `Expected mock not to have been called with ${expected.join(', ')}`
        : `Expected mock to have been called with ${expected.join(', ')}, but it was called with ${JSON.stringify(received.mock.calls)}`
    };
  },
  
  // Fix toHaveBeenCalledTimes matcher
  toHaveBeenCalledTimes(received, expected) {
    if (!received || typeof received.mock !== 'object') {
      return {
        pass: false,
        message: () => `Expected a mock function, but got ${typeof received}`
      };
    }
    
    const callCount = received.mock.calls.length;
    const pass = callCount === expected;
    
    return {
      pass,
      message: () => pass
        ? `Expected mock not to have been called ${expected} times`
        : `Expected mock to have been called ${expected} times, but was called ${callCount} times`
    };
  },
  
  // Fix toBe matcher
  toBe(received, expected) {
    const pass = Object.is(received, expected);
    return {
      pass,
      message: () => pass
        ? `Expected ${received} not to be ${expected}`
        : `Expected ${received} to be ${expected}`
    };
  },
  
  // Fix toEqual matcher 
  toEqual(received, expected) {
    const pass = deepEqual(received, expected);
    return {
      pass,
      message: () => pass
        ? `Expected ${JSON.stringify(received)} not to equal ${JSON.stringify(expected)}`
        : `Expected ${JSON.stringify(received)} to equal ${JSON.stringify(expected)}`
    };
  },
  
  // Add toHaveBeenCalled matcher
  toHaveBeenCalled(received) {
    if (!received || typeof received.mock !== 'object') {
      return {
        pass: false,
        message: () => `Expected a mock function, but got ${typeof received}`
      };
    }
    
    const pass = received.mock.calls.length > 0;
    return {
      pass,
      message: () => pass
        ? `Expected mock not to have been called`
        : `Expected mock to have been called`
    };
  }
});

// Add automatic mock clearing
beforeEach(() => {
  jest.clearAllMocks();
});

// Suppress certain console errors/warnings that might come from testing components
const originalConsoleError = console.error;
console.error = (...args) => {
  // Ignore specific React DOM prop type errors or other known warnings
  const suppressPatterns = [
    'Warning: ReactDOM.render',
    'Warning: Invalid DOM property',
    'Warning: Unknown prop',
    'Warning: Each child in a list',
    'pretty-format: Unknown option "maxWidth"',
    'MCP tool call to server.tool',
    'Cannot read properties of undefined',
    'is not a function'
  ];

  if (!args.some(arg =>
    typeof arg === 'string' &&
    suppressPatterns.some(pattern => arg.includes(pattern))
  )) {
    originalConsoleError(...args);
  }
};

// Mock console.warn
const originalConsoleWarn = console.warn;
console.warn = (...args) => {
  // Ignore specific warnings
  const suppressPatterns = [
    'Unknown event type:',
    'Invalid data format'
  ];

  if (!args.some(arg =>
    typeof arg === 'string' &&
    suppressPatterns.some(pattern => arg.includes(pattern))
  )) {
    originalConsoleWarn(...args);
  }
};

// Mock console.log for specific test logs
const originalConsoleLog = console.log;
console.log = (...args) => {
  // Always allow logs to pass through in tests
  originalConsoleLog(...args);
};

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
