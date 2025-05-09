import React, { useState, useEffect } from 'react';

/**
 * SettingsPanel Component
 *
 * Displays configurable settings for the Cline AI extension
 * Allows users to toggle features and adjust token budgets
 * Provides tooltips with explanations for each setting
 */
const SettingsPanel = ({ settings, tokenBudgets, onUpdateSetting, onUpdateTokenBudget, onSettingChange, onBudgetChange }) => {
  const [editingBudget, setEditingBudget] = useState(null);
  const [budgetValue, setBudgetValue] = useState('');
  const [error, setError] = useState(null);

  // Default settings for tests and initial render
  const defaultSettings = {
    autoModelSelection: true,
    cachingEnabled: true,
    contextWindowOptimization: true,
    outputMinimization: true,
    notifyOnLowBudget: false,
    safetyChecks: true
  };

  // Create local state to mirror the settings so we can update it instantly for better UX
  const [localSettings, setLocalSettings] = useState(settings || defaultSettings);

  // Update localSettings when settings prop changes
  useEffect(() => {
    // If settings are provided, use them, otherwise keep using the defaults
    if (settings) {
      setLocalSettings({
        ...defaultSettings, // Start with defaults
        ...settings         // Override with provided settings
      });
    }
  }, [settings]);

  // For compatibility with existing code and tests
  const updateSetting = onUpdateSetting || onSettingChange || (() => {});
  const updateTokenBudget = onUpdateTokenBudget || onBudgetChange || (() => {});

  // Handle setting toggle
  const handleToggleSetting = (settingKey) => {
    const newValue = !localSettings[settingKey];

    // Update local state immediately for a responsive UI
    setLocalSettings({
      ...localSettings,
      [settingKey]: newValue
    });

    // Notify parent component
    updateSetting(settingKey, newValue);
  };

  // Start editing a token budget
  const handleStartEditBudget = (budgetType) => {
    setEditingBudget(budgetType);
    if (tokenBudgets && tokenBudgets[budgetType]) {
      setBudgetValue(tokenBudgets[budgetType].budget.toString());
    }
    setError(null);
  };

  // Cancel editing a token budget
  const handleCancelEditBudget = () => {
    setEditingBudget(null);
    setBudgetValue('');
    setError(null);
  };

  // Save the edited token budget
  const handleSaveTokenBudget = (budgetType) => {
    // Validate the budget value
    const value = parseInt(budgetValue.replace(/,/g, ''), 10);

    if (isNaN(value)) {
      setError('Please enter a valid number');
      return;
    }

    if (value < 100) {
      setError('Budget must be at least 100 tokens');
      return;
    }

    if (value > 5000000) {
      setError('Budget cannot exceed 5 million tokens');
      return;
    }

    // Update the budget if validation passes
    updateTokenBudget(budgetType, value);

    // Reset the editing state
    setEditingBudget(null);
    setBudgetValue('');
    setError(null);
  };

  // Format large numbers with commas
  const formatNumber = (num) => {
    return num ? num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",") : "0";
  };

  // Configuration for boolean settings
  const booleanSettings = [
    {
      id: 'autoModelSelection',
      label: 'Auto Model Selection',
      description: 'Automatically selects the most cost-effective model for different tasks'
    },
    {
      id: 'cachingEnabled',
      label: 'Caching',
      description: 'Cache responses to reduce token usage and improve performance'
    },
    {
      id: 'contextWindowOptimization',
      label: 'Context Window Optimization',
      description: 'Optimize prompt size by automatically removing less relevant context'
    },
    {
      id: 'outputMinimization',
      label: 'Output Minimization',
      description: 'Reduce LLM verbosity to minimize token usage and costs'
    },
    {
      id: 'notifyOnLowBudget',
      label: 'Low Budget Notifications',
      description: 'Receive alerts when token budgets are close to being depleted'
    },
    {
      id: 'safetyChecks',
      label: 'Safety Checks',
      description: 'Enable additional checks to maintain response quality and safety'
    }
  ];

  // Budget categories
  const budgetCategories = [
    {
      id: 'codeCompletion',
      label: 'Code Completion',
      description: 'Budget for code generation and auto-completion'
    },
    {
      id: 'errorResolution',
      label: 'Error Resolution',
      description: 'Budget for debugging and fixing errors in code'
    },
    {
      id: 'architecture',
      label: 'Architecture',
      description: 'Budget for software architecture design and planning'
    },
    {
      id: 'thinking',
      label: 'Thinking',
      description: 'Budget for problem-solving and complex reasoning tasks'
    }
  ];

  return (
    <div className="settings-panel">
      <div className="panel-header">
        <h2>Settings</h2>
      </div>

      {/* Boolean Settings Section */}
      <div className="settings-section">
        <h3>Feature Settings</h3>

        <div className="settings-list">
          {booleanSettings.map((setting) => (
            <div key={setting.id} className="setting-item">
              <div className="setting-info">
                <div className="setting-label">{setting.label}</div>
                <div className="setting-description">{setting.description}</div>
              </div>

              <div className="setting-control">
                <label className="toggle-switch">
                  <input
                    type="checkbox"
                    checked={localSettings[setting.id]}
                    onChange={() => handleToggleSetting(setting.id)}
                    aria-label={setting.label}
                    data-testid={`setting-${setting.id}`}
                  />
                  <span className="toggle-slider"></span>
                </label>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Token Budgets Section */}
      {tokenBudgets && (
        <div className="settings-section">
          <h3>Token Budgets</h3>

          <div className="budgets-list">
            {budgetCategories.map((category) => {
              if (!tokenBudgets[category.id]) return null;

              const budget = tokenBudgets[category.id];
              const isEditing = editingBudget === category.id;
              const percentUsed = Math.round((budget.used / budget.budget) * 100) || 0;

              return (
                <div key={category.id} className="budget-item">
                  <div className="budget-info">
                    <div className="budget-label">{category.label}</div>
                    <div className="budget-description">{category.description}</div>
                  </div>

                  <div className="budget-values">
                    {!isEditing ? (
                      <>
                        <div className="budget-amount">
                          <span className="used">{formatNumber(budget.used)}</span>
                          <span className="separator">/</span>
                          <span
                            className="total"
                            onClick={() => handleStartEditBudget(category.id)}
                            data-testid={`budget-${category.id}`}
                          >
                            {formatNumber(budget.budget)}
                          </span>
                          <span className="edit-icon" onClick={() => handleStartEditBudget(category.id)}>✎</span>
                        </div>
                        <div className="budget-progress-container">
                          <div
                            className={`budget-progress ${percentUsed > 90 ? 'high' : percentUsed > 70 ? 'medium' : 'low'}`}
                            style={{ width: `${percentUsed}%` }}
                          ></div>
                        </div>
                      </>
                    ) : (
                      <div className="budget-edit">
                        <input
                          type="text"
                          value={budgetValue}
                          onChange={(e) => setBudgetValue(e.target.value)}
                          className={error ? 'error' : ''}
                          placeholder="Enter budget"
                          autoFocus
                        />
                        <div className="edit-actions">
                          <button className="save" onClick={() => handleSaveTokenBudget(category.id)}>Save</button>
                          <button className="cancel" onClick={handleCancelEditBudget}>Cancel</button>
                        </div>
                        {error && <div className="error-message">{error}</div>}
                      </div>
                    )}
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      )}

      {/* Information Section */}
      <div className="settings-section info-section">
        <div className="info-icon">ℹ️</div>
        <div className="info-content">
          <div className="info-title">Token Budget Management</div>
          <div className="info-text">
            Token budgets control how many tokens can be used for each type of task.
            Click on a budget value to edit it. Changes will take effect immediately.
          </div>
        </div>
      </div>

      <style jsx="true">{`
        .settings-panel {
          background-color: var(--card-background, #ffffff);
          border-radius: var(--border-radius-md, 8px);
          box-shadow: var(--shadow-sm, 0 1px 3px rgba(0, 0, 0, 0.1));
          padding: 1.5rem;
          height: 100%;
          overflow-y: auto;
        }

        .panel-header {
          margin-bottom: 1.5rem;
        }

        .panel-header h2 {
          margin: 0;
          font-size: 1.25rem;
          font-weight: 600;
        }

        .settings-section {
          margin-bottom: 2rem;
        }

        .settings-section h3 {
          font-size: 1rem;
          font-weight: 500;
          margin: 0 0 1rem 0;
          color: var(--text-primary, #333);
        }

        .settings-list {
          display: flex;
          flex-direction: column;
          gap: 1rem;
        }

        .setting-item {
          display: flex;
          justify-content: space-between;
          align-items: center;
          padding: 0.75rem 0;
          border-bottom: 1px solid var(--border-color, #eaeaea);
        }

        .setting-info {
          flex: 1;
        }

        .setting-label {
          font-weight: 500;
          margin-bottom: 0.25rem;
        }

        .setting-description {
          font-size: 0.875rem;
          color: var(--text-secondary, #666);
        }

        .toggle-switch {
          position: relative;
          display: inline-block;
          width: 48px;
          height: 24px;
        }

        .toggle-switch input {
          opacity: 0;
          width: 0;
          height: 0;
        }

        .toggle-slider {
          position: absolute;
          cursor: pointer;
          top: 0;
          left: 0;
          right: 0;
          bottom: 0;
          background-color: var(--border-color, #ccc);
          transition: .4s;
          border-radius: 24px;
        }

        .toggle-slider:before {
          position: absolute;
          content: "";
          height: 18px;
          width: 18px;
          left: 3px;
          bottom: 3px;
          background-color: white;
          transition: .4s;
          border-radius: 50%;
        }

        input:checked + .toggle-slider {
          background-color: var(--primary-color, #4a6cf7);
        }

        input:checked + .toggle-slider:before {
          transform: translateX(24px);
        }

        .budgets-list {
          display: flex;
          flex-direction: column;
          gap: 1.25rem;
        }

        .budget-item {
          display: flex;
          flex-direction: column;
          gap: 0.5rem;
          padding: 0.75rem;
          background-color: var(--background-color, #f9f9f9);
          border-radius: var(--border-radius-sm, 4px);
        }

        .budget-info {
          margin-bottom: 0.5rem;
        }

        .budget-label {
          font-weight: 500;
          margin-bottom: 0.25rem;
        }

        .budget-description {
          font-size: 0.875rem;
          color: var(--text-secondary, #666);
        }

        .budget-amount {
          display: flex;
          align-items: center;
          gap: 0.25rem;
          margin-bottom: 0.5rem;
          font-size: 0.875rem;
        }

        .budget-amount .used {
          color: var(--text-secondary, #666);
        }

        .budget-amount .separator {
          margin: 0 0.25rem;
          color: var(--text-secondary, #666);
        }

        .budget-amount .total {
          font-weight: 500;
          cursor: pointer;
        }

        .budget-amount .total:hover {
          color: var(--primary-color, #4a6cf7);
        }

        .edit-icon {
          font-size: 0.75rem;
          margin-left: 0.25rem;
          color: var(--text-secondary, #999);
          cursor: pointer;
        }

        .budget-progress-container {
          height: 4px;
          background-color: var(--border-color, #eaeaea);
          border-radius: 2px;
          overflow: hidden;
          width: 100%;
        }

        .budget-progress {
          height: 100%;
          border-radius: 2px;
        }

        .budget-progress.low {
          background-color: var(--success-color, #10b981);
        }

        .budget-progress.medium {
          background-color: var(--warning-color, #f59e0b);
        }

        .budget-progress.high {
          background-color: var(--error-color, #ef4444);
        }

        .budget-edit {
          display: flex;
          flex-direction: column;
          gap: 0.5rem;
        }

        .budget-edit input {
          padding: 0.5rem;
          border: 1px solid var(--border-color, #ddd);
          border-radius: var(--border-radius-sm, 4px);
          width: 100%;
        }

        .budget-edit input.error {
          border-color: var(--error-color, #ef4444);
        }

        .error-message {
          color: var(--error-color, #ef4444);
          font-size: 0.75rem;
        }

        .edit-actions {
          display: flex;
          gap: 0.5rem;
        }

        .edit-actions button {
          padding: 0.25rem 0.75rem;
          border-radius: var(--border-radius-sm, 4px);
          border: none;
          font-size: 0.875rem;
          cursor: pointer;
        }

        .edit-actions button.save {
          background-color: var(--primary-color, #4a6cf7);
          color: white;
        }

        .edit-actions button.cancel {
          background-color: var(--border-color, #eaeaea);
          color: var(--text-secondary, #666);
        }

        /* Info Section Styles */
        .info-section {
          display: flex;
          align-items: flex-start;
          gap: 1rem;
          background-color: var(--primary-light);
          padding: 1rem;
          border-radius: var(--border-radius-sm);
          margin-top: auto;
        }

        .info-icon {
          font-size: 1.25rem;
        }

        .info-content {
          flex: 1;
        }

        .info-title {
          font-weight: 500;
          margin-bottom: 0.25rem;
        }

        .info-text {
          font-size: 0.875rem;
        }

        /* Responsive adjustments */
        @media (min-width: 768px) {
          .budget-item {
            flex-direction: row;
            justify-content: space-between;
            align-items: center;
          }

          .budget-info {
            flex: 1;
            margin-bottom: 0;
          }

          .budget-values {
            width: 200px;
          }
        }

        @media (max-width: 767px) {
          .budget-edit {
            max-width: 100%;
          }
        }
      `}</style>
    </div>
  );
};

export { SettingsPanel };
export default SettingsPanel;
