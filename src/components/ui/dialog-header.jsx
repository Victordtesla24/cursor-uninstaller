import React from 'react';

const DialogHeader = ({ 
  className = '', 
  children,
  ...props 
}) => {
  return (
    <div 
      className={`flex flex-col space-y-1.5 text-center sm:text-left ${className}`}
      {...props}
    >
      {children}
    </div>
  );
};

export default DialogHeader; 