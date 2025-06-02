/**
 * Basic integration tests for cursor-uninstaller
 * Tests basic functionality after dashboard removal
 */

const fs = require('fs');
const path = require('path');

describe('Cursor Uninstaller Basic Tests', () => {
  test('main uninstaller script exists and is readable', () => {
    const scriptPath = path.join(__dirname, '../../uninstall_cursor.sh');
    expect(fs.existsSync(scriptPath)).toBe(true);
    
    const stats = fs.statSync(scriptPath);
    expect(stats.isFile()).toBe(true);
    expect(stats.size).toBeGreaterThan(0);
  });

  test('package.json has correct structure', () => {
    const packagePath = path.join(__dirname, '../../package.json');
    expect(fs.existsSync(packagePath)).toBe(true);
    
    const packageJson = JSON.parse(fs.readFileSync(packagePath, 'utf8'));
    expect(packageJson.name).toBe('cursor-uninstaller');
    expect(packageJson.description).toBe('Cursor uninstaller tool for macOS');
    expect(packageJson.main).toBe('uninstall_cursor.sh');
  });

  test('dashboard directory has been completely removed', () => {
    const dashboardPath = path.join(__dirname, '../../src/dashboard');
    expect(fs.existsSync(dashboardPath)).toBe(false);
  });

  test('src directory structure is clean', () => {
    const srcPath = path.join(__dirname, '../../src');
    if (fs.existsSync(srcPath)) {
      const srcContents = fs.readdirSync(srcPath);
      expect(srcContents).not.toContain('dashboard');
    }
  });

  test('no dashboard references in package.json', () => {
    const packagePath = path.join(__dirname, '../../package.json');
    const packageContent = fs.readFileSync(packagePath, 'utf8');
    expect(packageContent.toLowerCase()).not.toContain('dashboard');
    expect(packageContent.toLowerCase()).not.toContain('react');
    expect(packageContent.toLowerCase()).not.toContain('vite');
  });
}); 