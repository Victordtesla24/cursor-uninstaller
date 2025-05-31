/**
 * UI Component Library
 *
 * This file exports all the UI components used in the dashboard
 */

// Import components from individual files
export { default as Card } from './card.jsx';
export { default as CardHeader } from './card-header.jsx';
export { default as CardTitle } from './card-title.jsx';
export { default as CardDescription } from './card-description.jsx';
export { default as CardContent } from './card-content.jsx';
export { default as Button } from './button.jsx';
export { default as Badge } from './badge.jsx';
export { default as Separator } from './separator.jsx';
export { default as Progress } from './progress.jsx';
export { default as Switch } from './switch.jsx';
export { default as TooltipProvider } from './tooltip-provider.jsx';
export { default as Tooltip } from './tooltip.jsx';
export { default as TooltipTrigger } from './tooltip-trigger.jsx';
export { default as TooltipContent } from './tooltip-content.jsx';
export { default as Input } from './input.jsx';
export { default as Label } from './label.jsx';

// Additional form components
export { default as Select } from './select.jsx';
export { default as SelectContent } from './select-content.jsx';
export { default as SelectItem } from './select-item.jsx';
export { default as SelectTrigger } from './select-trigger.jsx';
export { default as SelectValue } from './select-value.jsx';
export { default as Textarea } from './textarea.jsx';
export { default as Checkbox } from './checkbox.jsx';

// Radio components
export { default as RadioGroup } from './radio-group.jsx';
export { default as RadioGroupItem } from './radio-group-item.jsx';

// Slider component
export { default as Slider } from './slider.jsx';

// Avatar components
export { default as Avatar } from './avatar.jsx';
export { default as AvatarImage } from './avatar-image.jsx';
export { default as AvatarFallback } from './avatar-fallback.jsx';

// Popover components
export { default as Popover } from './popover.jsx';
export { default as PopoverContent } from './popover-content.jsx';
export { default as PopoverTrigger } from './popover-trigger.jsx';

// Dialog components
export { default as Dialog } from './dialog.jsx';
export { default as DialogContent } from './dialog-content.jsx';
export { default as DialogHeader } from './dialog-header.jsx';
export { default as DialogTitle } from './dialog-title.jsx';
export { default as DialogDescription } from './dialog-description.jsx';
export { default as DialogFooter } from './dialog-footer.jsx';
export { default as DialogTrigger } from './dialog-trigger.jsx';

// Sheet components
export { default as Sheet } from './sheet.jsx';
export { default as SheetContent } from './sheet-content.jsx';
export { default as SheetHeader } from './sheet-header.jsx';
export { default as SheetTitle } from './sheet-title.jsx';
export { default as SheetDescription } from './sheet-description.jsx';
export { default as SheetFooter } from './sheet-footer.jsx';
export { default as SheetTrigger } from './sheet-trigger.jsx';

// Tabs components
export { default as Tabs } from './tabs.jsx';
export { default as TabsList } from './tabs-list.jsx';
export { default as TabsTrigger } from './tabs-trigger.jsx';
export { default as TabsContent } from './tabs-content.jsx';

// Table components
export { default as Table } from './table.jsx';
export { default as TableHeader } from './table-header.jsx';
export { default as TableBody } from './table-body.jsx';
export { default as TableFooter } from './table-footer.jsx';
export { default as TableHead } from './table-head.jsx';
export { default as TableRow } from './table-row.jsx';
export { default as TableCell } from './table-cell.jsx';
export { default as TableCaption } from './table-caption.jsx';

// Export the original components from shadcn-ui
export { default as Collapsible } from './collapsible.jsx';
export { default as CollapsibleContent } from './collapsible-content.jsx';
export { default as CollapsibleTrigger } from './collapsible-trigger.jsx';

// Accordion components
export { default as Accordion } from './accordion.jsx';
export { default as AccordionContent } from './accordion-content.jsx';
export { default as AccordionItem } from './accordion-item.jsx';
export { default as AccordionTrigger } from './accordion-trigger.jsx';

// Re-export CardFooter which wasn't included in our shadcn-ui implementation
export { default as CardFooter } from './card-footer.jsx';
