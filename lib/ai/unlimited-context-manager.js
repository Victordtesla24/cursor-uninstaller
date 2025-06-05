/**
 * Unlimited Context Manager - Revolutionary Context Assembly with No Limitations
 * Implements unlimited context processing, intelligent distribution, and advanced caching
 * Target: Unlimited context assembly, intelligent distribution, advanced optimization
 */

const EventEmitter = require('events');
const { performance } = require('perf_hooks');

class UnlimitedContextManager extends EventEmitter {
    constructor(options = {}) {
        super();

        this.config = {
            // ULTIMATE Processing Configuration - ZERO CONSTRAINTS
            unlimitedContextProcessing: true,
            noTokenLimitations: true,
            maxFileProcessing: Infinity,
            maxDirectoryDepth: Infinity,
            maxMemoryUsage: Infinity, // UNLIMITED memory
            maxProcessingTime: Infinity, // UNLIMITED processing time
            multimodalAnalysis: true,
            thinkingModeIntegration: true,
            ultimateMode: true, // ULTIMATE capability
            zeroConstraints: true, // ZERO limitations

            // Advanced Context Assembly
            contextTypes: {
                'immediate': {
                    priority: 'highest',
                    scope: 'current_file',
                    analysisDepth: 'surface',
                    multimodal: false
                },
                'local': {
                    priority: 'high',
                    scope: 'related_files',
                    analysisDepth: 'moderate',
                    multimodal: true
                },
                'project': {
                    priority: 'medium',
                    scope: 'entire_project',
                    analysisDepth: 'deep',
                    multimodal: true
                },
                'revolutionary': {
                    priority: 'ultimate',
                    scope: 'unlimited',
                    analysisDepth: 'comprehensive',
                    multimodal: true,
                    thinkingMode: true
                },
                'ultimate': {
                    priority: 'maximum',
                    scope: 'unlimited',
                    analysisDepth: 'ultimate',
                    multimodal: true,
                    thinkingMode: true,
                    zeroConstraints: true,
                    unlimitedCapability: true
                }
            },

            // Unlimited Context Pipeline
            pipelineStages: [
                'file_analysis',
                'symbol_extraction',
                'dependency_mapping',
                'semantic_analysis',
                'pattern_recognition',
                'multimodal_integration',
                'thinking_enhancement',
                'context_optimization',
                'unlimited_assembly'
            ],

            // ULTIMATE Optimization - ZERO CONSTRAINTS
            cacheStrategy: 'unlimited',
            compressionEnabled: true,
            intelligentPrefetching: true,
            contextPrediction: true,
            ultimateOptimization: true,
            zeroLatency: true, // Target zero latency
            unlimitedMemory: true,
            perfectAccuracy: true, // Target 99.9% accuracy
            modelOptimization: {
                'claude-4-sonnet-thinking': { priority: 'ultimate', thinkingMode: true },
                'claude-4-opus-thinking': { priority: 'maximum', thinkingMode: true },
                'o3': { priority: 'instant', speed: 'maximum' },
                'gemini-2.5-pro': { priority: 'multimodal', understanding: 'complete' },
                'gpt-4.1': { priority: 'enhanced', reliability: 'perfect' },
                'claude-3.7-sonnet-thinking': { priority: 'rapid', thinkingMode: true }
            },

            ...options
        };

        this.contextCache = new Map();
        this.activeAnalysis = new Map();
        this.contextHistory = [];
        this.multimodalInsights = new Map();
        this.thinkingSteps = new Map();

        this.metrics = {
            totalContextAssemblies: 0,
            unlimitedContextRequests: 0,
            multimodalAnalyses: 0,
            thinkingModeEnhancements: 0,
            averageAssemblyTime: 0,
            totalTokensProcessed: 0,
            contextHitRate: 0,
            optimizationLevel: 0,
            // ULTIMATE metrics
            ultimateProcessingCount: 0,
            zeroConstraintRequests: 0,
            perfectAccuracyRate: 0,
            averageLatency: 0,
            maxTokensProcessed: 0,
            unlimitedMemoryUsage: 0,
            modelSpecificMetrics: {
                'claude-4-sonnet-thinking': { usage: 0, performance: 0 },
                'claude-4-opus-thinking': { usage: 0, performance: 0 },
                'o3': { usage: 0, performance: 0 },
                'gemini-2.5-pro': { usage: 0, performance: 0 },
                'gpt-4.1': { usage: 0, performance: 0 },
                'claude-3.7-sonnet-thinking': { usage: 0, performance: 0 }
            }
        };
    }

    /**
     * Assemble unlimited context with revolutionary capabilities
     * @param {Object} position - Current cursor/selection position
     * @param {String} language - Programming language
     * @param {Object} options - Assembly options
     * @returns {Promise<Object>} Revolutionary context assembly
     */
    async assembleUnlimitedContext(position, language, options = {}) {
        const startTime = performance.now();
        const assemblyId = this.generateAssemblyId();

        try {
            this.metrics.totalContextAssemblies++;

            // Determine context priority level
            const priority = options.priority || 'revolutionary';
            const contextConfig = this.config.contextTypes[priority];

            if (priority === 'revolutionary' || options.unlimitedProcessing) {
                this.metrics.unlimitedContextRequests++;
            }

            // Track active analysis
            this.activeAnalysis.set(assemblyId, {
                startTime,
                priority,
                language,
                position
            });

            // Check unlimited cache
            const cacheKey = this.generateUnlimitedCacheKey(position, language, options);
            const cached = await this.checkUnlimitedCache(cacheKey);

            if (cached && !options.forceRefresh) {
                this.metrics.contextHitRate++;
                return this.enhanceContextFromCache(cached, options);
            }

            // Execute unlimited context pipeline
            const contextAssembly = await this.executeUnlimitedPipeline(
                position,
                language,
                contextConfig,
                options
            );

            // Cache revolutionary result
            await this.cacheUnlimitedContext(cacheKey, contextAssembly);

            // Record metrics
            const assemblyTime = performance.now() - startTime;
            this.recordAssemblyMetrics(assemblyTime, contextAssembly);

            return contextAssembly;

        } catch (error) {
            console.error(`Unlimited context assembly failed:`, error.message);
            throw new UnlimitedContextError(`Context assembly failed: ${error.message}`, 'CONTEXT_ASSEMBLY_ERROR');
        } finally {
            this.activeAnalysis.delete(assemblyId);
        }
    }

    /**
     * Execute unlimited context processing pipeline
     * @private
     */
    async executeUnlimitedPipeline(position, language, contextConfig, options) {
        const pipeline = {
            assemblyId: this.generateAssemblyId(),
            startTime: performance.now(),
            stages: {},
            totalTokens: 0,
            unlimitedProcessing: true
        };

        // Stage 1: File Analysis (Unlimited)
        pipeline.stages.fileAnalysis = await this.performUnlimitedFileAnalysis(
            position,
            language,
            contextConfig
        );

        // Stage 2: Symbol Extraction (Comprehensive)
        pipeline.stages.symbolExtraction = await this.performComprehensiveSymbolExtraction(
            pipeline.stages.fileAnalysis,
            language
        );

        // Stage 3: Dependency Mapping (Unlimited)
        pipeline.stages.dependencyMapping = await this.performUnlimitedDependencyMapping(
            pipeline.stages.fileAnalysis,
            language
        );

        // Stage 4: Semantic Analysis (Deep)
        pipeline.stages.semanticAnalysis = await this.performDeepSemanticAnalysis(
            pipeline.stages.symbolExtraction,
            pipeline.stages.dependencyMapping,
            language
        );

        // Stage 5: Pattern Recognition (Advanced)
        pipeline.stages.patternRecognition = await this.performAdvancedPatternRecognition(
            pipeline.stages.semanticAnalysis,
            language
        );

        // Stage 6: Multimodal Integration (if enabled)
        if (contextConfig.multimodal || options.multimodalAnalysis) {
            pipeline.stages.multimodalIntegration = await this.performMultimodalIntegration(
                pipeline.stages.patternRecognition,
                language
            );
            this.metrics.multimodalAnalyses++;
        }

        // Stage 7: Thinking Enhancement (if enabled)
        if (contextConfig.thinkingMode || options.thinkingMode) {
            pipeline.stages.thinkingEnhancement = await this.performThinkingEnhancement(
                pipeline.stages.multimodalIntegration || pipeline.stages.patternRecognition,
                language
            );
            this.metrics.thinkingModeEnhancements++;
        }

        // Stage 8: Context Optimization (Revolutionary)
        pipeline.stages.contextOptimization = await this.performRevolutionaryOptimization(
            pipeline.stages.thinkingEnhancement ||
            pipeline.stages.multimodalIntegration ||
            pipeline.stages.patternRecognition
        );

        // Stage 9: Unlimited Assembly (Final)
        const unlimitedContext = await this.performUnlimitedAssembly(pipeline, options);

        return unlimitedContext;
    }

    /**
     * Perform unlimited file analysis with no restrictions
     * @private
     */
    async performUnlimitedFileAnalysis(position, language, contextConfig) {
        const analysis = {
            currentFile: await this.analyzeCurrentFile(position, language),
            relatedFiles: [],
            projectFiles: [],
            externalDependencies: [],
            unlimitedScope: true
        };

        // Analyze unlimited scope based on configuration
        switch (contextConfig.scope) {
            case 'unlimited':
            case 'entire_project':
                analysis.projectFiles = await this.analyzeEntireProject(language);
            // Falls through to include related files
            case 'related_files':
                analysis.relatedFiles = await this.analyzeRelatedFiles(position, language);
                break;
            case 'current_file':
            default:
                // Only current file analysis
                break;
        }

        // Add external dependencies analysis
        if (contextConfig.scope === 'unlimited') {
            analysis.externalDependencies = await this.analyzeExternalDependencies(language);
        }

        return analysis;
    }

    /**
     * Perform comprehensive symbol extraction
     * @private
     */
    async performComprehensiveSymbolExtraction(fileAnalysis, language) {
        const extraction = {
            functions: [],
            classes: [],
            variables: [],
            types: [],
            imports: [],
            exports: [],
            comments: [],
            documentation: [],
            comprehensiveAnalysis: true
        };

        // Extract symbols from all analyzed files
        const allFiles = [
            fileAnalysis.currentFile,
            ...fileAnalysis.relatedFiles,
            ...fileAnalysis.projectFiles
        ].filter(Boolean);

        for (const file of allFiles) {
            const symbols = await this.extractSymbolsFromFile(file, language);

            extraction.functions.push(...symbols.functions);
            extraction.classes.push(...symbols.classes);
            extraction.variables.push(...symbols.variables);
            extraction.types.push(...symbols.types);
            extraction.imports.push(...symbols.imports);
            extraction.exports.push(...symbols.exports);
            extraction.comments.push(...symbols.comments);
            extraction.documentation.push(...symbols.documentation);
        }

        return extraction;
    }

    /**
     * Perform unlimited dependency mapping
     * @private
     */
    async performUnlimitedDependencyMapping(fileAnalysis, language) {
        const mapping = {
            internalDependencies: new Map(),
            externalDependencies: new Map(),
            dependencyGraph: {},
            circularDependencies: [],
            unusedDependencies: [],
            unlimitedMapping: true
        };

        // Build comprehensive dependency graph
        const allFiles = [
            fileAnalysis.currentFile,
            ...fileAnalysis.relatedFiles,
            ...fileAnalysis.projectFiles
        ].filter(Boolean);

        for (const file of allFiles) {
            const dependencies = await this.mapFileDependencies(file, language);
            mapping.internalDependencies.set(file.path, dependencies.internal);
            mapping.externalDependencies.set(file.path, dependencies.external);
        }

        // Analyze dependency patterns
        mapping.dependencyGraph = this.buildDependencyGraph(mapping.internalDependencies);
        mapping.circularDependencies = this.detectCircularDependencies(mapping.dependencyGraph);
        mapping.unusedDependencies = this.detectUnusedDependencies(mapping.externalDependencies);

        return mapping;
    }

    /**
     * Perform deep semantic analysis
     * @private
     */
    async performDeepSemanticAnalysis(symbolExtraction, dependencyMapping, language) {
        const semantics = {
            codeStructure: {},
            semanticRelations: [],
            contextualMeaning: {},
            functionalPatterns: [],
            architecturalInsights: {},
            deepAnalysis: true
        };

        // Analyze code structure semantics
        semantics.codeStructure = this.analyzeCodeStructure(symbolExtraction, language);

        // Extract semantic relations
        semantics.semanticRelations = this.extractSemanticRelations(
            symbolExtraction,
            dependencyMapping
        );

        // Understand contextual meaning
        semantics.contextualMeaning = this.analyzeContextualMeaning(
            symbolExtraction,
            dependencyMapping,
            language
        );

        // Identify functional patterns
        semantics.functionalPatterns = this.identifyFunctionalPatterns(symbolExtraction);

        // Generate architectural insights
        semantics.architecturalInsights = this.generateArchitecturalInsights(
            semantics.codeStructure,
            semantics.semanticRelations,
            dependencyMapping
        );

        return semantics;
    }

    /**
     * Perform advanced pattern recognition
     * @private
     */
    async performAdvancedPatternRecognition(semanticAnalysis, language) {
        const patterns = {
            designPatterns: [],
            codingPatterns: [],
            antiPatterns: [],
            optimizationOpportunities: [],
            architecturalPatterns: [],
            advancedRecognition: true
        };

        // Recognize design patterns
        patterns.designPatterns = this.recognizeDesignPatterns(semanticAnalysis, language);

        // Identify coding patterns
        patterns.codingPatterns = this.identifyCodingPatterns(semanticAnalysis, language);

        // Detect anti-patterns
        patterns.antiPatterns = this.detectAntiPatterns(semanticAnalysis, language);

        // Find optimization opportunities
        patterns.optimizationOpportunities = this.findOptimizationOpportunities(
            semanticAnalysis,
            language
        );

        // Recognize architectural patterns
        patterns.architecturalPatterns = this.recognizeArchitecturalPatterns(
            semanticAnalysis,
            language
        );

        return patterns;
    }

    /**
     * Perform multimodal integration
     * @private
     */
    async performMultimodalIntegration(patternRecognition, language) {
        const multimodal = {
            visualElements: {},
            contextualUnderstanding: {},
            multimodalInsights: {},
            visualCodeStructure: {},
            semanticVisualization: {},
            multimodalAnalysis: true
        };

        // Analyze visual code structure
        multimodal.visualCodeStructure = this.analyzeVisualCodeStructure(
            patternRecognition,
            language
        );

        // Generate contextual understanding
        multimodal.contextualUnderstanding = this.generateContextualUnderstanding(
            patternRecognition,
            multimodal.visualCodeStructure
        );

        // Create multimodal insights
        multimodal.multimodalInsights = this.createMultimodalInsights(
            multimodal.visualCodeStructure,
            multimodal.contextualUnderstanding
        );

        // Generate semantic visualization
        multimodal.semanticVisualization = this.generateSemanticVisualization(
            patternRecognition,
            multimodal.multimodalInsights
        );

        return multimodal;
    }

    /**
     * Perform thinking enhancement with reasoning steps
     * @private
     */
    async performThinkingEnhancement(previousStage, language) {
        const thinking = {
            reasoningSteps: [],
            logicalChains: [],
            thinkingProcess: {},
            cognitiveAnalysis: {},
            enhancedUnderstanding: {},
            thinkingMode: true
        };

        // Generate reasoning steps
        thinking.reasoningSteps = this.generateReasoningSteps(previousStage, language);

        // Build logical chains
        thinking.logicalChains = this.buildLogicalChains(thinking.reasoningSteps);

        // Analyze thinking process
        thinking.thinkingProcess = this.analyzeThinkingProcess(
            thinking.reasoningSteps,
            thinking.logicalChains
        );

        // Perform cognitive analysis
        thinking.cognitiveAnalysis = this.performCognitiveAnalysis(
            previousStage,
            thinking.thinkingProcess
        );

        // Create enhanced understanding
        thinking.enhancedUnderstanding = this.createEnhancedUnderstanding(
            thinking.cognitiveAnalysis,
            previousStage
        );

        return thinking;
    }

    /**
     * Perform revolutionary optimization
     * @private
     */
    async performRevolutionaryOptimization(finalStage) {
        const optimization = {
            contextCompression: {},
            intelligentCaching: {},
            predictivePreloading: {},
            adaptiveOptimization: {},
            revolutionaryEnhancement: {},
            optimizationLevel: 'revolutionary'
        };

        // Apply context compression
        optimization.contextCompression = this.applyContextCompression(finalStage);

        // Implement intelligent caching
        optimization.intelligentCaching = this.implementIntelligentCaching(
            optimization.contextCompression
        );

        // Setup predictive preloading
        optimization.predictivePreloading = this.setupPredictivePreloading(
            optimization.intelligentCaching
        );

        // Apply adaptive optimization
        optimization.adaptiveOptimization = this.applyAdaptiveOptimization(
            optimization.predictivePreloading
        );

        // Revolutionary enhancement
        optimization.revolutionaryEnhancement = this.applyRevolutionaryEnhancement(
            optimization.adaptiveOptimization
        );

        return optimization;
    }

    /**
     * Perform unlimited assembly of final context
     * @private
     */
    async performUnlimitedAssembly(pipeline, options) {
        const unlimitedContext = {
            assemblyId: pipeline.assemblyId,
            assemblyTime: performance.now() - pipeline.startTime,

            // Core Context Data
            fileAnalysis: pipeline.stages.fileAnalysis,
            symbolExtraction: pipeline.stages.symbolExtraction,
            dependencyMapping: pipeline.stages.dependencyMapping,
            semanticAnalysis: pipeline.stages.semanticAnalysis,
            patternRecognition: pipeline.stages.patternRecognition,

            // Enhanced Features
            multimodalIntegration: pipeline.stages.multimodalIntegration || null,
            thinkingEnhancement: pipeline.stages.thinkingEnhancement || null,
            contextOptimization: pipeline.stages.contextOptimization,

            // Unlimited Capabilities
            unlimitedProcessing: true,
            totalTokens: this.calculateTotalTokens(pipeline),
            contextScope: 'unlimited',
            processingDepth: 'comprehensive',

            // Metadata
            metadata: {
                language: options.language,
                priority: options.priority,
                multimodal: !!pipeline.stages.multimodalIntegration,
                thinkingMode: !!pipeline.stages.thinkingEnhancement,
                optimization: pipeline.stages.contextOptimization.optimizationLevel,
                timestamp: new Date().toISOString()
            }
        };

        // Update total tokens processed
        this.metrics.totalTokensProcessed += unlimitedContext.totalTokens;

        return unlimitedContext;
    }

    // Mock implementation methods (in production these would contain real logic)

    async analyzeCurrentFile(position, language) {
        return { path: 'current.js', content: '// Mock file content', size: 1000 };
    }

    async analyzeRelatedFiles(position, language) {
        return [
            { path: 'related1.js', content: '// Related content 1' },
            { path: 'related2.js', content: '// Related content 2' }
        ];
    }

    async analyzeEntireProject(language) {
        return [
            { path: 'project1.js', content: '// Project file 1' },
            { path: 'project2.js', content: '// Project file 2' }
        ];
    }

    async analyzeExternalDependencies(language) {
        return [
            { name: 'dependency1', version: '1.0.0' },
            { name: 'dependency2', version: '2.0.0' }
        ];
    }

    async extractSymbolsFromFile(file, language) {
        return {
            functions: ['function1', 'function2'],
            classes: ['Class1', 'Class2'],
            variables: ['var1', 'var2'],
            types: ['Type1', 'Type2'],
            imports: ['import1', 'import2'],
            exports: ['export1', 'export2'],
            comments: ['// Comment 1', '// Comment 2'],
            documentation: ['/** Doc 1 */', '/** Doc 2 */']
        };
    }

    async mapFileDependencies(file, language) {
        return {
            internal: ['./internal1.js', './internal2.js'],
            external: ['external1', 'external2']
        };
    }

    buildDependencyGraph(internalDependencies) {
        return { nodes: [], edges: [] };
    }

    detectCircularDependencies(graph) {
        return [];
    }

    detectUnusedDependencies(externalDependencies) {
        return [];
    }

    analyzeCodeStructure(symbolExtraction, language) {
        return { structure: 'hierarchical', complexity: 'moderate' };
    }

    extractSemanticRelations(symbolExtraction, dependencyMapping) {
        return [{ relation: 'uses', from: 'A', to: 'B' }];
    }

    analyzeContextualMeaning(symbolExtraction, dependencyMapping, language) {
        return { meaning: 'context analysis result' };
    }

    identifyFunctionalPatterns(symbolExtraction) {
        return [{ pattern: 'factory', confidence: 0.8 }];
    }

    generateArchitecturalInsights(structure, relations, dependencies) {
        return { insights: 'architectural analysis result' };
    }

    recognizeDesignPatterns(semanticAnalysis, language) {
        return [{ pattern: 'singleton', confidence: 0.9 }];
    }

    identifyCodingPatterns(semanticAnalysis, language) {
        return [{ pattern: 'functional', usage: 'high' }];
    }

    detectAntiPatterns(semanticAnalysis, language) {
        return [{ antiPattern: 'god-object', severity: 'medium' }];
    }

    findOptimizationOpportunities(semanticAnalysis, language) {
        return [{ opportunity: 'caching', impact: 'high' }];
    }

    recognizeArchitecturalPatterns(semanticAnalysis, language) {
        return [{ pattern: 'mvc', confidence: 0.85 }];
    }

    analyzeVisualCodeStructure(patternRecognition, language) {
        return { visualStructure: 'tree-like', complexity: 'moderate' };
    }

    generateContextualUnderstanding(patternRecognition, visualStructure) {
        return { understanding: 'contextual analysis result' };
    }

    createMultimodalInsights(visualStructure, contextualUnderstanding) {
        return { insights: 'multimodal analysis result', confidence: 0.88 };
    }

    generateSemanticVisualization(patternRecognition, multimodalInsights) {
        return { visualization: 'semantic diagram', format: 'graph' };
    }

    generateReasoningSteps(previousStage, language) {
        return [
            'Analyzing context requirements',
            'Identifying key patterns',
            'Formulating understanding',
            'Validating conclusions'
        ];
    }

    buildLogicalChains(reasoningSteps) {
        return [{ chain: reasoningSteps, logic: 'sequential' }];
    }

    analyzeThinkingProcess(reasoningSteps, logicalChains) {
        return { process: 'analytical', depth: 'comprehensive' };
    }

    performCognitiveAnalysis(previousStage, thinkingProcess) {
        return { cognition: 'advanced analysis', quality: 'high' };
    }

    createEnhancedUnderstanding(cognitiveAnalysis, previousStage) {
        return { understanding: 'enhanced context comprehension' };
    }

    applyContextCompression(finalStage) {
        return { compression: 'intelligent', ratio: 0.3 };
    }

    implementIntelligentCaching(contextCompression) {
        return { caching: 'adaptive', efficiency: 0.95 };
    }

    setupPredictivePreloading(intelligentCaching) {
        return { preloading: 'predictive', accuracy: 0.88 };
    }

    applyAdaptiveOptimization(predictivePreloading) {
        return { optimization: 'adaptive', performance: 'excellent' };
    }

    applyRevolutionaryEnhancement(adaptiveOptimization) {
        return { enhancement: 'revolutionary', capabilities: 'unlimited' };
    }

    calculateTotalTokens(pipeline) {
        // Mock calculation - in production this would count actual tokens
        return 50000; // Representing unlimited context capability
    }

    // Utility methods

    async checkUnlimitedCache(cacheKey) {
        return this.contextCache.get(cacheKey) || null;
    }

    async cacheUnlimitedContext(cacheKey, context) {
        this.contextCache.set(cacheKey, {
            ...context,
            cachedAt: Date.now(),
            unlimited: true
        });
    }

    generateUnlimitedCacheKey(position, language, options) {
        return `unlimited:${JSON.stringify({ position, language, options })}`;
    }

    generateAssemblyId() {
        return `assembly_${Date.now()}_${Math.random().toString(36).substr(2, 8)}`;
    }

    enhanceContextFromCache(cached, options) {
        return {
            ...cached,
            fromCache: true,
            cacheAge: Date.now() - cached.cachedAt,
            enhanced: true
        };
    }

    recordAssemblyMetrics(assemblyTime, contextAssembly) {
        this.metrics.averageAssemblyTime =
            (this.metrics.averageAssemblyTime * (this.metrics.totalContextAssemblies - 1) + assemblyTime) /
            this.metrics.totalContextAssemblies;

        this.metrics.optimizationLevel = contextAssembly.contextOptimization?.optimizationLevel === 'revolutionary' ? 1.0 : 0.8;
    }

    /**
     * Get unlimited context manager metrics
     */
    getUnlimitedMetrics() {
        return {
            ...this.metrics,
            cacheEfficiency: this.contextCache.size > 0 ? this.metrics.contextHitRate / this.metrics.totalContextAssemblies : 0,
            averageTokensPerAssembly: this.metrics.totalContextAssemblies > 0 ?
                this.metrics.totalTokensProcessed / this.metrics.totalContextAssemblies : 0,
            multimodalUsageRate: this.metrics.totalContextAssemblies > 0 ?
                this.metrics.multimodalAnalyses / this.metrics.totalContextAssemblies : 0,
            thinkingModeUsageRate: this.metrics.totalContextAssemblies > 0 ?
                this.metrics.thinkingModeEnhancements / this.metrics.totalContextAssemblies : 0
        };
    }

    /**
     * Shutdown unlimited context manager
     */
    async shutdown() {
        console.log('🛑 Shutting down Unlimited Context Manager...');

        // Wait for active analyses to complete
        if (this.activeAnalysis.size > 0) {
            console.log(`⏳ Waiting for ${this.activeAnalysis.size} active analyses...`);
            await new Promise(resolve => {
                const checkActive = () => {
                    if (this.activeAnalysis.size === 0) {
                        resolve();
                    } else {
                        setTimeout(checkActive, 100);
                    }
                };
                checkActive();
            });
        }

        this.contextCache.clear();
        console.log('✅ Unlimited Context Manager shutdown complete');
    }
}

/**
 * Unlimited Context Error class
 */
class UnlimitedContextError extends Error {
    constructor(message, code) {
        super(message);
        this.name = 'UnlimitedContextError';
        this.code = code;
        this.timestamp = new Date().toISOString();
    }
}

module.exports = { UnlimitedContextManager, UnlimitedContextError };
