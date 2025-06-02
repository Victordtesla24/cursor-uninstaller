const path = require('path');

describe('Debug Import Path Validation', () => {
  test('validates UI component imports from centralized index', () => {
    const uiIndex = require('../../src/components/ui/index.js');
    
    // Verify core UI components are properly exported
    expect(uiIndex.Card).toBeDefined();
    expect(typeof uiIndex.Card).toBe('function');
    
    expect(uiIndex.CardHeader).toBeDefined();
    expect(typeof uiIndex.CardHeader).toBe('function');
    
    expect(uiIndex.CardContent).toBeDefined();
    expect(typeof uiIndex.CardContent).toBe('function');
    
    expect(uiIndex.CardTitle).toBeDefined();
    expect(typeof uiIndex.CardTitle).toBe('function');
    
    expect(uiIndex.Button).toBeDefined();
    expect(typeof uiIndex.Button).toBe('function');
    
    expect(uiIndex.Badge).toBeDefined();
    expect(typeof uiIndex.Badge).toBe('function');
    
    expect(uiIndex.Progress).toBeDefined();
    expect(typeof uiIndex.Progress).toBe('object'); // forwardRef components are objects
    
    console.log('✓ All core UI components properly exported');
  });

  test('validates feature component imports after cleanup', () => {
    const featuresIndex = require('../../src/components/features/index.js');
    
    // Verify essential feature components remain
    expect(featuresIndex.MetricCard).toBeDefined();
    expect(typeof featuresIndex.MetricCard).toBe('function');
    
    // Verify the features index only exports MetricCard (streamlined)
    const exportedComponents = Object.keys(featuresIndex);
    expect(exportedComponents.length).toBe(1);
    expect(exportedComponents).toContain('MetricCard');
    
    console.log('✓ Feature components properly cleaned up - only essential MetricCard remains');
  });

  test('validates ModernDashboard uses centralized components', () => {
    // Test that ModernDashboard can be imported without errors
    const ModernDashboard = require('../../src/dashboard/ModernDashboard.jsx');
    expect(ModernDashboard.default).toBeDefined();
    expect(typeof ModernDashboard.default).toBe('function');
    
    // Verify ModernDashboard imports from correct centralized locations
    const dashboardSource = require('fs').readFileSync(
      path.resolve(__dirname, '../../src/dashboard/ModernDashboard.jsx'), 
      'utf8'
    );
    expect(dashboardSource).toContain("import {\n  MetricCard\n} from '../components/features/index.js'");
    expect(dashboardSource).toContain("} from '../components/ui/index.js'");
    
    console.log('✓ ModernDashboard uses centralized components correctly');
  });

  test('validates individual UI component files exist and are accessible', () => {
    const componentFiles = [
      'card.jsx',
      'card-header.jsx', 
      'card-content.jsx',
      'card-title.jsx',
      'button.jsx',
      'badge.jsx',
      'progress.jsx'
    ];
    
    componentFiles.forEach(file => {
      const componentPath = path.resolve(__dirname, `../../src/components/ui/${file}`);
      expect(() => require(componentPath)).not.toThrow();
    });
    
    console.log('✓ Individual UI component files accessible');
  });

  test('validates no circular dependencies in core components', () => {
    // Clear require cache to ensure fresh imports
    Object.keys(require.cache).forEach(key => {
      if (key.includes('src/components')) {
        delete require.cache[key];
      }
    });
    
    // Test importing components doesn't cause circular dependency errors
    expect(() => {
      const { Card, Button, Badge, Progress } = require('../../src/components/ui/index.js');
      const { MetricCard } = require('../../src/components/features/index.js');
      return { Card, Button, Badge, Progress, MetricCard };
    }).not.toThrow();
    
    console.log('✓ No circular dependencies detected');
  });

  test('validates enhanced styling integration', () => {
    const dashboardSource = require('fs').readFileSync(
      path.resolve(__dirname, '../../src/dashboard/ModernDashboard.jsx'), 
      'utf8'
    );
    
    // Verify enhanced CSS classes are applied
    expect(dashboardSource).toContain('glass-strong');
    expect(dashboardSource).toContain('glass ');
    expect(dashboardSource).toContain('dashboard-card');
    expect(dashboardSource).toContain('hover-lift');
    expect(dashboardSource).toContain('shadow-medium');
    expect(dashboardSource).toContain('animate-slide-up');
    expect(dashboardSource).toContain('animate-scale-in');
    expect(dashboardSource).toContain('animate-fade-in');
    expect(dashboardSource).toContain('text-gradient-');
    
    console.log('✓ Enhanced styling classes properly integrated');
  });

  test('validates streamlined codebase structure', () => {
    const fs = require('fs');
    
    // Verify main components index file was removed (it had non-existent component references)
    const mainIndexPath = path.resolve(__dirname, '../../src/components/index.js');
    expect(fs.existsSync(mainIndexPath)).toBe(false);
    
    // Verify only essential directories remain in components
    const componentsDir = path.resolve(__dirname, '../../src/components');
    const componentsDirContents = fs.readdirSync(componentsDir);
    expect(componentsDirContents).toContain('ui');
    expect(componentsDirContents).toContain('features');
    expect(componentsDirContents.length).toBe(2); // Only ui and features directories
    
    console.log('✓ Streamlined codebase structure achieved');
  });

  test('validates MetricCard component enhanced styling support', () => {
    const MetricCard = require('../../src/components/features/MetricCard.jsx');
    expect(MetricCard.default).toBeDefined();
    expect(typeof MetricCard.default).toBe('function');
    
    // Verify MetricCard source contains enhanced styling classes
    const metricCardSource = require('fs').readFileSync(
      path.resolve(__dirname, '../../src/components/features/MetricCard.jsx'), 
      'utf8'
    );
    expect(metricCardSource).toContain('metric-card');
    expect(metricCardSource).toContain('hover-lift');
    expect(metricCardSource).toContain('shadow-medium');
    expect(metricCardSource).toContain('animate-pulse-soft');
    
    console.log('✓ MetricCard component supports enhanced styling');
  });
});
