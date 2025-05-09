import React from 'react';
import { render, screen, fireEvent, waitFor, act } from '@testing-library/react';
import ClineDashboard from '../index.jsx';
import * as mcpApi from '../mcpApi';

// Mock the MCP API
jest.mock('../mcpApi', () => ({
  fetchDashboardData: jest.fn(),
  updateSelectedModel: jest.fn(),
  updateSetting: jest.fn(),
  updateTokenBudget: jest.fn(),
  refreshDashboardData: jest.fn()
}));

// Suppress console errors for cleaner test output
const originalConsoleError = console.error;
beforeAll(() => {
  console.error = jest.fn();
});

afterAll(() => {
  console.error = originalConsoleError;
});

// Sample dashboard data that matches the MCP server format
const mockDashboardData = {
  dailyUsage: [
    { date: '2025-05-01', requests: 100, tokens: 10000, responseTime: 1.2 },
    { date: '2025-05-02', requests: 120, tokens: 12000, responseTime: 1.3 }
  ],
  modelStats: {
    'claude-3.7-sonnet': {
      name: 'Claude 3.7 Sonnet',
      tokenPrice: 0.03,
      bestFor: ['Error Resolution', 'Architecture'],
      responseTime: 2.1,
      maxTokens: 200000
    },
    'gemini-2.5-flash': {
      name: 'Gemini 2.5 Flash',
      tokenPrice: 0.002,
      bestFor: ['Code Completion', 'Small Tasks'],
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
    total: { used: 4100, budget: 5800 }
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
  systemHealth: 'optimal',
  selectedModel: 'claude-3.7-sonnet',
  settings: {
    autoModelSelection: true,
    cachingEnabled: true,
    contextWindowOptimization: true,
    outputMinimization: true,
    notifyOnLowBudget: true,
    safetyChecks: true
  }
};

describe('ClineDashboard Integration Tests', () => {
  beforeEach(() => {
    // Clear all mocks
    jest.clearAllMocks();

    // Setup fetchDashboardData to return our mock data
    mcpApi.fetchDashboardData.mockResolvedValue(mockDashboardData);
    mcpApi.updateSelectedModel.mockResolvedValue(true);
    mcpApi.refreshDashboardData.mockResolvedValue(true);
  });

  test('fetches and displays dashboard data from MCP server', async () => {
    render(<ClineDashboard />);

    // Verify the API was called
    expect(mcpApi.fetchDashboardData).toHaveBeenCalledTimes(1);

    // Wait for data to load
    await waitFor(() => {
      // Verify key metrics are displayed
      expect(screen.getByText('Key Metrics')).toBeInTheDocument();
      expect(screen.getByText('Usage Statistics')).toBeInTheDocument();
      expect(screen.getByText('Token Utilization')).toBeInTheDocument();
      expect(screen.getByText('Cost Metrics')).toBeInTheDocument();
      expect(screen.getByText('Model Selection')).toBeInTheDocument();

      // Verify system status
      expect(screen.getByText(/System: optimal/)).toBeInTheDocument();
      expect(screen.getByText(/Active Requests: 3/)).toBeInTheDocument();
    });
  });

  test('updates selected model via MCP API', async () => {
    render(<ClineDashboard />);

    // Wait for initial data to load
    await waitFor(() => {
      expect(screen.getByText('Model Selection')).toBeInTheDocument();
    });

    // Find and click on the Gemini model card
    // Note: The exact selector may need to be adjusted based on your ModelSelector implementation
    const geminiCard = await screen.findByTestId('model-card-gemini-2.5-flash');
    fireEvent.click(geminiCard);

    // Verify updateSelectedModel was called with the correct model
    expect(mcpApi.updateSelectedModel).toHaveBeenCalledWith('gemini-2.5-flash');

    // Verify refreshDashboardData was called to get updated data
    await waitFor(() => {
      expect(mcpApi.refreshDashboardData).toHaveBeenCalled();
      expect(mcpApi.fetchDashboardData).toHaveBeenCalled(); // Called at least once more
    });
  });

  test('refreshes data when refresh button is clicked', async () => {
    render(<ClineDashboard />);

    // Wait for initial data to load
    await waitFor(() => {
      expect(screen.getByText('Key Metrics')).toBeInTheDocument();
    });

    // Find and click the refresh button
    const refreshButton = screen.getByTestId('refresh-button');
    fireEvent.click(refreshButton);

    // Verify refreshDashboardData was called
    expect(mcpApi.refreshDashboardData).toHaveBeenCalled();

    // Verify fetchDashboardData was called to get updated data
    await waitFor(() => {
      expect(mcpApi.fetchDashboardData).toHaveBeenCalledTimes(2); // Initial + refresh
    });
  });

  test('handles failed MCP server connections gracefully', async () => {
    // Setup fetchDashboardData to fail once, then succeed
    mcpApi.fetchDashboardData
      .mockRejectedValueOnce(new Error('MCP server error'))
      .mockResolvedValueOnce(mockDashboardData);

    // Silence console.error for this test
    jest.spyOn(console, 'error').mockImplementation(() => {});

    render(<ClineDashboard />);

    // Verify the API was called and failed
    expect(mcpApi.fetchDashboardData).toHaveBeenCalledTimes(1);

    // Wait for the component to handle the error
    await waitFor(() => {
      // The dashboard should still be rendered with default state
      expect(screen.getByText('Cline AI Dashboard')).toBeInTheDocument();
    });

    // Find and click the refresh button
    const refreshButton = screen.getByTestId('refresh-button');
    fireEvent.click(refreshButton);

    // Verify refreshDashboardData was called
    expect(mcpApi.refreshDashboardData).toHaveBeenCalled();

    // Wait for data to load after refresh
    await waitFor(() => {
      // Verify fetchDashboardData was called again
      expect(mcpApi.fetchDashboardData).toHaveBeenCalledTimes(2);

      // Verify system status is now displayed correctly
      expect(screen.getByText(/System: optimal/)).toBeInTheDocument();
    });

    // Restore console.error
    console.error.mockRestore();
  });
});
