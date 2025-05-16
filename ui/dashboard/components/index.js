/**
 * Components barrel file
 * Re-exports all UI components to simplify imports
 */

// UI components
export { default as Card } from './ui/card.jsx';
export { default as Button } from './ui/button.jsx';
export { default as Separator } from './ui/separator.jsx';
export { default as Badge } from './ui/badge.jsx';
export { default as Tabs } from './ui/tabs.jsx';
export { default as Progress } from './ui/progress.jsx';
export { default as Switch } from './ui/switch.jsx';
export { default as Select } from './ui/select.jsx';

// Dashboard components
export { default as TokenUtilization } from './TokenUtilization.jsx';
export { default as CostTracker } from './CostTracker.jsx';
export { default as UsageChart } from './UsageChart.jsx';
export { default as SettingsPanel } from './SettingsPanel.jsx';
export { default as ModelSelector } from './ModelSelector.jsx';
export { default as MetricsPanel } from './MetricsPanel.jsx';
export { default as UsageStats } from './UsageStats.jsx';

// Feature components
export { default as TokenBudgetRecommendations } from './features/TokenBudgetRecommendations.jsx';
export { default as EnhancedAnalyticsDashboard } from './features/EnhancedAnalyticsDashboard.jsx';
export { default as ModelPerformanceComparison } from './features/ModelPerformanceComparison.jsx';

// Shadcn UI components - standardized to use local ui directory
export {
  CardHeader,
  CardTitle,
  CardDescription,
  CardContent,
  CardFooter
} from './ui/card.jsx';

export {
  Tooltip,
  TooltipTrigger,
  TooltipContent,
  TooltipProvider
} from './ui/tooltip.jsx';

export {
  Collapsible,
  CollapsibleTrigger,
  CollapsibleContent
} from './ui/collapsible.jsx';

export {
  Accordion,
  AccordionItem,
  AccordionTrigger,
  AccordionContent
} from './ui/accordion.jsx';
