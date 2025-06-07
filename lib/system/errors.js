/**
 * @fileoverview
 * Revolutionary Error Classes for the Cursor AI system.
 *
 * This module provides specialized error classes with enhanced debugging
 * capabilities for the revolutionary AI architecture.
 */

/**
 * Base error class for all Revolutionary AI system errors.
 */
class RevolutionaryError extends Error {
  constructor(message) {
    super(message);
    this.name = 'RevolutionaryError';
    this.timestamp = new Date().toISOString();
  }
}

/**
 * Error for AI API-related failures.
 */
class RevolutionaryApiError extends RevolutionaryError {
  constructor(message = 'An AI API error occurred.', details = {}) {
    super(message);
    this.name = 'RevolutionaryApiError';
    this.details = details;
  }
}

/**
 * Error for timeout scenarios.
 */
class RevolutionaryTimeoutError extends RevolutionaryError {
  constructor(message = 'The AI operation timed out.', duration = 0) {
    super(message);
    this.name = 'RevolutionaryTimeoutError';
    this.duration = duration;
  }
}

/**
 * Error for configuration issues.
 */
class RevolutionaryConfigError extends RevolutionaryError {
  constructor(message = 'A configuration error occurred.', key = '') {
    super(message);
    this.name = 'RevolutionaryConfigError';
    this.configKey = key;
  }
}

module.exports = {
  RevolutionaryError,
  RevolutionaryApiError,
  RevolutionaryTimeoutError,
  RevolutionaryConfigError
};
