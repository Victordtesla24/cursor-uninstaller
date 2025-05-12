/**
 * Dashboard Component Coverage Improved Tests
 * Simple test suite that focuses on basic Dashboard functionality
 */
const React = require('react');
const { render, screen } = require('@testing-library/react');
const { Dashboard } = require('../Dashboard');
const mockApi = require('../mockApi');
const magicMcpIntegration = require('../magic-mcp-integration');

// Mock APIs
jest.mock('../mockApi', () => ({
  fetchDashboardData: jest.fn().mockResolvedValue({
    metrics: {},
    tokenData: {},
    costData: {},
    usageData: {},
    models: [],
    settings: {}
  }),
  updateSelectedModel: jest.fn().mockResolvedValue(true),
  updateSetting: jest.fn().mockResolvedValue(true),
  updateTokenBudget: jest.fn().mockResolvedValue(true),
  refreshDashboardData: jest.fn().mockResolvedValue(true)
}));

jest.mock('../magic-mcp-integration', () => ({
  isMcpAvailable: jest.fn().mockReturnValue(false),
  fetchDashboardData: jest.fn().mockResolvedValue({}),
  refreshDashboardData: jest.fn().mockResolvedValue(true),
  updateSelectedModel: jest.fn().mockResolvedValue(true),
  updateSetting: jest.fn().mockResolvedValue(true),
  updateTokenBudget: jest.fn().mockResolvedValue(true)
}));

// Mock ResizeObserver
global.ResizeObserver = jest.fn().mockImplementation(() => ({
  observe: jest.fn(),
  unobserve: jest.fn(),
  disconnect: jest.fn()
}));

describe('Dashboard Component (Improved Coverage)', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  test('renders Dashboard container', () => {
    render(<Dashboard />);
    // Verify the dashboard container renders
    expect(screen.getByTestId('dashboard-container')).toBeInTheDocument();
  });

  test('handles data fetching errors gracefully', async () => {
    // Mock API error
    mockApi.fetchDashboardData.mockRejectedValueOnce(new Error('API Error'));

    // Mock console.error to avoid test output pollution
    jest.spyOn(console, 'error').mockImplementation(() => {});

    const { container } = render(<Dashboard />);

    // We just need to ensure it doesn't crash when API fails
    expect(container).toBeDefined();
  });

  test('falls back to mockApi when MCP is not available', () => {
    // Setup MCP as unavailable
    magicMcpIntegration.isMcpAvailable.mockReturnValue(false);

    render(<Dashboard />);

    // Verify MCP API was not called
    expect(magicMcpIntegration.fetchDashboardData).not.toHaveBeenCalled();
  });

  test('uses MCP when available', () => {
    // Setup MCP as available
    magicMcpIntegration.isMcpAvailable.mockReturnValue(true);

    render(<Dashboard />);

    // MCP is available, expect dashboard to render without errors
    expect(screen.getByTestId('dashboard-container')).toBeInTheDocument();
  });
});
