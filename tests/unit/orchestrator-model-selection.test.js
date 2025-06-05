/**
 * Unit Tests for 6-Model Orchestrator - Model Selection Algorithm
 * Tests the intelligent model routing based on task complexity
 * 
 * @version 2.0.0 - Revolutionary Enhancement
 */

const { describe, test, expect, beforeEach } = require('@jest/globals');
const { SixModelOrchestrator } = require('../../lib/ai/6-model-orchestrator');

describe('6-Model Orchestrator - Model Selection', () => {
    let orchestrator;

    beforeEach(() => {
        orchestrator = new SixModelOrchestrator({
            orchestration: {
                parallelProcessing: true,
                thinkingModeEnabled: true,
                multimodalAnalysis: true,
                unlimitedContext: true
            }
        });
    });

    describe('Instant Complexity Tasks', () => {
        test('should select o3 for simple completions', () => {
            const request = {
                type: 'completion',
                code: 'const x = ',
                complexity: 'simple',
                latencyRequirement: 50
            };

            const result = orchestrator.selectModels(request);

            expect(result.modelDetails[0].name).toBe('o3');
            expect(result.modelDetails[0].role).toBe('primary');
            expect(result.modelDetails[0].reasoning).toContain('Ultra-fast');
        });

        test('should include validation model for parallel processing', () => {
            const request = {
                type: 'completion',
                code: 'const simple = true',
                complexity: 'simple'
            };

            const result = orchestrator.selectModels(request);

            expect(result.modelDetails).toHaveLength(2);
            const validationModel = result.modelDetails.find(m => m.role === 'validation');
            expect(validationModel.name).toBe('claude-3.7-sonnet-thinking');
        });
    });

    describe('Complex Reasoning Tasks', () => {
        test('should select Claude-4-Sonnet-Thinking for complex refactoring', () => {
            const request = {
                type: 'refactoring',
                code: 'complex function with multiple responsibilities',
                complexity: 'complex',
                requiresReasoning: true
            };

            const result = orchestrator.selectModels(request);

            const primaryModel = result.modelDetails.find(m => m.role === 'primary');
            expect(primaryModel.name).toBe('claude-4-sonnet-thinking');
            expect(primaryModel.reasoning).toContain('Advanced reasoning');
        });

        test('should include o3 as speed backup for complex tasks', () => {
            const request = {
                type: 'debugging',
                complexity: 'complex',
                requiresFastFallback: true
            };

            const result = orchestrator.selectModels(request);

            const speedBackup = result.modelDetails.find(m => m.role === 'speed-backup');
            expect(speedBackup.name).toBe('o3');
            expect(speedBackup.weight).toBe(0.5);
        });
    });

    describe('Ultimate Intelligence Tasks', () => {
        test('should select Claude-4-Opus-Thinking for maximum complexity', () => {
            const request = {
                type: 'system-design',
                description: 'Design a distributed system architecture',
                complexity: 'ultimate',
                requiresDeepReasoning: true
            };

            const result = orchestrator.selectModels(request);

            const primaryModel = result.modelDetails.find(m => m.role === 'primary');
            expect(primaryModel.name).toBe('claude-4-opus-thinking');
            expect(primaryModel.reasoning).toContain('Ultimate intelligence');
        });
    });

    describe('Multimodal Analysis', () => {
        test('should include Gemini-2.5-Pro for multimodal requests', () => {
            const request = {
                type: 'analysis',
                code: 'analyze this visual component',
                complexity: 'complex',
                multimodal: true,
                hasVisualContent: true
            };

            const result = orchestrator.selectModels(request);

            const multimodalModel = result.modelDetails.find(m => m.role === 'multimodal');
            expect(multimodalModel).toBeDefined();
            expect(multimodalModel.name).toBe('gemini-2.5-pro');
            expect(multimodalModel.reasoning).toContain('Multimodal');
        });
    });

    describe('Balanced Processing', () => {
        test('should select multiple models for balanced complexity', () => {
            const request = {
                type: 'code-review',
                complexity: 'balanced',
                requiresMultiplePerspectives: true
            };

            const result = orchestrator.selectModels(request);

            expect(result.modelDetails.length).toBeGreaterThan(1);
            const modelNames = result.modelDetails.map(m => m.name);
            expect(modelNames).toContain('gpt-4.1');
            expect(modelNames).toContain('o3');
        });
    });

    describe('Rapid Prototyping', () => {
        test('should prioritize Claude-3.7-Sonnet-Thinking for rapid tasks', () => {
            const request = {
                type: 'prototyping',
                complexity: 'rapid',
                requiresQuickIteration: true
            };

            const selectedModels = orchestrator.selectModels(request);

            const primaryModel = selectedModels.find(m => m.role === 'primary');
            expect(primaryModel.name).toBe('claude-3.7-sonnet-thinking');
            expect(primaryModel.reasoning).toContain('Rapid thinking');
        });
    });
}); 