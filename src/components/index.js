/**
 * Components barrel file
 * Re-exports all UI components to simplify imports
 */

// UI components from ./ui/index.js (which itself barrels individual .jsx files)
// Only re-export components that are actually defined within ui/dashboard/components/ui/
export {
  Card,
  CardHeader,
  CardTitle,
  CardDescription,
  CardContent,
  CardFooter,
  Button,
  Separator,
  Badge,
  Switch,
  Tooltip,
  TooltipTrigger,
  TooltipContent,
  TooltipProvider,
  Collapsible,
  CollapsibleTrigger,
  CollapsibleContent,
  Accordion,
  AccordionItem,
  AccordionTrigger,
  AccordionContent,
  Input,
  Label
} from './ui/index.js';

// Feature components (all dashboard components are in the features directory)
export { default as TokenUtilization } from './features/TokenUtilization.jsx';
export { default as CostTracker } from './features/CostTracker.jsx';
export { default as UsageChart } from './features/UsageChart.jsx';
export { default as SettingsPanel } from './features/SettingsPanel.jsx';
export { default as ModelSelector } from './features/ModelSelector.jsx';
export { default as MetricsPanel } from './features/MetricsPanel.jsx';
export { default as UsageStats } from './features/UsageStats.jsx';
export { default as Header } from './features/Header.jsx';
export { default as EnhancedHeader } from './features/EnhancedHeader.jsx';

// Additional feature components
export { default as TokenBudgetRecommendations } from './features/TokenBudgetRecommendations.jsx';
export { default as EnhancedAnalyticsDashboard } from './features/EnhancedAnalyticsDashboard.jsx';
export { default as ModelPerformanceComparison } from './features/ModelPerformanceComparison.jsx';
