/**
 * Jest Setup File
 * Sets environment variables and global configurations before tests run
 */

// Set NODE_ENV to test to disable long-running intervals during tests
process.env.NODE_ENV = 'test';

// Suppress console warnings during tests unless explicitly needed
if (!process.env.JEST_VERBOSE) {
  const originalWarn = console.warn;
  console.warn = (...args) => {
    // Only show warnings that don't match expected test patterns
    const message = args.join(' ');
    if (!message.includes('Request') && !message.includes('cancelled')) {
      originalWarn.apply(console, args);
    }
  };
}
