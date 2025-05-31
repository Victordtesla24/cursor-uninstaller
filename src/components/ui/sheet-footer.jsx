import React from 'react';

const SheetFooter = ({ 
  className = '', 
  children,
  ...props 
}) => {
  return (
    <div 
      className={`flex flex-col-reverse sm:flex-row sm:justify-end sm:space-x-2 ${className}`}
      {...props}
    >
      {children}
    </div>
  );
};

export default SheetFooter; 