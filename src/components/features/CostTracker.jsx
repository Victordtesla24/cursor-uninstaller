import React from 'react';
import {
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
  Badge,
  Separator
} from "../ui/index.js";
import {
  TrendingDown,
  TrendingUp,
  DollarSign,
  CreditCard,
  Clock,
  AlertCircle,
  PieChart,
  BanknoteIcon
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
const CostTracker = ({ costData = {}, className = '', darkMode = false }) => { // Changed _darkMode to darkMode
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
    if (darkMode) {
      return isPositive
        ? "bg-red-700/30 text-red-300"
        : "bg-emerald-700/30 text-emerald-300";
    }
    return isPositive
      ? "bg-red-100 text-red-700"
      : "bg-emerald-100 text-emerald-700";
  };

  // Handle empty or missing cost data
  if (!costData || Object.keys(costData).length === 0) {
    return (
      // Removed Card wrapper, styling applied directly or by parent
      <div className={`${className} ${darkMode ? 'bg-slate-800 text-slate-300' : 'bg-white text-slate-700'} p-6 rounded-xl shadow-lg`}>
        <div className="flex items-center space-x-3 mb-4">
          <div className={`p-2 rounded-lg ${darkMode ? 'bg-green-600/30 text-green-300' : 'bg-green-100 text-green-600'}`}>
            <DollarSign className="mr-0 h-5 w-5" /> {/* Adjusted icon margin */}
          </div>
          <div>
            <h3 className={`text-lg font-semibold ${darkMode ? 'text-slate-100' : 'text-slate-800'}`}>Cost Tracker</h3>
            <p className={`text-sm ${darkMode ? 'text-slate-400' : 'text-slate-500'}`}>No cost data available</p>
          </div>
        </div>
        <div className="flex flex-col items-center justify-center gap-3 h-40"> {/* Adjusted height */}
          <AlertCircle className={`h-10 w-10 ${darkMode ? 'text-amber-400' : 'text-amber-500'} opacity-80`} />
          <p className="text-center max-w-[250px]">Cost tracking information will appear here.</p>
        </div>
      </div>
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

  // Removed outer Card wrapper
  return (
    <div className={`${className} space-y-6`}>
      {/* Main cost metrics with improved layout and responsive design */}
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-6 animate-in fade-in duration-300">
        <div className={`space-y-2 p-5 rounded-xl shadow-md ${darkMode ? 'bg-slate-700/50' : 'bg-slate-50'}`}>
          <div className="flex items-center">
            <Clock className={`h-4 w-4 ${darkMode ? 'text-slate-400' : 'text-slate-500'} mr-2`} />
            <div className={`text-sm font-medium ${darkMode ? 'text-slate-300' : 'text-slate-600'}`}>Daily Cost</div>
          </div>
          <div className={`text-2xl font-bold ${darkMode ? 'text-white' : 'text-slate-900'}`}>{formatCurrency(daily)}</div>

          {formattedDailyChange && (
            <div className="flex items-center gap-2">
              <Badge
                variant="outline"
                className={`flex items-center text-xs px-2 py-0.5 ${getTrendColorClass(formattedDailyChange.isPositive)}`}
              >
                {formattedDailyChange.isPositive ? (
                  <TrendingUp className="mr-1 h-3 w-3" />
                ) : (
                  <TrendingDown className="mr-1 h-3 w-3" />
                )}
                {formattedDailyChange.value}%
              </Badge>
              <span className={`text-xs ${darkMode ? 'text-slate-400' : 'text-slate-500'} whitespace-nowrap`}>vs yesterday</span>
            </div>
          )}
        </div>

        <div className={`space-y-2 p-5 rounded-xl shadow-md ${darkMode ? 'bg-slate-700/50' : 'bg-slate-50'}`}>
          <div className="flex items-center">
            <BanknoteIcon className={`h-4 w-4 ${darkMode ? 'text-slate-400' : 'text-slate-500'} mr-2`} />
            <div className={`text-sm font-medium ${darkMode ? 'text-slate-300' : 'text-slate-600'}`}>Monthly Cost</div>
          </div>
          <div className={`text-2xl font-bold ${darkMode ? 'text-white' : 'text-slate-900'}`}>{formatCurrency(monthly)}</div>

          {formattedMonthlyChange && (
            <div className="flex items-center gap-2">
              <Badge
                variant="outline"
                className={`flex items-center text-xs px-2 py-0.5 ${getTrendColorClass(formattedMonthlyChange.isPositive)}`}
              >
                {formattedMonthlyChange.isPositive ? (
                  <TrendingUp className="mr-1 h-3 w-3" />
                ) : (
                  <TrendingDown className="mr-1 h-3 w-3" />
                )}
                {formattedMonthlyChange.value}%
              </Badge>
              <span className={`text-xs ${darkMode ? 'text-slate-400' : 'text-slate-500'} whitespace-nowrap`}>vs last month</span>
            </div>
          )}
        </div>
      </div>

      <Separator className={`${darkMode ? 'bg-slate-700' : 'bg-slate-200'} my-4`} />

      {/* Cost breakdown by model/category with improved visualization */}
      {breakdown && Object.keys(breakdown).length > 0 && (
        <div className="space-y-4 animate-in fade-in duration-300" style={{ animationDelay: "150ms" }}>
          <div className="flex items-center">
            <PieChart className={`mr-2 h-4 w-4 ${darkMode ? 'text-blue-400' : 'text-blue-600'}`} />
            <h3 className={`text-sm font-medium ${darkMode ? 'text-slate-200' : 'text-slate-700'}`}>Cost Breakdown</h3>
          </div>

          <div className="space-y-3">
            {Object.entries(breakdown).map(([model, cost], index) => {
              const percentage = totalCost > 0 ? (cost / totalCost) * 100 : 0;
              const colorVariants = [
                darkMode ? "bg-blue-500/70" : "bg-blue-500/70",
                darkMode ? "bg-emerald-500/70" : "bg-emerald-500/70",
                darkMode ? "bg-violet-500/70" : "bg-violet-500/70",
                darkMode ? "bg-amber-500/70" : "bg-amber-500/70",
                darkMode ? "bg-pink-500/70" : "bg-pink-500/70",
                darkMode ? "bg-cyan-500/70" : "bg-cyan-500/70",
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
                      <div className={`h-3 w-3 rounded-full ${colorClass} mr-2`}></div>
                      <span className={`text-sm font-medium ${darkMode ? 'text-slate-300' : 'text-slate-700'}`}>{model}</span>
                    </div>
                    <div className="flex items-center gap-3">
                      <span className={`text-sm font-semibold ${darkMode ? 'text-slate-100' : 'text-slate-800'}`}>{formatCurrency(cost)}</span>
                      <Badge variant="outline" className={`${darkMode ? 'bg-slate-700 text-slate-300 border-slate-600' : 'bg-slate-100 text-slate-600 border-slate-300'} text-xs px-1.5 py-0.5`}>
                        {percentage.toFixed(1)}%
                      </Badge>
                    </div>
                  </div>
                  <div className={`h-2 w-full ${darkMode ? 'bg-slate-700' : 'bg-slate-200'} rounded-full overflow-hidden`}>
                    <div
                      className={`h-full ${colorClass} rounded-full transition-all duration-1000 ease-out`}
                      style={{ width: `${percentage}%` }}
                    ></div>
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      )}

      <Separator className={`${darkMode ? 'bg-slate-700' : 'bg-slate-200'} my-4`} />

      {/* Rate information with improved visual design */}
      <div className={`rounded-lg ${darkMode ? 'bg-slate-700/50' : 'bg-slate-100/70'} p-4 animate-in fade-in duration-300`} style={{ animationDelay: "300ms" }}>
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <CreditCard className={`h-4 w-4 ${darkMode ? 'text-blue-400' : 'text-blue-600'}`} />
            <span className={`font-medium text-sm ${darkMode ? 'text-slate-200' : 'text-slate-700'}`}>Average Rate</span>
          </div>
          <TooltipProvider>
            <Tooltip>
              <TooltipTrigger className="font-medium">
                <Badge variant="outline" className={`${darkMode ? 'bg-blue-600/30 text-blue-300 border-blue-500/50' : 'bg-blue-100 text-blue-600 border-blue-300/50'} px-2 py-1`}>
                  {formatCurrencyAuto(averageRate)} / 1K tokens
                </Badge>
              </TooltipTrigger>
              <TooltipContent side="top" className={`${darkMode ? 'bg-slate-800 text-slate-200 border-slate-700' : 'bg-white text-slate-700 border-slate-200'}`}>
                <p>Average cost per 1,000 tokens across all models</p>
              </TooltipContent>
            </Tooltip>
          </TooltipProvider>
        </div>

        {costData.projectedMonthlyCost && (
          <div className="mt-4 flex flex-col space-y-2">
            <div className="flex items-center justify-between text-xs">
              <span className={`${darkMode ? 'text-slate-400' : 'text-slate-500'} flex items-center`}>
                <Clock className="mr-1 h-3 w-3" />
                Projected Monthly Cost:
              </span>
              <span className={`font-medium text-sm ${darkMode ? 'text-slate-100' : 'text-slate-800'}`}>
                {formatCurrency(costData.projectedMonthlyCost)}
              </span>
            </div>

            <div className={`h-1.5 w-full ${darkMode ? 'bg-slate-600' : 'bg-slate-200'} rounded-full overflow-hidden`}>
              <div
                className={`h-full ${darkMode ? 'bg-blue-500' : 'bg-blue-600'} rounded-full transition-all duration-1000`}
                style={{
                  width: `${Math.min(100, (costData.projectedMonthlyCost / (monthly || 1)) * 100)}%`
                }}
              ></div>
            </div>

            <div className={`flex justify-between text-xs ${darkMode ? 'text-slate-400' : 'text-slate-500'} pt-1`}>
              <span>Current: {formatCurrency(monthly)}</span>
              <span>Projected: {formatCurrency(costData.projectedMonthlyCost)}</span>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default CostTracker;
