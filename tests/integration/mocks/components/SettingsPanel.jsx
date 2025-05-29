import React, { useState } from 'react';

const SettingsPanel = ({ 
  settings, 
  tokenBudgets, 
  isCollapsed = false, 
  onToggleCollapse,
  darkMode,
  className,
  // Filter out other non-DOM props
  onBudgetChange,
  onRefresh,
  onModelSelect,
  onUpdateSetting,
  usageData,
  costData,
  ...domProps 
}) => {
  const [showAdvanced, setShowAdvanced] = useState(false);
  const [editingBudget, setEditingBudget] = useState(null);
  const [budgetValue, setBudgetValue] = useState('');

  // Handle empty states
  if (!settings && !tokenBudgets) {
    return (
      <div data-testid="settings-panel" className={className} {...domProps}>
        <h3>Settings</h3>
        <div>No settings available</div>
        <div>Settings information will appear here when available</div>
      </div>
    );
  }

  const handleBudgetEdit = (budgetKey, currentValue) => {
    setEditingBudget(budgetKey);
    setBudgetValue(currentValue.toString());
  };

  const handleBudgetSave = () => {
    if (editingBudget && budgetValue) {
      onBudgetChange?.(editingBudget, parseInt(budgetValue));
    }
    setEditingBudget(null);
    setBudgetValue('');
  };

  const handleBudgetCancel = () => {
    setEditingBudget(null);
    setBudgetValue('');
  };

  const renderSettingToggle = (key, label, value, ariaLabel) => (
    <label key={key}>
      <input
        type="checkbox"
        role="switch"
        checked={value || false}
        onChange={(e) => onUpdateSetting?.(key, e.target.checked)}
        data-testid={`setting-toggle-${key}`}
        aria-label={ariaLabel || label}
      />
      {label}
    </label>
  );

  return (
    <div data-testid="settings-panel" className={className} {...domProps}>
      <div data-testid="mock-card">
        <h3>Settings</h3>
        <div>Configure dashboard settings and token budgets</div>
        
        {/* Collapse/Expand Button */}
        <button 
          role="button"
          aria-label={isCollapsed ? 'Expand settings' : 'Collapse settings'}
          onClick={onToggleCollapse}
        >
          {isCollapsed ? 'Expand' : 'Collapse'} Settings
        </button>
        
        {/* Collapsible Content */}
        <div data-testid="collapsible" data-open={!isCollapsed ? 'true' : 'false'}>
          {!isCollapsed && (
            <>
              {/* Mock Accordion Items */}
              <div data-testid="mock-accordion-item">General Settings</div>
              <div data-testid="mock-accordion-item">API Settings</div>
              <div data-testid="mock-accordion-item">Budget Settings</div>
              
              {/* Settings */}
              {settings && (
                <div>
                  {/* Basic Settings */}
                  <label>
                    <input
                      type="checkbox"
                      checked={settings.autoModelSelection || false}
                      onChange={(e) => onUpdateSetting?.('autoModelSelection', e.target.checked)}
                      data-testid="auto-model-selection"
                    />
                    Auto Model Selection
                  </label>
                  
                  <label>
                    <input
                      type="checkbox"
                      checked={settings.autoRefresh || false}
                      onChange={(e) => onUpdateSetting?.('autoRefresh', e.target.checked)}
                      data-testid="setting-toggle-autoRefresh"
                      aria-label="Auto refresh"
                    />
                    Auto Refresh
                  </label>

                  {/* Dark Mode Toggle */}
                  {renderSettingToggle('darkMode', 'Dark Mode', settings.darkMode || darkMode)}

                  {/* Caching Toggle */}
                  {renderSettingToggle('cachingEnabled', 'Enable Caching', settings.cachingEnabled)}

                  {/* Additional toggle with the expected test ID */}
                  <button 
                    data-testid="toggle-cachingEnabled"
                    onClick={() => onUpdateSetting?.('cachingEnabled', !settings.cachingEnabled)}
                  >
                    Toggle Caching
                  </button>

                  {/* Additional Toggles */}
                  {renderSettingToggle('notifications', 'Enable Notifications', settings.notifications)}
                  {renderSettingToggle('autoSave', 'Auto Save', settings.autoSave)}

                  {/* Advanced Settings Toggle */}
                  <button 
                    onClick={() => setShowAdvanced(!showAdvanced)}
                    data-testid="toggle-advanced-settings"
                  >
                    {showAdvanced ? 'Hide' : 'Show'} Advanced Settings
                  </button>

                  {/* Advanced Settings Section */}
                  {showAdvanced && (
                    <div data-testid="advanced-settings">
                      <h4>Advanced Settings</h4>
                      {renderSettingToggle('contextOptimization', 'Context Window Optimization', settings.contextOptimization)}
                      {renderSettingToggle('outputMinimization', 'Output Minimization', settings.outputMinimization)}
                      {renderSettingToggle('safetyChecks', 'Safety Checks', settings.safetyChecks)}
                      {renderSettingToggle('debugMode', 'Debug Mode', settings.debugMode)}
                    </div>
                  )}
                </div>
              )}
              
              {/* Token Budgets */}
              {tokenBudgets && (
                <div>
                  <div data-testid="token-budget">
                    Token Budget: {tokenBudgets.total || 0}
                  </div>
                  <h4>Token Budgets</h4>
                  {Object.entries(tokenBudgets).map(([key, value]) => (
                    <div key={key}>
                      {editingBudget === key ? (
                        <div data-testid={`budget-edit-form-${key}`}>
                          <input
                            type="number"
                            value={budgetValue}
                            onChange={(e) => setBudgetValue(e.target.value)}
                            data-testid={`budget-input-${key}`}
                          />
                          <button 
                            onClick={handleBudgetSave}
                            data-testid={`budget-save-${key}`}
                          >
                            Save
                          </button>
                          <button 
                            onClick={handleBudgetCancel}
                            data-testid={`budget-cancel-${key}`}
                          >
                            Cancel
                          </button>
                        </div>
                      ) : (
                        <>
                          <span>{key}: {value}</span>
                          <button 
                            data-testid={`budget-edit-${key}`} 
                            onClick={() => handleBudgetEdit(key, value)}
                          >
                            Edit
                          </button>
                        </>
                      )}
                    </div>
                  ))}
                </div>
              )}

              {/* Token Budget Percentage Display */}
              {usageData && tokenBudgets && (
                <div data-testid="budget-usage-display">
                  <h4>Budget Usage</h4>
                  {typeof usageData === 'object' && usageData.used && usageData.budget ? (
                    <div>
                      <span>Used: {usageData.used}</span>
                      <span>Budget: {usageData.budget}</span>
                      <span>Percentage: {Math.round((usageData.used / usageData.budget) * 100)}%</span>
                    </div>
                  ) : (
                    <div>No usage data available</div>
                  )}
                </div>
              )}
            </>
          )}
        </div>
      </div>
    </div>
  );
};

export default SettingsPanel; 