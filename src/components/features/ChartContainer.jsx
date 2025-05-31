import React from 'react';

const ChartContainer = ({ 
  className = '', 
  children,
  config = {},
  ...props 
}) => {
  return (
    <div 
      className={`relative w-full h-full ${className}`}
      {...props}
    >
      {children}
    </div>
  );
};

export default ChartContainer; 