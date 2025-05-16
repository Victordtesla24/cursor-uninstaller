import React from 'react';

/**
 * Fallback components
 * Used as a last resort when the real components cannot be loaded
 */

export const FallbackMetricsPanel = () => (
  <div className="fallback-component">
    <h3>Metrics Panel (Fallback)</h3>
    <p>The actual metrics panel component could not be loaded.</p>
  </div>
);

export const FallbackTokenUtilization = () => (
  <div className="fallback-component">
    <h3>Token Utilization (Fallback)</h3>
    <p>The actual token utilization component could not be loaded.</p>
  </div>
);

export const FallbackCostTracker = () => (
  <div className="fallback-component">
    <h3>Cost Tracker (Fallback)</h3>
    <p>The actual cost tracker component could not be loaded.</p>
  </div>
);

export const FallbackUsageStats = () => (
  <div className="fallback-component">
    <h3>Usage Stats (Fallback)</h3>
    <p>The actual usage stats component could not be loaded.</p>
  </div>
);

export const FallbackModelSelector = () => (
  <div className="fallback-component">
    <h3>Model Selector (Fallback)</h3>
    <p>The actual model selector component could not be loaded.</p>
  </div>
);

export const FallbackSettingsPanel = () => (
  <div className="fallback-component">
    <h3>Settings Panel (Fallback)</h3>
    <p>The actual settings panel component could not be loaded.</p>
  </div>
);

// Fallback style
const FallbackStyle = () => (
  <style jsx="true">{`
    .fallback-component {
      padding: 20px;
      margin: 10px 0;
      background-color: #fff3cd;
      border: 1px solid #ffeeba;
      border-radius: 4px;
      color: #856404;
    }

    .fallback-component h3 {
      margin-top: 0;
      font-size: 18px;
    }
  `}</style>
);

/**
 * FallbackDashboard component
 *
 * This component serves as a reliable fallback when the main dashboard encounters errors
 * It uses minimal dependencies and provides basic information while diagnostic tools run
 */
const FallbackDashboard = ({ errorDetails = null }) => {
  return (
    <div style={{
      fontFamily: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif',
      maxWidth: '1200px',
      margin: '0 auto',
      padding: '20px',
      backgroundColor: '#f5f7fa',
      borderRadius: '8px',
      boxShadow: '0 1px 3px rgba(0, 0, 0, 0.1)'
    }}>
      <div style={{
        display: 'flex',
        justifyContent: 'space-between',
        alignItems: 'center',
        paddingBottom: '16px',
        borderBottom: '1px solid #e2e8f0',
        marginBottom: '24px'
      }}>
        <div style={{
          fontSize: '24px',
          fontWeight: '600',
          color: '#1e293b'
        }}>
          Cline AI Dashboard (Fallback Mode)
        </div>
        <button
          onClick={() => window.location.reload()}
          style={{
            padding: '8px 16px',
            background: '#3b82f6',
            color: 'white',
            border: 'none',
            borderRadius: '4px',
            cursor: 'pointer'
          }}
        >
          Reload Dashboard
        </button>
      </div>

      <div style={{
        backgroundColor: 'white',
        borderRadius: '6px',
        padding: '16px',
        marginBottom: '16px',
        boxShadow: '0 1px 2px rgba(0, 0, 0, 0.05)'
      }}>
        <h3 style={{ marginTop: 0, fontSize: '18px', color: '#334155' }}>Dashboard Status</h3>
        <p>The dashboard is currently running in fallback mode due to an error loading the main application.</p>
        <p>Please check the browser console for more detailed error information or click the "Show Debug Info" button.</p>

        {errorDetails && (
          <div style={{
            backgroundColor: '#fee2e2',
            borderRadius: '4px',
            padding: '12px',
            marginTop: '12px',
            color: '#7f1d1d'
          }}>
            <strong>Error Details:</strong>
            <p>{errorDetails?.message || 'Unknown error'}</p>
            {errorDetails?.stack && (
              <pre style={{
                overflow: 'auto',
                fontSize: '12px',
                padding: '8px',
                backgroundColor: 'rgba(0, 0, 0, 0.05)',
                borderRadius: '4px'
              }}>
                {errorDetails.stack}
              </pre>
            )}
          </div>
        )}
      </div>

      <div style={{
        backgroundColor: 'white',
        borderRadius: '6px',
        padding: '16px',
        marginBottom: '16px',
        boxShadow: '0 1px 2px rgba(0, 0, 0, 0.05)'
      }}>
        <h3 style={{ marginTop: 0, fontSize: '18px', color: '#334155' }}>Mock Metrics</h3>
        <p>Total Tokens: 450,000</p>
        <p>Estimated Cost: $45.20</p>
        <p>Active Models: 3</p>
      </div>

      <div style={{
        backgroundColor: 'white',
        borderRadius: '6px',
        padding: '16px',
        marginBottom: '16px',
        boxShadow: '0 1px 2px rgba(0, 0, 0, 0.05)'
      }}>
        <h3 style={{ marginTop: 0, fontSize: '18px', color: '#334155' }}>Token Usage</h3>
        <ul>
          <li>Code Completion: 200,000 tokens</li>
          <li>Error Resolution: 150,000 tokens</li>
          <li>Architecture: 80,000 tokens</li>
          <li>Thinking: 20,000 tokens</li>
        </ul>
      </div>

      <div style={{
        backgroundColor: 'white',
        borderRadius: '6px',
        padding: '16px',
        marginBottom: '16px',
        boxShadow: '0 1px 2px rgba(0, 0, 0, 0.05)'
      }}>
        <h3 style={{ marginTop: 0, fontSize: '18px', color: '#334155' }}>Actions</h3>
        <button
          onClick={() => window.showDashboardDebug && window.showDashboardDebug()}
          style={{
            padding: '8px 16px',
            marginRight: '8px',
            background: '#3b82f6',
            color: 'white',
            border: 'none',
            borderRadius: '4px',
            cursor: 'pointer'
          }}
        >
          Show Debug Info
        </button>
        <button
          onClick={() => window.location.href = 'debug-test.html'}
          style={{
            padding: '8px 16px',
            background: '#3b82f6',
            color: 'white',
            border: 'none',
            borderRadius: '4px',
            cursor: 'pointer'
          }}
        >
          Run Diagnostic Tests
        </button>
      </div>
    </div>
  );
};

export default FallbackDashboard;
