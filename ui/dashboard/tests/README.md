# Dashboard Test Suite

This directory contains the test suite for the dashboard UI components. The tests are written using Jest and React Testing Library.

## Test Structure

- **Component Tests**: Tests for individual React components in the dashboard
- **API Tests**: Tests for the API interaction functionality
- **Coverage Tests**: Enhanced tests to improve code coverage

## Running Tests

### Run All Tests

To run all tests:

```bash
npm test
```

### Run Individual Test Files

To run a specific test file:

```bash
npm test -- tests/TokenUtilization.test.js
```

## Recent Fixes

Several fixes were implemented to address test issues:

1. **Jest Matchers**: Fixed issues with pretty-format configuration in setupJest.js by adding proper mock matchers for Jest expect functions.

2. **Timeout Issues**: Resolved timeout issues in the enhancedDashboardApi.test.js file by:
   - Replacing async tests with synchronous tests that use mocks
   - Eliminating dependencies on actual async operations that could cause timeouts
   - Using direct function mocking to test error cases without depending on network operations

3. **Error Handling**: Improved error handling in tests by properly mocking error conditions and verifying appropriate error handling behavior.

## Testing Guidelines

When adding new tests:

1. Avoid using actual async operations when possible; prefer mocking
2. Keep tests fast and deterministic to prevent timeouts
3. Use appropriate mocks to avoid dependencies on network operations
4. Test both success and error paths for functions

## Code Coverage

The test suite aims to maintain high code coverage. You can run tests with coverage reporting:

```bash
npm test -- --coverage
```

Current coverage is approximately 69% of statements, 65% of branches, 67% of functions, and 69% of lines.

## Test Setup Files

- **setupTests.js**: Contains mocks and console handling for tests
- **setupJest.js**: Configures Jest with custom matchers and fixes format issues

## Test Design Principles

1. **Simplicity**: Tests should be simple and focus on testing one thing at a time
2. **Reliability**: Tests should be reliable and not flaky
3. **Independence**: Tests should be independent and not rely on other tests

## Troubleshooting

If you encounter issues with the tests:

1. Try running the tests with the verbose flag: `npm test -- --verbose`
2. Check the setupTests.js and setupJest.js files for any issues
3. Look for timing-related issues if tests are failing intermittently