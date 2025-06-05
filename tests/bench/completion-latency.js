/**
 * Completion Latency Benchmark
 * Measures AI completion performance across different scenarios
 * Target: <0.5s average completion time
 */

const { performance } = require('perf_hooks');
const fs = require('fs').promises;
const path = require('path');

class CompletionLatencyBenchmark {
  constructor() {
    this.results = [];
    this.scenarios = [
      {
        name: 'Simple JavaScript Variable',
        code: 'const x = ',
        language: 'javascript',
        complexity: 'simple',
        expectedLatency: 200 // ms
      },
      {
        name: 'JavaScript Function Declaration',
        code: 'function calculateSum(a, b) {\n  return ',
        language: 'javascript',
        complexity: 'medium',
        expectedLatency: 350
      },
      {
        name: 'React Component',
        code: 'const MyComponent = () => {\n  const [state, setState] = ',
        language: 'javascript',
        complexity: 'medium',
        expectedLatency: 400
      },
      {
        name: 'Python List Comprehension',
        code: 'numbers = [x for x in range(10) if ',
        language: 'python',
        complexity: 'medium',
        expectedLatency: 350
      },
      {
        name: 'Python Class Method',
        code: 'class DataProcessor:\n    def process_data(self, data):\n        return ',
        language: 'python',
        complexity: 'medium',
        expectedLatency: 400
      },
      {
        name: 'Shell Script Loop',
        code: 'for file in *.txt; do\n  echo ',
        language: 'shell',
        complexity: 'simple',
        expectedLatency: 250
      },
      {
        name: 'Large File Context (1000+ lines)',
        code: 'export const apiEndpoint = ',
        language: 'javascript',
        complexity: 'complex',
        expectedLatency: 800,
        contextSize: 'large'
      },
      {
        name: 'TypeScript Interface Extension',
        code: 'interface ApiResponse extends BaseResponse {\n  data: ',
        language: 'typescript',
        complexity: 'medium',
        expectedLatency: 400
      }
    ];
  }

  async mockAICompletion(scenario) {
    // Simulate AI completion with varying latency based on complexity
    const baseLatency = {
      simple: 150,
      medium: 300,
      complex: 600
    };

    const complexityMultiplier = {
      simple: 1,
      medium: 1.2,
      complex: 2.5
    };

    const contextMultiplier = scenario.contextSize === 'large' ? 1.8 : 1;
    
    // Add random variation (±20%)
    const variation = 0.8 + (Math.random() * 0.4);
    
    const simulatedLatency = baseLatency[scenario.complexity] * 
                           complexityMultiplier[scenario.complexity] * 
                           contextMultiplier * 
                           variation;

    return new Promise(resolve => {
      setTimeout(() => {
        resolve({
          completion: this.generateMockCompletion(scenario),
          confidence: 0.85 + (Math.random() * 0.15)
        });
      }, simulatedLatency);
    });
  }

  generateMockCompletion(scenario) {
    const completions = {
      'Simple JavaScript Variable': '"hello world"',
      'JavaScript Function Declaration': 'a + b;',
      'React Component': 'useState(0);',
      'Python List Comprehension': 'x % 2 == 0]',
      'Python Class Method': 'processed_data',
      'Shell Script Loop': '"Processing $file"',
      'Large File Context (1000+ lines)': '"https://api.example.com/v1"',
      'TypeScript Interface Extension': 'ApiData[]'
    };
    
    return completions[scenario.name] || 'completion';
  }

  async measureCompletion(scenario) {
    const startTime = performance.now();
    
    try {
      const result = await this.mockAICompletion(scenario);
      const endTime = performance.now();
      const latency = endTime - startTime;

      return {
        scenario: scenario.name,
        language: scenario.language,
        complexity: scenario.complexity,
        latency: Math.round(latency),
        expectedLatency: scenario.expectedLatency,
        success: true,
        completion: result.completion,
        confidence: result.confidence,
        performance: latency <= scenario.expectedLatency ? 'PASS' : 'FAIL'
      };
    } catch (error) {
      const endTime = performance.now();
      const latency = endTime - startTime;

      return {
        scenario: scenario.name,
        language: scenario.language,
        complexity: scenario.complexity,
        latency: Math.round(latency),
        expectedLatency: scenario.expectedLatency,
        success: false,
        error: error.message,
        performance: 'ERROR'
      };
    }
  }

  async runBenchmark() {
    console.log('🚀 Starting Completion Latency Benchmark...\n');
    
    const startTime = performance.now();
    
    for (let i = 0; i < this.scenarios.length; i++) {
      const scenario = this.scenarios[i];
      console.log(`📊 Testing: ${scenario.name} (${scenario.complexity})`);
      
      // Run each scenario 3 times and take average
      const runs = [];
      for (let run = 0; run < 3; run++) {
        const result = await this.measureCompletion(scenario);
        runs.push(result);
        process.stdout.write(`.`);
      }
      
      // Calculate average latency
      const avgLatency = Math.round(
        runs.reduce((sum, run) => sum + run.latency, 0) / runs.length
      );
      
      const bestRun = runs[0];
      bestRun.latency = avgLatency;
      
      this.results.push(bestRun);
      
      const status = bestRun.performance === 'PASS' ? '✅' : '❌';
      console.log(` ${status} ${avgLatency}ms (target: ${scenario.expectedLatency}ms)`);
    }
    
    const totalTime = performance.now() - startTime;
    
    console.log('\n📈 Benchmark Results Summary:');
    console.log('================================');
    
    await this.generateReport(totalTime);
    
    return this.results;
  }

  async generateReport(totalTime) {
    const passed = this.results.filter(r => r.performance === 'PASS').length;
    const failed = this.results.filter(r => r.performance === 'FAIL').length;
    const errors = this.results.filter(r => r.performance === 'ERROR').length;
    
    const avgLatency = Math.round(
      this.results.reduce((sum, r) => sum + r.latency, 0) / this.results.length
    );
    
    const maxLatency = Math.max(...this.results.map(r => r.latency));
    const minLatency = Math.min(...this.results.map(r => r.latency));
    
    // Performance by complexity
    const simpleAvg = this.getAvgLatencyByComplexity('simple');
    const mediumAvg = this.getAvgLatencyByComplexity('medium');
    const complexAvg = this.getAvgLatencyByComplexity('complex');
    
    // Performance by language
    const langPerformance = this.getPerformanceByLanguage();
    
    const report = {
      timestamp: new Date().toISOString(),
      totalTests: this.results.length,
      passed,
      failed,
      errors,
      successRate: Math.round((passed / this.results.length) * 100),
      metrics: {
        avgLatency,
        minLatency,
        maxLatency,
        targetLatency: 500, // 0.5s
        meetsTarget: avgLatency <= 500
      },
      performanceByComplexity: {
        simple: { avg: simpleAvg, target: 200 },
        medium: { avg: mediumAvg, target: 400 },
        complex: { avg: complexAvg, target: 800 }
      },
      performanceByLanguage: langPerformance,
      totalBenchmarkTime: Math.round(totalTime),
      results: this.results
    };
    
    // Console output
    console.log(`Total Tests: ${this.results.length}`);
    console.log(`✅ Passed: ${passed} (${Math.round((passed/this.results.length)*100)}%)`);
    console.log(`❌ Failed: ${failed} (${Math.round((failed/this.results.length)*100)}%)`);
    if (errors > 0) console.log(`💥 Errors: ${errors}`);
    
    console.log(`\n⏱️  Average Latency: ${avgLatency}ms (target: 500ms)`);
    console.log(`⚡ Fastest: ${minLatency}ms`);
    console.log(`🐌 Slowest: ${maxLatency}ms`);
    
    console.log('\n📊 Performance by Complexity:');
    console.log(`   Simple: ${simpleAvg}ms (target: 200ms)`);
    console.log(`   Medium: ${mediumAvg}ms (target: 400ms)`);
    console.log(`   Complex: ${complexAvg}ms (target: 800ms)`);
    
    console.log('\n🌐 Performance by Language:');
    Object.entries(langPerformance).forEach(([lang, perf]) => {
      console.log(`   ${lang}: ${perf.avg}ms (${perf.tests} tests)`);
    });
    
    // Save detailed report
    await fs.writeFile(
      path.join(__dirname, 'completion-latency-report.json'),
      JSON.stringify(report, null, 2)
    );
    
    console.log(`\n💾 Detailed report saved to: completion-latency-report.json`);
    
    if (report.metrics.meetsTarget) {
      console.log(`\n🎉 BENCHMARK PASSED - Average latency meets target!`);
    } else {
      console.log(`\n⚠️  BENCHMARK FAILED - Average latency exceeds target`);
    }
    
    return report;
  }

  getAvgLatencyByComplexity(complexity) {
    const results = this.results.filter(r => r.complexity === complexity);
    if (results.length === 0) return 0;
    return Math.round(results.reduce((sum, r) => sum + r.latency, 0) / results.length);
  }

  getPerformanceByLanguage() {
    const languages = {};
    
    this.results.forEach(result => {
      if (!languages[result.language]) {
        languages[result.language] = { total: 0, count: 0 };
      }
      languages[result.language].total += result.latency;
      languages[result.language].count += 1;
    });
    
    Object.keys(languages).forEach(lang => {
      languages[lang] = {
        avg: Math.round(languages[lang].total / languages[lang].count),
        tests: languages[lang].count
      };
    });
    
    return languages;
  }
}

// CLI execution
async function main() {
  if (require.main === module) {
    const benchmark = new CompletionLatencyBenchmark();
    try {
      await benchmark.runBenchmark();
      
      // Exit with appropriate code
      const report = JSON.parse(
        await fs.readFile(path.join(__dirname, 'completion-latency-report.json'))
      );
      
      process.exit(report.metrics.meetsTarget ? 0 : 1);
    } catch (error) {
      console.error('❌ Benchmark failed:', error.message);
      process.exit(1);
    }
  }
}

module.exports = CompletionLatencyBenchmark;

if (require.main === module) {
  main();
} 