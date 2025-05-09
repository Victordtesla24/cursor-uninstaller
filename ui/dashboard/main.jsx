import React from 'react';
import ReactDOM from 'react-dom/client';
import { Dashboard } from './enhancedDashboard.jsx';
import './styles.css';

/**
 * Main entry point for the Cline AI Dashboard
 * Renders the enhanced dashboard component with real-time data updates
 * and Magic MCP API integration
 */

// Check if we need to set up the MCP configuration first
const setupMcpIfNeeded = async () => {
  try {
    const { default: setupMcp } = await import('./lib/setupMcpServer.js');
    await setupMcp.initializeMcpServers();
  } catch (error) {
    console.error('Failed to set up MCP configuration:', error);
    // Continue anyway, will fall back to mock data
  }
};

// Initialize and render the application
const renderApp = () => {
  const rootElement = document.getElementById('root');

  if (rootElement) {
    ReactDOM.createRoot(rootElement).render(
      <React.StrictMode>
        <Dashboard />
      </React.StrictMode>
    );
  } else {
    console.error('Root element not found');
  }
};

// Start the application
const startApp = async () => {
  // Set up MCP if needed
  await setupMcpIfNeeded();

  // Render the dashboard
  renderApp();
};

// Start the application when the DOM is loaded
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', startApp);
} else {
  startApp();
}
