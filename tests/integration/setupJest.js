/* eslint-disable no-unused-vars */
// Jest Setup File

jest.setTimeout(10000); // Set a longer timeout for all tests

// Add automatic mock clearing
beforeEach(() => {
  jest.clearAllMocks();
}); 