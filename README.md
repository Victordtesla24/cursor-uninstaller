# Cursor AI Performance Dashboard

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

An AI Performance Dashboard and monitoring system for tracking and optimizing AI model usage within the Cursor AI editor.

## Overview

This project provides a comprehensive AI Performance Dashboard that works alongside Cursor AI editor's built-in models (like Claude-sonnet-4-thinking) while also supporting external API integrations for performance monitoring and analysis.

**Key Features:**
- **Real-time Performance Monitoring:** Live metrics for AI model performance, latency, and usage
- **Dual AI Support:** Works with Cursor's built-in AI models AND external API keys
- **Performance Dashboard:** Web-based dashboard for monitoring AI performance
- **Alert System:** Automated performance alerts and reporting
- **Model Comparison:** Compare performance across different AI models
- **Security First:** API keys stored locally in `.env` file (never committed to git)

## Features

-   **🚀 Real-time AI Performance Dashboard:** Monitor AI model performance with live metrics
-   **🔧 Multi-Provider Support:** Claude (Anthropic), GPT (OpenAI), and Gemini (Google AI)
-   **📊 Performance Analytics:** Track latency, error rates, and model efficiency
-   **⚠️ Alert System:** Automated performance monitoring with configurable alerts
-   **🔄 Intelligent Fallback:** Automatic failover between AI providers
-   **📈 Historical Data:** Performance trends and reporting
-   **🎯 Production-Ready:** Robust error handling and monitoring

## Getting Started

### Prerequisites

-   [Node.js](https://nodejs.org/) (v18 or higher)
-   [Cursor AI Editor](https://cursor.sh/)
-   API keys for AI providers (optional but recommended)

### Quick Setup

1.  **Clone and install:**
    ```bash
    git clone <repository-url>
    cd cursor-uninstaller
    npm install
    ```

2.  **Set up API keys:**
    ```bash
    # Create .env file from template
    npm run env:setup
    
    # Edit .env file and add your API keys
    # (Use any text editor or open in Cursor)
    ```

3.  **Configure your API keys in `.env`:**
    ```env
    # Required for real API functionality
    ANTHROPIC_API_KEY=sk-ant-api03-your-key-here
    
    # Optional (for additional providers)
    GOOGLE_AI_API_KEY=your-google-key-here
    OPENAI_API_KEY=sk-proj-your-openai-key-here
    ```

4.  **Start the monitoring system:**
    ```bash
    npm run start:monitoring
    ```

5.  **Open the dashboard:**
    ```bash
    npm run dashboard
    # Or visit: http://localhost:8080/dashboard
    ```

### API Key Setup (Detailed)

#### Required: Anthropic Claude API Key
1. Visit [https://console.anthropic.com/](https://console.anthropic.com/)
2. Create an account or sign in
3. Navigate to API Keys section
4. Create a new API key
5. Copy the key to your `.env` file

#### Optional: Additional Providers
- **Google AI (Gemini):** [https://aistudio.google.com/app/apikey](https://aistudio.google.com/app/apikey)
- **OpenAI (GPT):** [https://platform.openai.com/api-keys](https://platform.openai.com/api-keys)

### Verify Setup
```bash
# Check if your API keys are properly configured
npm run env:check
```

## Project Structure

```
.
├── lib/
│   ├── ai/             # AI client and logic placeholders
│   ├── lang/           # Language-specific adapters
│   └── tools/          # MCP server implementations
├── scripts/            # Helper and build scripts
├── tests/              # Unit and integration tests
├── .env                # API keys and environment variables
├── package.json        # Project configuration and dependencies
└── README.md           # This file
```

## How to Use

1.  **Flesh out the placeholders:** Replace the placeholder logic in `lib/ai/` and `lib/lang/` with your own implementations.
2.  **Configure MCP Servers:** Modify the MCP server configurations in your `~/.cursor/mcp.json` to point to the servers in this project.
3.  **Run the tests:**
    ```bash
    npm test
    ```
4.  **Start developing:** Add your custom features and functionality.

## Contributing

Contributions are welcome! If you have ideas for improving this template, feel free to open an issue or submit a pull request.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
