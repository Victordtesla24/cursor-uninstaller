/**
 * Testing utilities to help simplify test assertions and workaround common issues
 */

/**
 * Safely check if a DOM element has an attribute with a specific value
 * This avoids the pretty-format maxWidth error by not using Jest's toHaveAttribute
 * @param {HTMLElement} element - The DOM element to check
 * @param {string} attributeName - The name of the attribute to check
 * @param {string} [expectedValue] - Optional expected value of the attribute
 * @returns {boolean} True if the element has the attribute (with the expected value if provided)
 */
export const hasAttribute = (element, attributeName, expectedValue) => {
  if (!element || typeof element.hasAttribute !== 'function') {
    return false;
  }
  
  const hasAttr = element.hasAttribute(attributeName);
  if (expectedValue === undefined) {
    return hasAttr;
  }
  
  return hasAttr && element.getAttribute(attributeName) === expectedValue;
};

/**
 * Safely check if a string contains a substring
 * This avoids the pretty-format maxWidth error by not using Jest's toContain
 * @param {string} text - The string to search in
 * @param {string} substring - The substring to search for
 * @returns {boolean} True if the text contains the substring
 */
export const textContains = (text, substring) => {
  if (typeof text !== 'string' || typeof substring !== 'string') {
    return false;
  }
  
  return text.includes(substring);
};

/**
 * Safely check DOM text content for a specific value
 * @param {HTMLElement} element - The DOM element to check
 * @param {string} expectedText - The text to search for
 * @returns {boolean} True if element's text content contains the expected text
 */
export const elementContainsText = (element, expectedText) => {
  if (!element || typeof element.textContent !== 'string') {
    return false;
  }
  
  return element.textContent.includes(expectedText);
};

/**
 * Safely check if a mock function was called a specific number of times
 * @param {Function} mockFn - The mock function to check
 * @param {number} expectedTimes - The expected number of calls
 * @returns {boolean} True if the mock was called the expected number of times
 */
export const wasCalledTimes = (mockFn, expectedTimes) => {
  if (!mockFn || typeof mockFn.mock !== 'object') {
    return false;
  }
  
  return mockFn.mock.calls.length === expectedTimes;
};

/**
 * Safely check if a mock function was called with specific arguments
 * @param {Function} mockFn - The mock function to check
 * @param {...any} expectedArgs - The expected arguments
 * @returns {boolean} True if the mock was called with the expected arguments
 */
export const wasCalledWith = (mockFn, ...expectedArgs) => {
  if (!mockFn || typeof mockFn.mock !== 'object') {
    return false;
  }
  
  return mockFn.mock.calls.some(callArgs => {
    if (callArgs.length !== expectedArgs.length) {
      return false;
    }
    
    // Simple comparison of args
    return callArgs.every((arg, index) => {
      if (typeof arg === 'object' && arg !== null && typeof expectedArgs[index] === 'object' && expectedArgs[index] !== null) {
        // For objects, check if all expected keys are in the actual object with the same values
        return Object.entries(expectedArgs[index]).every(([key, value]) => 
          Object.prototype.hasOwnProperty.call(arg, key) && arg[key] === value
        );
      }
      return arg === expectedArgs[index];
    });
  });
};

/**
 * Safely compare two objects for equality
 * @param {object} actual - The actual object
 * @param {object} expected - The expected object
 * @returns {boolean} True if the objects have the same keys and values
 */
export const objectsAreEqual = (actual, expected) => {
  if (typeof actual !== 'object' || actual === null || 
      typeof expected !== 'object' || expected === null) {
    return actual === expected;
  }
  
  const actualKeys = Object.keys(actual);
  const expectedKeys = Object.keys(expected);
  
  if (actualKeys.length !== expectedKeys.length) {
    return false;
  }
  
  return expectedKeys.every(key => {
    if (typeof expected[key] === 'object' && expected[key] !== null &&
        typeof actual[key] === 'object' && actual[key] !== null) {
      return objectsAreEqual(actual[key], expected[key]);
    }
    return actual[key] === expected[key];
  });
};