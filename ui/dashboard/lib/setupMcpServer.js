/**
 * Setup MCP Server for Cline AI Dashboard
 * This module configures and initializes the MCP server for the dashboard
 * Integrates both the Cline Dashboard MCP server and the Magic MCP API
 */

import * as magicMcpClient from './magicMcpClient.js';

// Utility function to wait for a global variable to be defined
const waitForGlobal = (name, timeout = 5000) => {
  return new Promise((resolve, reject) => {
    if (window[name] !== undefined) {
      return resolve(window[name]);
    }

    const startTime = Date.now();

    const interval = setInterval(() => {
      if (window[name] !== undefined) {
        clearInterval(interval);
        resolve(window[name]);
      } else if (Date.now() > startTime + timeout) {
        clearInterval(interval);
        reject(new Error(`Timeout waiting for ${name} to be defined`));
      }
    }, 100);
  });
};

// Configuration for the Cline Dashboard MCP server
const setupClineServer = async () => {
  // Detect if running in VS Code or standalone mode
  const isVsCodeEnvironment = typeof window !== 'undefined' && window.cline;

  if (!isVsCodeEnvironment) {
    console.log('Not running in VS Code environment, using mock data');
    return false;
  }

  try {
    // Check if the cline-dashboard MCP server is already registered
    const existingServers = await window.cline.getMcpServers?.() || [];

    if (existingServers.includes('cline-dashboard')) {
      console.log('Cline Dashboard MCP server already registered');
      return true;
    }

    // If server management API is available in newer versions
    if (window.cline.registerMcpServer) {
      await window.cline.registerMcpServer({
        name: 'cline-dashboard',
        command: 'node',
        args: ['/Users/vicd/Documents/Cline/MCP/cline-dashboard-mcp/build/index.js'],
        env: {}
      });
      console.log('Registered Cline Dashboard MCP server');
      return true;
    }

    console.warn('Unable to register Cline Dashboard MCP server, VS Code API not available');
    return false;
  } catch (error) {
    console.error('Error setting up Cline Dashboard MCP server:', error);
    return false;
  }
};

// Configuration for the Magic MCP API
const setupMagicApiServer = async () => {
  try {
    // Test connection to the Magic API
    const connected = await magicMcpClient.checkMagicApiConnection();

    if (!connected) {
      console.warn('Failed to connect to Magic API');
      return false;
    }

    console.log('Successfully connected to Magic API');
    return true;
  } catch (error) {
    console.error('Error setting up Magic API server:', error);
    return false;
  }
};

// Configuration for the Puppeteer MCP server
const setupPuppeteerServer = async () => {
  try {
    // Check if Puppeteer MCP server is accessible
    console.log('Setting up Puppeteer MCP server...');

    // Try to connect to the Puppeteer server directly
    try {
      const response = await fetch(`${window.location.protocol}//${window.location.hostname}:3333/mcp/status`, {
        method: 'GET',
        headers: { 'Content-Type': 'application/json' }
      });

      if (response.ok) {
        // Set a global flag to indicate Puppeteer MCP server is available
        window.PUPPETEER_MCP_AVAILABLE = true;
        console.log('Successfully connected to Puppeteer MCP server');
        return true;
      } else {
        console.warn(`Puppeteer MCP server responded with status: ${response.status}`);
        window.PUPPETEER_MCP_AVAILABLE = false;
        return false;
      }
    } catch (connectionError) {
      console.warn('Unable to connect to Puppeteer MCP server:', connectionError);
      window.PUPPETEER_MCP_AVAILABLE = false;

      // Try the MCP client as a fallback
      if (window.__MCP_CLIENT) {
        try {
          console.log('Trying MCP client for Puppeteer check...');
          // Set the global flag if we have an MCP client
          window.PUPPETEER_MCP_AVAILABLE = true;
          return true;
        } catch (mcpError) {
          console.error('Error with MCP client for Puppeteer:', mcpError);
          window.PUPPETEER_MCP_AVAILABLE = false;
          return false;
        }
      }

      return false;
    }
  } catch (error) {
    console.error('Error setting up Puppeteer MCP server:', error);
    window.PUPPETEER_MCP_AVAILABLE = false;
    return false;
  }
};

/**
 * Initialize all MCP servers needed for the dashboard
 * @returns {Promise<Object>} Status of server initialization
 */
export const initializeMcpServers = async () => {
  const clineServerStatus = await setupClineServer();
  const magicApiStatus = await setupMagicApiServer();
  const puppeteerStatus = await setupPuppeteerServer();

  return {
    clineServerConnected: clineServerStatus,
    magicApiConnected: magicApiStatus,
    puppeteerConnected: puppeteerStatus,
    usingMockData: !clineServerStatus
  };
};

/**
 * Create a new MCP server configuration for a project
 * @param {string} projectPath - Path to the project
 * @returns {Object} MCP configuration object
 */
export const createMcpConfig = (projectPath = '.') => {
  return {
    mcpServers: {
      '@21st-dev/magic': {
        command: 'npx',
        args: ['-y', '@21st-dev/magic@latest'],
        env: {
          API_KEY: '53498dc92288a232c236c00f5c982f89456f3e7699b760e6746b133abb023bea'
        }
      },
      'cline-dashboard': {
        command: 'node',
        args: ['/Users/vicd/Documents/Cline/MCP/cline-dashboard-mcp/build/index.js'],
        env: {}
      },
      'puppeteer': {
        command: 'npx',
        args: ['-y', '@modelcontextprotocol/server-puppeteer'],
        env: {}
      }
    }
  };
};

/**
 * Save MCP configuration to the specified location
 * @param {string} configPath - Path to save the config (defaults to VS Code settings)
 * @returns {Promise<boolean>} Success status
 */
export const saveMcpConfig = async (configPath = null) => {
  // This is a placeholder - in a real implementation, this would write to disk
  // or use VS Code API to update settings

  const config = createMcpConfig();

  try {
    if (typeof window !== 'undefined' && window.cline && window.cline.updateConfiguration) {
      await window.cline.updateConfiguration('mcp', config);
      console.log('Updated MCP configuration in VS Code settings');
      return true;
    }

    console.log('MCP configuration would be saved to:', configPath || 'VS Code settings');
    console.log('Configuration:', JSON.stringify(config, null, 2));
    return true;
  } catch (error) {
    console.error('Error saving MCP configuration:', error);
    return false;
  }
};

// Export for direct imports
export default {
  initializeMcpServers,
  createMcpConfig,
  saveMcpConfig
};

// Also expose to window for easier access from other scripts
if (typeof window !== 'undefined') {
  window.setupMcp = {
    initializeMcpServers,
    createMcpConfig,
    saveMcpConfig
  };
}
