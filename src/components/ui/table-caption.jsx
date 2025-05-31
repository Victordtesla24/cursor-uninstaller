import React from 'react';

const TableCaption = ({ 
  className = '', 
  children,
  ...props 
}) => {
  return (
    <caption 
      className={`mt-4 text-sm text-muted-foreground ${className}`}
      {...props}
    >
      {children}
    </caption>
  );
};

export default TableCaption; 