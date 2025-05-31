import React from 'react';
import { RefreshCw } from 'lucide-react';
import Button from '../ui/button.jsx';

const RefreshButton = ({ 
  onRefresh,
  isLoading = false,
  className = '',
  children = 'Refresh',
  ...props 
}) => {
  return (
    <Button
      onClick={onRefresh}
      variant="outline"
      disabled={isLoading}
      className={`refresh-button ${className}`}
      {...props}
    >
      <RefreshCw className={`h-4 w-4 mr-2 ${isLoading ? 'animate-spin' : ''}`} />
      {children}
    </Button>
  );
};

export default RefreshButton; 