/**
 * @fileoverview
 * Claude Model Client - Production API Implementation
 *
 * Supports Claude-4-Sonnet, Claude-4-Opus, and Claude-3.7-Sonnet with
 * advanced thinking modes and production-ready API integration.
 */

const { RevolutionaryApiError, RevolutionaryTimeoutError } = require('../../system/errors');

/**
 * Claude Model Client - Production Implementation
 * @param {object} context - The assembled context
 * @param {object} options - Processing options
 * @returns {Promise<string>} The completion result
 */
async function claudeClient(context, options = {}) {
  const startTime = Date.now();
  const timeout = options.timeout || 30000; // 30 second timeout
  const useThinking = options.useThinking !== false;

  try {
    console.log('[Claude] Processing with thinking modes:', useThinking);
    
    // Production API configuration
    const apiConfig = {
      endpoint: process.env.CLAUDE_API_ENDPOINT || 'https://api.anthropic.com/v1/messages',
      apiKey: process.env.CLAUDE_API_KEY || process.env.ANTHROPIC_API_KEY,
      model: determineClaudeModel(context, options),
      maxTokens: 8000,
      temperature: 0.2,
      timeout: timeout
    };

    if (!apiConfig.apiKey) {
      throw new RevolutionaryApiError('Claude API key not configured. Set CLAUDE_API_KEY or ANTHROPIC_API_KEY environment variable.');
    }

    // Prepare API request with thinking mode support
    const requestBody = {
      model: apiConfig.model,
      max_tokens: apiConfig.maxTokens,
      temperature: apiConfig.temperature,
      messages: buildClaudeMessages(context, useThinking),
      system: buildSystemPrompt(useThinking)
    };

    // Make API request with timeout
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), timeout);

    try {
      const response = await fetch(apiConfig.endpoint, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${apiConfig.apiKey}`,
          'Content-Type': 'application/json',
          'x-api-key': apiConfig.apiKey,
          'anthropic-version': '2023-06-01',
          'User-Agent': 'cursor-uninstaller/1.0.0'
        },
        body: JSON.stringify(requestBody),
        signal: controller.signal
      });

      clearTimeout(timeoutId);

      if (!response.ok) {
        const errorData = await response.text();
        throw new RevolutionaryApiError(`Claude API error: ${response.status} ${response.statusText} - ${errorData}`);
      }

      const data = await response.json();
      const completion = data.content?.[0]?.text;
      
      if (!completion) {
        throw new RevolutionaryApiError('Claude API returned empty completion');
      }

      const latency = Date.now() - startTime;
      console.log(`[Claude] Thinking mode completion generated in ${latency}ms using ${apiConfig.model}`);
      return completion;

    } catch (error) {
      clearTimeout(timeoutId);
      
      if (error.name === 'AbortError') {
        throw new RevolutionaryTimeoutError(`Claude completion timed out after ${timeout}ms`, timeout);
      }
      throw error;
    }

  } catch (error) {
    const latency = Date.now() - startTime;
    console.error(`[Claude] Error after ${latency}ms:`, error.message);
    
    if (error instanceof RevolutionaryApiError || error instanceof RevolutionaryTimeoutError) {
      throw error;
    }
    
    throw new RevolutionaryApiError(`Claude processing failed: ${error.message}`, {
      model: 'claude',
      latency,
      context: 'thinking-mode-processing'
    });
  }
}

/**
 * Determines the optimal Claude model based on context and options
 * @private
 */
function determineClaudeModel(context, options) {
  if (options.model) return options.model;
  
  // Model selection based on complexity and requirements
  if (context.instruction && context.instruction.length > 1000) {
    return 'claude-3-opus-20240229'; // Complex instructions
  } else if (context.multimodal || context.visual) {
    return 'claude-3-sonnet-20240229'; // Multimodal analysis
  } else if (options.useThinking === false) {
    return 'claude-3-haiku-20240307'; // Fast processing
  } else {
    return 'claude-3-sonnet-20240229'; // Default thinking mode
  }
}

/**
 * Builds system prompt with thinking mode capabilities
 * @private
 */
function buildSystemPrompt(useThinking) {
  let systemPrompt = 'You are Claude, an AI assistant integrated into the Cursor editor. Provide precise, production-ready responses for coding tasks.';
  
  if (useThinking) {
    systemPrompt += '\n\nWhen processing complex requests, use step-by-step reasoning. Break down problems into logical components and explain your thought process clearly.';
  }
  
  return systemPrompt;
}

/**
 * Builds optimized messages for Claude API with thinking mode support
 * @private
 */
function buildClaudeMessages(context, useThinking) {
  const messages = [];

  if (context.instruction) {
    // Instruction execution with thinking mode
    let content = context.instruction;
    
    if (useThinking) {
      content = `Please analyze this instruction step by step and provide a comprehensive solution:\n\n${context.instruction}`;
      if (context.code) {
        content += `\n\nCode context:\n\`\`\`\n${context.code}\n\`\`\``;
      }
      if (context.additionalContext) {
        content += `\n\nAdditional context: ${context.additionalContext}`;
      }
    }
    
    messages.push({
      role: 'user',
      content: content
    });
  } else if (context.code) {
    // Code completion with thinking mode
    const language = context.language || 'javascript';
    let content = `Complete this ${language} code:\n\`\`\`${language}\n${context.code}\n\`\`\``;
    
    if (useThinking) {
      content = `Analyze this ${language} code and provide a thoughtful completion:\n\`\`\`${language}\n${context.code}\n\`\`\`\n\nConsider the context, patterns, and best practices.`;
    }
    
    messages.push({
      role: 'user',
      content: content
    });
  } else {
    // General processing
    messages.push({
      role: 'user',
      content: `Process this request with ${useThinking ? 'step-by-step analysis' : 'direct response'}: ${JSON.stringify(context, null, 2)}`
    });
  }

  return messages;
}

module.exports = claudeClient; 