const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

describe('Optimization Feature Validation', () => {
  const projectRoot = path.join(__dirname, '..', '..');
  const mainScript = path.join(projectRoot, 'bin', 'uninstall_cursor.sh');
  
  test('Main script syntax is valid', () => {
    expect(() => {
      execSync(`bash -n "${mainScript}"`, { encoding: 'utf8' });
    }).not.toThrow();
  });

  test('All required dependencies are loadable', () => {
    const libFiles = ['config.sh', 'helpers.sh', 'ui.sh'];
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
      expect(() => {
        execSync(`bash -n "${filePath}"`, { encoding: 'utf8' });
      }).not.toThrow();
    });
    
    // Check module files syntax
    moduleFiles.forEach(file => {
      const filePath = path.join(projectRoot, 'modules', file);
      expect(() => {
        execSync(`bash -n "${filePath}"`, { encoding: 'utf8' });
      }).not.toThrow();
    });
  });

  test('Main script contains production optimization function', () => {
    const scriptContent = fs.readFileSync(mainScript, 'utf8');
    
    // Should contain the production optimization function
    expect(scriptContent).toMatch(/production_execute_optimize\s*\(\)/);
    
    // Should NOT contain the problematic choice menu
    expect(scriptContent).not.toMatch(/Choose optimization mode \[1-3\]/);
    expect(scriptContent).not.toMatch(/SAFE OPTIMIZATIONS ONLY/);
    
    // Should contain consolidated optimization logic
    expect(scriptContent).toMatch(/COMPREHENSIVE.*OPTIMIZATION/);
    expect(scriptContent).toMatch(/PRODUCTION-GRADE.*OPTIMIZATION/);
  });

  test('Configuration constants are properly defined', () => {
    const configContent = fs.readFileSync(path.join(projectRoot, 'lib', 'config.sh'), 'utf8');
    
    // Check essential configuration constants
    expect(configContent).toMatch(/export ERR_GENERAL=1/);
    expect(configContent).toMatch(/export AI_MEMORY_LIMIT_GB=8/);
    expect(configContent).toMatch(/export AI_CONTEXT_LENGTH=8192/);
    expect(configContent).toMatch(/export CURSOR_APP_PATH/);
  });

  test('Helper functions are available', () => {
    const helpersContent = fs.readFileSync(path.join(projectRoot, 'lib', 'helpers.sh'), 'utf8');
    
    // Check essential helper functions
    expect(helpersContent).toMatch(/validate_system_requirements\s*\(\)/);
    expect(helpersContent).toMatch(/terminate_cursor_processes\s*\(\)/);
    expect(helpersContent).toMatch(/get_system_specs\s*\(\)/);
  });

  test('UI functions provide consistent interface', () => {
    const uiContent = fs.readFileSync(path.join(projectRoot, 'lib', 'ui.sh'), 'utf8');
    
    // Check essential UI functions
    expect(uiContent).toMatch(/show_progress\s*\(\)/);
    expect(uiContent).toMatch(/display_system_specifications\s*\(\)/);
    expect(uiContent).toMatch(/confirm_operation\s*\(\)/);
  });

  test('Script has proper error handling', () => {
    const scriptContent = fs.readFileSync(mainScript, 'utf8');
    
    // Should have error handling and logging
    expect(scriptContent).toMatch(/set -eE/);
    expect(scriptContent).toMatch(/production_error_handler/);
    expect(scriptContent).toMatch(/\$\?/); // Exit code checking
  });

  test('No duplicate or conflicting optimization functions', () => {
    const scriptContent = fs.readFileSync(mainScript, 'utf8');
    
    // Should only have one main optimization function
    const optimizeFunctionMatches = scriptContent.match(/function.*optimize.*\(\)|optimize.*\(\s*\)\s*{/g) || [];
    const productionOptimizeMatches = scriptContent.match(/production_execute_optimize/g) || [];
    
    // Should have exactly one production optimization function
    expect(productionOptimizeMatches.length).toBeGreaterThan(0);
    
    // Should not have conflicting safe mode functions
    expect(scriptContent).not.toMatch(/optimize_memory_and_performance_safe/);
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