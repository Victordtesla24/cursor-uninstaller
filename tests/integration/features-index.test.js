import * as FeatureComponents from '../../src/components/features/index.js';

describe('Features Index Exports', () => {
  test('exports all expected components', () => {
    const expectedExports = [
      'Header',
      'CostTracker',
      'ModelSelector',
      'SettingsPanel',
      'TokenUtilization',
      'UsageChart',
      'UsageStats',
      'EnhancedHeader',
      'MetricsPanel',
      'TokenBudgetRecommendations',
      'EnhancedAnalyticsDashboard',
      'ModelPerformanceComparison'
    ];

    expectedExports.forEach(componentName => {
      expect(FeatureComponents).toHaveProperty(componentName);
      expect(FeatureComponents[componentName]).toBeDefined();
    });
  });

  test('all exports are components or objects', () => {
    Object.values(FeatureComponents).forEach(component => {
      // Each export should be either a function (React component) or an object
      expect(['function', 'object'].includes(typeof component)).toBe(true);
    });
  });

  test('Header component is importable', () => {
    expect(typeof FeatureComponents.Header).toBe('function');
  });

  test('ModelSelector component is importable', () => {
    expect(typeof FeatureComponents.ModelSelector).toBe('function');
  });

  test('SettingsPanel component is importable', () => {
    expect(typeof FeatureComponents.SettingsPanel).toBe('function');
  });

  test('index file exports correct number of components', () => {
    const exportCount = Object.keys(FeatureComponents).length;
    expect(exportCount).toBe(12); // We expect 12 components based on the index file
  });
}); 