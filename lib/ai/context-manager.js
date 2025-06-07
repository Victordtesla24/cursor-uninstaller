/**
 * @fileoverview
 * Basic Context Manager - Simple context window management
 * 
 * NOTE: This is a basic implementation. Real context management is subject to:
 * - Model-specific context limits (e.g., 8K, 16K, 100K tokens)
 * - API rate limits
 * - No "unlimited" context exists
 */

class BasicContextManager {
  constructor(config = {}) {
    // Real context limits - no false "unlimited" claims
    this.config = {
      maxTokens: config.maxTokens || 8192, // Standard context limit
      warningThreshold: 0.8, // Warn at 80% usage
      ...config
    };
    
    this.currentContext = {
      messages: [],
      tokenCount: 0
    };
  }

  /**
   * Adds a message to context with token limit checking
   */
  addMessage(message) {
    if (!message || !message.content) {
      return { success: false, error: 'Invalid message' };
    }

    // Estimate tokens (rough estimate: 1 token ≈ 4 characters)
    const estimatedTokens = Math.ceil(message.content.length / 4);
    
    if (this.currentContext.tokenCount + estimatedTokens > this.config.maxTokens) {
      return { 
        success: false, 
        error: `Context limit exceeded. Current: ${this.currentContext.tokenCount}, Limit: ${this.config.maxTokens}` 
      };
    }

    this.currentContext.messages.push(message);
    this.currentContext.tokenCount += estimatedTokens;

    // Check if we're approaching the limit
    const usage = this.currentContext.tokenCount / this.config.maxTokens;
    if (usage > this.config.warningThreshold) {
      console.warn(`Context usage at ${(usage * 100).toFixed(1)}% - approaching limit`);
    }

    return { 
      success: true, 
      tokenCount: this.currentContext.tokenCount,
      usage: usage 
    };
  }

  /**
   * Clears the context
   */
  clearContext() {
    this.currentContext = {
      messages: [],
      tokenCount: 0
    };
    return { success: true };
  }

  /**
   * Gets current context status
   */
  getStatus() {
    return {
      messages: this.currentContext.messages.length,
      tokenCount: this.currentContext.tokenCount,
      maxTokens: this.config.maxTokens,
      usage: `${((this.currentContext.tokenCount / this.config.maxTokens) * 100).toFixed(1)}%`,
      warning: 'This is basic context management. Real usage depends on specific model limits.'
    };
  }

  /**
   * Trims context to fit within limits
   */
  trimContext() {
    if (this.currentContext.messages.length === 0) {
      return { success: true, trimmed: 0 };
    }

    let trimmed = 0;
    // Remove oldest messages until we're under 70% usage
    while (this.currentContext.tokenCount > this.config.maxTokens * 0.7 && 
           this.currentContext.messages.length > 1) {
      const removed = this.currentContext.messages.shift();
      const removedTokens = Math.ceil(removed.content.length / 4);
      this.currentContext.tokenCount -= removedTokens;
      trimmed++;
    }

    return { success: true, trimmed };
  }
}

module.exports = BasicContextManager; 