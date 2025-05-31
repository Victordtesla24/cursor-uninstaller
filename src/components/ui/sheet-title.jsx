import React from 'react';

const SheetTitle = ({ 
  className = '', 
  children,
  ...props 
}) => {
  return (
    <h2 
      className={`text-lg font-semibold text-foreground ${className}`}
      {...props}
    >
      {children}
    </h2>
  );
};

export default SheetTitle; 