#!/usr/bin/env node

/**
 * Comprehensive ESLint Auto-Fix Script
 * Systematically removes unused imports and variables from all JS/JSX files
 */

const fs = require('fs');
const path = require('path');

// Files to fix and their unused imports/variables
const fixes = {
  // This script is kept for potential future use
};

console.log('🔧 Starting comprehensive linting fixes...\n');

Object.entries(fixes).forEach(([filePath, { removeImports, prefixUnused }]) => {
  const fullPath = path.join(__dirname, filePath);
  
  if (!fs.existsSync(fullPath)) {
    console.log(`⚠️  File not found: ${filePath}`);
    return;
  }

  let content = fs.readFileSync(fullPath, 'utf8');
  let modified = false;

  // Remove unused imports
  removeImports.forEach(importName => {
    // Remove from import statements
    const importRegex = new RegExp(`\\s*,?\\s*${importName}\\s*,?`, 'g');
    const beforeImport = content;
    content = content.replace(importRegex, '');
    
    // Clean up empty commas and spaces
    content = content.replace(/,\s*,/g, ',');
    content = content.replace(/{\s*,/g, '{');
    content = content.replace(/,\s*}/g, '}');
    
    if (content !== beforeImport) {
      modified = true;
      console.log(`  ✓ Removed unused import: ${importName}`);
    }
  });

  // Prefix unused variables with underscore
  prefixUnused.forEach(varName => {
    // Handle function parameters
    const paramRegex = new RegExp(`\\b${varName}\\b(?=\\s*[,=})])`, 'g');
    const beforeParam = content;
    content = content.replace(paramRegex, `_${varName}`);
    
    // Handle variable declarations
    const declRegex = new RegExp(`(const|let|var)\\s+${varName}\\b`, 'g');
    const beforeDecl = content;
    content = content.replace(declRegex, `$1 _${varName}`);
    
    if (content !== beforeParam || content !== beforeDecl) {
      modified = true;
      console.log(`  ✓ Prefixed unused variable: ${varName} → _${varName}`);
    }
  });

  if (modified) {
    fs.writeFileSync(fullPath, content);
    console.log(`✅ Fixed: ${filePath}\n`);
  } else {
    console.log(`ℹ️  No changes needed: ${filePath}\n`);
  }
});

console.log('🎉 Comprehensive linting fixes completed!');
console.log('Run "npx eslint . --ext .js,.jsx" to verify fixes.'); 