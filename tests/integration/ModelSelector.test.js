import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import '@testing-library/jest-dom';

// Mock UI components that ModelSelector depends on
// ModelSelector imports from '../ui/index.js' relative to src/components/features/
jest.mock('../../src/components/ui/index.js', () => ({
  Card: ({ children, className }) => <div className={`card ${className || ''}`}>{children}</div>,
  CardContent: ({ children, className }) => <div className={`card-content ${className || ''}`}>{children}</div>,
  CardDescription: ({ children }) => <div>{children}</div>,
  CardHeader: ({ children, className }) => <div className={`card-header ${className || ''}`}>{children}</div>,
  CardTitle: ({ children, className }) => <div className={`card-title ${className || ''}`}>{children}</div>,
  Badge: ({ children, variant, className }) => <span className={`badge ${variant || ''} ${className || ''}`}>{children}</span>,
  Button: ({ children, variant, size, className, disabled, onClick }) => (
    <button 
      className={`button ${variant || ''} ${size || ''} ${className || ''}`} 
      disabled={disabled} 
      onClick={onClick}
    >
      {children}
    </button>
  ),
  Tooltip: ({ children }) => <div>{children}</div>,
  TooltipContent: ({ children }) => <div>{children}</div>,
  TooltipProvider: ({ children }) => <div>{children}</div>,
  TooltipTrigger: ({ children, asChild }) => asChild ? children : <div>{children}</div>,
  Separator: ({ className }) => <hr className={className || ''} />
}));

// Mock Lucide React icons
jest.mock('lucide-react', () => ({
  Code2: () => <span data-testid="icon-code">Code Icon</span>,
  BrainCircuit: () => <span data-testid="icon-brain">Brain Icon</span>,
  TextIcon: () => <span data-testid="icon-text">Text Icon</span>,
  Eye: () => <span data-testid="icon-eye">Eye Icon</span>,
  Calculator: () => <span data-testid="icon-calculator">Calculator Icon</span>,
  CheckCircle: () => <span data-testid="icon-check">Check Icon</span>,
  CheckCircle2: () => <span data-testid="icon-check2">Check2 Icon</span>,
  Sparkles: () => <span data-testid="icon-sparkles">Sparkles Icon</span>,
}));

import { ModelSelector } from '../../src/components/features/ModelSelector';

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

    // Check if all models are rendered by their test IDs
    expect(screen.getByTestId('model-name-model1')).toHaveTextContent('Test Model 1');
    expect(screen.getByTestId('model-name-model2')).toHaveTextContent('Test Model 2');
    expect(screen.getByTestId('model-name-model3')).toHaveTextContent('Test Model 3 with null cost');
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

    // Verify the callback was called with the correct model ID
    expect(onSelectMock).toHaveBeenCalledWith('model2');
  });

  test('handles null cost values', () => {
    render(<ModelSelector modelData={mockModels} onModelSelect={jest.fn()} />);

    // All models should be rendered without errors, including the one with null cost
    expect(screen.getByTestId('model-name-model3')).toHaveTextContent('Test Model 3 with null cost');
  });
});
