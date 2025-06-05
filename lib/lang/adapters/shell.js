/**
 * Shell/Bash Language Adapter - Shell script support with safety validation
 * Implements ShellCheck integration and dangerous command detection
 * Target: <50ms initialization, safety-first approach with validation
 */

const BaseLanguageAdapter = require('./base');
const fs = require('fs').promises;
const path = require('path');
const { spawn } = require('child_process');

class ShellAdapter extends BaseLanguageAdapter {
    constructor(options = {}) {
        super('shell', options);

        this.config = {
            ...this.config,
            enableShellCheck: options.enableShellCheck !== false,
            enableSafetyChecks: options.enableSafetyChecks !== false,
            allowDangerousCommands: options.allowDangerousCommands || false,
            shellCheckPath: options.shellCheckPath || 'shellcheck',
            defaultShell: options.defaultShell || 'bash',
            strictMode: options.strictMode !== false,
            maxLineLength: options.maxLineLength || 120
        };

        // Safety validation patterns
        this.dangerousPatterns = new Map([
            ['rm_recursive', /rm\s+(-[rf]*|--recursive|--force)/],
            ['dd_operations', /dd\s+if=/],
            ['format_operations', /mkfs\./],
            ['sudo_operations', /sudo\s+/],
            ['curl_pipe', /curl.*\|\s*(bash|sh)/],
            ['wget_pipe', /wget.*\|\s*(bash|sh)/],
            ['eval_dynamic', /eval\s+\$\(/],
            ['history_clear', /history\s+-c/],
            ['user_management', /(userdel|usermod|passwd)/],
            ['network_config', /(iptables|ufw|firewall)/],
            ['system_config', /(mount|umount|fdisk)/]
        ]);

        // Shell built-ins and safe commands
        this.builtinCommands = new Set([
            'echo', 'printf', 'read', 'test', '[', '[[', 'cd', 'pwd', 'pushd', 'popd',
            'set', 'unset', 'export', 'declare', 'local', 'readonly', 'shift',
            'getopts', 'source', '.', 'type', 'which', 'help', 'true', 'false',
            'exit', 'return', 'break', 'continue', 'wait', 'jobs', 'bg', 'fg',
            'alias', 'unalias', 'history', 'fc', 'ulimit', 'umask'
        ]);

        // Common safe external commands
        this.safeCommands = new Set([
            'ls', 'cat', 'less', 'more', 'head', 'tail', 'grep', 'sed', 'awk',
            'cut', 'sort', 'uniq', 'wc', 'tr', 'find', 'xargs', 'basename',
            'dirname', 'date', 'whoami', 'id', 'uname', 'hostname', 'uptime',
            'ps', 'top', 'df', 'du', 'free', 'lscpu', 'lsblk', 'lsof',
            'git', 'npm', 'node', 'python', 'pip', 'make', 'cmake'
        ]);

        this.shellCheckClient = null;
    }

    /**
     * Setup Language Server Protocol (ShellCheck)
     */
    async setupLSP() {
        if (!this.config.enableShellCheck) {
            console.log('📝 ShellCheck LSP disabled');
            return;
        }

        try {
            // Check if shellcheck is available
            const available = await this.checkShellCheckAvailability();
            if (available) {
                this.lspClient = {
                    available: true,
                    version: await this.getShellCheckVersion()
                };
                console.log(`✅ ShellCheck LSP available: ${this.lspClient.version}`);
            } else {
                console.log('⚠️  ShellCheck not found, syntax checking limited');
            }
        } catch (error) {
            console.warn('Failed to setup ShellCheck LSP:', error.message);
        }
    }

    /**
     * Setup syntax parser for shell scripts
     */
    async setupSyntaxParser() {
        this.syntaxParser = {
            parseShebang: (content) => this.parseShebang(content),
            extractFunctions: (content) => this.extractFunctions(content),
            extractVariables: (content) => this.extractVariables(content),
            findIncludes: (content) => this.findIncludes(content),
            analyzeControlFlow: (content) => this.analyzeControlFlow(content)
        };
        console.log('✅ Shell syntax parser initialized');
    }

    /**
     * Setup shell script linter (ShellCheck integration)
     */
    async setupLinter() {
        if (this.config.enableShellCheck && this.lspClient?.available) {
            console.log('✅ ShellCheck linter configured');
        } else {
            console.log('📝 Using basic shell validation');
        }
    }

    /**
     * Setup code formatter (shfmt-style)
     */
    async setupFormatter() {
        this.formatter = {
            indentSize: 2,
            useTabs: false,
            maxLineLength: this.config.maxLineLength,
            spaceRedirects: true
        };
        console.log('✅ Shell formatter configured');
    }

    /**
     * Extract context for shell scripts
     */
    async performContextExtraction(filePath, position, options = {}) {
        try {
            const content = await fs.readFile(filePath, 'utf8');
            const lines = content.split('\n');
            const currentLine = position.line || 0;

            const context = {
                file: filePath,
                position,
                language: 'shell',
                shebang: this.parseShebang(content),
                functions: this.extractFunctions(content),
                variables: this.extractVariables(content),
                includes: this.findIncludes(content),
                surrounding: this.extractSurroundingLines(lines, currentLine),
                safetyAnalysis: await this.analyzeSafety(content),
                controlFlow: this.analyzeControlFlow(content),
                tokens: this.tokenizeShellScript(content)
            };

            return context;

        } catch (error) {
            throw new Error(`Context extraction failed: ${error.message}`);
        }
    }

    /**
     * Perform shell script linting with ShellCheck
     */
    async performLinting(filePath, content) {
        const diagnostics = [];

        try {
            // Safety checks first
            if (this.config.enableSafetyChecks) {
                const safetyIssues = await this.performSafetyChecks(content);
                diagnostics.push(...safetyIssues);
            }

            // ShellCheck integration
            if (this.config.enableShellCheck && this.lspClient?.available) {
                const shellCheckResults = await this.runShellCheck(content, filePath);
                diagnostics.push(...shellCheckResults);
            }

            // Basic syntax validation
            const syntaxIssues = await this.validateShellSyntax(content);
            diagnostics.push(...syntaxIssues);

            return diagnostics;

        } catch (error) {
            return [{
                range: { start: { line: 0, character: 0 }, end: { line: 0, character: 0 } },
                severity: 'error',
                message: `Linting failed: ${error.message}`,
                source: 'shell-adapter'
            }];
        }
    }

    /**
     * Format shell script code
     */
    async performFormatting(content, options = {}) {
        try {
            const lines = content.split('\n');
            const formatted = [];
            let indentLevel = 0;
            const indentStr = this.formatter.useTabs ? '\t' : ' '.repeat(this.formatter.indentSize);

            for (let i = 0; i < lines.length; i++) {
                const line = lines[i].trim();

                // Skip empty lines and comments
                if (!line || line.startsWith('#')) {
                    formatted.push(line);
                    continue;
                }

                // Adjust indent level
                const newIndentLevel = this.calculateIndentLevel(line, indentLevel);

                // Format the line
                const formattedLine = indentStr.repeat(Math.max(0, newIndentLevel)) + line;

                // Check line length
                if (formattedLine.length > this.formatter.maxLineLength) {
                    // Consider line splitting for long lines
                    formatted.push(this.handleLongLine(formattedLine, newIndentLevel));
                } else {
                    formatted.push(formattedLine);
                }

                indentLevel = newIndentLevel;
            }

            return formatted.join('\n');

        } catch (error) {
            console.warn('Shell formatting failed:', error.message);
            return content;
        }
    }

    /**
     * Validate shell syntax
     */
    async validateSyntax(content) {
        const errors = [];

        try {
            // Check for basic syntax issues
            const lines = content.split('\n');

            for (let i = 0; i < lines.length; i++) {
                const line = lines[i].trim();
                if (!line || line.startsWith('#')) continue;

                // Check for common syntax errors
                const syntaxErrors = this.checkLineSyntax(line, i);
                errors.push(...syntaxErrors);
            }

            // Check for unbalanced quotes and brackets
            const balanceErrors = this.checkBalance(content);
            errors.push(...balanceErrors);

        } catch (error) {
            errors.push(`Syntax validation error: ${error.message}`);
        }

        return errors;
    }

    /**
     * Perform symbol resolution for shell scripts
     */
    async performSymbolResolution(filePath, symbol, position) {
        try {
            const content = await fs.readFile(filePath, 'utf8');

            // Check if symbol is a function
            const functions = this.extractFunctions(content);
            const functionMatch = functions.find(f => f.name === symbol);
            if (functionMatch) {
                return {
                    name: symbol,
                    kind: 'function',
                    definition: functionMatch.definition,
                    range: functionMatch.range,
                    documentation: functionMatch.documentation || ''
                };
            }

            // Check if symbol is a variable
            const variables = this.extractVariables(content);
            const variableMatch = variables.find(v => v.name === symbol);
            if (variableMatch) {
                return {
                    name: symbol,
                    kind: 'variable',
                    definition: variableMatch.definition,
                    range: variableMatch.range,
                    scope: variableMatch.scope
                };
            }

            // Check if symbol is a command
            if (this.builtinCommands.has(symbol) || this.safeCommands.has(symbol)) {
                return {
                    name: symbol,
                    kind: 'command',
                    definition: `Built-in or external command: ${symbol}`,
                    documentation: this.getCommandDocumentation(symbol)
                };
            }

            return null;

        } catch (error) {
            console.warn('Symbol resolution failed:', error.message);
            return null;
        }
    }

    /**
     * Provide shell-specific completions
     */
    async performCustomCompletions(filePath, position, triggerCharacter) {
        try {
            const completions = [];

            // Variable completions
            if (triggerCharacter === '$') {
                completions.push(...this.getVariableCompletions());
            }

            // Command completions
            if (triggerCharacter === ' ' || !triggerCharacter) {
                completions.push(...this.getCommandCompletions());
            }

            // Option completions
            if (triggerCharacter === '-') {
                completions.push(...this.getOptionCompletions());
            }

            return completions;

        } catch (error) {
            console.warn('Shell completions failed:', error.message);
            return [];
        }
    }

    // Shell-specific helper methods

    /**
     * Parse shebang line
     */
    parseShebang(content) {
        const firstLine = content.split('\n')[0];
        if (firstLine.startsWith('#!')) {
            const interpreter = firstLine.substring(2).trim();
            return {
                interpreter,
                shell: this.detectShellType(interpreter)
            };
        }
        return { interpreter: '', shell: this.config.defaultShell };
    }

    /**
     * Extract shell functions
     */
    extractFunctions(content) {
        const functions = [];
        const functionPattern = /^(\w+)\s*\(\s*\)\s*\{/gm;
        let match;

        while ((match = functionPattern.exec(content)) !== null) {
            const name = match[1];
            const startIndex = match.index;
            const line = content.substring(0, startIndex).split('\n').length - 1;

            functions.push({
                name,
                range: { start: { line, character: 0 }, end: { line, character: match[0].length } },
                definition: match[0],
                documentation: this.extractFunctionDocumentation(content, startIndex)
            });
        }

        return functions;
    }

    /**
     * Extract shell variables
     */
    extractVariables(content) {
        const variables = [];
        const variablePattern = /^(\w+)=/gm;
        let match;

        while ((match = variablePattern.exec(content)) !== null) {
            const name = match[1];
            const startIndex = match.index;
            const line = content.substring(0, startIndex).split('\n').length - 1;

            variables.push({
                name,
                range: { start: { line, character: 0 }, end: { line, character: match[0].length } },
                definition: match[0],
                scope: 'global' // Could be enhanced to detect local scope
            });
        }

        return variables;
    }

    /**
     * Find include statements (source, .)
     */
    findIncludes(content) {
        const includes = [];
        const includePattern = /^(source|\.|\.\.)\s+([^\s]+)/gm;
        let match;

        while ((match = includePattern.exec(content)) !== null) {
            const command = match[1];
            const filePath = match[2];
            const line = content.substring(0, match.index).split('\n').length - 1;

            includes.push({
                command,
                path: filePath,
                line,
                statement: match[0]
            });
        }

        return includes;
    }

    /**
     * Analyze safety of shell script
     */
    async analyzeSafety(content) {
        const safetyIssues = [];
        const lines = content.split('\n');

        for (let i = 0; i < lines.length; i++) {
            const line = lines[i].trim();
            if (!line || line.startsWith('#')) continue;

            // Check against dangerous patterns
            for (const [category, pattern] of this.dangerousPatterns.entries()) {
                if (pattern.test(line)) {
                    safetyIssues.push({
                        category,
                        line: i,
                        content: line,
                        severity: this.config.allowDangerousCommands ? 'warning' : 'error',
                        message: `Potentially dangerous operation: ${category}`
                    });
                }
            }
        }

        return {
            safe: safetyIssues.length === 0,
            issues: safetyIssues,
            score: Math.max(0, 100 - (safetyIssues.length * 10))
        };
    }

    /**
     * Perform safety checks and return diagnostics
     */
    async performSafetyChecks(content) {
        const diagnostics = [];
        const safetyAnalysis = await this.analyzeSafety(content);

        for (const issue of safetyAnalysis.issues) {
            diagnostics.push({
                range: {
                    start: { line: issue.line, character: 0 },
                    end: { line: issue.line, character: issue.content.length }
                },
                severity: issue.severity,
                message: `🚨 ${issue.message}: ${issue.content}`,
                source: 'shell-safety',
                code: issue.category
            });
        }

        return diagnostics;
    }

    /**
     * Run ShellCheck for advanced linting
     */
    async runShellCheck(content, filePath) {
        return new Promise((resolve) => {
            const shellcheck = spawn(this.config.shellCheckPath, [
                '--format=json',
                '--shell=bash',
                '-'
            ]);

            let output = '';
            let errorOutput = '';

            shellcheck.stdout.on('data', (data) => {
                output += data.toString();
            });

            shellcheck.stderr.on('data', (data) => {
                errorOutput += data.toString();
            });

            shellcheck.on('close', (code) => {
                if (code === 0 || output) {
                    try {
                        const results = JSON.parse(output);
                        const diagnostics = results.map(issue => ({
                            range: {
                                start: { line: issue.line - 1, character: issue.column - 1 },
                                end: { line: issue.endLine - 1, character: issue.endColumn - 1 }
                            },
                            severity: this.mapShellCheckSeverity(issue.level),
                            message: issue.message,
                            source: 'shellcheck',
                            code: `SC${issue.code}`
                        }));
                        resolve(diagnostics);
                    } catch (error) {
                        resolve([]);
                    }
                } else {
                    resolve([]);
                }
            });

            shellcheck.stdin.write(content);
            shellcheck.stdin.end();
        });
    }

    /**
     * Additional helper methods
     */

    checkShellCheckAvailability() {
        return new Promise((resolve) => {
            const shellcheck = spawn(this.config.shellCheckPath, ['--version']);
            shellcheck.on('close', (code) => resolve(code === 0));
            shellcheck.on('error', () => resolve(false));
        });
    }

    getShellCheckVersion() {
        return new Promise((resolve) => {
            const shellcheck = spawn(this.config.shellCheckPath, ['--version']);
            let output = '';

            shellcheck.stdout.on('data', (data) => {
                output += data.toString();
            });

            shellcheck.on('close', () => {
                const versionMatch = output.match(/version: (\S+)/);
                resolve(versionMatch ? versionMatch[1] : 'unknown');
            });
        });
    }

    detectShellType(interpreter) {
        if (interpreter.includes('bash')) return 'bash';
        if (interpreter.includes('zsh')) return 'zsh';
        if (interpreter.includes('fish')) return 'fish';
        if (interpreter.includes('sh')) return 'sh';
        return 'unknown';
    }

    mapShellCheckSeverity(level) {
        const mapping = {
            'error': 'error',
            'warning': 'warning',
            'info': 'information',
            'style': 'hint'
        };
        return mapping[level] || 'information';
    }

    getVariableCompletions() {
        return [
            { label: 'HOME', kind: 'variable', documentation: 'User home directory' },
            { label: 'PATH', kind: 'variable', documentation: 'Executable search path' },
            { label: 'PWD', kind: 'variable', documentation: 'Present working directory' },
            { label: 'USER', kind: 'variable', documentation: 'Current username' },
            { label: '?', kind: 'variable', documentation: 'Exit status of last command' }
        ];
    }

    getCommandCompletions() {
        const completions = [];

        // Built-in commands
        for (const cmd of this.builtinCommands) {
            completions.push({
                label: cmd,
                kind: 'keyword',
                documentation: `Shell built-in: ${cmd}`
            });
        }

        // Safe external commands
        for (const cmd of Array.from(this.safeCommands).slice(0, 20)) {
            completions.push({
                label: cmd,
                kind: 'command',
                documentation: `External command: ${cmd}`
            });
        }

        return completions;
    }

    getOptionCompletions() {
        return [
            { label: '-e', kind: 'option', documentation: 'Exit on error' },
            { label: '-u', kind: 'option', documentation: 'Exit on undefined variable' },
            { label: '-x', kind: 'option', documentation: 'Print commands' },
            { label: '-v', kind: 'option', documentation: 'Verbose mode' }
        ];
    }

    extractSurroundingLines(lines, lineNumber) {
        const start = Math.max(0, lineNumber - this.config.contextRadius);
        const end = Math.min(lines.length, lineNumber + this.config.contextRadius + 1);

        return lines.slice(start, end).map((line, index) => ({
            line: start + index,
            content: line,
            isCurrent: start + index === lineNumber
        }));
    }

    // Additional methods for formatting, validation, etc. would be implemented here...
    calculateIndentLevel(line, currentLevel) {
        // Simplified indent calculation
        if (line.match(/^(if|for|while|function|case)\b/) || line.includes('{')) {
            return currentLevel + 1;
        }
        if (line.match(/^(fi|done|esac)\b/) || line.includes('}')) {
            return Math.max(0, currentLevel - 1);
        }
        return currentLevel;
    }

    handleLongLine(line, indentLevel) {
        // Simplified long line handling
        return line; // Could implement line splitting logic
    }

    checkLineSyntax(line, lineNumber) {
        const errors = [];
        // Basic syntax checking logic would go here
        return errors;
    }

    checkBalance(content) {
        const errors = [];
        // Balance checking for quotes, brackets, etc.
        return errors;
    }

    analyzeControlFlow(content) {
        // Control flow analysis
        return {};
    }

    tokenizeShellScript(content) {
        // Basic tokenization
        return [];
    }

    validateShellSyntax(content) {
        // Shell syntax validation
        return [];
    }

    extractFunctionDocumentation(content, startIndex) {
        // Extract function documentation
        return '';
    }

    getCommandDocumentation(command) {
        // Get command documentation
        return `Documentation for ${command}`;
    }
}

module.exports = ShellAdapter; 