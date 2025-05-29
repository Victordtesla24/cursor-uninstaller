import React from "react";
import ReactDOM from "react-dom/client";
import EnhancedDashboard from "./enhancedDashboard.jsx";
import { initializeMcpServers } from './lib/setupMcpServer.js';
import "./styles.css";
// Removed import for Dashboard.jsx and index.jsx as they are consolidated into enhancedDashboard.jsx

console.log("Starting Cline AI Dashboard...");

// Helper to remove the loading screen once React has rendered
const removeLoadingScreen = () => {
  const loadingScreen = document.getElementById("loading-screen");
  if (loadingScreen) {
    console.log("Removing loading screen");

    // Add fade-out effect
    loadingScreen.style.transition = "opacity 0.5s";
    loadingScreen.style.opacity = "0";

    // Remove element after transition
    setTimeout(() => {
      if (loadingScreen.parentNode) {
        loadingScreen.parentNode.removeChild(loadingScreen);
      }
    }, 500);
  }
};

// Ensure the root element exists
const ensureRootElement = () => {
  if (!document.getElementById("root")) {
    console.log("Root element missing, creating it");
    const root = document.createElement("div");
    root.id = "root";
    document.body.appendChild(root);
    return true;
  }
  return false;
};

/**
 * Initialize MCP and render the dashboard
 * This function sets up the MCP client and then renders
 * the EnhancedDashboard as the sole application component.
 */
async function initAndRenderApp() {
  try {
    // Ensure root element exists
    ensureRootElement();
    const rootElement = document.getElementById("root");

    // Initialize MCP servers via the setup module
    console.log("Setting up MCP servers...");
    const mcpStatus = await initializeMcpServers();
    console.log("MCP setup complete", mcpStatus);

    // Render the EnhancedDashboard
    console.log("Rendering EnhancedDashboard...");
    const reactRoot = ReactDOM.createRoot(rootElement);
    reactRoot.render(
      <React.StrictMode>
        <EnhancedDashboard />
      </React.StrictMode>
    );

    // Remove loading screen after render
    removeLoadingScreen();

    console.log("Dashboard rendered successfully");
  } catch (error) {
    console.error("Error initializing application:", error);

    // Even if MCP setup fails, still render the dashboard
    // enhancedDashboardApi will fall back to mock data
    try {
      const rootElement = document.getElementById("root");
      if (rootElement) {
        console.log("Rendering EnhancedDashboard with fallback to mock data...");
        const reactRoot = ReactDOM.createRoot(rootElement);
        reactRoot.render(
          <React.StrictMode>
            <EnhancedDashboard />
          </React.StrictMode>
        );

        // Remove loading screen
        removeLoadingScreen();

        console.log("Dashboard rendered with fallback to mock data");
      }
    } catch (renderError) {
      console.error("Critical error rendering dashboard:", renderError);
      // Display error message in root element
      const rootElement = document.getElementById("root");
      if (rootElement) {
        rootElement.innerHTML = `
          <div style="padding: 20px; font-family: sans-serif; background-color: #fdd; border: 1px solid #f00; color: #a00;">
            <h2>Dashboard Failed to Load</h2>
            <p>There was a critical error initializing the dashboard application.</p>
            <p><strong>Error Message:</strong> ${renderError.message || "Unknown error"}</p>
            <button onclick="window.location.reload()" style="padding: 8px 16px; background: #3b82f6; color: white; border: none; border-radius: 4px; cursor: pointer; margin-top: 10px;">
              Reload Page
            </button>
          </div>
        `;
      }
    }
  }
}

// Start the application when document is ready
if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", initAndRenderApp);
} else {
  initAndRenderApp();
}

// Additional error handling for global errors
window.addEventListener("error", (event) => {
  console.error("Global error caught:", event.error);
});

console.log("main.jsx script execution completed");
