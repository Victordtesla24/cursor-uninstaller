/**
 * @fileoverview
 * Basic Context Manager - Manages context for AI operations
 *
 * Provides simple context assembly and management.
 * NOTE: This is a basic implementation without actual AI integration.
 */

class ContextManager {
  constructor(config = {}) {
    this.config = config;
    this.maxContextSize = config.maxContextSize || 4096; // tokens
  }

  /**
   * Assembles context from provided inputs
   * @param {object} options - Context options
   * @returns {object} Assembled context
   */
  async assembleContext(options = {}) {
    const { code, language, instruction, additionalContext, conversationHistory } = options;

    const context = {
      timestamp: new Date().toISOString(),
      parts: []
    };

    // Add code context if provided
    if (code) {
      context.parts.push({
        type: 'code',
        content: code,
        language: language || 'unknown'
      });
    }

    // Add instruction if provided
    if (instruction) {
      context.parts.push({
        type: 'instruction',
        content: instruction
      });
    }

    // Add additional context if provided
    if (additionalContext) {
      context.parts.push({
        type: 'context',
        content: additionalContext
      });
    }

    // Add conversation history if provided
    if (conversationHistory && Array.isArray(conversationHistory)) {
      context.conversationHistory = conversationHistory.slice(-10); // Keep last 10 messages
    }

    // Basic size estimation (character count as proxy for tokens)
    const totalSize = JSON.stringify(context).length;
    context.estimatedTokens = Math.ceil(totalSize / 4); // Rough estimation

    return context;
  }

  /**
   * Checks if context is within size limits
   * @param {object} context - Context to check
   * @returns {boolean} Whether context is within limits
   */
  isWithinLimits(context) {
    return context.estimatedTokens <= this.maxContextSize;
  }

  /**
   * Truncates context to fit within limits
   * @param {object} context - Context to truncate
   * @returns {object} Truncated context
   */
  truncateContext(context) {
    if (this.isWithinLimits(context)) {
      return context;
    }

    // Simple truncation strategy - remove oldest conversation history
    if (context.conversationHistory && context.conversationHistory.length > 0) {
      context.conversationHistory = context.conversationHistory.slice(-5);
    }

    // If still too large, truncate parts
    if (!this.isWithinLimits(context) && context.parts.length > 0) {
      context.parts = context.parts.slice(-2); // Keep only last 2 parts
    }

    context.truncated = true;
    return context;
  }
}

module.exports = ContextManager; 