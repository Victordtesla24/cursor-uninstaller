/**
 * Puppeteer MCP Client for Cline AI Dashboard
 * Provides utility functions to interact with the Puppeteer MCP server
 * Used for debugging and testing the dashboard UI in real-time
 */

// Default server name for Puppeteer MCP
const PUPPETEER_SERVER = 'puppeteer';

// Guard to prevent circular dependency issues
let checkingPuppeteerAvailability = false;

/**
 * Check if the Puppeteer MCP client is available
 * @returns {Promise<boolean>} Whether the MCP client is available
 */
export const isPuppeteerAvailable = async () => {
  if (typeof window === 'undefined') return false;
  
  // First check if we already know it's available
  if (window.PUPPETEER_MCP_AVAILABLE === true) {
    return true;
  }
  
  // If we already tried and it's not available, return false
  if (window.PUPPETEER_MCP_AVAILABLE === false) {
    return false;
  }
  
  // Guard against reentrant calls that could cause stack overflow
  if (checkingPuppeteerAvailability) {
    console.warn('Preventing recursive isPuppeteerAvailable call');
    return false;
  }
  
  // Set guard to prevent nested calls
  checkingPuppeteerAvailability = true;
  
  // Set a default false value to prevent recursive calls
  window.PUPPETEER_MCP_AVAILABLE = false;
  
  try {
    console.log('Checking Puppeteer MCP availability...');
    
    // Try to connect to the Puppeteer MCP server
    const response = await fetch(`${window.location.protocol}//${window.location.hostname}:3333/mcp/status`, {
      method: 'GET',
      headers: { 'Content-Type': 'application/json' }
    });
    
    const isAvailable = response.ok;
    
    // Cache the result
    window.PUPPETEER_MCP_AVAILABLE = isAvailable;
    
    if (isAvailable) {
      console.log('Puppeteer MCP server is available');
    } else {
      console.warn('Puppeteer MCP server is not available');
    }
    
    checkingPuppeteerAvailability = false;
    return isAvailable;
  } catch (error) {
    console.warn('Error checking Puppeteer MCP availability:', error);
    window.PUPPETEER_MCP_AVAILABLE = false;
    checkingPuppeteerAvailability = false;
    return false;
  }
};

/**
 * Navigate to a URL using Puppeteer
 * @param {string} url - URL to navigate to
 * @returns {Promise<boolean>} Success status
 */
export const navigate = async (url) => {
  // Use cached value to prevent circular dependencies
  if (window.PUPPETEER_MCP_AVAILABLE !== true) {
    console.error('Puppeteer MCP client not available');
    return false;
  }

  try {
    await window.__MCP_CLIENT.useTool(PUPPETEER_SERVER, 'puppeteer_navigate', {
      url
    });
    return true;
  } catch (error) {
    console.error('Error navigating with Puppeteer:', error);
    return false;
  }
};

/**
 * Take a screenshot using Puppeteer
 * @param {Object} options - Screenshot options
 * @param {string} options.name - Name for the screenshot
 * @param {string} [options.selector] - CSS selector for element to screenshot
 * @param {number} [options.width=800] - Width in pixels
 * @param {number} [options.height=600] - Height in pixels
 * @returns {Promise<string|null>} Screenshot data or null on failure
 */
export const takeScreenshot = async ({ name, selector, width = 800, height = 600 }) => {
  // Use cached value to prevent circular dependencies
  if (window.PUPPETEER_MCP_AVAILABLE !== true) {
    console.error('Puppeteer MCP client not available');
    return null;
  }

  try {
    const args = { name };
    if (selector) args.selector = selector;
    if (width) args.width = width;
    if (height) args.height = height;

    const result = await window.__MCP_CLIENT.useTool(PUPPETEER_SERVER, 'puppeteer_screenshot', args);
    return result;
  } catch (error) {
    console.error('Error taking screenshot with Puppeteer:', error);
    return null;
  }
};

/**
 * Click an element on the page using Puppeteer
 * @param {string} selector - CSS selector for element to click
 * @returns {Promise<boolean>} Success status
 */
export const click = async (selector) => {
  // Use cached value to prevent circular dependencies
  if (window.PUPPETEER_MCP_AVAILABLE !== true) {
    console.error('Puppeteer MCP client not available');
    return false;
  }

  try {
    await window.__MCP_CLIENT.useTool(PUPPETEER_SERVER, 'puppeteer_click', {
      selector
    });
    return true;
  } catch (error) {
    console.error('Error clicking element with Puppeteer:', error);
    return false;
  }
};

/**
 * Fill out an input field using Puppeteer
 * @param {string} selector - CSS selector for input field
 * @param {string} value - Value to fill
 * @returns {Promise<boolean>} Success status
 */
export const fill = async (selector, value) => {
  // Use cached value to prevent circular dependencies
  if (window.PUPPETEER_MCP_AVAILABLE !== true) {
    console.error('Puppeteer MCP client not available');
    return false;
  }

  try {
    await window.__MCP_CLIENT.useTool(PUPPETEER_SERVER, 'puppeteer_fill', {
      selector,
      value
    });
    return true;
  } catch (error) {
    console.error('Error filling input with Puppeteer:', error);
    return false;
  }
};

/**
 * Hover an element on the page using Puppeteer
 * @param {string} selector - CSS selector for element to hover
 * @returns {Promise<boolean>} Success status
 */
export const hover = async (selector) => {
  // Use cached value to prevent circular dependencies
  if (window.PUPPETEER_MCP_AVAILABLE !== true) {
    console.error('Puppeteer MCP client not available');
    return false;
  }

  try {
    await window.__MCP_CLIENT.useTool(PUPPETEER_SERVER, 'puppeteer_hover', {
      selector
    });
    return true;
  } catch (error) {
    console.error('Error hovering element with Puppeteer:', error);
    return false;
  }
};

/**
 * Execute JavaScript in the browser console using Puppeteer
 * @param {string} script - JavaScript code to execute
 * @returns {Promise<any>} Result of the execution
 */
export const evaluate = async (script) => {
  // Use cached value instead of making a potentially recursive call
  if (window.PUPPETEER_MCP_AVAILABLE !== true) {
    console.error('Puppeteer MCP client not available for evaluate');
    return null;
  }

  try {
    // Guard against recursive evaluate calls
    if (window.__PUPPETEER_EVALUATING_GUARD === true) {
        console.warn('evaluate: Aborting nested evaluation call');
        return null;
    }
    window.__PUPPETEER_EVALUATING_GUARD = true;
    
    // Direct tool call without additional checks that could create recursion
    const result = await window.__MCP_CLIENT.useTool(PUPPETEER_SERVER, 'puppeteer_evaluate', {
      script
    });
    return result;
  } catch (error) {
    console.error('Error evaluating script with Puppeteer:', error);
    return null;
  } finally {
    window.__PUPPETEER_EVALUATING_GUARD = false;
  }
};

/**
 * Run a diagnostic test on the dashboard using Puppeteer
 * @returns {Promise<Object>} Test results
 */
export const runDiagnosticTest = async () => {
  if (window.PUPPETEER_MCP_AVAILABLE !== true) {
    return {
      success: false,
      message: 'Puppeteer MCP client not available for diagnostic test',
      results: []
    };
  }

  try {
    const navigateResult = await navigate(window.location.href);
    if (!navigateResult) {
      return {
        success: false,
        message: 'Failed to navigate to dashboard for diagnostic test',
        results: []
      };
    }

    await takeScreenshot({ name: 'dashboard_diagnostic' });

    const diagnosticScript = `
      (() => {
        const results = [];
        const root = document.getElementById('root');
        results.push({
          name: 'Root element exists',
          success: !!root,
          details: root ? 'Found #root element' : 'Missing #root element'
        });
        const dashboard = document.querySelector('.enhanced-dashboard, .fallback-dashboard');
        results.push({
          name: 'Dashboard loaded',
          success: !!dashboard,
          details: dashboard ? 'Dashboard UI found' : 'Dashboard UI not found'
        });
        const errors = document.querySelector('.dashboard-error, .error-container');
        results.push({
          name: 'Error check',
          success: !errors,
          details: errors ? 'Error displayed: ' + errors.innerText : 'No visible errors'
        });
        const connectionStatus = document.querySelector('.connection-status');
        results.push({
          name: 'Connection status',
          success: !!connectionStatus,
          details: connectionStatus ? 'Connection status: ' + connectionStatus.textContent : 'No connection status found'
        });
        const mockData = document.querySelector('.mock-data-indicator');
        results.push({
          name: 'Mock data check',
          success: true, 
          details: mockData ? 'Using mock data: ' + mockData.textContent : 'Not using mock data'
        });
        const consoleErrors = window.__console_errors || [];
        results.push({
          name: 'Console errors',
          success: consoleErrors.length === 0,
          details: consoleErrors.length > 0 ? 'Console has ' + consoleErrors.length + ' errors' : 'No console errors'
        });
        return {
          success: results.every(r => r.success),
          message: results.every(r => r.success) ? 'All diagnostic checks passed' : 'Some diagnostic checks failed',
          results: results
        };
      })()
    `;
    
    const diagnosticResults = await evaluate(diagnosticScript);

    return diagnosticResults || {
      success: false,
      message: 'Failed to run diagnostic scripts',
      results: []
    };
  } catch (error) {
    console.error('Error running diagnostic test with Puppeteer:', error);
    return {
      success: false,
      message: `Diagnostic test error: ${error.message}`,
      results: []
    };
  }
};

export default {
  isPuppeteerAvailable,
  navigate,
  takeScreenshot,
  click,
  fill,
  hover,
  evaluate,
  runDiagnosticTest
}; 