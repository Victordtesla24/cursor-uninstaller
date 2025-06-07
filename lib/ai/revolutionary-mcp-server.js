#!/usr/bin/env node

/**
 * @fileoverview
 * Basic MCP Server - Simple Model Context Protocol implementation
 * 
 * NOTE: This is a basic MCP server that provides simple tools.
 * - No "revolutionary" features
 * - No "6-model orchestration"
 * - Just basic placeholder functionality
 */

import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from '@modelcontextprotocol/sdk/types.js';

class BasicMCPServer {
  constructor() {
    this.server = new Server(
      {
        name: 'basic-ai-server',
        version: '1.0.0',
      },
      {
        capabilities: {
          tools: {},
        },
      }
    );

    this.setupHandlers();
  }

  setupHandlers() {
    // List available tools
    this.server.setRequestHandler(ListToolsRequestSchema, async () => ({
      tools: [
        {
          name: 'echo',
          description: 'Simple echo tool for testing',
          inputSchema: {
            type: 'object',
            properties: {
              message: {
                type: 'string',
                description: 'Message to echo back',
              },
            },
            required: ['message'],
          },
        },
        {
          name: 'get_info',
          description: 'Get basic server information',
          inputSchema: {
            type: 'object',
            properties: {},
          },
        },
      ],
    }));

    // Handle tool calls
    this.server.setRequestHandler(CallToolRequestSchema, async (request) => {
      const { name, arguments: args } = request.params;

      switch (name) {
        case 'echo':
          return {
            content: [
              {
                type: 'text',
                text: `Echo: ${args.message || 'No message provided'}`,
              },
            ],
          };

        case 'get_info':
          return {
            content: [
              {
                type: 'text',
                text: JSON.stringify({
                  server: 'basic-ai-server',
                  version: '1.0.0',
                  status: 'operational',
                  note: 'This is a basic MCP server with placeholder functionality. Real AI features require proper API integration.',
                }, null, 2),
              },
            ],
          };

        default:
          throw new Error(`Unknown tool: ${name}`);
      }
    });
  }

  async run() {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
    console.error('Basic MCP Server running on stdio');

    // Handle shutdown gracefully
    process.on('SIGINT', async () => {
      console.error('Shutting down Basic MCP Server...');
      await this.server.close();
      process.exit(0);
    });

    process.on('SIGTERM', async () => {
      console.error('Shutting down Basic MCP Server...');
      await this.server.close();
      process.exit(0);
    });
  }
}

// Start the server
const server = new BasicMCPServer();
server.run().catch(console.error); 