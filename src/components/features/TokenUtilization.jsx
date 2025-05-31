import React, { useMemo, useState, useEffect } from 'react';
import {
  Card, // Card is used in BudgetOverview
  CardContent, // CardContent is used in BudgetOverview
  Badge,
  Progress
} from "../ui/index.js";
import {
  Database,
  TrendingUp,
  TrendingDown,
  AlertTriangle,
  CheckCircle,
  Shield,
  Zap,
  Sparkles,
  BarChart3,
  CreditCard,
  Target,
  DollarSign,
  Timer,
  Activity
} from "lucide-react";

// Enhanced Token Category Card Component
function TokenCategoryCard({ category, usage, budget, percentage, icon, trend }) {
  const getStatusConfig = (percentage) => {
    if (percentage > 90) {
      return {
        color: 'red',
        bg: 'from-red-50 to-red-100 dark:from-red-900/20 dark:to-red-800/20',
        text: 'text-red-900 dark:text-red-100',
        accent: 'text-red-600 dark:text-red-400',
        status: 'Critical'
      };
    }
    if (percentage > 75) {
      return {
        color: 'amber',
        bg: 'from-amber-50 to-amber-100 dark:from-amber-900/20 dark:to-amber-800/20',
        text: 'text-amber-900 dark:text-amber-100',
        accent: 'text-amber-600 dark:text-amber-400',
        status: 'Warning'
      };
    }
    return {
      color: 'emerald',
      bg: 'from-emerald-50 to-emerald-100 dark:from-emerald-900/20 dark:to-emerald-800/20',
      text: 'text-emerald-900 dark:text-emerald-100',
      accent: 'text-emerald-600 dark:text-emerald-400',
      status: 'Good'
    };
  };

  const config = getStatusConfig(percentage);

  return (
    <div className={`bg-gradient-to-br ${config.bg} p-4 rounded-xl shadow-sm hover:shadow-md transition-all duration-200 border border-slate-200/50 dark:border-slate-700/50 group`}>
      <div className="flex items-start justify-between mb-3">
        <div className={`p-2 rounded-lg bg-white/80 dark:bg-slate-800/80 ${config.accent}`}>
          {icon}
        </div>
        <Badge 
          variant={percentage > 90 ? 'destructive' : percentage > 75 ? 'secondary' : 'success'}
          className="text-xs"
        >
          {config.status}
        </Badge>
      </div>
      
      <div className="space-y-3">
        <div>
          <div className={`text-xs ${config.accent} font-medium uppercase tracking-wide`}>
            {category}
          </div>
          <div className="flex items-baseline justify-between mt-1">
            <span className={`text-lg font-bold ${config.text}`}>
              {usage?.toLocaleString() || '0'}
            </span>
            <span className="text-xs text-slate-500 dark:text-slate-400">
              / {budget?.toLocaleString() || '0'}
            </span>
          </div>
        </div>
        
        <div className="space-y-2">
          <div className="flex items-center justify-between">
            <span className="text-xs text-slate-600 dark:text-slate-400">Usage</span>
            <span className={`text-xs font-medium ${config.accent}`}>
              {percentage.toFixed(1)}%
            </span>
          </div>
          <Progress value={percentage} className="h-2" />
        </div>

        {trend && (
          <div className="flex items-center justify-between text-xs">
            <span className="text-slate-600 dark:text-slate-400">Trend</span>
            <div className={`flex items-center space-x-1 ${trend.direction === 'up' ? 'text-emerald-600' : trend.direction === 'down' ? 'text-red-600' : 'text-slate-500'}`}>
              {trend.direction === 'up' ? (
                <TrendingUp className="w-3 h-3" />
              ) : trend.direction === 'down' ? (
                <TrendingDown className="w-3 h-3" />
              ) : null}
              <span>{trend.value}%</span>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

// Budget Overview Card
function BudgetOverview({ totalUsage, totalBudget, percentage, estimatedCost, tokensSaved, cacheEfficiency }) {
  const getOverallStatus = () => {
    if (percentage > 90) return { status: 'critical', icon: AlertTriangle, color: 'text-red-600 dark:text-red-400' };
    if (percentage > 75) return { status: 'warning', icon: AlertTriangle, color: 'text-amber-600 dark:text-amber-400' };
    return { status: 'good', icon: CheckCircle, color: 'text-emerald-600 dark:text-emerald-400' };
  };

  const statusConfig = getOverallStatus();
  const StatusIcon = statusConfig.icon;

  return (
    <Card className="bg-gradient-to-br from-slate-50 to-slate-100 dark:from-slate-900/50 dark:to-slate-800/50 border-slate-200 dark:border-slate-700">
      <CardContent className="p-6">
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center space-x-3">
            <div className="p-3 rounded-xl bg-gradient-to-br from-blue-500 to-purple-600 text-white shadow-lg">
              <Target className="h-6 w-6" />
            </div>
            <div>
              <h3 className="text-lg font-bold text-slate-900 dark:text-white">Overall Budget</h3>
              <p className="text-sm text-slate-600 dark:text-slate-400">Total token allocation</p>
            </div>
          </div>
          
          <div className={`flex items-center space-x-2 px-3 py-2 rounded-full bg-white dark:bg-slate-800 ${statusConfig.color}`}>
            <StatusIcon className="w-4 h-4" />
            <span className="text-sm font-medium capitalize">{statusConfig.status}</span>
          </div>
        </div>

        <div className="space-y-4">
          <div className="flex items-center justify-between">
            <span className="text-sm text-slate-600 dark:text-slate-400">Token Usage</span>
            <span className="text-lg font-bold text-slate-900 dark:text-white">
              {totalUsage.toLocaleString()} / {totalBudget.toLocaleString()}
            </span>
          </div>
          
          <div className="space-y-2">
            <div className="flex items-center justify-between">
              <span className="text-xs text-slate-600 dark:text-slate-400">Progress</span>
              <span className={`text-xs font-medium ${percentage > 90 ? 'text-red-600' : percentage > 75 ? 'text-amber-600' : 'text-emerald-600'}`}>
                {percentage.toFixed(1)}%
              </span>
            </div>
            <Progress value={percentage} className="h-3" />
          </div>

          <div className="grid grid-cols-3 gap-4 pt-4 border-t border-slate-200 dark:border-slate-700">
            <div className="text-center">
              <div className="flex items-center justify-center mb-2">
                <DollarSign className="w-4 h-4 text-blue-600 dark:text-blue-400" />
              </div>
              <div className="text-sm font-bold text-slate-900 dark:text-white">${estimatedCost}</div>
              <div className="text-xs text-slate-600 dark:text-slate-400">Est. Cost</div>
            </div>
            
            <div className="text-center">
              <div className="flex items-center justify-center mb-2">
                <Zap className="w-4 h-4 text-emerald-600 dark:text-emerald-400" />
              </div>
              <div className="text-sm font-bold text-slate-900 dark:text-white">{tokensSaved.toLocaleString()}</div>
              <div className="text-xs text-slate-600 dark:text-slate-400">Saved</div>
            </div>
            
            <div className="text-center">
              <div className="flex items-center justify-center mb-2">
                <Activity className="w-4 h-4 text-purple-600 dark:text-purple-400" />
              </div>
              <div className="text-sm font-bold text-slate-900 dark:text-white">{(cacheEfficiency * 100).toFixed(1)}%</div>
              <div className="text-xs text-slate-600 dark:text-slate-400">Cache Hit</div>
            </div>
          </div>
        </div>
      </CardContent>
    </Card>
  );
}

/**
 * Enhanced TokenUtilization Component with modern design
 */
const TokenUtilization = ({
  tokenData = {},
  costData = {},
  darkMode, // Added darkMode prop
  className = ''
}) => {
  const [isVisible, setIsVisible] = useState(false);
  const { usage = {}, budgets = {}, cacheEfficiency = 0 } = tokenData;

  // Animation effect on mount
  useEffect(() => {
    const timer = setTimeout(() => setIsVisible(true), 100);
    return () => clearTimeout(timer);
  }, []);

  // Helper function to calculate usage percentage
  const calculatePercentage = (used, total) => {
    if (!total) return 0;
    return Math.min(100, Math.round((used / total) * 100));
  };

  // Icon mapping for each category
  const categoryIconMap = useMemo(() => ({
    'prompt': <Zap className="h-4 w-4" />,
    'completion': <CheckCircle className="h-4 w-4" />,
    'embedding': <Sparkles className="h-4 w-4" />,
    'fine-tuning': <Shield className="h-4 w-4" />,
    'chat': <BarChart3 className="h-4 w-4" />,
    'vision': <CreditCard className="h-4 w-4" />
  }), []);

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

  // Generate mock trend data for demonstration
  const getTrend = (category) => {
    const trends = {
      prompt: { direction: 'up', value: '12.5' },
      completion: { direction: 'up', value: '8.3' },
      embedding: { direction: 'down', value: '5.2' },
      'fine-tuning': { direction: 'stable', value: '0.0' },
      chat: { direction: 'up', value: '15.7' },
      vision: { direction: 'down', value: '3.1' }
    };
    return trends[category] || { direction: 'stable', value: '0.0' };
  };

  // If no data available, show enhanced placeholder
  if (!usage.total && !budgets.total) {
    return (
      // Removed Card wrapper, styling will be applied directly or by parent
      <div className={`${className} ${darkMode ? 'bg-slate-800 text-slate-300' : 'bg-white text-slate-700'} p-6 rounded-xl shadow-lg`}>
        <div className="flex items-center space-x-3 mb-4">
          <div className={`p-2 rounded-lg ${darkMode ? 'bg-blue-600/30 text-blue-300' : 'bg-blue-100 text-blue-600'}`}>
            <Database className="h-5 w-5" />
          </div>
          <div>
            <h3 className={`text-lg font-semibold ${darkMode ? 'text-slate-100' : 'text-slate-800'}`}>
              Token Utilization
            </h3>
            <p className={`text-sm ${darkMode ? 'text-slate-400' : 'text-slate-500'}`}>
              Monitor token usage and budget allocation
            </p>
          </div>
        </div>
        <div className="flex flex-col items-center justify-center gap-4 h-40">
          <div className={`p-4 rounded-full ${darkMode ? 'bg-slate-700' : 'bg-slate-100'}`}>
            <Timer className={`h-8 w-8 ${darkMode ? 'text-slate-400' : 'text-slate-500'}`} />
          </div>
          <div className="text-center">
            <p className="font-medium">No token data available</p>
            <p className="text-sm">Usage metrics will appear here when available</p>
          </div>
        </div>
      </div>
    );
  }

  return (
    // Removed outer Card wrapper
    <div className={`space-y-6 ${className} ${isVisible ? 'animate-fade-in' : 'opacity-0'}`}>
      {/* Budget Overview - now uses darkMode prop */}
      <BudgetOverview
        totalUsage={usage.total || 0}
        totalBudget={budgets.total || 0}
        percentage={totalPercentage}
        estimatedCost={estimatedCost}
        tokensSaved={tokensSaved}
        cacheEfficiency={cacheEfficiency}
        darkMode={darkMode} 
      />

      {/* Category Breakdown - now uses darkMode prop */}
      <div className={`${darkMode ? 'bg-slate-800' : 'bg-white'} p-6 rounded-xl shadow-lg`}>
        <div className="flex items-center space-x-3 mb-4">
          <div className={`p-2 rounded-lg ${darkMode ? 'bg-emerald-600/30 text-emerald-300' : 'bg-emerald-100 text-emerald-600'}`}>
            <BarChart3 className="h-5 w-5" />
          </div>
          <div>
            <h3 className={`text-lg font-semibold ${darkMode ? 'text-slate-100' : 'text-slate-800'}`}>
              Category Breakdown
            </h3>
            <p className={`text-sm ${darkMode ? 'text-slate-400' : 'text-slate-500'}`}>
              Token usage by category and type
            </p>
          </div>
        </div>

        {categories.length > 0 ? (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
            {categories.map((category) => {
              const categoryUsage = usage[category] || 0;
              const categoryBudget = budgets[category] || 0;
              const percentage = calculatePercentage(categoryUsage, categoryBudget);
              const icon = categoryIconMap[category.toLowerCase()] || <Database className="h-4 w-4" />;
              const trend = getTrend(category);

              return (
                <TokenCategoryCard
                  key={category}
                  category={category}
                  usage={categoryUsage}
                  budget={categoryBudget}
                  percentage={percentage}
                  icon={icon}
                  trend={trend}
                  // Pass darkMode to TokenCategoryCard if it needs it, or adjust its styles internally
                />
              );
            })}
          </div>
        ) : (
          <div className={`text-center py-8 ${darkMode ? 'text-slate-400' : 'text-slate-500'}`}>
            <Database className="h-12 w-12 mx-auto mb-4 opacity-50" />
            <p>No category data available</p>
          </div>
        )}
      </div>

      {/* Performance Metrics - now uses darkMode prop */}
      <div className={`${darkMode ? 'bg-slate-800' : 'bg-white'} p-6 rounded-xl shadow-lg`}>
        <h3 className={`text-sm font-semibold mb-4 flex items-center ${darkMode ? 'text-slate-100' : 'text-slate-700'}`}>
          <Activity className={`w-4 h-4 mr-2 ${darkMode ? 'text-blue-400' : 'text-blue-500'}`} />
          Performance Insights
        </h3>
        
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div className="space-y-3">
            <div className="flex items-center justify-between">
              <span className={`text-xs ${darkMode ? 'text-slate-400' : 'text-slate-600'}`}>Budget Utilization</span>
              <div className="flex items-center space-x-2">
                <Progress value={totalPercentage} className="w-16 h-2" />
                <span className={`text-xs font-medium ${totalPercentage > 90 ? (darkMode ? 'text-red-400' : 'text-red-600') : totalPercentage > 75 ? (darkMode ? 'text-amber-400' : 'text-amber-600') : (darkMode ? 'text-emerald-400' : 'text-emerald-600')}`}>
                  {totalPercentage > 90 ? 'High' : totalPercentage > 75 ? 'Medium' : 'Optimal'}
                </span>
              </div>
            </div>

            <div className="flex items-center justify-between">
              <span className={`text-xs ${darkMode ? 'text-slate-400' : 'text-slate-600'}`}>Cache Efficiency</span>
              <div className="flex items-center space-x-2">
                <Progress value={cacheEfficiency * 100} className="w-16 h-2" />
                <span className={`text-xs font-medium ${cacheEfficiency > 0.8 ? (darkMode ? 'text-emerald-400' : 'text-emerald-600') : cacheEfficiency > 0.6 ? (darkMode ? 'text-amber-400' : 'text-amber-600') : (darkMode ? 'text-red-400' : 'text-red-600')}`}>
                  {cacheEfficiency > 0.8 ? 'Excellent' : cacheEfficiency > 0.6 ? 'Good' : 'Needs Attention'}
                </span>
              </div>
            </div>
          </div>

          <div className="space-y-3">
            <div className="flex items-center justify-between">
              <span className={`text-xs ${darkMode ? 'text-slate-400' : 'text-slate-600'}`}>Cost Efficiency</span>
              <div className="flex items-center space-x-2">
                <DollarSign className={`w-3 h-3 ${darkMode ? 'text-emerald-400' : 'text-emerald-600'}`} />
                <span className={`text-xs font-medium ${darkMode ? 'text-emerald-400' : 'text-emerald-600'}`}>
                  ${(parseFloat(estimatedCost) / (usage.total || 1) * 1000).toFixed(4)}/1K tokens
                </span>
              </div>
            </div>

            <div className="flex items-center justify-between">
              <span className={`text-xs ${darkMode ? 'text-slate-400' : 'text-slate-600'}`}>Tokens Saved</span>
              <div className="flex items-center space-x-2">
                <Zap className={`w-3 h-3 ${darkMode ? 'text-blue-400' : 'text-blue-600'}`} />
                <span className={`text-xs font-medium ${darkMode ? 'text-blue-400' : 'text-blue-600'}`}>
                  {tokensSaved.toLocaleString()}
                </span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default TokenUtilization;
