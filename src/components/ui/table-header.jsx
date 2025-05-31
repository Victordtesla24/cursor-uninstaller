import React from 'react';

const TableHeader = ({ 
  className = '', 
  children,
  ...props 
}) => {
  return (
    <thead 
      className={`[&_tr]:border-b ${className}`}
      {...props}
    >
      {children}
    </thead>
  );
};

export default TableHeader; 