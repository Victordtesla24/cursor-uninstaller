# Dashboard Test Suite

This directory contains the test suite for the dashboard UI components. The tests are written using Jest and React Testing Library.

## Test Structure

- **Component Tests**: Tests for individual React components in the dashboard
- **API Tests**: Tests for the API interaction functionality
- **Coverage Tests**: Enhanced tests to improve code coverage

## Running Tests

### Run All Working Tests

To run all tests except the known problematic ones:

```bash
./run-working-tests.sh
```

### Run Individual Test Files

To run a specific test file:

```bash
npm test -- tests/TokenUtilization.test.js
```

### Run All Tests (Including Problematic Ones)

```bash
npm test
```

## Known Issues

1. **enhancedDashboardApi.test.js**:
   - The enhancedDashboardApi.test.js file contains tests that are currently failing due to issues with mock functions and Jest matchers
   - Some tests in this file experience timeout issues
   - This file is excluded in the `run-working-tests.sh` script

2. **Pretty Format Configuration**:
   - We've had to add special handling in setupJest.js to fix "Unknown option 'maxWidth'" errors
   - This issue is related to version compatibility between Jest and its dependencies

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