import React from 'react';

const RadioGroup = ({ 
  value, 
  onValueChange, 
  className = '', 
  children,
  disabled = false,
  ...props 
}) => {
  return (
    <div 
      className={`grid gap-2 ${className}`}
      role="radiogroup"
      {...props}
    >
      {children}
    </div>
  );
};

export default RadioGroup; 