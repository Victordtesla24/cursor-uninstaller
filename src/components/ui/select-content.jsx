import React from 'react';

const SelectContent = ({ children, className = '', ...props }) => {
  return (
    <div 
      className={`absolute z-50 min-w-[8rem] overflow-hidden rounded-md border bg-popover p-1 text-popover-foreground shadow-md ${className}`}
      {...props}
    >
      {children}
    </div>
  );
};

export default SelectContent; 