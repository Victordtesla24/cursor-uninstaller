/**
 * Components barrel file
 * Re-exports all UI components to simplify imports
 */

// UI components
export { default as Card } from './ui/card';
export { default as Button } from './ui/button';
export { default as Separator } from './ui/separator';
export { default as Badge } from './ui/badge';
export { default as Tabs } from './ui/tabs';
export { default as Progress } from './ui/progress';
export { default as Switch } from './ui/switch';
export { default as Select } from './ui/select';

// Dashboard components
export { default as TokenUtilization } from './TokenUtilization';
export { default as CostTracker } from './CostTracker';
export { default as UsageChart } from './UsageChart';
export { default as SettingsPanel } from './SettingsPanel';
export { default as ModelSelector } from './ModelSelector';
export { default as MetricsPanel } from './MetricsPanel';
export { default as UsageStats } from './UsageStats';

// Feature components
export { default as TokenBudgetRecommendations } from './features/TokenBudgetRecommendations';
export { default as EnhancedAnalyticsDashboard } from './features/EnhancedAnalyticsDashboard';
export { default as ModelPerformanceComparison } from './features/ModelPerformanceComparison';

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
