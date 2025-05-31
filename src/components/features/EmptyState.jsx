import React from 'react';
import { FileX } from 'lucide-react';

const EmptyState = ({ 
  title = 'No data available',
  description = 'There is no data to display at the moment.',
  icon: Icon = FileX,
  action,
  className = '',
  ...props 
}) => {
  return (
    <div 
      className={`empty-state flex flex-col items-center justify-center p-8 text-center ${className}`}
      {...props}
    >
      <Icon className="h-12 w-12 text-muted-foreground mb-4" />
      <h3 className="text-lg font-medium text-foreground mb-2">{title}</h3>
      <p className="text-sm text-muted-foreground mb-4 max-w-sm">{description}</p>
      {action && (
        <div className="mt-4">
          {action}
        </div>
      )}
    </div>
  );
};

export default EmptyState; 