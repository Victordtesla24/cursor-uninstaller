const fs = require('fs');
const path = require('path');

const packagePath = path.join(process.cwd(), 'package.json');
const packageJson = JSON.parse(fs.readFileSync(packagePath, 'utf8'));

// Add revolutionary scripts
packageJson.scripts = {
    ...packageJson.scripts,
    "revolutionary:setup": "bash scripts/revolutionary-setup.sh",
    "revolutionary:start": "NODE_ENV=revolutionary npm run dev",
    "revolutionary:test": "jest --config jest.config.revolutionary.js",
    "revolutionary:test:watch": "npm run revolutionary:test -- --watch",
    "revolutionary:benchmark": "node tests/bench/revolutionary-benchmark.js",
    "revolutionary:optimize": "node scripts/revolutionary-optimizer.js",
    "revolutionary:build": "NODE_ENV=production npm run build",
    "revolutionary:validate": "npm run lint && npm run revolutionary:test && npm run revolutionary:benchmark",
    "lint": "eslint lib modules tests --ext .ts,.js --fix",
    "lint:check": "eslint lib modules tests --ext .ts,.js",
    "test:revolutionary": "npm run revolutionary:test",
    "build:revolutionary": "npm run revolutionary:build",
    "dev": "nodemon --exec 'node --experimental-modules' --ext js,ts,json",
    "performance:monitor": "clinic doctor -- node tests/bench/performance-monitor.js",
    "cache:clear": "rm -rf .cache/revolutionary/* && echo 'Revolutionary cache cleared'",
    "setup:complete": "npm run revolutionary:setup && npm run revolutionary:validate"
};

fs.writeFileSync(packagePath, JSON.stringify(packageJson, null, 2));
console.log('✅ Package.json updated with revolutionary scripts');
