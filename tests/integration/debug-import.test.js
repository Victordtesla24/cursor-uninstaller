const path = require('path');

describe('Debug UI Import', () => {
  test('check what is exported from UI index', () => {
    const uiIndex = require('../../src/components/ui/index.js');
    console.log('UI Index exports:', Object.keys(uiIndex));
    console.log('Tooltip export:', uiIndex.Tooltip);
    console.log('Tooltip type:', typeof uiIndex.Tooltip);
    
    // Check individual tooltip file using absolute path
    const tooltipPath = path.resolve(__dirname, '../../src/components/ui/tooltip.jsx');
    console.log('Tooltip absolute path:', tooltipPath);
    
    // Clear require cache to ensure fresh load
    delete require.cache[tooltipPath];
    
    const tooltipFile = require(tooltipPath);
    console.log('Tooltip file exports:', Object.keys(tooltipFile));
    console.log('Tooltip default:', tooltipFile.default);
    console.log('Tooltip default type:', typeof tooltipFile.default);
    
    // Check other tooltip components
    const tooltipProvider = require('../../src/components/ui/tooltip-provider.jsx');
    console.log('TooltipProvider default:', typeof tooltipProvider.default);
    
    const tooltipContent = require('../../src/components/ui/tooltip-content.jsx');
    console.log('TooltipContent default:', typeof tooltipContent.default);
    
    const tooltipTrigger = require('../../src/components/ui/tooltip-trigger.jsx');
    console.log('TooltipTrigger default:', typeof tooltipTrigger.default);
    
    // Check if there's a specific issue with the index file import
    console.log('TooltipProvider from index:', typeof uiIndex.TooltipProvider);
    console.log('TooltipContent from index:', typeof uiIndex.TooltipContent);
    console.log('TooltipTrigger from index:', typeof uiIndex.TooltipTrigger);
    
    // Try to actually use the tooltip component
    try {
      const React = require('react');
      const TooltipDirect = tooltipFile.default;
      console.log('Direct tooltip import successful:', typeof TooltipDirect);
      
      if (TooltipDirect) {
        React.createElement(TooltipDirect, { children: 'test' });
        console.log('Tooltip element created successfully');
      }
    } catch (error) {
      console.log('Error creating tooltip element:', error.message);
    }
  });
}); 