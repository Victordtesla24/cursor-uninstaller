# Cursor AI Integration Template

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/cursor-ai/integration-template)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Status](https://img.shields.io/badge/status-Template-yellow.svg)](#status)

> **A basic template project for Cursor AI integrations**

This is a template/placeholder project that demonstrates the structure needed for Cursor AI integrations. It includes basic MCP (Model Context Protocol) server examples and placeholder implementations.

## ⚠️ Important Notice

This is a **template project** with placeholder implementations. It does NOT provide:
- Actual AI model integration
- Real API functionality
- "Revolutionary" features
- "6-model orchestration"
- "Unlimited context"

To build a real integration, you'll need to:
1. Obtain API keys from AI providers (OpenAI, Anthropic, Google, etc.)
2. Implement actual API calls
3. Handle rate limits and errors properly
4. Implement real functionality

## 📁 Project Structure

```
cursor-uninstaller/
├── lib/
│   ├── ai/               # AI-related placeholder modules
│   ├── cache/            # Basic caching utilities
│   ├── lang/             # Language adapters
│   ├── shadow/           # Shadow functionality placeholders
│   ├── system/           # System utilities
│   ├── tools/            # MCP server implementations
│   └── ui/               # UI-related utilities
├── scripts/              # Various utility scripts
├── tests/                # Test files
└── package.json          # Node.js dependencies
```

## 🚀 Getting Started

### Prerequisites

- macOS (tested on darwin 24.5.0)
- Node.js 18+ 
- npm or yarn
- Cursor AI installed

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd cursor-uninstaller
```

2. Install dependencies:
```bash
npm install
```

3. Set up environment variables (if implementing real functionality):
```bash
export OPENAI_API_KEY="your-api-key"
export ANTHROPIC_API_KEY="your-api-key"
# etc.
```

## 🔧 MCP Servers

This template includes basic MCP server examples:

### Browser MCP Server
Located at `lib/tools/browser-mcp-server.js`
- Provides basic web browsing tools
- Requires Puppeteer for actual functionality

### Basic AI MCP Server  
Located at `lib/ai/revolutionary-mcp-server.js` (should be renamed)
- Provides placeholder AI tools
- Requires API integration for real functionality

### Configuration

MCP servers are configured in `~/.cursor/mcp.json`:

```json
{
  "mcpServers": {
    "basic-ai": {
      "command": "node",
      "args": ["path/to/basic-mcp-server.js"]
    }
  }
}
```

## 📝 Scripts

- `scripts/test-mcp-servers.js` - Test MCP server connectivity
- `scripts/syntax_and_shellcheck.sh` - Validate shell scripts
- Various other utility scripts for testing and validation

## 🧪 Testing

Run tests with:
```bash
npm test
```

Run specific test suites:
```bash
npm run test:unit
npm run test:integration
```

## ⚙️ Configuration

Basic configuration is handled through:
- Environment variables
- `lib/config.sh` for shell scripts
- Individual module configurations

## 🤝 Contributing

This is a template project. Feel free to:
1. Fork and modify for your needs
2. Add real API integrations
3. Implement actual functionality
4. Remove placeholder code

## 📄 License

MIT License - see LICENSE file for details

## 🔍 Status

This is a **template/placeholder project**. It provides structure but requires significant implementation work to become functional. All "AI" features are placeholders that return error messages indicating the need for proper API integration.

## ✅ What This Project Actually Provides

- Basic project structure for Cursor AI integrations
- MCP server examples
- Placeholder modules showing where real code would go
- Test structure examples
- Basic utility scripts

## ❌ What This Project Does NOT Provide

- Working AI model integration
- API functionality without keys
- Any "revolutionary" features
- Multi-model orchestration
- Unlimited context processing
- Production-ready code

To build a real Cursor AI integration, use this as a starting template and implement the actual functionality based on your specific needs.
