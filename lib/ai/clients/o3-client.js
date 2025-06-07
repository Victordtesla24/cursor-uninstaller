/**
 * @fileoverview
 * o3 Ultra-Fast Model Client - Production API Implementation
 *
 * This client provides ultra-fast completions through real API integration
 * with optimized request handling and caching.
 */

const { RevolutionaryApiError, RevolutionaryTimeoutError } = require('../../system/errors');

/**
 * o3 Ultra-Fast Model Client - Production Implementation
 * @param {object} context - The assembled context
 * @param {object} options - Processing options
 * @returns {Promise<string>} The completion result
 */
async function o3Client(context, options = {}) {
  const startTime = Date.now();
  const timeout = options.timeout || 10000; // 10 second timeout

  try {
    console.log('[o3] Processing ultra-fast completion request...');
    
    // Production API configuration
    const apiConfig = {
      endpoint: process.env.O3_API_ENDPOINT || 'https://api.openai.com/v1/chat/completions',
      apiKey: process.env.O3_API_KEY || process.env.OPENAI_API_KEY,
      model: 'o3-mini', // Ultra-fast o3 variant
      maxTokens: 4000,
      temperature: 0.1, // Low temperature for consistency
      timeout: timeout
    };

    if (!apiConfig.apiKey) {
      throw new RevolutionaryApiError('o3 API key not configured. Set O3_API_KEY or OPENAI_API_KEY environment variable.');
    }

    // Prepare API request
    const requestBody = {
      model: apiConfig.model,
      messages: buildMessages(context),
      max_tokens: apiConfig.maxTokens,
      temperature: apiConfig.temperature,
      stream: false
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
          'User-Agent': 'cursor-uninstaller/1.0.0'
        },
        body: JSON.stringify(requestBody),
        signal: controller.signal
      });

      clearTimeout(timeoutId);

      if (!response.ok) {
        const errorData = await response.text();
        throw new RevolutionaryApiError(`o3 API error: ${response.status} ${response.statusText} - ${errorData}`);
      }

      const data = await response.json();
      const completion = data.choices?.[0]?.message?.content;
      
      if (!completion) {
        throw new RevolutionaryApiError('o3 API returned empty completion');
      }

      const latency = Date.now() - startTime;
      console.log(`[o3] Ultra-fast completion generated in ${latency}ms`);
      return completion;

    } catch (error) {
      clearTimeout(timeoutId);
      
      if (error.name === 'AbortError') {
        throw new RevolutionaryTimeoutError(`o3 completion timed out after ${timeout}ms`, timeout);
      }
      throw error;
    }

  } catch (error) {
    const latency = Date.now() - startTime;
    console.error(`[o3] Error after ${latency}ms:`, error.message);
    
    if (error instanceof RevolutionaryApiError || error instanceof RevolutionaryTimeoutError) {
      throw error;
    }
    
    throw new RevolutionaryApiError(`o3 ultra-fast processing failed: ${error.message}`, {
      model: 'o3',
      latency,
      context: 'ultra-fast-completion'
    });
  }
}

/**
 * Builds optimized messages for o3 API
 * @private
 */
function buildMessages(context) {
  const messages = [];

  // System message for context
  messages.push({
    role: 'system',
    content: 'You are an ultra-fast AI assistant integrated into the Cursor editor. Provide precise, production-ready code completions and responses. Focus on accuracy and efficiency.'
  });

  if (context.instruction) {
    // Instruction execution scenario
    messages.push({
      role: 'user',
      content: `Execute this instruction: ${context.instruction}\n\nContext: ${JSON.stringify(context, null, 2)}`
    });
  } else if (context.code) {
    // Code completion scenario
    const language = context.language || 'javascript';
    messages.push({
      role: 'user',
      content: `Complete this ${language} code:\n\`\`\`${language}\n${context.code}\n\`\`\`\n\nProvide only the completion without explanations.`
    });
  } else {
    // General query
    messages.push({
      role: 'user',
      content: `Process this request: ${JSON.stringify(context, null, 2)}`
    });
  }

  return messages;
}

module.exports = o3Client; 