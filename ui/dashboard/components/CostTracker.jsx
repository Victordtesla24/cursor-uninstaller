import React, { useMemo } from 'react';
import { 
  Card, 
  CardContent, 
  CardDescription, 
  CardHeader, 
  CardTitle, 
  Tooltip, 
  TooltipContent, 
  TooltipProvider, 
  TooltipTrigger, 
  Badge, 
  Separator
} from "./ui/index.js";
import { 
  TrendingDown, 
  TrendingUp, 
  DollarSign, 
  CreditCard, 
  Clock, 
  BarChart3, 
  AlertCircle,
  PieChart,
  BanknoteIcon,
  Wallet,
  ArrowRight,
  ArrowUp,
  ArrowDown,
  Calculator
} from "lucide-react";

/**
 * CostTracker Component
 * 
 * Displays AI token usage costs, monthly expenses, and provides budget visualization.
 * Includes savings breakdowns, cost trends, and projected expenses.
 * 
 * @typedef {Object} CostData
 * @property {number} [total] - Total cost incurred
 * @property {number} [monthlyCost] - Current month's cost
 * @property {number} [projectedMonthlyCost] - Projected cost for the current month
 * @property {Object} [savings] - Cost savings information
 * @property {number} [savings.total] - Total cost saved
 * @property {number} [savings.caching] - Savings from cache hits
 * @property {number} [savings.optimizations] - Savings from other optimizations
 * @property {Object} [byModel] - Costs broken down by model
 * @property {number} [averageRate] - Average cost per 1K tokens
 * 
 * @param {Object} props - Component props
 * @param {CostData} [props.costData={}] - Cost and savings data
 * @param {string} [props.className=''] - Additional CSS class names
 * @param {boolean} [props.darkMode=false] - Whether dark mode is enabled
 * 
 * @returns {JSX.Element} Rendered component displaying cost tracking information
 * 
 * @example
 * // Basic usage
 * <CostTracker costData={costData} />
 * 
 * @example
 * // With dark mode and custom class
 * <CostTracker 
 *   costData={costData} 
 *   darkMode={true}
 *   className="my-custom-class"
 * />
 */
const CostTracker = ({ costData = {}, className = '', darkMode = false }) => {
  // Format currency with 2 decimal places
  const formatCurrency = (amount) => {
    if (amount === undefined || amount === null) return '—';
    return `$${amount.toFixed(2)}`;
  };

  // Format currency with auto decimal places based on value
  const formatCurrencyAuto = (amount) => {
    if (amount === undefined || amount === null) return '—';
    
    // For very small values (less than 0.01), show more decimal places
    if (amount < 0.01) {
      return `$${amount.toFixed(5)}`;
    }
    
    // For small values (less than 1), show 3 decimal places
    if (amount < 1) {
      return `$${amount.toFixed(3)}`;
    }
    
    // For normal values, show 2 decimal places
    return `$${amount.toFixed(2)}`;
  };

  // Format percentage change with sign
  const formatPercentChange = (value) => {
    if (value === undefined || value === null) return null;
    return {
      value: Math.abs(value).toFixed(1),
      isPositive: value >= 0
    };
  };

  // Helper to get color for cost trends
  const getTrendColorClass = (isPositive) => {
    // For costs, "up" is bad (red), "down" is good (green)
    return isPositive 
      ? "bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-400" 
      : "bg-emerald-100 text-emerald-800 dark:bg-emerald-900/30 dark:text-emerald-400";
  };

  // Handle empty or missing cost data
  if (!costData || Object.keys(costData).length === 0) {
    return (
      <Card className={`${className} shadow-sm hover:shadow-md transition-shadow duration-200`}>
        <CardHeader>
          <CardTitle className="flex items-center">
            <DollarSign className="mr-2 h-5 w-5 text-primary" />
            Cost Tracker
          </CardTitle>
          <CardDescription>
            No cost data available
          </CardDescription>
        </CardHeader>
        <CardContent className="flex flex-col items-center justify-center gap-3 h-48 text-muted-foreground">
          <AlertCircle className="h-10 w-10 text-amber-500 opacity-80" />
          <p className="text-center max-w-[250px]">Cost tracking information will appear here when available</p>
        </CardContent>
      </Card>
    );
  }

  // Extract data with defaults
  const { 
    daily = 0, 
    monthly = 0, 
    dailyChange = 0, 
    monthlyChange = 0,
    breakdown = {},
    averageRate = 0
  } = costData;

  // Format changes for display
  const formattedDailyChange = formatPercentChange(dailyChange);
  const formattedMonthlyChange = formatPercentChange(monthlyChange);
  
  // Calculate total cost for breakdown chart
  const totalCost = Object.values(breakdown).reduce((sum, curr) => sum + curr, 0);

  return (
    <Card className={`${className} shadow-sm hover:shadow-md transition-shadow duration-200`}>
      <CardHeader className="pb-3">
        <CardTitle className="flex items-center">
          <DollarSign className="mr-2 h-5 w-5 text-primary" />
          Cost Tracker
        </CardTitle>
        <CardDescription>
          Track and analyze your AI operation costs
        </CardDescription>
      </CardHeader>
      
      <CardContent className="space-y-6">
        {/* Main cost metrics with improved layout and responsive design */}
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-6 animate-in fade-in duration-300">
          <div className="space-y-2 p-4 bg-primary/5 dark:bg-primary/10 rounded-lg">
            <div className="flex items-center">
              <Clock className="h-4 w-4 text-muted-foreground mr-2" />
              <div className="text-sm font-medium">Daily Cost</div>
            </div>
            <div className="text-2xl font-bold">{formatCurrency(daily)}</div>
            
            {formattedDailyChange && (
              <div className="flex items-center gap-2">
                <Badge 
                  variant="outline" 
                  className={`flex items-center ${getTrendColorClass(formattedDailyChange.isPositive)}`}
                >
                  {formattedDailyChange.isPositive ? (
                    <TrendingUp className="mr-1 h-3 w-3" />
                  ) : (
                    <TrendingDown className="mr-1 h-3 w-3" />
                  )}
                  {formattedDailyChange.value}%
                </Badge>
                <span className="text-xs text-muted-foreground whitespace-nowrap">vs yesterday</span>
              </div>
            )}
          </div>
          
          <div className="space-y-2 p-4 bg-primary/5 dark:bg-primary/10 rounded-lg">
            <div className="flex items-center">
              <BanknoteIcon className="h-4 w-4 text-muted-foreground mr-2" />
              <div className="text-sm font-medium">Monthly Cost</div>
            </div>
            <div className="text-2xl font-bold">{formatCurrency(monthly)}</div>
            
            {formattedMonthlyChange && (
              <div className="flex items-center gap-2">
                <Badge 
                  variant="outline" 
                  className={`flex items-center ${getTrendColorClass(formattedMonthlyChange.isPositive)}`}
                >
                  {formattedMonthlyChange.isPositive ? (
                    <TrendingUp className="mr-1 h-3 w-3" />
                  ) : (
                    <TrendingDown className="mr-1 h-3 w-3" />
                  )}
                  {formattedMonthlyChange.value}%
                </Badge>
                <span className="text-xs text-muted-foreground whitespace-nowrap">vs last month</span>
              </div>
            )}
          </div>
        </div>
        
        <Separator className="my-1" />
        
        {/* Cost breakdown by model/category with improved visualization */}
        {breakdown && Object.keys(breakdown).length > 0 && (
          <div className="space-y-4 animate-in fade-in duration-300" style={{ animationDelay: "150ms" }}>
            <div className="flex items-center">
              <PieChart className="mr-2 h-4 w-4 text-primary" />
              <h3 className="text-sm font-medium">Cost Breakdown</h3>
            </div>
            
            <div className="space-y-3">
              {Object.entries(breakdown).map(([model, cost], index) => {
                // Calculate percentage of total
                const percentage = totalCost > 0 ? (cost / totalCost) * 100 : 0;
                
                // Generate a color based on the model name (for visual variety)
                const colorVariants = [
                  "primary/70",
                  "blue-500/70",
                  "emerald-500/70",
                  "violet-500/70",
                  "amber-500/70",
                  "pink-500/70"
                ];
                const colorClass = colorVariants[index % colorVariants.length];
                
                return (
                  <div 
                    key={model} 
                    className="relative animate-in fade-in slide-in-from-bottom-1 duration-300" 
                    style={{ animationDelay: `${index * 50}ms` }}
                  >
                    <div className="flex items-center justify-between mb-1">
                      <div className="flex items-center">
                        <div className={`h-3 w-3 rounded-full bg-${colorClass} mr-2`}></div>
                        <span className="text-sm font-medium">{model}</span>
                      </div>
                      <div className="flex items-center gap-3">
                        <span className="text-sm font-semibold">{formatCurrency(cost)}</span>
                        <Badge variant="outline" className="bg-muted text-muted-foreground text-xs">
                          {percentage.toFixed(1)}%
                        </Badge>
                      </div>
                    </div>
                    <div className="h-2 w-full bg-muted rounded-full overflow-hidden">
                      <div 
                        className={`h-full bg-${colorClass} rounded-full transition-all duration-1000 ease-out`} 
                        style={{ width: `${percentage}%` }}
                      ></div>
                    </div>
                  </div>
                );
              })}
            </div>
          </div>
        )}
        
        <Separator className="my-1" />
        
        {/* Rate information with improved visual design */}
        <div className="rounded-lg bg-muted/50 dark:bg-muted/20 p-4 animate-in fade-in duration-300" style={{ animationDelay: "300ms" }}>
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <CreditCard className="h-4 w-4 text-primary" />
              <span className="font-medium text-sm">Average Rate</span>
            </div>
            <TooltipProvider>
              <Tooltip>
                <TooltipTrigger className="font-medium">
                  <Badge variant="outline" className="bg-primary/10 text-primary border-primary/20 dark:bg-primary/20">
                    {formatCurrencyAuto(averageRate)} / 1K tokens
                  </Badge>
                </TooltipTrigger>
                <TooltipContent side="top">
                  <p>Average cost per 1,000 tokens across all models</p>
                </TooltipContent>
              </Tooltip>
            </TooltipProvider>
          </div>
          
          {costData.projectedMonthlyCost && (
            <div className="mt-4 flex flex-col space-y-2">
              <div className="flex items-center justify-between text-xs">
                <span className="text-muted-foreground flex items-center">
                  <Clock className="mr-1 h-3 w-3" />
                  Projected Monthly Cost:
                </span>
                <span className="font-medium text-sm">
                  {formatCurrency(costData.projectedMonthlyCost)}
                </span>
              </div>
              
              {/* Add visual representation for projected cost */}
              <div className="h-1.5 w-full bg-muted rounded-full overflow-hidden">
                <div 
                  className="h-full bg-primary/60 rounded-full transition-all duration-1000"
                  style={{ 
                    width: `${Math.min(100, (costData.projectedMonthlyCost / (monthly || 1)) * 100)}%` 
                  }}
                ></div>
              </div>
              
              <div className="flex justify-between text-xs text-muted-foreground pt-1">
                <span>Current: {formatCurrency(monthly)}</span>
                <span>Projected: {formatCurrency(costData.projectedMonthlyCost)}</span>
              </div>
            </div>
          )}
        </div>
      </CardContent>
    </Card>
  );
};

export default CostTracker;
