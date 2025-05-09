import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import '@testing-library/jest-dom';
import { SettingsPanel } from '../components/SettingsPanel';

describe('SettingsPanel Component', () => {
  const mockSettings = {
    autoModelSelection: true,
    cachingEnabled: true,
    contextWindowOptimization: true,
    outputMinimization: true,
    notifyOnLowBudget: false,
    safetyChecks: true
  };

  const mockBudgets = {
    codeCompletion: {
      used: 275420,
      budget: 300000,
      remaining: 24580
    },
    errorResolution: {
      used: 125640,
      budget: 200000,
      remaining: 74360
    }
  };

  test('renders settings correctly', () => {
    render(
      <SettingsPanel
        settings={mockSettings}
        tokenBudgets={mockBudgets}
        onUpdateSetting={jest.fn()}
        onUpdateTokenBudget={jest.fn()}
      />
    );

    // Check for settings headings
    expect(screen.getByText('Feature Settings')).toBeInTheDocument();
    expect(screen.getByText('Token Budgets')).toBeInTheDocument();

    // Check for specific settings
    expect(screen.getByText('Auto Model Selection')).toBeInTheDocument();
    expect(screen.getByText('Caching')).toBeInTheDocument();

    // Check for budget categories
    expect(screen.getByText('Code Completion')).toBeInTheDocument();
    expect(screen.getByText('Error Resolution')).toBeInTheDocument();
  });

  test('calls onUpdateSetting when toggle is clicked', () => {
    const mockUpdateFn = jest.fn();

    render(
      <SettingsPanel
        settings={mockSettings}
        tokenBudgets={mockBudgets}
        onUpdateSetting={mockUpdateFn}
        onUpdateTokenBudget={jest.fn()}
      />
    );

    // Find all toggle switches
    const toggles = screen.getAllByRole('checkbox');

    // Find the toggle for Auto Model Selection
    const autoModelSwitch = toggles[0];

    // Initial state should be checked (true)
    expect(autoModelSwitch).toBeChecked();

    // Click the toggle
    fireEvent.click(autoModelSwitch);

    // Verify the callback was called with the correct parameters
    expect(mockUpdateFn).toHaveBeenCalledWith('autoModelSelection', false);

    // Note: We can't check if it's now unchecked because the component doesn't update its state
    // in the test environment. It only calls the callback function.
  });

  test('edits token budget when edit icon is clicked', () => {
    const mockUpdateBudgetFn = jest.fn();

    render(
      <SettingsPanel
        settings={mockSettings}
        tokenBudgets={mockBudgets}
        onUpdateSetting={jest.fn()}
        onUpdateTokenBudget={mockUpdateBudgetFn}
      />
    );

    // Find all edit icons
    const editIcons = screen.getAllByText('✎');

    // Click the first edit icon
    fireEvent.click(editIcons[0]);

    // Should now show input field
    const input = screen.getByPlaceholderText('Enter budget');
    expect(input).toBeInTheDocument();

    // Enter new value
    fireEvent.change(input, { target: { value: '400000' } });

    // Click the save button
    const saveButton = screen.getByText('Save');
    fireEvent.click(saveButton);

    // Verify the callback was called
    expect(mockUpdateBudgetFn).toHaveBeenCalled();
  });

  test('handles cancel when editing budget', () => {
    render(
      <SettingsPanel
        settings={mockSettings}
        tokenBudgets={mockBudgets}
        onUpdateSetting={jest.fn()}
        onUpdateTokenBudget={jest.fn()}
      />
    );

    // Find and click the first edit icon
    const editIcons = screen.getAllByText('✎');
    fireEvent.click(editIcons[0]);

    // Input field should be visible
    expect(screen.getByPlaceholderText('Enter budget')).toBeInTheDocument();

    // Click the cancel button
    const cancelButton = screen.getByText('Cancel');
    fireEvent.click(cancelButton);

    // Input field should be gone now
    expect(screen.queryByPlaceholderText('Enter budget')).not.toBeInTheDocument();
  });
});
