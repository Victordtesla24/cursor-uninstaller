/**
 * Unit Tests for 6-Model Orchestrator - Model Selection Algorithm
 * Tests the intelligent model routing based on task complexity
 * 
 * @version 2.0.0 - Revolutionary Enhancement
 */

const { describe, test, expect, beforeEach } = require('@jest/globals');
const SixModelOrchestrator = require('../../lib/ai/6-model-orchestrator');

/**
 * @fileoverview
 * Tests for model selection logic
 * 
 * NOTE: These tests use placeholder model names for testing purposes only.
 * Real implementation would use actual available models.
 */

describe('Model Selection', () => {
    let orchestrator;

    beforeEach(() => {
        orchestrator = new SixModelOrchestrator();
    });

    test('should select appropriate model for simple completion', () => {
        const models = orchestrator.selectModels({
            context: {
                instruction: 'Complete this simple function',
                complexity: 'simple'
            },
            priority: 'latency'
        });

        expect(models).toHaveProperty('primary');
        expect(models.primary).toHaveProperty('name');
        expect(models.primary).toHaveProperty('role');
        expect(models.primary.role).toBe('primary');
    });

    test('should handle complex refactoring requests', () => {
        const models = orchestrator.selectModels({
            context: {
                instruction: 'Refactor this complex class hierarchy',
                complexity: 'complex'
            },
            priority: 'accuracy'
        });

        expect(models).toHaveProperty('primary');
        expect(models.primary).toHaveProperty('name');
        expect(models.primary.role).toBe('primary');
        
        // Should have validation model for complex tasks
        expect(models).toHaveProperty('validation');
    });

    test('should include all required model properties', () => {
        const models = orchestrator.selectModels({
            context: { instruction: 'Test task' }
        });

        const primaryModel = models.primary;
        expect(primaryModel).toHaveProperty('name');
        expect(primaryModel).toHaveProperty('role');
        expect(primaryModel).toHaveProperty('weight');
        expect(typeof primaryModel.weight).toBe('number');
        expect(primaryModel.weight).toBeGreaterThan(0);
        expect(primaryModel.weight).toBeLessThanOrEqual(1);
    });

    test('should handle multimodal requests appropriately', () => {
        const models = orchestrator.selectModels({
            context: {
                instruction: 'Analyze this code diagram',
                visual: true,
                multimodal: true
            },
            priority: 'accuracy'
        });

        expect(models).toHaveProperty('primary');
        expect(models.primary).toHaveProperty('name');
        expect(models.primary.role).toBe('primary');
    });

    test('should handle rapid iteration requests', () => {
        const models = orchestrator.selectModels({
            context: {
                instruction: 'Quick iteration on this prototype',
                complexity: 'simple',
                speed: 'fast'
            },
            priority: 'latency'
        });

        expect(models).toHaveProperty('primary');
        expect(models.primary.role).toBe('primary');
    });

    test('should return available models list', () => {
        const availableModels = orchestrator.getAvailableModels();
        
        expect(Array.isArray(availableModels)).toBe(true);
        expect(availableModels.length).toBeGreaterThan(0);
        
        availableModels.forEach(model => {
            expect(model).toHaveProperty('name');
            expect(model).toHaveProperty('capabilities');
            expect(Array.isArray(model.capabilities)).toBe(true);
        });
    });

    test('should handle edge cases gracefully', () => {
        // Empty context
        const models1 = orchestrator.selectModels({ context: {} });
        expect(models1).toHaveProperty('primary');
        
        // No context
        const models2 = orchestrator.selectModels({});
        expect(models2).toHaveProperty('primary');
        
        // Unknown priority
        const models3 = orchestrator.selectModels({
            context: { instruction: 'Test' },
            priority: 'unknown'
        });
        expect(models3).toHaveProperty('primary');
    });
}); 