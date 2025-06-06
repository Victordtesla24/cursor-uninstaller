/**
 * AI System V2.0.0 Integration Test
 * Validates all new components work together and meet performance targets
 * Target validation: <0.5s completion latency, <500MB memory overhead, 95%+ first-pass accuracy, >60% cache hit rate
 */

const { expect } = require('@jest/globals');

// Import all V2.0.0 components
const { LanguageAdapterFramework } = require('../../lib/lang');
const { ShadowWorkspace } = require('../../lib/shadow');
const { PerformanceMonitoringSystem } = require('../../modules/performance');
const { UISystem } = require('../../lib/ui');
const { AIController } = require('../../lib/ai');
const ModelSelector = require('../../lib/ai/model-selector');
const ContextManager = require('../../lib/ai/context-manager');
const ResultCache = require('../../lib/cache/result-cache');

describe('AI System V2.0.0 Integration Tests', () => {
    let languageFramework;
    let shadowWorkspace;
    let performanceMonitor;
    let uiSystem;
    let aiController;
    let modelSelector;
    let contextManager;
    let cache;

    beforeAll(async () => {
        console.log('🚀 Starting AI System V2.0.0 Integration Tests...');

        // Initialize performance monitoring first
        performanceMonitor = new PerformanceMonitoringSystem({
            enableCollection: true,
            enableRealTimeAnalysis: true,
            enableMemoryMonitoring: true,
            enableLatencyTracking: true
        });
        await performanceMonitor.initialize();

        // Initialize language framework
        languageFramework = new LanguageAdapterFramework({
            enableAutoDetection: true,
            cacheAdapters: true,
            enableLSP: false, // Disable for testing
            enableSafetyChecks: true
        });
        await languageFramework.initialize();

        // Initialize shadow workspace
        shadowWorkspace = new ShadowWorkspace({
            isolationLevel: 'process',
            enableLinting: true,
            enableTesting: true
        });
        await shadowWorkspace.initialize();

        // Initialize UI system
        uiSystem = new UISystem({
            theme: 'dark',
            realTimeUpdates: false // Disable for testing
        });
        await uiSystem.initialize();

        // Initialize cache
        cache = new ResultCache({
            maxSize: 1000,
            enableCompression: true,
            enableStatistics: true
        });
        // Note: ResultCache doesn't need initialization - ready after construction

        // Initialize AI dependencies
        modelSelector = new ModelSelector({
            enableIntelligentRouting: true,
            fastModelThreshold: 200
        });

        contextManager = new ContextManager({
            maxContextTokens: 8000,
            cacheContexts: true
        });

        // Initialize AI controller with all dependencies
        aiController = new AIController({
            performanceMonitor,
            cache,
            languageFramework
        });
        await aiController.initialize({
            modelSelector,
            contextManager,
            resultCache: cache,
            performanceMonitor
        });

        console.log('✅ All V2.0.0 components initialized');
    }, 30000);

    afterAll(async () => {
        // Shutdown all components safely and sequentially
        const components = [
            aiController,
            uiSystem,
            shadowWorkspace,
            languageFramework,
            performanceMonitor,
            cache,
            modelSelector,
            contextManager,
        ];

        for (const component of components) {
            if (component && typeof component.shutdown === 'function') {
                try {
                    await component.shutdown();
                } catch (err) {
                    console.warn(`${component.constructor.name} shutdown error:`, err.message);
                }
            }
        }

        console.log('✅ All components shut down');
        jest.clearAllTimers();
    });

    describe('Language Adapter Framework', () => {
        test('should support all required languages', async () => {
            const supportedLanguages = languageFramework.getSupportedLanguages();

            expect(supportedLanguages).toContain('javascript');
            expect(supportedLanguages).toContain('python');
            expect(supportedLanguages).toContain('shell');
            expect(supportedLanguages.length).toBeGreaterThanOrEqual(3);
        });

        test('should auto-detect JavaScript files', async () => {
            const jsContent = `
                import React from 'react';
                
                export const Component = () => {
                    return <div>Hello World</div>;
                };
            `;

            const language = await languageFramework.detectLanguage('component.jsx', jsContent);
            expect(language).toBe('javascript');
        });

        test('should auto-detect Python files', async () => {
            const pyContent = `
                #!/usr/bin/env python3
                
                def main():
                    print("Hello World")
                
                if __name__ == "__main__":
                    main()
            `;

            const language = await languageFramework.detectLanguage('script.py', pyContent);
            expect(language).toBe('python');
        });

        test('should auto-detect Shell scripts', async () => {
            const shellContent = `
                #!/bin/bash
                
                function deploy() {
                    echo "Deploying application..."
                }
                
                deploy
            `;

            const language = await languageFramework.detectLanguage('deploy.sh', shellContent);
            expect(language).toBe('shell');
        });

        test('should initialize adapters within performance target', async () => {
            const startTime = Date.now();

            const adapter = await languageFramework.getAdapter('javascript');

            const initTime = Date.now() - startTime;
            expect(initTime).toBeLessThan(50); // <50ms target
            expect(adapter).toBeDefined();
            expect(adapter.language).toBe('javascript');
        });

        test('should process files with comprehensive operations', async () => {
            const jsContent = `
                const message = "Hello World";
                console.log(message);
            `;

            const result = await performanceMonitor.trackOperation(
                'file_processing',
                () => languageFramework.processFile('test.js', jsContent, {
                    extractContext: true,
                    lint: true,
                    format: true,
                    validate: true
                })
            );

            expect(result.language).toBe('javascript');
            expect(result.results.context).toBeDefined();
            expect(result.results.diagnostics).toBeDefined();
            expect(result.results.formatted).toBeDefined();
            expect(result.results.syntaxErrors).toBeDefined();
        });
    });

    describe('Shadow Workspace System', () => {
        test('should create isolated workspace', async () => {
            const workspace = await shadowWorkspace.createIsolatedEnvironment('test-workspace');

            expect(workspace).toBeDefined();
            expect(workspace.id).toBe('test-workspace');
            expect(workspace.isolated).toBe(true);
        });

        test('should apply edits safely', async () => {
            const testCode = 'console.log("test");';

            const result = await performanceMonitor.trackOperation(
                'shadow_edit',
                () => shadowWorkspace.applyEdit('test.js', testCode, {
                    validateSyntax: true,
                    runLints: true
                })
            );

            expect(result.success).toBe(true);
            expect(result.diagnostics).toBeDefined();
        });

        test('should maintain independence from main workspace', async () => {
            const mainWorkspaceFile = 'main.js';
            const shadowWorkspaceFile = 'shadow.js';

            // Apply changes in shadow workspace
            await shadowWorkspace.applyEdit(shadowWorkspaceFile, 'const x = 1;');

            // Main workspace should be unaffected
            const mainExists = await shadowWorkspace.fileExists(mainWorkspaceFile);
            const shadowExists = await shadowWorkspace.fileExists(shadowWorkspaceFile);

            expect(shadowExists).toBe(true);
            expect(mainExists).toBe(false); // Should not affect main workspace
        });
    });

    describe('Performance Monitoring System', () => {
        test('should track operation latency within target', async () => {
            const operation = () => new Promise(resolve => {
                const timer = setTimeout(resolve, 100);
                timer.unref(); // Prevent hanging the process
            });

            await performanceMonitor.trackOperation('test_operation', operation);

            const metrics = performanceMonitor.getCurrentMetrics();
            expect(metrics.averageLatency).toBeLessThan(500); // <0.5s target
            expect(metrics.totalOperations).toBeGreaterThan(0);
        });

        test('should monitor memory usage within target', async () => {
            const heavyOperation = () => {
                // Simulate memory usage
                const data = new Array(1000).fill('test');
                return Promise.resolve(data);
            };

            await performanceMonitor.trackOperation('memory_test', heavyOperation);

            const summary = await performanceMonitor.generateSummary();
            expect(summary.memoryUsageMB).toBeLessThan(500); // <500MB target
        });

        test('should detect performance degradation', async () => {
            let degradationDetected = false;

            performanceMonitor.callbacks.onAlert = (alert) => {
                if (alert.type === 'performance_degradation') {
                    degradationDetected = true;
                }
            };

            // Simulate slow operations
            for (let i = 0; i < 5; i++) {
                const slowOperation = () => new Promise(resolve => {
                    const timer = setTimeout(resolve, 600);
                    timer.unref(); // Prevent hanging the process
                });
                await performanceMonitor.trackOperation('slow_operation', slowOperation);
            }

            // Allow time for analysis
            await new Promise(resolve => {
                const timer = setTimeout(resolve, 1000);
                timer.unref(); // Prevent hanging the process
            });

            // Should detect degradation (operations > 500ms threshold)
            expect(degradationDetected).toBe(true);
        });

        test('should generate comprehensive performance report', async () => {
            const report = await performanceMonitor.generateReport();

            expect(report.timestamp).toBeDefined();
            expect(report.metrics).toBeDefined();
            expect(report.summary).toBeDefined();
            expect(report.summary.totalOperations).toBeGreaterThan(0);
            expect(report.summary.healthScore).toBeGreaterThan(0);
        });
    });

    describe('UI Components System', () => {
        test('should initialize all components', async () => {
            const status = uiSystem.getStatus();

            expect(status.initialized).toBe(true);
            expect(status.componentStatus).toBeDefined();
            expect(Object.keys(status.componentStatus).length).toBeGreaterThan(0);
        });

        test('should handle theme changes', async () => {
            const initialTheme = uiSystem.state.currentTheme;

            uiSystem.setTheme('light');
            expect(uiSystem.state.currentTheme).toBe('light');

            uiSystem.setTheme(initialTheme);
            expect(uiSystem.state.currentTheme).toBe(initialTheme);
        });

        test('should display performance metrics', async () => {
            const performanceData = {
                latency: 250,
                memoryUsage: 300,
                successRate: 0.95
            };

            uiSystem.showPerformanceDashboard(performanceData);

            expect(uiSystem.state.activeComponents.has('performanceDashboard')).toBe(true);
        });

        test('should show notifications for alerts', async () => {
            const notification = {
                type: 'warning',
                title: 'Performance Alert',
                message: 'Latency threshold exceeded',
                duration: 5000
            };

            uiSystem.showNotification(notification);

            expect(uiSystem.state.activeComponents.has('notificationSystem')).toBe(true);
        });
    });

    describe('Cache System Performance', () => {
        test('should achieve target cache hit rate', async () => {
            const testKey = 'performance_test';
            const testData = { result: 'cached_data' };

            // Prime the cache
            await cache.set(testKey, testData);

            // Test cache hits
            for (let i = 0; i < 10; i++) {
                const cachedResult = await cache.get(testKey);
                expect(cachedResult).toEqual(testData);
            }

            const stats = cache.getStats();
            expect(stats.hitRate).toBeGreaterThan(0.6); // >60% target
        });

        test('should compress data efficiently', async () => {
            const largeData = {
                content: 'x'.repeat(10000), // 10KB of data
                metadata: { size: 10000 }
            };

            await cache.set('large_data', largeData);

            const stats = cache.getStats();
            expect(stats.compressionRatio).toBeGreaterThan(0); // Should have compression
        });
    });

    describe('End-to-End AI Performance Engine', () => {
        test('should complete full AI workflow within performance targets', async () => {
            const testCode = `
                function calculateSum(a, b) {
                    return a + b;
                }
                
                const result = calculateSum(5, 3);
                console.log(result);
            `;

            const startTime = Date.now();

            // Full AI workflow simulation
            const workflowResult = await performanceMonitor.trackOperation(
                'ai_workflow',
                async () => {
                    // 1. Language detection and adapter selection
                    const adapter = await languageFramework.getAdapterForFile('test.js', testCode);

                    // 2. Context extraction
                    const context = await adapter.performContextExtraction('test.js', { line: 0, character: 0 });

                    // 3. Shadow workspace processing
                    const shadowResult = await shadowWorkspace.applyEdit('test.js', testCode, {
                        validateSyntax: true,
                        runLints: true
                    });

                    // 4. Cache the results
                    const cacheKey = `workflow_${Date.now()}`;
                    await cache.set(cacheKey, { context, shadowResult });

                    // 5. UI updates
                    uiSystem.updateStatus({
                        type: 'success',
                        message: 'AI workflow completed'
                    });

                    return {
                        language: adapter.language,
                        context,
                        shadowResult,
                        cached: true
                    };
                }
            );

            const totalTime = Date.now() - startTime;

            // Validate performance targets
            expect(totalTime).toBeLessThan(500); // <0.5s completion latency
            expect(workflowResult.language).toBe('javascript');
            expect(workflowResult.context).toBeDefined();
            expect(workflowResult.shadowResult.success).toBe(true);
            expect(workflowResult.cached).toBe(true);
        });

        test('should maintain 95%+ accuracy under load', async () => {
            const testCases = [
                { file: 'test1.js', content: 'const x = 1;', expectedLang: 'javascript' },
                { file: 'test2.py', content: 'x = 1', expectedLang: 'python' },
                { file: 'test3.sh', content: '#!/bin/bash\necho "test"', expectedLang: 'shell' },
                { file: 'test4.jsx', content: 'export const App = () => <div/>;', expectedLang: 'javascript' },
                { file: 'test5.py', content: 'def main():\n    pass', expectedLang: 'python' }
            ];

            let correctDetections = 0;

            for (const testCase of testCases) {
                try {
                    const detectedLang = await languageFramework.detectLanguage(testCase.file, testCase.content);
                    if (detectedLang === testCase.expectedLang) {
                        correctDetections++;
                    }
                } catch (error) {
                    console.warn(`Detection failed for ${testCase.file}:`, error.message);
                }
            }

            const accuracy = correctDetections / testCases.length;
            expect(accuracy).toBeGreaterThanOrEqual(0.95); // 95%+ first-pass accuracy
        });

        test('should generate final performance report', async () => {
            const finalReport = await performanceMonitor.generateReport({ type: 'integration_test' });

            console.log('📊 Final Performance Report:');
            console.log(`Total Operations: ${finalReport.summary.totalOperations}`);
            console.log(`Average Latency: ${finalReport.summary.averageLatency}ms`);
            console.log(`Memory Usage: ${finalReport.summary.memoryUsageMB}MB`);
            console.log(`Success Rate: ${(finalReport.summary.overallSuccessRate * 100).toFixed(1)}%`);
            console.log(`Health Score: ${finalReport.summary.healthScore}/100`);

            // Validate final targets
            expect(finalReport.summary.averageLatency).toBeLessThan(500); // <0.5s
            expect(finalReport.summary.memoryUsageMB).toBeLessThan(500); // <500MB
            expect(finalReport.summary.overallSuccessRate).toBeGreaterThanOrEqual(0.95); // 95%+
            expect(finalReport.summary.healthScore).toBeGreaterThan(80); // 80+ health score

            // Cache hit rate validation
            const cacheStats = cache.getStats();
            expect(cacheStats.hitRate).toBeGreaterThan(0.6); // >60%

            console.log(`Cache Hit Rate: ${(cacheStats.hitRate * 100).toFixed(1)}%`);
            console.log('✅ All V2.0.0 performance targets met!');
        });
    });

    describe('System Integration Stability', () => {
        test('should handle component failures gracefully', async () => {
            // Simulate component failure
            const originalMethod = shadowWorkspace.applyEdit;
            shadowWorkspace.applyEdit = jest.fn().mockRejectedValue(new Error('Simulated failure'));

            let errorHandled = false;

            try {
                await performanceMonitor.trackOperation(
                    'failure_test',
                    () => shadowWorkspace.applyEdit('test.js', 'test code')
                );
            } catch (error) {
                errorHandled = true;
                expect(error.message).toContain('Simulated failure');
            }

            // Restore original method
            shadowWorkspace.applyEdit = originalMethod;

            expect(errorHandled).toBe(true);

            // System should still be functional
            const systemStatus = uiSystem.getStatus();
            expect(systemStatus.initialized).toBe(true);
        });

        test('should maintain memory efficiency over time', async () => {
            const initialMemory = process.memoryUsage();

            // Perform multiple operations
            for (let i = 0; i < 20; i++) {
                await performanceMonitor.trackOperation(
                    `stress_test_${i}`,
                    async () => {
                        const adapter = await languageFramework.getAdapter('javascript');
                        await adapter.performContextExtraction('test.js', { line: 0, character: 0 });
                        return `operation_${i}`;
                    }
                );
            }

            // Force garbage collection if available
            if (global.gc) {
                global.gc();
            }

            const finalMemory = process.memoryUsage();
            const memoryGrowth = (finalMemory.heapUsed - initialMemory.heapUsed) / (1024 * 1024);

            // Memory growth should be reasonable (< 50MB for 20 operations)
            expect(memoryGrowth).toBeLessThan(50);

            console.log(`Memory growth: ${memoryGrowth.toFixed(2)}MB`);
        });
    });
});
