/**
 * @fileoverview
 * Context Manager - Standard context management for the Revolutionary AI system.
 */

class ContextManager {
  constructor(config = {}) {
    this.config = config;
    this.maxContextSize = config.maxContextSize || 8192;
    this.contextHistory = [];
    console.log('[Context Manager] Initialized for standard context management');
  }

  async assembleContext(options) {
    const { code, instruction, language, files } = options;
    
    const context = {
      timestamp: new Date().toISOString(),
      code: code || '',
      instruction: instruction || '',
      language: language || 'javascript',
      files: files || [],
      metadata: {
        size: (code || '').length,
        complexity: this._calculateComplexity(code),
        type: this._detectContextType(instruction)
      }
    };

    // Add to history
    this.contextHistory.push(context);
    if (this.contextHistory.length > 100) {
      this.contextHistory.shift(); // Keep last 100 contexts
    }

    return context;
  }

  _calculateComplexity(code) {
    if (!code) return 'simple';
    const lines = code.split('\n').length;
    if (lines > 100) return 'complex';
    if (lines > 50) return 'medium';
    return 'simple';
  }

  _detectContextType(instruction) {
    if (!instruction) return 'completion';
    if (instruction.includes('refactor')) return 'refactoring';
    if (instruction.includes('debug')) return 'debugging';
    if (instruction.includes('explain')) return 'explanation';
    return 'general';
  }

  getContextHistory() {
    return this.contextHistory;
  }

  clearHistory() {
    this.contextHistory = [];
  }
}

module.exports = { ContextManager }; 