/**
 * Basic integration tests for cursor-uninstaller
 * Tests core functionality
 */

const fs = require('fs');
const path = require('path');

describe('Cursor Uninstaller Basic Tests', () => {
  test('main uninstaller script exists and is readable', () => {
    const scriptPath = path.join(__dirname, '../../bin/uninstall_cursor.sh');
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
    expect(packageJson.main).toBe('bin/uninstall_cursor.sh');
  });

  test('src directory structure is valid', () => {
    const srcPath = path.join(__dirname, '../../src');
    if (fs.existsSync(srcPath)) {
      const srcContents = fs.readdirSync(srcPath);
      // Verify src contains only expected directories
      const allowedDirs = ['components'];
      srcContents.forEach(item => {
        if (fs.statSync(path.join(srcPath, item)).isDirectory()) {
          expect(allowedDirs).toContain(item);
        }
      });
    }
  });

  test('essential project files exist', () => {
    const essentialFiles = [
      'package.json',
      'bin/uninstall_cursor.sh',
      'README.md',
      'jest.config.js'
    ];
    
    essentialFiles.forEach(file => {
      const filePath = path.join(__dirname, '../..', file);
      expect(fs.existsSync(filePath)).toBe(true);
    });
  });
}); 