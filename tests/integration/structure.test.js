const fs = require('fs');
const path = require('path');

describe('Project Directory Structure Protocol Validation', () => {
  const projectRoot = path.join(__dirname, '..', '..');

  // Helper function to recursively scan directory structure
  function scanDirectory(dirPath, excludePatterns = []) {
    const defaultExcludes = [
      'node_modules', '.venv', '.git', '.cursor', '.vscode',
      'build', 'dist', 'coverage', '.husky'
    ];
    const allExcludes = [...defaultExcludes, ...excludePatterns];

    const items = [];

    try {
      const contents = fs.readdirSync(dirPath);

      for (const item of contents) {
        if (allExcludes.includes(item)) continue;

        const itemPath = path.join(dirPath, item);
        const stats = fs.statSync(itemPath);

        items.push({
          name: item,
          path: itemPath,
          relativePath: path.relative(projectRoot, itemPath),
          isDirectory: stats.isDirectory(),
          isFile: stats.isFile()
        });
      }
    } catch (_error) {
      // Directory doesn't exist or can't be read
      return [];
    }

    return items;
  }

  // Helper function to detect potential duplicates based on naming patterns
  function detectPotentialDuplicates(items) {
    const duplicates = [];
    const nameGroups = {};

    items.forEach(item => {
      const fileName = item.name.toLowerCase();

      // Exclude common, non-problematic duplicate names like index.js
      if (fileName.startsWith('index.')) {
        return;
      }

      // Group by full file name (case-insensitive)
      if (!nameGroups[fileName]) {
        nameGroups[fileName] = [];
      }
      nameGroups[fileName].push(item);
    });

    Object.entries(nameGroups).forEach(([fileName, group]) => {
      if (group.length > 1) {
        duplicates.push({
          baseName: path.basename(fileName, path.extname(fileName)),
          items: group
        });
      }
    });

    return duplicates;
  }

  // Helper function to validate project structure conventions
  function validateProjectConventions() {
    const packageJsonPath = path.join(projectRoot, 'package.json');
    let projectType = 'unknown';

    if (fs.existsSync(packageJsonPath)) {
      try {
        const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, 'utf8'));
        if (packageJson.dependencies?.react || packageJson.devDependencies?.react) {
          projectType = 'react';
        } else if (packageJson.dependencies?.next || packageJson.devDependencies?.next) {
          projectType = 'nextjs';
        } else if (packageJson.type === 'module' || packageJson.main) {
          projectType = 'node';
        }
      } catch (_error) {
        // Invalid package.json
      }
    }

    return { projectType };
  }

  test('Directory structure should follow established conventions', () => {
    validateProjectConventions();
    const rootItems = scanDirectory(projectRoot);

    // Verify essential project files exist
    const hasPackageJson = rootItems.some(item => item.name === 'package.json');
    const hasReadme = rootItems.some(item => item.name.toLowerCase().includes('readme'));

    expect(hasPackageJson).toBe(true);
    expect(hasReadme).toBe(true);

    // Verify no prohibited development artifacts in root
    const prohibitedItems = ['node_modules_backup', '.env.local', 'debug.log'];
    prohibitedItems.forEach(prohibited => {
      expect(rootItems.some(item => item.name === prohibited)).toBe(false);
    });
  });

  test('Should not contain duplicate or overlapping files', () => {
    const allItems = [];

    // Recursively collect all files
    function collectItems(dirPath, depth = 0) {
      if (depth > 5) return; // Prevent infinite recursion

      const items = scanDirectory(dirPath);
      allItems.push(...items.filter(item => item.isFile));

      items.filter(item => item.isDirectory).forEach(dir => {
        collectItems(dir.path, depth + 1);
      });
    }

    collectItems(projectRoot);

    const potentialDuplicates = detectPotentialDuplicates(allItems);

    // This test now expects no duplicates after refining the logic.
    if (potentialDuplicates.length > 0) {
      console.warn('Potential duplicate files detected:');
      potentialDuplicates.forEach(duplicate => {
        console.warn(`- ${duplicate.baseName}:`, duplicate.items.map(item => item.relativePath));
      });
    }

    // This test passes but warns about potential issues
    expect(potentialDuplicates).toHaveLength(0);
  });

  test('File organization should follow single responsibility principle', () => {
    const rootItems = scanDirectory(projectRoot);
    const directories = rootItems.filter(item => item.isDirectory);
    const files = rootItems.filter(item => item.isFile);

    // Verify reasonable file-to-directory ratio (not too many loose files)
    const looseFiles = files.filter(file =>
      !['package.json', 'package-lock.json', 'README.md', 'CHANGELOG.md',
        'LICENSE', '.gitignore', 'Dockerfile', 'docker-compose.yml',
        'jest.config.js', 'eslint.config.js', 'tsconfig.json'].includes(file.name)
    );

    // Should have more organized directories than loose files
    expect(directories.length).toBeGreaterThanOrEqual(looseFiles.length);
  });

  test('Import paths should be resolvable', () => {
    const jsFiles = [];

    function findJsFiles(dirPath, depth = 0) {
      if (depth > 5) return;

      const items = scanDirectory(dirPath);
      jsFiles.push(...items.filter(item =>
        item.isFile && /\.(js|jsx|ts|tsx)$/.test(item.name)
      ));

      items.filter(item => item.isDirectory).forEach(dir => {
        findJsFiles(dir.path, depth + 1);
      });
    }

    findJsFiles(projectRoot);

    let unresolvedImports = 0;

    jsFiles.forEach(file => {
      try {
        const content = fs.readFileSync(file.path, 'utf8');
        const importMatches = content.match(/(?:import|require)\s*\(?['"`]([^'"`]+)['"`]\)?/g);

        if (importMatches) {
          importMatches.forEach(importStatement => {
            const match = importStatement.match(/['"`]([^'"`]+)['"`]/);
            if (match && match[1].startsWith('.')) {
              // Relative import - check if file exists
              const importPath = path.resolve(path.dirname(file.path), match[1]);
              const possibleExtensions = ['', '.js', '.jsx', '.ts', '.tsx', '/index.js', '/index.jsx'];

              const exists = possibleExtensions.some(ext =>
                fs.existsSync(importPath + ext)
              );

              if (!exists) {
                unresolvedImports++;
                console.warn(`Unresolved import: ${match[1]} in ${file.relativePath}`);
              }
            }
          });
        }
      } catch (_error) {
        // File read error - skip
      }
    });

    expect(unresolvedImports).toBe(0);
  });

  test('Configuration files should be properly placed', () => {
    const rootItems = scanDirectory(projectRoot);
    const configFiles = rootItems.filter(item =>
      item.isFile && (
        item.name.includes('config') ||
        item.name.startsWith('.') ||
        item.name.includes('rc') ||
        ['package.json', 'tsconfig.json', 'jest.config.js', 'eslint.config.js'].includes(item.name)
      )
    );

    // Configuration files should be in root or dedicated config directories
    configFiles.forEach(configFile => {
      const isInRoot = path.dirname(configFile.path) === projectRoot;
      const isInConfigDir = configFile.relativePath.includes('config') ||
        configFile.relativePath.includes('.config');

      expect(isInRoot || isInConfigDir).toBe(true);
    });
  });

  test('Directory structure should support maintainability', () => {
    const rootItems = scanDirectory(projectRoot);
    const directories = rootItems.filter(item => item.isDirectory);

    // Check for overly deep nesting (max 5 levels recommended)
    function checkDepth(dirPath, currentDepth = 0) {
      if (currentDepth > 5) {
        return currentDepth;
      }

      const items = scanDirectory(dirPath);
      const subdirs = items.filter(item => item.isDirectory);

      let maxDepth = currentDepth;
      subdirs.forEach(subdir => {
        const depth = checkDepth(subdir.path, currentDepth + 1);
        maxDepth = Math.max(maxDepth, depth);
      });

      return maxDepth;
    }

    const maxDepth = checkDepth(projectRoot);
    expect(maxDepth).toBeLessThanOrEqual(5);

    // Verify reasonable number of items per directory (not too cluttered)
    directories.forEach(dir => {
      const items = scanDirectory(dir.path);
      if (items.length > 20) {
        console.warn(`Directory ${dir.relativePath} contains ${items.length} items - consider reorganization`);
      }
      expect(items.length).toBeLessThanOrEqual(30); // Hard limit
    });
  });
});