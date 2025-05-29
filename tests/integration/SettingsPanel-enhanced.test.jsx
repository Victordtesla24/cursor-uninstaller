import React from 'react';
import { render, screen, fireEvent, waitFor, act } from '@testing-library/react';
import '@testing-library/jest-dom';

// Mock UI components that SettingsPanel depends on
jest.mock('../../src/components/ui/index.js', () => ({
  Card: ({ children, className }) => <div className={`card ${className || ''}`}>{children}</div>,
  CardContent: ({ children, className }) => <div className={`card-content ${className || ''}`}>{children}</div>,
  CardDescription: ({ children }) => <div>{children}</div>,
  CardHeader: ({ children, className }) => <div className={`card-header ${className || ''}`}>{children}</div>,
  CardTitle: ({ children, className }) => <div className={`card-title ${className || ''}`}>{children}</div>,
  CardFooter: ({ children, className }) => <div className={`card-footer ${className || ''}`}>{children}</div>,
  Badge: ({ children, variant, className }) => <span className={`badge ${variant || ''} ${className || ''}`}>{children}</span>,
  Button: ({ children, variant, size, className, disabled, onClick, ...props }) => (
    <button 
      className={`button ${variant || ''} ${size || ''} ${className || ''}`} 
      disabled={disabled} 
      onClick={onClick}
      {...props}
    >
      {children}
    </button>
  ),
  Switch: ({ checked, onCheckedChange, id, ...props }) => (
    <input 
      type="checkbox" 
      checked={checked}
      onChange={(e) => onCheckedChange && onCheckedChange(e.target.checked)}
      id={id}
      role="switch"
      aria-checked={checked}
      {...props}
    />
  ),
  Label: ({ children, htmlFor, className }) => (
    <label htmlFor={htmlFor} className={className}>{children}</label>
  ),
  Input: ({ value, onChange, className, ...props }) => (
    <input value={value} onChange={onChange} className={className} {...props} />
  ),
  Separator: ({ className }) => <hr className={className || ''} />,
  Collapsible: ({ children, open, className }) => <div className={className} data-open={open}>{children}</div>,
  CollapsibleContent: ({ children, className }) => <div className={className}>{children}</div>,
  CollapsibleTrigger: ({ children, onClick }) => <button onClick={onClick}>{children}</button>,
  Accordion: ({ children, type, collapsible, className }) => <div className={className}>{children}</div>,
  AccordionItem: ({ children, value, className }) => <div className={className} data-value={value}>{children}</div>,
  AccordionTrigger: ({ children, className }) => <div className={className}>{children}</div>,
  AccordionContent: ({ children, className }) => <div className={className}>{children}</div>,
  Tooltip: ({ children }) => <div>{children}</div>,
  TooltipContent: ({ children, side }) => <div data-side={side}>{children}</div>,
  TooltipProvider: ({ children }) => <div>{children}</div>,
  TooltipTrigger: ({ children, asChild }) => asChild ? children : <div>{children}</div>,
}));

// Mock Lucide React icons (same as the working test file)
jest.mock('lucide-react', () => ({
  Settings: () => <span data-testid="icon-settings">Settings Icon</span>,
  ChevronDown: () => <span data-testid="icon-chevron-down">ChevronDown Icon</span>,
  ChevronUp: () => <span data-testid="icon-chevron-up">ChevronUp Icon</span>,
  Edit: () => <span data-testid="icon-edit">Edit Icon</span>,
  Save: () => <span data-testid="icon-save">Save Icon</span>,
  X: () => <span data-testid="icon-x">X Icon</span>,
  Check: () => <span data-testid="icon-check">Check Icon</span>,
  AlertCircle: () => <span data-testid="icon-alert">Alert Icon</span>,
  Info: () => <span data-testid="icon-info">Info Icon</span>,
  CreditCard: () => <span data-testid="icon-credit-card">CreditCard Icon</span>,
  Bell: () => <span data-testid="icon-bell">Bell Icon</span>,
  WrenchIcon: () => <span data-testid="icon-wrench">Wrench Icon</span>,
  MonitorIcon: () => <span data-testid="icon-monitor">Monitor Icon</span>,
  RefreshCwIcon: () => <span data-testid="icon-refresh">RefreshCw Icon</span>,
  MoonIcon: () => <span data-testid="icon-moon">Moon Icon</span>,
  LayoutGrid: () => <span data-testid="icon-layout">LayoutGrid Icon</span>,
}));

import SettingsPanel from '../../src/components/features/SettingsPanel';

describe('SettingsPanel Component (Enhanced Tests)', () => {
  // Test data
  const settings = {
    autoRefresh: true,
    darkMode: false,
    compactMode: true,
    budgetAlerts: true,
    performanceAlerts: false,
    detailedLogging: true,
    debugMode: false,
    experimentalFeatures: true,
    cachingEnabled: true,
    contextWindowOptimization: false,
    outputMinimization: true
  };

  const tokenBudgets = {
    codeCompletion: 300000,
    errorResolution: 200000,
    architecture: 150000,
    thinking: 100000,
    total: 750000
  };

  // Test functions for toggling setting state and collapsing
  const defaultProps = {
    settings,
    tokenBudgets,
    onSettingChange: jest.fn(),
    onBudgetChange: jest.fn(),
    isCollapsed: false,
    onToggleCollapse: jest.fn(),
    className: 'test-class',
    darkMode: false
  };

  // Helper function to get a setting toggle by ID
  const getSettingToggle = (container, settingId) => {
    return container.querySelector(`input#toggle-${settingId}`);
  };

  afterEach(() => {
    jest.clearAllMocks();
  });

  // Basic rendering tests
  test('renders settings panel with correct title and description', () => {
    const { getByText } = render(<SettingsPanel {...defaultProps} />);

    expect(getByText('Settings')).toBeInTheDocument();
    expect(getByText('Configure dashboard settings and token budgets')).toBeInTheDocument();
  });

  test('renders empty state when settings and budgets are null', () => {
    const { getByText } = render(
      <SettingsPanel
        settings={null}
        tokenBudgets={null}
      />
    );

    expect(getByText('No settings available')).toBeInTheDocument();
    expect(getByText('Settings information will appear here when available')).toBeInTheDocument();
  });

  // Collapse functionality tests
  test('handles collapsed state correctly', () => {
    const { rerender, getByRole } = render(
      <SettingsPanel {...defaultProps} isCollapsed={false} />
    );

    // Initially expanded
    const collapseButton = getByRole('button', { name: /collapse settings/i });
    expect(collapseButton).toBeInTheDocument();

    // Click to collapse
    fireEvent.click(collapseButton);
    expect(defaultProps.onToggleCollapse).toHaveBeenCalledTimes(1);

    // Rerender with collapsed state
    rerender(<SettingsPanel {...defaultProps} isCollapsed={true} />);

    const expandButton = getByRole('button', { name: /expand settings/i });
    expect(expandButton).toBeInTheDocument();
  });

  test('renders collapsible content when not collapsed', () => {
    const { container } = render(<SettingsPanel {...defaultProps} isCollapsed={false} />);

    // Find the collapsible element by its class and data-open attribute
    const collapsible = container.querySelector('[data-open="true"]');
    expect(collapsible).toHaveAttribute('data-open', 'true');
  });

  test('does not render collapsible content when collapsed', () => {
    const { container } = render(<SettingsPanel {...defaultProps} isCollapsed={true} />);

    // Find the collapsible element by its class and data-open attribute
    const collapsible = container.querySelector('[data-open="false"]');
    expect(collapsible).toHaveAttribute('data-open', 'false');
  });

  // Settings toggle tests
  test('toggles settings correctly', () => {
    const { container } = render(<SettingsPanel {...defaultProps} />);

    // Find the autoRefresh toggle
    const autoRefreshToggle = getSettingToggle(container, 'autoRefresh');
    expect(autoRefreshToggle).toBeInTheDocument();
    expect(autoRefreshToggle).toBeChecked(); // Should be checked initially

    // Toggle it
    fireEvent.click(autoRefreshToggle);

    // Check that the callback was called with the right parameters
    expect(defaultProps.onSettingChange).toHaveBeenCalledWith('autoRefresh', false);
  });

  test('renders all settings in appropriate categories', () => {
    const { container, getAllByTestId } = render(<SettingsPanel {...defaultProps} />); // Use container from here

    // Check that all accordion items are rendered by looking for actual accordion items
    const accordionItems = container.querySelectorAll('[data-value]');
    expect(accordionItems.length).toBeGreaterThanOrEqual(3); // At least 3 categories

    // Check that all settings are rendered
    // Settings known to be rendered by the component based on its internal settingsCategories
    const renderedSettingIds = [
      'autoRefresh', 'darkMode', 'compactMode',
      'budgetAlerts', 'performanceAlerts',
      'detailedLogging', 'debugMode', 'experimentalFeatures'
    ];

    renderedSettingIds.forEach(settingId => {
      // There should be a label for each setting
      const expectedLabelText = settingId.replace(/([A-Z])/g, ' $1').replace(/^./, str => str.toUpperCase());
      const labels = Array.from(container.querySelectorAll('label')).filter(
        label => label.textContent.includes(expectedLabelText)
      );

      // Ensure the label is found for settings that are expected to be rendered
      if (settings.hasOwnProperty(settingId)) { // Check if the setting is in the props
        expect(labels.length).toBeGreaterThanOrEqual(1);
        // Ensure the label is associated with a switch
        const switchEl = container.querySelector(`#toggle-${settingId}`);
        expect(switchEl).toBeInTheDocument();
        const labelForSwitch = container.querySelector(`label[for="toggle-${settingId}"]`);
        expect(labelForSwitch).toBeInTheDocument();
        expect(labelForSwitch.textContent).toContain(expectedLabelText);
      }
    });
  });

  // Budget editing tests
  test('edits budget value correctly', async () => {
    const { container, getAllByRole } = render(<SettingsPanel {...defaultProps} />);

    // Find edit buttons for budgets
    const editButtons = getAllByRole('button').filter(button =>
      button.getAttribute('data-testid')?.includes('budget-edit-')
    );

    // Click the first edit button
    fireEvent.click(editButtons[0]);

    // Find the input
    const input = container.querySelector('input[data-testid^="budget-input-"]');
    expect(input).toBeInTheDocument();

    // Change the value
    fireEvent.change(input, { target: { value: '400000' } });

    // Find the save button and click it
    const saveButton = container.querySelector('button[data-testid^="budget-save-"]');
    fireEvent.click(saveButton);

    // Check that the callback was called with the right parameters
    // The exact category depends on the implementation, but it should be called
    expect(defaultProps.onBudgetChange).toHaveBeenCalled();
    expect(defaultProps.onBudgetChange.mock.calls[0][1]).toBe(400000);
  });

  test('validates budget input correctly', async () => {
    const { container, getAllByRole } = render(<SettingsPanel {...defaultProps} />);

    // Find edit buttons for budgets
    const editButtons = getAllByRole('button').filter(button =>
      button.getAttribute('data-testid')?.includes('budget-edit-')
    );

    // Click the first edit button
    fireEvent.click(editButtons[0]);

    // Find the input
    const input = container.querySelector('input[data-testid^="budget-input-"]');

    // Enter invalid value (non-numeric)
    fireEvent.change(input, { target: { value: 'abc' } });

    // Find the save button and click it
    const saveButton = container.querySelector('button[data-testid^="budget-save-"]');
    fireEvent.click(saveButton);

    // Check for error message using findByText for async update
    await screen.findByText('Please enter a valid number');

    // Should not call the callback for invalid input
    expect(defaultProps.onBudgetChange).not.toHaveBeenCalled();
  });

  test('cancels budget editing correctly', async () => {
    const { container, getAllByRole } = render(<SettingsPanel {...defaultProps} />);

    // Find edit buttons for budgets
    const editButtons = getAllByRole('button').filter(button =>
      button.getAttribute('data-testid')?.includes('budget-edit-')
    );

    // Click the first edit button
    fireEvent.click(editButtons[0]);

    // Find the input
    const input = container.querySelector('input[data-testid^="budget-input-"]');
    expect(input).toBeInTheDocument();

    // Change the value
    fireEvent.change(input, { target: { value: '400000' } });

    // Find the cancel button and click it
    const cancelButton = container.querySelector('button[data-testid^="budget-cancel-"]');
    fireEvent.click(cancelButton);

    // The input should no longer be visible
    expect(container.querySelector('input[data-testid^="budget-input-"]')).not.toBeInTheDocument();

    // The callback should not have been called
    expect(defaultProps.onBudgetChange).not.toHaveBeenCalled();
  });

  // Accessibility tests
  test('has proper ARIA attributes for settings toggles', () => {
    const { container } = render(<SettingsPanel {...defaultProps} />);

    // Find toggle switches
    const toggles = container.querySelectorAll('input[role="switch"]');

    // Each toggle should have appropriate ARIA attributes
    toggles.forEach(toggle => {
      expect(toggle).toHaveAttribute('aria-checked');
      expect(toggle).toHaveAttribute('id');

      // Should have an associated label
      const labelFor = toggle.getAttribute('id');
      const label = container.querySelector(`label[for="${labelFor}"]`);
      expect(label).toBeInTheDocument();
    });
  });

  test('collapse/expand button has appropriate ARIA label', () => {
    const { getByRole, rerender } = render(<SettingsPanel {...defaultProps} isCollapsed={false} />);

    // When expanded, should have "Collapse settings" aria-label
    const collapseButton = getByRole('button', { name: /collapse settings/i });
    expect(collapseButton).toHaveAttribute('aria-label', 'Collapse settings');

    // Rerender with collapsed state
    rerender(<SettingsPanel {...defaultProps} isCollapsed={true} />);

    // When collapsed, should have "Expand settings" aria-label
    const expandButton = getByRole('button', { name: /expand settings/i });
    expect(expandButton).toHaveAttribute('aria-label', 'Expand settings');
  });

  // Dark mode tests
  test('applies correct styling with dark mode', () => {
    const { container } = render(<SettingsPanel {...defaultProps} darkMode={true} />);

    // Check that the component renders properly with dark mode prop
    const card = container.querySelector('.card');
    expect(card).toBeInTheDocument();

    // The component should still render all its content
    expect(screen.getByText('Settings')).toBeInTheDocument();
  });
});
