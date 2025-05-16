import React, { useState, useEffect, useMemo } from 'react';
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
  Button,
  Separator,
  Badge,
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
} from "../ui";
import {
  BarChart3,
  TrendingUp,
  TrendingDown,
  AlertTriangle,
  CheckCircle,
  Sparkles,
  Lightbulb,
  ArrowRight,
  BarChart4,
  RotateCcw
} from "lucide-react";

/**
 * TokenBudgetRecommendations Component
 *
 * Analyzes token usage patterns and provides intelligent budget recommendations
 * based on historical data, usage trends, and anomaly detection.
 *
 * @param {Object} props
 * @param {Object} props.tokenData - Historical and current token usage data
 * @param {Function} props.onApplyRecommendation - Callback when recommendation is applied
 * @param {Boolean} props.darkMode - Whether dark mode is enabled
 */
const TokenBudgetRecommendations = ({
  tokenData = {},
  onApplyRecommendation,
  darkMode = false
}) => {
  const [recommendations, setRecommendations] = useState([]);
  const [analyzing, setAnalyzing] = useState(false);
  const [selectedRecommendation, setSelectedRecommendation] = useState(null);

  // Calculate recommendations based on usage patterns and historical data
  useEffect(() => {
    if (!tokenData.usage || !tokenData.history) return;

    generateRecommendations(tokenData);
  }, [tokenData]);

  // Generate recommendations based on token usage patterns
  const generateRecommendations = async (data) => {
    setAnalyzing(true);

    try {
      // Simulate analytics processing
      await new Promise(resolve => setTimeout(resolve, 1500));

      // This would be a real algorithm that analyzes usage patterns
      // For now, we'll generate mock recommendations
      const mockRecommendations = [
        {
          id: 'rec-1',
          category: 'prompt',
          currentBudget: data.budgets?.prompt || 500000,
          recommendedBudget: 650000,
          savings: 120,
          confidence: 0.87,
          reason: 'Increasing trend in prompt token usage over the past 2 weeks (+15%)',
          impact: 'Reduce potential throttling during peak usage',
          seasonalPattern: 'Weekly peak on Wednesdays',
        },
        {
          id: 'rec-2',
          category: 'completion',
          currentBudget: data.budgets?.completion || 750000,
          recommendedBudget: 600000,
          savings: 90,
          confidence: 0.92,
          reason: 'Steady decrease in completion token usage (-12% month-over-month)',
          impact: 'Optimize budget allocation without impact on performance',
          anomalies: 'No significant anomalies detected',
        },
        {
          id: 'rec-3',
          category: 'embedding',
          currentBudget: data.budgets?.embedding || 200000,
          recommendedBudget: 350000,
          savings: -95,
          confidence: 0.79,
          reason: 'Recent spike in embedding requests (2.1x increase)',
          impact: 'Prevent embedding request failures due to budget limits',
          anomalies: 'Unusual spike detected on May 10-12',
        }
      ];

      setRecommendations(mockRecommendations);
    } catch (error) {
      console.error('Error generating recommendations:', error);
    } finally {
      setAnalyzing(false);
    }
  };

  // Handle applying a recommendation
  const handleApplyRecommendation = (rec) => {
    if (onApplyRecommendation) {
      onApplyRecommendation(rec.category, rec.recommendedBudget);

      // Update the selected recommendation
      setSelectedRecommendation(rec.id);

      // Reset after a delay to show the success state
      setTimeout(() => {
        setSelectedRecommendation(null);
      }, 2000);
    }
  };

  // Format numbers for display
  const formatNumber = (num) => {
    return num.toLocaleString();
  };

  // Get the badge for confidence level
  const getConfidenceBadge = (confidence) => {
    if (confidence >= 0.9) {
      return "bg-emerald-100 text-emerald-800 dark:bg-emerald-900/30 dark:text-emerald-400";
    } else if (confidence >= 0.7) {
      return "bg-amber-100 text-amber-800 dark:bg-amber-900/30 dark:text-amber-400";
    } else {
      return "bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-400";
    }
  };

  // Get savings badge color
  const getSavingsBadge = (savings) => {
    if (savings > 0) {
      return "bg-emerald-100 text-emerald-800 dark:bg-emerald-900/30 dark:text-emerald-400";
    } else if (savings < 0) {
      return "bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-400";
    } else {
      return "bg-gray-100 text-gray-800 dark:bg-gray-800/30 dark:text-gray-400";
    }
  };

  if (recommendations.length === 0) {
    return (
      <Card className={`shadow-sm transition-shadow duration-200 ${darkMode ? 'bg-card/95' : ''}`}>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Lightbulb className="h-5 w-5 text-amber-500" aria-hidden="true" />
            Token Budget Recommendations
          </CardTitle>
          <CardDescription>
            Intelligent budget suggestions based on usage patterns
          </CardDescription>
        </CardHeader>
        <CardContent className="flex flex-col items-center justify-center space-y-4 py-8">
          {analyzing ? (
            <>
              <div className="h-12 w-12 animate-spin rounded-full border-4 border-primary border-t-transparent"></div>
              <p className="text-muted-foreground">Analyzing token usage patterns...</p>
            </>
          ) : (
            <>
              <Sparkles className="h-12 w-12 text-amber-500/80" aria-hidden="true" />
              <p>No budget recommendations available yet</p>
              <Button
                variant="outline"
                onClick={() => generateRecommendations(tokenData)}
                className="mt-2"
              >
                Generate Recommendations
              </Button>
            </>
          )}
        </CardContent>
      </Card>
    );
  }

  return (
    <Card className={`shadow-sm hover:shadow-md transition-shadow duration-200 ${darkMode ? 'bg-card/95' : ''}`}>
      <CardHeader className="pb-2">
        <div className="flex justify-between items-center">
          <div>
            <CardTitle className="flex items-center gap-2">
              <Lightbulb className="h-5 w-5 text-amber-500" aria-hidden="true" />
              Token Budget Recommendations
            </CardTitle>
            <CardDescription>
              Intelligent budget suggestions based on usage patterns
            </CardDescription>
          </div>
          <Button
            variant="ghost"
            size="sm"
            onClick={() => generateRecommendations(tokenData)}
            disabled={analyzing}
            className="h-8 w-8 p-0"
            aria-label="Refresh recommendations"
          >
            <RotateCcw className={`h-4 w-4 ${analyzing ? 'animate-spin' : ''}`} />
          </Button>
        </div>
      </CardHeader>
      <CardContent className="space-y-4">
        {recommendations.map((rec) => (
          <div
            key={rec.id}
            className={`rounded-lg border p-4 transition-all duration-200 animate-in fade-in ${selectedRecommendation === rec.id ? 'bg-primary/10 border-primary' : 'bg-card hover:bg-accent/50'}`}
          >
            <div className="flex flex-col gap-3">
              <div className="flex justify-between items-center">
                <div className="flex items-center gap-2">
                  <div className={`p-2 rounded-full ${rec.savings >= 0 ? 'bg-emerald-100 dark:bg-emerald-900/30' : 'bg-amber-100 dark:bg-amber-900/30'}`}>
                    {rec.savings >= 0 ? (
                      <TrendingDown className="h-5 w-5 text-emerald-600 dark:text-emerald-400" aria-hidden="true" />
                    ) : (
                      <TrendingUp className="h-5 w-5 text-amber-600 dark:text-amber-400" aria-hidden="true" />
                    )}
                  </div>
                  <div className="flex flex-col">
                    <span className="font-medium capitalize">{rec.category} Budget</span>
                    <TooltipProvider>
                      <Tooltip delayDuration={300}>
                        <TooltipTrigger asChild>
                          <span className="text-xs text-muted-foreground flex items-center cursor-help">
                            <span>Confidence:</span>
                            <Badge
                              variant="outline"
                              className={`ml-1 text-[10px] px-1 py-0 ${getConfidenceBadge(rec.confidence)}`}
                            >
                              {Math.round(rec.confidence * 100)}%
                            </Badge>
                          </span>
                        </TooltipTrigger>
                        <TooltipContent side="top" className="max-w-xs">
                          <p className="text-xs">{rec.reason}</p>
                          {rec.seasonalPattern && (
                            <p className="text-xs mt-1"><span className="font-medium">Pattern:</span> {rec.seasonalPattern}</p>
                          )}
                          {rec.anomalies && (
                            <p className="text-xs mt-1"><span className="font-medium">Anomalies:</span> {rec.anomalies}</p>
                          )}
                        </TooltipContent>
                      </Tooltip>
                    </TooltipProvider>
                  </div>
                </div>

                <Badge
                  variant="outline"
                  className={`${getSavingsBadge(rec.savings)} flex items-center gap-1`}
                >
                  {rec.savings > 0 ? (
                    <>
                      <CheckCircle className="h-3 w-3" aria-hidden="true" />
                      <span>${Math.abs(rec.savings)} savings</span>
                    </>
                  ) : rec.savings < 0 ? (
                    <>
                      <AlertTriangle className="h-3 w-3" aria-hidden="true" />
                      <span>${Math.abs(rec.savings)} increase</span>
                    </>
                  ) : (
                    <span>No change</span>
                  )}
                </Badge>
              </div>

              <div className="grid grid-cols-12 gap-4 items-center">
                <div className="col-span-5">
                  <div className="text-xs text-muted-foreground mb-1">Current Budget</div>
                  <div className="font-semibold">{formatNumber(rec.currentBudget)} tokens</div>
                </div>

                <div className="col-span-2 flex justify-center">
                  <ArrowRight className="h-4 w-4 text-muted-foreground" aria-hidden="true" />
                </div>

                <div className="col-span-5">
                  <div className="text-xs text-muted-foreground mb-1">Recommended</div>
                  <div className="font-semibold">{formatNumber(rec.recommendedBudget)} tokens</div>
                </div>
              </div>

              <div className="text-sm text-muted-foreground mt-1">
                {rec.impact}
              </div>

              <div className="flex justify-end mt-2">
                <Button
                  size="sm"
                  onClick={() => handleApplyRecommendation(rec)}
                  disabled={selectedRecommendation === rec.id}
                  className={selectedRecommendation === rec.id ? 'bg-emerald-600 hover:bg-emerald-700' : ''}
                >
                  {selectedRecommendation === rec.id ? (
                    <span className="flex items-center gap-1">
                      <CheckCircle className="h-4 w-4" aria-hidden="true" />
                      Applied
                    </span>
                  ) : (
                    'Apply Recommendation'
                  )}
                </Button>
              </div>
            </div>
          </div>
        ))}
      </CardContent>
    </Card>
  );
};

export default TokenBudgetRecommendations;
