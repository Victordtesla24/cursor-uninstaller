// Simple debug test to identify React rendering and import issues

// Function to test imports
async function testImports() {
  try {
    console.log("Testing React import...");
    const React = await import("react");
    console.log("✅ React imported successfully:", React.version);

    console.log("Testing ReactDOM import...");
    const ReactDOM = await import("react-dom/client");
    console.log("✅ ReactDOM imported successfully");

    console.log("Testing component imports...");
    const components = await import("./components/index.js");
    console.log("✅ Components imported successfully:", Object.keys(components));

    console.log("Testing enhancedDashboard import...");
    const EnhancedDashboard = await import("./enhancedDashboard.jsx").then(module => module.default);
    console.log("✅ EnhancedDashboard imported successfully:", typeof EnhancedDashboard);

    console.log("Testing enhancedDashboardApi import...");
    const enhancedDashboardApi = await import("./lib/enhancedDashboardApi.js");
    console.log("✅ enhancedDashboardApi imported successfully");

    console.log("Testing setupMcpServer import...");
    const setupMcp = await import("./lib/setupMcpServer.js");
    console.log("✅ setupMcpServer imported successfully");

    return true;
  } catch (error) {
    console.error("❌ Import test failed:", error);
    return false;
  }
}

// Function to test DOM rendering
function testDomRendering() {
  try {
    console.log("Testing DOM rendering...");

    // Check if root element exists
    const rootElement = document.getElementById("root");
    if (!rootElement) {
      console.error("❌ Root element not found in DOM");
      return false;
    }

    console.log("✅ Root element found in DOM");

    // Create a simple test element to verify we can modify the DOM
    const testElement = document.createElement("div");
    testElement.id = "test-element";
    testElement.textContent = "DOM Test Element";
    testElement.style.padding = "10px";
    testElement.style.margin = "10px";
    testElement.style.border = "1px solid red";

    rootElement.appendChild(testElement);

    console.log("✅ Test element added to DOM");

    return true;
  } catch (error) {
    console.error("❌ DOM rendering test failed:", error);
    return false;
  }
}

// Function to test React rendering
async function testReactRendering() {
  try {
    console.log("Testing React rendering...");

    // Import React and ReactDOM
    const React = await import("react");
    const ReactDOM = await import("react-dom/client");

    // Check if root element exists
    const rootElement = document.getElementById("root");
    if (!rootElement) {
      console.error("❌ Root element not found for React rendering");
      return false;
    }

    // Create a simple React component
    const TestComponent = () => {
      return React.createElement("div", {
        style: {
          padding: "20px",
          margin: "20px",
          border: "2px solid blue",
          backgroundColor: "#f0f8ff"
        }
      }, [
        React.createElement("h2", { key: "title" }, "React Rendering Test"),
        React.createElement("p", { key: "description" }, "If you can see this, React is rendering correctly."),
        React.createElement("button", {
          key: "button",
          onClick: () => console.log("Button clicked!")
        }, "Test Button")
      ]);
    };

    // Render the component
    const root = ReactDOM.createRoot(rootElement);
    root.render(React.createElement(TestComponent));

    console.log("✅ React component rendered");

    return true;
  } catch (error) {
    console.error("❌ React rendering test failed:", error);
    return false;
  }
}

// Run all tests
async function runAllTests() {
  console.log("🧪 Running dashboard diagnostic tests...");

  const importTestResult = await testImports();
  console.log("\nImport test result:", importTestResult ? "PASSED" : "FAILED");

  const domRenderingResult = testDomRendering();
  console.log("\nDOM rendering test result:", domRenderingResult ? "PASSED" : "FAILED");

  const reactRenderingResult = await testReactRendering();
  console.log("\nReact rendering test result:", reactRenderingResult ? "PASSED" : "FAILED");

  console.log("\n🧪 All tests completed");
}

// Export the test functions
export {
  testImports,
  testDomRendering,
  testReactRendering,
  runAllTests
};

// Expose to window for easy console access
if (typeof window !== 'undefined') {
  window.dashboardTests = {
    testImports,
    testDomRendering,
    testReactRendering,
    runAllTests
  };
}
