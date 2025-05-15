/**
 * Utility functions for the UI Dashboard
 * 
 * Contains reusable utility functions for the UI components
 */

/**
 * Conditionally joins class names together
 * 
 * @param {...string} classes - Class names to join together
 * @returns {string} - Joined class names with extra spaces removed
 */
export function cn(...classes) {
  return classes.filter(Boolean).join(' ');
}

// Export commonly used functions
export default {
  cn
}; 