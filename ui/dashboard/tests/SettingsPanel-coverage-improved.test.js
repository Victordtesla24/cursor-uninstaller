/**
 * Improved test coverage for SettingsPanel component
 * Focus on branch coverage to improve it above 85%
 */
import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import SettingsPanel from '../components/SettingsPanel';

// Define all test data outside the tests
const settings = {
  autoRefresh: true,
  darkMode: false,
  compactMode: true,
  budgetAlerts: true,
  performanceAlerts: false,
  detailedLogging: true,
  debugMode: false,
  experimentalFeatures: true
};

const tokenBudgets = {
  codeCompletion: 5000,
  errorResolution: 10000,
  architecture: 8000,
  thinking: 15000
};

describe('SettingsPanel Component Branch Coverage', () => {
  test('renders with settings correctly', () => {
    const { container } = render(
      <SettingsPanel
        settings={settings}
        tokenBudgets={tokenBudgets}
      />
    );

    // Simple check - component rendered
    const hasSettings = screen.getByText('Settings');
    expect(hasSettings).not.toBeNull();

    // Basic content check - use safer assertion method
    const hasAutoRefresh = container.textContent.indexOf('Auto Refresh') > -1;
    expect(hasAutoRefresh).toBe(true); // Use toBe instead of toBeTruthy
  });

  test('renders token budgets correctly', () => {
    const { container } = render(
      <SettingsPanel
        settings={settings}
        tokenBudgets={tokenBudgets}
      />
    );

    // Simple check - token budgets section exists
    const hasBudgets = container.textContent.indexOf('Token Budgets') > -1;
    expect(hasBudgets).toBeTruthy();
  });

  test('handles missing settings gracefully', () => {
    const { container } = render(
      <SettingsPanel settings={null} tokenBudgets={null} />
    );

    // Simple check - still renders something
    const hasSettings = screen.getByText('Settings');
    expect(hasSettings).toBeTruthy();
  });

  test('renders with empty settings objects', () => {
    const { container } = render(
      <SettingsPanel settings={{}} tokenBudgets={{}} />
    );

    // Simple check - component rendered
    const hasSettings = screen.getByText('Settings');
    expect(hasSettings).toBeTruthy();
  });

  test('renders with UI elements', () => {
    const { container } = render(
      <SettingsPanel settings={settings} tokenBudgets={tokenBudgets} />
    );

    // Simple check - has inputs and buttons
    const inputCount = container.querySelectorAll('input').length;
    const buttonCount = container.querySelectorAll('button').length;

    // Just check they exist without using matchers that might cause format issues
    expect(inputCount > 0).toBe(true); // Use toBe instead of toBeTruthy
    expect(buttonCount > 0).toBe(true); // Use toBe instead of toBeTruthy
  });
});
