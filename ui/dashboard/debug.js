/**
 * Debug Utilities for Cline AI Dashboard
 * 
 * Provides debugging tools and utilities for real-time diagnostics
 * and troubleshooting of the dashboard application.
 */

// Import specific functions from puppeteerClient instead of default import
// This prevents circular dependency issues
import { isPuppeteerAvailable, takeScreenshot, runDiagnosticTest } from './lib/puppeteerClient';

/**
 * Ensure the root element exists in the DOM
 * Returns true if the element was created, false if it already existed
 * @returns {boolean} Whether the element was created
 */
export const ensureRootElement = () => {
  if (!document.getElementById('root')) {
    console.log('Root element missing, creating it');
    const root = document.createElement('div');
    root.id = 'root';
    document.body.appendChild(root);
    return true;
  }
  return false;
};

/**
 * Create and show a debug info panel
 * Allows inspecting the current state of the dashboard
 * @returns {HTMLElement} The debug panel element
 */
export const showDebugInfo = () => {
  // If an existing debug container is present, remove it first
  const existingContainer = document.getElementById('debug-container');
  if (existingContainer) {
    existingContainer.parentNode.removeChild(existingContainer);
  }

  // Create a new debug container
  const debugContainer = document.createElement('div');
  debugContainer.id = 'debug-container';
  debugContainer.style.position = 'fixed';
  debugContainer.style.top = '10px';
  debugContainer.style.right = '10px';
  debugContainer.style.padding = '15px';
  debugContainer.style.backgroundColor = 'rgba(0, 0, 0, 0.8)';
  debugContainer.style.color = '#fff';
  debugContainer.style.borderRadius = '5px';
  debugContainer.style.zIndex = '9999';
  debugContainer.style.maxWidth = '400px';
  debugContainer.style.maxHeight = '80vh';
  debugContainer.style.overflow = 'auto';
  
  // Add heading
  const title = document.createElement('h3');
  title.textContent = 'Dashboard Debug';
  title.style.margin = '0 0 10px 0';
  debugContainer.appendChild(title);
  
  // Try to detect Puppeteer MCP availability
  const puppeteerStatus = document.createElement('div');
  puppeteerStatus.style.marginBottom = '10px';
  puppeteerStatus.style.padding = '5px';
  puppeteerStatus.style.backgroundColor = 'rgba(255, 255, 255, 0.1)';
  puppeteerStatus.style.borderRadius = '3px';
  
  // Check Puppeteer availability using imported function
  // Use the cached value to avoid potential recursion
  const puppeteerAvailable = window.PUPPETEER_MCP_AVAILABLE === true;
  if (puppeteerAvailable) {
    puppeteerStatus.textContent = '✅ Puppeteer MCP is available';
    puppeteerStatus.style.color = '#4ade80';
  } else {
    puppeteerStatus.textContent = '❌ Puppeteer MCP is not available';
    puppeteerStatus.style.color = '#f87171';
  }
  debugContainer.appendChild(puppeteerStatus);

  // Add environment info
  const envInfo = document.createElement('div');
  envInfo.style.marginTop = '10px';
  envInfo.innerHTML = `
    <div style="margin-bottom: 5px; font-weight: bold;">Environment</div>
    <div>User Agent: ${navigator.userAgent}</div>
    <div>Window Size: ${window.innerWidth}x${window.innerHeight}</div>
    <div>Root Element: ${document.getElementById('root') ? 'Found' : 'Not Found'}</div>
    <div>React: ${window.React ? window.React.version : 'Not found in window object'}</div>
  `;
  debugContainer.appendChild(envInfo);

  // Add React component info if available
  if (window.React && window.__REACT_DEVTOOLS_GLOBAL_HOOK__) {
    const reactInfo = document.createElement('div');
    reactInfo.style.marginTop = '10px';
    reactInfo.innerHTML = '<div style="margin-bottom: 5px; font-weight: bold;">React Components</div>';
    
    try {
      const reactInstances = Array.from(document.querySelectorAll('[data-reactroot]'));
      if (reactInstances.length > 0) {
        reactInstances.forEach((instance, index) => {
          const componentName = instance._reactRootContainer?._internalRoot?.current?.child?.type?.name || 'Unknown';
          reactInfo.innerHTML += `<div>Root ${index+1}: ${componentName}</div>`;
        });
      } else {
        reactInfo.innerHTML += '<div>No React roots found</div>';
      }
    } catch (e) {
      reactInfo.innerHTML += `<div>Error inspecting React: ${e.message}</div>`;
    }
    
    debugContainer.appendChild(reactInfo);
  }
  
  // Add console output capture
  const consoleOutput = document.createElement('div');
  consoleOutput.style.marginTop = '10px';
  consoleOutput.innerHTML = '<div style="margin-bottom: 5px; font-weight: bold;">Console Output</div>';
  
  const consoleLog = document.createElement('div');
  consoleLog.style.backgroundColor = '#111';
  consoleLog.style.padding = '5px';
  consoleLog.style.borderRadius = '3px';
  consoleLog.style.fontSize = '12px';
  consoleLog.style.fontFamily = 'monospace';
  consoleLog.style.whiteSpace = 'pre-wrap';
  consoleLog.style.maxHeight = '200px';
  consoleLog.style.overflow = 'auto';
  consoleLog.textContent = 'Console output will appear here.';
  
  consoleOutput.appendChild(consoleLog);
  debugContainer.appendChild(consoleOutput);
  
  // Add actions section
  const actions = document.createElement('div');
  actions.style.marginTop = '15px';
  actions.innerHTML = '<div style="margin-bottom: 5px; font-weight: bold;">Actions</div>';
  
  // Create action buttons
  const refreshButton = document.createElement('button');
  refreshButton.textContent = 'Refresh Dashboard';
  refreshButton.style.marginRight = '5px';
  refreshButton.style.padding = '5px 10px';
  refreshButton.style.backgroundColor = '#3b82f6';
  refreshButton.style.border = 'none';
  refreshButton.style.borderRadius = '3px';
  refreshButton.style.color = '#fff';
  refreshButton.style.cursor = 'pointer';
  refreshButton.onclick = () => window.location.reload();
  actions.appendChild(refreshButton);
  
  const diagButton = document.createElement('button');
  diagButton.textContent = 'Run Diagnostic Tests';
  diagButton.style.padding = '5px 10px';
  diagButton.style.backgroundColor = '#3b82f6';
  diagButton.style.border = 'none';
  diagButton.style.borderRadius = '3px';
  diagButton.style.color = '#fff';
  diagButton.style.cursor = 'pointer';
  diagButton.onclick = () => {
    window.location.href = 'debug-test.html';
  };
  actions.appendChild(diagButton);
  
  // Use cached value instead of calling isPuppeteerAvailable
  // to avoid potential recursion
  if (window.PUPPETEER_MCP_AVAILABLE === true) {
    const puppeteerButton = document.createElement('button');
    puppeteerButton.textContent = 'Puppeteer Debug';
    puppeteerButton.style.marginTop = '5px';
    puppeteerButton.style.padding = '5px 10px';
    puppeteerButton.style.backgroundColor = '#10b981';
    puppeteerButton.style.border = 'none';
    puppeteerButton.style.borderRadius = '3px';
    puppeteerButton.style.color = '#fff';
    puppeteerButton.style.cursor = 'pointer';
    puppeteerButton.onclick = async () => {
      try {
        console.log('Running Puppeteer diagnostic test...');
        const results = await runDiagnosticTest();
        
        // Add results to console output
        consoleLog.innerHTML += `\n<div style="color: ${results.success ? '#4ade80' : '#f87171'}">
          Puppeteer Diagnostics: ${results.message}
        </div>`;
        
        results.results.forEach(result => {
          consoleLog.innerHTML += `\n<div style="color: ${result.success ? '#4ade80' : '#f87171'}">
            - ${result.name}: ${result.details}
          </div>`;
        });
        
        consoleLog.scrollTop = consoleLog.scrollHeight;
      } catch (error) {
        console.error('Error running Puppeteer diagnostics:', error);
        consoleLog.innerHTML += `\n<div style="color: #f87171">
          Error running Puppeteer diagnostics: ${error.message}
        </div>`;
        consoleLog.scrollTop = consoleLog.scrollHeight;
      }
    };
    actions.appendChild(puppeteerButton);
  }
  
  debugContainer.appendChild(actions);
  
  // Add close button
  const closeButton = document.createElement('button');
  closeButton.textContent = 'Close';
  closeButton.style.marginTop = '15px';
  closeButton.style.width = '100%';
  closeButton.style.padding = '5px 10px';
  closeButton.style.backgroundColor = '#444';
  closeButton.style.border = 'none';
  closeButton.style.borderRadius = '3px';
  closeButton.style.color = '#fff';
  closeButton.style.cursor = 'pointer';
  closeButton.onclick = () => document.body.removeChild(debugContainer);
  debugContainer.appendChild(closeButton);
  
  document.body.appendChild(debugContainer);

  // Override console to capture output
  const originalLog = console.log;
  const originalError = console.error;
  const originalWarn = console.warn;
  
  function captureLog(method, args) {
    const message = Array.from(args).map(arg => {
      try {
        return typeof arg === 'object' ? JSON.stringify(arg) : String(arg);
      } catch (e) {
        return String(arg);
      }
    }).join(' ');
    
    consoleLog.innerHTML += `\n<div style="color: ${
      method === 'error' ? '#f87171' : 
      method === 'warn' ? '#fbbf24' : 
      '#a8c8ff'
    }">[${method}] ${message}</div>`;
    consoleLog.scrollTop = consoleLog.scrollHeight;
  }
  
  console.log = function() {
    captureLog('log', arguments);
    originalLog.apply(console, arguments);
  };
  
  console.error = function() {
    captureLog('error', arguments);
    originalError.apply(console, arguments);
  };
  
  console.warn = function() {
    captureLog('warn', arguments);
    originalWarn.apply(console, arguments);
  };
  
  // Restore original console when debug panel is closed
  closeButton.addEventListener('click', () => {
    console.log = originalLog;
    console.error = originalError;
    console.warn = originalWarn;
  });
  
  return debugContainer;
};

/**
 * Initialize the React-based Debug Panel component
 * This is used by the main app to render the debug panel
 * @param {Function} renderDebugPanel - Function to render the debug panel component
 */
export const initDebugPanel = (renderDebugPanel) => {
  // Store the render function globally for access from console
  window.__renderDebugPanel = renderDebugPanel;
  
  // Add keyboard shortcut (Ctrl+Shift+D) to toggle debug panel
  document.addEventListener('keydown', (e) => {
    if (e.ctrlKey && e.shiftKey && e.key === 'D') {
      e.preventDefault();
      if (typeof window.__renderDebugPanel === 'function') {
        window.__renderDebugPanel();
      } else {
        // Fallback to classic debug info panel
        showDebugInfo();
      }
    }
  });
  
  console.log('Debug panel initialized (press Ctrl+Shift+D to show)');
};

/**
 * Capture screenshot using Puppeteer
 * @param {string} [name='dashboard'] - Name for the screenshot
 * @param {string} [selector] - Optional selector to screenshot specific element
 * @returns {Promise<string|null>} Base64 encoded image data or null on failure
 */
export const captureScreenshot = async (name = 'dashboard', selector = null) => {
  // Use cached value instead of making a call that could create a circular dependency
  if (window.PUPPETEER_MCP_AVAILABLE !== true) {
    console.error('Puppeteer not available for screenshot');
    return null;
  }
  
  try {
    const options = { name };
    if (selector) options.selector = selector;
    
    return await takeScreenshot(options);
  } catch (error) {
    console.error('Error capturing screenshot:', error);
    return null;
  }
};

// Export debugging utilities
export default {
  ensureRootElement,
  showDebugInfo,
  initDebugPanel,
  captureScreenshot,
  isPuppeteerAvailable: () => window.PUPPETEER_MCP_AVAILABLE === true
};
