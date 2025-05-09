import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import '@testing-library/jest-dom';
import { ModelSelector } from '../components/ModelSelector';

describe('ModelSelector Component', () => {
  const mockModels = {
    selected: 'model1',
    available: [
      {
        id: 'model1',
        name: 'Test Model 1',
        contextWindow: 100000,
        costPerToken: 0.00002,
        capabilities: ['code', 'reasoning']
      },
      {
        id: 'model2',
        name: 'Test Model 2',
        contextWindow: 50000,
        costPerToken: 0.00001,
        capabilities: ['text']
      },
      {
        id: 'model3',
        name: 'Test Model 3 with null cost',
        contextWindow: 25000,
        costPerToken: null,
        capabilities: ['vision']
      }
    ],
    recommendedFor: {
      task1: 'model1',
      task2: 'model2'
    }
  };

  test('renders all models correctly', () => {
    const onSelectMock = jest.fn();
    render(<ModelSelector modelData={mockModels} onModelSelect={onSelectMock} />);

    // Check if all models are rendered
    expect(screen.getByText('Test Model 1')).toBeInTheDocument();
    expect(screen.getByText('Test Model 2')).toBeInTheDocument();
    expect(screen.getByText('Test Model 3 with null cost')).toBeInTheDocument();
  });

  test('shows current model as selected', () => {
    render(<ModelSelector modelData={mockModels} onModelSelect={jest.fn()} />);

    // Selected model should have "Current" badge
    expect(screen.getByText('Current')).toBeInTheDocument();

    // Selected model should have "Selected" button
    expect(screen.getByText('Selected')).toBeInTheDocument();
  });

  test('calls onModelSelect when a model is clicked', () => {
    const onSelectMock = jest.fn();
    render(<ModelSelector modelData={mockModels} onModelSelect={onSelectMock} />);

    // Find the "Select" button for model2 (which is not the selected model)
    const selectButton = screen.getAllByText('Select')[0];
    fireEvent.click(selectButton);

    // Verify the callback was called
    expect(onSelectMock).toHaveBeenCalled();
  });

  test('handles null cost values', () => {
    render(<ModelSelector modelData={mockModels} onModelSelect={jest.fn()} />);

    // All models should be rendered without errors, including the one with null cost
    expect(screen.getByText('Test Model 3 with null cost')).toBeInTheDocument();
  });
});
