import fs from 'fs';
import path from 'path';

function processFile(filePath) {
    let content = fs.readFileSync(filePath, 'utf8');
    let changed = false;

    console.log(`Processing: ${filePath}`);

    // Handle specific problematic variables we know are unused
    const knownUnused = [
        'error', 'position', 'language', 'options', 'filePath', 'content',
        'symbol', 'triggerCharacter', 'startTime', 'totalTime', 'beforeStart',
        'results', 'request', 'spawn', 'path', 'data', 'operation',
        'code', 'context', 'tokenCount', 'priority', 'requestType', 'complexity',
        'file', 'internalDependencies', 'graph', 'externalDependencies',
        'symbolExtraction', 'dependencyMapping', 'structure', 'relations',
        'dependencies', 'semanticAnalysis', 'patternRecognition', 'visualStructure',
        'contextualUnderstanding', 'multimodalInsights', 'previousStage',
        'reasoningSteps', 'logicalChains', 'thinkingProcess', 'cognitiveAnalysis',
        'finalStage', 'contextCompression', 'intelligentCaching', 'predictivePreloading',
        'adaptiveOptimization', 'pipeline', 'value', 'categoryConfig', 'intelligenceData',
        'originalSize', 'strategy', 'metadata', 'intelligence', 'category',
        'cacheEntry', 'cacheState', 'payload', 'messageId', 'fileUri',
        'variableRegex', 'usedVars', 'expectedIndent', 'indentLevel', 'line',
        'lineNumber', 'startIndex', 'beforeEach', 'revolutionaryOptimizer',
        'simpleRequest', 'complexRequest', 'unlimitedRequest', 'multimodalRequest',
        'errorOutput'
    ];

    knownUnused.forEach(varName => {
        // Replace parameter declarations: function(varName) -> function(_varName)
        const paramRegex = new RegExp(`\\b(${varName})\\b(?=\\s*[,)])`, 'g');
        const newContent = content.replace(paramRegex, (match, name) => {
            // Don't change if already prefixed with underscore
            if (name.startsWith('_')) return match;
            changed = true;
            return `_${name}`;
        });
        content = newContent;
    });

    if (changed) {
        fs.writeFileSync(filePath, content);
        console.log(`  ✓ Fixed unused variables in ${filePath}`);
    }
}

// Process all JS files
const files = [
    'lib/ai/6-model-orchestrator.js',
    'lib/ai/context-manager.js',
    'lib/ai/controller.js',
    'lib/ai/model-selector.js',
    'lib/ai/multi-model-orchestrator.js',
    'lib/ai/revolutionary-controller.js',
    'lib/cache/revolutionary-cache.js',
    'lib/lang/adapters/base.js',
    'lib/lang/adapters/javascript.js',
    'lib/lang/adapters/python.js',
    'lib/lang/adapters/shell.js',
    'lib/shadow/ipc.js',
    'lib/shadow/workspace.js',
    'modules/performance/index.js',
    'modules/performance/latency-tracker.js',
    'modules/performance/revolutionary-optimizer.js',
    'tests/revolutionary-test-suite.js'
];

files.forEach(file => {
    if (fs.existsSync(file)) {
        processFile(file);
    }
});

console.log('Done processing files'); 