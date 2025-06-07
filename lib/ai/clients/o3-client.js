/**
 * @fileoverview
 * Placeholder Client - Not a real model
 * 
 * NOTE: This file represents a placeholder for a non-existent model.
 * There is no "o3" model available. This is intentionally left as a
 * placeholder to demonstrate what would be needed for model integration.
 */

class PlaceholderClient {
  constructor(config = {}) {
    this.config = config;
    console.warn('PlaceholderClient: This represents a non-existent model.');
  }

  /**
   * This method always returns an error since the model doesn't exist
   */
  async complete(prompt, options = {}) {
    return {
      success: false,
      error: 'This is a placeholder for a non-existent model. No actual functionality available.',
      model: 'placeholder',
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
   * Returns status indicating this is not a real model
   */
  getStatus() {
    return {
      provider: 'none',
      configured: false,
      models: [],
      warning: 'This is a placeholder client for a non-existent model. No actual functionality available.'
    };
  }
}

module.exports = PlaceholderClient; 