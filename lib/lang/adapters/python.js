/**
 * Python Language Adapter
 * Provides advanced Python development support with Pylance LSP and venv detection
 * Target: <100ms context extraction, full Pylance integration, PEP8 compliance
 */

const BaseLanguageAdapter = require('./base');
const fs = require('fs').promises;
const path = require('path');
const { spawn } = require('child_process');

class PythonAdapter extends BaseLanguageAdapter {
    constructor(options = {}) {
        super('python', {
            enablePylance: true,
            enableFlake8: true,
            enableBlack: true,
            enableMypy: true,
            autoVenvDetection: true,
            pep8Compliance: true,
            detectFrameworks: true,
            ...options
        });

        this.pylanceClient = null;
        this.flake8Client = null;
        this.blackConfig = null;
        this.mypyClient = null;
        this.virtualEnv = null;
        this.packageInfo = null;

        this.supportedExtensions = ['.py', '.pyw', '.pyi'];
        this.frameworkPatterns = {
            django: ['Django', 'django'],
            flask: ['Flask', 'flask'],
            fastapi: ['FastAPI', 'fastapi'],
            streamlit: ['streamlit'],
            pytorch: ['torch', 'pytorch'],
            tensorflow: ['tensorflow', 'tf'],
            pandas: ['pandas'],
            numpy: ['numpy'],
            scikit: ['scikit-learn', 'sklearn']
        };

        this.builtinModules = [
            'os', 'sys', 'json', 'datetime', 'collections', 'itertools',
            'functools', 'operator', 're', 'math', 'random', 'urllib',
            'http', 'pathlib', 'typing', 'asyncio', 'threading', 'multiprocessing'
        ];
    }

    /**
     * Execute Python process (utility for actual Python operations)
     */
    async executePython(command, args = [], options = {}) {
        return new Promise((resolve, reject) => {
            const pythonPath = this.virtualEnv?.pythonPath || 'python';
            const child = spawn(pythonPath, ['-c', command, ...args], {
                stdio: 'pipe',
                cwd: options.cwd || process.cwd(),
                ...options
            });

            let stdout = '';
            let stderr = '';

            child.stdout.on('data', (data) => {
                stdout += data.toString();
            });

            child.stderr.on('data', (data) => {
                stderr += data.toString();
            });

            child.on('close', (code) => {
                if (code === 0) {
                    resolve({ stdout: stdout.trim(), stderr: stderr.trim() });
                } else {
                    reject(new Error(`Python execution failed: ${stderr || stdout}`));
                }
            });

            child.on('error', reject);
        });
    }

    /**
     * Setup Language Server Protocol client (Pylance)
     */
    async setupLSP() {
        try {
            if (!this.config.enablePylance) return;

            // Pylance LSP setup not yet implemented
            this.pylanceClient = null;

            // Detect and activate virtual environment
            if (this.config.autoVenvDetection) {
                await this.detectVirtualEnvironment();
            }

        } catch (error) {
            console.warn(`Python LSP setup failed: ${error.message}`);
        }
    }

    /**
     * Setup syntax parser (AST-based)
     */
    async setupSyntaxParser() {
        try {
            // Mock Python AST parser setup
            this.syntaxParser = {
                type: 'ast',
                version: '3.11',
                features: ['type_hints', 'f_strings', 'walrus_operator', 'match_case']
            };

        } catch (error) {
            console.warn(`Python parser setup failed: ${error.message}`);
        }
    }

    /**
     * Setup Flake8 linter
     */
    async setupLinter() {
        try {
            if (!this.config.enableFlake8) return;

            // Mock Flake8 setup
            this.flake8Client = {
                connected: true,
                configFile: '.flake8',
                rules: {
                    'E501': 'line too long',
                    'E302': 'expected 2 blank lines',
                    'E303': 'too many blank lines',
                    'F401': 'imported but unused',
                    'F841': 'local variable assigned but never used'
                }
            };

            // Setup MyPy for type checking
            if (this.config.enableMypy) {
                this.mypyClient = {
                    connected: true,
                    configFile: 'mypy.ini',
                    strictMode: false
                };
            }

        } catch (error) {
            console.warn(`Python linter setup failed: ${error.message}`);
        }
    }

    /**
     * Setup Black formatter
     */
    async setupFormatter() {
        try {
            if (!this.config.enableBlack) return;

            // Mock Black setup
            this.blackConfig = {
                lineLength: 88,
                targetVersion: ['py38', 'py39', 'py310', 'py311'],
                skipStringNormalization: false,
                skipMagicTrailing: false
            };

        } catch (error) {
            console.warn(`Python formatter setup failed: ${error.message}`);
        }
    }

    /**
     * Detect virtual environment
     */
    async detectVirtualEnvironment() {
        try {
            const venvPaths = [
                'venv',
                '.venv',
                'env',
                '.env',
                'virtualenv',
                '../venv',
                '../.venv'
            ];

            for (const venvPath of venvPaths) {
                try {
                    const activateScript = path.join(venvPath, 'bin', 'activate');
                    await fs.access(activateScript);

                    this.virtualEnv = {
                        path: venvPath,
                        activateScript,
                        pythonPath: path.join(venvPath, 'bin', 'python'),
                        detected: true
                    };

                    break;
                } catch {
                    // Try Windows path
                    try {
                        const activateScript = path.join(venvPath, 'Scripts', 'activate.bat');
                        await fs.access(activateScript);

                        this.virtualEnv = {
                            path: venvPath,
                            activateScript,
                            pythonPath: path.join(venvPath, 'Scripts', 'python.exe'),
                            detected: true
                        };

                        break;
                    } catch {
                        continue;
                    }
                }
            }

        } catch (error) {
            console.warn(`Virtual environment detection failed: ${error.message}`);
        }
    }

    /**
     * Perform context extraction for Python files
     */
    async performContextExtraction(filePath, position, options = {}) {
        try {
            // Read file content
            const content = await fs.readFile(filePath, 'utf8');
            const lines = content.split('\n');

            // Apply options for context customization
            const includeDocstrings = options.includeDocstrings !== false;
            const maxSymbols = options.maxSymbols || this.config.maxSymbols;

            // Extract Python-specific context
            const context = {
                file: filePath,
                position,
                language: 'python',
                surrounding: this.extractSurroundingLines(lines, position.line),
                imports: this.extractImports(content),
                exports: this.extractExports(content),
                symbols: await this.extractSymbols(content, position),
                classes: this.extractClasses(content),
                functions: this.extractFunctions(content),
                framework: await this.detectFramework(filePath),
                virtualEnv: this.virtualEnv,
                syntax: this.analyzeSyntax(content),
                docstrings: includeDocstrings ? this.extractDocstrings(content) : [],
                options: { includeDocstrings, maxSymbols }
            };

            return context;

        } catch (error) {
            console.error(`Python context extraction failed for ${filePath}: ${error.message}`);
            return this.createFallbackContext(filePath, position);
        }
    }

    /**
     * Extract Python imports
     */
    extractImports(content) {
        const imports = [];

        // Standard imports: import module
        const importRegex = /^import\s+([\w\.]+)(?:\s+as\s+(\w+))?/gm;
        let match;

        while ((match = importRegex.exec(content)) !== null) {
            imports.push({
                type: 'import',
                module: match[1],
                alias: match[2] || null,
                statement: match[0],
                line: content.substring(0, match.index).split('\n').length - 1
            });
        }

        // From imports: from module import item
        const fromImportRegex = /^from\s+([\w\.]+)\s+import\s+([\w\s,*]+)/gm;

        while ((match = fromImportRegex.exec(content)) !== null) {
            const items = match[2].split(',').map(item => item.trim());

            imports.push({
                type: 'from_import',
                module: match[1],
                items: items,
                statement: match[0],
                line: content.substring(0, match.index).split('\n').length - 1
            });
        }

        return imports;
    }

    /**
     * Extract Python exports (functions and classes defined at module level)
     */
    extractExports(content) {
        const exports = [];

        // Function definitions at module level
        const functionRegex = /^def\s+(\w+)\s*\([^)]*\):/gm;
        let match;

        while ((match = functionRegex.exec(content)) !== null) {
            exports.push({
                type: 'function',
                name: match[1],
                statement: match[0],
                line: content.substring(0, match.index).split('\n').length - 1
            });
        }

        // Class definitions at module level
        const classRegex = /^class\s+(\w+)(?:\([^)]*\))?:/gm;

        while ((match = classRegex.exec(content)) !== null) {
            exports.push({
                type: 'class',
                name: match[1],
                statement: match[0],
                line: content.substring(0, match.index).split('\n').length - 1
            });
        }

        // Variable assignments at module level
        const varRegex = /^(\w+)\s*=\s*([^#\n]+)/gm;

        while ((match = varRegex.exec(content)) !== null) {
            // Skip if it looks like a private variable
            if (!match[1].startsWith('_')) {
                exports.push({
                    type: 'variable',
                    name: match[1],
                    value: match[2].trim(),
                    statement: match[0],
                    line: content.substring(0, match.index).split('\n').length - 1
                });
            }
        }

        return exports;
    }

    /**
     * Extract Python symbols (functions, classes, methods)
     */
    async extractSymbols(content, position) {
        const symbols = [];

        // Extract all function definitions
        const functionRegex = /(?:^|\n)([ ]*)def\s+(\w+)\s*\(([^)]*)\)(?:\s*->\s*([^:]+))?:/g;
        let match;

        while ((match = functionRegex.exec(content)) !== null) {
            const indentation = match[1].length;
            const name = match[2];
            const params = match[3];
            const returnType = match[4];
            const line = content.substring(0, match.index).split('\n').length - 1;

            // Consider position proximity for relevance
            const proximity = Math.abs(line - position.line);

            symbols.push({
                name,
                kind: 'function',
                line,
                indentation,
                parameters: this.parseParameters(params),
                returnType: returnType?.trim() || null,
                detail: `def ${name}(${params})${returnType ? ` -> ${returnType}` : ''}`,
                scope: this.determineScope(content, match.index),
                isMethod: indentation > 0,
                proximity,
                relevant: proximity < this.config.contextRadius
            });
        }

        // Extract class definitions
        const classRegex = /(?:^|\n)class\s+(\w+)(?:\(([^)]*)\))?:/g;

        while ((match = classRegex.exec(content)) !== null) {
            const name = match[1];
            const bases = match[2];
            const line = content.substring(0, match.index).split('\n').length - 1;

            symbols.push({
                name,
                kind: 'class',
                line,
                bases: bases ? bases.split(',').map(b => b.trim()) : [],
                detail: `class ${name}${bases ? `(${bases})` : ''}`,
                scope: 'module',
                methods: this.extractClassMethods(content, match.index)
            });
        }

        return symbols.slice(0, this.config.maxSymbols);
    }

    /**
     * Extract class definitions
     */
    extractClasses(content) {
        const classes = [];
        const classRegex = /class\s+(\w+)(?:\(([^)]*)\))?:\s*(?:\n\s*"""([^"]*?)""")?/g;
        let match;

        while ((match = classRegex.exec(content)) !== null) {
            const line = content.substring(0, match.index).split('\n').length - 1;

            classes.push({
                name: match[1],
                bases: match[2] ? match[2].split(',').map(b => b.trim()) : [],
                docstring: match[3] || null,
                line,
                methods: this.extractClassMethods(content, match.index)
            });
        }

        return classes;
    }

    /**
     * Extract function definitions
     */
    extractFunctions(content) {
        const functions = [];
        const functionRegex = /def\s+(\w+)\s*\(([^)]*)\)(?:\s*->\s*([^:]+))?:\s*(?:\n\s*"""([^"]*?)""")?/g;
        let match;

        while ((match = functionRegex.exec(content)) !== null) {
            const line = content.substring(0, match.index).split('\n').length - 1;

            functions.push({
                name: match[1],
                parameters: this.parseParameters(match[2]),
                returnType: match[3]?.trim() || null,
                docstring: match[4] || null,
                line,
                isAsync: content.substring(Math.max(0, match.index - 10), match.index).includes('async')
            });
        }

        return functions;
    }

    /**
     * Extract class methods
     */
    extractClassMethods(content, classStartIndex) {
        const methods = [];
        const classContent = content.substring(classStartIndex);
        const nextClassMatch = classContent.substring(1).search(/^class\s+/m);
        const classEnd = nextClassMatch === -1 ? classContent.length : nextClassMatch + 1;
        const classBlock = classContent.substring(0, classEnd);

        const methodRegex = /    def\s+(\w+)\s*\(([^)]*)\)(?:\s*->\s*([^:]+))?:/g;
        let match;

        while ((match = methodRegex.exec(classBlock)) !== null) {
            methods.push({
                name: match[1],
                parameters: this.parseParameters(match[2]),
                returnType: match[3]?.trim() || null,
                isPrivate: match[1].startsWith('_'),
                isSpecial: match[1].startsWith('__') && match[1].endsWith('__')
            });
        }

        return methods;
    }

    /**
     * Parse function parameters
     */
    parseParameters(paramString) {
        if (!paramString.trim()) return [];

        const params = [];
        const paramParts = paramString.split(',');

        for (const part of paramParts) {
            const trimmed = part.trim();
            if (!trimmed) continue;

            const param = { name: '', type: null, default: null };

            // Check for default value
            if (trimmed.includes('=')) {
                const [nameType, defaultValue] = trimmed.split('=', 2);
                param.default = defaultValue.trim();
                param.name = nameType.trim();
            } else {
                param.name = trimmed;
            }

            // Check for type annotation
            if (param.name.includes(':')) {
                const [name, type] = param.name.split(':', 2);
                param.name = name.trim();
                param.type = type.trim();
            }

            params.push(param);
        }

        return params;
    }

    /**
     * Extract docstrings
     */
    extractDocstrings(content) {
        const docstrings = [];
        const docstringRegex = /"""([^"]*?)"""/g;
        let match;

        while ((match = docstringRegex.exec(content)) !== null) {
            const line = content.substring(0, match.index).split('\n').length - 1;

            docstrings.push({
                content: match[1].trim(),
                line,
                type: this.analyzeDocstringType(match[1])
            });
        }

        return docstrings;
    }

    /**
     * Analyze docstring type (Google, NumPy, Sphinx)
     */
    analyzeDocstringType(docstring) {
        if (docstring.includes('Args:') || docstring.includes('Returns:')) {
            return 'google';
        }

        if (docstring.includes('Parameters') || docstring.includes('--------')) {
            return 'numpy';
        }

        if (docstring.includes(':param') || docstring.includes(':return')) {
            return 'sphinx';
        }

        return 'plain';
    }

    /**
     * Detect Python framework
     */
    async detectFramework(filePath) {
        if (!this.config.detectFrameworks) return null;

        try {
            const requirementsPath = await this.findRequirementsFile(filePath);
            if (!requirementsPath) return null;

            const requirementsContent = await fs.readFile(requirementsPath, 'utf8');
            const packages = requirementsContent.split('\n')
                .map(line => line.trim().split(/[>=<]/)[0])
                .filter(pkg => pkg.length > 0);

            for (const [framework, patterns] of Object.entries(this.frameworkPatterns)) {
                if (patterns.some(pattern => packages.includes(pattern))) {
                    return {
                        name: framework,
                        packages: patterns.filter(p => packages.includes(p)),
                        requirementsFile: requirementsPath
                    };
                }
            }

            return null;

        } catch (error) {
            console.error(`Framework detection failed for ${filePath}: ${error.message}`);
            return null;
        }
    }

    /**
     * Find requirements file
     */
    async findRequirementsFile(filePath) {
        const candidates = [
            'requirements.txt',
            'requirements.dev.txt',
            'requirements-dev.txt',
            'pyproject.toml',
            'setup.py',
            'Pipfile'
        ];

        let currentDir = path.dirname(filePath);

        while (currentDir !== path.dirname(currentDir)) {
            for (const candidate of candidates) {
                const candidatePath = path.join(currentDir, candidate);

                try {
                    await fs.access(candidatePath);
                    return candidatePath;
                } catch {
                    continue;
                }
            }

            currentDir = path.dirname(currentDir);
        }

        return null;
    }

    /**
     * Analyze Python syntax features
     */
    analyzeSyntax(content) {
        const features = {
            python3: false,
            typeHints: false,
            fStrings: false,
            asyncAwait: false,
            dataclasses: false,
            walrusOperator: false,
            matchCase: false
        };

        // Type hints
        if (content.includes(': ') && (content.includes('def ') || content.includes('class '))) {
            features.typeHints = true;
        }

        // F-strings
        if (content.includes('f"') || content.includes('f\'')) {
            features.fStrings = true;
        }

        // Async/await
        if (content.includes('async ') || content.includes('await ')) {
            features.asyncAwait = true;
        }

        // Dataclasses
        if (content.includes('@dataclass')) {
            features.dataclasses = true;
        }

        // Walrus operator (Python 3.8+)
        if (content.includes(':=')) {
            features.walrusOperator = true;
        }

        // Match case (Python 3.10+)
        if (content.includes('match ') && content.includes('case ')) {
            features.matchCase = true;
        }

        // Python 3 indicators
        if (content.includes('print(') || features.typeHints || features.fStrings) {
            features.python3 = true;
        }

        return features;
    }

    /**
     * Perform Flake8 and MyPy linting
     */
    async performLinting(filePath, content) {
        if (!this.flake8Client && !this.mypyClient) return [];

        try {
            const diagnostics = [];

            // Mock Flake8 linting
            if (this.flake8Client) {
                // Check line length
                const lines = content.split('\n');
                lines.forEach((line, index) => {
                    if (line.length > 88) {
                        diagnostics.push({
                            range: { start: { line: index, character: 88 }, end: { line: index, character: line.length } },
                            severity: 'warning',
                            message: 'Line too long (>88 characters)',
                            source: 'flake8',
                            code: 'E501'
                        });
                    }
                });

                // Check for unused imports (simplified)
                const importRegex = /^(?:import|from)\s+([\w\.]+)/gm;
                let match;
                const imports = new Set();

                while ((match = importRegex.exec(content)) !== null) {
                    imports.add(match[1]);
                }

                // Check for unused variables (simplified)
                const variableRegex = /^(\w+)\s*=/gm;
                const usedVars = new Set();
                let varMatch;

                // Extract variable assignments
                while ((varMatch = variableRegex.exec(content)) !== null) {
                    usedVars.add(varMatch[1]);
                }

                // This is a simplified check - in real implementation would use AST
                for (const varName of usedVars) {
                    const usageRegex = new RegExp(`\\b${varName}\\b`, 'g');
                    const matches = content.match(usageRegex);

                    if (matches && matches.length === 1) {
                        diagnostics.push({
                            range: { start: { line: 0, character: 0 }, end: { line: 0, character: varName.length } },
                            severity: 'warning',
                            message: `'${varName}' is assigned but never used`,
                            source: 'flake8',
                            code: 'F841'
                        });
                    }
                }
            }

            return diagnostics;

        } catch (error) {
            console.error(`Python linting failed for ${filePath}: ${error.message}`);
            return [];
        }
    }

    /**
     * Perform Black formatting
     */
    async performFormatting(content, options = {}) {
        if (!this.blackConfig) return content;

        try {
            // Black formatting not yet implemented
            console.debug(`Black formatting not implemented`);
            return content;

        } catch (error) {
            console.error(`Python formatting failed: ${error.message}`);
            return content;
        }
    }

    /**
     * Validate Python syntax using AST
     */
    async validateSyntax(content) {
        try {
            // Python AST validation not yet implemented
            const errors = [];

            // Check for basic indentation errors
            const lines = content.split('\n');
            let expectedIndent = 0;

            for (let i = 0; i < lines.length; i++) {
                const line = lines[i];
                if (line.trim() === '') continue;

                const actualIndent = line.length - line.trimStart().length;

                // Simple indentation check
                if (line.trim().endsWith(':')) {
                    expectedIndent = actualIndent + 4;
                } else if (actualIndent < expectedIndent && line.trim() !== '') {
                    // Reset expected indent for dedent
                    expectedIndent = actualIndent;
                }

                // Check for syntax patterns
                if (line.includes('print ') && !line.includes('print(')) {
                    errors.push({
                        range: { start: { line: i, character: 0 }, end: { line: i, character: line.length } },
                        severity: 'error',
                        message: 'print is a function in Python 3',
                        source: 'python-syntax'
                    });
                }
            }

            return errors;

        } catch (error) {
            console.error(`Python syntax validation failed: ${error.message}`);
            return [{
                range: { start: { line: 0, character: 0 }, end: { line: 0, character: 1 } },
                severity: 'error',
                message: 'Syntax validation failed',
                source: 'python-syntax'
            }];
        }
    }

    /**
     * Perform symbol resolution
     */
    async performSymbolResolution(filePath, symbol, position) {
        try {
            const content = await fs.readFile(filePath, 'utf8');

            // Look for function definition
            const functionRegex = new RegExp(`def\\s+${symbol}\\s*\\([^)]*\\):`, 'g');
            const match = functionRegex.exec(content);

            if (match) {
                const line = content.substring(0, match.index).split('\n').length - 1;
                const proximity = Math.abs(line - position.line);

                return {
                    name: symbol,
                    kind: 'function',
                    range: {
                        start: { line, character: match.index },
                        end: { line, character: match.index + match[0].length }
                    },
                    detail: this.extractFunctionDocstring(content, match.index),
                    documentation: this.extractFunctionDocstring(content, match.index),
                    proximity,
                    relevant: proximity < this.config.contextRadius
                };
            }

            // Look for class definition
            const classRegex = new RegExp(`class\\s+${symbol}`, 'g');
            const classMatch = classRegex.exec(content);

            if (classMatch) {
                const line = content.substring(0, classMatch.index).split('\n').length - 1;

                return {
                    name: symbol,
                    kind: 'class',
                    range: {
                        start: { line, character: classMatch.index },
                        end: { line, character: classMatch.index + classMatch[0].length }
                    },
                    detail: `class ${symbol}`,
                    documentation: this.extractClassDocstring(content, classMatch.index)
                };
            }

            return null;

        } catch (error) {
            console.error(`Python symbol resolution failed for ${symbol} in ${filePath}: ${error.message}`);
            return null;
        }
    }

    /**
     * Perform custom completion suggestions
     */
    async performCustomCompletions(filePath, position, triggerCharacter) {
        const suggestions = [];

        try {
            const content = await fs.readFile(filePath, 'utf8');
            const framework = await this.detectFramework(filePath);

            // Log trigger character for debugging
            if (triggerCharacter) {
                console.debug(`Python completions triggered by '${triggerCharacter}' at ${JSON.stringify(position)} in ${filePath}`);
            }

            // Framework-specific completions
            if (framework?.name === 'django') {
                suggestions.push(...this.getDjangoCompletions(content, position));
            }

            if (framework?.name === 'flask') {
                suggestions.push(...this.getFlaskCompletions(content, position));
            }

            // Python built-in completions
            suggestions.push(...this.getPythonBuiltinCompletions(content, position));

            return suggestions;

        } catch (error) {
            console.error(`Python custom completions failed for ${filePath}: ${error.message}`);
            return [];
        }
    }

    // Helper methods

    /**
     * Extract surrounding lines around position
     */
    extractSurroundingLines(lines, lineNumber) {
        const start = Math.max(0, lineNumber - this.config.contextRadius);
        const end = Math.min(lines.length, lineNumber + this.config.contextRadius + 1);

        const surrounding = [];
        for (let i = start; i < end; i++) {
            surrounding.push({
                line: i,
                content: lines[i] || '',
                isCurrent: i === lineNumber,
                indentation: (lines[i] || '').length - (lines[i] || '').trimStart().length
            });
        }

        return surrounding;
    }

    /**
     * Determine scope of symbol
     */
    determineScope(content, index) {
        const beforeContent = content.substring(0, index);
        const lines = beforeContent.split('\n');

        for (let i = lines.length - 1; i >= 0; i--) {
            const line = lines[i].trim();

            if (line.startsWith('class ')) {
                return 'class';
            }

            if (line.startsWith('def ')) {
                return 'function';
            }
        }

        return 'module';
    }

    /**
     * Extract function docstring
     */
    extractFunctionDocstring(content, startIndex) {
        const afterFunction = content.substring(startIndex);
        const docstringMatch = afterFunction.match(/:\s*\n\s*"""([^"]*?)"""/);

        if (docstringMatch) {
            return docstringMatch[1].trim();
        }

        return 'No documentation available';
    }

    /**
     * Extract class docstring
     */
    extractClassDocstring(content, startIndex) {
        const afterClass = content.substring(startIndex);
        const docstringMatch = afterClass.match(/:\s*\n\s*"""([^"]*?)"""/);

        if (docstringMatch) {
            return docstringMatch[1].trim();
        }

        return 'No documentation available';
    }

    /**
     * Get Django-specific completions
     */
    getDjangoCompletions(content, position) {
        const suggestions = [];

        // Log position context for debugging
        console.debug(`Django completions requested at line ${position.line}, character ${position.character}`);

        // Django model fields
        const fields = ['CharField', 'IntegerField', 'DateTimeField', 'BooleanField', 'TextField'];
        for (const field of fields) {
            suggestions.push({
                label: field,
                kind: 'class',
                detail: `Django model field: ${field}`,
                insertText: field,
                documentation: `Django ${field} model field`
            });
        }

        return suggestions;
    }

    /**
     * Get Flask-specific completions
     */
    getFlaskCompletions(content, position) {
        const suggestions = [];

        // Log position context for debugging
        console.debug(`Flask completions requested for content length ${content.length} at position ${JSON.stringify(position)}`);

        // Flask decorators
        const decorators = ['@app.route', '@app.before_request', '@app.after_request'];
        for (const decorator of decorators) {
            suggestions.push({
                label: decorator,
                kind: 'snippet',
                detail: `Flask decorator: ${decorator}`,
                insertText: decorator,
                documentation: `Flask ${decorator} decorator`
            });
        }

        return suggestions;
    }

    /**
     * Get Python built-in completions
     */
    getPythonBuiltinCompletions(content, position) {
        const suggestions = [];

        // Log completion context for debugging
        console.debug(`Python builtin completions for content length ${content.length} at position ${JSON.stringify(position)}`);

        // Python built-in functions
        const builtins = ['len', 'str', 'int', 'float', 'list', 'dict', 'set', 'tuple'];
        for (const builtin of builtins) {
            suggestions.push({
                label: builtin,
                kind: 'function',
                detail: `Python built-in: ${builtin}`,
                insertText: builtin,
                documentation: `Python built-in ${builtin} function`
            });
        }

        return suggestions;
    }
}

module.exports = PythonAdapter; 