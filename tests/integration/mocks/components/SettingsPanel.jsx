import React from 'react';

const SettingsPanel = ({ settings, onSettingChange, ...props }) => (
  <div data-testid="settings-panel" {...props}>
    <h3>Settings Panel Mock</h3>
    {settings && (
      <div>
        <label>
          <input
            type="checkbox"
            checked={settings.autoModelSelection || false}
            onChange={(e) => onSettingChange?.('autoModelSelection', e.target.checked)}
            data-testid="auto-model-selection"
          />
          Auto Model Selection
        </label>
        <div data-testid="token-budget">
          Token Budget: {settings.tokenBudget || 0}
        </div>
      </div>
    )}
  </div>
);

export default SettingsPanel; 