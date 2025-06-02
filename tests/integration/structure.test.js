const fs = require('fs');
const path = require('path');

describe('Project Directory Structure Validation', () => {
  const projectRoot = path.join(__dirname, '..', '..'); // Adjusted path for tests/integration

  test('Essential directories should exist', () => {
    const dirsToExist = ['bin', 'lib', 'modules', 'scripts', 'tests', 'docs', '.github', '.cursor', '.clinerules'];
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

  test('lib/ directory should contain essential library files', () => {
    const libPath = path.join(projectRoot, 'lib');
    expect(fs.existsSync(libPath)).toBe(true);
    const libContents = fs.readdirSync(libPath).sort();
    const expectedLibContents = ['config.sh', 'helpers.sh', 'ui.sh'].sort();
    expect(libContents).toEqual(expectedLibContents);
  });

  test('modules/ directory should contain functional modules', () => {
    const modulesPath = path.join(projectRoot, 'modules');
    expect(fs.existsSync(modulesPath)).toBe(true);
    const modulesContents = fs.readdirSync(modulesPath).sort();
    const expectedModulesContents = [
      'ai_optimization.sh',
      'complete_removal.sh', 
      'git_integration.sh',
      'installation.sh',
      'optimization.sh',
      'uninstall.sh'
    ].sort();
    expect(modulesContents).toEqual(expectedModulesContents);
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

  test('No development artifacts should remain in root', () => {
    const rootContents = fs.readdirSync(projectRoot);
    const bannedItems = ['coverage', '.vscode', 'src'];
    
    bannedItems.forEach(bannedItem => {
      expect(rootContents).not.toContain(bannedItem);
    });
  });
  
  test('Main script dependencies are satisfied', () => {
    // Check that main script can find all its dependencies
    const libFiles = ['config.sh', 'helpers.sh', 'ui.sh'];
    const moduleFiles = [
      'installation.sh',
      'optimization.sh', 
      'uninstall.sh',
      'git_integration.sh',
      'complete_removal.sh',
      'ai_optimization.sh'
    ];
    
    libFiles.forEach(file => {
      const filePath = path.join(projectRoot, 'lib', file);
      expect(fs.existsSync(filePath)).toBe(true);
    });
    
    moduleFiles.forEach(file => {
      const filePath = path.join(projectRoot, 'modules', file);
      expect(fs.existsSync(filePath)).toBe(true);
    });
  });
}); 