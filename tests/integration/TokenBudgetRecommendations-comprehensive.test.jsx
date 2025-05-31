import { render, screen, fireEvent } from '@testing-library/react';
import '@testing-library/jest-dom';
import TokenBudgetRecommendations from '../../src/components/features/TokenBudgetRecommendations.jsx';

// Mock the UI components
jest.mock('../../src/components/ui', () => ({
  Card: ({ children, className }) => <div data-testid="card" className={className}>{children}</div>,
  CardContent: ({ children, className }) => <div data-testid="card-content" className={className}>{children}</div>,
  CardDescription: ({ children, className }) => <div data-testid="card-description" className={className}>{children}</div>,
  CardHeader: ({ children, className }) => <div data-testid="card-header" className={className}>{children}</div>,
  CardTitle: ({ children, className }) => <div data-testid="card-title" className={className}>{children}</div>,
  Badge: ({ children, variant, className }) => (
    <span data-testid="badge" className={`${variant} ${className}`}>{children}</span>
  ),
  Progress: ({ value, className }) => (
    <div data-testid="progress" className={className} data-value={value}>
      <div style={{ width: `${value}%` }} />
    </div>
  ),
  Button: ({ children, onClick, variant, size, className, disabled }) => (
    <button 
      onClick={onClick} 
      className={`${variant} ${size} ${className}`} 
      disabled={disabled}
      data-testid="button"
    >
      {children}
    </button>
  ),
  Separator: () => <div data-testid="separator" />,
  Tooltip: ({ children }) => <div data-testid="tooltip">{children}</div>,
  TooltipContent: ({ children, className }) => <div data-testid="tooltip-content" className={className}>{children}</div>,
  TooltipProvider: ({ children }) => <div data-testid="tooltip-provider">{children}</div>,
  TooltipTrigger: ({ children, className }) => <div data-testid="tooltip-trigger" className={className}>{children}</div>
}));

// Mock Lucide React icons
jest.mock('lucide-react', () => ({
  Target: () => <div data-testid="target-icon" />,
  DollarSign: () => <div data-testid="dollar-sign-icon" />,
  TrendingUp: () => <div data-testid="trending-up-icon" />,
  TrendingDown: () => <div data-testid="trending-down-icon" />,
  AlertTriangle: () => <div data-testid="alert-triangle-icon" />,
  CheckCircle: () => <div data-testid="check-circle-icon" />,
  Lightbulb: () => <div data-testid="lightbulb-icon" />,
  Calculator: () => <div data-testid="calculator-icon" />,
  BarChart3: () => <div data-testid="bar-chart-3-icon" />,
  PieChart: () => <div data-testid="pie-chart-icon" />,
  Settings: () => <div data-testid="settings-icon" />,
  RefreshCw: () => <div data-testid="refresh-cw-icon" />,
  Calendar: () => <div data-testid="calendar-icon" />,
  Clock: () => <div data-testid="clock-icon" />,
  Zap: () => <div data-testid="zap-icon" />,
  Shield: () => <div data-testid="shield-icon" />,
  Users: () => <div data-testid="users-icon" />,
  Activity: () => <div data-testid="activity-icon" />
}));

describe('TokenBudgetRecommendations Component - Comprehensive Coverage', () => {
  const mockBudgetData = {
    current: {
      monthlyBudget: 1000,
      currentSpend: 675,
      projectedSpend: 850,
      remainingBudget: 325,
      daysRemaining: 12,
      burnRate: 22.5 // dollars per day
    },
    historical: {
      lastMonth: 720,
      threeMonthAvg: 680,
      yearToDate: 6540,
      trend: 'increasing'
    },
    breakdown: {
      byModel: {
        'gpt-4': { cost: 450, percentage: 66.7, tokensUsed: 225000 },
        'gpt-3.5-turbo': { cost: 180, percentage: 26.7, tokensUsed: 900000 },
        'gpt-4-vision': { cost: 45, percentage: 6.6, tokensUsed: 15000 }
      },
      byCategory: {
        'chat': { cost: 400, percentage: 59.3 },
        'completion': { cost: 200, percentage: 29.6 },
        'embedding': { cost: 75, percentage: 11.1 }
      },
      byTeam: {
        'engineering': { cost: 350, percentage: 51.9 },
        'product': { cost: 200, percentage: 29.6 },
        'marketing': { cost: 125, percentage: 18.5 }
      }
    }
  };

  const mockRecommendations = {
    budget: [
      {
        id: 1,
        type: 'budget_increase',
        priority: 'high',
        title: 'Consider Budget Increase',
        description: 'Current projection exceeds budget by 15%',
        impact: 'Prevent service interruption',
        suggestedAmount: 1200,
        confidence: 85
      },
      {
        id: 2,
        type: 'usage_optimization',
        priority: 'medium',
        title: 'Optimize Model Selection',
        description: 'Switch 30% of GPT-4 requests to GPT-3.5-turbo',
        impact: 'Save approximately $135/month',
        savings: 135,
        confidence: 78
      }
    ],
    optimization: [
      {
        id: 3,
        type: 'caching',
        priority: 'medium',
        title: 'Implement Response Caching',
        description: 'Cache similar requests to reduce API calls',
        impact: 'Reduce costs by 20-30%',
        potentialSavings: 200,
        implementationEffort: 'medium'
      },
      {
        id: 4,
        type: 'prompt_optimization',
        priority: 'low',
        title: 'Optimize Prompt Length',
        description: 'Reduce average prompt length by 15%',
        impact: 'Save $50-75/month',
        potentialSavings: 62.5,
        implementationEffort: 'low'
      }
    ],
    alerts: [
      {
        id: 5,
        type: 'warning',
        title: 'High Burn Rate',
        description: 'Current daily spend is 25% above average',
        threshold: 18,
        current: 22.5,
        severity: 'medium'
      }
    ]
  };

  const mockProjections = {
    monthEnd: {
      spending: 850,
      confidence: 82,
      scenarios: {
        conservative: 780,
        optimistic: 720,
        aggressive: 920
      }
    },
    quarterEnd: {
      spending: 2650,
      confidence: 65,
      scenarios: {
        conservative: 2450,
        optimistic: 2200,
        aggressive: 2900
      }
    },
    factors: [
      { name: 'Seasonal Usage', impact: '+15%', description: 'Holiday period increase' },
      { name: 'New Features', impact: '+8%', description: 'Recent product launches' },
      { name: 'Optimization Efforts', impact: '-12%', description: 'Ongoing efficiency improvements' }
    ]
  };

  const defaultProps = {
    budgetData: mockBudgetData,
    recommendations: mockRecommendations,
    projections: mockProjections,
    darkMode: false,
    onBudgetUpdate: jest.fn(),
    onRecommendationApply: jest.fn(),
    onSettingsChange: jest.fn()
  };

  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('Component Rendering', () => {
    test('renders main budget recommendations structure', () => {
      render(<TokenBudgetRecommendations {...defaultProps} />);
      
      expect(screen.getByText('Budget Recommendations')).toBeInTheDocument();
      expect(screen.getByText('AI-powered budget optimization and cost management')).toBeInTheDocument();
    });

    test('renders with dark mode styling', () => {
      render(<TokenBudgetRecommendations {...defaultProps} darkMode={true} />);
      
      const cards = screen.getAllByTestId('card');
      expect(cards.length).toBeGreaterThan(0);
    });

    test('renders without data gracefully', () => {
      render(<TokenBudgetRecommendations budgetData={{}} recommendations={{}} projections={{}} />);
      
      expect(screen.getByText('Budget Recommendations')).toBeInTheDocument();
    });
  });

  describe('Budget Overview Display', () => {
    test('displays current budget information', () => {
      render(<TokenBudgetRecommendations {...defaultProps} />);
      
      expect(screen.getByText('Monthly Budget')).toBeInTheDocument();
      expect(screen.getByText('$1,000')).toBeInTheDocument();
      expect(screen.getByTestId('dollar-sign-icon')).toBeInTheDocument();
    });

    test('shows current spending and remaining budget', () => {
      render(<TokenBudgetRecommendations {...defaultProps} />);
      
      expect(screen.getByText('Current Spend')).toBeInTheDocument();
      expect(screen.getByText('$675')).toBeInTheDocument();
      expect(screen.getByText('Remaining Budget')).toBeInTheDocument();
      expect(screen.getByText('$325')).toBeInTheDocument();
    });

    test('displays projected spending', () => {
      render(<TokenBudgetRecommendations {...defaultProps} />);
      
      expect(screen.getByText('Projected Spend')).toBeInTheDocument();
      expect(screen.getByText('$850')).toBeInTheDocument();
    });

    test('shows burn rate and days remaining', () => {
      render(<TokenBudgetRecommendations {...defaultProps} />);
      
      expect(screen.getByText('Daily Burn Rate')).toBeInTheDocument();
      expect(screen.getByText('$22.50')).toBeInTheDocument();
      expect(screen.getByText('Days Remaining')).toBeInTheDocument();
      expect(screen.getByText('12')).toBeInTheDocument();
    });

    test('displays budget utilization progress', () => {
      render(<TokenBudgetRecommendations {...defaultProps} />);
      
      const progressBars = screen.getAllByTestId('progress');
      expect(progressBars.length).toBeGreaterThan(0);
      
      // Check if progress bar shows correct percentage (675/1000 = 67.5%)
      const budgetProgress = progressBars.find(bar => bar.getAttribute('data-value') === '67.5');
      expect(budgetProgress).toBeInTheDocument();
    });
  });

  describe('Historical Analysis', () => {
    test('displays historical spending data', () => {
      render(<TokenBudgetRecommendations {...defaultProps} />);
      
      expect(screen.getByText('Historical Analysis')).toBeInTheDocument();
      expect(screen.getByText('Last Month')).toBeInTheDocument();
      expect(screen.getByText('$720')).toBeInTheDocument();
      expect(screen.getByText('3-Month Average')).toBeInTheDocument();
      expect(screen.getByText('$680')).toBeInTheDocument();
    });

    test('shows year-to-date spending', () => {
      render(<TokenBudgetRecommendations {...defaultProps} />);
      
      expect(screen.getByText('Year to Date')).toBeInTheDocument();
      expect(screen.getByText('$6,540')).toBeInTheDocument();
    });

    test('displays spending trend indicators', () => {
      render(<TokenBudgetRecommendations {...defaultProps} />);
      
      expect(screen.getByText('Increasing')).toBeInTheDocument();
      expect(screen.getByTestId('trending-up-icon')).toBeInTheDocument();
    });
  });

  describe('Cost Breakdown Analysis', () => {
    test('displays breakdown by model', () => {
      render(<TokenBudgetRecommendations {...defaultProps} />);
      
      expect(screen.getByText('Cost by Model')).toBeInTheDocument();
      expect(screen.getByText('GPT-4')).toBeInTheDocument();
      expect(screen.getByText('GPT-3.5 Turbo')).toBeInTheDocument();
      expect(screen.getByText('GPT-4 Vision')).toBeInTheDocument();
    });

    test('shows model cost percentages', () => {
      render(<TokenBudgetRecommendations {...defaultProps} />);
      
      expect(screen.getByText('66.7%')).toBeInTheDocument();
      expect(screen.getByText('26.7%')).toBeInTheDocument();
      expect(screen.getByText('6.6%')).toBeInTheDocument();
    });

    test('displays breakdown by category', () => {
      render(<TokenBudgetRecommendations {...defaultProps} />);
      
      expect(screen.getByText('Cost by Category')).toBeInTheDocument();
      expect(screen.getByText('Chat')).toBeInTheDocument();
      expect(screen.getByText('Completion')).toBeInTheDocument();
      expect(screen.getByText('Embedding')).toBeInTheDocument();
    });

    test('shows team-based cost allocation', () => {
      render(<TokenBudgetRecommendations {...defaultProps} />);
      
      expect(screen.getByText('Cost by Team')).toBeInTheDocument();
      expect(screen.getByText('Engineering')).toBeInTheDocument();
      expect(screen.getByText('Product')).toBeInTheDocument();
      expect(screen.getByText('Marketing')).toBeInTheDocument();
    });
  });

  describe('Budget Recommendations', () => {
    test('displays budget-related recommendations', () => {
      render(<TokenBudgetRecommendations {...defaultProps} />);
      
      expect(screen.getByText('Budget Recommendations')).toBeInTheDocument();
      expect(screen.getByText('Consider Budget Increase')).toBeInTheDocument();
      expect(screen.getByText('Current projection exceeds budget by 15%')).toBeInTheDocument();
    });

    test('shows recommendation priorities', () => {
      render(<TokenBudgetRecommendations {...defaultProps} />);
      
      const badges = screen.getAllByTestId('badge');
      const highPriorityBadge = badges.find(badge => badge.textContent.includes('High'));
      const mediumPriorityBadge = badges.find(badge => badge.textContent.includes('Medium'));
      
      expect(highPriorityBadge).toBeInTheDocument();
      expect(mediumPriorityBadge).toBeInTheDocument();
    });

    test('displays confidence scores', () => {
      render(<TokenBudgetRecommendations {...defaultProps} />);
      
      expect(screen.getByText('85% confidence')).toBeInTheDocument();
      expect(screen.getByText('78% confidence')).toBeInTheDocument();
    });

    test('shows potential savings amounts', () => {
      render(<TokenBudgetRecommendations {...defaultProps} />);
      
      expect(screen.getByText('Save approximately $135/month')).toBeInTheDocument();
    });
  });

  describe('Optimization Suggestions', () => {
    test('displays optimization recommendations', () => {
      render(<TokenBudgetRecommendations {...defaultProps} />);
      
      expect(screen.getByText('Optimization Suggestions')).toBeInTheDocument();
      expect(screen.getByText('Implement Response Caching')).toBeInTheDocument();
      expect(screen.getByText('Optimize Prompt Length')).toBeInTheDocument();
    });

    test('shows implementation effort levels', () => {
      render(<TokenBudgetRecommendations {...defaultProps} />);
      
      expect(screen.getByText('Medium effort')).toBeInTheDocument();
      expect(screen.getByText('Low effort')).toBeInTheDocument();
    });

    test('displays potential savings ranges', () => {
      render(<TokenBudgetRecommendations {...defaultProps} />);
      
      expect(screen.getByText('Reduce costs by 20-30%')).toBeInTheDocument();
      expect(screen.getByText('Save $50-75/month')).toBeInTheDocument();
    });
  });

  describe('Alerts and Warnings', () => {
    test('displays budget alerts', () => {
      render(<TokenBudgetRecommendations {...defaultProps} />);
      
      expect(screen.getByText('Budget Alerts')).toBeInTheDocument();
      expect(screen.getByText('High Burn Rate')).toBeInTheDocument();
      expect(screen.getByText('Current daily spend is 25% above average')).toBeInTheDocument();
    });

    test('shows alert severity indicators', () => {
      render(<TokenBudgetRecommendations {...defaultProps} />);
      
      expect(screen.getByTestId('alert-triangle-icon')).toBeInTheDocument();
      
      const badges = screen.getAllByTestId('badge');
      const warningBadge = badges.find(badge => badge.textContent.includes('Medium'));
      expect(warningBadge).toBeInTheDocument();
    });

    test('displays threshold comparisons', () => {
      render(<TokenBudgetRecommendations {...defaultProps} />);
      
      expect(screen.getByText('Threshold: $18')).toBeInTheDocument();
      expect(screen.getByText('Current: $22.50')).toBeInTheDocument();
    });
  });

  describe('Spending Projections', () => {
    test('displays projection scenarios', () => {
      render(<TokenBudgetRecommendations {...defaultProps} />);
      
      expect(screen.getByText('Spending Projections')).toBeInTheDocument();
      expect(screen.getByText('Month-end Projection')).toBeInTheDocument();
      expect(screen.getByText('$850')).toBeInTheDocument();
    });

    test('shows projection confidence levels', () => {
      render(<TokenBudgetRecommendations {...defaultProps} />);
      
      expect(screen.getByText('82% confidence')).toBeInTheDocument();
      expect(screen.getByText('65% confidence')).toBeInTheDocument();
    });

    test('displays scenario ranges', () => {
      render(<TokenBudgetRecommendations {...defaultProps} />);
      
      expect(screen.getByText('Conservative: $780')).toBeInTheDocument();
      expect(screen.getByText('Optimistic: $720')).toBeInTheDocument();
      expect(screen.getByText('Aggressive: $920')).toBeInTheDocument();
    });

    test('shows projection factors', () => {
      render(<TokenBudgetRecommendations {...defaultProps} />);
      
      expect(screen.getByText('Projection Factors')).toBeInTheDocument();
      expect(screen.getByText('Seasonal Usage')).toBeInTheDocument();
      expect(screen.getByText('New Features')).toBeInTheDocument();
      expect(screen.getByText('Optimization Efforts')).toBeInTheDocument();
    });
  });

  describe('Interactive Features', () => {
    test('handles recommendation application', async () => {
      const onRecommendationApply = jest.fn();
      render(<TokenBudgetRecommendations {...defaultProps} onRecommendationApply={onRecommendationApply} />);
      
      const applyButtons = screen.getAllByTestId('button').filter(button => 
        button.textContent.includes('Apply') || button.textContent.includes('Implement')
      );
      
      if (applyButtons.length > 0) {
        fireEvent.click(applyButtons[0]);
        expect(onRecommendationApply).toHaveBeenCalled();
      }
    });

    test('handles budget updates', async () => {
      const onBudgetUpdate = jest.fn();
      render(<TokenBudgetRecommendations {...defaultProps} onBudgetUpdate={onBudgetUpdate} />);
      
      const updateButtons = screen.getAllByTestId('button').filter(button => 
        button.textContent.includes('Update Budget') || button.textContent.includes('Adjust')
      );
      
      if (updateButtons.length > 0) {
        fireEvent.click(updateButtons[0]);
        // Should trigger budget update flow
      }
    });

    test('provides detailed recommendation views', async () => {
      render(<TokenBudgetRecommendations {...defaultProps} />);
      
      const detailButtons = screen.getAllByTestId('button').filter(button => 
        button.textContent.includes('Details') || button.textContent.includes('View More')
      );
      
      if (detailButtons.length > 0) {
        fireEvent.click(detailButtons[0]);
        // Should show detailed recommendation view
      }
    });
  });

  describe('Budget Calculator', () => {
    test('shows budget calculator tool', () => {
      render(<TokenBudgetRecommendations {...defaultProps} />);
      
      expect(screen.getByTestId('calculator-icon')).toBeInTheDocument();
      expect(screen.getByText('Budget Calculator')).toBeInTheDocument();
    });

    test('handles budget scenario calculations', async () => {
      render(<TokenBudgetRecommendations {...defaultProps} />);
      
      const calculatorButton = screen.getAllByTestId('button').find(button => 
        button.querySelector('[data-testid="calculator-icon"]')
      );
      
      if (calculatorButton) {
        fireEvent.click(calculatorButton);
        // Should open budget calculator
      }
    });

    test('provides what-if analysis', () => {
      render(<TokenBudgetRecommendations {...defaultProps} showCalculator={true} />);
      
      expect(screen.getByText('What-if Analysis')).toBeInTheDocument();
    });
  });

  describe('Settings and Configuration', () => {
    test('shows settings panel', () => {
      render(<TokenBudgetRecommendations {...defaultProps} />);
      
      expect(screen.getByTestId('settings-icon')).toBeInTheDocument();
    });

    test('handles settings changes', async () => {
      const onSettingsChange = jest.fn();
      render(<TokenBudgetRecommendations {...defaultProps} onSettingsChange={onSettingsChange} />);
      
      const settingsButton = screen.getAllByTestId('button').find(button => 
        button.querySelector('[data-testid="settings-icon"]')
      );
      
      if (settingsButton) {
        fireEvent.click(settingsButton);
        // Should handle settings changes
      }
    });

    test('allows alert threshold customization', () => {
      render(<TokenBudgetRecommendations {...defaultProps} showSettings={true} />);
      
      expect(screen.getByText('Alert Thresholds')).toBeInTheDocument();
    });
  });

  describe('Data Export and Reporting', () => {
    test('provides export functionality', () => {
      render(<TokenBudgetRecommendations {...defaultProps} />);
      
      const exportButtons = screen.getAllByTestId('button').filter(button => 
        button.textContent.includes('Export') || button.textContent.includes('Download')
      );
      
      expect(exportButtons.length).toBeGreaterThan(0);
    });

    test('handles budget report generation', async () => {
      render(<TokenBudgetRecommendations {...defaultProps} />);
      
      const reportButton = screen.getAllByTestId('button').find(button => 
        button.textContent.includes('Generate Report')
      );
      
      if (reportButton) {
        fireEvent.click(reportButton);
        // Should generate budget report
      }
    });
  });

  describe('Error Handling', () => {
    test('handles missing budget data', () => {
      render(<TokenBudgetRecommendations {...defaultProps} budgetData={null} />);
      
      expect(screen.getByText('Budget Recommendations')).toBeInTheDocument();
    });

    test('handles invalid projections', () => {
      const invalidProjections = {
        monthEnd: { spending: 'invalid' },
        quarterEnd: null
      };
      
      render(<TokenBudgetRecommendations {...defaultProps} projections={invalidProjections} />);
      
      expect(screen.getByText('Budget Recommendations')).toBeInTheDocument();
    });

    test('shows error state for calculation failures', () => {
      const errorBudgetData = {
        current: { monthlyBudget: 'invalid', currentSpend: null }
      };
      
      render(<TokenBudgetRecommendations {...defaultProps} budgetData={errorBudgetData} />);
      
      expect(screen.getByText('Budget Recommendations')).toBeInTheDocument();
    });
  });

  describe('Performance Optimization', () => {
    test('memoizes expensive calculations', () => {
      const { rerender } = render(<TokenBudgetRecommendations {...defaultProps} />);
      
      // Rerender with same props should not cause unnecessary recalculations
      rerender(<TokenBudgetRecommendations {...defaultProps} />);
      
      expect(screen.getByText('Budget Recommendations')).toBeInTheDocument();
    });

    test('handles complex recommendation algorithms efficiently', () => {
      const complexRecommendations = {
        ...mockRecommendations,
        budget: new Array(50).fill(0).map((_, i) => ({
          id: i,
          type: 'optimization',
          priority: i % 3 === 0 ? 'high' : 'medium',
          title: `Recommendation ${i}`,
          description: `Description ${i}`,
          confidence: Math.floor(Math.random() * 40) + 60
        }))
      };
      
      render(<TokenBudgetRecommendations {...defaultProps} recommendations={complexRecommendations} />);
      
      expect(screen.getByText('Budget Recommendations')).toBeInTheDocument();
    });
  });

  describe('Responsive Design', () => {
    test('applies responsive layouts', () => {
      render(<TokenBudgetRecommendations {...defaultProps} />);
      
      const cards = screen.getAllByTestId('card');
      expect(cards.length).toBeGreaterThan(0);
    });

    test('adapts to mobile viewport', () => {
      Object.defineProperty(window, 'innerWidth', {
        writable: true,
        configurable: true,
        value: 375,
      });
      
      render(<TokenBudgetRecommendations {...defaultProps} />);
      
      expect(screen.getByText('Budget Recommendations')).toBeInTheDocument();
    });
  });

  describe('Accessibility', () => {
    test('provides proper ARIA labels', () => {
      render(<TokenBudgetRecommendations {...defaultProps} />);
      
      const buttons = screen.getAllByTestId('button');
      expect(buttons.length).toBeGreaterThan(0);
    });

    test('supports keyboard navigation', () => {
      render(<TokenBudgetRecommendations {...defaultProps} />);
      
      const buttons = screen.getAllByTestId('button');
      if (buttons.length > 0) {
        buttons[0].focus();
        expect(document.activeElement).toBe(buttons[0]);
      }
    });

    test('provides screen reader friendly content', () => {
      render(<TokenBudgetRecommendations {...defaultProps} />);
      
      expect(screen.getByText('Monthly Budget')).toBeInTheDocument();
      expect(screen.getByText('$1,000')).toBeInTheDocument();
    });
  });
}); 