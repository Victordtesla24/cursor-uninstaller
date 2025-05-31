import React from 'react';

const PopoverContent = ({ 
  className = '', 
  children,
  isOpen = false,
  align = 'center',
  side = 'bottom',
  ...props 
}) => {
  if (!isOpen) return null;

  return (
    <div 
      className={`absolute z-50 w-72 rounded-md border bg-popover p-4 text-popover-foreground shadow-md outline-none ${className}`}
      {...props}
    >
      {children}
    </div>
  );
};

export default PopoverContent; 