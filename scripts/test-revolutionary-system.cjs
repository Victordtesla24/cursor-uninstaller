#!/usr/bin/env node
/**
 * @fileoverview
 * Basic System Test Script
 * 
 * Tests the actual components that exist in the project.
 * No false claims about non-existent AI models or capabilities.
 */

const fs = require('fs');
const path = require('path');

console.log('=== Basic System Test ===\n');

let totalTests = 0;
let passedTests = 0;

function test(name, testFunction) {
  totalTests++;
  try {
    const result = testFunction();
    if (result) {
      console.log(`✅ ${name}`);
      passedTests++;
    } else {
      console.log(`❌ ${name} - Test returned false`);
    }
  } catch (error) {
    console.log(`❌ ${name} - ${error.message}`);
  }
}

function fileExists(filePath) {
  return fs.existsSync(path.join(__dirname, '..', filePath));
}

// Test Core Files Exist
console.log('Core File Tests:');
test('Package.json exists', () => fileExists('package.json'));
test('Main script exists', () => fileExists('bin/cursor-ai-uninstaller'));
test('AI index exists', () => fileExists('lib/ai/index.js'));
test('Basic AI helper exists', () => fileExists('lib/ai/basic-ai-helper.js'));
test('Basic context manager exists', () => fileExists('lib/ai/basic-context-manager.js'));
test('Basic model selector exists', () => fileExists('lib/ai/basic-model-selector.js'));
test('Basic MCP server exists', () => fileExists('lib/ai/basic-mcp-server.js'));

console.log('\nAI Client Placeholder Tests:');
test('Claude client placeholder exists', () => fileExists('lib/ai/clients/claude-client.js'));
test('GPT client placeholder exists', () => fileExists('lib/ai/clients/gpt-client.js'));
test('Gemini client placeholder exists', () => fileExists('lib/ai/clients/gemini-client.js'));
test('O3 client placeholder exists', () => fileExists('lib/ai/clients/o3-client.js'));

console.log('\nMCP Server Tests:');
test('Browser MCP server exists', () => fileExists('lib/tools/browser-mcp-server.js'));
test('MCP servers test script exists', () => fileExists('scripts/test-mcp-servers.js'));

// Test MCP Configuration
console.log('\nMCP Configuration Test:');
test('User MCP config exists', () => {
  const mcpPath = path.join(process.env.HOME, '.cursor', 'mcp.json');
  if (fs.existsSync(mcpPath)) {
    const config = JSON.parse(fs.readFileSync(mcpPath, 'utf8'));
    const hasServers = config.mcpServers && Object.keys(config.mcpServers).length > 0;
    if (hasServers) {
      console.log(`   Found ${Object.keys(config.mcpServers).length} MCP servers configured`);
    }
    return hasServers;
  }
  return false;
});

// Test Cache Components
console.log('\nCache Component Tests:');
test('Basic cache exists', () => fileExists('lib/cache/basic-cache.js'));
test('Result cache exists', () => fileExists('lib/cache/result-cache.js'));

// Test System Components
console.log('\nSystem Component Tests:');
test('Lifecycle manager exists', () => fileExists('lib/system/LifecycleManager.js'));
test('Error definitions exist', () => fileExists('lib/system/errors.js'));

// Test Scripts
console.log('\nScript Tests:');
test('Cursor production optimizer exists', () => fileExists('scripts/cursor_production_optimizer.sh'));
test('Syntax checker exists', () => fileExists('scripts/syntax_and_shellcheck.sh'));
test('Performance demo exists', () => fileExists('scripts/performance-demo.js'));

// Summary
console.log('\n=== Test Summary ===');
console.log(`Total Tests: ${totalTests}`);
console.log(`Passed: ${passedTests}`);
console.log(`Failed: ${totalTests - passedTests}`);
console.log(`Success Rate: ${((passedTests / totalTests) * 100).toFixed(1)}%`);

console.log('\n📌 Important Notes:');
console.log('- AI client files are placeholders that require API keys and implementation');
console.log('- No "revolutionary" AI models exist - these are development placeholders');
console.log('- MCP servers require proper configuration in Cursor to function');
console.log('- Performance claims should be validated with real benchmarks');

process.exit(totalTests === passedTests ? 0 : 1); 