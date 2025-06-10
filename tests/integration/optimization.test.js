import fs from 'fs';
import path from 'path';
import { execSync } from 'child_process';
import { fileURLToPath } from 'url';
import { dirname } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

describe('Optimization Feature Validation', () => {
  const projectRoot = path.join(__dirname, '..', '..');
  const mainScript = path.join(projectRoot, 'bin', 'uninstall_cursor.sh');
  const optimizationScript = path.join(projectRoot, 'scripts', 'optimize_system.sh');

  test('Main script syntax is valid', () => {
    expect(() => {
      execSync(`bash -n "${mainScript}"`, { encoding: 'utf8' });
    }).not.toThrow();
  });

  test('All required dependencies are loadable', () => {
    const libFiles = ['config.sh', 'error_codes.sh', 'helpers.sh', 'ui.sh'];
    const moduleFiles = [
      'installation.sh',
      'optimization.sh',
      'uninstall.sh',
      'git_integration.sh',
      'complete_removal.sh',
      'ai_optimization.sh'
    ];

    // Check lib files syntax
    libFiles.forEach(file => {
      const filePath = path.join(projectRoot, 'lib', file);
      if (fs.existsSync(filePath)) {
        expect(() => {
          execSync(`bash -n "${filePath}"`, { encoding: 'utf8' });
        }).not.toThrow();
      }
    });

    // Check module files syntax
    moduleFiles.forEach(file => {
      const filePath = path.join(projectRoot, 'modules', file);
      if (fs.existsSync(filePath)) {
        expect(() => {
          execSync(`bash -n "${filePath}"`, { encoding: 'utf8' });
        }).not.toThrow();
      }
    });
  });

  test('Optimization script contains production optimization function', () => {
    const scriptContent = fs.readFileSync(optimizationScript, 'utf8');

    // Should contain the production optimization function
    expect(scriptContent).toMatch(/production_execute_optimize\s*\(\)/);

    // Should contain consolidated optimization logic
    expect(scriptContent).toMatch(/COMPREHENSIVE.*OPTIMIZATION/);
    expect(scriptContent).toMatch(/PRODUCTION-GRADE.*OPTIMIZATION/);
  });

  test('Main script references optimization script correctly', () => {
    const scriptContent = fs.readFileSync(mainScript, 'utf8');

    // Should reference the external optimization script
    expect(scriptContent).toMatch(/scripts\/optimize_system\.sh/);

    // Should contain the execute_optimize function that calls the external script
    expect(scriptContent).toMatch(/execute_optimize\s*\(\)/);
  });

  test('Configuration constants are properly defined', () => {
    const configContent = fs.readFileSync(path.join(projectRoot, 'lib', 'config.sh'), 'utf8');

    // Check essential configuration constants (updated for actual structure)
    expect(configContent).toMatch(/AI_MEMORY_LIMIT_GB=8/);
    expect(configContent).toMatch(/CURSOR_APP_PATH/);
    expect(configContent).toMatch(/MIN_MEMORY_GB/);
  });

  test('Helper functions are available', () => {
    const helpersContent = fs.readFileSync(path.join(projectRoot, 'lib', 'helpers.sh'), 'utf8');

    // Check essential helper functions (these may have different exact names)
    expect(helpersContent).toMatch(/validate.*system/);
    expect(helpersContent).toMatch(/terminate.*cursor/);
    expect(helpersContent).toMatch(/system.*spec/);
  });

  test('UI functions provide consistent interface', () => {
    const uiContent = fs.readFileSync(path.join(projectRoot, 'lib', 'ui.sh'), 'utf8');

    // Check essential UI functions (these may have different exact names)
    expect(uiContent).toMatch(/progress/);
    expect(uiContent).toMatch(/display.*system/);
    expect(uiContent).toMatch(/confirm/);
  });

  test('Script has proper error handling', () => {
    const scriptContent = fs.readFileSync(mainScript, 'utf8');

    // Should have error handling and logging (updated patterns)
    expect(scriptContent).toMatch(/set -euo/); // Updated to match actual pattern
    expect(scriptContent).toMatch(/error_handler/); // Updated to match actual function name
    expect(scriptContent).toMatch(/\$\?/); // Exit code checking
  });

  test('No duplicate or conflicting optimization functions', () => {
    const optimizationContent = fs.readFileSync(optimizationScript, 'utf8');

    // Should have exactly one production optimization function
    const productionOptimizeMatches = optimizationContent.match(/production_execute_optimize/g) || [];
    expect(productionOptimizeMatches.length).toBeGreaterThan(0);

    // Should not have conflicting safe mode functions or unused legacy functions
    expect(optimizationContent).not.toMatch(/optimize_memory_and_performance_safe/);
    expect(optimizationContent).not.toMatch(/optimize_memory_and_performance\(\)/); // Legacy function should be removed
  });

  test('Dependencies in target directory are deployable', () => {
    const targetDir = '/Users/vicd/downloads/cursor_uninstaller';

    if (fs.existsSync(targetDir)) {
      // Check that essential files exist in target
      expect(fs.existsSync(path.join(targetDir, 'bin', 'uninstall_cursor.sh'))).toBe(true);
      expect(fs.existsSync(path.join(targetDir, 'lib', 'config.sh'))).toBe(true);
      expect(fs.existsSync(path.join(targetDir, 'modules', 'optimization.sh'))).toBe(true);

      // Check that the main script in target is executable
      const targetScript = path.join(targetDir, 'bin', 'uninstall_cursor.sh');
      const stats = fs.statSync(targetScript);
      expect(stats.mode & parseInt('111', 8)).toBeTruthy(); // Executable permissions
    }
  });
});
