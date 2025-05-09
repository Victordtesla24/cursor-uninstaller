import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import ClineDashboard from '../index.jsx';
import { MetricsPanel } from '../components/MetricsPanel';
import { UsageStats } from '../components/UsageStats';
import { TokenUtilization } from '../components/TokenUtilization';
import { CostTracker } from '../components/CostTracker';
import { ModelSelector } from '../components/ModelSelector';
import { SettingsPanel } from '../components/SettingsPanel';
import { Header, __TEST_ONLY_toggleTheme } from '../components/Header';
import * as mockApi from '../mockApi';

// Mock fetchDashboardData function
jest.mock('../mockApi', () => ({
  fetchDashboardData: jest.fn(() => Promise.resolve({
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
      currentMonth: 25.50,
      previousMonth: 32.75,
      savings: 15.30,
      breakdown: {
        codeCompletion: 8.2,
        errorResolution: 12.5,
        architecture: 4.8
      },
      byModel: {
        'claude-3.7-sonnet': 18.75,
        'gemini-2.5-flash': 6.75
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
  }))
}));

describe('ClineDashboard Component', () => {
  beforeEach(() => {
    mockApi.fetchDashboardData.mockClear();
  });

  test('renders the main dashboard', async () => {
    render(<ClineDashboard />);

    // Check that the header is rendered
    expect(screen.getByText('Cline AI Dashboard')).toBeInTheDocument();

    // Wait for fetch to complete and component to update
    await waitFor(() => {
      // Check that all the panels are rendered with their section titles
      expect(screen.getByText('Key Metrics')).toBeInTheDocument();
      expect(screen.getByText('Usage Statistics')).toBeInTheDocument();
      expect(screen.getByText('Token Utilization')).toBeInTheDocument();
      expect(screen.getByText('Cost Metrics')).toBeInTheDocument();
      expect(screen.getByText('Model Selection')).toBeInTheDocument();

      // For Settings, use a more specific query to avoid multiple elements
      const settingsPanel = screen.getByText((content, element) => {
        return content === 'Settings' && element.tagName.toLowerCase() === 'span' &&
               element.parentElement.className.includes('section-title');
      });
      expect(settingsPanel).toBeInTheDocument();
    });

    // Check that the fetchDashboardData was called
    expect(mockApi.fetchDashboardData).toHaveBeenCalledTimes(1);
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
    expect(screen.getByText('270')).toBeInTheDocument(); // 120 + 150 requests
    expect(screen.getByText('68.0%')).toBeInTheDocument(); // Cache hit rate
  });

  test('UsageStats handles empty data', () => {
    render(<UsageStats usage={[]} className="test-class" />);

    expect(screen.getByText('Usage Statistics')).toBeInTheDocument();
    expect(screen.getByText('No usage data available yet')).toBeInTheDocument();
  });

  test('TokenUtilization renders budget information', () => {
    const tokenData = {
      codeCompletion: { used: 150, budget: 300 },
      errorResolution: { used: 950, budget: 1500 },
      architecture: { used: 0, budget: 2000 }, // Adding architecture with 0 used
      thinking: { used: 0, budget: 2000 }, // Adding thinking with 0 used
      total: { used: 1100, budget: 1800 }
    };

    render(<TokenUtilization tokenData={tokenData} className="test-class" />);

    expect(screen.getByText('Token Utilization')).toBeInTheDocument();
    expect(screen.getByText('Token Budget Utilization')).toBeInTheDocument();
    expect(screen.getByText('150 / 300')).toBeInTheDocument();
    expect(screen.getByText('950 / 1,500')).toBeInTheDocument();
  });

  test('CostTracker renders cost information', () => {
    const costData = {
      currentMonth: 25.50,
      previousMonth: 32.75,
      savings: 15.30,
      breakdown: {
        codeCompletion: 8.2,
        errorResolution: 12.5,
        architecture: 4.8
      },
      byModel: {
        'claude-3.7-sonnet': 18.75,
        'gemini-2.5-flash': 6.75
      }
    };

    render(<CostTracker costData={costData} className="test-class" />);

    expect(screen.getByText('Cost Metrics')).toBeInTheDocument();
    expect(screen.getByText('$25.50')).toBeInTheDocument();
    expect(screen.getByText('$15.30')).toBeInTheDocument();
    expect(screen.getByText(/from token optimization/)).toBeInTheDocument();
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
    render(<SettingsPanel className="test-class" />);

    expect(screen.getByText('Settings')).toBeInTheDocument();

    // Get the switch input for Auto Model Selection using aria-label
    const autoModelSwitch = screen.getByLabelText('Auto Model Selection');

    // Check that it's initially checked
    expect(autoModelSwitch).toBeChecked();

    // Click to toggle it off
    fireEvent.click(autoModelSwitch);

    // Check that it's now unchecked
    expect(autoModelSwitch).not.toBeChecked();
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
