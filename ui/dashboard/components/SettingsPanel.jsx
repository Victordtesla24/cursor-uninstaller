import React, { useState } from 'react';
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
  CardFooter,
  Collapsible,
  CollapsibleContent,
  CollapsibleTrigger,
  Accordion,
  AccordionContent,
  AccordionItem,
  AccordionTrigger,
  Button,
  Input,
  Label,
  Switch,
  Badge,
  Separator,
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger
} from "./ui/index.js";
import {
  ChevronDown,
  ChevronUp,
  Settings,
  CreditCard,
  Save,
  X,
  Edit,
  Check,
  AlertCircle,
  Info,
  Bell,
  WrenchIcon,
  MonitorIcon,
  RefreshCwIcon,
  MoonIcon,
  LayoutGrid
} from "lucide-react";

/**
 * SettingsPanel Component
 *
 * Displays and allows editing of application settings and token budgets
 *
 * @param {Object} props Component props
 * @param {Object} props.settings Application settings
 * @param {Object} props.tokenBudgets Token budget settings
 * @param {Function} props.onSettingChange Callback for setting changes
 * @param {Function} props.onBudgetChange Callback for budget changes
 * @param {Boolean} props.isCollapsed Whether the panel is collapsed
 * @param {Function} props.onToggleCollapse Callback to toggle collapsed state
 * @param {String} props.className Additional CSS classes
 * @param {Boolean} props.darkMode Whether dark mode is enabled
 */
const SettingsPanel = ({
  settings = {},
  tokenBudgets = {},
  onSettingChange = () => {},
  onBudgetChange = () => {},
  isCollapsed = false,
  onToggleCollapse = () => {},
  className = '',
  darkMode = false
}) => {
  // State for editing budget values
  const [editingBudget, setEditingBudget] = useState(null);
  const [budgetValue, setBudgetValue] = useState('');
  const [budgetError, setBudgetError] = useState('');

  // Group settings by category with icons
  const settingsCategories = {
    general: {
      icon: <MonitorIcon className="h-4 w-4 text-blue-500" />,
      label: "General",
      settings: [
        { id: 'autoRefresh', label: 'Auto Refresh', description: 'Automatically refresh data at regular intervals', icon: <RefreshCwIcon className="h-4 w-4" /> },
        { id: 'darkMode', label: 'Dark Mode', description: 'Use dark color theme for the dashboard', icon: <MoonIcon className="h-4 w-4" /> },
        { id: 'compactMode', label: 'Compact Mode', description: 'Display information in a more condensed layout', icon: <LayoutGrid className="h-4 w-4" /> },
        { id: 'autoModelSelection', label: 'Auto Model Selection', description: 'Automatically select the most appropriate model based on context' },
        { id: 'cachingEnabled', label: 'Caching Enabled', description: 'Enable response caching to reduce token usage' },
        { id: 'contextWindowOptimization', label: 'Context Window Optimization', description: 'Optimize context window usage for better performance' },
        { id: 'outputMinimization', label: 'Output Minimization', description: 'Minimize output tokens where possible' }
      ]
    },
    notifications: {
      icon: <Bell className="h-4 w-4 text-amber-500" />,
      label: "Notifications",
      settings: [
        { id: 'budgetAlerts', label: 'Budget Alerts', description: 'Receive alerts when token usage approaches budget limits' },
        { id: 'performanceAlerts', label: 'Performance Alerts', description: 'Receive alerts for performance degradation' }
      ]
    },
    advanced: {
      icon: <WrenchIcon className="h-4 w-4 text-violet-500" />,
      label: "Advanced Settings",
      settings: [
        { id: 'detailedLogging', label: 'Detailed Logging', description: 'Enable detailed request and response logging' },
        { id: 'debugMode', label: 'Debug Mode', description: 'Enable additional debug information and controls' },
        { id: 'experimentalFeatures', label: 'Experimental Features', description: 'Enable experimental and beta features' }
      ]
    }
  };

  // Helper for finding the category of a setting
  const findSettingCategory = (settingId) => {
    for (const [category, {settings: items}] of Object.entries(settingsCategories)) {
      if (items.some(item => item.id === settingId)) {
        return category;
      }
    }
    return 'general'; // Default category
  };

  // Get all available settings (for test compatibility)
  const getAllSettings = () => {
    const allSettings = {};
    Object.values(settingsCategories).forEach(({settings: items}) => {
      items.forEach(setting => {
        allSettings[setting.id] = settings[setting.id] || false;
      });
    });
    return allSettings;
  };

  // Extract budget categories from tokenBudgets or use defaults
  const budgetCategories = tokenBudgets ? Object.keys(tokenBudgets).sort() : [];

  // Format number with commas for display
  const formatNumber = (num) => {
    return num?.toLocaleString() || '0';
  };

  // Handle starting to edit a budget
  const handleEditBudget = (category) => {
    setBudgetError('');
    setBudgetValue(tokenBudgets[category]?.toString().replace(/,/g, '') || '0');
    setEditingBudget(category);
  };

  // Handle saving a budget value
  const handleSaveBudget = (category) => {
    // Validate input
    const numValue = parseFloat(budgetValue.replace(/,/g, ''));

    if (isNaN(numValue)) {
      setBudgetError('Please enter a valid number');
      return;
    }

    if (numValue < 0) {
      setBudgetError('Budget cannot be negative');
      return;
    }

    // Save changes
    onBudgetChange(category, numValue);
    setEditingBudget(null);
    setBudgetError('');
  };

  // Handle canceling budget edit
  const handleCancelEdit = () => {
    setEditingBudget(null);
    setBudgetError('');
  };

  // Handle budget input change
  const handleBudgetChange = (e) => {
    const value = e.target.value.replace(/,/g, '');
    setBudgetValue(value);
    setBudgetError('');
  };

  // Get color for budget badges based on value
  const getBudgetBadgeColor = (category) => {
    const value = tokenBudgets[category];
    if (!value) return "bg-muted/50 text-muted-foreground";

    // For "total" category, use a different color
    if (category === "total") {
      return "bg-primary/10 text-primary dark:bg-primary/20";
    }

    return "bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-300";
  };

  // Render a toggle item for a setting
  const renderSettingToggle = (settingId, label, description, icon) => {
    const isEnabled = settings?.[settingId] || false;

    return (
      <div
        className="flex items-start justify-between space-y-0 py-3 px-1 hover:bg-muted/50 rounded-md transition-colors"
        key={settingId}
      >
        <div className="flex space-x-3">
          {icon && <div className="pt-0.5 text-muted-foreground">{icon}</div>}
          <div className="space-y-1">
            <Label
              htmlFor={`toggle-${settingId}`}
              className="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
            >
              {label}
            </Label>
            <p className="text-xs text-muted-foreground">
              {description}
            </p>
          </div>
        </div>
        <Switch
          id={`toggle-${settingId}`}
          checked={isEnabled}
          aria-checked={isEnabled ? 'true' : 'false'}
          onCheckedChange={(checked) => onSettingChange(settingId, checked)}
          data-testid={`setting-${settingId}`}
          className="mt-1"
        />
      </div>
    );
  };

  // If no settings available, show placeholder
  if (!settings && !tokenBudgets) {
    return (
      <Card className={`${className} shadow-sm hover:shadow-md transition-shadow duration-200`}>
        <CardHeader>
          <CardTitle className="flex items-center">
            <Settings className="mr-2 h-5 w-5 text-primary" />
            Settings
          </CardTitle>
          <CardDescription>
            No settings available
          </CardDescription>
        </CardHeader>
        <CardContent className="flex flex-col items-center justify-center gap-3 h-48 text-muted-foreground py-8">
          <AlertCircle className="h-10 w-10 text-amber-500 opacity-80" />
          <p className="text-center max-w-[250px]">Settings information will appear here when available</p>
        </CardContent>
      </Card>
    );
  }

  return (
    <Card className={`${className} shadow-sm hover:shadow-md transition-shadow duration-200`}>
      <CardHeader className="pb-3">
        <div className="flex items-center justify-between">
          <CardTitle className="flex items-center">
            <Settings className="mr-2 h-5 w-5 text-primary" />
            Settings
          </CardTitle>
          <Button
            variant="outline"
            size="sm"
            onClick={onToggleCollapse}
            className="h-8 w-8 p-0"
            aria-label={isCollapsed ? "Expand settings" : "Collapse settings"}
          >
            {isCollapsed ? <ChevronDown className="h-4 w-4" /> : <ChevronUp className="h-4 w-4" />}
          </Button>
        </div>
        <CardDescription>
          Configure dashboard settings and token budgets
        </CardDescription>
      </CardHeader>

      <Collapsible open={!isCollapsed} className="w-full">
        <CollapsibleContent className="animate-in slide-in-from-top-5 transition-all duration-300">
          <CardContent className="space-y-6 pt-2">
            {/* Settings Section */}
            {settings && Object.keys(settings).length > 0 && (
              <div className="space-y-4">
                <div className="flex items-center">
                  <h3 className="text-sm font-medium leading-none">Application Settings</h3>
                  <TooltipProvider>
                    <Tooltip>
                      <TooltipTrigger asChild>
                        <Info className="h-4 w-4 text-muted-foreground ml-1.5 cursor-help" />
                      </TooltipTrigger>
                      <TooltipContent>
                        <p className="text-xs">Configure how the dashboard works</p>
                      </TooltipContent>
                    </Tooltip>
                  </TooltipProvider>
                </div>

                <Accordion
                  type="single"
                  collapsible
                  className="w-full"
                  defaultValue="general" // Initially open the general settings
                >
                  {Object.entries(settingsCategories).map(([category, {icon, label, settings: items}]) => (
                    <AccordionItem
                      value={category}
                      key={category}
                      className="border-b border-border last:border-0"
                    >
                      <AccordionTrigger className="py-3 text-sm hover:no-underline">
                        <div className="flex items-center">
                          {icon}
                          <span className="ml-2">{label}</span>
                        </div>
                      </AccordionTrigger>
                      <AccordionContent className="animate-in slide-in-from-top-2 duration-200">
                        <div className="space-y-1 pt-1 pb-2">
                          {items.map(item =>
                            renderSettingToggle(item.id, item.label, item.description, item.icon)
                          )}
                        </div>
                      </AccordionContent>
                    </AccordionItem>
                  ))}
                </Accordion>
              </div>
            )}

            {/* Token Budgets Section */}
            {tokenBudgets && Object.keys(tokenBudgets).length > 0 && (
              <>
                <Separator className="my-2" />

                <div className="space-y-4 animate-in fade-in duration-500" style={{ animationDelay: "100ms" }}>
                  <div className="flex items-center">
                    <CreditCard className="mr-2 h-4 w-4 text-primary" />
                    <h3 className="text-sm font-medium leading-none">Token Budgets</h3>

                    <TooltipProvider>
                      <Tooltip>
                        <TooltipTrigger asChild>
                          <Info className="h-4 w-4 text-muted-foreground ml-1.5 cursor-help" />
                        </TooltipTrigger>
                        <TooltipContent>
                          <p className="text-xs">Set maximum token limits for each category</p>
                        </TooltipContent>
                      </Tooltip>
                    </TooltipProvider>
                  </div>

                  <div className="space-y-3 rounded-md border border-border p-3 bg-muted/10">
                    {budgetCategories.map((category, index) => (
                      <div
                        key={category}
                        className={`flex items-center justify-between py-2 px-2 rounded-md transition-all duration-200 ${
                          editingBudget === category ? 'bg-primary/5 dark:bg-primary/10' : 'hover:bg-muted/50'
                        } ${index !== 0 ? 'border-t border-border/50' : ''}`}
                      >
                        <div className="flex items-center">
                          {category === 'total' ? (
                            <Badge className="mr-2 bg-primary/20 text-primary hover:bg-primary/30 text-xs">
                              Total
                            </Badge>
                          ) : (
                            <span className="capitalize text-sm">{category}</span>
                          )}
                        </div>

                        {editingBudget === category ? (
                          <div className="flex items-center gap-2 animate-in fade-in zoom-in-95 duration-200">
                            <div className="space-y-1">
                              <Input
                                className={`w-[120px] text-right px-2 py-1 h-8 text-sm ${
                                  budgetError ? 'border-red-500 focus-visible:ring-red-500' : ''
                                }`}
                                value={budgetValue}
                                onChange={handleBudgetChange}
                                data-testid={`budget-input-${category}`}
                                autoFocus
                              />
                              {budgetError && (
                                <p className="text-xs text-red-500 absolute">{budgetError}</p>
                              )}
                            </div>
                            <Button
                              variant="ghost"
                              size="sm"
                              onClick={() => handleSaveBudget(category)}
                              className="h-7 w-7 p-0 text-green-600 hover:text-green-700 hover:bg-green-100 dark:hover:bg-green-900/20"
                              data-testid={`budget-save-${category}`}
                            >
                              <Check className="h-4 w-4" />
                            </Button>
                            <Button
                              variant="ghost"
                              size="sm"
                              onClick={handleCancelEdit}
                              className="h-7 w-7 p-0 text-muted-foreground hover:text-red-600 hover:bg-red-100 dark:hover:bg-red-900/20"
                              data-testid={`budget-cancel-${category}`}
                            >
                              <X className="h-4 w-4" />
                            </Button>
                          </div>
                        ) : (
                          <div className="flex items-center gap-2">
                            <Badge
                              variant="outline"
                              className={`px-2.5 py-1 h-6 font-medium ${getBudgetBadgeColor(category)}`}
                            >
                              {formatNumber(tokenBudgets[category])}
                            </Badge>
                            <Button
                              variant="ghost"
                              size="sm"
                              onClick={() => handleEditBudget(category)}
                              className="h-7 w-7 p-0 text-muted-foreground hover:text-primary"
                              data-testid={`budget-edit-${category}`}
                            >
                              <Edit className="h-3.5 w-3.5" />
                            </Button>
                          </div>
                        )}
                      </div>
                    ))}
                  </div>
                </div>
              </>
            )}
          </CardContent>
        </CollapsibleContent>
      </Collapsible>
    </Card>
  );
};

export default SettingsPanel;
