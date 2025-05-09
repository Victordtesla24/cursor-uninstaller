import React from 'react';
import { render, screen, waitFor } from '@testing-library/react';
import '@testing-library/jest-dom';
import ClineDashboard from '../index.jsx';

describe('ClineDashboard Component', () => {
  // Capture console errors but don't output them in tests
  const originalConsoleError = console.error;

  beforeAll(() => {
    console.error = jest.fn();
  });

  afterAll(() => {
    console.error = originalConsoleError;
  });

  test('renders the dashboard wrapper', async () => {
    render(<ClineDashboard />);

    // The component should render a dashboard container div
    expect(screen.getByTestId('dashboard-container')).toBeInTheDocument();
  });
});
