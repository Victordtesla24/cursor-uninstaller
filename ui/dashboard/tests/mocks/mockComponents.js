import React from 'react';

// Mock UI components for testing
export const MockSettingsPanel = ({
  settings = {},
  tokenBudgets = {},
  onSettingChange = () => {},
  onBudgetChange = () => {},
  ...props
}) => (
  <div data-testid="settings-panel" className="mock-settings-panel">
    <h2>Settings</h2>
    {/* Minimal settings render for testing */}
    <div className="settings-items">
      {settings && Object.keys(settings).map(key => (
        <div key={key} className="setting-item" data-setting-id={key}>
          <span>{key}</span>
          <input
            type="checkbox"
            checked={settings[key]}
            onChange={() => onSettingChange(key, !settings[key])}
            data-testid={`setting-${key}`}
          />
        </div>
      ))}
    </div>

    {/* Minimal token budgets render for testing */}
    <div className="budget-items">
      {tokenBudgets && Object.keys(tokenBudgets).map(key => (
        <div key={key} className="budget-item" data-budget-id={key}>
          <span>{key}</span>
          <span>{tokenBudgets[key]}</span>
          <button
            onClick={() => onBudgetChange(key, tokenBudgets[key] + 100)}
            data-testid={`budget-edit-${key}`}
          >
            Edit
          </button>
        </div>
      ))}
    </div>
  </div>
);

// Add other mock components as needed
