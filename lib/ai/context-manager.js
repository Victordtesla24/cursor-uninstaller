/**
 * @fileoverview
 * Context Manager - Enhanced context window management with caching and preparation
 * 
 * NOTE: This is a production implementation. Real context management is subject to:
 * - Model-specific context limits (e.g., 8K, 16K, 100K tokens)
 * - API rate limits
 * - No "unlimited" context exists
 */

export default class BasicContextManager {
  constructor(config = {}) {
    // Real context limits - no false "unlimited" claims
    this.config = {
      maxTokens: config.maxTokens || 8192, // Standard context limit
      warningThreshold: 0.8, // Warn at 80% usage
      enableCaching: true,
      ...config
    };
    
    this.currentContext = {
      messages: [],
      tokenCount: 0
    };

    // Context cache for prepared contexts
    this.contextCache = new Map();
    this.initialized = false;
  }

  /**
   * Initialize the context manager
   */
  async initialize() {
    try {
      // Initialize any required resources
      this.contextCache.clear();
      this.initialized = true;
      return { success: true };
    } catch (error) {
      return { success: false, error: error.message };
    }
  }

  /**
   * Prepare context for a request
   * @param {Object} request - The request object
   * @returns {Promise<Object>} Prepared context
   */
  async prepareContext(request) {
    if (!request) {
      return null;
    }

    try {
      // Generate cache key
      const cacheKey = this._generateContextKey(request);
      
      // Check cache first
      if (this.config.enableCaching && this.contextCache.has(cacheKey)) {
        return this.contextCache.get(cacheKey);
      }

      // Prepare context based on request type
      const context = {
        language: request.language,
        timestamp: Date.now()
      };

      // Add code analysis if code is provided
      if (request.code) {
        context.codeAnalysis = this._analyzeCode(request.code, request.language);
        context.symbols = this._extractSymbols(request.code, request.language);
      }

      // Add framework detection
      if (request.language) {
        context.framework = this._detectFramework(request.code, request.language);
      }

      // Add position context if provided
      if (request.position) {
        context.position = request.position;
        context.contextLines = this._getContextLines(request.code, request.position);
      }

      // Cache the prepared context
      if (this.config.enableCaching) {
        this.contextCache.set(cacheKey, context);
      }

      return context;
    } catch (error) {
      console.warn('Context preparation failed:', error.message);
      return null;
    }
  }

  /**
   * Analyze code structure and patterns
   * @param {string} code - Code to analyze
   * @param {string} language - Programming language
   * @returns {Object} Analysis result
   */
  _analyzeCode(code, language) {
    if (!code || typeof code !== 'string') {
      return { complexity: 'unknown', patterns: [] };
    }

    const lines = code.split('\n');
    const analysis = {
      lineCount: lines.length,
      complexity: 'simple',
      patterns: [],
      hasImports: false,
      hasExports: false,
      hasFunctions: false,
      hasClasses: false
    };

    // Simple pattern detection
    const patterns = {
      javascript: {
        imports: /^import\s+.+from\s+['"`].+['"`]/,
        exports: /^export\s+/,
        functions: /function\s+\w+|const\s+\w+\s*=\s*\(|=>\s*{/,
        classes: /^class\s+\w+/,
        async: /async\s+function|async\s+\(/
      },
      python: {
        imports: /^from\s+.+import|^import\s+/,
        functions: /^def\s+\w+\(/,
        classes: /^class\s+\w+/,
        decorators: /^@\w+/
      }
    };

    const langPatterns = patterns[language] || patterns.javascript;

    for (const line of lines) {
      const trimmedLine = line.trim();
      if (!trimmedLine || trimmedLine.startsWith('//') || trimmedLine.startsWith('#')) {
        continue;
      }

      // Check for various patterns
      if (langPatterns.imports && langPatterns.imports.test(trimmedLine)) {
        analysis.hasImports = true;
        analysis.patterns.push('imports');
      }
      if (langPatterns.exports && langPatterns.exports.test(trimmedLine)) {
        analysis.hasExports = true;
        analysis.patterns.push('exports');
      }
      if (langPatterns.functions && langPatterns.functions.test(trimmedLine)) {
        analysis.hasFunctions = true;
        analysis.patterns.push('functions');
      }
      if (langPatterns.classes && langPatterns.classes.test(trimmedLine)) {
        analysis.hasClasses = true;
        analysis.patterns.push('classes');
      }
    }

    // Determine complexity
    if (analysis.lineCount > 50 || analysis.hasClasses) {
      analysis.complexity = 'complex';
    } else if (analysis.lineCount > 20 || analysis.hasFunctions) {
      analysis.complexity = 'moderate';
    }

    return analysis;
  }

  /**
   * Extract symbols from code
   * @param {string} code - Code to analyze
   * @param {string} language - Programming language
   * @returns {Array} Array of symbol objects
   */
  _extractSymbols(code, language) {
    if (!code || typeof code !== 'string') {
      return [];
    }

    const symbols = [];
    const lines = code.split('\n');

    for (let i = 0; i < lines.length; i++) {
      const line = lines[i].trim();
      let match;

      // JavaScript/TypeScript symbols
      if (language === 'javascript' || language === 'typescript') {
        // Function declarations
        if ((match = line.match(/function\s+(\w+)\s*\(/))) {
          symbols.push({
            name: match[1],
            kind: 'function',
            line: i + 1,
            detail: line
          });
        }
        // Arrow functions
        if ((match = line.match(/const\s+(\w+)\s*=\s*\(/))) {
          symbols.push({
            name: match[1],
            kind: 'function',
            line: i + 1,
            detail: line
          });
        }
        // Class declarations
        if ((match = line.match(/class\s+(\w+)/))) {
          symbols.push({
            name: match[1],
            kind: 'class',
            line: i + 1,
            detail: line
          });
        }
        // Variable declarations
        if ((match = line.match(/(?:const|let|var)\s+(\w+)/))) {
          symbols.push({
            name: match[1],
            kind: 'variable',
            line: i + 1,
            detail: line
          });
        }
      }

      // Python symbols
      if (language === 'python') {
        // Function definitions
        if ((match = line.match(/def\s+(\w+)\s*\(/))) {
          symbols.push({
            name: match[1],
            kind: 'function',
            line: i + 1,
            detail: line
          });
        }
        // Class definitions
        if ((match = line.match(/class\s+(\w+)/))) {
          symbols.push({
            name: match[1],
            kind: 'class',
            line: i + 1,
            detail: line
          });
        }
      }
    }

    return symbols.slice(0, 10); // Limit to first 10 symbols
  }

  /**
   * Detect framework from code
   * @param {string} code - Code to analyze
   * @param {string} language - Programming language
   * @returns {Object} Framework detection result
   */
  _detectFramework(code, language) {
    if (!code || typeof code !== 'string') {
      return { name: 'unknown', confidence: 0 };
    }

    const frameworks = {
      javascript: [
        { name: 'React', patterns: [/import.*react/i, /from\s+['"`]react['"`]/i, /jsx/i] },
        { name: 'Vue', patterns: [/import.*vue/i, /<template>/i, /<script>/i] },
        { name: 'Express', patterns: [/express\(\)/i, /app\.get|app\.post/i] },
        { name: 'Node.js', patterns: [/require\(/i, /module\.exports/i] }
      ],
      python: [
        { name: 'Django', patterns: [/from django/i, /django\./i] },
        { name: 'Flask', patterns: [/from flask/i, /@app\.route/i] },
        { name: 'FastAPI', patterns: [/from fastapi/i, /@app\./i] }
      ]
    };

    const langFrameworks = frameworks[language] || [];
    
    for (const framework of langFrameworks) {
      const matches = framework.patterns.filter(pattern => pattern.test(code));
      if (matches.length > 0) {
        return {
          name: framework.name,
          confidence: matches.length / framework.patterns.length
        };
      }
    }

    return { name: 'unknown', confidence: 0 };
  }

  /**
   * Get context lines around a position
   * @param {string} code - Code to analyze
   * @param {Object} position - Position object
   * @returns {Array} Context lines
   */
  _getContextLines(code, position) {
    if (!code || !position || typeof position.line !== 'number') {
      return [];
    }

    const lines = code.split('\n');
    const lineIndex = position.line;
    const contextRadius = 3;

    const start = Math.max(0, lineIndex - contextRadius);
    const end = Math.min(lines.length, lineIndex + contextRadius + 1);

    return lines.slice(start, end).map((line, index) => ({
      lineNumber: start + index,
      text: line,
      isCurrent: start + index === lineIndex
    }));
  }

  /**
   * Generate cache key for context
   * @param {Object} request - Request object
   * @returns {string} Cache key
   */
  _generateContextKey(request) {
    const key = JSON.stringify({
      code: request.code?.slice(0, 100), // First 100 chars for caching
      language: request.language,
      type: request.type
    });
    return Buffer.from(key).toString('base64').slice(0, 32);
  }

  /**
   * Clear context cache
   */
  clearCache() {
    this.contextCache.clear();
    return { success: true, cleared: true };
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
