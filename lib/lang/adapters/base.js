/**
 * Base Language Adapter - Abstract interface for all language-specific functionality
 * Provides common contract for parsing, context extraction, and tool integration
 * Target: Language adapters <50ms initialization, context extraction <100ms
 */

const EventEmitter = require('events');

class BaseLanguageAdapter extends EventEmitter {
    constructor(language, options = {}) {
        super();

        this.language = language;
        this.config = {
            enableLSP: true,
            enableLinting: true,
            enableFormatting: true,
            enableSyntaxHighlighting: true,
            maxFileSize: 10485760, // 10MB
            contextRadius: 20, // lines around cursor
            maxSymbols: 50,
            cacheResults: true,
            ...options
        };

        this.lspClient = null;
        this.syntaxParser = null;
        this.cache = new Map();
        this.initialized = false;

        this.stats = {
            contextExtractions: 0,
            symbolResolutions: 0,
            lspQueries: 0,
            cacheHits: 0,
            averageExtractionTime: 0
        };
    }

    /**
     * Initialize the language adapter
     * @returns {Promise<void>}
     */
    async initialize() {
        if (this.initialized) return;

        try {
            await this.setupLSP();
            await this.setupSyntaxParser();
            await this.setupLinter();
            await this.setupFormatter();

            this.initialized = true;
            this.emit('initialized', this.language);

        } catch (error) {
            this.emit('error', { phase: 'initialization', error: error.message });
            throw new Error(`Failed to initialize ${this.language} adapter: ${error.message}`);
        }
    }

    /**
     * Extract context for AI completion
     * @param {string} filePath - Path to the file
     * @param {Object} position - Cursor position {line, character}
     * @param {Object} options - Context extraction options
     * @returns {Promise<Object>} Extracted context
     */
    async extractContext(filePath, position, options = {}) {
        const startTime = performance.now();

        try {
            this.stats.contextExtractions++;

            // Check cache first
            const cacheKey = this.generateCacheKey('context', filePath, position);
            if (this.config.cacheResults && this.cache.has(cacheKey)) {
                this.stats.cacheHits++;
                return this.cache.get(cacheKey);
            }

            // Extract context using language-specific implementation
            const context = await this.performContextExtraction(filePath, position, options);

            // Cache result
            if (this.config.cacheResults) {
                this.cache.set(cacheKey, context);
            }

            // Update statistics
            const extractionTime = performance.now() - startTime;
            this.updateExtractionStats(extractionTime);

            return context;

        } catch (error) {
            this.emit('error', { phase: 'context_extraction', error: error.message, filePath });
            return this.createFallbackContext(filePath, position);
        }
    }

    /**
     * Resolve symbol definitions and usages
     * @param {string} filePath - Path to the file
     * @param {string} symbol - Symbol to resolve
     * @param {Object} position - Position of symbol
     * @returns {Promise<Object>} Symbol information
     */
    async resolveSymbol(filePath, symbol, position) {
        const startTime = performance.now();

        try {
            this.stats.symbolResolutions++;

            // Check cache first
            const cacheKey = this.generateCacheKey('symbol', filePath, symbol, position);
            if (this.config.cacheResults && this.cache.has(cacheKey)) {
                this.stats.cacheHits++;
                return this.cache.get(cacheKey);
            }

            // Use LSP for symbol resolution if available
            let symbolInfo = null;
            if (this.lspClient) {
                symbolInfo = await this.queryLSPSymbol(filePath, symbol, position);
            }

            // Fallback to syntax-based resolution
            if (!symbolInfo) {
                symbolInfo = await this.performSymbolResolution(filePath, symbol, position);
            }

            // Cache result
            if (this.config.cacheResults && symbolInfo) {
                this.cache.set(cacheKey, symbolInfo);
            }

            // Update performance metrics with timing
            const executionTime = performance.now() - startTime;
            this.updateExtractionStats(executionTime);

            return symbolInfo;

        } catch (error) {
            this.emit('error', { phase: 'symbol_resolution', error: error.message, symbol });
            return null;
        }
    }

    /**
     * Get language-specific diagnostic information
     * @param {string} filePath - Path to the file
     * @param {string} content - File content
     * @returns {Promise<Array>} Diagnostic messages
     */
    async getDiagnostics(filePath, content) {
        try {
            const diagnostics = [];

            // LSP diagnostics
            if (this.lspClient) {
                const lspDiagnostics = await this.queryLSPDiagnostics(filePath, content);
                diagnostics.push(...lspDiagnostics);
            }

            // Custom linter diagnostics
            if (this.config.enableLinting) {
                const lintDiagnostics = await this.performLinting(filePath, content);
                diagnostics.push(...lintDiagnostics);
            }

            return this.normalizeDiagnostics(diagnostics);

        } catch (error) {
            this.emit('error', { phase: 'diagnostics', error: error.message, filePath });
            return [];
        }
    }

    /**
     * Format code using language-specific formatter
     * @param {string} content - Code content to format
     * @param {Object} options - Formatting options
     * @returns {Promise<string>} Formatted code
     */
    async formatCode(content, options = {}) {
        try {
            if (!this.config.enableFormatting) {
                return content;
            }

            return await this.performFormatting(content, options);

        } catch (error) {
            this.emit('error', { phase: 'formatting', error: error.message });
            return content; // Return original on error
        }
    }

    /**
     * Validate code syntax and structure
     * @param {string} content - Code content to validate
     * @param {Object} options - Validation options
     * @returns {Promise<Object>} Validation result
     */
    async validateCode(content, options = {}) {
        try {
            const validation = {
                isValid: true,
                errors: [],
                warnings: [],
                suggestions: []
            };

            // Syntax validation
            const syntaxErrors = await this.validateSyntax(content);
            validation.errors.push(...syntaxErrors);

            // Semantic validation if LSP available
            if (this.lspClient) {
                const semanticIssues = await this.validateSemantics(content);
                validation.errors.push(...semanticIssues.errors);
                validation.warnings.push(...semanticIssues.warnings);
            }

            // Language-specific validation
            const customIssues = await this.performCustomValidation(content, options);
            validation.suggestions.push(...customIssues);

            validation.isValid = validation.errors.length === 0;

            return validation;

        } catch (error) {
            this.emit('error', { phase: 'validation', error: error.message });
            return { isValid: false, errors: [error.message], warnings: [], suggestions: [] };
        }
    }

    /**
     * Get completion suggestions for given position
     * @param {string} filePath - Path to the file
     * @param {Object} position - Cursor position
     * @param {string} triggerCharacter - Character that triggered completion
     * @returns {Promise<Array>} Completion suggestions
     */
    async getCompletionSuggestions(filePath, position, triggerCharacter = null) {
        try {
            let suggestions = [];

            // LSP-based completions
            if (this.lspClient) {
                const lspSuggestions = await this.queryLSPCompletions(filePath, position, triggerCharacter);
                suggestions.push(...lspSuggestions);
            }

            // Language-specific completions
            const customSuggestions = await this.performCustomCompletions(filePath, position, triggerCharacter);
            suggestions.push(...customSuggestions);

            return this.rankCompletionSuggestions(suggestions);

        } catch (error) {
            this.emit('error', { phase: 'completions', error: error.message, filePath });
            return [];
        }
    }

    // Abstract methods to be implemented by specific language adapters

    /**
     * Setup Language Server Protocol client
     * @abstract
     */
    async setupLSP() {
        throw new Error('setupLSP must be implemented by subclass');
    }

    /**
     * Setup syntax parser
     * @abstract
     */
    async setupSyntaxParser() {
        throw new Error('setupSyntaxParser must be implemented by subclass');
    }

    /**
     * Setup language-specific linter
     * @abstract
     */
    async setupLinter() {
        throw new Error('setupLinter must be implemented by subclass');
    }

    /**
     * Setup code formatter
     * @abstract
     */
    async setupFormatter() {
        throw new Error('setupFormatter must be implemented by subclass');
    }

    /**
     * Perform language-specific context extraction
     * @abstract
     */
    async performContextExtraction(filePath, position, options) {
        throw new Error(`performContextExtraction must be implemented by subclass for ${this.language} (file: ${filePath}, position: ${JSON.stringify(position)}, options: ${JSON.stringify(options)})`);
    }

    /**
     * Perform language-specific symbol resolution
     * @abstract
     */
    async performSymbolResolution(filePath, symbol, position) {
        throw new Error(`performSymbolResolution must be implemented by subclass for ${this.language} (file: ${filePath}, symbol: ${symbol}, position: ${JSON.stringify(position)})`);
    }

    /**
     * Perform language-specific linting
     * @abstract
     */
    async performLinting(filePath, content) {
        throw new Error(`performLinting must be implemented by subclass for ${this.language} (file: ${filePath}, content length: ${content.length})`);
    }

    /**
     * Perform language-specific formatting
     * @abstract
     */
    async performFormatting(content, options) {
        throw new Error(`performFormatting must be implemented by subclass for ${this.language} (content length: ${content.length}, options: ${JSON.stringify(options)})`);
    }

    /**
     * Validate syntax using language-specific parser
     * @abstract
     */
    async validateSyntax(content) {
        throw new Error(`validateSyntax must be implemented by subclass for ${this.language} (content length: ${content.length})`);
    }

    /**
     * Perform semantic validation using LSP
     * @abstract
     */
    async validateSemantics(content) {
        // Log content analysis for debugging mock implementation
        console.debug(`Semantic validation for ${this.language} (content hash: ${content.slice(0, 100)}...)`);
        return { errors: [], warnings: [] };
    }

    /**
     * Perform custom validation rules
     * @abstract
     */
    async performCustomValidation(content, options) {
        // Log validation request for debugging
        console.debug(`Custom validation requested for ${this.language} (content length: ${content.length}, options: ${JSON.stringify(options)})`);
        return [];
    }

    /**
     * Perform custom completion suggestions
     * @abstract
     */
    async performCustomCompletions(filePath, position, triggerCharacter) {
        // Log completion request for debugging
        console.debug(`Custom completions requested for ${this.language} (file: ${filePath}, position: ${JSON.stringify(position)}, trigger: ${triggerCharacter})`);
        return [];
    }

    // Helper methods

    /**
     * Query LSP for symbol information
     * @protected
     */
    async queryLSPSymbol(filePath, symbol, position) {
        if (!this.lspClient) return null;

        this.stats.lspQueries++;

        try {
            // Mock LSP query - in real implementation would use actual LSP client
            console.debug(`LSP symbol query for ${symbol} at ${JSON.stringify(position)} in ${filePath}`);
            return {
                name: symbol,
                kind: 'function',
                detail: 'Mock LSP symbol info',
                documentation: 'Symbol information from LSP',
                range: { start: position, end: position }
            };
        } catch (error) {
            console.error(`LSP symbol query failed: ${error.message}`);
            return null;
        }
    }

    /**
     * Query LSP for diagnostics
     * @protected
     */
    async queryLSPDiagnostics(filePath, content) {
        if (!this.lspClient) return [];

        this.stats.lspQueries++;

        try {
            // Mock diagnostics - in real implementation would use actual LSP client
            console.debug(`LSP diagnostics for ${filePath} (content length: ${content.length})`);
            return [];
        } catch (error) {
            console.error(`LSP diagnostics query failed: ${error.message}`);
            return [];
        }
    }

    /**
     * Query LSP for completions
     * @protected
     */
    async queryLSPCompletions(filePath, position, triggerCharacter) {
        if (!this.lspClient) return [];

        this.stats.lspQueries++;

        try {
            // Mock completions - in real implementation would use actual LSP client
            const triggerInfo = triggerCharacter ? ` triggered by '${triggerCharacter}'` : '';
            console.debug(`LSP completions for ${filePath} at ${JSON.stringify(position)}${triggerInfo}`);
            return [];
        } catch (error) {
            console.error(`LSP completions query failed: ${error.message}`);
            return [];
        }
    }

    /**
     * Normalize diagnostic messages to common format
     * @protected
     */
    normalizeDiagnostics(diagnostics) {
        return diagnostics.map(diagnostic => ({
            range: diagnostic.range || { start: { line: 0, character: 0 }, end: { line: 0, character: 0 } },
            severity: diagnostic.severity || 'error',
            message: diagnostic.message || 'Unknown diagnostic',
            source: diagnostic.source || this.language,
            code: diagnostic.code || null
        }));
    }

    /**
     * Rank completion suggestions by relevance
     * @protected
     */
    rankCompletionSuggestions(suggestions) {
        return suggestions.sort((a, b) => {
            // Sort by relevance score (higher is better)
            const scoreA = a.sortText || a.label || '';
            const scoreB = b.sortText || b.label || '';
            return scoreA.localeCompare(scoreB);
        });
    }

    /**
     * Generate cache key for caching
     * @protected
     */
    generateCacheKey(type, ...args) {
        const keyData = [type, ...args.map(arg =>
            typeof arg === 'object' ? JSON.stringify(arg) : String(arg)
        )].join(':');
        return Buffer.from(keyData).toString('base64').slice(0, 32);
    }

    /**
     * Create fallback context when extraction fails
     * @protected
     */
    createFallbackContext(filePath, position) {
        return {
            file: filePath,
            position,
            surrounding: [],
            symbols: [],
            imports: [],
            exports: [],
            language: this.language,
            fallback: true
        };
    }

    /**
     * Update extraction time statistics
     * @protected
     */
    updateExtractionStats(extractionTime) {
        const newAvgTime = this.stats.averageExtractionTime === 0 ? extractionTime :
            (this.stats.averageExtractionTime * (this.stats.contextExtractions - 1) + extractionTime) / this.stats.contextExtractions;

        this.stats.averageExtractionTime = Math.round(newAvgTime);
    }

    /**
     * Get adapter statistics
     */
    getStats() {
        return {
            ...this.stats,
            language: this.language,
            initialized: this.initialized,
            cacheSize: this.cache.size,
            cacheHitRate: this.stats.contextExtractions > 0 ?
                (this.stats.cacheHits / this.stats.contextExtractions) * 100 : 0
        };
    }

    /**
     * Get performance metrics for this adapter
     * @returns {Object} Performance metrics
     */
    getPerformanceMetrics() {
        const stats = this.getStats();
        const totalOperations = stats.contextExtractions + stats.symbolResolutions;

        return {
            totalOperations,
            averageLatency: stats.averageLatency,
            cacheHitRate: totalOperations > 0 ? (stats.cacheHits / totalOperations) * 100 : 0,
            errorRate: totalOperations > 0 ? (stats.errors / totalOperations) * 100 : 0,
            efficiency: stats.averageLatency < 100 ? 'high' : stats.averageLatency < 300 ? 'medium' : 'low'
        };
    }

    /**
     * Clear adapter cache
     */
    clearCache() {
        this.cache.clear();
    }

    /**
     * Shutdown the adapter and cleanup resources
     */
    async shutdown() {
        try {
            if (this.lspClient) {
                await this.lspClient.stop?.();
            }

            this.clearCache();
            this.removeAllListeners();
            this.initialized = false;

            this.emit('shutdown', this.language);

        } catch (error) {
            this.emit('error', { phase: 'shutdown', error: error.message });
        }
    }
}

module.exports = BaseLanguageAdapter; 