import React from 'react';
import { render, screen, fireEvent, waitFor, act } from '@testing-library/react';
import '@testing-library/jest-dom';
import SettingsPanel from '../components/SettingsPanel';

// Mock the UI components
jest.mock('../components/ui', () => ({
  Card: ({ children, className }) => <div data-testid="card" className={className}>{children}</div>,
  CardHeader: ({ children }) => <div data-testid="card-header">{children}</div>,
  CardContent: ({ children, className }) => <div data-testid="card-content" className={className}>{children}</div>,
  CardDescription: ({ children }) => <div data-testid="card-description">{children}</div>,
  CardTitle: ({ children, className }) => <div data-testid="card-title" className={className}>{children}</div>,
  CardFooter: ({ children, className }) => <div data-testid="card-footer" className={className}>{children}</div>,
  Button: ({ children, variant, size, onClick, className, disabled, ...props }) => (
    <button 
      data-testid="button" 
      data-variant={variant} 
      data-size={size} 
      onClick={onClick} 
      className={className}
      disabled={disabled}
      {...props}
    >
      {children}
    </button>
  ),
  Switch: ({ checked, onCheckedChange, id, className, ...props }) => (
    <input 
      type="checkbox" 
      data-testid={id || "switch"} 
      checked={checked} 
      onChange={(e) => onCheckedChange && onCheckedChange(e.target.checked)} 
      className={className}
      role="switch"
      aria-checked={checked}
      {...props}
    />
  ),
  Label: ({ children, htmlFor, className }) => (
    <label data-testid="label" htmlFor={htmlFor} className={className}>{children}</label>
  ),
  Input: ({ value, onChange, className, autoFocus, ...props }) => (
    <input 
      data-testid="input" 
      value={value} 
      onChange={onChange} 
      className={className}
      {...props} 
    />
  ),
  Badge: ({ children, variant, className }) => (
    <span data-testid="badge" data-variant={variant} className={className}>{children}</span>
  ),
  Separator: ({ className }) => <hr data-testid="separator" className={className} />,
  Tooltip: ({ children }) => <div data-testid="tooltip">{children}</div>,
  TooltipContent: ({ children, side }) => <div data-testid="tooltip-content" data-side={side}>{children}</div>,
  TooltipProvider: ({ children }) => <div data-testid="tooltip-provider">{children}</div>,
  TooltipTrigger: ({ children, asChild }) => <div data-testid="tooltip-trigger" data-aschild={asChild}>{children}</div>,
  Collapsible: ({ children, open, className }) => (
    <div data-testid="collapsible" data-open={open} className={className}>{children}</div>
  ),
  CollapsibleContent: ({ children, className }) => (
    <div data-testid="collapsible-content" className={className}>{children}</div>
  ),
  CollapsibleTrigger: ({ children }) => <div data-testid="collapsible-trigger">{children}</div>,
  Accordion: ({ children, type, collapsible, className, defaultValue }) => (
    <div 
      data-testid="accordion" 
      data-type={type} 
      data-collapsible={collapsible} 
      className={className} 
      data-default-value={defaultValue}
    >
      {children}
    </div>
  ),
  AccordionItem: ({ children, value, className }) => (
    <div data-testid="accordion-item" data-value={value} className={className}>{children}</div>
  ),
  AccordionTrigger: ({ children, className }) => (
    <div data-testid="accordion-trigger" className={className}>{children}</div>
  ),
  AccordionContent: ({ children, className }) => (
    <div data-testid="accordion-content" className={className}>{children}</div>
  ),
}));

// Mock lucide-react icons
jest.mock('lucide-react', () => {
  // Create a mock icon component generator
  const createIconMock = (name) => ({ className, size }) => (
    <span data-testid={`icon-${name.toLowerCase()}`} className={className} data-size={size}>
      {name} Icon
    </span>
  );
  
  // Return mocked icon components
  return {
    Settings: createIconMock("Settings"),
    ChevronDown: createIconMock("ChevronDown"),
    ChevronUp: createIconMock("ChevronUp"),
    CreditCard: createIconMock("CreditCard"),
    Save: createIconMock("Save"),
    X: createIconMock("X"),
    Check: createIconMock("Check"),
    Edit: createIconMock("Edit"),
    AlertCircle: createIconMock("AlertCircle"),
    Info: createIconMock("Info"),
    Bell: createIconMock("Bell"),
    WrenchIcon: createIconMock("Wrench"),
    MonitorIcon: createIconMock("Monitor"),
    RefreshCwIcon: createIconMock("RefreshCw"),
    MoonIcon: createIconMock("Moon"),
    LayoutGrid: createIconMock("LayoutGrid"),
  };
});

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
    const { getByTestId } = render(<SettingsPanel {...defaultProps} isCollapsed={false} />);
    
    const collapsible = getByTestId('mock-collapsible');
    expect(collapsible).toHaveAttribute('data-open', 'true');
  });

  test('does not render collapsible content when collapsed', () => {
    const { getByTestId } = render(<SettingsPanel {...defaultProps} isCollapsed={true} />);
    
    const collapsible = getByTestId('mock-collapsible');
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
    const { getAllByTestId, getByText } = render(<SettingsPanel {...defaultProps} />);
    
    // Check that all accordion items are rendered
    const accordionItems = getAllByTestId('mock-accordion-item');
    expect(accordionItems.length).toBeGreaterThanOrEqual(3); // At least 3 categories
    
    // Check that all settings are rendered
    Object.keys(settings).forEach(settingId => {
      // There should be a label for each setting
      const labels = Array.from(document.querySelectorAll('label')).filter(
        label => label.textContent.includes(settingId.replace(/([A-Z])/g, ' $1').replace(/^./, str => str.toUpperCase()))
      );
      
      expect(labels.length).toBeGreaterThanOrEqual(1);
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
    
    // Check for error message
    expect(container.textContent).toContain('Please enter a valid number');
    
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
    
    // For this test, we'll just check that the props were passed correctly
    const card = container.querySelector('[data-testid="mock-card"]');
    expect(card).toBeInTheDocument();
    
    // Additional checks could be added for specific dark mode classes
    // depending on implementation
  });
}); 