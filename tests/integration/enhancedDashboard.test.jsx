import React from 'react';
import { render, screen, fireEvent, waitFor, act } from '@testing-library/react';
import '@testing-library/jest-dom';
import EnhancedDashboard from '../enhancedDashboard';
import * as enhancedDashboardApi from '../lib/enhancedDashboardApi';
import { dashboardConfig } from '../lib/config';

// Mock all component dependencies to isolate the test
jest.mock('../components/TokenUtilization', () => ({ tokenData, selectedModel }) => (
  <div data-testid="token-utilization" data-model={selectedModel}>
    Token Utilization Mock
    {tokenData && <span>Total: {tokenData.total?.used || 0}</span>}
  </div>
));

jest.mock('../components/CostTracker', () => ({ costData, tokenBudget, onBudgetChange }) => (
  <div data-testid="cost-tracker" data-budget={tokenBudget}>
    Cost Tracker Mock
    <button onClick={() => onBudgetChange('total', 100000)}>Update Budget</button>
  </div>
));

jest.mock('../components/UsageChart', () => ({ usageData, darkMode }) => (
  <div data-testid="usage-chart" data-dark={darkMode ? 'true' : 'false'}>
    Usage Chart Mock
  </div>
));

jest.mock('../components/ModelSelector', () => ({ models, selectedModel, onModelSelect }) => (
  <div data-testid="model-selector" data-selected={selectedModel}>
    Model Selector Mock
    <button onClick={() => onModelSelect('test-model-id')}>Select Test Model</button>
  </div>
));

jest.mock('../components/SettingsPanel', () => ({ settings, tokenBudgets, onSettingChange, onBudgetChange, showAdvanced }) => (
  <div data-testid="settings-panel" data-advanced={showAdvanced ? 'true' : 'false'}>
    Settings Panel Mock
    <button onClick={() => onSettingChange('autoModelSelection', !settings.autoModelSelection)}>Toggle Auto Selection</button>
  </div>
));

jest.mock('../components/MetricsPanel', () => ({ metrics, darkMode }) => (
  <div data-testid="metrics-panel" data-dark={darkMode ? 'true' : 'false'}>
    Metrics Panel Mock
    {metrics && <span>Response Time: {metrics.avgResponseTime || 0}ms</span>}
  </div>
));

jest.mock('../components/UsageStats', () => ({ usageData, lastUpdate }) => (
  <div data-testid="usage-stats" data-timestamp={lastUpdate}>
    Usage Stats Mock
  </div>
));

// Mock status badge and section header components defined in enhancedDashboard.jsx
jest.mock('../components/EnhancedHeader', () => ({ title, subtitle }) => (
  <div data-testid="enhanced-header">
    <h1>{title}</h1>
    {subtitle && <p>{subtitle}</p>}
  </div>
));

jest.mock('../components/features/EnhancedAnalyticsDashboard', () => ({ usageData, modelsData, darkMode }) => (
  <div data-testid="enhanced-analytics-dashboard" data-dark={darkMode ? 'true' : 'false'}>
    Enhanced Analytics Dashboard Mock
  </div>
));

jest.mock('../components/features/ModelPerformanceComparison', () => ({ modelsData, usageData, onModelSelect, darkMode }) => (
  <div data-testid="model-performance-comparison" data-dark={darkMode ? 'true' : 'false'}>
    Model Performance Comparison Mock
    <button onClick={() => onModelSelect('recommended-model')}>Select Recommended Model</button>
  </div>
));

jest.mock('../components/features/TokenBudgetRecommendations', () => ({ tokenData, onApplyRecommendation, darkMode }) => (
  <div data-testid="token-budget-recommendations" data-dark={darkMode ? 'true' : 'false'}>
    Token Budget Recommendations Mock
    <button onClick={() => onApplyRecommendation('total', 1000000)}>Apply Recommendation</button>
  </div>
));

// Mock the enhancedDashboardApi
jest.mock('../lib/enhancedDashboardApi', () => ({
  refreshData: jest.fn(),
  updateSelectedModel: jest.fn(),
  updateSetting: jest.fn(),
  updateTokenBudget: jest.fn(),
  cleanup: jest.fn(),
  addEventListener: jest.fn(),
  removeEventListener: jest.fn(),
  initialize: jest.fn(),
}));

// Mock dashboardConfig
jest.mock('../lib/config', () => ({
  dashboardConfig: {
    version: '1.0.0',
    refreshInterval: 1000,
  }
}));

// Mock localStorage
const localStorageMock = (() => {
  let store = {};
  return {
    getItem: jest.fn((key) => store[key] || null),
    setItem: jest.fn((key, value) => {
      store[key] = value.toString();
    }),
    clear: jest.fn(() => {
      store = {};
    }),
  };
})();
Object.defineProperty(window, 'localStorage', { value: localStorageMock });

// Mock matchMedia
Object.defineProperty(window, 'matchMedia', {
  writable: true,
  value: jest.fn().mockImplementation(query => ({
    matches: false,
    media: query,
    onchange: null,
    addListener: jest.fn(),
    removeListener: jest.fn(),
    addEventListener: jest.fn(),
    removeEventListener: jest.fn(),
    dispatchEvent: jest.fn(),
  })),
});

// Mock for Lucide icons
jest.mock('lucide-react', () => ({
  LayoutDashboard: () => <span data-testid="icon-dashboard">Dashboard Icon</span>,
  BarChart3: () => <span data-testid="icon-chart">Chart Icon</span>,
  BarChart2: () => <span data-testid="icon-chart2">Chart2 Icon</span>,
  LineChart: () => <span data-testid="icon-line-chart">Line Chart Icon</span>,
  Settings: () => <span data-testid="icon-settings">Settings Icon</span>,
  RefreshCw: () => <span data-testid="icon-refresh">Refresh Icon</span>,
  AlertCircle: () => <span data-testid="icon-alert">Alert Icon</span>,
  ChevronDown: () => <span data-testid="icon-chevron">Chevron Icon</span>,
  Wifi: () => <span data-testid="icon-wifi">Wifi Icon</span>,
  WifiOff: () => <span data-testid="icon-wifi-off">Wifi Off Icon</span>,
  ArrowUpRight: () => <span data-testid="icon-arrow-up">Arrow Up Icon</span>,
  ArrowDownRight: () => <span data-testid="icon-arrow-down">Arrow Down Icon</span>,
  Moon: () => <span data-testid="icon-moon">Moon Icon</span>,
  Sun: () => <span data-testid="icon-sun">Sun Icon</span>,
  Lightbulb: () => <span data-testid="icon-lightbulb">Lightbulb Icon</span>,
}));

describe('EnhancedDashboard Component', () => {
  const mockDashboardData = {
    tokens: {
      total: { used: 500000, budgeted: 750000 },
      daily: { used: 18000 },
      budgets: {
        total: { used: 500000, budget: 750000, remaining: 250000 },
        codeCompletion: { used: 200000, budget: 300000, remaining: 100000 },
        errorResolution: { used: 150000, budget: 200000, remaining: 50000 },
        architecture: { used: 100000, budget: 150000, remaining: 50000 },
        thinking: { used: 50000, budget: 100000, remaining: 50000 },
      }
    },
    models: {
      selected: 'claude-3-sonnet',
      available: [
        {
          id: 'claude-3-sonnet',
          name: 'Claude 3 Sonnet',
          contextWindow: 200000,
          costPerToken: 0.00003,
        },
        {
          id: 'gemini-2-pro',
          name: 'Gemini 2 Pro',
          contextWindow: 128000,
          costPerToken: 0.00002,
        }
      ]
    },
    metrics: {
      avgResponseTime: 2.5,
      reliability: 99.8,
      cacheHitRate: 0.68,
      costSavingsRate: 0.43,
    },
    settings: {
      autoModelSelection: true,
      cachingEnabled: true,
      contextWindowOptimization: false,
      outputMinimization: true,
    },
    costs: {
      total: 4.79,
      monthlyCost: 22.45,
      projectedCost: 25.12,
      savings: { total: 3.65, caching: 1.85 },
      byModel: {
        'claude-3-sonnet': 2.85,
        'gemini-2-pro': 1.94,
      }
    },
    usage: {
      daily: Array(30).fill(0).map((_, i) => 10000 + Math.floor(Math.random() * 5000)),
      byModel: {
        'claude-3-sonnet': 280450,
        'gemini-2-pro': 190350,
      }
    }
  };

  beforeEach(() => {
    // Reset mocks
    jest.clearAllMocks();

    // Mock successful API responses by default
    enhancedDashboardApi.refreshData.mockResolvedValue(mockDashboardData);
    enhancedDashboardApi.updateSelectedModel.mockResolvedValue(true);
    enhancedDashboardApi.updateSetting.mockResolvedValue(true);
    enhancedDashboardApi.updateTokenBudget.mockResolvedValue(true);

    // Clear localStorage
    localStorageMock.clear();
  });

  test('renders loading state initially', async () => {
    // Mock a delayed API response to ensure we see the loading state
    enhancedDashboardApi.refreshData.mockImplementationOnce(() =>
      new Promise(resolve => setTimeout(() => resolve(mockDashboardData), 100))
    );

    render(<EnhancedDashboard />);

    // Should show loading spinner and text
    expect(screen.getByText('Loading Dashboard...')).toBeInTheDocument();

    // Wait for data to load
    await waitFor(() => {
      expect(screen.queryByText('Loading Dashboard...')).not.toBeInTheDocument();
    });
  });

  test('renders main dashboard content when data is loaded', async () => {
    render(<EnhancedDashboard />);

    // Wait for data to load
    await waitFor(() => {
      expect(screen.queryByText('Loading Dashboard...')).not.toBeInTheDocument();
    });

    // Check for main dashboard elements
    expect(screen.getByText('Cline AI Dashboard')).toBeInTheDocument();
    expect(screen.getByTestId('metrics-panel')).toBeInTheDocument();
    expect(screen.getByTestId('token-utilization')).toBeInTheDocument();
    expect(screen.getByTestId('cost-tracker')).toBeInTheDocument();
    expect(screen.getByTestId('usage-chart')).toBeInTheDocument();

    // Check that API was called
    expect(enhancedDashboardApi.refreshData).toHaveBeenCalledTimes(1);
  });

  test('handles error state when API fails', async () => {
    // Mock API failure
    enhancedDashboardApi.refreshData.mockRejectedValueOnce(new Error('Failed to load data'));

    render(<EnhancedDashboard />);

    // Wait for error state to appear
    await waitFor(() => {
      expect(screen.getByText('Error Loading Dashboard')).toBeInTheDocument();
      expect(screen.getByText('Failed to load data')).toBeInTheDocument();
    });

    // Should show a button to toggle data source
    const toggleButton = screen.getByText('Use Mock Data');
    expect(toggleButton).toBeInTheDocument();

    // Click the button to toggle data source
    fireEvent.click(toggleButton);

    // Check that a new API call was triggered
    expect(enhancedDashboardApi.refreshData).toHaveBeenCalledTimes(2);
  });

  test('changes view mode when tabs are clicked', async () => {
    render(<EnhancedDashboard />);

    // Wait for data to load
    await waitFor(() => {
      expect(screen.queryByText('Loading Dashboard...')).not.toBeInTheDocument();
    });

    // Initially should be in overview mode - check for a unique element in that view
    expect(screen.getByText('Performance Metrics')).toBeInTheDocument();

    // Click on detailed tab
    fireEvent.click(screen.getByText('Detailed'));

    // Wait for the view to update
    await waitFor(() => {
      const modelSelectionHeaders = screen.getAllByText('Model Selection');
      expect(modelSelectionHeaders.length).toBeGreaterThan(0);
    });

    // Click on settings tab
    fireEvent.click(screen.getByText('Settings'));

    // Should render the settings panel with advanced settings toggle
    await waitFor(() => {
      const dashboardSettingsHeaders = screen.getAllByText('Dashboard Settings');
      expect(dashboardSettingsHeaders.length).toBeGreaterThan(0);
    });

    // Get all "Show Advanced" buttons and use the first one
    const showAdvancedButtons = screen.getAllByText('Show Advanced');
    expect(showAdvancedButtons.length).toBeGreaterThan(0);

    // Toggle advanced settings
    fireEvent.click(showAdvancedButtons[0]);

    // Advanced settings button text should change - use getAllByText since there could be multiple
    const hideAdvancedButtons = screen.getAllByText('Hide Advanced');
    expect(hideAdvancedButtons.length).toBeGreaterThan(0);
  });

  test('toggles dark mode', async () => {
    // Mock document functions
    document.documentElement.classList.add = jest.fn();
    document.documentElement.classList.remove = jest.fn();

    render(<EnhancedDashboard />);

    // Wait for data to load
    await waitFor(() => {
      expect(screen.queryByText('Loading Dashboard...')).not.toBeInTheDocument();
    });

    // Find dark mode toggle button (it will have either sun or moon icon)
    const darkModeButton = screen.getByTestId(/icon-(sun|moon)/).closest('button');
    expect(darkModeButton).toBeInTheDocument();

    // Initially dark mode should be false (based on our matchMedia mock)
    expect(document.documentElement.classList.add).not.toHaveBeenCalledWith('dark');

    // Click the button to toggle dark mode
    fireEvent.click(darkModeButton);

    // Dark mode should be added to the document
    expect(document.documentElement.classList.add).toHaveBeenCalledWith('dark');
    expect(localStorageMock.setItem).toHaveBeenCalledWith('darkMode', 'true');

    // Click again to toggle it off
    fireEvent.click(darkModeButton);

    // Dark mode should be removed
    expect(document.documentElement.classList.remove).toHaveBeenCalledWith('dark');
    expect(localStorageMock.setItem).toHaveBeenCalledWith('darkMode', 'false');
  });

  test('manual refresh button triggers data refresh', async () => {
    render(<EnhancedDashboard />);

    // Wait for data to load
    await waitFor(() => {
      expect(screen.queryByText('Loading Dashboard...')).not.toBeInTheDocument();
    });

    // Initial load should have called the API once
    expect(enhancedDashboardApi.refreshData).toHaveBeenCalledTimes(1);

    // Find and click the refresh button
    const refreshButton = screen.getByTestId('icon-refresh').closest('button');
    fireEvent.click(refreshButton);

    // API should have been called again
    expect(enhancedDashboardApi.refreshData).toHaveBeenCalledTimes(2);
  });

  test('handles model selection', async () => {
    render(<EnhancedDashboard />);

    // Wait for data to load and go to detailed view to see model selector
    await waitFor(() => {
      expect(screen.queryByText('Loading Dashboard...')).not.toBeInTheDocument();
    });

    // Switch to detailed view where model selector is visible
    fireEvent.click(screen.getByText('Detailed'));

    // Wait for the view to update and find the "Select Test Model" button
    let selectModelButtons;
    await waitFor(() => {
      selectModelButtons = screen.getAllByText('Select Test Model');
      expect(selectModelButtons.length).toBeGreaterThan(0);
    });

    // Click the first button
    fireEvent.click(selectModelButtons[0]);

    // API should have been called with the correct model ID
    expect(enhancedDashboardApi.updateSelectedModel).toHaveBeenCalledWith('test-model-id');

    // Wait for the API call to resolve and the dashboard to refresh
    await waitFor(() => {
      expect(enhancedDashboardApi.refreshData).toHaveBeenCalledTimes(2);
    });
  });

  test('handles setting updates', async () => {
    render(<EnhancedDashboard />);

    // Wait for data to load
    await waitFor(() => {
      expect(screen.queryByText('Loading Dashboard...')).not.toBeInTheDocument();
    });

    // Switch to settings view
    fireEvent.click(screen.getByText('Settings'));

    // Wait for the view to update
    await waitFor(() => {
      const dashboardSettingsHeaders = screen.getAllByText('Dashboard Settings');
      expect(dashboardSettingsHeaders.length).toBeGreaterThan(0);
    });

    // Find settings toggle button and click it - use getAllByText and get the first one
    const toggleSettingButtons = screen.getAllByText('Toggle Auto Selection');
    fireEvent.click(toggleSettingButtons[0]);

    // API should have been called with the correct setting
    expect(enhancedDashboardApi.updateSetting).toHaveBeenCalledWith('autoModelSelection', false);
  });

  test('handles token budget updates', async () => {
    render(<EnhancedDashboard />);

    // Wait for data to load
    await waitFor(() => {
      expect(screen.queryByText('Loading Dashboard...')).not.toBeInTheDocument();
    });

    // Click on the update budget button in cost tracker
    const updateBudgetButton = screen.getByText('Update Budget');
    fireEvent.click(updateBudgetButton);

    // API should have been called with the correct budget parameters
    expect(enhancedDashboardApi.updateTokenBudget).toHaveBeenCalledWith('total', 100000);

    // Dashboard should refresh after budget update
    await waitFor(() => {
      expect(enhancedDashboardApi.refreshData).toHaveBeenCalledTimes(2);
    });
  });

  test('handles error state when API fails', async () => {
    // Mock API failure
    enhancedDashboardApi.refreshData.mockRejectedValueOnce(new Error('Failed to load data'));

    render(<EnhancedDashboard />);

    // Wait for error state to appear
    await waitFor(() => {
      expect(screen.getByText('Error Loading Dashboard')).toBeInTheDocument();
      expect(screen.getByText('Failed to load data')).toBeInTheDocument();
    });

    // Should show a button to toggle data source
    const toggleButton = screen.getByText('Use Mock Data');
    expect(toggleButton).toBeInTheDocument();

    // Click the button to toggle data source
    fireEvent.click(toggleButton);

    // Check that a new API call was triggered
    expect(enhancedDashboardApi.refreshData).toHaveBeenCalledTimes(2);
  });

  test('cleans up resources on unmount', async () => {
    const { unmount } = render(<EnhancedDashboard />);

    // Wait for data to load
    await waitFor(() => {
      expect(screen.queryByText('Loading Dashboard...')).not.toBeInTheDocument();
    });

    // Unmount the component
    unmount();

    // Timeout should be cleared in the cleanup function
    // Unfortunately we can't easily test this directly, but we can verify
    // that no errors occur during unmount
  });

  test('displays footer with version information', async () => {
    render(<EnhancedDashboard />);

    // Wait for data to load
    await waitFor(() => {
      expect(screen.queryByText('Loading Dashboard...')).not.toBeInTheDocument();
    });

    // Check for footer with version
    expect(screen.getByText(`Cline AI Dashboard v${dashboardConfig.version}`)).toBeInTheDocument();
  });
});
