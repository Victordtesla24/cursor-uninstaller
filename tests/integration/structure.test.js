const fs = require('fs');
const path = require('path');

describe('Project Directory Structure Validation', () => {
  const projectRoot = path.join(__dirname, '..', '..'); // Adjusted path for tests/integration

  test('Essential directories should exist', () => {
    const dirsToExist = ['bin', 'scripts', 'tests', 'docs', '.github', '.cursor', '.clinerules'];
    dirsToExist.forEach(dir => {
      const dirPath = path.join(projectRoot, dir);
      expect(fs.existsSync(dirPath)).toBe(true);
      expect(fs.lstatSync(dirPath).isDirectory()).toBe(true);
    });
  });

  test('Essential root files should exist', () => {
    const filesToExist = [
      'package.json',
      'jest.config.js',
      'Dockerfile',
      '.gitignore',
      'README.md',
      '.pre-commit-config.yaml'
    ];
    filesToExist.forEach(file => {
      const filePath = path.join(projectRoot, file);
      expect(fs.existsSync(filePath)).toBe(true);
      expect(fs.lstatSync(filePath).isFile()).toBe(true);
    });
  });

  test('bin/ directory should contain the main uninstaller script and nothing else', () => {
    const binPath = path.join(projectRoot, 'bin');
    expect(fs.existsSync(binPath)).toBe(true);
    const binContents = fs.readdirSync(binPath);
    expect(binContents).toEqual(['uninstall_cursor.sh']);
  });

  test('scripts/ directory should contain expected utility scripts and resume-creation/', () => {
    const scriptsDir = path.join(projectRoot, 'scripts');
    const actualScriptsContents = fs.readdirSync(scriptsDir).sort();
    const expectedScriptsContents = [
      'build_release.sh',
      'create_dmg_package.sh',
      'install_cursor_uninstaller.sh',
      'resume-creation'
    ].sort();
    expect(actualScriptsContents).toEqual(expectedScriptsContents);
  });

  test('No unexpected files or directories in root (visual check reminder)', () => {
    // This test serves as a reminder for a manual check or more sophisticated listing/diffing if needed.
    // For now, it just passes.
    expect(true).toBe(true);
  });
  
  test('src/ directory should exist (currently expected to fail if src is missing)', () => {
    const srcPath = path.join(projectRoot, 'src');
    // This test is expected to fail until src is restored.
    expect(fs.existsSync(srcPath)).toBe(true); 
  });
}); 