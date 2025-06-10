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
     * Get script directory for relative path operations
     */
    getScriptDirectory(filePath) {
        return path.dirname(path.resolve(filePath));
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

            // Apply options for context customization
            const includeSafety = options.includeSafety !== false;
            const includeTokens = options.includeTokens !== false;

            const context = {
                file: filePath,
                position,
                language: 'shell',
                shebang: this.parseShebang(content),
                functions: this.extractFunctions(content),
                variables: this.extractVariables(content),
                includes: this.findIncludes(content),
                surrounding: this.extractSurroundingLines(lines, currentLine),
                safetyAnalysis: includeSafety ? await this.analyzeSafety(content) : null,
                controlFlow: this.analyzeControlFlow(content),
                tokens: includeTokens ? this.tokenizeShellScript(content) : [],
                scriptDir: this.getScriptDirectory(filePath),
                options: { includeSafety, includeTokens }
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
            // Apply formatting options
            const formattingOptions = { ...this.formatter, ...options };
            console.debug(`Applying shell formatting options: ${JSON.stringify(formattingOptions)}`);

            const lines = content.split('\n');
            const formatted = [];
            let indentLevel = 0;
            const indentStr = this.formatter.useTabs ? '\t' : ' '.repeat(this.formatter.indentSize);

            for (const line of lines) {
                const trimmed = line.trim();
                if (trimmed === '') {
                    formatted.push('');
                    continue;
                }

                // Calculate indentation
                if (trimmed.match(/^(fi|done|esac|\})/)) {
                    indentLevel = Math.max(0, indentLevel - 1);
                }

                const indentedLine = indentStr.repeat(indentLevel) + trimmed;
                formatted.push(indentedLine);

                // Increase indent for control structures
                if (trimmed.match(/^(if|while|for|case|function|\{)/)) {
                    indentLevel++;
                }
            }

            return formatted.join('\n');

        } catch (error) {
            console.error(`Shell formatting failed: ${error.message}`);
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

            // Look for function definition
            const functionRegex = new RegExp(`^\\s*(?:function\\s+)?${symbol}\\s*\\(\\)`, 'gm');
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
                    detail: this.extractFunctionDocumentation(content, match.index),
                    documentation: this.extractFunctionDocumentation(content, match.index),
                    proximity,
                    relevant: proximity < this.config.contextRadius
                };
            }

            // Look for variable definition
            const varRegex = new RegExp(`^\\s*${symbol}=`, 'gm');
            const varMatch = varRegex.exec(content);

            if (varMatch) {
                const line = content.substring(0, varMatch.index).split('\n').length - 1;

                return {
                    name: symbol,
                    kind: 'variable',
                    range: {
                        start: { line, character: varMatch.index },
                        end: { line, character: varMatch.index + varMatch[0].length }
                    },
                    detail: `Variable: ${symbol}`,
                    documentation: `Shell variable ${symbol}`
                };
            }

            return null;

        } catch (error) {
            console.error(`Shell symbol resolution failed for ${symbol} in ${filePath}: ${error.message}`);
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
        try {
            if (!this.lspClient?.available) {
                console.debug(`ShellCheck not available for ${filePath}`);
                return [];
            }

            // Create temporary file for ShellCheck analysis
            const tempFile = path.join(process.cwd(), '.shellcheck_temp.sh');
            await fs.writeFile(tempFile, content);

            try {
                const result = await this.executeCommand('shellcheck', [
                    '--format=json',
                    '--severity=style',
                    tempFile
                ]);

                if (result.success && result.stdout) {
                    const shellCheckResults = JSON.parse(result.stdout);
                    const diagnostics = shellCheckResults.map(issue => ({
                        range: {
                            start: { line: issue.line - 1, character: issue.column - 1 },
                            end: { line: issue.endLine - 1, character: issue.endColumn - 1 }
                        },
                        severity: this.mapShellCheckSeverity(issue.level),
                        message: `${issue.message} (SC${issue.code})`,
                        source: 'shellcheck',
                        code: `SC${issue.code}`
                    }));

                    return diagnostics;
                }

                return [];

            } finally {
                // Clean up temporary file
                try {
                    await fs.unlink(tempFile);
                } catch (cleanupError) {
                    console.warn(`Failed to clean up temp file: ${cleanupError.message}`);
                }
            }

        } catch (error) {
            console.error(`ShellCheck execution failed: ${error.message}`);
            return [];
        }
    }

    /**
     * Additional helper methods
     */

    /**
     * Check if ShellCheck is available
     */
    async checkShellCheckAvailability() {
        try {
            const result = await this.executeCommand('shellcheck', ['--version']);
            return result.success;
        } catch (error) {
            console.warn(`ShellCheck availability check failed: ${error.message}`);
            return false;
        }
    }

    /**
     * Execute shell command utility
     */
    async executeCommand(command, args = []) {
        return new Promise((resolve) => {
            const child = spawn(command, args, { stdio: 'pipe' });

            let stdout = '';
            let stderr = '';

            child.stdout.on('data', (data) => {
                stdout += data.toString();
            });

            child.stderr.on('data', (data) => {
                stderr += data.toString();
            });

            child.on('close', (code) => {
                resolve({
                    success: code === 0,
                    stdout: stdout.trim(),
                    stderr: stderr.trim()
                });
            });
        });
    }

    /**
     * Get ShellCheck version
     */
    async getShellCheckVersion() {
        try {
            const result = await this.executeCommand('shellcheck', ['--version']);
            if (result.success) {
                const versionMatch = result.stdout.match(/version: (.+)/);
                return versionMatch ? versionMatch[1] : 'unknown';
            }
            return 'unavailable';
        } catch (error) {
            console.warn(`Failed to get ShellCheck version: ${error.message}`);
            return 'unavailable';
        }
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
        if (line.length <= this.formatter.maxLineLength) {
            return [line];
        }

        // Log indentation context for debugging
        console.debug(`Breaking long line at indent level ${indentLevel}: ${line.substring(0, 50)}...`);

        const maxLength = this.formatter.maxLineLength - (indentLevel * this.formatter.indentSize);
        const parts = [];
        let current = line;

        while (current.length > maxLength) {
            // Find a good break point (space, pipe, etc.)
            let breakPoint = current.lastIndexOf(' ', maxLength);
            if (breakPoint === -1) breakPoint = maxLength;

            parts.push(current.substring(0, breakPoint) + ' \\');
            current = '    ' + current.substring(breakPoint).trim();
        }

        if (current.trim()) {
            parts.push(current);
        }

        return parts;
    }

    checkLineSyntax(line, lineNumber) {
        const issues = [];

        // Log line analysis for debugging
        console.debug(`Checking syntax for line ${lineNumber}: ${line.trim()}`);

        // Check for unquoted variables
        if (line.match(/\$\w+/) && !line.match(/"\$\w+"/)) {
            issues.push({
                range: { start: { line: lineNumber, character: 0 }, end: { line: lineNumber, character: line.length } },
                severity: 'warning',
                message: 'Consider quoting variables to prevent word splitting',
                source: 'shell-syntax'
            });
        }

        return issues;
    }

    checkBalance(content) {
        const issues = [];

        // Log content analysis for debugging
        console.debug(`Checking bracket balance for content length: ${content.length}`);

        let parenCount = 0;
        let bracketCount = 0;
        let braceCount = 0;

        for (const char of content) {
            switch (char) {
                case '(': parenCount++; break;
                case ')': parenCount--; break;
                case '[': bracketCount++; break;
                case ']': bracketCount--; break;
                case '{': braceCount++; break;
                case '}': braceCount--; break;
            }
        }

        if (parenCount !== 0 || bracketCount !== 0 || braceCount !== 0) {
            issues.push({
                range: { start: { line: 0, character: 0 }, end: { line: 0, character: 1 } },
                severity: 'error',
                message: 'Unmatched brackets or parentheses',
                source: 'shell-syntax'
            });
        }

        return issues;
    }

    analyzeControlFlow(content) {
        const structures = [];

        // Log content analysis for debugging
        console.debug(`Analyzing control flow for content length: ${content.length}`);

        const controlRegex = /(if|while|for|case|function)\s/g;
        let match;

        while ((match = controlRegex.exec(content)) !== null) {
            const line = content.substring(0, match.index).split('\n').length - 1;
            structures.push({
                type: match[1],
                line,
                position: match.index
            });
        }

        return structures;
    }

    tokenizeShellScript(content) {
        const tokens = [];

        // Log content analysis for debugging
        console.debug(`Tokenizing shell script, content length: ${content.length}`);

        // Simple tokenization - in real implementation would be more sophisticated
        const words = content.split(/\s+/);
        words.forEach((word, index) => {
            if (word.trim()) {
                tokens.push({
                    type: this.getTokenType(word),
                    value: word,
                    index
                });
            }
        });

        return tokens;
    }

    validateShellSyntax(content) {
        const errors = [];

        // Log content analysis for debugging
        console.debug(`Validating shell syntax for content length: ${content.length}`);

        // Check balance
        errors.push(...this.checkBalance(content));

        // Check line syntax
        const lines = content.split('\n');
        lines.forEach((line, index) => {
            errors.push(...this.checkLineSyntax(line, index));
        });

        return errors;
    }

    extractFunctionDocumentation(content, startIndex) {
        // Log extraction context for debugging
        console.debug(`Extracting function documentation from index ${startIndex}`);

        const beforeContent = content.substring(Math.max(0, startIndex - 500), startIndex);
        const lines = beforeContent.split('\n').reverse();

        const docLines = [];
        for (const line of lines) {
            const trimmed = line.trim();
            if (trimmed.startsWith('#')) {
                docLines.unshift(trimmed);
            } else if (trimmed === '') {
                continue;
            } else {
                break;
            }
        }

        return docLines.join('\n') || 'No documentation available';
    }

    getCommandDocumentation(command) {
        // Get command documentation
        return `Documentation for ${command}`;
    }

    getTokenType(word) {
        if (this.builtinCommands.has(word)) return 'builtin';
        if (this.safeCommands.has(word)) return 'command';
        if (word.startsWith('$')) return 'variable';
        if (word.match(/^-+\w/)) return 'option';
        return 'word';
    }
}

module.exports = ShellAdapter;
