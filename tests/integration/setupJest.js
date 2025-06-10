 
// Jest Setup File for ES Modules

import { jest, beforeEach } from '@jest/globals';

jest.setTimeout(10000); // Set a longer timeout for all tests

// Add automatic mock clearing
beforeEach(() => {
  jest.clearAllMocks();
});
