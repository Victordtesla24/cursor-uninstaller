import React from 'react';

const SheetHeader = ({ 
  className = '', 
  children,
  ...props 
}) => {
  return (
    <div 
      className={`flex flex-col space-y-2 text-center sm:text-left ${className}`}
      {...props}
    >
      {children}
    </div>
  );
};

export default SheetHeader; 