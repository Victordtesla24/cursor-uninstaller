import React from 'react';

const TabsList = ({ 
  className = '', 
  children,
  ...props 
}) => {
  return (
    <div 
      className={`inline-flex h-10 items-center justify-center rounded-md bg-muted p-1 text-muted-foreground ${className}`}
      role="tablist"
      {...props}
    >
      {children}
    </div>
  );
};

export default TabsList; 