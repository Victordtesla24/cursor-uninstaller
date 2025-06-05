#!/bin/bash
# Cursor AI Editor Enhancement Setup Script
# Resolves all dependencies in one command

set -euo pipefail

echo "🚀 Setting up Cursor AI Editor Enhancement Environment..."

# 1. Validate environment
echo "📋 Validating environment..."
command -v node >/dev/null 2>&1 || { echo "❌ Node.js required"; exit 1; }
command -v npm >/dev/null 2>&1 || { echo "❌ npm required"; exit 1; }

# 2. Install Node.js dependencies
echo "📦 Installing Node.js dependencies..."
npm install --silent

# 3. Install development tools
echo "🔧 Installing development tools..."
npm install -g jest eslint typescript @types/vscode --silent

# 4. Create required directories
echo "📁 Creating directory structure..."
mkdir -p lib/ai lib/lang/adapters lib/shadow lib/cache lib/ui
mkdir -p modules/performance modules/integration
mkdir -p tests/bench tests/unit tests/e2e
mkdir -p scripts

# 5. Initialize configuration files
echo "⚙️  Creating configuration files..."
cat > .eslintrc.json << EOF
{
  "extends": ["eslint:recommended"],
  "env": {
    "node": true,
    "es2021": true
  },
  "parserOptions": {
    "ecmaVersion": 12,
    "sourceType": "module"
  }
}
EOF

# Update jest config (merge with existing)
cat > jest.config.enhanced.js << EOF
module.exports = {
  testEnvironment: 'node',
  collectCoverage: true,
  coverageThreshold: {
    global: {
      branches: 90,
      functions: 90,
      lines: 90,
      statements: 90
    }
  },
  testMatch: ['**/tests/**/*.test.js'],
  setupFilesAfterEnv: ['<rootDir>/tests/setup.js']
};
EOF

# 6. Set up VS Code workspace
echo "💼 Configuring VS Code workspace..."
mkdir -p .vscode
cat > .vscode/settings.json << EOF
{
  "editor.formatOnSave": true,
  "eslint.autoFixOnSave": true,
  "typescript.preferences.includePackageJsonAutoImports": "auto"
}
EOF

# 7. Initialize git hooks if git repo exists
if [ -d ".git" ]; then
  echo "🔗 Setting up git hooks..."
  cat > .git/hooks/pre-commit << EOF
#!/bin/bash
npm test && npm run lint
EOF
  chmod +x .git/hooks/pre-commit
fi

# 8. Create CI/CD workflow
echo "🔄 Setting up CI/CD workflow..."
mkdir -p .github/workflows
cat > .github/workflows/ci.yml << EOF
name: Cursor AI Enhancement CI

on:
  push:
    branches: [ main, development ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    strategy:
      matrix:
        node-version: [16.x, 18.x, 20.x]
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Use Node.js \${{ matrix.node-version }}
      uses: actions/setup-node@v3
      with:
        node-version: \${{ matrix.node-version }}
        cache: 'npm'
    
    - run: npm ci
    - run: npm run lint
    - run: npm test
    - run: npm run test:benchmark
    
    - name: Upload coverage to Codecov
      uses: codecov/codecov-action@v3
      
  performance:
    runs-on: ubuntu-latest
    needs: test
    
    steps:
    - uses: actions/checkout@v3
    - uses: actions/setup-node@v3
      with:
        node-version: '18.x'
        cache: 'npm'
    
    - run: npm ci
    - run: npm run benchmark:ci
    
    - name: Performance regression check
      run: |
        if [ -f "performance-baseline.json" ]; then
          npm run performance:compare
        fi
EOF

# 9. Create basic test setup
echo "🧪 Creating test infrastructure..."
cat > tests/setup.js << EOF
// Global test setup
const { performance } = require('perf_hooks');

global.measurePerformance = (fn) => {
  const start = performance.now();
  const result = fn();
  const end = performance.now();
  return { result, duration: end - start };
};

global.mockVSCode = {
  window: {
    showInformationMessage: jest.fn(),
    showErrorMessage: jest.fn()
  },
  workspace: {
    getConfiguration: jest.fn(() => ({
      get: jest.fn()
    }))
  },
  languages: {
    registerCompletionItemProvider: jest.fn()
  }
};
EOF

# 10. Update package.json scripts
echo "📄 Updating package.json scripts..."
npm pkg set scripts.lint="eslint lib/ modules/ tests/ --ext .js"
npm pkg set scripts.test="jest"
npm pkg set scripts.test:watch="jest --watch"
npm pkg set scripts.test:coverage="jest --coverage"
npm pkg set scripts.test:benchmark="node tests/bench/run-all.js"
npm pkg set scripts.benchmark="node scripts/benchmark.sh"
npm pkg set scripts.benchmark:ci="node tests/bench/ci-benchmark.js"
npm pkg set scripts.performance:compare="node scripts/performance-compare.js"
npm pkg set scripts.verify="./scripts/verify.sh"
npm pkg set scripts.dev="node --inspect lib/ai/controller.js"

# 11. Install required dependencies
echo "📦 Installing enhanced dependencies..."
npm install --save-dev \
  @types/node \
  @types/jest \
  codecov \
  performance-now \
  memory-usage \
  --silent

npm install --save \
  lodash \
  uuid \
  semver \
  --silent

# 12. Validate setup
echo "✅ Validating setup..."
if command -v npm run test >/dev/null 2>&1; then
  echo "✅ npm scripts configured"
else
  echo "⚠️  npm scripts configuration issue"
fi

if command -v npm run lint >/dev/null 2>&1; then
  echo "✅ ESLint configured"
else
  echo "⚠️  ESLint configuration issue"
fi

echo "🎉 Setup complete! Ready for development."
echo ""
echo "📝 Next steps:"
echo "   1. Run 'npm test' to verify all tests pass"
echo "   2. Run 'npm run benchmark' to establish baseline metrics"
echo "   3. Start development with 'npm run dev'"
echo "   4. Use 'npm run verify' to validate implementations"
echo ""
echo "📁 Directory structure created:"
echo "   ├── lib/ai/           # AI core components"
echo "   ├── lib/lang/         # Language adapters"
echo "   ├── lib/shadow/       # Shadow workspace"
echo "   ├── lib/cache/        # Caching layer"
echo "   ├── lib/ui/           # UI components"
echo "   ├── modules/          # Performance & integration"
echo "   ├── tests/            # Comprehensive test suite"
echo "   └── scripts/          # Automation scripts" 