import React, { useState, useEffect } from 'react';
import puppeteerClient from '../lib/puppeteerClient';

// Fallback if import fails
if (!puppeteerClient || Object.keys(puppeteerClient).length === 0) {
  console.error('Failed to import puppeteerClient, creating fallback');
  
  // Create fallback puppeteerClient
  const fallbackClient = {
    isPuppeteerAvailable: () => {
      return typeof window !== 'undefined' && 
            typeof window.__MCP_CLIENT !== 'undefined' && 
            window.PUPPETEER_MCP_AVAILABLE === true;
    },
    
    navigate: async () => false,
    takeScreenshot: async () => null,
    click: async () => false,
    fill: async () => false,
    hover: async () => false,
    evaluate: async () => null,
    runDiagnosticTest: async () => ({
      success: false,
      message: 'Puppeteer client unavailable',
      results: []
    })
  };
  
  Object.assign(puppeteerClient, fallbackClient);
}

/**
 * Debug Panel Component
 * 
 * Provides debugging tools for the dashboard with Puppeteer integration
 * Allows testing UI interactions and viewing diagnostic information
 */
const DebugPanel = ({ onClose }) => {
  const [isExpanded, setIsExpanded] = useState(false);
  const [puppeteerAvailable, setPuppeteerAvailable] = useState(false);
  const [diagnosticResults, setDiagnosticResults] = useState(null);
  const [selectedElement, setSelectedElement] = useState('');
  const [isInspecting, setIsInspecting] = useState(false);
  const [lastScreenshot, setLastScreenshot] = useState(null);
  const [consoleMessages, setConsoleMessages] = useState([]);

  // Check if Puppeteer client is available on mount
  useEffect(() => {
    const checkPuppeteer = async () => {
      try {
        const available = await puppeteerClient.isPuppeteerAvailable();
        setPuppeteerAvailable(available);
        if (available) {
          console.log("Puppeteer client is available for debugging");
        } else {
          console.warn("Puppeteer client is not available - some debug features will be disabled");
        }
      } catch (error) {
        console.error("Error checking Puppeteer availability:", error);
        setPuppeteerAvailable(false);
      }
    };

    checkPuppeteer();

    // Set up console message capturing
    const originalConsoleLog = console.log;
    const originalConsoleError = console.error;
    const originalConsoleWarn = console.warn;

    // Store up to 50 most recent messages
    const MAX_MESSAGES = 50;
    window.__console_errors = [];

    console.log = (...args) => {
      const message = args.map(arg => 
        typeof arg === 'object' ? JSON.stringify(arg) : String(arg)
      ).join(' ');
      
      setConsoleMessages(prev => {
        const newMessages = [{type: 'log', content: message}, ...prev];
        return newMessages.slice(0, MAX_MESSAGES);
      });
      originalConsoleLog.apply(console, args);
    };

    console.error = (...args) => {
      const message = args.map(arg => 
        typeof arg === 'object' ? JSON.stringify(arg) : String(arg)
      ).join(' ');
      
      window.__console_errors.push(message);
      
      setConsoleMessages(prev => {
        const newMessages = [{type: 'error', content: message}, ...prev];
        return newMessages.slice(0, MAX_MESSAGES);
      });
      originalConsoleError.apply(console, args);
    };

    console.warn = (...args) => {
      const message = args.map(arg => 
        typeof arg === 'object' ? JSON.stringify(arg) : String(arg)
      ).join(' ');
      
      setConsoleMessages(prev => {
        const newMessages = [{type: 'warn', content: message}, ...prev];
        return newMessages.slice(0, MAX_MESSAGES);
      });
      originalConsoleWarn.apply(console, args);
    };

    return () => {
      // Restore original console methods on cleanup
      console.log = originalConsoleLog;
      console.error = originalConsoleError;
      console.warn = originalConsoleWarn;
    };
  }, []);

  // Take a screenshot of the dashboard
  const handleTakeScreenshot = async () => {
    if (!puppeteerAvailable) {
      console.error("Puppeteer not available for screenshot");
      return;
    }

    try {
      const screenshot = await puppeteerClient.takeScreenshot({
        name: 'dashboard_debug',
        width: 1024,
        height: 768
      });
      
      setLastScreenshot(screenshot);
      console.log("Screenshot taken successfully");
    } catch (error) {
      console.error("Error taking screenshot:", error);
    }
  };

  // Run diagnostic tests
  const handleRunDiagnostics = async () => {
    if (!puppeteerAvailable) {
      console.error("Puppeteer not available for diagnostics");
      return;
    }

    try {
      const results = await puppeteerClient.runDiagnosticTest();
      setDiagnosticResults(results);
      console.log("Diagnostic results:", results);
    } catch (error) {
      console.error("Error running diagnostics:", error);
      setDiagnosticResults({
        success: false,
        message: `Error: ${error.message}`,
        results: []
      });
    }
  };

  // Start element inspector
  const handleStartInspector = () => {
    if (!puppeteerAvailable) {
      console.error("Puppeteer not available for inspection");
      return;
    }
    
    setIsInspecting(true);
    
    // Inject inspector code - simplified to avoid complex DOM handling
    const script = `
      (function() {
        // Clean up any existing inspector first
        if (window.cleanupInspector) {
          window.cleanupInspector();
        }
      
        // Create overlay for selection
        const overlay = document.createElement('div');
        overlay.id = 'debug-inspector-overlay';
        overlay.style.position = 'fixed';
        overlay.style.top = '0';
        overlay.style.left = '0';
        overlay.style.width = '100%';
        overlay.style.height = '100%';
        overlay.style.pointerEvents = 'none';
        overlay.style.zIndex = '9999';
        document.body.appendChild(overlay);
        
        // Create highlight element
        let highlight = document.createElement('div');
        highlight.id = 'debug-inspector-highlight';
        highlight.style.position = 'fixed';
        highlight.style.border = '2px solid #f00';
        highlight.style.backgroundColor = 'rgba(255, 0, 0, 0.2)';
        highlight.style.pointerEvents = 'none';
        highlight.style.zIndex = '10000';
        highlight.style.display = 'none';
        document.body.appendChild(highlight);
        
        // Simple selector generation
        function getSimpleSelector(element) {
          if (element.id) return '#' + element.id;
          
          let selector = element.tagName.toLowerCase();
          if (element.className) {
            const classes = element.className.split(/\\s+/);
            for (const cls of classes) {
              if (cls) selector += '.' + cls;
            }
          }
          
          return selector;
        }
        
        // Setup event listeners
        function handleMouseOver(e) {
          const rect = e.target.getBoundingClientRect();
          highlight.style.top = rect.top + 'px';
          highlight.style.left = rect.left + 'px';
          highlight.style.width = rect.width + 'px';
          highlight.style.height = rect.height + 'px';
          highlight.style.display = 'block';
          
          window.__currentInspectedElement = {
            selector: getSimpleSelector(e.target),
            tagName: e.target.tagName,
            classes: e.target.className,
            id: e.target.id
          };
        }
        
        function handleClick(e) {
          e.preventDefault();
          e.stopPropagation();
          
          window.__selectedElement = getSimpleSelector(e.target);
          window.postMessage({ 
            type: 'DEBUG_INSPECTOR_SELECTED', 
            selector: window.__selectedElement 
          }, '*');
          
          window.cleanupInspector();
          return false;
        }
        
        // Set cursor and add event listeners
        document.body.style.cursor = 'crosshair';
        document.body.addEventListener('mouseover', handleMouseOver, true);
        document.body.addEventListener('click', handleClick, true);
        
        // Cleanup function
        window.cleanupInspector = function() {
          document.body.style.cursor = '';
          document.body.removeEventListener('mouseover', handleMouseOver, true);
          document.body.removeEventListener('click', handleClick, true);
          
          if (highlight && highlight.parentNode) {
            highlight.parentNode.removeChild(highlight);
          }
          if (overlay && overlay.parentNode) {
            overlay.parentNode.removeChild(overlay);
          }
          
          window.postMessage({ type: 'DEBUG_INSPECTOR_DONE' }, '*');
        };
      })();
    `;
    
    try {
      puppeteerClient.evaluate(script);
      
      // Listen for messages from the inspector
      const handleMessage = (event) => {
        if (event.data && event.data.type === 'DEBUG_INSPECTOR_SELECTED') {
          setSelectedElement(event.data.selector);
          setIsInspecting(false);
        } else if (event.data && event.data.type === 'DEBUG_INSPECTOR_DONE') {
          setIsInspecting(false);
        }
      };
      
      window.addEventListener('message', handleMessage);
      
      // Auto-timeout after 30 seconds
      const timeout = setTimeout(() => {
        if (isInspecting) {
          puppeteerClient.evaluate("window.cleanupInspector && window.cleanupInspector()");
          setIsInspecting(false);
        }
      }, 30000);
      
      // Return cleanup function
      return () => {
        window.removeEventListener('message', handleMessage);
        clearTimeout(timeout);
        puppeteerClient.evaluate("window.cleanupInspector && window.cleanupInspector()");
      };
    } catch (error) {
      console.error("Error starting inspector:", error);
      setIsInspecting(false);
    }
  };

  // Stop element inspector
  const handleStopInspector = () => {
    puppeteerClient.evaluate("window.cleanupInspector && window.cleanupInspector()");
    setIsInspecting(false);
  };

  // Run action on selected element
  const handleElementAction = async (action) => {
    if (!selectedElement || !puppeteerAvailable) return;
    
    try {
      switch (action) {
        case 'click':
          await puppeteerClient.click(selectedElement);
          console.log(`Clicked element: ${selectedElement}`);
          break;
        case 'hover':
          await puppeteerClient.hover(selectedElement);
          console.log(`Hovered element: ${selectedElement}`);
          break;
        case 'screenshot':
          const screenshot = await puppeteerClient.takeScreenshot({
            name: 'element_debug',
            selector: selectedElement
          });
          setLastScreenshot(screenshot);
          console.log(`Took screenshot of element: ${selectedElement}`);
          break;
        default:
          console.warn(`Unknown action: ${action}`);
      }
    } catch (error) {
      console.error(`Error performing ${action} on ${selectedElement}:`, error);
    }
  };

  // Styling for debug panel
  const panelStyle = {
    position: 'fixed',
    bottom: '10px',
    right: '10px',
    zIndex: 9999,
    backgroundColor: 'rgba(0, 0, 0, 0.85)',
    color: '#fff',
    padding: '10px',
    borderRadius: '5px',
    boxShadow: '0 0 10px rgba(0, 0, 0, 0.5)',
    maxWidth: isExpanded ? '600px' : '300px',
    maxHeight: isExpanded ? '80vh' : '40px',
    overflow: 'hidden',
    transition: 'all 0.3s ease',
    display: 'flex',
    flexDirection: 'column'
  };

  const headerStyle = {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: '10px',
    cursor: 'pointer'
  };

  const buttonStyle = {
    backgroundColor: '#3b82f6',
    color: 'white',
    border: 'none',
    borderRadius: '4px',
    padding: '8px 12px',
    margin: '5px',
    cursor: 'pointer',
    fontSize: '12px'
  };

  const disabledButtonStyle = {
    ...buttonStyle,
    backgroundColor: '#666',
    cursor: 'not-allowed'
  };

  const consoleStyle = {
    maxHeight: '150px',
    overflow: 'auto',
    backgroundColor: '#1a1a1a',
    padding: '10px',
    borderRadius: '4px',
    marginTop: '10px',
    fontSize: '12px',
    fontFamily: 'monospace'
  };

  const messageStyle = (type) => ({
    margin: '5px 0',
    color: type === 'error' ? '#ff6b6b' : type === 'warn' ? '#ffdd57' : '#a8c8ff'
  });

  const screenshotStyle = {
    maxWidth: '100%',
    maxHeight: '200px',
    objectFit: 'contain',
    marginTop: '10px'
  };

  return (
    <div style={panelStyle}>
      <div 
        style={headerStyle} 
        onClick={() => setIsExpanded(!isExpanded)}
      >
        <h3 style={{ margin: 0, fontSize: '14px' }}>Dashboard Debug Panel {puppeteerAvailable ? '🟢' : '🔴'}</h3>
        <div style={{ display: 'flex' }}>
          <button 
            style={{ ...buttonStyle, padding: '2px 8px', margin: '0 5px' }}
            onClick={(e) => {
              e.stopPropagation();
              setIsExpanded(!isExpanded);
            }}
          >
            {isExpanded ? '▼' : '▲'}
          </button>
          <button 
            style={{ ...buttonStyle, padding: '2px 8px', margin: '0' }}
            onClick={(e) => {
              e.stopPropagation();
              onClose();
            }}
          >
            ✕
          </button>
        </div>
      </div>

      {isExpanded && (
        <div style={{ overflow: 'auto', maxHeight: 'calc(80vh - 40px)' }}>
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: '5px' }}>
            <button 
              style={puppeteerAvailable ? buttonStyle : disabledButtonStyle}
              onClick={handleTakeScreenshot}
              disabled={!puppeteerAvailable}
            >
              Take Screenshot
            </button>
            
            <button 
              style={puppeteerAvailable ? buttonStyle : disabledButtonStyle}
              onClick={handleRunDiagnostics}
              disabled={!puppeteerAvailable}
            >
              Run Diagnostics
            </button>
            
            {isInspecting ? (
              <button 
                style={{ ...buttonStyle, backgroundColor: '#ef4444' }}
                onClick={handleStopInspector}
              >
                Cancel Inspection
              </button>
            ) : (
              <button 
                style={puppeteerAvailable ? buttonStyle : disabledButtonStyle}
                onClick={handleStartInspector}
                disabled={!puppeteerAvailable}
              >
                Select Element
              </button>
            )}
          </div>

          {selectedElement && (
            <div style={{ marginTop: '10px', padding: '10px', backgroundColor: 'rgba(255, 255, 255, 0.1)', borderRadius: '4px' }}>
              <div style={{ fontSize: '12px', marginBottom: '5px' }}>Selected: <code>{selectedElement}</code></div>
              <div style={{ display: 'flex', gap: '5px' }}>
                <button 
                  style={buttonStyle}
                  onClick={() => handleElementAction('click')}
                >
                  Click
                </button>
                <button 
                  style={buttonStyle}
                  onClick={() => handleElementAction('hover')}
                >
                  Hover
                </button>
                <button 
                  style={buttonStyle}
                  onClick={() => handleElementAction('screenshot')}
                >
                  Screenshot
                </button>
              </div>
            </div>
          )}

          {diagnosticResults && (
            <div style={{ marginTop: '10px', padding: '10px', backgroundColor: diagnosticResults.success ? 'rgba(34, 197, 94, 0.2)' : 'rgba(239, 68, 68, 0.2)', borderRadius: '4px' }}>
              <h4 style={{ margin: '0 0 5px 0', fontSize: '13px' }}>Diagnostic Results</h4>
              <div style={{ fontSize: '12px' }}>{diagnosticResults.message}</div>
              <ul style={{ margin: '5px 0', padding: '0 0 0 20px', fontSize: '12px' }}>
                {diagnosticResults.results.map((result, i) => (
                  <li key={i} style={{ color: result.success ? '#22c55e' : '#ef4444' }}>
                    {result.name}: {result.details}
                  </li>
                ))}
              </ul>
            </div>
          )}

          {lastScreenshot && (
            <div style={{ marginTop: '10px' }}>
              <h4 style={{ margin: '0 0 5px 0', fontSize: '13px' }}>Last Screenshot</h4>
              <img 
                src={`data:image/png;base64,${lastScreenshot}`} 
                alt="Dashboard Screenshot" 
                style={screenshotStyle}
              />
            </div>
          )}

          <div style={{ marginTop: '10px' }}>
            <h4 style={{ margin: '0 0 5px 0', fontSize: '13px' }}>Console Output</h4>
            <div style={consoleStyle}>
              {consoleMessages.length === 0 ? (
                <div style={{ color: '#999', fontStyle: 'italic' }}>No messages yet...</div>
              ) : (
                consoleMessages.map((msg, i) => (
                  <div key={i} style={messageStyle(msg.type)}>
                    [{msg.type}] {msg.content}
                  </div>
                ))
              )}
            </div>
          </div>

          <div style={{ marginTop: '10px', fontSize: '11px', color: '#999' }}>
            {puppeteerAvailable ? 
              'Puppeteer MCP server is connected' : 
              'Puppeteer MCP server is not available - some features are disabled'
            }
          </div>
        </div>
      )}
    </div>
  );
};

export default DebugPanel; 