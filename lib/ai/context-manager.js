/**
 * Context Manager - Intelligent context assembly and optimization
 * Assembles relevant code context for AI requests with token budget management
 * Target: Context assembly <50ms, optimal token usage
 */

const fs = require('fs').promises;
const path = require('path');

class ContextManager {
  constructor(options = {}) {
    this.config = {
      maxContextTokens: 8000,
      maxFileSize: 100000, // 100KB
      maxFilesInContext: 20,
      contextRadius: 10, // lines around cursor
      includeImports: true,
      includeExports: true,
      cacheContexts: true,
      tokenEstimateRatio: 3.5, // chars per token estimate
      ...options
    };

    this.contextCache = new Map();
    this.symbolCache = new Map();
    this.projectStructure = null;

    this.stats = {
      contextsAssembled: 0,
      cacheHits: 0,
      averageTokens: 0,
      averageAssemblyTime: 0
    };
  }

  /**
   * Assemble context for AI request
   * @param {Object} position - Cursor position or file location
   * @param {string} language - Programming language
   * @param {Object} options - Context assembly options
   * @returns {Promise<Object>} Assembled context
   */
  async assembleContext(position, language, options = {}) {
    const startTime = performance.now();

    try {
      const contextOptions = {
        priority: 'interactive',
        maxTokens: this.config.maxContextTokens,
        includeProjectContext: false,
        ...options
      };

      // Generate context key for caching
      const contextKey = this.generateContextKey(position, language, contextOptions);

      // Check cache first
      if (this.config.cacheContexts && this.contextCache.has(contextKey)) {
        this.stats.cacheHits++;
        const cached = this.contextCache.get(contextKey);
        return this.enhanceContext(cached, { fromCache: true });
      }

      // Assemble new context
      const context = await this.buildContext(position, language, contextOptions);

      // Cache result
      if (this.config.cacheContexts) {
        this.cacheContext(contextKey, context);
      }

      // Update stats
      const assemblyTime = performance.now() - startTime;
      this.updateStats(context, assemblyTime);

      return this.enhanceContext(context, { assemblyTime });

    } catch (error) {
      console.warn(`Context assembly failed: ${error.message}`);
      return this.createFallbackContext(position, language);
    }
  }

  /**
   * Build complete context from components
   * @private
   */
  async buildContext(position, language, options) {
    const context = {
      primary: null,
      surrounding: [],
      imports: [],
      exports: [],
      symbols: [],
      projectContext: [],
      totalTokens: 0,
      language,
      timestamp: Date.now()
    };

    // 1. Get primary file content
    if (position.uri || position.filePath) {
      context.primary = await this.getPrimaryFileContext(position, language, options);
    }

    // 2. Get surrounding context (lines around cursor)
    if (position.line !== undefined && context.primary) {
      context.surrounding = this.getSurroundingContext(
        context.primary.content,
        position.line,
        options
      );
    }

    // 3. Get import/export context
    if (this.config.includeImports && context.primary) {
      context.imports = await this.getImportContext(context.primary, language);
      context.exports = await this.getExportContext(context.primary, language);
    }

    // 4. Get symbol definitions
    context.symbols = await this.getSymbolContext(position, language, options);

    // 5. Get project context (if requested)
    if (options.includeProjectContext) {
      context.projectContext = await this.getProjectContext(language, options);
    }

    // 6. Optimize context size
    await this.optimizeContextSize(context, options.maxTokens);

    return context;
  }

  /**
   * Get primary file context
   * @private
   */
  async getPrimaryFileContext(position, language, options) {
    try {
      const filePath = position.uri ? position.uri.replace('file://', '') : position.filePath;

      // Apply options for context customization
      const maxFileSize = options.maxFileSize || this.config.maxFileSize;

      // Check file size
      const stats = await fs.stat(filePath);
      if (stats.size > maxFileSize) {
        return this.getPartialFileContext(filePath, position, language);
      }

      // Read full file
      const content = await fs.readFile(filePath, 'utf8');
      const tokens = this.estimateTokens(content);

      return {
        uri: position.uri || `file://${filePath}`,
        filePath,
        content,
        language,
        tokens,
        size: stats.size,
        lastModified: stats.mtime
      };

    } catch (error) {
      console.warn(`Failed to read primary file: ${error.message}`);
      return null;
    }
  }

  /**
   * Get partial file context for large files
   * @private
   */
  async getPartialFileContext(filePath, position, language) {
    try {
      const content = await fs.readFile(filePath, 'utf8');
      const lines = content.split('\n');

      // Extract context window around position
      const startLine = Math.max(0, (position.line || 0) - this.config.contextRadius);
      const endLine = Math.min(lines.length, (position.line || 0) + this.config.contextRadius + 1);

      const contextLines = lines.slice(startLine, endLine);
      const contextContent = contextLines.join('\n');

      return {
        uri: position.uri || `file://${filePath}`,
        filePath,
        content: contextContent,
        fullFileLines: lines.length,
        contextRange: { start: startLine, end: endLine },
        language,
        tokens: this.estimateTokens(contextContent),
        partial: true
      };

    } catch (error) {
      console.warn(`Failed to read partial file: ${error.message}`);
      return null;
    }
  }

  /**
   * Get surrounding context lines
   * @private
   */
  getSurroundingContext(content, line, options) {
    if (!content || line === undefined) return [];

    const lines = content.split('\n');
    const radius = options.contextRadius || this.config.contextRadius;

    const startLine = Math.max(0, line - radius);
    const endLine = Math.min(lines.length, line + radius + 1);

    const context = [];
    for (let i = startLine; i < endLine; i++) {
      context.push({
        line: i,
        content: lines[i] || '',
        isCurrent: i === line,
        tokens: this.estimateTokens(lines[i] || '')
      });
    }

    return context;
  }

  /**
   * Get import-related context
   * @private
   */
  async getImportContext(primaryFile, language) {
    if (!primaryFile?.content) return [];

    const imports = this.extractImports(primaryFile.content, language);
    const importContext = [];

    for (const importInfo of imports.slice(0, 5)) { // Limit to 5 imports
      try {
        const resolvedPath = this.resolveImportPath(importInfo.path, primaryFile.filePath);
        if (resolvedPath && await this.fileExists(resolvedPath)) {
          const content = await fs.readFile(resolvedPath, 'utf8');
          const exportedSymbols = this.extractExports(content, language);

          importContext.push({
            importStatement: importInfo.statement,
            resolvedPath,
            symbols: exportedSymbols,
            tokens: this.estimateTokens(content.slice(0, 1000)) // First 1000 chars
          });
        }
      } catch (error) {
        // Skip failed imports - log error for debugging
        console.debug(`Failed to resolve import ${importInfo.path}: ${error.message}`);
      }
    }

    return importContext;
  }

  /**
   * Get export-related context
   * @private
   */
  async getExportContext(primaryFile, language) {
    if (!primaryFile?.content) return [];

    return this.extractExports(primaryFile.content, language);
  }

  /**
   * Get symbol definitions context
   * @private
   */
  async getSymbolContext(position, language, options) {
    // Mock implementation - in practice, would integrate with language servers
    // Using position, language, and options for future implementation
    const contextSize = options.symbolContextSize || 5;
    const lineNumber = position.line || 0;

    return [
      {
        name: 'mockFunction',
        type: 'function',
        definition: 'function mockFunction() { return "mock"; }',
        location: { line: lineNumber + 10, character: 0 },
        language: language,
        contextSize: contextSize,
        tokens: 15
      }
    ];
  }

  /**
   * Get project-wide context
   * @private
   */
  async getProjectContext(language, options) {
    // Mock implementation - would analyze project structure
    // Using language and options for context customization
    const includeDevDeps = options.includeDevDependencies || false;

    return [
      {
        type: 'package_info',
        content: '{"name": "project", "version": "1.0.0"}',
        language: language,
        includeDevDeps: includeDevDeps,
        tokens: 10
      }
    ];
  }

  /**
   * Optimize context size to fit token budget
   * @private
   */
  async optimizeContextSize(context, maxTokens) {
    let totalTokens = 0;

    // Calculate current total
    if (context.primary) totalTokens += context.primary.tokens || 0;
    totalTokens += context.surrounding.reduce((sum, item) => sum + (item.tokens || 0), 0);
    totalTokens += context.imports.reduce((sum, item) => sum + (item.tokens || 0), 0);
    totalTokens += context.symbols.reduce((sum, item) => sum + (item.tokens || 0), 0);
    totalTokens += context.projectContext.reduce((sum, item) => sum + (item.tokens || 0), 0);

    context.totalTokens = totalTokens;

    // If over budget, trim context
    if (totalTokens > maxTokens) {
      await this.trimContext(context, maxTokens);
    }
  }

  /**
   * Trim context to fit token budget
   * @private
   */
  async trimContext(context, maxTokens) {
    let currentTokens = context.totalTokens;

    // Priority order for trimming (keep most important)
    const trimOrder = [
      () => this.trimArray(context.projectContext, 0.3),
      () => this.trimArray(context.imports, 0.5),
      () => this.trimArray(context.symbols, 0.7),
      () => this.trimArray(context.surrounding, 0.8),
      () => this.trimPrimaryFile(context.primary, 0.9)
    ];

    for (const trimFunction of trimOrder) {
      if (currentTokens <= maxTokens) break;

      const savedTokens = trimFunction();
      currentTokens -= savedTokens;
    }

    context.totalTokens = currentTokens;
    context.trimmed = currentTokens < context.totalTokens;
  }

  /**
   * Trim array of context items
   * @private
   */
  trimArray(array, keepRatio) {
    if (!Array.isArray(array) || array.length === 0) return 0;

    const keepCount = Math.ceil(array.length * keepRatio);
    const trimCount = array.length - keepCount;

    let trimmedTokens = 0;
    for (let i = 0; i < trimCount; i++) {
      const item = array.pop();
      if (item) trimmedTokens += item.tokens || 0;
    }

    return trimmedTokens;
  }

  /**
   * Trim primary file content
   * @private
   */
  trimPrimaryFile(primaryFile, keepRatio) {
    if (!primaryFile || !primaryFile.content) return 0;

    const originalTokens = primaryFile.tokens || 0;
    const targetLength = Math.floor(primaryFile.content.length * keepRatio);

    primaryFile.content = primaryFile.content.slice(0, targetLength);
    primaryFile.tokens = this.estimateTokens(primaryFile.content);
    primaryFile.trimmed = true;

    return originalTokens - primaryFile.tokens;
  }

  /**
   * Extract imports from source code
   * @private
   */
  extractImports(content, language) {
    const patterns = {
      javascript: [
        /import\s+.*?\s+from\s+['"`]([^'"`]+)['"`]/g,
        /require\(['"`]([^'"`]+)['"`]\)/g
      ],
      python: [
        /^import\s+(\w+)/gm,
        /^from\s+(\w+)\s+import/gm
      ],
      shell: [
        /source\s+['"`]?([^'"`\s]+)['"`]?/g,
        /\.\s+['"`]?([^'"`\s]+)['"`]?/g
      ]
    };

    const langPatterns = patterns[language] || patterns.javascript;
    const imports = [];

    for (const pattern of langPatterns) {
      let match;
      while ((match = pattern.exec(content)) !== null) {
        imports.push({
          statement: match[0],
          path: match[1],
          line: content.substring(0, match.index).split('\n').length - 1
        });
      }
    }

    return imports;
  }

  /**
   * Extract exports from source code
   * @private
   */
  extractExports(content, language) {
    const patterns = {
      javascript: [
        /export\s+(?:function|class|const|let|var)\s+(\w+)/g,
        /export\s+default\s+(\w+)/g
      ],
      python: [
        /^def\s+(\w+)/gm,
        /^class\s+(\w+)/gm
      ]
    };

    const langPatterns = patterns[language] || patterns.javascript;
    const exports = [];

    for (const pattern of langPatterns) {
      let match;
      while ((match = pattern.exec(content)) !== null) {
        exports.push({
          name: match[1],
          type: match[0].includes('function') ? 'function' :
            match[0].includes('class') ? 'class' : 'variable',
          statement: match[0]
        });
      }
    }

    return exports;
  }

  /**
   * Resolve import path to absolute file path
   * @private
   */
  resolveImportPath(importPath, currentFile) {
    if (importPath.startsWith('.')) {
      return path.resolve(path.dirname(currentFile), importPath);
    }

    // For node_modules and absolute paths, return as-is for now
    return importPath;
  }

  /**
   * Check if file exists
   * @private
   */
  async fileExists(filePath) {
    try {
      await fs.access(filePath);
      return true;
    } catch {
      return false;
    }
  }

  /**
   * Estimate token count from text
   * @private
   */
  estimateTokens(text) {
    if (!text) return 0;
    return Math.ceil(text.length / this.config.tokenEstimateRatio);
  }

  /**
   * Generate cache key for context
   * @private
   */
  generateContextKey(position, language, options) {
    const key = JSON.stringify({
      uri: position.uri || position.filePath,
      line: position.line,
      language,
      maxTokens: options.maxTokens,
      includeProjectContext: options.includeProjectContext
    });

    return Buffer.from(key).toString('base64').slice(0, 32);
  }

  /**
   * Cache assembled context
   * @private
   */
  cacheContext(key, context) {
    // Simple LRU cache implementation
    if (this.contextCache.size >= 100) {
      const firstKey = this.contextCache.keys().next().value;
      this.contextCache.delete(firstKey);
    }

    this.contextCache.set(key, {
      ...context,
      cachedAt: Date.now()
    });
  }

  /**
   * Enhance context with metadata
   * @private
   */
  enhanceContext(context, metadata) {
    return {
      ...context,
      metadata: {
        timestamp: new Date().toISOString(),
        ...metadata
      }
    };
  }

  /**
   * Create fallback context for errors
   * @private
   */
  createFallbackContext(position, language) {
    return {
      primary: null,
      surrounding: [],
      imports: [],
      exports: [],
      symbols: [],
      projectContext: [],
      totalTokens: 0,
      language,
      fallback: true,
      metadata: {
        timestamp: new Date().toISOString(),
        error: 'Context assembly failed'
      }
    };
  }

  /**
   * Update performance statistics
   * @private
   */
  updateStats(context, assemblyTime) {
    this.stats.contextsAssembled++;

    const newAvgTokens = this.stats.averageTokens === 0 ? context.totalTokens :
      (this.stats.averageTokens * (this.stats.contextsAssembled - 1) + context.totalTokens) / this.stats.contextsAssembled;

    const newAvgTime = this.stats.averageAssemblyTime === 0 ? assemblyTime :
      (this.stats.averageAssemblyTime * (this.stats.contextsAssembled - 1) + assemblyTime) / this.stats.contextsAssembled;

    this.stats.averageTokens = Math.round(newAvgTokens);
    this.stats.averageAssemblyTime = Math.round(newAvgTime);
  }

  /**
   * Get context manager statistics
   */
  getStats() {
    return {
      ...this.stats,
      cacheSize: this.contextCache.size,
      cacheHitRate: this.stats.contextsAssembled > 0 ?
        (this.stats.cacheHits / this.stats.contextsAssembled) * 100 : 0
    };
  }

  /**
   * Clear context cache
   */
  clearCache() {
    this.contextCache.clear();
    this.symbolCache.clear();
  }
}

module.exports = ContextManager;
