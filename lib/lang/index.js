/**
 * @fileoverview
 * Language Adapter Framework - Multi-language support for the development tools.
 */

const BaseLanguageAdapter = require('./adapters/base');
const JavaScriptAdapter = require('./adapters/javascript');
const PythonAdapter = require('./adapters/python');
const ShellAdapter = require('./adapters/shell');

class LanguageAdapterFramework {
    constructor(config = {}) {
        this.config = config;
        this.adapters = new Map();
        this.initialized = false;
        
        console.log('[Language Framework] Initializing multi-language adapter framework');
        this._registerDefaultAdapters();
    }

    async initialize() {
        this.initialized = true;
        console.log('[Language Framework] Framework initialized with multi-language support');
    }

    _registerDefaultAdapters() {
        this.adapters.set('javascript', new JavaScriptAdapter());
        this.adapters.set('python', new PythonAdapter());
        this.adapters.set('shell', new ShellAdapter());
        this.adapters.set('typescript', new JavaScriptAdapter()); // TypeScript uses JS adapter
        this.adapters.set('bash', new ShellAdapter());
        this.adapters.set('zsh', new ShellAdapter());
    }

    getAdapter(language) {
        const adapter = this.adapters.get(language.toLowerCase());
        if (!adapter) {
            console.warn(`[Language Framework] No adapter found for ${language}, using base adapter`);
            return new BaseLanguageAdapter();
        }
        return adapter;
    }

    registerAdapter(language, adapter) {
        this.adapters.set(language.toLowerCase(), adapter);
        console.log(`[Language Framework] Registered adapter for ${language}`);
    }

    getSupportedLanguages() {
        return Array.from(this.adapters.keys());
    }

    async analyzeCode(code, language) {
        const adapter = this.getAdapter(language);
        return await adapter.analyzeCode(code);
    }

    async parseCode(code, language) {
        const adapter = this.getAdapter(language);
        return await adapter.parseCode(code);
    }

    async generateCompletion(code, language, context = {}) {
        const adapter = this.getAdapter(language);
        return await adapter.generateCompletion(code, context);
    }

    async validateSyntax(code, language) {
        const adapter = this.getAdapter(language);
        return await adapter.validateSyntax(code);
    }

    async formatCode(code, language, options = {}) {
        const adapter = this.getAdapter(language);
        return await adapter.formatCode(code, options);
    }

    async detectLanguage(fileName, code) {
        // First try file extension detection
        if (fileName) {
            const ext = fileName.split('.').pop().toLowerCase();
            const extensionMap = {
                'js': 'javascript',
                'jsx': 'javascript', 
                'ts': 'typescript',
                'tsx': 'typescript',
                'py': 'python',
                'sh': 'shell',
                'bash': 'shell',
                'zsh': 'shell'
            };
            
            if (extensionMap[ext]) {
                return extensionMap[ext];
            }
        }
        
        // Fallback to content-based detection
        if (code) {
            const patterns = {
                javascript: [/function\s+\w+\s*\(/, /const\s+\w+\s*=/, /=>\s*{/, /console\.log/, /require\(/, /import.*from/, /export.*{/],
                python: [/def\s+\w+\s*\(/, /import\s+\w+/, /from\s+\w+\s+import/, /print\(/, /if\s+__name__\s*==\s*['"]/, /class\s+\w+.*:/],
                shell: [/^#!\/bin\/bash/, /^#!\/bin\/sh/, /echo\s/, /export\s+\w+=/, /\$\w+/, /^\s*if\s*\[/, /^\s*for\s+\w+\s+in/],
                typescript: [/interface\s+\w+/, /type\s+\w+\s*=/, /:\s*string/, /:\s*number/, /private\s+/, /public\s+/]
            };

            for (const [language, langPatterns] of Object.entries(patterns)) {
                const matches = langPatterns.reduce((count, pattern) => {
                    return count + (pattern.test(code) ? 1 : 0);
                }, 0);
                
                if (matches >= 1) { // Lowered threshold for better detection
                    return language;
                }
            }
        }

        return 'plaintext'; // Default fallback
    }

    async getLanguageInfo(language) {
        const adapter = this.getAdapter(language);
        return {
            language,
            supported: this.adapters.has(language.toLowerCase()),
            features: adapter.getSupportedFeatures ? adapter.getSupportedFeatures() : [],
            adapter: adapter.constructor.name
        };
    }

    getStats() {
        return {
            supportedLanguages: this.getSupportedLanguages(),
            totalAdapters: this.adapters.size,
            initialized: this.initialized
        };
    }

    async processFile(filePath, content, options = {}) {
        const language = await this.detectLanguage(filePath, content);
        const adapter = this.getAdapter(language);
        
        const processingResults = {
            processed: true,
            timestamp: new Date().toISOString()
        };

        if (options.extractContext) {
            processingResults.context = await adapter.analyzeCode(content);
        }

        if (options.lint || options.validate) {
            processingResults.diagnostics = await adapter.validateSyntax(content);
            processingResults.syntaxErrors = processingResults.diagnostics || [];
        }

        if (options.format) {
            processingResults.formatted = await adapter.formatCode(content, options.formatOptions);
        }

        return {
            language,
            filePath,
            results: processingResults
        };
    }

    async getAdapterForFile(filePath, content = '') {
        const language = await this.detectLanguage(filePath, content);
        const adapter = this.getAdapter(language);
        
        // Add file-specific context to adapter
        adapter.currentFile = filePath;
        adapter.currentLanguage = language;
        
        return {
            adapter,
            language,
            filePath,
            performContextExtraction: async (file, position) => {
                const analysis = await adapter.analyzeCode(content);
                return {
                    context: analysis,
                    position,
                    file,
                    language,
                    symbols: analysis.symbols || [],
                    imports: analysis.imports || []
                };
            }
        };
    }

    async shutdown() {
        console.log('[Language Framework] Shutting down language framework');
        this.initialized = false;
    }
}

// Maintain backward compatibility
class LanguageAdapters {
    constructor() {
        console.log('[Language Adapters] Initializing language adapters');
        this.adapters = {
            javascript: new JavaScriptAdapter(),
            python: new PythonAdapter(),
            shell: new ShellAdapter(),
            base: new BaseLanguageAdapter()
        };
    }

    getAdapter(language) {
        return this.adapters[language] || this.adapters.base;
    }

    // ... existing code ...
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
        return await framework.detectLanguage(content);
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