/**
 * Memory Usage Benchmark
 * Measures memory overhead of AI operations and shadow workspace
 * Target: <500MB total overhead above base VS Code
 */

const { performance } = require('perf_hooks');
const fs = require('fs').promises;
const path = require('path');

class MemoryUsageBenchmark {
  constructor() {
    this.results = [];
    this.baselineMemory = 0;
    this.memorySnapshots = [];
    this.targetOverhead = 500 * 1024 * 1024; // 500MB in bytes
  }

  getMemoryUsage() {
    const usage = process.memoryUsage();
    return {
      heapUsed: usage.heapUsed,
      heapTotal: usage.heapTotal,
      external: usage.external,
      rss: usage.rss, // Resident Set Size
      timestamp: Date.now()
    };
  }

  formatMemory(bytes) {
    return `${Math.round(bytes / 1024 / 1024)}MB`;
  }

  async simulateBaseVSCode() {
    // Simulate base VS Code memory usage
    console.log('📊 Measuring baseline VS Code memory usage...');
    
    // Simulate loading basic extensions and workspace
    const mockExtensions = [];
    for (let i = 0; i < 10; i++) {
      mockExtensions.push({
        id: `extension-${i}`,
        data: Buffer.alloc(1024 * 1024) // 1MB per extension
      });
    }
    
    // Force garbage collection if available
    if (global.gc) global.gc();
    
    await new Promise(resolve => setTimeout(resolve, 1000));
    
    this.baselineMemory = this.getMemoryUsage();
    console.log(`✅ Baseline memory: ${this.formatMemory(this.baselineMemory.heapUsed)}`);
    
    return this.baselineMemory;
  }

  async simulateAIController() {
    console.log('🤖 Simulating AI Controller initialization...');
    
    // Simulate AI controller with caches
    const aiController = {
      contextCache: new Map(),
      resultCache: new Map(),
      modelConfigs: {}
    };
    
    // Populate caches with realistic data
    for (let i = 0; i < 100; i++) {
      aiController.contextCache.set(`context-${i}`, {
        code: 'x'.repeat(1000), // 1KB of code context
        embeddings: new Float32Array(768), // Typical embedding size
        metadata: { timestamp: Date.now(), language: 'javascript' }
      });
    }
    
    for (let i = 0; i < 50; i++) {
      aiController.resultCache.set(`result-${i}`, {
        completion: 'y'.repeat(500), // 500B completion
        confidence: 0.85,
        tokens: 150
      });
    }
    
    const aiMemory = this.getMemoryUsage();
    const overhead = aiMemory.heapUsed - this.baselineMemory.heapUsed;
    
    this.results.push({
      component: 'AI Controller',
      memory: aiMemory,
      overhead: overhead,
      overheadFormatted: this.formatMemory(overhead),
      targetMet: overhead <= (100 * 1024 * 1024) // 100MB target for AI controller
    });
    
    console.log(`   Memory: ${this.formatMemory(aiMemory.heapUsed)} (+${this.formatMemory(overhead)})`);
    
    return aiController;
  }

  async simulateShadowWorkspace() {
    console.log('👥 Simulating Shadow Workspace...');
    
    // Simulate hidden VS Code instance
    const shadowWorkspace = {
      hiddenEditor: {
        textModels: new Map(),
        diagnostics: new Map(),
        lspConnections: []
      },
      tempFiles: new Map()
    };
    
    // Simulate file models in shadow workspace
    for (let i = 0; i < 20; i++) {
      const fileContent = 'console.log("test");'.repeat(100); // ~2KB per file
      shadowWorkspace.hiddenEditor.textModels.set(`file-${i}.js`, {
        content: fileContent,
        version: 1,
        ast: { type: 'Program', body: [] }, // Mock AST
        diagnostics: []
      });
    }
    
    // Simulate LSP diagnostics
    for (let i = 0; i < 50; i++) {
      shadowWorkspace.hiddenEditor.diagnostics.set(`diag-${i}`, {
        severity: 'error',
        message: 'Mock diagnostic message',
        range: { start: { line: 1, character: 0 }, end: { line: 1, character: 10 } }
      });
    }
    
    const shadowMemory = this.getMemoryUsage();
    const aiControllerMemory = this.results[0].memory.heapUsed;
    const shadowOverhead = shadowMemory.heapUsed - aiControllerMemory;
    
    this.results.push({
      component: 'Shadow Workspace',
      memory: shadowMemory,
      overhead: shadowOverhead,
      overheadFormatted: this.formatMemory(shadowOverhead),
      targetMet: shadowOverhead <= (200 * 1024 * 1024) // 200MB target for shadow workspace
    });
    
    console.log(`   Memory: ${this.formatMemory(shadowMemory.heapUsed)} (+${this.formatMemory(shadowOverhead)})`);
    
    return shadowWorkspace;
  }

  async simulateLanguageAdapters() {
    console.log('🌐 Simulating Language Adapters...');
    
    const adapters = {};
    const languages = ['javascript', 'python', 'shell', 'typescript'];
    
    // Simulate each language adapter
    languages.forEach(lang => {
      adapters[lang] = {
        lspClient: { connection: {}, capabilities: {} },
        contextCache: new Map(),
        rules: new Array(50).fill({ rule: 'mock-rule', config: {} }),
        diagnosticsParser: { patterns: [], handlers: [] }
      };
      
      // Add some cached context for each adapter
      for (let i = 0; i < 20; i++) {
        adapters[lang].contextCache.set(`${lang}-context-${i}`, {
          symbols: new Array(10).fill({ name: 'symbol', type: 'function' }),
          types: new Array(5).fill({ name: 'Type', definition: 'interface' }),
          imports: new Array(15).fill({ module: 'module', path: '/path' })
        });
      }
    });
    
    const adaptersMemory = this.getMemoryUsage();
    const shadowMemory = this.results[1].memory.heapUsed;
    const adaptersOverhead = adaptersMemory.heapUsed - shadowMemory;
    
    this.results.push({
      component: 'Language Adapters',
      memory: adaptersMemory,
      overhead: adaptersOverhead,
      overheadFormatted: this.formatMemory(adaptersOverhead),
      targetMet: adaptersOverhead <= (50 * 1024 * 1024) // 50MB target for all adapters
    });
    
    console.log(`   Memory: ${this.formatMemory(adaptersMemory.heapUsed)} (+${this.formatMemory(adaptersOverhead)})`);
    
    return adapters;
  }

  async simulateMemoryLeak() {
    console.log('🔍 Testing for memory leaks...');
    
    const initialMemory = this.getMemoryUsage();
    const leakTest = [];
    
    // Simulate 100 AI completion cycles
    for (let cycle = 0; cycle < 100; cycle++) {
      // Simulate completion request processing
      const requestData = {
        context: 'x'.repeat(1000),
        completion: 'y'.repeat(500),
        metadata: { timestamp: Date.now(), cycle }
      };
      
      leakTest.push(requestData);
      
      // Take memory snapshot every 10 cycles
      if (cycle % 10 === 0) {
        const snapshot = this.getMemoryUsage();
        this.memorySnapshots.push({
          cycle,
          memory: snapshot,
          growth: snapshot.heapUsed - initialMemory.heapUsed
        });
      }
      
      // Simulate some processing delay
      await new Promise(resolve => setTimeout(resolve, 10));
    }
    
    // Force garbage collection
    if (global.gc) global.gc();
    await new Promise(resolve => setTimeout(resolve, 1000));
    
    const finalMemory = this.getMemoryUsage();
    const memoryGrowth = finalMemory.heapUsed - initialMemory.heapUsed;
    const growthPercentage = (memoryGrowth / initialMemory.heapUsed) * 100;
    
    const hasMemoryLeak = growthPercentage > 10; // >10% growth indicates potential leak
    
    this.results.push({
      component: 'Memory Leak Test',
      memory: finalMemory,
      overhead: memoryGrowth,
      overheadFormatted: this.formatMemory(memoryGrowth),
      growthPercentage: Math.round(growthPercentage * 100) / 100,
      hasLeak: hasMemoryLeak,
      targetMet: !hasMemoryLeak
    });
    
    console.log(`   Growth: ${this.formatMemory(memoryGrowth)} (${growthPercentage.toFixed(1)}%)`);
    console.log(`   Leak detected: ${hasMemoryLeak ? '❌ YES' : '✅ NO'}`);
    
    return { hasMemoryLeak, memoryGrowth, growthPercentage };
  }

  async runBenchmark() {
    console.log('🚀 Starting Memory Usage Benchmark...\n');
    
    const startTime = performance.now();
    
    try {
      // 1. Establish baseline
      await this.simulateBaseVSCode();
      
      // 2. Test AI Controller memory usage
      await this.simulateAIController();
      
      // 3. Test Shadow Workspace memory usage
      await this.simulateShadowWorkspace();
      
      // 4. Test Language Adapters memory usage
      await this.simulateLanguageAdapters();
      
      // 5. Test for memory leaks
      await this.simulateMemoryLeak();
      
      const totalTime = performance.now() - startTime;
      
      console.log('\n📈 Memory Benchmark Results Summary:');
      console.log('=====================================');
      
      await this.generateReport(totalTime);
      
      return this.results;
    } catch (error) {
      console.error('❌ Memory benchmark failed:', error.message);
      throw error;
    }
  }

  async generateReport(totalTime) {
    const totalOverhead = this.results
      .filter(r => r.component !== 'Memory Leak Test')
      .reduce((sum, r) => sum + r.overhead, 0);
    
    const finalMemory = this.results[this.results.length - 1].memory;
    const meetsOverheadTarget = totalOverhead <= this.targetOverhead;
    
    const componentsWithIssues = this.results.filter(r => !r.targetMet);
    
    const report = {
      timestamp: new Date().toISOString(),
      baseline: {
        memory: this.baselineMemory,
        formatted: this.formatMemory(this.baselineMemory.heapUsed)
      },
      totalOverhead: {
        bytes: totalOverhead,
        formatted: this.formatMemory(totalOverhead),
        target: this.formatMemory(this.targetOverhead),
        meetsTarget: meetsOverheadTarget
      },
      final: {
        memory: finalMemory,
        formatted: this.formatMemory(finalMemory.heapUsed)
      },
      components: this.results,
      memorySnapshots: this.memorySnapshots,
      summary: {
        componentsWithIssues: componentsWithIssues.length,
        totalComponents: this.results.length,
        overallPass: componentsWithIssues.length === 0 && meetsOverheadTarget
      },
      benchmarkDuration: Math.round(totalTime)
    };
    
    // Console output
    console.log(`📊 Baseline Memory: ${this.formatMemory(this.baselineMemory.heapUsed)}`);
    console.log(`📈 Final Memory: ${this.formatMemory(finalMemory.heapUsed)}`);
    console.log(`⬆️  Total Overhead: ${this.formatMemory(totalOverhead)} (target: ${this.formatMemory(this.targetOverhead)})`);
    
    console.log('\n📋 Component Breakdown:');
    this.results.forEach(result => {
      const status = result.targetMet ? '✅' : '❌';
      console.log(`   ${status} ${result.component}: ${result.overheadFormatted}`);
      if (result.hasLeak !== undefined) {
        console.log(`      Memory leak: ${result.hasLeak ? '❌ Detected' : '✅ None'}`);
      }
    });
    
    if (componentsWithIssues.length > 0) {
      console.log('\n⚠️  Components exceeding targets:');
      componentsWithIssues.forEach(component => {
        console.log(`   - ${component.component}: ${component.overheadFormatted}`);
      });
    }
    
    // Save detailed report
    await fs.writeFile(
      path.join(__dirname, 'memory-usage-report.json'),
      JSON.stringify(report, null, 2)
    );
    
    console.log(`\n💾 Detailed report saved to: memory-usage-report.json`);
    
    if (report.summary.overallPass) {
      console.log('\n🎉 MEMORY BENCHMARK PASSED - All targets met!');
    } else {
      console.log('\n⚠️  MEMORY BENCHMARK FAILED - Some targets exceeded');
    }
    
    return report;
  }
}

// CLI execution
async function main() {
  if (require.main === module) {
    const benchmark = new MemoryUsageBenchmark();
    try {
      await benchmark.runBenchmark();
      
      // Exit with appropriate code
      const report = JSON.parse(
        await fs.readFile(path.join(__dirname, 'memory-usage-report.json'))
      );
      
      process.exit(report.summary.overallPass ? 0 : 1);
    } catch (error) {
      console.error('❌ Memory benchmark failed:', error.message);
      process.exit(1);
    }
  }
}

module.exports = MemoryUsageBenchmark;

if (require.main === module) {
  main();
} 