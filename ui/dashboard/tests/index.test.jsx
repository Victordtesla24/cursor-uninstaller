import React from 'react';
import { render, screen, waitFor, act } from '@testing-library/react';
import '@testing-library/jest-dom';
import { Dashboard } from '../index';
import * as magicMcp from '../magic-mcp-integration';
import mockApi from '../mockApi';

// Mock magic-mcp-integration module
jest.mock('../magic-mcp-integration', () => ({
  initializeDashboard: jest.fn(),
  isMcpAvailable: jest.fn(),
  fetchDashboardData: jest.fn(),
  updateSelectedModel: jest.fn(),
  useMagicMcpDashboard: jest.fn()
}));

// Mock mockApi
jest.mock('../mockApi', () => ({
  fetchDashboardData: jest.fn(),
  updateSelectedModel: jest.fn(),
  updateSetting: jest.fn(),
  updateTokenBudget: jest.fn(),
  refreshDashboardData: jest.fn()
}));

describe('Dashboard Index Component', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    
    // Default mock implementations
    magicMcp.isMcpAvailable.mockReturnValue(true);
    magicMcp.fetchDashboardData.mockResolvedValue({
      tokens: { total: { used: 100, budgeted: 1000 } },
      models: { selected: 'test-model' },
      settings: {},
      metrics: {},
      costs: {},
      usage: {}
    });
    
    mockApi.fetchDashboardData.mockResolvedValue({
      tokens: { total: { used: 100, budgeted: 1000 } },
      models: { selected: 'test-model' },
      settings: {},
      metrics: {},
      costs: {},
      usage: {}
    });
  });
  
  test('renders dashboard component without crashing', async () => {
    await act(async () => {
      render(<Dashboard />);
    });
    
    await waitFor(() => {
      expect(screen.queryByTestId('dashboard-container')).toBeInTheDocument();
    });
  });
  
  test('renders dashboard component with data', async () => {
    await act(async () => {
      render(<Dashboard />);
    });
    
    // Wait for the dashboard to render
    await waitFor(() => {
      // Look for any core component that would be rendered in the dashboard
      const dashboardElement = screen.queryByTestId('dashboard-container');
      expect(dashboardElement).toBeInTheDocument();
    });
  });
  
  test('handles loading state correctly', async () => {
    // Mock a loading state
    magicMcp.fetchDashboardData.mockImplementationOnce(() => {
      return new Promise(resolve => {
        // Resolve after a delay to simulate loading
        setTimeout(() => {
          resolve({
            tokens: { total: { used: 100, budgeted: 1000 } },
            models: { selected: 'test-model' },
            settings: {},
            metrics: {},
            costs: {},
            usage: {}
          });
        }, 100);
      });
    });
    
    render(<Dashboard />);
    
    // Initially should show loading indicator
    expect(screen.getByText(/Loading dashboard data/i)).toBeInTheDocument();
    
    // After data loads, the dashboard should be displayed
    await waitFor(() => {
      expect(screen.queryByTestId('dashboard-container')).toBeInTheDocument();
    });
  });
  
  test('handles error state correctly', async () => {
    // Mock a failure
    magicMcp.fetchDashboardData.mockRejectedValueOnce(new Error('Failed to load dashboard data'));
    
    await act(async () => {
      render(<Dashboard />);
    });
    
    // Should show error message
    await waitFor(() => {
      const errorElement = screen.queryByText(/Failed to load dashboard data/i);
      expect(errorElement).toBeInTheDocument();
    });
  });
}); 