/**
 * Magic MCP Client for Cline AI Dashboard
 * Handles integration with the 21st.dev Magic API for enhanced UI components
 *
 * Based on Magic MCP documentation from magic-mcp.md
 */

const API_KEY = '53498dc92288a232c236c00f5c982f89456f3e7699b760e6746b133abb023bea';
const API_BASE_URL = 'https://api.21st.dev';

/**
 * Search for UI components by description
 * @param {string} query - Description of the UI component needed
 * @param {number} page - Page number for pagination (default: 1)
 * @param {number} perPage - Results per page (default: 20)
 * @returns {Promise<Object>} Search results including component previews
 */
export const searchComponents = async (query, page = 1, perPage = 20) => {
  try {
    const response = await fetch(`${API_BASE_URL}/api/search`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': API_KEY
      },
      body: JSON.stringify({
        search: query,
        page,
        per_page: perPage
      })
    });

    if (!response.ok) {
      const errorData = await response.json();
      throw new Error(errorData.error || 'Failed to search components');
    }

    return await response.json();
  } catch (error) {
    console.error('Error searching Magic components:', error);
    throw error;
  }
};

/**
 * Generate a prompt for a specific component
 * @param {string} demoId - The demo ID from search results
 * @param {string} promptType - Type of prompt (default: 'magic_patterns')
 * @returns {Promise<Object>} Object containing the generated prompt
 */
export const generateComponentPrompt = async (demoId, promptType = 'magic_patterns') => {
  try {
    const response = await fetch(`${API_BASE_URL}/api/prompts`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': API_KEY
      },
      body: JSON.stringify({
        prompt_type: promptType,
        demo_id: demoId
      })
    });

    if (!response.ok) {
      const errorData = await response.json();
      throw new Error(errorData.error || 'Failed to generate prompt');
    }

    return await response.json();
  } catch (error) {
    console.error('Error generating component prompt:', error);
    throw error;
  }
};

/**
 * Format search results for easy consumption by the dashboard
 * @param {Object} searchResults - Results from the searchComponents function
 * @returns {Array<Object>} Formatted components list
 */
export const formatComponentResults = (searchResults) => {
  if (!searchResults || !searchResults.results) {
    return [];
  }

  return searchResults.results.map(result => ({
    id: result.demo_id,
    name: result.component_data.name,
    description: result.component_data.description,
    previewUrl: result.preview_url,
    videoUrl: result.video_url || null,
    codeUrl: result.component_data.code,
    installCommand: result.component_data.install_command,
    author: {
      name: result.component_user_data.name,
      username: result.component_user_data.username,
      imageUrl: result.component_user_data.image_url
    },
    usageCount: result.usage_count
  }));
};

/**
 * Get remaining API requests information
 * @param {Object} searchResults - Results from the searchComponents function
 * @returns {Object} Information about remaining requests and plan
 */
export const getApiUsageInfo = (searchResults) => {
  if (!searchResults || !searchResults.metadata) {
    return {
      plan: 'unknown',
      requestsRemaining: 0,
      totalRequests: 0
    };
  }

  return {
    plan: searchResults.metadata.plan,
    requestsRemaining: searchResults.metadata.requests_remaining,
    totalRequests: 100 // Default value from documentation
  };
};

/**
 * Check if the Magic API connection is working
 * @returns {Promise<boolean>} True if connected, false otherwise
 */
export const checkMagicApiConnection = async () => {
  try {
    // Perform a minimal search to check connectivity
    const response = await searchComponents('test', 1, 1);
    return !!response && !!response.results;
  } catch (error) {
    console.error('Magic API connection test failed:', error);
    return false;
  }
};

export default {
  searchComponents,
  generateComponentPrompt,
  formatComponentResults,
  getApiUsageInfo,
  checkMagicApiConnection
};
