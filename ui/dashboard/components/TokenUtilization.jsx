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
import { Progress } from "../../../components/ui/progress";
import {
  Database,
  Info,
  TrendingUp,
  TrendingDown,
  AlertTriangle,
  CheckCircle,
  Shield,
  Zap,
  Sparkles,
  BarChart3,
  CreditCard
} from "lucide-react";

/**
 * TokenUtilization Component
 *
 * Displays token usage metrics and budgets with visual indicators and accessibility features
 *
 * @param {Object} props Component props
 * @param {Object} props.tokenData Token usage and budget data
 * @param {Object} props.tokenData.usage Current token usage stats by category
 * @param {Object} props.tokenData.budgets Budget limits by category
 * @param {Number} props.tokenData.cacheEfficiency Percentage of tokens saved via caching
 * @param {Object} props.costData Token cost information
 * @param {String} props.className Additional CSS classes
 * @param {Boolean} props.darkMode Whether dark mode is enabled
 */
const TokenUtilization = ({
  tokenData = {},
  costData = {},
  className = '',
  darkMode = false
}) => {
  const { usage = {}, budgets = {}, cacheEfficiency } = tokenData;

  // Helper function to calculate usage percentage
  const calculatePercentage = (used, total) => {
    if (!total) return 0;
    return Math.min(100, Math.round((used / total) * 100));
  };

  // Memoized helpers for better performance
  const statusColorMapping = useMemo(() => ({
    high: darkMode ? "bg-red-500" : "bg-red-600",
    medium: darkMode ? "bg-amber-400" : "bg-amber-500",
    normal: darkMode ? "bg-emerald-500" : "bg-emerald-600",
  }), [darkMode]);

  const badgeColorMapping = useMemo(() => ({
    high: "bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-400",
    medium: "bg-amber-100 text-amber-800 dark:bg-amber-900/30 dark:text-amber-400",
    normal: "bg-emerald-100 text-emerald-800 dark:bg-emerald-900/30 dark:text-emerald-400",
  }), []);

  // Helper to determine color based on usage percentage
  const getStatusColor = useMemo(() => (percentage) => {
    if (percentage > 90) return statusColorMapping.high;
    if (percentage > 75) return statusColorMapping.medium;
    return statusColorMapping.normal;
  }, [statusColorMapping]);

  // Helper to get badge color variant for percentage
  const getBadgeColor = useMemo(() => (percentage) => {
    if (percentage > 90) return badgeColorMapping.high;
    if (percentage > 75) return badgeColorMapping.medium;
    return badgeColorMapping.normal;
  }, [badgeColorMapping]);

  // Icon mapping for each category
  const categoryIconMap = useMemo(() => ({
    'prompt': <Zap className="h-3.5 w-3.5" aria-hidden="true" />,
    'completion': <CheckCircle className="h-3.5 w-3.5" aria-hidden="true" />,
    'embedding': <Sparkles className="h-3.5 w-3.5" aria-hidden="true" />,
    'fine-tuning': <Shield className="h-3.5 w-3.5" aria-hidden="true" />,
    'chat': <BarChart3 className="h-3.5 w-3.5" aria-hidden="true" />,
    'vision': <CreditCard className="h-3.5 w-3.5" aria-hidden="true" />
  }), []);

  // Helper to get icon based on category
  const getCategoryIcon = useMemo(() => (category) => {
    return categoryIconMap[category.toLowerCase()] || null;
  }, [categoryIconMap]);

  // Get categories excluding 'total'
  const categories = useMemo(() =>
    Object.keys(budgets).filter(key => key !== 'total'),
  [budgets]);

  // Memoized total percentage calculation
  const totalPercentage = useMemo(() =>
    calculatePercentage(usage.total || 0, budgets.total || 0),
  [usage.total, budgets.total]);

  // Memoized cost calculation
  const estimatedCost = useMemo(() => {
    const rate = costData?.averageRate || 0.002;
    return (((usage.total || 0) / 1000) * rate).toFixed(2);
  }, [usage.total, costData?.averageRate]);

  // Memoized savings calculation
  const tokensSaved = useMemo(() => {
    if (cacheEfficiency === undefined) return 0;
    return Math.round((usage.total || 0) * cacheEfficiency);
  }, [usage.total, cacheEfficiency]);

  // If no data available, show placeholder message with improved visual design
  if (!usage.total && !budgets.total) {
    return (
      <Card
        className={`${className} shadow-sm hover:shadow-md transition-shadow duration-200`}
        aria-labelledby="token-utilization-empty-title"
      >
        <CardHeader>
          <CardTitle id="token-utilization-empty-title" className="flex items-center">
            <Database className="mr-2 h-5 w-5 text-primary" aria-hidden="true" />
            Token Utilization
          </CardTitle>
          <CardDescription>
            No token usage data available
          </CardDescription>
        </CardHeader>
        <CardContent className="flex flex-col items-center justify-center gap-3 h-48 text-muted-foreground">
          <AlertTriangle className="h-8 w-8 text-amber-500 opacity-80 animate-pulse" aria-hidden="true" />
          <p>Token usage metrics will appear here when available</p>
        </CardContent>
      </Card>
    );
  }

  return (
    <Card
      className={`${className} shadow-sm hover:shadow-md transition-shadow duration-200 animate-in fade-in duration-300 ${darkMode ? 'bg-card/95' : ''}`}
      aria-labelledby="token-utilization-title"
    >
      <CardHeader className="pb-3">
        <CardTitle id="token-utilization-title" className="flex items-center">
          <Database className="mr-2 h-5 w-5 text-primary" aria-hidden="true" />
          Token Utilization
        </CardTitle>
        <CardDescription>
          Token usage across different categories and overall budget
        </CardDescription>
      </CardHeader>
      <CardContent className="space-y-6">
        {/* Overall Budget Summary with improved visual design */}
        <div className="space-y-3">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <h3 className="font-semibold">Overall Budget</h3>
              <TooltipProvider>
                <Tooltip delayDuration={300}>
                  <TooltipTrigger asChild>
                    <Info className="h-4 w-4 text-muted-foreground cursor-help" aria-hidden="true" />
                  </TooltipTrigger>
                  <TooltipContent side="top">
                    <p>Total token usage across all categories</p>
                  </TooltipContent>
                </Tooltip>
              </TooltipProvider>
            </div>
            <div
              className="text-sm font-medium"
              aria-label={`${(usage.total || 0).toLocaleString()} tokens used out of ${(budgets.total || 0).toLocaleString()} tokens budgeted`}
            >
              {(usage.total || 0).toLocaleString()} / {(budgets.total || 0).toLocaleString()}
            </div>
          </div>

          <div className="relative">
            <Progress
              value={totalPercentage}
              className="h-3"
              aria-label={`Overall budget usage is at ${totalPercentage} percent`}
              aria-valuemin="0"
              aria-valuemax="100"
              aria-valuenow={totalPercentage}
            />

            {/* Critical threshold markers with enhanced visual design */}
            <div className="absolute top-0 left-[75%] h-full w-[1px] bg-amber-500/70 after:content-[''] after:absolute after:top-[-3px] after:left-[-2px] after:w-[5px] after:h-[5px] after:rounded-full after:bg-amber-500"></div>
            <div className="absolute top-0 left-[90%] h-full w-[1px] bg-red-500/70 after:content-[''] after:absolute after:top-[-3px] after:left-[-2px] after:w-[5px] after:h-[5px] after:rounded-full after:bg-red-500"></div>
          </div>

          <div className="flex flex-col sm:flex-row sm:justify-between gap-2 sm:gap-0">
            <Badge
              variant="outline"
              className={`${getBadgeColor(totalPercentage)} w-fit flex items-center gap-0.5 px-2 py-0.5`}
            >
              {totalPercentage > 75 ? <AlertTriangle className="h-3 w-3 mr-1" aria-hidden="true" /> : null}
              {totalPercentage}% used
            </Badge>
            <div
              className="text-sm text-muted-foreground flex items-center gap-1.5"
              aria-label={`Estimated cost: ${estimatedCost} dollars`}
            >
              <CreditCard className="h-3.5 w-3.5 opacity-70" aria-hidden="true" />
              Est. Cost: <span className="font-semibold">${estimatedCost}</span>
            </div>
          </div>
        </div>

        <Separator className="my-1" />

        {/* Categories Breakdown with improved visual design and animation */}
        <div className="space-y-4" aria-labelledby="budget-categories-heading">
          <h3 id="budget-categories-heading" className="text-sm font-semibold">Budget Categories</h3>

          <div className="grid gap-5">
            {categories.map((category, index) => {
              const used = usage[category] || 0;
              const budget = budgets[category] || 0;
              const percentage = calculatePercentage(used, budget);
              const categoryIcon = getCategoryIcon(category);

              return (
                <div
                  key={category}
                  className="space-y-2 animate-in fade-in slide-in-from-left duration-300"
                  style={{ animationDelay: `${index * 100}ms` }}
                  aria-labelledby={`category-${category}`}
                >
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-1.5">
                      {categoryIcon && (
                        <span className={`p-1 rounded-full ${darkMode ? 'bg-primary/20' : 'bg-primary/10'} text-primary`}>
                          {categoryIcon}
                        </span>
                      )}
                      <span id={`category-${category}`} className="capitalize text-sm font-medium">{category}</span>
                    </div>
                    <div
                      className="text-xs text-muted-foreground"
                      aria-label={`${used.toLocaleString()} tokens used out of ${budget.toLocaleString()} tokens budgeted for ${category}`}
                    >
                      {used.toLocaleString()} / {budget.toLocaleString()}
                    </div>
                  </div>

                  <div
                    className="relative h-2 w-full rounded-full bg-muted overflow-hidden"
                    role="progressbar"
                    aria-label={`${category} usage is at ${percentage} percent`}
                    aria-valuemin="0"
                    aria-valuemax="100"
                    aria-valuenow={percentage}
                  >
                    <div
                      className={`absolute left-0 top-0 h-full rounded-full ${getStatusColor(percentage)} transition-all duration-700 ease-in-out`}
                      style={{ width: `${percentage}%` }}
                    ></div>

                    {/* Add pulsing animation for high usage */}
                    {percentage > 90 && (
                      <div
                        className="absolute inset-0 bg-red-500/20 rounded-full animate-pulse"
                        aria-hidden="true"
                      ></div>
                    )}
                  </div>

                  <div className="flex items-center justify-between text-xs">
                    <Badge
                      variant="outline"
                      className={getBadgeColor(percentage)}
                    >
                      {percentage}%
                    </Badge>

                    {/* Show trend if available with improved visualization */}
                    {tokenData.trends && tokenData.trends[category] && (
                      <div className="flex items-center">
                        {tokenData.trends[category] > 0 ? (
                          <Badge
                            variant="outline"
                            className="bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-400 flex items-center"
                            aria-label={`Trending up ${tokenData.trends[category].toFixed(1)} percent`}
                          >
                            <TrendingUp className="mr-1 h-3 w-3" aria-hidden="true" />
                            {tokenData.trends[category].toFixed(1)}%
                          </Badge>
                        ) : (
                          <Badge
                            variant="outline"
                            className="bg-emerald-100 text-emerald-800 dark:bg-emerald-900/30 dark:text-emerald-400 flex items-center"
                            aria-label={`Trending down ${tokenData.trends[category].toFixed(1)} percent`}
                          >
                            <TrendingDown className="mr-1 h-3 w-3" aria-hidden="true" />
                            {tokenData.trends[category].toFixed(1)}%
                          </Badge>
                        )}
                      </div>
                    )}
                  </div>
                </div>
              );
            })}
          </div>
        </div>

        {/* Cache Efficiency with improved visual design */}
        {cacheEfficiency !== undefined && (
          <>
            <Separator className="my-1" />
            <div
              className={`rounded-lg ${darkMode ? 'bg-primary/15' : 'bg-primary/5'} p-4 animate-in fade-in duration-500 shadow-sm`}
              aria-labelledby="cache-efficiency-heading"
            >
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <Database className="h-4 w-4 text-primary" aria-hidden="true" />
                  <span id="cache-efficiency-heading" className="font-medium">Cache Efficiency</span>
                </div>
                <Badge
                  variant="outline"
                  className={`${darkMode ? 'bg-primary/25 border-primary/30' : 'bg-primary/10 border-primary/20'} text-primary`}
                  aria-label={`Cache efficiency is ${(cacheEfficiency * 100).toFixed(0)} percent`}
                >
                  {(cacheEfficiency * 100).toFixed(0)}%
                </Badge>
              </div>
              <p
                className="mt-2 text-xs text-muted-foreground"
                aria-label={`${tokensSaved.toLocaleString()} tokens saved through caching`}
              >
                Tokens saved through caching: <span className="font-semibold">{tokensSaved.toLocaleString()}</span>
              </p>

              {/* Enhanced visual representation of cache savings */}
              <div className="mt-3 pt-1">
                <div
                  className="h-2 w-full bg-muted rounded-full overflow-hidden"
                  role="progressbar"
                  aria-label={`Cache efficiency visual indicator at ${(cacheEfficiency * 100).toFixed(0)} percent`}
                  aria-valuemin="0"
                  aria-valuemax="100"
                  aria-valuenow={(cacheEfficiency * 100)}
                >
                  <div
                    className={`h-full rounded-full ${darkMode ? 'bg-primary/80' : 'bg-primary/60'} transition-all duration-1000 ease-in-out`}
                    style={{ width: `${cacheEfficiency * 100}%` }}
                  ></div>
                </div>

                {/* Add visual scale marks */}
                <div className="flex justify-between text-[10px] text-muted-foreground/70 mt-1 px-0.5">
                  <span>0%</span>
                  <span>50%</span>
                  <span>100%</span>
                </div>
              </div>

              {/* Add estimated savings note */}
              <div className="mt-3 text-xs text-muted-foreground bg-background/50 rounded p-2 border border-border/40">
                <div className="flex items-center gap-1">
                  <CreditCard className="h-3 w-3 text-primary/70" aria-hidden="true" />
                  <span className="font-medium">Estimated Savings:</span>
                  <span
                    className="font-semibold"
                    aria-label={`Saved ${(tokensSaved / 1000 * (costData?.averageRate || 0.002)).toFixed(2)} dollars through caching`}
                  >
                    ${(tokensSaved / 1000 * (costData?.averageRate || 0.002)).toFixed(2)}
                  </span>
                </div>
              </div>
            </div>
          </>
        )}
      </CardContent>
    </Card>
  );
};

export default TokenUtilization;
