import React from 'react';

const DialogTitle = ({ 
  className = '', 
  children,
  ...props 
}) => {
  return (
    <h3 
      className={`text-lg font-semibold leading-none tracking-tight ${className}`}
      {...props}
    >
      {children}
    </h3>
  );
};

export default DialogTitle; 