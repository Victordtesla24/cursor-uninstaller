import React from 'react';

const DialogDescription = ({ 
  className = '', 
  children,
  ...props 
}) => {
  return (
    <p 
      className={`text-sm text-muted-foreground ${className}`}
      {...props}
    >
      {children}
    </p>
  );
};

export default DialogDescription; 