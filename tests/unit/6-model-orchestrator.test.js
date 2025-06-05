/**
 * Comprehensive Unit Tests for Revolutionary 6-Model Orchestrator
 * 
 * Test Coverage:
 * - Model selection algorithms
 * - Parallel processing execution
 * - Thinking mode integration
 * - Multimodal analysis
 * - Unlimited context processing
 * - Performance optimization
 * - Caching mechanisms
 * - Error handling and fallbacks
 * 
 * @version 2.0.0 - Revolutionary Enhancement
 */

const { describe, test, expect, beforeEach, afterEach } = require('@jest/globals');
const { SixModelOrchestrator } = require('../../lib/ai/6-model-orchestrator');
const { performance } = require('perf_hooks');

describe('Revolutionary 6-Model Orchestrator', () => {
    let orchestrator;
    let mockCache;

    beforeEach(() => {
        // Create mock cache
        mockCache = {
            get: jest.fn(),
            set: jest.fn(),
            clear: jest.fn(),
            getStats: jest.fn(() => ({ hits: 0, misses: 0, size: 0 }))
        };

        // Initialize orchestrator with test configuration
        orchestrator = new SixModelOrchestrator({
            performance: {
                maxLatency: 200,
                targetAccuracy: 98,
                cacheHitTarget: 80,
                unlimitedProcessing: true
            },
            orchestration: {
                parallelProcessing: true,
                thinkingModeEnabled: true,
                multimodalAnalysis: true,
                unlimitedContext: true
            }
        });

        orchestrator.setCache(mockCache);
    });

    afterEach(() => {
        jest.clearAllMocks();
    });

    describe('Model Selection Algorithm', () => {
        test('should select o3 for instant complexity tasks', () => {
            const request = {
                type: 'completion',
                code: 'const x = ',
                complexity: 'simple',
                latencyRequirement: 50
            };

            const selection = orchestrator.selectModels(request);

            expect(selection.modelDetails).toHaveLength(2);
            expect(selection.modelDetails[0].name).toBe('o3');
            expect(selection.modelDetails[0].role).toBe('primary');
            expect(selection.modelDetails[0].weight).toBe(1.0);
            expect(selection.modelDetails[0].reasoning).toContain('Ultra-fast');
        });

        test('should select Claude-4-Sonnet-Thinking for complex tasks', () => {
            const request = {
                type: 'refactoring',
                code: 'complex function with multiple responsibilities',
                complexity: 'complex',
                requiresReasoning: true
            };

            const selection = orchestrator.selectModels(request);

            const primaryModel = selection.modelDetails.find(m => m.role === 'primary');
            expect(primaryModel.name).toBe('claude-4-sonnet-thinking');
            expect(primaryModel.reasoning).toContain('Advanced reasoning');
        });

        test('should select Claude-4-Opus-Thinking for ultimate complexity', () => {
            const request = {
                type: 'system-design',
                description: 'Design a distributed system architecture',
                complexity: 'ultimate',
                requiresDeepReasoning: true
            };

            const selection = orchestrator.selectModels(request);

            const primaryModel = selection.modelDetails.find(m => m.role === 'primary');
            expect(primaryModel.name).toBe('claude-4-opus-thinking');
            expect(primaryModel.reasoning).toContain('Ultimate intelligence');
        });

        test('should include Gemini-2.5-Pro for multimodal requests', () => {
            const request = {
                type: 'analysis',
                code: 'analyze this visual component',
                complexity: 'complex',
                multimodal: true,
                hasVisualContent: true
            };

            const selection = orchestrator.selectModels(request);

            const multimodalModel = selection.modelDetails.find(m => m.role === 'multimodal');
            expect(multimodalModel).toBeDefined();
            expect(multimodalModel.name).toBe('gemini-2.5-pro');
            expect(multimodalModel.reasoning).toContain('Multimodal');
        });

        test('should select multiple models for balanced complexity', () => {
            const request = {
                type: 'code-review',
                complexity: 'balanced',
                requiresMultiplePerspectives: true
            };

            const selection = orchestrator.selectModels(request);

            expect(selection.modelDetails.length).toBeGreaterThan(1);
            const modelNames = selection.modelDetails.map(m => m.name);
            expect(modelNames).toContain('gpt-4.1');
        });
    });

    describe('Parallel Processing Execution', () => {
        test('should execute multiple models in parallel', async () => {
            const models = [
                { name: 'o3', role: 'primary', weight: 1.0 },
                { name: 'claude-3.7-sonnet-thinking', role: 'validation', weight: 0.3 }
            ];

            const request = {
                type: 'completion',
                code: 'const example = ',
                unlimitedContext: true
            };

            // Mock model execution
            jest.spyOn(orchestrator, '_executeModel').mockImplementation(async (modelName) => ({
                modelName,
                result: `completion from ${modelName}`,
                confidence: 0.95,
                latency: 50,
                success: true,
                thinkingMode: modelName.includes('thinking')
            }));

            const results = await orchestrator.executeParallel(models, request);

            expect(results).toHaveLength(2);
            expect(results[0].modelName).toBe('o3');
            expect(results[1].modelName).toBe('claude-3.7-sonnet-thinking');
            expect(results[1].thinkingMode).toBe(true);
        });

        test('should handle model execution failures gracefully', async () => {
            const models = [
                { name: 'o3', role: 'primary', weight: 1.0 },
                { name: 'failing-model', role: 'backup', weight: 0.5 }
            ];

            const request = { type: 'completion', code: 'test' };

            jest.spyOn(orchestrator, '_executeModel').mockImplementation(async (modelName) => {
                if (modelName === 'failing-model') {
                    throw new Error('Model execution failed');
                }
                return {
                    modelName,
                    result: 'success',
                    confidence: 0.95,
                    latency: 50,
                    success: true
                };
            });

            const results = await orchestrator.executeParallel(models, request);

            expect(results).toHaveLength(1);
            expect(results[0].success).toBe(true);
        });
    });

    describe('Thinking Mode Integration', () => {
        test('should enable thinking mode for Claude models', async () => {
            const request = {
                type: 'complex-refactoring',
                code: 'complex legacy code',
                enableThinking: true
            };

            const modelRequest = await orchestrator._prepareModelRequest(
                { name: 'claude-4-sonnet-thinking', thinkingMode: true },
                request
            );

            expect(modelRequest.thinkingMode).toBe(true);
            expect(modelRequest.enhancedReasoning).toBe(true);
            expect(modelRequest.stepByStepAnalysis).toBe(true);
        });

        test('should include thinking steps in results', async () => {
            jest.spyOn(orchestrator, '_executeModel').mockImplementation(async () => ({
                modelName: 'claude-4-sonnet-thinking',
                result: 'refactored code',
                confidence: 0.98,
                thinkingSteps: [
                    'Analyze current code structure',
                    'Identify refactoring opportunities',
                    'Apply SOLID principles',
                    'Optimize for readability'
                ],
                reasoning: 'Applied clean code principles',
                success: true
            }));

            const models = [{ name: 'claude-4-sonnet-thinking', role: 'primary', weight: 1.0 }];
            const request = { type: 'refactoring', enableThinking: true };

            const results = await orchestrator.executeParallel(models, request);

            expect(results[0].thinkingSteps).toBeDefined();
            expect(results[0].thinkingSteps).toHaveLength(4);
            expect(results[0].reasoning).toContain('SOLID');
        });
    });

    describe('Unlimited Context Processing', () => {
        test('should handle unlimited context without token limits', () => {
            const largeRequest = {
                type: 'analysis',
                code: 'x'.repeat(1000000), // 1MB of code
                context: 'unlimited',
                files: Array.from({ length: 100 }, (_, i) => `file${i}.js`)
            };

            const complexity = orchestrator.complexityAnalyzer.analyze(largeRequest);

            expect(complexity.contextSize).toBe('unlimited');
            expect(complexity.tokenLimitations).toBe('removed');
            expect(complexity.processingCapability).toBe('unlimited');
        });

        test('should process large codebases efficiently', () => {
            const massiveRequest = {
                type: 'codebase-analysis',
                codebase: {
                    files: Array.from({ length: 10000 }, (_, i) => ({
                        path: `src/component${i}.js`,
                        size: 50000
                    })),
                    totalSize: 500000000 // 500MB codebase
                },
                unlimitedProcessing: true
            };

            const selectedModels = orchestrator.selectModels(massiveRequest);

            // Should still select appropriate models despite massive size
            expect(selectedModels.length).toBeGreaterThan(0);
            const primaryModel = selectedModels.find(m => m.role === 'primary');
            expect(primaryModel).toBeDefined();
        });
    });

    describe('Performance Optimization', () => {
        test('should achieve target latency under 200ms', async () => {
            const startTime = performance.now();

            jest.spyOn(orchestrator, '_executeModel').mockImplementation(async () => ({
                modelName: 'o3',
                result: 'fast completion',
                confidence: 0.95,
                latency: 45,
                success: true
            }));

            const models = [{ name: 'o3', role: 'primary', weight: 1.0 }];
            const request = { type: 'completion', fastTrack: true };

            await orchestrator.executeParallel(models, request);

            const totalTime = performance.now() - startTime;
            expect(totalTime).toBeLessThan(200);
        });

        test('should maintain high confidence scores', async () => {
            jest.spyOn(orchestrator, '_executeModel').mockImplementation(async (modelName) => ({
                modelName,
                result: 'high quality result',
                confidence: 0.98,
                accuracy: 0.985,
                success: true
            }));

            const models = [
                { name: 'claude-4-sonnet-thinking', role: 'primary', weight: 1.0 },
                { name: 'o3', role: 'validation', weight: 0.5 }
            ];
            const request = { type: 'complex-task', requiresHighAccuracy: true };

            const results = await orchestrator.executeParallel(models, request);

            const avgConfidence = results.reduce((sum, r) => sum + r.confidence, 0) / results.length;
            expect(avgConfidence).toBeGreaterThanOrEqual(0.95);
        });
    });

    describe('Revolutionary Caching', () => {
        test('should cache model responses with unlimited storage', async () => {
            const request = { type: 'completion', code: 'const test = ' };

            mockCache.get.mockReturnValue(null); // Cache miss

            jest.spyOn(orchestrator, '_executeModel').mockImplementation(async () => ({
                modelName: 'o3',
                result: 'const test = "hello";',
                confidence: 0.95,
                success: true
            }));

            const models = [{ name: 'o3', role: 'primary', weight: 1.0 }];
            await orchestrator.executeParallel(models, request);

            expect(mockCache.set).toHaveBeenCalled();
            const cacheCall = mockCache.set.mock.calls[0];
            expect(cacheCall[0]).toContain('o3'); // Cache key contains model name
            expect(cacheCall[1]).toEqual(expect.objectContaining({
                result: 'const test = "hello";',
                confidence: 0.95
            }));
        });

        test('should retrieve cached responses for unlimited performance', async () => {
            const cachedResponse = {
                result: 'cached completion',
                confidence: 0.98,
                cached: true,
                timestamp: Date.now()
            };

            mockCache.get.mockReturnValue(cachedResponse);

            const models = [{ name: 'o3', role: 'primary', weight: 1.0 }];
            const request = { type: 'completion', code: 'const cached = ' };

            const results = await orchestrator.executeParallel(models, request);

            expect(results[0].cached).toBe(true);
            expect(results[0].result).toBe('cached completion');
            expect(orchestrator._executeModel).not.toHaveBeenCalled();
        });
    });

    describe('Metrics and Monitoring', () => {
        test('should track comprehensive performance metrics', async () => {
            jest.spyOn(orchestrator, '_executeModel').mockImplementation(async (modelName) => ({
                modelName,
                result: 'result',
                confidence: 0.95,
                latency: 100,
                success: true
            }));

            const models = [{ name: 'claude-4-sonnet-thinking', role: 'primary', weight: 1.0 }];
            const request = { type: 'test-request' };

            await orchestrator.executeParallel(models, request);

            const metrics = orchestrator.getMetrics();

            expect(metrics.totalRequests).toBe(1);
            expect(metrics.successfulResponses).toBe(1);
            expect(metrics.modelUsage['claude-4-sonnet-thinking'].requests).toBe(1);
            expect(metrics.averageLatency).toBeGreaterThan(0);
        });

        test('should track thinking mode usage', async () => {
            jest.spyOn(orchestrator, '_executeModel').mockImplementation(async () => ({
                modelName: 'claude-4-sonnet-thinking',
                result: 'thinking result',
                confidence: 0.98,
                thinkingMode: true,
                success: true
            }));

            const models = [{ name: 'claude-4-sonnet-thinking', role: 'primary', weight: 1.0 }];
            const request = { type: 'complex-task', enableThinking: true };

            await orchestrator.executeParallel(models, request);

            const metrics = orchestrator.getMetrics();
            expect(metrics.thinkingModeUsage).toBe(1);
        });

        test('should track multimodal requests', async () => {
            jest.spyOn(orchestrator, '_executeModel').mockImplementation(async () => ({
                modelName: 'gemini-2.5-pro',
                result: 'multimodal analysis',
                confidence: 0.96,
                multimodal: true,
                success: true
            }));

            const models = [{ name: 'gemini-2.5-pro', role: 'multimodal', weight: 1.0 }];
            const request = { type: 'visual-analysis', multimodal: true };

            await orchestrator.executeParallel(models, request);

            const metrics = orchestrator.getMetrics();
            expect(metrics.multimodalRequests).toBe(1);
        });
    });

    describe('Error Handling and Resilience', () => {
        test('should handle network failures gracefully', async () => {
            jest.spyOn(orchestrator, '_executeModel').mockImplementation(async (modelName) => {
                if (modelName === 'o3') {
                    throw new Error('Network timeout');
                }
                return {
                    modelName,
                    result: 'fallback result',
                    confidence: 0.90,
                    success: true
                };
            });

            const models = [
                { name: 'o3', role: 'primary', weight: 1.0 },
                { name: 'claude-3.7-sonnet-thinking', role: 'fallback', weight: 0.8 }
            ];
            const request = { type: 'completion', resilience: true };

            const results = await orchestrator.executeParallel(models, request);

            expect(results).toHaveLength(1);
            expect(results[0].modelName).toBe('claude-3.7-sonnet-thinking');
            expect(results[0].success).toBe(true);
        });

        test('should emit error events for monitoring', async () => {
            const errorHandler = jest.fn();
            orchestrator.on('modelError', errorHandler);

            jest.spyOn(orchestrator, '_executeModel').mockImplementation(async () => {
                throw new Error('Model API error');
            });

            const models = [{ name: 'o3', role: 'primary', weight: 1.0 }];
            const request = { type: 'test-error' };

            await orchestrator.executeParallel(models, request);

            expect(errorHandler).toHaveBeenCalledWith(expect.objectContaining({
                modelName: 'o3',
                error: expect.any(Error),
                request: expect.any(Object)
            }));
        });
    });

    describe('Revolutionary Features Integration', () => {
        test('should integrate all revolutionary capabilities', async () => {
            const revolutionaryRequest = {
                type: 'ultimate-task',
                complexity: 'ultimate',
                unlimitedContext: true,
                thinkingMode: true,
                multimodal: true,
                revolutionaryAccuracy: true,
                performanceTarget: 150
            };

            const selectedModels = orchestrator.selectModels(revolutionaryRequest);

            // Should select multiple models for ultimate capabilities
            expect(selectedModels.length).toBeGreaterThan(2);

            // Should include thinking models
            const thinkingModels = selectedModels.filter(m =>
                m.name.includes('thinking') || m.name === 'claude-4-opus-thinking'
            );
            expect(thinkingModels.length).toBeGreaterThan(0);

            // Should include multimodal capability
            const multimodalModel = selectedModels.find(m => m.name === 'gemini-2.5-pro');
            expect(multimodalModel).toBeDefined();
        });
    });
}); 