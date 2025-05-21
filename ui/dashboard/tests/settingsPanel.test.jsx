import React from 'react';
import { render } from '@testing-library/react';
import '@testing-library/jest-dom';
import SettingsPanel from '../components/SettingsPanel';

describe('SettingsPanel Component', () => {
  const mockSettings = {
    darkMode: true,
    notifications: false,
    autoRefresh: true
  };

  test('renders successfully', () => {
    const { container } = render(<SettingsPanel settings={mockSettings} />);
    expect(container).toBeTruthy();
  });
});
