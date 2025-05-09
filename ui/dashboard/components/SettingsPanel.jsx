import React, { useState } from 'react';

/**
 * SettingsPanel Component
 *
 * Displays configurable settings for the Cline AI extension
 * Allows users to toggle features and adjust token budgets
 * Provides tooltips with explanations for each setting
 */
const SettingsPanel = ({ settings, tokenBudgets, onUpdateSetting, onUpdateTokenBudget }) => {
  const [editingBudget, setEditingBudget] = useState(null);
  const [budgetValue, setBudgetValue] = useState('');
  const [error, setError] = useState(null);

  if (!settings || !tokenBudgets) {
    return null;
  }

  // Toggle a boolean setting
  const handleToggleSetting = (setting) => {
    if (typeof onUpdateSetting === 'function') {
      onUpdateSetting(setting, !settings[setting]);
    }
  };

  // Start editing a token budget
  const handleStartEditBudget = (budgetType) => {
    setEditingBudget(budgetType);
    setBudgetValue(tokenBudgets[budgetType].budget.toString());
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
    if (typeof onUpdateTokenBudget === 'function') {
      onUpdateTokenBudget(budgetType, value);
    }

    // Reset the editing state
    setEditingBudget(null);
    setBudgetValue('');
    setError(null);
  };

  // Format large numbers with commas
  const formatNumber = (num) => {
    return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
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
                    checked={settings[setting.id] || false}
                    onChange={() => handleToggleSetting(setting.id)}
                  />
                  <span className="toggle-slider"></span>
                </label>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Token Budgets Section */}
      <div className="settings-section">
        <h3>Token Budgets</h3>

        <div className="budgets-list">
          {budgetCategories.map((category) => {
            const budget = tokenBudgets[category.id];
            if (!budget) return null;

            const isEditing = editingBudget === category.id;
            const percentUsed = Math.round((budget.used / budget.budget) * 100);

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
                        <span className="total" onClick={() => handleStartEditBudget(category.id)}>{formatNumber(budget.budget)}</span>
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
                        placeholder="Enter budget"
                        autoFocus
                      />
                      <div className="edit-actions">
                        <button className="save-button" onClick={() => handleSaveTokenBudget(category.id)}>Save</button>
                        <button className="cancel-button" onClick={handleCancelEditBudget}>Cancel</button>
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

      <style jsx>{`
        .settings-panel {
          background-color: var(--card-background);
          border-radius: var(--border-radius-md);
          box-shadow: var(--shadow-sm);
          padding: 1.5rem;
          height: 100%;
          display: flex;
          flex-direction: column;
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
        }

        .settings-list, .budgets-list {
          display: flex;
          flex-direction: column;
          gap: 1rem;
        }

        .setting-item {
          display: flex;
          justify-content: space-between;
          align-items: flex-start;
          gap: 1rem;
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
          color: var(--text-secondary);
        }

        .setting-control {
          padding-top: 0.25rem;
        }

        /* Toggle Switch Styles */
        .toggle-switch {
          position: relative;
          display: inline-block;
          width: 40px;
          height: 24px;
        }

        .toggle-switch input {
          opacity: 0;
          width: 0;
          height: 0;
        }

        .toggle-slider {
          position: absolute;
          top: 0;
          left: 0;
          right: 0;
          bottom: 0;
          background-color: var(--background-color);
          border: 1px solid var(--border-color);
          border-radius: 34px;
          transition: .4s;
          cursor: pointer;
        }

        .toggle-slider:before {
          position: absolute;
          content: "";
          height: 16px;
          width: 16px;
          left: 3px;
          bottom: 3px;
          background-color: var(--text-secondary);
          border-radius: 50%;
          transition: .4s;
        }

        .toggle-switch input:checked + .toggle-slider {
          background-color: var(--primary-color);
          border-color: var(--primary-color);
        }

        .toggle-switch input:checked + .toggle-slider:before {
          transform: translateX(16px);
          background-color: white;
        }

        /* Budget Item Styles */
        .budget-item {
          display: flex;
          flex-direction: column;
          padding: 0.75rem;
          background-color: var(--background-color);
          border-radius: var(--border-radius-sm);
        }

        .budget-info {
          display: flex;
          flex-direction: column;
          margin-bottom: 0.5rem;
        }

        .budget-label {
          font-weight: 500;
          margin-bottom: 0.25rem;
        }

        .budget-description {
          font-size: 0.875rem;
          color: var(--text-secondary);
        }

        .budget-values {
          display: flex;
          flex-direction: column;
          gap: 0.5rem;
        }

        .budget-amount {
          display: flex;
          align-items: center;
          font-size: 0.875rem;
        }

        .budget-amount .used {
          font-weight: 500;
        }

        .budget-amount .separator {
          margin: 0 0.25rem;
          color: var(--text-secondary);
        }

        .budget-amount .total {
          cursor: pointer;
          text-decoration: underline;
          text-decoration-style: dotted;
          text-underline-offset: 2px;
        }

        .edit-icon {
          margin-left: 0.375rem;
          cursor: pointer;
          color: var(--primary-color);
          font-size: 0.75rem;
        }

        .budget-progress-container {
          height: 0.375rem;
          background-color: var(--background-color-light);
          border-radius: var(--border-radius-sm);
          overflow: hidden;
        }

        .budget-progress {
          height: 100%;
          border-radius: var(--border-radius-sm);
          transition: width 0.3s ease;
        }

        .budget-progress.low {
          background-color: var(--success-color);
        }

        .budget-progress.medium {
          background-color: var(--warning-color);
        }

        .budget-progress.high {
          background-color: var(--error-color);
        }

        /* Budget Edit Styles */
        .budget-edit {
          display: flex;
          flex-direction: column;
          gap: 0.5rem;
        }

        .budget-edit input {
          padding: 0.375rem 0.5rem;
          border: 1px solid var(--border-color);
          border-radius: var(--border-radius-sm);
          font-size: 0.875rem;
        }

        .budget-edit input:focus {
          border-color: var(--primary-color);
          outline: none;
        }

        .edit-actions {
          display: flex;
          gap: 0.5rem;
        }

        .save-button, .cancel-button {
          padding: 0.25rem 0.5rem;
          border-radius: var(--border-radius-sm);
          font-size: 0.75rem;
          cursor: pointer;
          border: none;
        }

        .save-button {
          background-color: var(--primary-color);
          color: white;
        }

        .cancel-button {
          background-color: var(--background-color-light);
          border: 1px solid var(--border-color);
        }

        .error-message {
          color: var(--error-color);
          font-size: 0.75rem;
          margin-top: 0.25rem;
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

export default SettingsPanel;
