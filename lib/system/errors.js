/**
 * @fileoverview
 * Basic Error Classes for the development tools.
 *
 * This module provides standard error classes for error handling.
 */

/**
 * Base error class for all system errors.
 */
class BasicError extends Error {
  constructor(message) {
    super(message);
    this.name = 'BasicError';
    this.timestamp = new Date().toISOString();
  }
}

/**
 * Error for API-related failures.
 */
class ApiError extends BasicError {
  constructor(message = 'An API error occurred.', details = {}) {
    super(message);
    this.name = 'ApiError';
    this.details = details;
  }
}

/**
 * Error for timeout scenarios.
 */
class TimeoutError extends BasicError {
  constructor(message = 'The operation timed out.', duration = 0) {
    super(message);
    this.name = 'TimeoutError';
    this.duration = duration;
  }
}

/**
 * Error for configuration issues.
 */
class ConfigError extends BasicError {
  constructor(message = 'A configuration error occurred.', key = '') {
    super(message);
    this.name = 'ConfigError';
    this.configKey = key;
  }
}

module.exports = {
  BasicError,
  ApiError,
  TimeoutError,
  ConfigError
};
