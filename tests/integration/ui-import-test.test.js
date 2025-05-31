/**
 * Simple UI Import Test
 * 
 * Tests to verify that UI components can be imported correctly
 */

describe('UI Component Import Test', () => {
  test('can import all UI components without errors', () => {
    // Test importing individual components
    expect(() => {
      const Card = require('../../src/components/ui/card.jsx').default;
      const CardContent = require('../../src/components/ui/card-content.jsx').default;
      const CardDescription = require('../../src/components/ui/card-description.jsx').default;
      const CardHeader = require('../../src/components/ui/card-header.jsx').default;
      const CardTitle = require('../../src/components/ui/card-title.jsx').default;
      const Tooltip = require('../../src/components/ui/tooltip.jsx').default;
      const TooltipContent = require('../../src/components/ui/tooltip-content.jsx').default;
      const TooltipProvider = require('../../src/components/ui/tooltip-provider.jsx').default;
      const TooltipTrigger = require('../../src/components/ui/tooltip-trigger.jsx').default;
      const Badge = require('../../src/components/ui/badge.jsx').default;
      const Separator = require('../../src/components/ui/separator.jsx').default;
      const Progress = require('../../src/components/ui/progress.jsx').default;
      const Button = require('../../src/components/ui/button.jsx').default;
      
      // Verify they are functions/components
      expect(typeof Card).toBe('function');
      expect(typeof CardContent).toBe('function');
      expect(typeof CardDescription).toBe('function');
      expect(typeof CardHeader).toBe('function');
      expect(typeof CardTitle).toBe('function');
      expect(typeof Tooltip).toBe('function');
      expect(typeof TooltipContent).toBe('function');
      expect(typeof TooltipProvider).toBe('function');
      expect(typeof TooltipTrigger).toBe('function');
      expect(typeof Badge).toBe('function');
      expect(typeof Separator).toBe('function');
      expect(typeof Progress).toBe('function');
      expect(typeof Button).toBe('function');
    }).not.toThrow();
  });

  test('can import from UI index file', () => {
    expect(() => {
      const {
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
        Separator,
        Progress,
        Button
      } = require('../../src/components/ui/index.js');
      
      // Verify they are functions/components
      expect(typeof Card).toBe('function');
      expect(typeof CardContent).toBe('function');
      expect(typeof CardDescription).toBe('function');
      expect(typeof CardHeader).toBe('function');
      expect(typeof CardTitle).toBe('function');
      expect(typeof Tooltip).toBe('function');
      expect(typeof TooltipContent).toBe('function');
      expect(typeof TooltipProvider).toBe('function');
      expect(typeof TooltipTrigger).toBe('function');
      expect(typeof Badge).toBe('function');
      expect(typeof Separator).toBe('function');
      expect(typeof Progress).toBe('function');
      expect(typeof Button).toBe('function');
    }).not.toThrow();
  });
}); 