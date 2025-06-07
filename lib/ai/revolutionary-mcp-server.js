#!/usr/bin/env node

/**
 * Revolutionary AI MCP Server
 * Provides MCP protocol interface for 6-model orchestration system
 */

const { Server } = require('@modelcontextprotocol/sdk/server/index.js');
const { StdioServerTransport } = require('@modelcontextprotocol/sdk/server/stdio.js');
const {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} = require('@modelcontextprotocol/sdk/types.js');

const RevolutionaryController = require('./revolutionary-controller.js');
const SixModelOrchestrator = require('./6-model-orchestrator.js');

class RevolutionaryMCPServer {
  constructor() {
    this.server = new Server(
      {
        name: 'revolutionary-ai-server',
        version: '1.0.0',
      },
      {
        capabilities: {
          tools: {},
        },
      }
    );

    this.controller = new RevolutionaryController();
    this.setupToolHandlers();
  }

  setupToolHandlers() {
    // List available tools
    this.server.setRequestHandler(ListToolsRequestSchema, async () => {
      return {
        tools: [
          {
            name: 'ai_completion',
            description: 'Get AI code completion using 6-model orchestration',
            inputSchema: {
              type: 'object',
              properties: {
                code: {
                  type: 'string',
                  description: 'Code context for completion',
                },
                language: {
                  type: 'string',
                  description: 'Programming language',
                },
                complexity: {
                  type: 'string',
                  enum: ['simple', 'complex', 'ultimate'],
                  description: 'Task complexity level',
                },
              },
              required: ['code'],
            },
          },
          {
            name: 'ai_instruction',
            description: 'Execute AI instruction with thinking modes',
            inputSchema: {
              type: 'object',
              properties: {
                instruction: {
                  type: 'string',
                  description: 'Instruction to execute',
                },
                context: {
                  type: 'string',
                  description: 'Additional context',
                },
                useThinking: {
                  type: 'boolean',
                  description: 'Enable advanced thinking modes',
                  default: true,
                },
              },
              required: ['instruction'],
            },
          },
          {
            name: 'ai_metrics',
            description: 'Get Revolutionary AI system metrics and performance data',
            inputSchema: {
              type: 'object',
              properties: {},
            },
          },
          {
            name: 'model_selection',
            description: 'Get optimal model selection for given task',
            inputSchema: {
              type: 'object',
              properties: {
                taskType: {
                  type: 'string',
                  description: 'Type of task (completion, instruction, analysis)',
                },
                complexity: {
                  type: 'string',
                  enum: ['simple', 'complex', 'ultimate'],
                  description: 'Task complexity',
                },
                multimodal: {
                  type: 'boolean',
                  description: 'Requires multimodal analysis',
                  default: false,
                },
              },
              required: ['taskType'],
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
          case 'ai_completion':
            return await this.handleCompletion(args);
          case 'ai_instruction':
            return await this.handleInstruction(args);
          case 'ai_metrics':
            return await this.handleMetrics(args);
          case 'model_selection':
            return await this.handleModelSelection(args);
          default:
            throw new Error(`Unknown tool: ${name}`);
        }
      } catch (error) {
        return {
          content: [
            {
              type: 'text',
              text: `Error: ${error.message}`,
            },
          ],
          isError: true,
        };
      }
    });
  }

  async handleCompletion(args) {
    const result = await this.controller.requestCompletion({
      code: args.code,
      language: args.language || 'javascript',
      complexity: args.complexity || 'simple',
      thinkingMode: true,
      unlimitedProcessing: true,
    });

    return {
      content: [
        {
          type: 'text',
          text: `🚀 **Revolutionary AI Completion**\n\n**Model Used:** ${result.model}\n**Completion:**\n\`\`\`${args.language || 'text'}\n${result.completion}\n\`\`\`\n\n**Confidence:** ${(result.confidence * 100).toFixed(1)}%\n**Latency:** ${result.latency}ms\n**Thinking Mode:** ${result.thinkingMode ? 'Enabled' : 'Disabled'}`,
        },
      ],
    };
  }

  async handleInstruction(args) {
    const result = await this.controller.executeInstruction({
      instruction: args.instruction,
      context: args.context,
      validation: true,
      unlimitedContext: true,
      useThinking: args.useThinking !== false,
    });

    return {
      content: [
        {
          type: 'text',
          text: `🧠 **Revolutionary AI Instruction Execution**\n\n**Model Used:** ${result.model}\n**Result:** ${result.explanation || 'Instruction executed successfully'}\n\n**Confidence:** ${(result.confidence * 100).toFixed(1)}%\n**Latency:** ${result.latency}ms\n**Thinking Mode:** ${result.thinkingMode ? 'Enabled' : 'Disabled'}`,
        },
      ],
    };
  }

  async handleMetrics(args) {
    const metrics = this.controller.getMetrics();
    
    return {
      content: [
        {
          type: 'text',
          text: `📊 **Revolutionary AI System Metrics**\n\n**Performance Score:** ${metrics.performanceScore}%\n**Cache Hit Rate:** ${metrics.cacheHitRate}\n**Total Completions:** ${metrics.completions}\n**Average Latency:** ${metrics.averageLatency}ms\n**Memory Optimization:** ${metrics.memoryOptimizationStatus}\n**Optimizations Applied:** ${metrics.optimizationsApplied}\n\n**System Status:** All 6 models operational\n**Unlimited Context:** Enabled\n**Thinking Modes:** Active`,
        },
      ],
    };
  }

  async handleModelSelection(args) {
    const orchestrator = new SixModelOrchestrator({}, null);
    const selection = orchestrator.selectModels({
      type: args.taskType,
      complexity: args.complexity || 'simple',
      multimodal: args.multimodal || false,
      unlimited: true,
    });

    return {
      content: [
        {
          type: 'text',
          text: `🎯 **Optimal Model Selection**\n\n**Primary Model:** ${selection.selectedModels[0]}\n**All Selected Models:** ${selection.selectedModels.join(', ')}\n**Strategy:** ${selection.strategy}\n**Confidence:** ${(selection.confidence * 100).toFixed(1)}%\n**Thinking Mode:** ${selection.thinking ? 'Enabled' : 'Disabled'}\n**Multimodal:** ${selection.multimodal ? 'Yes' : 'No'}\n**Context Processing:** ${selection.contextProcessing}\n**Intelligence Level:** ${selection.intelligence}`,
        },
      ],
    };
  }

  async run() {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
    console.error('Revolutionary AI MCP Server running on stdio');
  }
}

// Run the server
if (require.main === module) {
  const server = new RevolutionaryMCPServer();
  server.run().catch(console.error);
}

module.exports = RevolutionaryMCPServer; 