/**
 * @fileoverview
 * Placeholder Client - Template for AI model integration
 * 
 * NOTE: This is a placeholder showing how to structure an AI client.
 * No "o3" model exists. To implement real functionality:
 * - Replace with actual API client (OpenAI, Anthropic, etc.)
 * - Add proper API key handling
 * - Implement real API calls
 */

class PlaceholderClient {
  constructor(config = {}) {
    this.config = config;
    console.warn('PlaceholderClient: This is a template client with no real functionality.');
  }

  /**
   * Placeholder method - implement with real API calls
   */
  async complete(prompt, options = {}) {
    return {
      success: false,
      error: 'This is a placeholder client. Please implement real API integration.',
      isPlaceholder: true
    };
  }

  /**
   * Always returns false since this isn't a real client
   */
  isConfigured() {
    return false;
  }

  /**
   * Returns status indicating this is a placeholder
   */
  getStatus() {
    return {
      provider: 'none',
      configured: false,
      models: [],
      warning: 'This is a placeholder client. Implement real API integration for actual functionality.'
    };
  }
}

module.exports = PlaceholderClient; 