import React from 'react';
import { Card, CardContent, CardHeader, CardTitle, Badge, Progress } from '../ui';
import { TrendingUp, TrendingDown } from 'lucide-react';

const MetricCard = ({ 
  title, 
  value, 
  description, 
  icon: Icon, 
  trend, 
  change,
  color = 'blue',
  target,
  className = '',
  ...props 
}) => {
  const colorClasses = {
    blue: {
      bg: 'from-blue-50 to-blue-100 dark:from-blue-900/20 dark:to-blue-800/20',
      text: 'text-blue-900 dark:text-blue-100',
      icon: 'text-blue-600 dark:text-blue-400',
      accent: 'text-blue-600 dark:text-blue-400'
    },
    green: {
      bg: 'from-emerald-50 to-emerald-100 dark:from-emerald-900/20 dark:to-emerald-800/20',
      text: 'text-emerald-900 dark:text-emerald-100',
      icon: 'text-emerald-600 dark:text-emerald-400',
      accent: 'text-emerald-600 dark:text-emerald-400'
    },
    amber: {
      bg: 'from-amber-50 to-amber-100 dark:from-amber-900/20 dark:to-amber-800/20',
      text: 'text-amber-900 dark:text-amber-100',
      icon: 'text-amber-600 dark:text-amber-400',
      accent: 'text-amber-600 dark:text-amber-400'
    },
    purple: {
      bg: 'from-purple-50 to-purple-100 dark:from-purple-900/20 dark:to-purple-800/20',
      text: 'text-purple-900 dark:text-purple-100',
      icon: 'text-purple-600 dark:text-purple-400',
      accent: 'text-purple-600 dark:text-purple-400'
    }
  };

  const classes = colorClasses[color] || colorClasses.blue;
  const progress = target ? Math.min((parseFloat(value) / target) * 100, 100) : null;

  // Use enhanced styling if color is provided (MetricsPanel usage)
  if (color && colorClasses[color]) {
    // Generate test ID based on title
    const getIconTestId = (title) => {
      const iconMap = {
        'Response Time': 'clock-icon',
        'Reliability': 'shield-icon', 
        'Throughput': 'activity-icon',
        'Error Rate': 'alert-triangle-icon',
        'Cache Hit Rate': 'database-icon',
        'System Load': 'cpu-icon',
        'Memory Usage': 'database-icon',
        'Active Connections': 'target-icon'
      };
      return iconMap[title] || 'icon';
    };

    return (
      <div className={`bg-gradient-to-br ${classes.bg} p-4 rounded-xl shadow-sm hover:shadow-md transition-all duration-200 border border-slate-200/50 dark:border-slate-700/50 ${className}`} {...props}>
        <div className="flex items-start justify-between mb-3">
          <div className={`p-2 rounded-lg bg-white/80 dark:bg-slate-800/80 ${classes.icon}`}>
            {Icon && <Icon className="w-4 h-4 animate-pulse-soft" data-testid={getIconTestId(title)} />}
          </div>
          {change && (
            <Badge variant={trend === 'up' ? 'success' : trend === 'down' ? 'destructive' : 'secondary'} className="text-xs" data-testid="badge">
              {trend === 'up' ? (
                <TrendingUp className="w-3 h-3 mr-1" data-testid="trending-up-icon" />
              ) : trend === 'down' ? (
                <TrendingDown className="w-3 h-3 mr-1" data-testid="trending-down-icon" />
              ) : null}
              {change}
            </Badge>
          )}
        </div>
        
        <div className="space-y-1">
          <div className={`text-xs ${classes.accent} font-medium`}>{title}</div>
          <div className={`text-xl font-bold ${classes.text}`}>{value}</div>
          {description && (
            <div className="text-xs text-slate-600 dark:text-slate-400">{description}</div>
          )}
          {progress !== null && (
            <div className="mt-2">
              <Progress value={progress} className="h-1.5" data-testid="progress" />
              <div className="text-xs text-slate-500 dark:text-slate-400 mt-1">
                {progress.toFixed(1)}% of target
              </div>
            </div>
          )}
        </div>
      </div>
    );
  }

  // Default Card-based styling (backwards compatibility)
  return (
    <Card className={`metric-card hover-lift shadow-medium ${className}`} {...props}>
      <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
        <CardTitle className="text-sm font-medium">
          {title}
        </CardTitle>
        {Icon && <Icon className="h-4 w-4 text-muted-foreground animate-pulse-soft" />}
      </CardHeader>
      <CardContent>
        <div className="text-2xl font-bold">{value}</div>
        {description && (
          <p className="text-xs text-muted-foreground">
            {description}
          </p>
        )}
        {trend && (
          <div className={`text-xs ${trend.positive ? 'text-green-600' : 'text-red-600'}`}>
            {trend.value}
          </div>
        )}
      </CardContent>
    </Card>
  );
};

export default MetricCard;
