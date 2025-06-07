#!/usr/bin/env node

/**
 * Browser Tool MCP Server
 * Provides web browsing capabilities for Cursor AI
 */

const { Server } = require('@modelcontextprotocol/sdk/server/index.js');
const { StdioServerTransport } = require('@modelcontextprotocol/sdk/server/stdio.js');
const {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} = require('@modelcontextprotocol/sdk/types.js');

const puppeteer = require('puppeteer');
const https = require('https');
const http = require('http');
const url = require('url');

class BrowserMCPServer {
  constructor() {
    this.server = new Server(
      {
        name: 'browser-tool-server',
        version: '1.0.0',
      },
      {
        capabilities: {
          tools: {},
        },
      }
    );

    this.browser = null;
    this.setupToolHandlers();
  }

  setupToolHandlers() {
    // List available tools
    this.server.setRequestHandler(ListToolsRequestSchema, async () => {
      return {
        tools: [
          {
            name: 'browse_url',
            description: 'Browse a URL and extract content for analysis',
            inputSchema: {
              type: 'object',
              properties: {
                url: {
                  type: 'string',
                  description: 'URL to browse',
                },
                selector: {
                  type: 'string',
                  description: 'CSS selector to extract specific content (optional)',
                },
                waitFor: {
                  type: 'number',
                  description: 'Time to wait in milliseconds (default: 3000)',
                  default: 3000,
                },
              },
              required: ['url'],
            },
          },
          {
            name: 'search_web',
            description: 'Search the web using DuckDuckGo for troubleshooting and research',
            inputSchema: {
              type: 'object',
              properties: {
                query: {
                  type: 'string',
                  description: 'Search query',
                },
                maxResults: {
                  type: 'number',
                  description: 'Maximum number of results to return (default: 5)',
                  default: 5,
                },
              },
              required: ['query'],
            },
          },
          {
            name: 'fetch_documentation',
            description: 'Fetch documentation from popular tech sites',
            inputSchema: {
              type: 'object',
              properties: {
                technology: {
                  type: 'string',
                  description: 'Technology or topic to find documentation for',
                },
                site: {
                  type: 'string',
                  enum: ['mdn', 'stackoverflow', 'github', 'npm', 'docs'],
                  description: 'Specific site to search (optional)',
                },
              },
              required: ['technology'],
            },
          },
          {
            name: 'check_status',
            description: 'Check the status of a website or API endpoint',
            inputSchema: {
              type: 'object',
              properties: {
                url: {
                  type: 'string',
                  description: 'URL to check status',
                },
                method: {
                  type: 'string',
                  enum: ['GET', 'POST', 'HEAD'],
                  description: 'HTTP method (default: GET)',
                  default: 'GET',
                },
              },
              required: ['url'],
            },
          },
          {
            name: 'screenshot_page',
            description: 'Take a screenshot of a web page for visual analysis',
            inputSchema: {
              type: 'object',
              properties: {
                url: {
                  type: 'string',
                  description: 'URL to screenshot',
                },
                fullPage: {
                  type: 'boolean',
                  description: 'Take full page screenshot (default: false)',
                  default: false,
                },
              },
              required: ['url'],
            },
          },
        ],
      };
    });

    // Handle tool calls
    this.server.setRequestHandler(CallToolRequestSchema, async (request) => {
      const { name, arguments: args } = request.params;

      try {
        switch (name) {
          case 'browse_url':
            return await this.handleBrowseUrl(args);
          case 'search_web':
            return await this.handleSearchWeb(args);
          case 'fetch_documentation':
            return await this.handleFetchDocumentation(args);
          case 'check_status':
            return await this.handleCheckStatus(args);
          case 'screenshot_page':
            return await this.handleScreenshot(args);
          default:
            throw new Error(`Unknown tool: ${name}`);
        }
      } catch (error) {
        return {
          content: [
            {
              type: 'text',
              text: `Browser tool error: ${error.message}`,
            },
          ],
          isError: true,
        };
      }
    });
  }

  async ensureBrowser() {
    if (!this.browser) {
      this.browser = await puppeteer.launch({
        headless: true,
        args: ['--no-sandbox', '--disable-setuid-sandbox'],
      });
    }
    return this.browser;
  }

  async handleBrowseUrl(args) {
    const browser = await this.ensureBrowser();
    const page = await browser.newPage();

    try {
      await page.goto(args.url, { waitUntil: 'networkidle2', timeout: 30000 });
      
      if (args.waitFor) {
        await page.waitForTimeout(args.waitFor);
      }

      let content;
      if (args.selector) {
        content = await page.$eval(args.selector, el => el.textContent);
      } else {
        content = await page.evaluate(() => {
          // Remove script and style elements
          const scripts = document.querySelectorAll('script, style');
          scripts.forEach(el => el.remove());
          return document.body.innerText;
        });
      }

      const title = await page.title();
      
      return {
        content: [
          {
            type: 'text',
            text: `🌐 **Web Page Analysis**\n\n**URL:** ${args.url}\n**Title:** ${title}\n\n**Content:**\n${content.substring(0, 2000)}${content.length > 2000 ? '...' : ''}`,
          },
        ],
      };
    } finally {
      await page.close();
    }
  }

  async handleSearchWeb(args) {
    const searchUrl = `https://html.duckduckgo.com/html/?q=${encodeURIComponent(args.query)}`;
    const browser = await this.ensureBrowser();
    const page = await browser.newPage();

    try {
      await page.goto(searchUrl, { waitUntil: 'networkidle2', timeout: 30000 });
      
      const results = await page.evaluate((maxResults) => {
        const resultElements = document.querySelectorAll('.result');
        const results = [];
        
        for (let i = 0; i < Math.min(resultElements.length, maxResults); i++) {
          const element = resultElements[i];
          const titleEl = element.querySelector('.result__title a');
          const snippetEl = element.querySelector('.result__snippet');
          
          if (titleEl && snippetEl) {
            results.push({
              title: titleEl.textContent.trim(),
              url: titleEl.href,
              snippet: snippetEl.textContent.trim(),
            });
          }
        }
        
        return results;
      }, args.maxResults || 5);

      const searchResults = results.map((result, index) => 
        `${index + 1}. **${result.title}**\n   ${result.url}\n   ${result.snippet}\n`
      ).join('\n');

      return {
        content: [
          {
            type: 'text',
            text: `🔍 **Web Search Results**\n\n**Query:** ${args.query}\n**Results:**\n\n${searchResults}`,
          },
        ],
      };
    } finally {
      await page.close();
    }
  }

  async handleFetchDocumentation(args) {
    const docUrls = {
      mdn: `https://developer.mozilla.org/en-US/search?q=${encodeURIComponent(args.technology)}`,
      stackoverflow: `https://stackoverflow.com/search?q=${encodeURIComponent(args.technology)}`,
      github: `https://github.com/search?q=${encodeURIComponent(args.technology)}`,
      npm: `https://www.npmjs.com/search?q=${encodeURIComponent(args.technology)}`,
    };

    const searchUrl = args.site && docUrls[args.site] 
      ? docUrls[args.site]
      : `https://www.google.com/search?q=${encodeURIComponent(args.technology + ' documentation')}`;

    return await this.handleBrowseUrl({ url: searchUrl, waitFor: 3000 });
  }

  async handleCheckStatus(args) {
    return new Promise((resolve) => {
      const parsedUrl = url.parse(args.url);
      const isHttps = parsedUrl.protocol === 'https:';
      const client = isHttps ? https : http;

      const options = {
        hostname: parsedUrl.hostname,
        port: parsedUrl.port || (isHttps ? 443 : 80),
        path: parsedUrl.path,
        method: args.method || 'GET',
        timeout: 10000,
      };

      const req = client.request(options, (res) => {
        let data = '';
        res.on('data', chunk => data += chunk);
        res.on('end', () => {
          resolve({
            content: [
              {
                type: 'text',
                text: `🌐 **Status Check**\n\n**URL:** ${args.url}\n**Status Code:** ${res.statusCode}\n**Status Message:** ${res.statusMessage}\n**Headers:** ${JSON.stringify(res.headers, null, 2)}\n\n**Response Preview:**\n${data.substring(0, 500)}${data.length > 500 ? '...' : ''}`,
              },
            ],
          });
        });
      });

      req.on('error', (error) => {
        resolve({
          content: [
            {
              type: 'text',
              text: `❌ **Status Check Failed**\n\n**URL:** ${args.url}\n**Error:** ${error.message}`,
            },
          ],
        });
      });

      req.on('timeout', () => {
        req.destroy();
        resolve({
          content: [
            {
              type: 'text',
              text: `⏰ **Status Check Timeout**\n\n**URL:** ${args.url}\n**Error:** Request timed out after 10 seconds`,
            },
          ],
        });
      });

      req.end();
    });
  }

  async handleScreenshot(args) {
    const browser = await this.ensureBrowser();
    const page = await browser.newPage();

    try {
      await page.goto(args.url, { waitUntil: 'networkidle2', timeout: 30000 });
      
      const screenshotBuffer = await page.screenshot({
        fullPage: args.fullPage || false,
        type: 'png',
      });

      const base64Screenshot = screenshotBuffer.toString('base64');
      
      return {
        content: [
          {
            type: 'text',
            text: `📸 **Screenshot Captured**\n\n**URL:** ${args.url}\n**Full Page:** ${args.fullPage ? 'Yes' : 'No'}\n**Size:** ${Math.round(screenshotBuffer.length / 1024)} KB\n\nScreenshot saved as base64 data (use image viewer to display).`,
          },
          {
            type: 'image',
            data: base64Screenshot,
            mimeType: 'image/png',
          },
        ],
      };
    } finally {
      await page.close();
    }
  }

  async run() {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
    console.error('Browser Tool MCP Server running on stdio');
  }

  async shutdown() {
    if (this.browser) {
      await this.browser.close();
    }
  }
}

// Run the server
if (require.main === module) {
  const server = new BrowserMCPServer();
  
  // Handle graceful shutdown
  process.on('SIGINT', async () => {
    await server.shutdown();
    process.exit(0);
  });
  
  server.run().catch(console.error);
}

module.exports = BrowserMCPServer; 