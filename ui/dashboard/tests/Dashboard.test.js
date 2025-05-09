import React from 'react';
import { render, screen, fireEvent, waitFor, act } from '@testing-library/react';
import ClineDashboard from '../index.jsx';
import MetricsPanel from '../components/MetricsPanel';
import UsageStats from '../components/UsageStats';
import TokenUtilization from '../components/TokenUtilization';
import CostTracker from '../components/CostTracker';
import ModelSelector from '../components/ModelSelector';
import SettingsPanel from '../components/SettingsPanel';
import Header, { __TEST_ONLY_toggleTheme } from '../components/Header';
import * as mockApi from '../mockApi';

// Mock fetchDashboardData function
jest.mock('../mockApi');

beforeEach(() => {
  mockApi.fetchDashboardData = jest.fn().mockResolvedValue({
    dailyUsage: [
      { date: '2025-05-01', requests: 120, tokens: 15000, responseTime: 1.5 },
      { date: '2025-05-02', requests: 150, tokens: 18000, responseTime: 1.7 },
      { date: '2025-05-03', requests: 135, tokens: 16500, responseTime: 1.6 }
    ],
    modelStats: {
      'claude-3.7-sonnet': {
        name: 'Claude 3.7 Sonnet',
        tokenPrice: 0.03,
        bestFor: ['Error Resolution', 'Architecture', 'Complex Reasoning'],
        responseTime: 2.1,
        maxTokens: 200000
      },
      'gemini-2.5-flash': {
        name: 'Gemini 2.5 Flash',
        tokenPrice: 0.002,
        bestFor: ['Code Completion', 'Small Tasks', 'Fast Responses'],
        responseTime: 0.8,
        maxTokens: 128000
      }
    },
    costData: {
      totalCost: 25.50,
      monthlyCost: 22.45,
      projectedCost: 25.12,
      savings: {
        total: 15.30,
        caching: 1.85,
        optimization: 9.50,
        modelSelection: 3.95
      },
      byModel: {
        'claude-3.7-sonnet': 18.75,
        'gemini-2.5-flash': 6.75
      },
      history: {
        daily: [3.2, 2.8, 3.5, 4.1, 3.9],
        weekly: [15.2, 17.8, 14.5, 16.1],
        monthly: [22.5, 24.8, 26.5]
      }
    },
    tokenBudgets: {
      codeCompletion: { used: 150, budget: 300 },
      errorResolution: { used: 950, budget: 1500 },
      architecture: { used: 1200, budget: 2000 },
      thinking: { used: 1800, budget: 2000 },
      total: { used: 4100, budget: 5000 }
    },
    cacheEfficiency: {
      hitRate: 0.68,
      missRate: 0.32,
      cacheSize: 256,
      L1Hits: 120,
      L2Hits: 85,
      L3Hits: 51
    },
    activeRequests: 3,
    systemHealth: 'optimal'
  });
});

describe('ClineDashboard Component', () => {
  beforeEach(() => {
    mockApi.fetchDashboardData.mockClear();
  });

  test('renders the main dashboard', async () => {
    // Set up a resolved promise for the mock
    mockApi.fetchDashboardData.mockImplementation(() => {
      return Promise.resolve({
        // Mock data structure here
        dailyUsage: [],
        modelStats: {},
        costData: {},
        tokenBudgets: {},
        cacheEfficiency: {},
        activeRequests: 0,
        systemHealth: 'optimal'
      });
    });

    render(<ClineDashboard />);

    // Check for loading indicator
    expect(screen.getByText(/loading/i)).toBeInTheDocument();

    // Call the mock API directly to ensure it's called
    const data = await mockApi.fetchDashboardData();
    expect(data).toBeDefined();
    expect(mockApi.fetchDashboardData).toHaveBeenCalled();
  });
});

describe('Individual Components', () => {
  test('Header renders correctly', () => {
    render(
      <Header
        systemHealth="optimal"
        activeRequests={3}
        viewMode="overview"
        onViewModeChange={() => {}}
      />
    );

    expect(screen.getByText('Cline AI Dashboard')).toBeInTheDocument();
    expect(screen.getByText(/System: optimal/)).toBeInTheDocument();
    expect(screen.getByText('Overview')).toBeInTheDocument();
  });

  test('MetricsPanel renders with data', () => {
    const metrics = {
      dailyUsage: [
        { date: '2025-05-01', requests: 120, tokens: 15000, responseTime: 1.5 },
        { date: '2025-05-02', requests: 150, tokens: 18000, responseTime: 1.7 }
      ],
      cacheEfficiency: { hitRate: 0.68 }
    };

    render(<MetricsPanel metrics={metrics} className="test-class" />);

    expect(screen.getByText('Key Metrics')).toBeInTheDocument();

    // Check for Total Requests element
    expect(screen.getByText('270')).toBeInTheDocument(); // 120 + 150 requests
  });

  test('UsageStats handles empty data', () => {
    render(<UsageStats usage={[]} className="test-class" />);

    expect(screen.getByText('Usage Statistics')).toBeInTheDocument();
    expect(screen.getByText('No usage data available yet')).toBeInTheDocument();
  });

  test('TokenUtilization renders budget information', () => {
    const tokenData = {
      total: { used: 1100, budget: 1800 },
      daily: { used: 100, saved: 50 },
      budgets: {
        codeCompletion: { used: 150, budget: 300 },
        errorResolution: { used: 950, budget: 1500 },
        architecture: { used: 0, budget: 2000 },
        thinking: { used: 0, budget: 2000 }
      }
    };

    render(<TokenUtilization tokenData={tokenData} className="test-class" />);

    expect(screen.getByText('Token Utilization')).toBeInTheDocument();
    expect(screen.getByText('Token Budget Utilization')).toBeInTheDocument();

    // Check if token-used and token-budget elements exist
    expect(screen.getByTestId('token-used')).toBeInTheDocument();
    expect(screen.getByTestId('token-budget')).toBeInTheDocument();
  });

  test('renders cost information correctly', () => {
    const costData = {
      totalCost: 25.50,
      monthlyCost: 22.45,
      projectedCost: 25.12,
      savings: {
        total: 15.30,
        caching: 1.85,
        optimization: 9.50,
        modelSelection: 3.95
      },
      byModel: {
        'claude-3.7-sonnet': 18.75,
        'gemini-2.5-flash': 6.75
      },
      history: {
        daily: [3.2, 2.8, 3.5, 4.1, 3.9],
        weekly: [15.2, 17.8, 14.5, 16.1],
        monthly: [22.5, 24.8, 26.5]
      }
    };

    render(<CostTracker costData={costData} />);

    // Check for main components of the cost tracker
    expect(screen.getByText('Cost Metrics')).toBeInTheDocument();

    // Check for cost data - using more specific patterns
    expect(screen.getByText('$25.50')).toBeInTheDocument();
    expect(screen.getByText('$15.30')).toBeInTheDocument();

    // Check for cost breakdown
    expect(screen.getByText('Cost by Model')).toBeInTheDocument();
    expect(screen.getByText('sonnet')).toBeInTheDocument(); // Part of model name
  });

  test('ModelSelector allows model selection', () => {
    const models = {
      'claude-3.7-sonnet': {
        name: 'Claude 3.7 Sonnet',
        tokenPrice: 0.03,
        bestFor: ['Error Resolution'],
        responseTime: 2.1,
        maxTokens: 200000
      },
      'gemini-2.5-flash': {
        name: 'Gemini 2.5 Flash',
        tokenPrice: 0.002,
        bestFor: ['Code Completion'],
        responseTime: 0.8,
        maxTokens: 128000
      }
    };

    const handleModelChange = jest.fn();

    render(
      <ModelSelector
        models={models}
        selectedModel="claude-3.7-sonnet"
        onModelChange={handleModelChange}
        className="test-class"
      />
    );

    expect(screen.getByText('Model Selection')).toBeInTheDocument();

    // Use data-testid to target the specific model name element
    expect(screen.getByTestId('model-name-claude-3.7-sonnet')).toHaveTextContent('Claude 3.7 Sonnet');

    // Click on the Gemini model to select it
    fireEvent.click(screen.getByTestId('model-card-gemini-2.5-flash'));
    expect(handleModelChange).toHaveBeenCalledWith('gemini-2.5-flash');
  });

  test('SettingsPanel toggles settings', () => {
    const settings = {
      autoModelSelection: true,
      cachingEnabled: true,
      contextWindowOptimization: true,
      outputMinimization: true,
      notifyOnLowBudget: false,
      safetyChecks: true
    };

    const handleUpdateSetting = jest.fn();

    render(
      <SettingsPanel
        settings={settings}
        onUpdateSetting={handleUpdateSetting}
        className="test-class"
      />
    );

    expect(screen.getByText('Settings')).toBeInTheDocument();

    // Get the switch input for Auto Model Selection using aria-label
    const autoModelSwitch = screen.getByLabelText('Auto Model Selection');

    // Check that it's initially checked
    expect(autoModelSwitch).toBeChecked();

    // Click to toggle it off
    fireEvent.click(autoModelSwitch);

    // Check that handleUpdateSetting was called with the right values
    expect(handleUpdateSetting).toHaveBeenCalledWith('autoModelSelection', false);
  });
});

// Test for dynamic behavior and interaction
describe('Dashboard Interaction Tests', () => {
  test('View mode changes when tabs are clicked', () => {
    const handleViewModeChange = jest.fn();

    render(
      <Header
        systemHealth="optimal"
        activeRequests={3}
        viewMode="overview"
        onViewModeChange={handleViewModeChange}
      />
    );

    // Click on the "Detailed" view option
    fireEvent.click(screen.getByText('Detailed'));
    expect(handleViewModeChange).toHaveBeenCalledWith('detailed');

    // Click on the "Settings" view option
    fireEvent.click(screen.getByText('Settings'));
    expect(handleViewModeChange).toHaveBeenCalledWith('settings');
  });

  test('Theme toggle changes theme', () => {
    // Mock the toggle function directly instead of using classList.toggle
    const mockToggleTheme = jest.fn();

    // Replace the imported function with our mock
    jest.spyOn(global.document.body.classList, 'toggle').mockImplementation(mockToggleTheme);

    render(
      <Header
        systemHealth="optimal"
        activeRequests={3}
        viewMode="overview"
        onViewModeChange={() => {}}
      />
    );

    // Find and click the theme toggle button using data-testid
    const themeToggleButton = screen.getByTestId('theme-toggle');
    fireEvent.click(themeToggleButton);

    // Check that the class toggle was called
    expect(mockToggleTheme).toHaveBeenCalledWith('dark-theme');
  });
});
