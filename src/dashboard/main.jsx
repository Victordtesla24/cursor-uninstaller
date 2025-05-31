import React from "react";
import ReactDOM from "react-dom/client";
import ModernDashboard from "./ModernDashboard.jsx";
import "./styles.css";

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
 * Initialize and render the modern dashboard
 */
async function initAndRenderApp() {
  try {
    // Ensure root element exists
    ensureRootElement();
    const rootElement = document.getElementById("root");

    // Render the ModernDashboard
    console.log("Rendering ModernDashboard...");
    const reactRoot = ReactDOM.createRoot(rootElement);
    reactRoot.render(
      <React.StrictMode>
        <ModernDashboard />
      </React.StrictMode>
    );

    // Remove loading screen after render
    removeLoadingScreen();

    console.log("Modern Dashboard rendered successfully");
  } catch (error) {
    console.error("Error initializing application:", error);
    
    // Display error message in root element
    const rootElement = document.getElementById("root");
    if (rootElement) {
      rootElement.innerHTML = `
        <div style="padding: 20px; font-family: sans-serif; background-color: #fdd; border: 1px solid #f00; color: #a00;">
          <h2>Dashboard Failed to Load</h2>
          <p>There was a critical error initializing the dashboard application.</p>
          <p><strong>Error Message:</strong> ${error.message || "Unknown error"}</p>
          <button onclick="window.location.reload()" style="padding: 8px 16px; background: #3b82f6; color: white; border: none; border-radius: 4px; cursor: pointer; margin-top: 10px;">
            Reload Page
          </button>
        </div>
      `;
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
