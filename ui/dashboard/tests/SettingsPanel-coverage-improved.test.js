/**
 * Improved test coverage for SettingsPanel component
 * Focus on branch coverage to improve it above 85%
 */
import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import '@testing-library/jest-dom';
import SettingsPanel from '../components/SettingsPanel';

describe('SettingsPanel Component Branch Coverage', () => {
  // Sample data for testing
  const settings = {
    autoModelSelection: true,
    cachingEnabled: false,
    contextWindowOptimization: true,
    outputMinimization: false,
    notifyOnLowBudget: true,
    safetyChecks: true
  };

  const tokenBudgets = {
    codeCompletion: {
      budget: 5000,
      used: 2500
    },
    errorResolution: {
      budget: 10000,
      used: 1000
    },
    architecture: {
      budget: 8000,
      used: 3000
    },
    thinking: {
      budget: 15000,
      used: 7500
    }
  };

  test('renders all settings correctly', () => {
    const mockUpdateSetting = jest.fn();
    const mockUpdateTokenBudget = jest.fn();

    render(
      <SettingsPanel
        settings={settings}
        tokenBudgets={tokenBudgets}
        onUpdateSetting={mockUpdateSetting}
        onUpdateTokenBudget={mockUpdateTokenBudget}
      />
    );

    // Check that all settings are displayed
    Object.keys(settings).forEach(key => {
      // Find the corresponding setting label
      const settingConfig = [
        { id: 'autoModelSelection', label: 'Auto Model Selection' },
        { id: 'cachingEnabled', label: 'Caching' },
        { id: 'contextWindowOptimization', label: 'Context Optimization' },
        { id: 'outputMinimization', label: 'Output Minimization' },
        { id: 'notifyOnLowBudget', label: 'Budget Notifications' },
        { id: 'safetyChecks', label: 'Safety Checks' }
      ].find(item => item.id === key);

      const settingElement = screen.getByText(settingConfig.label);
      expect(settingElement).toBeInTheDocument();

      // Check that toggle states match settings
      const toggle = screen.getByTestId(`toggle-${key}`);
      expect(toggle.checked).toBe(settings[key]);
    });
  });

  test('renders all budget items correctly', () => {
    const mockUpdateSetting = jest.fn();
    const mockUpdateTokenBudget = jest.fn();

    render(
      <SettingsPanel
        settings={settings}
        tokenBudgets={tokenBudgets}
        onUpdateSetting={mockUpdateSetting}
        onUpdateTokenBudget={mockUpdateTokenBudget}
      />
    );

    // Check budgets are displayed
    const budgetLabels = {
      codeCompletion: 'Code Completion',
      errorResolution: 'Error Resolution',
      architecture: 'Architecture',
      thinking: 'Thinking'
    };

    Object.entries(tokenBudgets).forEach(([key, value]) => {
      // Find the corresponding budget label
      const budgetLabel = budgetLabels[key];
      const budgetElement = screen.getByText(budgetLabel);
      expect(budgetElement).toBeInTheDocument();

      // Check the budget values are displayed
      const usedValue = screen.getByText(value.used.toLocaleString(), { exact: false });
      expect(usedValue).toBeInTheDocument();

      // Use data-testid instead of text content to find the specific budget element
      const budgetElement2 = screen.getByTestId(`edit-budget-${key}`);
      expect(budgetElement2).toBeInTheDocument();
      expect(budgetElement2.textContent).toContain(`${value.budget.toLocaleString()} tokens`);

      // Check the progress bar exists
      const progressBar = screen.getByTestId(`budget-progress-${key}`);
      expect(progressBar).toBeInTheDocument();

      // Check width of progress bar matches percentage
      const percentUsed = Math.round((value.used / value.budget) * 100);
      expect(progressBar.style.width).toBe(`${percentUsed}%`);
    });
  });

  test('all setting toggles trigger callback with correct values', () => {
    const mockUpdateSetting = jest.fn();
    const mockUpdateTokenBudget = jest.fn();

    render(
      <SettingsPanel
        settings={settings}
        tokenBudgets={tokenBudgets}
        onUpdateSetting={mockUpdateSetting}
        onUpdateTokenBudget={mockUpdateTokenBudget}
      />
    );

    // Check each setting toggle callback
    Object.keys(settings).forEach(key => {
      const toggle = screen.getByTestId(`toggle-${key}`);

      // Click the toggle to change its state
      fireEvent.click(toggle);

      // Verify the callback was called with the correct args
      expect(mockUpdateSetting).toHaveBeenCalledWith(key, !settings[key]);
    });

    // Verify total number of calls
    expect(mockUpdateSetting).toHaveBeenCalledTimes(Object.keys(settings).length);
  });

  test('clicking budget value opens editor', () => {
    const mockUpdateSetting = jest.fn();
    const mockUpdateTokenBudget = jest.fn();

    render(
      <SettingsPanel
        settings={settings}
        tokenBudgets={tokenBudgets}
        onUpdateSetting={mockUpdateSetting}
        onUpdateTokenBudget={mockUpdateTokenBudget}
      />
    );

    // Check that editing works for a specific budget
    const budgetType = 'codeCompletion';
    const budgetElement = screen.getByTestId(`edit-budget-${budgetType}`);

    // Click to start editing
    fireEvent.click(budgetElement);

    // Verify that the input editor is now visible
    const editor = screen.getByTestId(`budget-input-${budgetType}`);
    expect(editor).toBeInTheDocument();

    // Type a new value
    fireEvent.change(editor, { target: { value: '7500' } });

    // Click the save button
    const saveButton = screen.getByTestId(`save-budget-${budgetType}`);
    fireEvent.click(saveButton);

    // Verify the callback was called with the correct args
    expect(mockUpdateTokenBudget).toHaveBeenCalledWith(budgetType, 7500);
  });

  test('canceling budget edit discards changes', () => {
    const mockUpdateSetting = jest.fn();
    const mockUpdateTokenBudget = jest.fn();

    render(
      <SettingsPanel
        settings={settings}
        tokenBudgets={tokenBudgets}
        onUpdateSetting={mockUpdateSetting}
        onUpdateTokenBudget={mockUpdateTokenBudget}
      />
    );

    // Find and click the budget to edit
    const budgetType = 'architecture';
    const budgetElement = screen.getByTestId(`edit-budget-${budgetType}`);
    fireEvent.click(budgetElement);

    // Type a new value
    const editor = screen.getByTestId(`budget-input-${budgetType}`);
    fireEvent.change(editor, { target: { value: '12000' } });

    // Find and click the cancel button
    const cancelButton = screen.getByTestId(`cancel-budget-${budgetType}`);
    fireEvent.click(cancelButton);

    // Verify the callback was NOT called
    expect(mockUpdateTokenBudget).not.toHaveBeenCalled();

    // Verify the editor is no longer visible
    expect(screen.queryByTestId(`budget-input-${budgetType}`)).not.toBeInTheDocument();
  });

  test('handles invalid budget input', () => {
    const mockUpdateSetting = jest.fn();
    const mockUpdateTokenBudget = jest.fn();

    render(
      <SettingsPanel
        settings={settings}
        tokenBudgets={tokenBudgets}
        onUpdateSetting={mockUpdateSetting}
        onUpdateTokenBudget={mockUpdateTokenBudget}
      />
    );

    // Find and click the budget to edit
    const budgetType = 'thinking';
    const budgetElement = screen.getByTestId(`edit-budget-${budgetType}`);
    fireEvent.click(budgetElement);

    // Type an invalid value (non-numeric)
    const editor = screen.getByTestId(`budget-input-${budgetType}`);
    fireEvent.change(editor, { target: { value: 'abc' } });

    // Click the save button
    const saveButton = screen.getByTestId(`save-budget-${budgetType}`);
    fireEvent.click(saveButton);

    // Verify the callback was NOT called with invalid input
    expect(mockUpdateTokenBudget).not.toHaveBeenCalled();

    // Should show an error message
    const errorMessage = screen.getByText('Please enter a valid number');
    expect(errorMessage).toBeInTheDocument();

    // Now try with a value that's too low
    fireEvent.change(editor, { target: { value: '50' } });
    fireEvent.click(saveButton);

    // Verify the callback was NOT called with low value
    expect(mockUpdateTokenBudget).not.toHaveBeenCalled();

    // Should show an error message for minimum value
    const minErrorMessage = screen.getByText('Budget must be at least 100 tokens');
    expect(minErrorMessage).toBeInTheDocument();

    // Now try with a value that's too high
    fireEvent.change(editor, { target: { value: '10000000' } });
    fireEvent.click(saveButton);

    // Verify the callback was NOT called with high value
    expect(mockUpdateTokenBudget).not.toHaveBeenCalled();

    // Should show an error message for maximum value
    const maxErrorMessage = screen.getByText('Budget cannot exceed 5 million tokens');
    expect(maxErrorMessage).toBeInTheDocument();
  });

  test('renders with missing budget or settings data', () => {
    const mockUpdateSetting = jest.fn();
    const mockUpdateTokenBudget = jest.fn();

    // Render with null settings and tokenBudgets
    const { rerender } = render(
      <SettingsPanel
        settings={null}
        tokenBudgets={null}
        onUpdateSetting={mockUpdateSetting}
        onUpdateTokenBudget={mockUpdateTokenBudget}
      />
    );

    // Component should render without crashing
    expect(screen.getByText('Settings')).toBeInTheDocument();

    // Render with empty settings and tokenBudgets
    rerender(
      <SettingsPanel
        settings={{}}
        tokenBudgets={{}}
        onUpdateSetting={mockUpdateSetting}
        onUpdateTokenBudget={mockUpdateTokenBudget}
      />
    );

    // Component should render without crashing
    expect(screen.getByText('Settings')).toBeInTheDocument();
  });

  test('handles budget with commas in input', () => {
    const mockUpdateSetting = jest.fn();
    const mockUpdateTokenBudget = jest.fn();

    render(
      <SettingsPanel
        settings={settings}
        tokenBudgets={tokenBudgets}
        onUpdateSetting={mockUpdateSetting}
        onUpdateTokenBudget={mockUpdateTokenBudget}
      />
    );

    // Find and click a budget to edit
    const budgetType = 'errorResolution';
    const budgetElement = screen.getByTestId(`edit-budget-${budgetType}`);
    fireEvent.click(budgetElement);

    // Type a value with commas
    const editor = screen.getByTestId(`budget-input-${budgetType}`);
    fireEvent.change(editor, { target: { value: '12,500' } });

    // Click the save button
    const saveButton = screen.getByTestId(`save-budget-${budgetType}`);
    fireEvent.click(saveButton);

    // Verify the callback was called with the correct numeric value (commas removed)
    expect(mockUpdateTokenBudget).toHaveBeenCalledWith(budgetType, 12500);
  });
});
