/**
 * @fileoverview
 * Gemini Model Client - Production API Implementation
 *
 * This client provides multimodal understanding through real Google AI integration
 * with support for visual code analysis and comprehensive context processing.
 */

const { RevolutionaryApiError, RevolutionaryTimeoutError } = require('../../system/errors');

/**
 * Gemini Model Client - Production Implementation
 * @param {object} context - The assembled context
 * @param {object} options - Processing options
 * @returns {Promise<string>} The completion result
 */
async function geminiClient(context, options = {}) {
  const startTime = Date.now();
  const timeout = options.timeout || 30000; // 30 second timeout
  const multimodal = options.multimodal !== false;

  try {
    console.log('[Gemini] Processing multimodal request with visual analysis:', multimodal);
    
    // Production API configuration
    const apiConfig = {
      endpoint: process.env.GEMINI_API_ENDPOINT || 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent',
      apiKey: process.env.GEMINI_API_KEY || process.env.GOOGLE_AI_API_KEY,
      model: determineGeminiModel(context, options),
      timeout: timeout
    };

    if (!apiConfig.apiKey) {
      throw new RevolutionaryApiError('Gemini API key not configured. Set GEMINI_API_KEY or GOOGLE_AI_API_KEY environment variable.');
    }

    // Prepare API request with multimodal support
    const requestBody = {
      contents: buildGeminiContents(context, multimodal),
      generationConfig: {
        maxOutputTokens: 8000,
        temperature: 0.3,
        topP: 0.8,
        topK: 40
      },
      safetySettings: [
        {
          category: 'HARM_CATEGORY_HARASSMENT',
          threshold: 'BLOCK_ONLY_HIGH'
        },
        {
          category: 'HARM_CATEGORY_HATE_SPEECH',
          threshold: 'BLOCK_ONLY_HIGH'
        },
        {
          category: 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
          threshold: 'BLOCK_ONLY_HIGH'
        },
        {
          category: 'HARM_CATEGORY_DANGEROUS_CONTENT',
          threshold: 'BLOCK_ONLY_HIGH'
        }
      ]
    };

    // Make API request with timeout
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), timeout);

    try {
      const response = await fetch(`${apiConfig.endpoint}?key=${apiConfig.apiKey}`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'cursor-uninstaller/1.0.0'
        },
        body: JSON.stringify(requestBody),
        signal: controller.signal
      });

      clearTimeout(timeoutId);

      if (!response.ok) {
        const errorData = await response.text();
        throw new RevolutionaryApiError(`Gemini API error: ${response.status} ${response.statusText} - ${errorData}`);
      }

      const data = await response.json();
      const completion = data.candidates?.[0]?.content?.parts?.[0]?.text;
      
      if (!completion) {
        throw new RevolutionaryApiError('Gemini API returned empty completion');
      }

      const latency = Date.now() - startTime;
      console.log(`[Gemini] Multimodal completion generated in ${latency}ms using ${apiConfig.model}`);
      return completion;

    } catch (error) {
      clearTimeout(timeoutId);
      
      if (error.name === 'AbortError') {
        throw new RevolutionaryTimeoutError(`Gemini completion timed out after ${timeout}ms`, timeout);
      }
      throw error;
    }

  } catch (error) {
    const latency = Date.now() - startTime;
    console.error(`[Gemini] Error after ${latency}ms:`, error.message);
    
    if (error instanceof RevolutionaryApiError || error instanceof RevolutionaryTimeoutError) {
      throw error;
    }
    
    throw new RevolutionaryApiError(`Gemini multimodal processing failed: ${error.message}`, {
      model: 'gemini',
      latency,
      context: 'multimodal-processing'
    });
  }
}

/**
 * Determines the optimal Gemini model based on context and options
 * @private
 */
function determineGeminiModel(context, options) {
  if (options.model) return options.model;
  
  // Model selection based on multimodal requirements
  if (context.visual || context.images || options.multimodal) {
    return 'gemini-2.0-flash-exp'; // Latest multimodal model
  } else if (context.instruction && context.instruction.length > 2000) {
    return 'gemini-1.5-pro-latest'; // Complex text processing
  } else {
    return 'gemini-1.5-flash-latest'; // Fast processing
  }
}

/**
 * Builds optimized contents for Gemini API with multimodal support
 * @private
 */
function buildGeminiContents(context, multimodal) {
  const contents = [];
  const parts = [];

  // Build text content
  if (context.instruction) {
    // Instruction execution with multimodal analysis
    let textContent = multimodal ? 
      `Perform multimodal analysis and execute this instruction with comprehensive understanding:\n\n${context.instruction}` :
      `Execute this instruction: ${context.instruction}`;
    
    if (context.code) {
      textContent += `\n\nCode context:\n\`\`\`${context.language || 'text'}\n${context.code}\n\`\`\``;
    }
    
    if (context.additionalContext) {
      textContent += `\n\nAdditional context: ${context.additionalContext}`;
    }
    
    parts.push({ text: textContent });
  } else if (context.code) {
    // Code completion with visual understanding
    const language = context.language || 'javascript';
    let textContent = multimodal ?
      `Analyze this ${language} code structure visually and provide intelligent completion:\n\`\`\`${language}\n${context.code}\n\`\`\`\n\nConsider patterns, architecture, and visual code organization.` :
      `Complete this ${language} code:\n\`\`\`${language}\n${context.code}\n\`\`\``;
    
    parts.push({ text: textContent });
  } else {
    // General processing
    const textContent = multimodal ?
      `Process this request with multimodal understanding and visual analysis: ${JSON.stringify(context, null, 2)}` :
      `Process this request: ${JSON.stringify(context, null, 2)}`;
    
    parts.push({ text: textContent });
  }

  // Add visual context if available
  if (multimodal && context.images) {
    context.images.forEach(image => {
      if (typeof image === 'string') {
        // Base64 encoded image
        parts.push({
          inlineData: {
            mimeType: 'image/png',
            data: image
          }
        });
      } else if (image.url) {
        // Image URL (note: Gemini API may have restrictions on external URLs)
        parts.push({
          fileData: {
            mimeType: image.mimeType || 'image/png',
            fileUri: image.url
          }
        });
      }
    });
  }

  contents.push({
    role: 'user',
    parts: parts
  });

  return contents;
}

module.exports = geminiClient; 