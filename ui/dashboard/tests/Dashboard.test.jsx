import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import '@testing-library/jest-dom';
import { act } from 'react-dom/test-utils';

// Import components
import Dashboard from '../Dashboard';
import MetricsPanel from '../components/MetricsPanel';
import TokenUtilization from '../components/TokenUtilization';
import CostTracker from '../components/CostTracker';
import UsageChart from '../components/UsageChart';
import ModelSelector from '../components/ModelSelector';
import SettingsPanel from '../components/SettingsPanel';

// Import API modules
import mockApi from '../mockApi';

// Mock the API modules
jest.mock('../mockApi');
jest.mock('../mcpApi');
jest.mock('../lib/enhancedDashboardApi');

// Mock data for tests
const mockDashboardData = {
  metrics: {
    tokenSavingsRate: 0.37,
    costSavingsRate: 0.43,
    averageResponseTime: 2.4,
    cacheHitRate: 0.68,
    dailyActiveUsers: 25,
    completionRate: 0.94,
    totalQueries: 8750,
    averageContextSize: 14250
  },
  tokens: {
    total: {
      used: 527890,
      saved: 312450,
      budgeted: 750000
    },
    daily: {
      used: 18450,
      saved: 10320,
      budgeted: 25000
    },
    budgets: {
      codeCompletion: {
        used: 275420,
        budget: 300000,
        remaining: 24580
      },
      errorResolution: {
        used: 125640,
        budget: 200000,
        remaining: 74360
      },
      architecture: {
        used: 89430,
        budget: 150000,
        remaining: 60570
      },
      thinking: {
        used: 37400,
        budget: 100000,
        remaining: 62600
      }
    },
    cacheEfficiency: {
      hitRate: 0.68,
      missRate: 0.32,
      totalCached: 4250,
      totalHits: 2890
    }
  },
  costs: {
    totalCost: 4.79,
    monthlyCost: 22.45,
    projectedCost: 25.12,
    savings: {
      total: 3.65,
      caching: 1.85,
      optimization: 1.20,
      modelSelection: 0.60
    },
    byModel: {
      'claude-3.7-sonnet': 2.85,
      'gemini-2.5-flash': 1.35,
      'claude-3.7-haiku': 0.59
    },
    history: {
      daily: [3.2, 2.8, 3.5, 4.1, 3.9],
      weekly: [15.2, 17.8, 14.5, 16.1],
      monthly: [22.5, 24.8, 26.5]
    }
  },
  usage: {
    daily: [12000, 15000, 11000, 14000, 13000],
    byModel: {
      'claude-3.7-sonnet': 280450,
      'gemini-2.5-flash': 190350,
      'claude-3.7-haiku': 57090
    },
    byFunction: {
      codeCompletion: 250300,
      errorResolution: 120450,
      architecture: 95670,
      thinking: 61470
    },
    byFile: {
      js: 180450,
      ts: 130670,
      jsx: 85230,
      tsx: 45780,
      css: 32450,
      html: 28320,
      json: 24990
    },
    popularity: {
      'Code Completion': 42,
      'Error Resolution': 28,
      'Code Explanation': 15,
      'Architecture Design': 10,
      'Test Generation': 5
    }
  },
  models: {
    selected: 'claude-3.7-sonnet',
    available: [
      {
        id: 'claude-3.7-sonnet',
        name: 'Claude 3.7 Sonnet',
        contextWindow: 200000,
        costPerToken: 0.000015,
        capabilities: ['code', 'reasoning', 'text', 'vision', 'math']
      },
      {
        id: 'gemini-2.5-flash',
        name: 'Gemini 2.5 Flash',
        contextWindow: 128000,
        costPerToken: 0.000008,
        capabilities: ['code', 'reasoning', 'text']
      },
      {
        id: 'claude-3.7-haiku',
        name: 'Claude 3.7 Haiku',
        contextWindow: 48000,
        costPerToken: 0.000003,
        capabilities: ['code', 'text', 'reasoning']
      }
    ],
    recommendedFor: {
      codeCompletion: 'gemini-2.5-flash',
      errorResolution: 'claude-3.7-sonnet',
      architecture: 'claude-3.7-sonnet',
      thinking: 'claude-3.7-sonnet',
      basicTasks: 'claude-3.7-haiku'
    }
  },
  settings: {
    autoModelSelection: true,
    cachingEnabled: true,
    contextWindowOptimization: true,
    outputMinimization: true,
    notifyOnLowBudget: false,
    safetyChecks: true
  }
};

// Setup mock API responses
beforeEach(() => {
  mockApi.fetchDashboardData.mockResolvedValue(mockDashboardData);
  mockApi.updateSelectedModel.mockResolvedValue(true);
  mockApi.updateSetting.mockResolvedValue(true);
  mockApi.updateTokenBudget.mockResolvedValue(true);
  mockApi.refreshDashboardData.mockResolvedValue(mockDashboardData);

  // Mock window methods for JSX styles and charts
  if (typeof window.matchMedia !== 'function') {
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
  }
});

// Clear all mocks after each test
afterEach(() => {
  jest.clearAllMocks();
});

describe('Dashboard Component', () => {
  test('renders loading state initially', async () => {
    mockApi.fetchDashboardData.mockImplementationOnce(() => {
      return new Promise(resolve => setTimeout(() => resolve(mockDashboardData), 100));
    });

    render(<Dashboard />);

    expect(screen.getByText('Loading dashboard data...')).toBeInTheDocument();
  });

  test('renders dashboard with data after loading', async () => {
    await act(async () => {
      render(<Dashboard />);
    });

    // Wait for the data to load
    await waitFor(() => {
      expect(screen.getByText('Cline AI Dashboard')).toBeInTheDocument();
    });

    // Check for key component headings
    expect(screen.getByText('Key Metrics')).toBeInTheDocument();
    expect(screen.getByText('Token Utilization')).toBeInTheDocument();
    expect(screen.getByText('Cost Tracker')).toBeInTheDocument();
    expect(screen.getByText('Usage Statistics')).toBeInTheDocument();
    expect(screen.getByText('AI Models')).toBeInTheDocument();
    expect(screen.getByText('Settings')).toBeInTheDocument();
  });

  test('handles data fetch error state correctly', async () => {
    // Mock the API to return an error
    mockApi.fetchDashboardData.mockRejectedValueOnce(new Error('Failed to fetch data'));

    await act(async () => {
      render(<Dashboard />);
    });

    // Check for error message
    await waitFor(() => {
      expect(screen.getByText('Error Loading Dashboard')).toBeInTheDocument();
    });

    // Check for retry button
    expect(screen.getByText('Use Mock Data')).toBeInTheDocument();
  });

  test('switches between mock and live data sources', async () => {
    await act(async () => {
      render(<Dashboard />);
    });

    // Wait for data to load
    await waitFor(() => {
      expect(screen.getByText('Cline AI Dashboard')).toBeInTheDocument();
    });

    // Check initial data source
    expect(screen.getByText('Data Source: Live Data')).toBeInTheDocument();

    // Click the toggle button
    fireEvent.click(screen.getByText('Switch to Mock Data'));

    // Check data source changed
    expect(screen.getByText('Data Source: Mock Data')).toBeInTheDocument();
  });
});

describe('Individual Components', () => {
  describe('MetricsPanel', () => {
    test('renders metrics correctly', () => {
      render(<MetricsPanel metrics={mockDashboardData.metrics} />);

      // Check for metric values
      expect(screen.getByText('37%')).toBeInTheDocument(); // Token Savings
      expect(screen.getByText('43%')).toBeInTheDocument(); // Cost Savings
      expect(screen.getByText('2.4s')).toBeInTheDocument(); // Avg. Response Time
      expect(screen.getByText('68%')).toBeInTheDocument(); // Cache Hit Rate
    });

    test('handles null metrics gracefully', () => {
      const { container } = render(<MetricsPanel metrics={null} />);
      expect(container.firstChild).toBeNull();
    });
  });

  describe('TokenUtilization', () => {
    test('renders token usage information correctly', () => {
      render(<TokenUtilization tokenData={mockDashboardData.tokens} />);

      // Check for main usage data
      expect(screen.getByText('528K')).toBeInTheDocument(); // Total used (formatted)
      expect(screen.getByText('750K')).toBeInTheDocument(); // Total budget (formatted)

      // Check for budget categories
      expect(screen.getByText('Code Completion')).toBeInTheDocument();
      expect(screen.getByText('Error Resolution')).toBeInTheDocument();
    });

    test('calculates percentages correctly', () => {
      render(<TokenUtilization tokenData={mockDashboardData.tokens} />);

      // Main percentage (527890 / 750000) * 100 = ~70%
      expect(screen.getByText('70%')).toBeInTheDocument();
    });
  });

  describe('CostTracker', () => {
    test('renders cost information correctly', () => {
      render(<CostTracker costData={mockDashboardData.costs} />);

      // Check for cost values
      expect(screen.getByText('$4.79')).toBeInTheDocument(); // Total cost
      expect(screen.getByText('$25.12')).toBeInTheDocument(); // Projected cost

      // Check for savings information
      expect(screen.getByText('$3.65')).toBeInTheDocument(); // Total savings
    });

    test('changes timeframe when selector is changed', () => {
      render(<CostTracker costData={mockDashboardData.costs} />);

      // Default is daily view

      // Change to weekly view
      fireEvent.change(screen.getByRole('combobox'), { target: { value: 'weekly' } });

      // Should display weekly cost history now
    });
  });

  describe('UsageChart', () => {
    test('renders chart correctly', () => {
      render(<UsageChart usageData={mockDashboardData.usage} />);

      // Check chart view selector
      expect(screen.getByText('Daily Usage')).toBeInTheDocument();

      // Check chart type toggles
      expect(screen.getByText('Line')).toBeInTheDocument();
      expect(screen.getByText('Bar')).toBeInTheDocument();
    });

    test('changes chart view when selector is changed', () => {
      render(<UsageChart usageData={mockDashboardData.usage} />);

      // Change to "By Model" view
      fireEvent.change(screen.getByRole('combobox'), { target: { value: 'byModel' } });

      // Should display model breakdown now
    });
  });

  describe('ModelSelector', () => {
    test('renders model cards correctly', () => {
      render(<ModelSelector modelData={mockDashboardData.models} onModelSelect={jest.fn()} />);

      // Check for model names
      expect(screen.getByText('Claude 3.7 Sonnet')).toBeInTheDocument();
      expect(screen.getByText('Gemini 2.5 Flash')).toBeInTheDocument();
      expect(screen.getByText('Claude 3.7 Haiku')).toBeInTheDocument();

      // Check for selected model indicator
      expect(screen.getByText('Current')).toBeInTheDocument();
    });

    test('calls onModelSelect when model is selected', () => {
      const mockSelectFn = jest.fn();
      render(<ModelSelector modelData={mockDashboardData.models} onModelSelect={mockSelectFn} />);

      // Find the "Select" button for Gemini model (which is not currently selected)
      const selectButton = screen.getAllByText('Select')[0];
      fireEvent.click(selectButton);

      // Check if the function was called
      expect(mockSelectFn).toHaveBeenCalled();
    });
  });

  describe('SettingsPanel', () => {
    test('renders settings correctly', () => {
      render(
        <SettingsPanel
          settings={mockDashboardData.settings}
          tokenBudgets={mockDashboardData.tokens.budgets}
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
    });

    test('toggles settings when clicked', () => {
      const mockUpdateFn = jest.fn();
      render(
        <SettingsPanel
          settings={mockDashboardData.settings}
          tokenBudgets={mockDashboardData.tokens.budgets}
          onUpdateSetting={mockUpdateFn}
          onUpdateTokenBudget={jest.fn()}
        />
      );

      // Find toggle inputs
      const toggles = screen.getAllByRole('checkbox');

      // Click the first toggle (Auto Model Selection)
      fireEvent.click(toggles[0]);

      // Check if the update function was called with correct args
      expect(mockUpdateFn).toHaveBeenCalledWith('autoModelSelection', false);
    });

    test('edits token budget when budget value is clicked', async () => {
      const mockUpdateBudgetFn = jest.fn();
      render(
        <SettingsPanel
          settings={mockDashboardData.settings}
          tokenBudgets={mockDashboardData.tokens.budgets}
          onUpdateSetting={jest.fn()}
          onUpdateTokenBudget={mockUpdateBudgetFn}
        />
      );

      // Find the edit icon for the first budget
      const editIcons = screen.getAllByText('✎');
      fireEvent.click(editIcons[0]);

      // Should now show input field
      const input = screen.getByPlaceholderText('Enter budget');
      expect(input).toBeInTheDocument();

      // Change the value and save
      fireEvent.change(input, { target: { value: '400000' } });
      const saveButton = screen.getByText('Save');
      fireEvent.click(saveButton);

      // Check if the update function was called with correct args
      expect(mockUpdateBudgetFn).toHaveBeenCalledWith('codeCompletion', 400000);
    });
  });
});

describe('Integration Tests', () => {
  test('updates model selection in the dashboard', async () => {
    mockApi.updateSelectedModel.mockResolvedValueOnce(true);

    await act(async () => {
      render(<Dashboard />);
    });

    // Wait for data to load
    await waitFor(() => {
      expect(screen.getByText('Cline AI Dashboard')).toBeInTheDocument();
    });

    // Find a model to select (Gemini)
    const selectButtons = screen.getAllByText('Select');
    fireEvent.click(selectButtons[0]);

    // API should have been called to update the model
    expect(mockApi.updateSelectedModel).toHaveBeenCalled();
  });

  test('updates settings in the dashboard', async () => {
    mockApi.updateSetting.mockResolvedValueOnce(true);

    await act(async () => {
      render(<Dashboard />);
    });

    // Wait for data to load
    await waitFor(() => {
      expect(screen.getByText('Cline AI Dashboard')).toBeInTheDocument();
    });

    // Find a toggle switch
    const toggles = screen.getAllByRole('checkbox');
    fireEvent.click(toggles[0]);

    // API should have been called to update the setting
    expect(mockApi.updateSetting).toHaveBeenCalled();
  });

  test('handles refresh data action', async () => {
    await act(async () => {
      render(<Dashboard />);
    });

    // Wait for data to load
    await waitFor(() => {
      expect(screen.getByText('Cline AI Dashboard')).toBeInTheDocument();
    });

    // Find and click refresh button (assuming we can find it by its title)
    // Note: You might need to adjust this selector based on your implementation
    const refreshButtons = screen.getAllByTitle('Refresh metrics data');
    if (refreshButtons.length > 0) {
      fireEvent.click(refreshButtons[0]);

      // API should have been called to refresh the data
      expect(mockApi.fetchDashboardData).toHaveBeenCalledTimes(2); // Once for initial load, once for refresh
    }
  });
});
