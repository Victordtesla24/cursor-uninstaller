/**
 * Language Adapter Framework - Main Entry Point
 * Provides unified interface for all language adapters with automatic detection
 * Target: Universal language support, <50ms adapter initialization
 */

const BaseLanguageAdapter = require('./adapters/base');
const JavaScriptAdapter = require('./adapters/javascript');
const PythonAdapter = require('./adapters/python');
const ShellAdapter = require('./adapters/shell');

class LanguageAdapterFramework {
    constructor(options = {}) {
        this.config = {
            enableAutoDetection: options.enableAutoDetection !== false,
            cacheAdapters: options.cacheAdapters !== false,
            enableLSP: options.enableLSP !== false,
            enableSafetyChecks: options.enableSafetyChecks !== false,
            defaultTimeout: options.defaultTimeout || 5000,
            maxConcurrentAdapters: options.maxConcurrentAdapters || 5,
            ...options
        };

        this.adapters = new Map();
        this.adapterCache = new Map();
        this.supportedLanguages = new Set(['javascript', 'python', 'shell', 'bash']);
        this.initialized = false;

        // Language detection patterns
        this.languagePatterns = new Map([
            ['javascript', {
                extensions: ['.js', '.jsx', '.ts', '.tsx', '.mjs', '.cjs'],
                shebangs: ['node', 'nodejs'],
                content: [/import\s+.*from/, /require\s*\(/, /export\s+/, /\.jsx?$/, /\.tsx?$/]
            }],
            ['python', {
                extensions: ['.py', '.pyx', '.pyw', '.py3', '.ipynb'],
                shebangs: ['python', 'python3', 'python2'],
                content: [/import\s+\w+/, /from\s+\w+\s+import/, /def\s+\w+\s*\(/, /__name__\s*==\s*['"]\s*__main__\s*['"]/]
            }],
            ['shell', {
                extensions: ['.sh', '.bash', '.zsh', '.fish', '.ksh'],
                shebangs: ['bash', 'sh', 'zsh', 'fish', 'ksh'],
                content: [/^#!/, /\$\{?\w+\}?/, /\[\s*.*\s*\]/, /function\s+\w+/, /\w+\(\)/]
            }]
        ]);

        // Adapter classes
        this.adapterClasses = new Map([
            ['javascript', JavaScriptAdapter],
            ['python', PythonAdapter],
            ['shell', ShellAdapter],
            ['bash', ShellAdapter] // Alias for shell
        ]);
    }

    /**
     * Initialize the language adapter framework
     * @returns {Promise<void>}
     */
    async initialize() {
        if (this.initialized) return;

        try {
            console.log('🔧 Initializing Language Adapter Framework...');

            // Pre-initialize common adapters if caching is enabled
            if (this.config.cacheAdapters) {
                await this.preInitializeAdapters();
            }

            this.initialized = true;

            console.log('✅ Language Adapter Framework initialized');
            console.log(`📝 Supported languages: ${Array.from(this.supportedLanguages).join(', ')}`);

        } catch (error) {
            console.error('❌ Language framework initialization failed:', error.message);
            throw error;
        }
    }

    /**
     * Pre-initialize common adapters for better performance
     * @private
     */
    async preInitializeAdapters() {
        const commonLanguages = ['javascript', 'python', 'shell'];

        for (const language of commonLanguages) {
            try {
                const adapter = await this.createAdapter(language);
                this.adapterCache.set(language, adapter);
                console.log(`✅ Pre-initialized ${language} adapter`);
            } catch (error) {
                console.warn(`Failed to pre-initialize ${language} adapter:`, error.message);
            }
        }
    }

    /**
     * Get adapter for a specific language
     * @param {string} language - Language identifier
     * @param {Object} options - Adapter options
     * @returns {Promise<BaseLanguageAdapter>} Language adapter
     */
    async getAdapter(language, options = {}) {
        if (!this.initialized) {
            await this.initialize();
        }

        const normalizedLanguage = this.normalizeLanguage(language);

        if (!this.supportedLanguages.has(normalizedLanguage)) {
            throw new Error(`Unsupported language: ${language}`);
        }

        // Return cached adapter if available
        if (this.config.cacheAdapters && this.adapterCache.has(normalizedLanguage)) {
            return this.adapterCache.get(normalizedLanguage);
        }

        // Create new adapter
        const adapter = await this.createAdapter(normalizedLanguage, options);

        if (this.config.cacheAdapters) {
            this.adapterCache.set(normalizedLanguage, adapter);
        }

        return adapter;
    }

    /**
     * Auto-detect language from file path and content
     * @param {string} filePath - File path
     * @param {string} content - File content (optional)
     * @returns {Promise<string>} Detected language
     */
    async detectLanguage(filePath, content = '') {
        if (!this.config.enableAutoDetection) {
            throw new Error('Auto-detection is disabled');
        }

        try {
            // Extract file extension
            const extension = this.extractExtension(filePath);

            // Check shebang if content is provided
            const shebang = content ? this.extractShebang(content) : null;

            // Score each language
            const scores = new Map();

            for (const [language, patterns] of this.languagePatterns.entries()) {
                let score = 0;

                // Extension match (high weight)
                if (patterns.extensions.includes(extension)) {
                    score += 100;
                }

                // Shebang match (very high weight)
                if (shebang && patterns.shebangs.some(sb => shebang.includes(sb))) {
                    score += 200;
                }

                // Content patterns (medium weight)
                if (content) {
                    for (const pattern of patterns.content) {
                        if (pattern.test(content)) {
                            score += 50;
                        }
                    }
                }

                if (score > 0) {
                    scores.set(language, score);
                }
            }

            // Return language with highest score
            if (scores.size > 0) {
                const detectedLanguage = Array.from(scores.entries())
                    .sort(([, a], [, b]) => b - a)[0][0];

                console.log(`🔍 Detected language: ${detectedLanguage} (score: ${scores.get(detectedLanguage)})`);
                return detectedLanguage;
            }

            // Fallback to extension-based detection
            const fallback = this.detectByExtension(extension);
            if (fallback) {
                console.log(`🔍 Fallback detection: ${fallback}`);
                return fallback;
            }

            throw new Error('Unable to detect language');

        } catch (error) {
            console.warn('Language detection failed:', error.message);
            throw error;
        }
    }

    /**
     * Get adapter for file (with auto-detection)
     * @param {string} filePath - File path
     * @param {string} content - File content (optional)
     * @param {Object} options - Adapter options
     * @returns {Promise<BaseLanguageAdapter>} Language adapter
     */
    async getAdapterForFile(filePath, content = '', options = {}) {
        try {
            const language = await this.detectLanguage(filePath, content);
            return await this.getAdapter(language, options);
        } catch (error) {
            throw new Error(`Failed to get adapter for file ${filePath}: ${error.message}`);
        }
    }

    /**
     * Process file with appropriate adapter
     * @param {string} filePath - File path
     * @param {string} content - File content
     * @param {Object} operations - Operations to perform
     * @returns {Promise<Object>} Processing results
     */
    async processFile(filePath, content, operations = {}) {
        try {
            const adapter = await this.getAdapterForFile(filePath, content);
            const results = {};

            // Extract context if requested
            if (operations.extractContext) {
                results.context = await adapter.performContextExtraction(
                    filePath,
                    operations.position || { line: 0, character: 0 }
                );
            }

            // Perform linting if requested
            if (operations.lint) {
                results.diagnostics = await adapter.performLinting(filePath, content);
            }

            // Format code if requested
            if (operations.format) {
                results.formatted = await adapter.performFormatting(content, operations.formatOptions);
            }

            // Validate syntax if requested
            if (operations.validate) {
                results.syntaxErrors = await adapter.validateSyntax(content);
            }

            // Resolve symbols if requested
            if (operations.resolveSymbol) {
                results.symbolInfo = await adapter.performSymbolResolution(
                    filePath,
                    operations.symbol,
                    operations.position
                );
            }

            // Get completions if requested
            if (operations.getCompletions) {
                results.completions = await adapter.performCustomCompletions(
                    filePath,
                    operations.position,
                    operations.triggerCharacter
                );
            }

            return {
                language: adapter.language,
                filePath,
                results,
                timestamp: Date.now(),
                performance: adapter.getPerformanceMetrics()
            };

        } catch (error) {
            throw new Error(`File processing failed: ${error.message}`);
        }
    }

    /**
     * Create adapter instance
     * @private
     */
    async createAdapter(language, options = {}) {
        const AdapterClass = this.adapterClasses.get(language);
        if (!AdapterClass) {
            throw new Error(`No adapter class found for language: ${language}`);
        }

        const adapterOptions = {
            enableLSP: this.config.enableLSP,
            enableSafetyChecks: this.config.enableSafetyChecks,
            timeout: this.config.defaultTimeout,
            ...options
        };

        const adapter = new AdapterClass(adapterOptions);
        await adapter.initialize();

        return adapter;
    }

    /**
     * Normalize language identifier
     * @private
     */
    normalizeLanguage(language) {
        const normalized = language.toLowerCase();

        // Handle aliases
        const aliases = new Map([
            ['js', 'javascript'],
            ['ts', 'javascript'],
            ['jsx', 'javascript'],
            ['tsx', 'javascript'],
            ['node', 'javascript'],
            ['py', 'python'],
            ['bash', 'shell'],
            ['sh', 'shell'],
            ['zsh', 'shell']
        ]);

        return aliases.get(normalized) || normalized;
    }

    /**
     * Extract file extension
     * @private
     */
    extractExtension(filePath) {
        const match = filePath.match(/\.([^.]+)$/);
        return match ? `.${match[1].toLowerCase()}` : '';
    }

    /**
     * Extract shebang from content
     * @private
     */
    extractShebang(content) {
        const firstLine = content.split('\n')[0];
        if (firstLine.startsWith('#!')) {
            return firstLine.substring(2).trim();
        }
        return null;
    }

    /**
     * Detect language by extension (fallback)
     * @private
     */
    detectByExtension(extension) {
        for (const [language, patterns] of this.languagePatterns.entries()) {
            if (patterns.extensions.includes(extension)) {
                return language;
            }
        }
        return null;
    }

    /**
     * Get supported languages
     * @returns {Array<string>} Supported languages
     */
    getSupportedLanguages() {
        return Array.from(this.supportedLanguages);
    }

    /**
     * Check if language is supported
     * @param {string} language - Language to check
     * @returns {boolean} Is supported
     */
    isLanguageSupported(language) {
        const normalized = this.normalizeLanguage(language);
        return this.supportedLanguages.has(normalized);
    }

    /**
     * Register custom adapter
     * @param {string} language - Language identifier
     * @param {class} AdapterClass - Adapter class
     * @param {Object} patterns - Language detection patterns
     */
    registerAdapter(language, AdapterClass, patterns = {}) {
        const normalized = this.normalizeLanguage(language);

        this.supportedLanguages.add(normalized);
        this.adapterClasses.set(normalized, AdapterClass);

        if (patterns.extensions || patterns.shebangs || patterns.content) {
            this.languagePatterns.set(normalized, {
                extensions: patterns.extensions || [],
                shebangs: patterns.shebangs || [],
                content: patterns.content || []
            });
        }

        console.log(`✅ Registered custom adapter for ${language}`);
    }

    /**
     * Get framework statistics
     * @returns {Object} Statistics
     */
    getStatistics() {
        return {
            supportedLanguages: this.getSupportedLanguages(),
            cachedAdapters: Array.from(this.adapterCache.keys()),
            adapterCount: this.adapterClasses.size,
            initialized: this.initialized,
            config: {
                autoDetection: this.config.enableAutoDetection,
                caching: this.config.cacheAdapters,
                lsp: this.config.enableLSP,
                safetyChecks: this.config.enableSafetyChecks
            }
        };
    }

    /**
     * Shutdown the framework
     * @returns {Promise<void>}
     */
    async shutdown() {
        try {
            console.log('🔄 Shutting down Language Adapter Framework...');

            // Shutdown cached adapters
            for (const adapter of this.adapterCache.values()) {
                if (adapter && typeof adapter.shutdown === 'function') {
                    await adapter.shutdown();
                }
            }

            this.adapterCache.clear();
            this.adapters.clear();
            this.initialized = false;

            console.log('✅ Language Adapter Framework shutdown complete');

        } catch (error) {
            console.error('Language framework shutdown failed:', error.message);
        }
    }
}

// Factory functions and utilities
const LanguageFramework = {
    /**
     * Create a new language adapter framework
     */
    create(options = {}) {
        return new LanguageAdapterFramework(options);
    },

    /**
     * Create adapter for specific language
     */
    async createAdapter(language, options = {}) {
        const framework = new LanguageAdapterFramework(options);
        await framework.initialize();
        return await framework.getAdapter(language);
    },

    /**
     * Quick language detection
     */
    async detectLanguage(filePath, content = '') {
        const framework = new LanguageAdapterFramework({ enableAutoDetection: true });
        await framework.initialize();
        return await framework.detectLanguage(filePath, content);
    }
};

module.exports = {
    LanguageAdapterFramework,
    LanguageFramework,
    BaseLanguageAdapter,
    JavaScriptAdapter,
    PythonAdapter,
    ShellAdapter
}; 